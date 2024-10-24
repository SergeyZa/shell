Import-Module -Name Terminal-Icons

oh-my-posh --init --shell pwsh --config D:\projects\shell\sergeyz.omp.json | Invoke-Expression

function ??
{
    gh copilot suggest -t shell @args
}

function ps?
{
    gh copilot suggest -t shell 'use powershell to ' + @args
}

function git?
{
    gh copilot suggest -t git @args
}

function gh?
{
    gh copilot suggest -t gh @args
}
