#!/usr/bin/env bash
#
# Name: EZ Pre-commit check
# Description: Reject any push to main/integration/develop/release* branches which do not have JIRA reference in the comment.
#
# Organization Unit: Ezmeral
# Team: Ezmeral
#

pattern='develop|main|integration|release'


zero_commit='0000000000000000000000000000000000000000'
msg_regex='/*(EZQE|EZAWB|EZCP|EZCPQA|EZCTL|EZEPIC|EZESC|EZUX|EZKUBE|EZKD|EZDO|EZKP|EZML)-[0-9].+?'

while read -r oldrev newrev refname; do
  current_branch=${refname#refs/heads/}
  if [[ $current_branch =~ $pattern  ]];then
    # Branch or tag got deleted, ignore the push
      [ "$newrev" = "$zero_commit" ] && continue

      # Calculate range for new branch/updated branch
      [ "$oldrev" = "$zero_commit" ] && range="$newrev" || range="$oldrev..$newrev"

    for commit in $(git rev-list "$range" --not --all); do
      message=$(git show -s --format=%B $commit)
      if ! echo $message | grep -iqE "$msg_regex"; then
        echo "ERROR:"
        echo "ERROR: Your push was rejected because the commit"
        echo "ERROR: $commit in ${refname#refs/heads/}"
        echo "ERROR: is missing the JIRA Issue Please enter valid JIRA Issue ID for example EZCP-XXXX (Valid Regex allowed: $msg_regex)"
        echo "ERROR:"
        echo "ERROR: Please fix the commit message and push again."
        echo "ERROR: https://help.github.com/en/articles/changing-a-commit-message"
        echo "ERROR"
        exit 1
      fi
    done
  fi
done
