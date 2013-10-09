param(
    [string[]]$platforms = @(
        "AnyCpu"
    ),
    [string[]]$targetFrameworks = @(
        "v3.5", 
        "v4.0",
        "v4.5", 
        "v4.5.1"
    ),
    [string]$packageVersion = $null,
    [string]$config = "Release",
    [string]$target = "Rebuild",
    [string]$verbosity = "Minimal",

    [bool]$clean = $true
)

# Initialization
$rootFolder = Split-Path -parent $script:MyInvocation.MyCommand.Definition
. $rootFolder\myget.include.ps1

# Build folders
$outputFolder = Join-Path $rootFolder "bin"

# Myget
$packageVersion = MyGet-Package-Version $packageVersion
$nugetExe = MyGet-NugetExe-Path

# Project
$project = "$rootFolder\src\abbyy.cloudocrsdk\Abbyy.CloudOcrSdk.csproj"
$nuspec = Join-Path $rootFolder "src\abbyy.cloudocrsdk\Abbyy.CloudOcrSdk.nuspec"

if($clean) { MyGet-Build-Clean $rootFolder }

$platforms | ForEach-Object {
    $platform = $_

    $buildOutputFolder = Join-Path $outputFolder "$packageVersion\$platform\$config"

    MyGet-Build-Project -rootFolder $rootFolder `
       -outputFolder $outputFolder `
       -project $project `
       -config $config `
       -target $target `
       -targetFrameworks $targetFrameworks `
       -platform $platform `
	   -verbosity $verbosity `
       -version $packageVersion

    MyGet-Build-Nupkg -rootFolder $rootFolder `
        -outputFolder $buildOutputFolder `
        -project $project `
        -config $config `
        -version $packageVersion `
        -platform $platform

}

MyGet-Build-Success