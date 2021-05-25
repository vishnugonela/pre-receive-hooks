#!/bin/bash
# regex to validate in commit msg
commit_regex='(HPEFS-[0-9]+)'
error_msg="Aborting commit. Your commit message is missing JIRA Issue ID. Please put JIRA ID in start of commit msg. Example HPEFS-XXXXX'"

if ! grep -iqE "$commit_regex" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi