#!/bin/bash
#
# Ugly hack to check links validity

set -eu

check_exit_code=0
grep_option="-e ''"
verbose=""

if [ "$#" -gt 0 ]; then
    if [ "$1" = "-v" ]; then
        verbose="1"
        shift
    fi
fi

if [ "$#" -gt 0 ]; then
    grep_option="$1"
fi

git -c grep.lineNumber=false  grep -Iho 'https\?://[[:alnum:]/:._-]*' | grep -e "$grep_option" | while read link; do
#git -c grep.lineNumber=false  grep -Iho 'https\?://[[:alnum:]/:._-]*' | while read link; do
    test -z "$verbose" || echo "Check link: $link"
    if ! curl -sI -m10 "$link" >/dev/null; then
        echo "Broken link: $link" >&2
        check_exit_code=1
    fi
done

exit "$check_exit_code"
