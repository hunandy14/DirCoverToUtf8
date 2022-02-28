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
    # �q�޹D��J
    if ($InputObject) { $Content = $InputObject }
    # �ˬd�ɮ�
    if (!(Test-Path $Path -PathType:Leaf)) {
        Write-Error "���|���s�b"
        return
    }
    
    # ����s�X
    if ($DefaultEncoding) {
        # �ϥη�e�t�νs�X
        $Enc = [Text.Encoding]::Default
    }
    elseif ((!$Encoding) ) {
        # ���������w�w�]�w�]URF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    }
    elseif ($Encoding -eq 65001) {
        # ���wUTF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    }
    else {
        # �ϥΪ̫��w
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    }
    
    # Ū���ɮ�
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
        # �q�޹D��J
        if ($InputObject) {
            Write-Host "intput==="$InputObject
            $Content = $InputObject
        }
        
        # ����s�X
        if ($DefaultEncoding) {
            # �ϥη�e�t�νs�X
            $Enc = [Text.Encoding]::Default
        }
        elseif ((!$Encoding) ) {
            # ���������w�w�]�w�]URF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        }
        elseif ($Encoding -eq 65001) {
            # ���wUTF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        }
        else {
            # �ϥΪ̫��w
            $Enc = [Text.Encoding]::GetEncoding($Encoding)
        }
        
        # �إ��ɮ�
        if (!$Append) {
            (New-Item $Path -ItemType:File -Force) | Out-Null
        }
    } process{
        # �g�J�ɮ�
        if($Idx -eq 0){
            [System.IO.File]::AppendAllText($Path, "$_", $Enc);
        } else {
            [System.IO.File]::AppendAllText($Path, "`n$_", $Enc);
        } $Idx++
    }
    END {
        # [System.IO.File]::AppendAllText($Path, "`n", $Enc);
        Write-Host "�̫�@��==[$Idx][$_]"
        if ($_ -eq "") {
        }
    }
}
# $Content = "�~�r"
# $Content|WriteContent "Out.txt" -DefaultEncoding
# $Content|WriteContent "Out.txt" 65001
# $Content|WriteContent "Out.txt"

# (ReadContent "Encoding_SHIFT.txt" 932)|WriteContent "Out.txt" 65001

# �U�ؽs�XŪ�g�d��
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
