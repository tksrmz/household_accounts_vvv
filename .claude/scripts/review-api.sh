#!/usr/bin/env bash
# The two GitHub reads /pr-review needs, and nothing else.
#
# Granting the review command `gh api` outright would let any instruction that
# reaches the model -- including text sitting in the diff it was asked to review
# -- issue authenticated writes with the job's pull-requests: write token. An
# allow rule cannot narrow that down, because it matches on a command prefix
# while `--method` and `-F field=@file` can follow the endpoint. Hence a wrapper:
# fixed endpoints, GET only, arguments validated before they reach the URL.
#
# This file is only trustworthy because the workflow restores .claude/ from the
# default branch before the review runs. Keep it there.
set -euo pipefail

usage() {
  echo "usage: ${0} comments <pr-number>" >&2
  echo "       ${0} compare <base-sha> <head-sha>" >&2
  exit 2
}

repo="${GITHUB_REPOSITORY:-}"
if [ -z "$repo" ]; then
  repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

case "${1:-}" in
  comments)
    [ "$#" -eq 2 ] || usage
    [[ "$2" =~ ^[0-9]+$ ]] || usage
    exec gh api --method GET --paginate "repos/${repo}/pulls/${2}/comments"
    ;;
  compare)
    [ "$#" -eq 3 ] || usage
    [[ "$2" =~ ^[0-9a-fA-F]{7,40}$ ]] || usage
    [[ "$3" =~ ^[0-9a-fA-F]{7,40}$ ]] || usage
    exec gh api --method GET "repos/${repo}/compare/${2}...${3}"
    ;;
  *)
    usage
    ;;
esac
