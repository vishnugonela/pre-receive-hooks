# pre-receive-hooks

This repository hosts the **pre-receive** hooks for use on this GitHub Enterprise (GHE) instance. Due to the current implementation of the pre-receive hook environment in the GHE product, adding or changing hooks requires consultation with a **GHE Site Administrator**.

## What is a pre-receive hook?

A **hook** in a repository is a script that executes before or after events such as commit, push and receive.

**GitHub Enterprise (GHE)** allows the usage of **pre-receive hooks** in its Git repositories with the help of its Site Administrators. This repository is used to host the pre-receive hook scripts and is maintained by the GHE Site Administrator team _(**Support** link is located at the bottom of this page)_.

In short, a **pre-receive hook** is a script that is executed when a push occurs in a GHE repository. You can use a pre-receive hook to perform an action or check that must occur when a push happens. For example, you can use hooks to check commit message syntax, verify a commit message is not blank, block all pushes, etc.

## How do I set up a pre-receive hook?

Setting up a pre-receive hook on this GHE instance requires the help of the **Site Administrator** team. This is because hooks are executed on the GHE server itself and they must be reviewed by the admins before they can be run in the hook environment. Typical workflows are shown below.

**To set up a new pre-receive hook:**

1. **Fork** the [pre-receive-hooks](https://github.hpe.com/GitHub/pre-receive-hooks) repo.
2. In your fork, create the new hook script.
3. Push the **changes** to your fork and create a [Pull Request (PR)](https://help.github.com/articles/about-pull-requests/) when you are done or would like to start a conversation with the site admins.
4. In the Pull Request comments, suggest a **friendly name** for the hook.
5. The site admins will **review** the changes in the PR:.
    - If the script looks **good**, the site admins will **merge** the PR..
    - If the script is **rejected or needs changes**, the site admins will **provide feedback** in the PR for the submitter to consider. Either cancel the request or make additional changes for the PR based on the feedback.
6. Once a hook script is **accepted and merged**, the site admins will create the hook selection on the server and notify the submitter.
7. After being notified about the loaded hook script, the submitter can choose to **Enable or **Disable** the hook at https://github.hpe.com/OWNERNAME/REPONAME/settings/hooks.

_**NOTE:** Pre-receive hook scripts, once accepted and loaded, are visible to all repositories on the instance. However, each repository owner can choose whether or not to enable it individually. Be sure your hook script is a generic implementation since it will be visible._


**To update an existing pre-receive hook:**

The process to **update** an existing pre-receive hook that has already been loaded will follow the same procedure as **Steps 1-5** above. Once it is **merged**, the change will be available immediately.

## References

- [Creating a pre-receive hook script](https://help.github.com/enterprise/2.7/admin/guides/developer-workflow/creating-a-pre-receive-hook-script/)
- [What is a Pull Request?](https://help.github.com/articles/about-pull-requests/)
- [Examples of Git-Enforce Policy](https://git-scm.com/book/en/v2/Customizing-Git-An-Example-Git-Enforced-Policy)

These guidelines are included in this [CONTRIBUTE.md](https://github.hpe.com/RnDIT-SWET/pre-receive-hooks/blob/POC/CONTRIBUTE.md).  Please note, these guidelines can be modified at any time.  Be sure to review it before all new proposals/Pull Requests.  
