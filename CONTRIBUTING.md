# Contributing to pre-receive-hooks

Use the below procedure to **add** or **change** pre-receive hooks to this repository.

## Things to consider

- All pre-receive-hooks that are implemented are visible by all repositories on the GHE server, but it is disabled by default. Despite this, all repository owners will have the option to enable it if they browse the hooks section in their repository settings.
- All pre-receive-hooks proposed and implemented should generally be consumable by any repository since they will be visible by anyone.

## How do I set up a pre-receive hook?

Setting up a pre-receive hook on this GHE instance requires the help of the **Site Administrator** team. This is because hooks are executed on the GHE server itself and they must be reviewed by the admins before they can be run in the hook environment. Typical workflows are shown below.

### To set up a new pre-receive hook

1. [Fork](https://help.github.com/articles/fork-a-repo/)] the [pre-receive-hooks](https://github.hpe.com/GitHub/pre-receive-hooks) repository.
2. In your fork, create the new hook script in the **hooks** directory. At the top of the hook, add a comments section including script **Name, Description, Author, Organization Unit** and **Team** for future reference by others who may wish to use your hook script. _(See the example [always_reject.sh](https://github.hpe.com/GitHub/pre-receive-hooks/blob/doc-update/hooks/always_reject.sh) for help.)_
3. Push the **changes** to your fork and create a [Pull Request (PR)](https://help.github.com/articles/about-pull-requests/) when you are done or would like to start a conversation with the site admins.
4. In the Pull Request comments, suggest a **friendly name** for the hook.
5. The site admins will **review** the changes in the PR:.
    - If the script looks **good**, the site admins will **merge** the PR..
    - If the script is **rejected or needs changes**, the site admins will **provide feedback** in the PR for the submitter to consider. Either cancel the request or make additional changes for the PR based on the feedback.
6. Once a hook script is **accepted and merged**, the site admins will create the hook selection on the server and notify the submitter.
7. After being notified about the loaded hook script, the submitter can choose to **Enable or **Disable** the hook at https://github.hpe.com/OWNERNAME/REPONAME/settings/hooks.

_**NOTE:** Pre-receive hook scripts, once accepted and loaded, are visible to all repositories on the instance. However, each repository owner can choose whether or not to enable it individually. Be sure your hook script is a generic implementation since it will be visible._


### To update an existing pre-receive hook

The process to **update** an existing pre-receive hook that has already been loaded will follow the same procedure as **Steps 1-5** above. Once it is **merged**, the change will be available immediately.
