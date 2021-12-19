# 資料夾特定檔案GBK轉UTF8
cvEncode
```
irm "https://raw.githubusercontent.com/hunandy14/DirCoverToUtf8/master/ConvertEncode.ps1" | iex

############### UTF8　-＞　Shift-JIS ###############
$cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
$cvEnc.convertDir("UTF8_File", "Output")
# $cvEnc.convertDir("UTF8_File")

############### Shift-JIS　-＞　UTF8 ###############
$cvEnc = [cvEncode]::new('Shift-JIS', 'UTF8')
$cvEnc.convert("JIS_File\A.txt")
# $cvEnc.convert("JIS_File\B.md", "Output\convertTest2.md")
```
