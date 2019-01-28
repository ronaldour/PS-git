# Git update remote branches

This Powershell script updates all the branches names from a repository adding a prefix to each name


### How to use it

Run the powershell script with the following parameters:

- Url: The git repository Url
- Username: The username to authenticate to the repo (optional if credentials are already configured)
- Password: The password to authenticate (optional optional if credentials are already configured)
- Prefix: Prefix to add to the branches

```
PS C:\> .\update-branches.ps1 -Url <url> -Username <username> -Password <password> -Prefix <prefix>
```

#### Important

- If you are using github the default branch can not be deleted so there are going to be two branches, one with the old name and one with the new name
Please change the default branch and delete it manually

- The cloned repos are not deleted, delete them if you want to re-run the script

### Outputs

The script generates a csv file with some information
