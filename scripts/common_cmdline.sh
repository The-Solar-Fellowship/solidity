#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# vim:ts=4:et
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016-2019 solidity contributors.
# ------------------------------------------------------------------------------

YULARGS=(--strict-assembly)
FULLARGS=(--optimize --ignore-missing --combined-json "abi,asm,ast,bin,bin-runtime,compact-format,devdoc,hashes,interface,metadata,opcodes,srcmap,srcmap-runtime,userdoc")
OLDARGS=(--optimize --combined-json "abi,asm,ast,bin,bin-runtime,devdoc,interface,metadata,opcodes,srcmap,srcmap-runtime,userdoc")
function compileFull()
{
    local expected_exit_code=0
    local expect_output=0

    case "$1" in
        '-e')
            expected_exit_code=1
            expect_output=1
            shift;
            ;;
        '-w')
            expect_output=1
            shift;
            ;;
        '-o')
            expect_output=2
            shift;
            ;;
    esac

    local args=("${FULLARGS[@]}")
    if [[ $1 = '-v' ]]; then
        if (echo "$2" | grep -Po '(?<=0.4.)\d+' >/dev/null); then
            patch=$(echo "$2" | grep -Po '(?<=0.4.)\d+')
            if (( patch < 22 )); then
                args=("${OLDARGS[@]}")
            fi
        fi
        shift 2
    fi

    local files=("$@")

    local stderr_path; stderr_path=$(mktemp)

    if [ "${files: -4}" == ".yul" ]
    then
        args=("${YULARGS[@]}")
    fi

    set +e
    "$SOLC" "${args[@]}" "${files[@]}" >/dev/null 2>"$stderr_path"
    local exit_code=$?
    local errors; errors=$(grep -v -E \
        -e 'Warning: This is a pre-release compiler version|Warning: Experimental features are turned on|pragma experimental ABIEncoderV2|^ +--> |^ +\||^[0-9]+ +\| ' \
        -e 'Warning: Yul is still experimental. Please use the output with care.' \
        -e '^No text representation found.$' < "$stderr_path"
    )

    set -e
    rm "$stderr_path"

    if [[ \
        ("$exit_code" -ne "$expected_exit_code" || \
            ( $expect_output -eq 0 && -n "$errors" ) || \
            ( $expect_output -ne 0 && $expected_exit_code -eq 0 && \
              $expect_output -ne 2 && -z "$errors" )
        )
    ]]
    then
        printError "Test failure:"
        printError "Exit code: $exit_code"
        printError "Expected:  $expected_exit_code"
        printError "==== Output ===="
        echo $errors
        printError "== Output end =="
        printError ""
        case "$expect_output" in
            0)
                printError "No output was expected."
                ;;
            1)
                printError "Expected warnings or errors."
                ;;
            2)
                printError "Expected possible warnings."
                ;;
        esac

        printError ""
        printError "While calling:"
        echo "\"$SOLC\" ${args[*]} ${files[*]}"
        printError "Inside directory:"
        pwd
        printError "Input was:"
        cat ${files[@]}
        false
    fi
}
