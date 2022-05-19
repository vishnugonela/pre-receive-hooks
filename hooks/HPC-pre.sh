#! /bin/sh

# NOTE: This hook requires the following alpine+openssh environment:
#       docker/hpc.pre.receive.false.tar.gz

SSH_OPTIONS="-q -x -o strictHostKeyChecking=no"
SSH_USER=ghe
SSH_HOST=salsa.chf.rdlabs.hpecorp.net
SSH_HOST=137.38.153.239		# XXX: HPE yet do not DNS resolve sgi.com 
SSH_ACCESS="${SSH_USER}@${SSH_HOST}"
SSH="ssh $SSH_OPTIONS $SSH_ACCESS"

# If ".wiki" repo , return 0 immediately
# Wiki repo "hint" is in GIT_DIR, not GITHUB_REPO_NAME
# Trick below obtained from github.com Engineering.
# Ex: GIT_DIR=/data/user/repositories/a/nw/aa/b3/23/14/20.wiki.git
# Also was https://github.hpe.com/GitHub/IssueTracking/issues/97
[ "${GIT_DIR: -9}" == ".wiki.git" ] && exit 0 || :

ERR=0
while read old_rev new_rev ref ; do
	$SSH hooks pre  					\
		${GITHUB_USER_LOGIN:-"user_unknown"}		\
		${GITHUB_REPO_NAME:-"NA/repo_unknown"}		\
		$old_rev					\
		$new_rev					\
		$ref						\
		${GITHUB_VIA:-"NONE"}				\
		${GITHUB_PULL_REQUEST_AUTHOR_LOGIN:-"NONE"}	\
		${GITHUB_PULL_REQUEST_HEAD:-"NONE"}		\
		${GITHUB_PULL_REQUEST_BASE:-"NONE"}		\
		$NULL
	ERR=$(( $ERR + $? ))
done
exit $ERR
