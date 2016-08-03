#!/usr/bin/env bash

echo " ";
echo "ERROR:  +------------------------------------------------------------+";
echo "ERROR:  |  The 'Reject All Pushes' pre-receive hook is currently     |";
echo "ERROR:  |  enabled on this repository. This will reject all pushes.  |";
echo "ERROR:  |  Please contact the repository administrator if you need   |";
echo "ERROR:  |  to disable this hook.                                     |";
echo "ERROR:  +------------------------------------------------------------+";
echo " ";

exit 1;

