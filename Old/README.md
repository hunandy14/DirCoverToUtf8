# 資料夾特定檔案GBK轉UTF8 (pwsh 7.0)
cvEncode

```
############### File ###############
irm "https://raw.githubusercontent.com/hunandy14/DirCoverToUtf8/master/old/cvEncode.ps1" | iex
$cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
$cvEnc.convertDir("UTF8_File", "Output")
# $cvEnc.convertDir("UTF8_File")

############### Dir ###############
# $cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
irm "https://raw.githubusercontent.com/hunandy14/DirCoverToUtf8/master/old/cvEncode.ps1" | iex
$srcDir = "Z:\Work\doc_1130\source_before"
$dstDir = "Z:\Work\cvEncode\doc_1130"
[cvEncode]::new('Shift-JIS', 'UTF8', @("*.*")).convertDir($srcDir, $dstDir)
```
