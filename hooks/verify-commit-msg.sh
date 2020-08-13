#!/bin/bash
#
# Name: Verify 1st commit message(Heading of pull request) in git push
# Description: Reject pushes that contain commit with message that does not adhere to defined regex. Useful to link github commits to jira issues
# Exit-code: If jira id  is not  mentioned in 1st commit message of a pull request, this script will exit with error code 1 and  push will be rejected.

# Author: Jasmeen Kamboj <jasmeen.kamboj@hpe.com>
# Organization Unit: Infosight
# Team: Devops
#

set -e

zero_commit='0000000000000000000000000000000000000000'

while  read -r old_rev new_rev ref ; do

  #Ingnore the  push if brach/tag got deleted
  [ $new_rev = $zero_commit ] && continue

  #Calculate commit range for updated branch
  [ $old_rev = $zero_commit ] && range=$new_rev || range=$old_rev..$new_rev

  for commit in $(git rev-list $range --reverse) ; do
    message=$(git show -s --format=%B $commit)
    if ! echo $message | grep -qE "^(IS|ISHD)-[0-9]+"; then
      echo "ERROR"
      echo "Your push was rejected because"
      echo "ERROR: $commit in ${ref#refs/heads/}"
      echo "ERROR: is missing the JIRA id"
      echo "ERROR:"
      echo "ERROR: Please fix the commit message and push again."
      echo "ERROR: https://help.github.com/en/articles/changing-a-commit-message"
      echo "ERROR"
      exit 1
    fi
    break
  done
done
