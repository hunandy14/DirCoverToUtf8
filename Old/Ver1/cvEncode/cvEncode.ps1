[CmdletBinding()]
Param(
    $srcFile,
    $srcEncode,
    $dstFile,
    $dstEncode
)
New-Item -ItemType File -Path $dstFile -Force | Out-Null
$ct = Get-Content -Encoding $srcEncode $srcFile
$ct | Out-File -Encoding $dstEncode -FilePath $dstFile
