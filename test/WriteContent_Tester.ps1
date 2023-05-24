


# 編碼與結尾換行測試
"0行空格測試"|WriteContent "out\Out0_System.txt"
@("1行空格測試", "")|WriteContent "out\Out1_950.txt" 950
@("1行空格測試`r`n")|WriteContent "out\Out1_UTF8BOM.txt" -UTF8BOM
@("2行空格測試", "", "")|WriteContent "out\Out2_UTF8.txt" -UTF8
@("2行空格測試", "`r`n")|WriteContent "out\Out2_UTF8BOM.txt" -UTF8BOM -ShowTimeTaken


# 消除空白與換行測試
ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Trim\Out_Trim.txt" -TrimWhiteSpace
ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Trim\Out_EnsureOneEndLine.txt" -EnsureOneEndLine
ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Trim\Out_ForceOneEndLine.txt" -ForceOneEndLine
ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Trim\Out_TrimFile.txt" -TrimWhiteSpace -ForceOneEndLine


# 跑分測試
$ct = ReadContent "test\f001.data" 65001 -ShowTimeTaken
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$tt = 0
$cc = 20
for ($i = 0; $i -lt $cc; $i++) {
    $ct|WriteContent "R:\file1.data" -UTF8 -ShowTimeTaken
    $tt += $time
} 
Write-Host "平均:" $($tt/$cc)
