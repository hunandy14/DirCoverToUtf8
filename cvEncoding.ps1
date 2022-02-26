function cvEncode{
    param (
        $scrPath,
        $dstPath
    )
    $Content = Get-Content $scrPath -Encoding:Default
    $Encode = New-Object System.Text.UTF8Encoding $False
    New-Item -ItemType File -Path $dstPath -Force | Out-Null
    [System.IO.File]::WriteAllLines($dstPath, $Content, $Encode)
}
# cvEncodeToUTF8 Encode_Default.txt Encode_UTF8.txt

function FileTrim {
    param (
        [System.Object] $Content,
        [string] $str = " |`t"
    )
    for ($i = 0; $i -lt $Content.Count; $i++) {
        $Content[$i] = $Content[$i].TrimEnd(" |`t")
        if($Content[$i] -ne ""){ $Line = $i }
    } $Content = $Content[0..($Line)]
    return $Content
}
function ReadContent {
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
    if ((!$Encoding) ) {
        $Enc = New-Object System.Text.UTF8Encoding $False
        # $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) {
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else {
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    } 
    # 讀取檔案
    [System.IO.File]::ReadAllLines($Path, $Enc)
    return $Content
} # ReadContent "Encoding_SHIFT.txt" -Encoding:932
function WriteContent {
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = "")]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "A")]
        [Parameter(Position = 1, ParameterSetName = "B")]
        [System.Object] $Content,
        [Parameter(Position = 2, ParameterSetName = "A")]
        [Parameter(Position = 2, ParameterSetName = "C")]
        [int] $Encoding,
        [Parameter(Position = 2, ParameterSetName = "B")]
        [Parameter(Position = 2, ParameterSetName = "D")]
        [switch] $DefaultEncoding,
        
        [Parameter(ParameterSetName = "")]
        [switch] $NoNewline,
        [Parameter(ValueFromPipeline, ParameterSetName = "C")]
        [Parameter(ValueFromPipeline, ParameterSetName = "D")]
        [System.Object] $InputObject
    )
    # 從管道輸入
    if ($InputObject) { $Content = $InputObject }
    # 獲取編碼
    if ((!$Encoding) ) {
        $Enc = New-Object System.Text.UTF8Encoding $False
        # $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) {
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else {
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    } 
    # 建立檔案
    if ( Test-Path $Path -PathType:Leaf ) {
        (New-Item $Path -ItemType:File -Force)|Out-Null
    }
    # 寫入檔案
    if ($NoNewline) {
        [System.IO.File]::WriteAllLines($Path, ($Content[0..($Content.Count-2)]), $Enc);
        [System.IO.File]::AppendAllText($Path, ($Content[-1]), $Enc);
    } else {
        [System.IO.File]::WriteAllLines($Path, $Content, $Enc);
    }
}
$Content = "漢字"
# $Content|WriteContent "Out.txt" -Encoding:65001
$Content|WriteContent "Out.txt" 65001
