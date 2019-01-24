[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)]
  [string] $Url,

  [Parameter(Mandatory=$false)]
  [string] $Username,

  [Parameter(Mandatory=$false)]
  [string] $Password,

  [Parameter(Mandatory=$true)]
  [string] $Prefix
)

#Replace '@' with '%40' in case that password contains @
#Should do it for other characters
$Password = $Password -replace "@", "%40"

$splitUrl = $Url -split "://"

#Set URL 
if(!$Username){
  $GitUrl = $Url
}
elseif(!$Password){
  $GitUrl = $splitUrl[0] + "://" + $Username + "@" + $splitUrl[1]
}
else{
  $GitUrl = $splitUrl[0] + "://" + $Username + ":" + $Password + "@" + $splitUrl[1]
}

try {
  git clone $GitUrl Old

  if($LASTEXITCODE) { throw "Error clonning the git repo, it may already exist"}

  Set-Location Old

  $oldRefs = $(git ls-remote --heads --quiet)
  $oldbranches =  $oldRefs | ForEach-Object { Split-Path -Path $_ -Leaf }

  $newbranches = $oldbranches | ForEach-Object { $Prefix + $_ }

  #Updating remote branches
  for($i = 0; $i -lt $oldbranches.Length; $i++){
    git checkout $oldbranches[$i]
    git branch -m $oldbranches[$i] $newbranches[$i]
    git push origin --delete $oldbranches[$i]
    git push origin -u $newbranches[$i]
  }
}
catch {
  Write-Output $("An error ocurred at line: {0} When tryng to update the branches name => {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.Exception.Message)
  return
}

try {
  Set-Location ..
  #Fresh new clone
  git clone $GitUrl New
  if($LASTEXITCODE) { throw "Error clonning the new git repo, it may already exist"}
  Set-Location New

  $checkRefs = $(git ls-remote --heads --quiet)
  $checkbranches =  $checkRefs | ForEach-Object { Split-Path -Path $_ -Leaf }

  $output = @()

  for($i = 0; $i -lt $oldbranches.Length; $i++){

    $lastCommit = git log -1 $("origin/" + $newbranches[$i])
    $output += [PSCustomObject]@{
      OldBranch = $oldbranches[$i];
      NewBranch = $newbranches[$i];
      OldRef = $oldRefs[$i];
      NewRef = $checkRefs[$i];
      Message = $lastCommit[4];
      Date = $lastCommit[2];
      Verified = $checkbranches -contains $newbranches[$i]
    }
  }

  Set-Location ..
  $output | Export-Csv Output.csv -NoTypeInformation
  Write-Output "Done"
}
catch {
  Write-Output $("An error ocurred at line: {0} When tryng to verify the results => {1}" -f $_.InvocationInfo.ScriptLineNumber, $_.Exception.Message)
  return
}