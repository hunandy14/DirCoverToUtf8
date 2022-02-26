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
    # �q�޹D��J
    if ($InputObject) { $Content = $InputObject }
    # �ˬd�ɮ�
    if (!(Test-Path $Path -PathType:Leaf)) {
        Write-Error "���|���s�b"
        return
    }
    # ����s�X
    if ((!$Encoding) ) {
        $Enc = New-Object System.Text.UTF8Encoding $False
        # $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) {
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else {
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    } 
    # Ū���ɮ�
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
    # �q�޹D��J
    if ($InputObject) { $Content = $InputObject }
    # ����s�X
    if ((!$Encoding) ) {
        $Enc = New-Object System.Text.UTF8Encoding $False
        # $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) {
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else {
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    } 
    # �إ��ɮ�
    if ( Test-Path $Path -PathType:Leaf ) {
        (New-Item $Path -ItemType:File -Force)|Out-Null
    }
    # �g�J�ɮ�
    if ($NoNewline) {
        [System.IO.File]::WriteAllLines($Path, ($Content[0..($Content.Count-2)]), $Enc);
        [System.IO.File]::AppendAllText($Path, ($Content[-1]), $Enc);
    } else {
        [System.IO.File]::WriteAllLines($Path, $Content, $Enc);
    }
}
$Content = "�~�r"
# $Content|WriteContent "Out.txt" -Encoding:65001
$Content|WriteContent "Out.txt" 65001
