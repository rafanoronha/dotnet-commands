$ErrorActionPreference = "Stop"
$releases = Invoke-WebRequest https://github.com/Lambda3/dotnet-commands/releases.atom
$uri="https://github.com/Lambda3/dotnet-commands/releases/download/$($([xml]$releases.Content).feed.entry[0].title)/dotnet-commands.zip"
$outFile=[System.IO.Path]::GetTempFileName()
Invoke-WebRequest -uri $uri -OutFile $outFile
Add-Type -assembly System.IO.Compression.FileSystem
$outDir = "$outFile-extracted"
[System.IO.Compression.ZipFile]::ExtractToDirectory($outFile, $outDir)
Write-Host $outDir
. "$outDir\dotnet-commands.cmd" install dotnet-commands --verbose --pre
if ($LASTEXITCODE -ne 0) {
    Write-Host "Could not install."
    exit 1
}
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = "$env:USERPROFILE\.nuget\commands\bin;$path"
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
$env:Path="$env:USERPROFILE\.nuget\commands\bin;$env:Path"