
###########################
# React-related functions #
###########################
function syys {
  $currentPath = Get-FullPath
  Start-NewPowershell {
    param($currentPath)
    Set-Location $currentPath
    yarn
    yarn start
  } ($($currentPath))
}
Add-ToFunctionList -category 'React' -name 'syys' -value 'Start new PS w/yarn && yarn start'


Set-Alias y yarn
Add-ToFunctionList -category 'React' -name 'y' -value 'yarn'


function ys { yarn start }
Add-ToFunctionList -category 'React' -name 'ys' -value 'yarn start'


function yt { yarn test }
Add-ToFunctionList -category 'React' -name 'yt' -value 'yarn test'


function yys {
  yarn
  yarn start
}
Add-ToFunctionList -category 'React' -name 'yys' -value 'yarn && yarn start'


function yu { yarn test -u }
Add-ToFunctionList -category 'React' -name 'yu' -value 'yarn test -u (Test w/upd snapshots)'



function ycra {
  [Parameter(Mandatory)][String]$name
  yarn create react-app $name --template typescript
}
Add-ToFunctionList -category 'React' -name 'ycra' -value 'yarn create react-TS-app'
