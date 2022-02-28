function FileTrim {
    param (
        [System.Object] $Content,
        [string] $str = " |`t"
    )
    for ($i = 0; $i -lt $Content.Count; $i++) {
        $Content[$i] = $Content[$i].TrimEnd(" |`t")
        if ($Content[$i] -ne "") { $Line = $i }
    } $Content = $Content[0..($Line)]
    return $Content
}
function ReadContent {
    [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "")]
        [string] $Path,
        [Parameter(Position = 2, ParameterSetName = "A")]
        [int] $Encoding,
        [Parameter(Position = 2, ParameterSetName = "B")]
        [switch] $DefaultEncoding
    )
    # 從管道輸入
    if ($InputObject) { $Content = $InputObject }
    # 檢查檔案
    if (!(Test-Path $Path -PathType:Leaf)) {
        Write-Error "路徑不存在"
        return
    }
    
    # 獲取編碼
    if ($DefaultEncoding) {
        # 使用當前系統編碼
        $Enc = [Text.Encoding]::Default
    }
    elseif ((!$Encoding) ) {
        # 完全不指定預設預設URF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    }
    elseif ($Encoding -eq 65001) {
        # 指定UTF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    }
    else {
        # 使用者指定
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    }
    
    # 讀取檔案
    $Content = [System.IO.File]::ReadAllLines($Path, $Enc)
    return $Content
}
# ReadContent "Encoding_SHIFT.txt" 932
# ReadContent "Encoding_UTF8.txt"

function WriteContent {
    [CmdletBinding(DefaultParameterSetName = "D")]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "")]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "C")]
        [int] $Encoding,
        [Parameter(Position = 1, ParameterSetName = "D")]
        [switch] $DefaultEncoding,
        
        [Parameter(ParameterSetName = "")]
        [switch] $NoNewline,
        [Parameter(ParameterSetName = "")]
        [switch] $Append,
        [Parameter(ValueFromPipeline, ParameterSetName = "")]
        [System.Object] $InputObject
    )
    BEGIN {
        $Idx = 0
        $Count = 0
        # 從管道輸入
        if ($InputObject) {
            Write-Host "intput==="$InputObject
            $Content = $InputObject
        }
        
        # 獲取編碼
        if ($DefaultEncoding) {
            # 使用當前系統編碼
            $Enc = [Text.Encoding]::Default
        }
        elseif ((!$Encoding) ) {
            # 完全不指定預設預設URF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        }
        elseif ($Encoding -eq 65001) {
            # 指定UTF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        }
        else {
            # 使用者指定
            $Enc = [Text.Encoding]::GetEncoding($Encoding)
        }
        
        # 建立檔案
        if (!$Append) {
            (New-Item $Path -ItemType:File -Force) | Out-Null
        }
    } process{
        # 寫入檔案
        if($Idx -eq 0){
            [System.IO.File]::AppendAllText($Path, "$_", $Enc);
        } else {
            [System.IO.File]::AppendAllText($Path, "`n$_", $Enc);
        } $Idx++
    }
    END {
        # [System.IO.File]::AppendAllText($Path, "`n", $Enc);
        Write-Host "最後一行==[$Idx][$_]"
        if ($_ -eq "") {
        }
    }
}
# $Content = "漢字"
# $Content|WriteContent "Out.txt" -DefaultEncoding
# $Content|WriteContent "Out.txt" 65001
# $Content|WriteContent "Out.txt"

# (ReadContent "Encoding_SHIFT.txt" 932)|WriteContent "Out.txt" 65001

# 各種編碼讀寫範例
# (ReadContent "Encoding_UTF8.txt")|WriteContent "Out_BIG5.txt" 950
# (ReadContent "0.txt")|WriteContent "Out_BIG5.txt" 950
# (ReadContent "2.txt").Count
# (ReadContent "1.txt")|WriteContent "Out_BIG5.txt" 950

# $Enc1 = [Text.Encoding]::GetEncoding(65001)
# $Enc2 = New-Object System.Text.UTF8Encoding $False
# (Get-Content "1.txt" -Encoding:UTF8)

$str = [System.IO.File]::ReadLines("0.txt")
# $str

$str.Length

# (ReadContent "2.txt")|WriteContent "Out_BIG5.txt" 950
# (ReadContent "Encoding_BIG5.txt" 950)|WriteContent "Out_BIG5.txt" 950
# (ReadContent "Encoding_UTF8.txt")|WriteContent "Out_BIG5.txt" 950

# function cvEncode{
#     param (
#         $scrPath,
#         $dstPath
#     )
#     $Content = Get-Content $scrPath -Encoding:Default
#     $Encode = New-Object System.Text.UTF8Encoding $False
#     New-Item -ItemType File -Path $dstPath -Force | Out-Null
#     [System.IO.File]::WriteAllLines($dstPath, $Content, $Encode)
# }
# cvEncodeToUTF8 Encode_Default.txt Encode_UTF8.txt
