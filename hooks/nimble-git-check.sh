#!/usr/bin/env bash
#
# Name: Nimble Check
# Description: Runs a curl command to asks a Nimble server to apply its business process checks before accepting a push.
#
# Author: Cristian Medina <cristian.medinaabkarian@hpe.com>
# Organization Unit: Primary Storage - EIG
# Team: DevTools
#

HOOK_API="http://git-hook.eng.nimblestorage.com/v1/github"
ZERO_COMMIT='0000000000000000000000000000000000000000'

while  read -r old_rev new_rev ref ; do
    # Ignore the  push if brach/tag got deleted
    [ $new_rev = $ZERO_COMMIT ] && continue

    # Calculate commit range for updated branch
    [ $old_rev = $ZERO_COMMIT ] && range=$new_rev || range=$old_rev..$new_rev

    # Iterate through commits
    for commit in $(git rev-list $range --reverse) ; do
        # Extract message
        message=$(git show -s --format=%B $commit)
        author=$(git show -s --format=%an $commit)

        # Validate commit
        RESP=$(curl -s -X POST \
               -H 'Content-Type: application/json' \
               -d "{\"data\": {\"old_rev\": \"$old_rev\", \"new_rev\": \"$new_rev\", \"ref\": \"$ref\", \"message\": \"$message\", \"author\": \"$author\"}}" \
               $HOOK_API)

        if [ ! "$RESP" = "OK" ]; then
            echo $RESP
            exit 1
        fi
    done
done
