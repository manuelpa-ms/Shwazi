#!/usr/bin/env bash
set -euo pipefail

artifact="${1:-build/app/outputs/bundle/release/app-release.aab}"

if [[ ! -f "$artifact" ]]; then
  echo "Artifact not found: $artifact" >&2
  exit 1
fi

android_sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
objdump_bin=""

if command -v llvm-objdump >/dev/null 2>&1; then
  objdump_bin="$(command -v llvm-objdump)"
elif [[ -d "$android_sdk" ]]; then
  objdump_bin="$(find "$android_sdk/ndk" -path '*/toolchains/llvm/prebuilt/*/bin/llvm-objdump' -type f 2>/dev/null | sort | tail -n 1 || true)"
fi

if [[ -z "$objdump_bin" ]] && command -v objdump >/dev/null 2>&1; then
  objdump_bin="$(command -v objdump)"
fi

if [[ -z "$objdump_bin" ]]; then
  echo "Could not find llvm-objdump or objdump." >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

unzip -q "$artifact" -d "$tmp_dir"

shared_objects_file="$tmp_dir/shared_objects.txt"
find "$tmp_dir" -name '*.so' -type f | sort > "$shared_objects_file"

if [[ ! -s "$shared_objects_file" ]]; then
  echo "No native shared libraries found in $artifact."
  exit 0
fi

failed=0

while IFS= read -r shared_object; do
  relative_path="${shared_object#$tmp_dir/}"
  load_lines="$($objdump_bin -p "$shared_object" | grep 'LOAD' || true)"

  if [[ -z "$load_lines" ]]; then
    echo "UNVERIFIED $relative_path: no LOAD segments reported"
    failed=1
    continue
  fi

  min_alignment=999
  while IFS= read -r line; do
    if [[ "$line" =~ align[[:space:]]+2\*\*([0-9]+) ]]; then
      exponent="${BASH_REMATCH[1]}"
      if (( exponent < min_alignment )); then
        min_alignment="$exponent"
      fi
    fi
  done <<< "$load_lines"

  if (( min_alignment == 999 )); then
    echo "UNVERIFIED $relative_path: could not parse LOAD alignment"
    failed=1
  elif (( min_alignment < 14 )); then
    echo "UNALIGNED $relative_path: minimum LOAD alignment is 2**$min_alignment"
    failed=1
  else
    echo "ALIGNED   $relative_path: minimum LOAD alignment is 2**$min_alignment"
  fi
done < "$shared_objects_file"

if [[ "$artifact" == *.apk ]]; then
  zipalign_bin=""
  if command -v zipalign >/dev/null 2>&1; then
    zipalign_bin="$(command -v zipalign)"
  elif [[ -d "$android_sdk" ]]; then
    zipalign_bin="$(find "$android_sdk/build-tools" -name zipalign -type f 2>/dev/null | sort | tail -n 1 || true)"
  fi

  if [[ -n "$zipalign_bin" ]]; then
    "$zipalign_bin" -c -P 16 -v 4 "$artifact" >/dev/null
    echo "ZIPALIGNED $artifact: 16 KB zip alignment verified"
  else
    echo "SKIPPED zipalign check: zipalign not found"
  fi
fi

if (( failed != 0 )); then
  exit 1
fi