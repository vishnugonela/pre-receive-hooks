#!/usr/bin/env bash
#
# Name: Reject All Pushes
# Description: Immediately reject any push that occurs on the repository. Useful when you need to lock a repository.
#
# Author: James Garcia <james.rob.garcia@hpe.com>
# Organization Unit: Enterprise Group IT
# Team: Research & Development IT
#

echo " ";
echo "ERROR:  +------------------------------------------------------------+";
echo "ERROR:  |  The 'Reject All Pushes' pre-receive hook is currently     |";
echo "ERROR:  |  enabled on this repository. This will reject all pushes.  |";
echo "ERROR:  |  Please contact the repository administrator if you need   |";
echo "ERROR:  |  to disable this hook.                                     |";
echo "ERROR:  +------------------------------------------------------------+";
echo " ";

exit 1;
