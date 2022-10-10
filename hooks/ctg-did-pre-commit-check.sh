#!/bin/bash

# Name: ctg-did-pre-commit-check.sh
# Description:  Script is used to eIUM GIT hooks to validate commit messages 
# Organization Unit: CTG
# Author: sanoymathew@hpe.com
# Team: CTG Digital Identity

DEBUG=0
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


# check if the message contains QXCR id
check_qxcr_nocr()
{
    message="$1"
    commit_id=`git rev-parse --short $2`
    echo $message | grep -qE "(${QXCR_RE})|(${JIRA_RE})" 
    if [ $? -ne 0 ] ; then
	# no QXCR/JIRA in the comment, check "NOCR"
	nocr_reason=`echo $message | sed -n -e "s/^.*${NOCR_RE}.*$/\1/p"`

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


#Few users can pass the push option --push-option=mod_admin to get the admin privilege
#eg. git push --push-option=mod-admin
ENABLE_ADMIN=0
ALLOW_TAGS=YES
i=0
while [ ${i} -lt ${GIT_PUSH_OPTION_COUNT:-0} ]
do
	eval push_opt="\${GIT_PUSH_OPTION_${i}}"
	: push_opt="${push_opt}"
	case "${push_opt}" in
		mod-admin)
			ENABLE_ADMIN=1
			echo "[POLICY] Requested admin mode!"
		;;
		mod-debug)
			echo "[POLICY] Requested debug mode!"
			DEBUG=1
			printenv | sort -t=
		;;
		mod-trace)
			echo "[POLICY] Requested trace mode!"
			DEBUG=2
			set -x
			printenv | sort -t=
		;;
		*)
			:
		;;
	esac
	i=$((${i}+1))
done

while read -r oldrev newrev refname; do

	echo "${refname}: ${oldrev:0:7}..${newrev:0:7}"
	
	#take care of local git and github env for the user details
	if [ -z "${GIT_USER}" ] ; then
	  GIT_USER=${GITHUB_USER_LOGIN}
	fi
	
	if [ ${DEBUG} -ne 0 ]; then
		scriptname=$(echo ${0##*/} | tr ' ' _)
		printf '%s: DEBUG:  details : repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GIT_USER}" "${refname}" "${oldrev}" "${newrev}"
	fi
	
	
	ZEROREF=0000000000000000000000000000000000000000
	
	echo "Enforcing Policies..."
	
	if [ -z "${GIT_USER}" ] ; then
	    echo "[POLICY] Environment variable GIT_USER OR GITHUB_USER_LOGIN not set"
	    echo "[POLICY] Update rejected"
	    exit 6
	fi
	
	
	IS_ADMIN=0
	if [ ${ENABLE_ADMIN} -ne 0 ]; then
			case "${GIT_USER}" in 
			  "vishnug" | \
			  "anand.subramanian" | \
			  "rajeshn" | \
			  "guangqi.gong" | \
			  "sanoymathew" )
	
				IS_ADMIN=1
			  ;;
			  *)
				IS_ADMIN=0
			  ;;
			esac
	fi
	
	
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

	INTEGRATION_BRANCH_RE="(^refs/heads/integration-)"
	USER_BRANCH_RE="^refs/heads/${GIT_USER}-"
	INTEGRATION_BRANCH=`echo ${refname} | grep -E -c "${INTEGRATION_BRANCH_RE}"`
	USER_BRANCH=`echo ${refname} | grep -E -c "${USER_BRANCH_RE}"`
	
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
	
	for rev in ${missed_revs} ; do 
	    message=`git cat-file commit ${rev} | sed '1,/^$/d' | tr '\n' ' '`
	    check_qxcr_nocr "$message" $rev
	done
	exit 0
done

exit 0
