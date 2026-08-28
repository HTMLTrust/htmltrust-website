#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/../htmltrust-spec"
mode=""

usage() {
  cat <<'EOF'
Usage: scripts/sync-spec-artifacts.sh [sync|--check] [--source PATH]

Copy or check the five spec artifacts published by this website. PATH defaults
to the sibling htmltrust-spec checkout.
EOF
}

while (($# > 0)); do
  case "$1" in
    sync)
      if [[ -n "$mode" ]]; then
        echo "sync and --check cannot be combined" >&2
        exit 2
      fi
      mode="sync"
      shift
      ;;
    --check)
      if [[ -n "$mode" ]]; then
        echo "sync and --check cannot be combined" >&2
        exit 2
      fi
      mode="check"
      shift
      ;;
    --source)
      if (($# < 2)); then
        echo "--source requires a path" >&2
        exit 2
      fi
      source_root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$mode" ]]; then
  mode="sync"
fi

declare -a source_paths=(
  "ietf-draft/draft-grey-htmltrust-00.html"
  "ietf-draft/draft-grey-htmltrust-00.md"
  "IETF_SPEC_REVIEW.md"
  "w3c-cg/index.html"
  "W3C_SPEC_REVIEW.md"
)
declare -a destination_paths=(
  "static/spec/ietf-draft/draft-grey-htmltrust-00.html"
  "static/spec/ietf-draft/draft-grey-htmltrust-00.md"
  "static/spec/ietf-draft/review.md"
  "static/spec/w3c-cg/draft.html"
  "static/spec/w3c-cg/review.md"
)

if [[ ! -d "$source_root" ]]; then
  echo "Spec source directory not found: $source_root" >&2
  exit 1
fi

for source_path in "${source_paths[@]}"; do
  if [[ ! -f "$source_root/$source_path" ]]; then
    echo "Required spec artifact not found: $source_root/$source_path" >&2
    exit 1
  fi
done

if [[ "$mode" == "sync" ]]; then
  for destination_path in "${destination_paths[@]}"; do
    mkdir -p "$repo_root/$(dirname "$destination_path")"
  done
fi

status=0
for i in "${!source_paths[@]}"; do
  source_path="$source_root/${source_paths[$i]}"
  destination_path="$repo_root/${destination_paths[$i]}"

  if [[ "$mode" == "sync" ]]; then
    cp -- "$source_path" "$destination_path"
    echo "Copied ${source_paths[$i]} -> ${destination_paths[$i]}"
  elif [[ ! -f "$destination_path" ]]; then
    echo "Missing published artifact: ${destination_paths[$i]}" >&2
    status=1
  elif cmp -s "$source_path" "$destination_path"; then
    echo "OK ${destination_paths[$i]}"
  else
    echo "Out-of-date published artifact: ${destination_paths[$i]}" >&2
    status=1
  fi
done

if [[ "$mode" == "check" && "$status" -ne 0 ]]; then
  exit "$status"
fi
