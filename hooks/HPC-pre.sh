 #! /bin/sh -x

# NOTE: This hook requires the following alpine+openssh environment:
#       docker/hpc.pre.receive.false.tar.gz

SSH_OPTIONS="-q -x -o strictHostKeyChecking=no"
SSH_USER=ghe
SSH_HOST=salsa.engr.sgi.com
SSH_HOST=137.38.153.239		# XXX: HPE yet do not DNS resolve sgi.com 
SSH_ACCESS="${SSH_USER}@${SSH_HOST}"
SSH="ssh $SSH_OPTIONS $SSH_ACCESS"

ERR=0
while read old_rev new_rev ref ; do
	$SSH hooks pre  					\
		${GITHUB_USER_LOGIN:-"user_unknown"}		\
		${GITHUB_REPO_NAME:-"NA/repo_unknown"}		\
		$old_rev					\
		$new_rev					\
		$ref
	ERR=$(( $ERR + $? ))
done
exit $ERR
