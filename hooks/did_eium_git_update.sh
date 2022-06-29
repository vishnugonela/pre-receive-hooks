#!/bin/bash

# source the function definitions

QXCR_RE="QXCR[0-9]{10}([^0-9].*)?$"
JIRA_RE="CMSEIUM-[0-9]+"
NOCR_RE="NOCR:[ \t]*\([A-Za-z0-9_-]\+\)"
NOCR_REASONS="\
@quickfix@: Easy fix for accidentally found potential problem in the code--
@cleanup@: Simple code cleanup (indentation, comments, variable names etc.)--
@docfix@: Fixes in chints and other documentation--
@internal@: Changes/fixes in code only used internally by eIUM team--
@admin@: Changes to the build system etc., not to be used by developers--
"


OBSOLETE_BRANCHES="${OBSOLETE_BRANCHES} 7.0_fp01_upm_cust 8.0_sprint_cust next-8.3 integration-sm next-nfv integration-8.3_nls 6.0_fp03_verizon_cust next-srf next-8.3_fp01 integration-syzygy next-syzygy 8.3_fp01_upm_prod_001_QXCR1001527975_cpe next-tissot next-9.0_fp01 9.0_fp01_orange_cust next-9.2 next-9.0_fp02 integration-x-cis next-x integration-10.0.x 10.0.x next-10.1 next-10.5 next-10.6 next-10.7"

# check if the message contains QXCR id
check_qxcr_nocr()
{
    msg_file=$1
    commit_id=`git rev-parse --short $2`
    grep -E "(${QXCR_RE})|(${JIRA_RE})" $msg_file > /dev/null 2>&1
    if [ $? -ne 0 ] ; then
	# no QXCR/JIRA in the comment, check "NOCR"
	nocr_reason=`sed -n -e "s/^.*${NOCR_RE}.*$/\1/p" $msg_file`

	if [ -n "${nocr_reason}" ] ; then
	    echo ${NOCR_REASONS} | grep "@${nocr_reason}@" > /dev/null 2>&1
	    if  [ $? -ne 0 ] ; then
		echo "[POLICY] Your message of commit ${commit_id} contains 'NOCR:' but reason '${nocr_reason}' is not valid"
		echo "[POLICY] Valid reasons are:"
		echo ${NOCR_REASONS} | sed -e s/@/\"/g | sed -e "s/--/\n/g" | while read l; do echo $l; done
		exit 2
	    fi
	else
	    echo "[POLICY] Your message in commit ${commit_id} must contain CR id (e.g. QXCR1234567890 or CMSEIUM-1234) or 'NOCR:<reason>'"
	    exit 2
	fi
    fi
}


find_branch_base()
{
    new_commit=$1
    branch_base=""
    for branch_name in `git show-ref --heads -s` ; do
        cur_branch_base=`git merge-base $branch_name $new_commit`
        if [ "$cur_branch_base" == "" ] ; then
            return 
        fi
        num_revs=`git rev-list $cur_branch_base..$new_commit | wc -l`
        if [ "$min_num_revs" == "" ] || [ $num_revs -lt $min_num_revs ] ; then
            min_num_revs=$num_revs
            branch_base=$cur_branch_base
        fi
    done
}









# Main code

refname=$1
oldrev=$2
newrev=$3

ZEROREF=0000000000000000000000000000000000000000
ADMIN_USER=admin

#OBSOLETE_BRANCHES="${OBSOLETE_BRANCHES} next-10.8"
OBSOLETE_BRANCHES="${OBSOLETE_BRANCHES} "

echo "Enforcing Policies..."
if [ -z "${GIT_USER}" ] ; then
    echo "[POLICY] Environment variable GIT_USER not set"
    echo "[POLICY] Update rejected"
    exit 6
fi

GIT_ACCESS=${GIT_ACCESS:-RW}
ALLOW_TAGS=${ALLOW_TAGS:-NO}

if [ "${GIT_ACCESS}" != "RW" ] ; then
    echo "[POLICY] You don't have write access, update is not allowed"
    exit 8
fi

if [ "${GIT_USER}" == "${ADMIN_USER}" ] ; then
    IS_ADMIN=1
else
    IS_ADMIN=0
fi

echo "${refname}: ${oldrev:0:7}..${newrev:0:7}"

if [ ${IS_ADMIN} -eq 1 ] ; then
    echo "[POLICY] Hello admin!"
    echo "[POLICY] You have the power. I hope you are being careful"
    exit 0
fi

TAG_RE="^refs/tags/"
echo ${refname} | grep -E "${TAG_RE}" > /dev/null 2>&1
if [ $? -eq 0 ] ; then
    if [ "$ALLOW_TAGS" == "YES" ] ; then
        if [ "$oldrev" == "$ZEROREF" ] ; then
            exit 0
        else
            echo "[POLICY] You are only allowed to create new tags"
            exit 9
        fi
    else
        echo "[POLICY] Updating tags is not allowed"
        exit 7
    fi 
fi

NEXT_BRANCH_RE="^refs/heads/next($|-)"
CPE_BRANCH_RE="^refs/heads/.*_cpe$"
CUST_BRANCH_RE="^refs/heads/.*_cust$"
PROD_BRANCH_RE="^refs/heads/.*_prod$"
#ALLOWED_BRANCH_RE="(^refs/heads/next-)|(^refs/heads/.*_cpe$)|(^refs/heads/.*_cust$)"
INTEGRATION_BRANCH_RE="(^refs/heads/integration-)"
USER_BRANCH_RE="^refs/heads/${GIT_USER}-"

for bn in ${OBSOLETE_BRANCHES} ; do
    if [ "${refname}" == "refs/heads/${bn}" ] ; then
        echo "[POLICY] Branch ${refname} is obsolete. Update not allowed"
        exit 11
    fi;
done

NEXT_BRANCH=`echo ${refname} | grep -E -c "${NEXT_BRANCH_RE}"`
CPE_BRANCH=`echo ${refname} | grep -E -c "${CPE_BRANCH_RE}"`
CUST_BRANCH=`echo ${refname} | grep -E -c "${CUST_BRANCH_RE}"`
PROD_BRANCH=`echo ${refname} | grep -E -c "${PROD_BRANCH_RE}"`
INTEGRATION_BRANCH=`echo ${refname} | grep -E -c "${INTEGRATION_BRANCH_RE}"`
USER_BRANCH=`echo ${refname} | grep -E -c "${USER_BRANCH_RE}"`

if [ ${NEXT_BRANCH} -eq 0 -a ${CPE_BRANCH} -eq 0 -a ${CUST_BRANCH} -eq 0 -a ${PROD_BRANCH} -eq 0 -a ${INTEGRATION_BRANCH} -eq 0 -a ${USER_BRANCH} -eq 0 ] ; then
    # this is neither "standard" next or next- or _cpe branch, nor a user branch
    echo "[POLICY] Updating this branch (${refname}) is not allowed"
    echo "[POLICY] You are only allowed to update next, next-*, integration-*, *_cpe, *_cust, *_prod and ${GIT_USER}-* branches"
    exit 5
fi

CREATE_BRANCH=0
DELETE_BRANCH=0
if [ "$oldrev" == "$ZEROREF" ] ; then
    if [ ${USER_BRANCH} -eq 0 -a ${INTEGRATION_BRANCH} -eq 0 ] ; then
	echo "[POLICY] New branch creation (${refname}) not allowed"
	exit 3
    else
	CREATE_BRANCH=1
    fi
fi

if [ "$newrev" == "$ZEROREF" ] ; then
    if [ ${USER_BRANCH} -eq 0 ] ; then
	echo "[POLICY] Branch deletion (${refname}) not allowed"
	exit 4
    else
	DELETE_BRANCH=1
        exit 0
    fi
fi

# this only works if CREATE_BRANCH is 0, but CREATE_BRANCH must not be set when NEXT_BRANCH is set
if [ $NEXT_BRANCH -eq 1 -o $CPE_BRANCH -eq 1 ] ; then
    merge_revs=`git rev-list --merges $oldrev..$newrev`
    if [ -n "$merge_revs" ] ; then
	MERGE_COMMIT=1
    else
	MERGE_COMMIT=0
    fi

    if [ $MERGE_COMMIT -eq 1 ] ; then
	echo "[POLICY] Merges are forbidden on next, next-* and *_cpe branches"
	exit 12
    fi
fi

if [ $CREATE_BRANCH -eq 1 ] ; then
    find_branch_base $newrev
    if [ "$branch_base" == "" ] ; then
        echo "[POLICY] Your branch tip ${newrev} is not a descendant of any existing branch, branch creation not allowed"
        exit 10
    fi
    missed_revs=`git rev-list $branch_base..$newrev`
else
    missed_revs=`git rev-list $oldrev..$newrev`
fi

tmp_file=`mktemp msgXXXXX`
for rev in ${missed_revs} ; do 
    git cat-file commit ${rev} | sed '1,/^$/d' > $tmp_file
    check_qxcr_nocr $tmp_file $rev
done
rm -f $tmp_file
exit 0

