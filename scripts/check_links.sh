#!/bin/bash
#
# Ugly hack to check links validity

set -eu

check_exit_code=0

git -c grep.lineNumber=false  grep -Iho 'https\?://[[:alnum:]/:._-]*'  | while read link; do
    if ! curl -sI -m10 "$link" >/dev/null; then
        echo "Broken link: $link" >&2
        check_exit_code=1
    fi
done

exit "$check_exit_code"
