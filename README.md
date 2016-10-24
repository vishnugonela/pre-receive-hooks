# pre-receive-hooks

This repository hosts the **pre-receive** hooks for use on this GitHub Enterprise (GHE) instance. Due to the current implementation of the pre-receive hook environment in the GHE product, adding or changing hooks requires consultation with a **GHE Site Administrator**.

## What is a pre-receive hook?

A **hook** in a repository is a script that executes before or after events such as commit, push and receive.

**GitHub Enterprise (GHE)** allows the usage of **pre-receive hooks** in its Git repositories with the help of its Site Administrators. This repository is used to host the pre-receive hook scripts and is maintained by the GHE Site Administrator team

**NOTE:** The **Support** link is located at the bottom of this page.

In short, a [pre-receive hook](https://help.github.com/enterprise/2.7/admin/guides/developer-workflow/about-pre-receive-hooks/) is a script that is executed when a push occurs in a GHE repository. You can use a pre-receive hook to perform an action or check that must occur when a push happens. For example, you can use hooks to check commit message syntax, verify a commit message is not blank, block all pushes, etc.

## How do I add or change a hook?

For details on adding a new or changing an existing hook, see our [CONTRIBUTING.md](https://github.hpe.com/GitHub/pre-receive-hooks/blob/doc-update/CONTRIBUTING.md) document.

## References

- [About pre-receive hooks](https://help.github.com/enterprise/2.7/admin/guides/developer-workflow/about-pre-receive-hooks/)
- [Creating a pre-receive hook script](https://help.github.com/enterprise/2.7/admin/guides/developer-workflow/creating-a-pre-receive-hook-script/)
- [What is a Pull Request?](https://help.github.com/articles/about-pull-requests/)
- [Examples of Git-Enforced Policy](https://git-scm.com/book/en/v2/Customizing-Git-An-Example-Git-Enforced-Policy)
