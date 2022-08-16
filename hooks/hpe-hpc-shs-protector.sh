#!/bin/sh
scriptname=$(echo ${0##*/} | tr ' ' _)

#
# a github pre-receive script to provide branch & tag protection for
# HPC Slingshot Host Software repos (hpe/hpc-shs-*)
#
# running this script in other repos is an error and this script returns failure
#

#
# git sha of forty zeros
# used with git-push to indicate creating or deleting a reference
#
#                      1         2         3
#            0123456789012345678901234567890123456789
zero_commit='0000000000000000000000000000000000000000'

#
# default values
#
DEBUG=0
exit_value=0
upstream_synching=0

#
# process all git-push options
#
i=0
while [ ${i} -lt ${GIT_PUSH_OPTION_COUNT:-0} ]
do
    eval push_opt="\${GIT_PUSH_OPTION_${i}}"
    : push_opt="${push_opt}"
    case "${push_opt}" in
        #
        # enable debugging
        #
        hpe-hpc-shs-protector-hook-debug)
            DEBUG=$((${DEBUG}+1))
            case ${DEBUG} in
                2)
                    printenv | sort -t=
                    ;;
                3)
                    set -x
                    ;;
                *)
                    :
                    ;;
            esac
            ;;

        #
        # bypass -- exit immediately indicating success
        #
        hpe-hpc-shs-protector-hook-bypass)
            exit 0
            ;;

        #
        # upstream synchronized references (branches, tags, ...) are only allowed by be modified
        # by specific users.  and in order to not leave the upstream synchronized references always
        # pushable by these specific users, require use of git-push option "synchronizer".
        #
        synchronizer)
            case ${GITHUB_USER_LOGIN} in
                #
                # github user account used by hpc/cray jenkins jobs
                #
                hpe-cray-svc-jenkins)
                    upstream_synching=1
                    ;;
                #
                # users that may syncrhonize
                #
                dennis-c-josifovich     |\
                mike-uttormark          )
                    upstream_synching=1
                    ;;
                *)
                    printf '%s: WARNING: synchronizer NOT enabled: unrecognized user: "%s"\n' "${scriptname}" ${GITHUB_USER_LOGIN}
                    ;;
            esac
            ;;
        *)
            printf '%s: WARNING: unrecognized git push option: "%s"\n' "${scriptname}" "${push_opt}"
            ;;
    esac
    i=$((${i}+1))
done

#
# this github pre-receive hook is meant to run only against Slingshot Host Software repos
#
case ${GITHUB_REPO_NAME} in
    hpe/hpc-shs-*)
        :
        ;;
    *)
        printf '%s: ERROR: unsupported repo. not an HPC Slingshot Host Software (SHS) repo: %s\n' "${scriptname}" "${GITHUB_REPO_NAME}"
        exit 1
        ;;
esac

#
# process the references and its revisions
#
while read -r oldrev newrev refname
do
    : repo="${GITHUB_REPO_NAME}"
    : user="${GITHUB_USER_LOGIN}"
    : upstream_synching="${upstream_synching}"
    : oldrev="${oldrev}"
    : newrev="${newrev}"
    : refname="${refname}"

    case ${oldrev},${newrev},${refname} in
        #
        # neither refname, oldrev, or newrev should be empty
        #
        # because of this input error, exit immediately.
        #
        ,*,*  |\
        *,,*  |\
        *,*,  )
            printf '%s: ERROR: malformed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
            exit 1
            ;;
        *)
            :
            ;;
    esac

    #
    # The following matches may be both blacklist & whitelist
    # that may have extra conditions applied as well.
    #
    case ${GITHUB_REPO_NAME},${refname} in
        #
        # allow list with more specific matches overriding more generic deny matches
        #
        hpe/hpc-shs-libfabric-netc,refs/tags/v*.x-ss*-mpt       )
            if [ ${newrev} == ${zero_commit} ]
            then
                printf '%s: ERROR: v*.x-ss*-mpt tags may not be deleted: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
                exit_value=1
            else
                if [ ${DEBUG} -ne 0 ]
                then
                    printf '%s: DEBUG: push allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
                fi
            fi
            ;;
        #
        # non-active release branches & tags are read-only
        #
        hpe/hpc-shs-*,refs/heads/release/slingshot-1.8          |\
        hpe/hpc-shs-*,refs/tags/release/shs-1.8*                |\
\
        hpe/hpc-shs-*,refs/heads/release/cos-*                  |\
        hpe/hpc-shs-*,refs/heads/release/shasta-*               |\
        hpe/hpc-shs-*,refs/tags/shasta-*                        )
            printf '%s: ERROR: read-only reference: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
            exit_value=1
            ;;

        #
        # tags for active release branches may be created but not modified or deleted.
        # this includes the release candidate tags and release tags.
        # eventually this will include the release build tags (when they exist)
        #
        hpe/hpc-shs-*,refs/tags/release/shs-*           )
            if [ ${oldrev} != ${zero_commit} ]
            then
                printf '%s: ERROR: read-only reference: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
                exit_value=1
            else
                if [ ${DEBUG} -ne 0 ]
                then
                    printf '%s: DEBUG: active release tag push allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
                fi
            fi
            ;;

        #
        # active release branches may be created and modified but not deleted
        #
        hpe/hpc-shs-*,refs/heads/release/slingshot-*    )
            if [ ${newrev} == ${zero_commit} ]
            then
                printf '%s: ERROR: release branches may not be deleted: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
                exit_value=1
            else
                if [ ${DEBUG} -ne 0 ]
                then
                    printf '%s: DEBUG: active release branch push allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
                fi
            fi
            ;;

        #
        # certain tags are allowed to be created by not modified or deleted.
        #
        hpe/hpc-shs-*,refs/tags/release/slingshot-*spt          |\
        hpe/hpc-shs-*,refs/tags/llnl-*                          |\
        hpe/hpc-shs-libfabric-netc,refs/tags/v*.x-ss*-spt       )
            if [ ${oldrev} != ${zero_commit} ]
            then
                printf '%s: ERROR: read-only reference: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
                exit_value=1
            else
                if [ ${DEBUG} -ne 0 ]
                then
                    printf '%s: DEBUG: protected tag creation push allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
                fi
            fi
            ;;

        #
        # upstream synchronized repos+refs are generally treated as read-only
        # _unless_ they are being synchronized to the upstream
        #       (by a specific user using specific option to indicate synching is occuring)
        #
        hpe/hpc-shs-libfabric,refs/heads/master         |\
        hpe/hpc-shs-libfabric,refs/heads/upstream       |\
        hpe/hpc-shs-libfabric,refs/heads/v*.x-mirror    |\
        hpe/hpc-shs-libfabric,refs/tags/dev             |\
        hpe/hpc-shs-libfabric,refs/tags/v*              |\
\
        hpe/hpc-shs-libfabric-netc,refs/heads/coverity_scan                                     |\
        hpe/hpc-shs-libfabric-netc,refs/heads/gh-pages                                          |\
        hpe/hpc-shs-libfabric-netc,refs/heads/main                                              |\
        hpe/hpc-shs-libfabric-netc,refs/heads/pr/update-nroff-generated-man-pages-v1.14.1       |\
        hpe/hpc-shs-libfabric-netc,refs/heads/v*.x                                              |\
        hpe/hpc-shs-libfabric-netc,refs/tags/dev                                                |\
        hpe/hpc-shs-libfabric-netc,refs/tags/v*                                                 |\
\
        hpe/hpc-shs-python-tabulate,refs/heads/master   |\
        hpe/hpc-shs-python-tabulate,refs/tags/v*        |\
\
        hpe/hpc-shs-scapy,refs/heads/master     |\
        hpe/hpc-shs-scapy,refs/tags/v*          )
            if [ ${upstream_synching} -eq 0 ]
            then
                printf '%s: ERROR: repo="%s" refname="%s" may only be modified when syncrhonizing to the upstream\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
                exit_value=1
            else
                if [ ${DEBUG} -ne 0 ]
                then
                    printf '%s: DEBUG: synchonizing protected reference allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
                fi
            fi
            ;;

        #
        # read only repos+refs
        #
        hpe/hpc-shs-cfs,refs/heads/feature/raspberry-ncn-customization          |\
\
        hpe/hpc-shs-firmware-management,refs/heads/archive/release/shasta-1.4   |\
        hpe/hpc-shs-firmware-management,refs/heads/integration                  |\
        hpe/hpc-shs-firmware-management,refs/heads/release/slingahot-1.7        |\
\
        hpe/hpc-shs-kfabric,refs/heads/master           |\
\
        hpe/hpc-shs-libfabric,refs/heads/memhooks-test          |\
\
        hpe/hpc-shs-libfabric-netc,refs/heads/integration       |\
\
        hpe/hpc-shs-mellanox-ofed,refs/heads/integration                                                                                |\
        hpe/hpc-shs-mellanox-ofed,refs/heads/release/SKERN-5263-build-kasan-enabled-kernel-to-debug-nvidia-null-pointer-at-nersc        |\
\
        hpe/hpc-shs-network-config,refs/heads/release/test-1.6.1        |\
\
        hpe/hpc-shs-network-groovy-libs,refs/heads/integration          |\
\
        hpe/hpc-shs-product-stream,refs/heads/SSHOTMGP-5094-add-Post-Install-validation         |\
        hpe/hpc-shs-product-stream,refs/heads/placeholder_1_7_2_rc6                             |\
        hpe/hpc-shs-product-stream,refs/heads/static-releases                                   |\
\
        hpe/hpc-shs-snif,refs/heads/snif-socket         |\
\
        hpe/hpc-shs-virtme,refs/heads/master            )
            printf '%s: ERROR: read-only reference: repo="%s" refname="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${refname}"
            exit_value=1
            ;;
        #
        # default to catch all other repos+refs
        #
        *)
            if [ ${DEBUG} -ne 0 ]
            then
                printf '%s: DEBUG: push allowed: repo="%s" user="%s" refname="%s" oldrev="%s" newrev="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}" "${refname}" "${oldrev}" "${newrev}"
            fi
    esac
done

#
# if any errors were found, then output a final error message.
#
if [ ${exit_value} -ne 0 ]
then
    printf '%s: ERROR: one or more errors detected. pushed rejected for: repo="%s" username="%s"\n' "${scriptname}" "${GITHUB_REPO_NAME}" "${GITHUB_USER_LOGIN}"
fi
exit ${exit_value}
