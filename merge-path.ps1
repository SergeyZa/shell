param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('User','Process','Machine')]
    [string]$Source,

    [Parameter(Mandatory=$false)]
    [ValidateSet('User','Process','Machine')]
    [string]$Destination
)

function Merge-Path {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('User','Process','Machine')]
        [string]$Source,

        [Parameter(Mandatory)]
        [ValidateSet('User','Process','Machine')]
        [string]$Destination
    )

    function Get-Path([string]$scope) {
        return [System.Environment]::GetEnvironmentVariable('PATH', $scope)
    }

    function Set-Path([string]$scope, [string]$value) {
        if ($scope -eq 'Process') {
            $env:PATH = $value
        } elseif ($scope -eq 'User' -or $scope -eq 'Machine') {
            [System.Environment]::SetEnvironmentVariable('PATH', $value, $scope)
        }
    }

    $srcPath = Get-Path $Source
    $dstPath = Get-Path $Destination

    $srcList = $srcPath -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim() }
    $dstList = $dstPath -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim() }

    # Add missing paths from source to destination
    $merged = $dstList + ($srcList | Where-Object { $dstList -notcontains $_ })
    $mergedPath = ($merged | Select-Object -Unique) -join ';'

    Set-Path $Destination $mergedPath
}

# If called with parameters, invoke the function
if ($PSBoundParameters.ContainsKey('Source') -and $PSBoundParameters.ContainsKey('Destination')) {
    Merge-Path -Source $Source -Destination $Destination
}
