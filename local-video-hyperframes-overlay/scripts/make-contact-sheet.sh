#!/usr/bin/env bash
set -euo pipefail

frames_dir="${1:-qa}"
output="${2:-contact.png}"
shift 2 || true

files=()
if [[ "$#" -gt 0 ]]; then
  for sec in "$@"; do
    files+=("$frames_dir/$sec.png")
  done
else
  while IFS= read -r file; do
    files+=("$file")
  done < <(find "$frames_dir" -maxdepth 1 -type f -name '*.png' | sort -V | head -n 6)
fi

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "no png frames found in $frames_dir" >&2
  exit 1
fi

for file in "${files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing frame: $file" >&2
    exit 1
  fi
done

while [[ "${#files[@]}" -lt 6 ]]; do
  files+=("${files[-1]}")
done

ffmpeg -hide_banner -loglevel error -y \
  -i "${files[0]}" -i "${files[1]}" -i "${files[2]}" \
  -i "${files[3]}" -i "${files[4]}" -i "${files[5]}" \
  -filter_complex "[0:v]scale=320:-1,setsar=1[a];[1:v]scale=320:-1,setsar=1[b];[2:v]scale=320:-1,setsar=1[c];[3:v]scale=320:-1,setsar=1[d];[4:v]scale=320:-1,setsar=1[e];[5:v]scale=320:-1,setsar=1[f];[a][b][c]hstack=3[top];[d][e][f]hstack=3[bottom];[top][bottom]vstack=2" \
  "$output"
