#!/usr/bin/env bash
#
# Script Friendly Name: Reject All Pushes
# Script Description: Immediately reject any push that occurs on the repository.
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
