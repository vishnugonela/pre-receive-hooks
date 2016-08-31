# pre-receive-hooks

## Things to consider:
* All pre-receive-hooks that are implemented will be available for use across all repositories within the GHE@HPE site.
* All pre-receive-hooks proposed and implemented must be consumable by all repositories.  The RnD-IT GHE Team will not accept pre-receive-hooks that are customized to only work with certain repositories, teams, or organizations.


## The process for adding a pre-receive hook is as follows:
1. Create a [Fork](https://help.github.com/enterprise/2.6/user/articles/fork-a-repo) of this repository using the guide found.  

2. In newly created Fork, create a new folder named for each type of pre-receive-hook that is being proposed under the **Pre-Receive-Hooks** folder.

3. Include the following for each proposed pre-receive-hook:  
  a. The pre-receive-hook script  
  b. A **README.md** containing the following information:
    - The User/Organization/Team proposing the pre-receive-hook with contact information
    - description of the pre-receive-hook  
    - the intended use case  
    - any prerequisites or dependencies  

  c. A **CONTRIBUTE.md** containing how to contribute to the pre-receive-hook and who to contact.

4. Once all the required information has been added to the Fork, create a [Pull Request](https://help.github.com/enterprise/2.6/user/articles/about-pull-requests/) back to this repository.  

5. The RnD-IT GHE team will then evaluate the new **Pull Request** and contact your team if there are any issues or questions regarding the proposed pre-receive-hook.  


*More information about writing pre-receive-hooks can be found [here](https://help.github.com/enterprise/2.6/admin/guides/developer-workflow/creating-a-pre-receive-hook-script/)*
