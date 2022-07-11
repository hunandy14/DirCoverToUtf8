function TrimFile {
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
    $Path = [IO.Path]::GetFullPath($Path)
    if (!(Test-Path $Path -PathType:Leaf)) {
        Write-Error "���|���s�b"
        return
    }

    # ����s�X
    if ($DefaultEncoding) { # �ϥη�e�t�νs�X
        # $Enc = [Text.Encoding]::Default
        $Enc = PowerShell.exe -C "& {return [Text.Encoding]::Default}"
    } elseif ((!$Encoding) ) { # ���������w�w�]
        # $Enc = New-Object System.Text.UTF8Encoding $False
        $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) { # ���wUTF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else { # �ϥΪ̫��w
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    }

    # Ū���ɮ�
    $Content = [IO.File]::ReadAllLines($Path, $Enc)
    return $Content
}
# ReadContent "enc\Encoding_SHIFT.txt" 932
# (ReadContent "enc\Encoding_UTF8.txt" 65001)
# TrimFile (ReadContent "enc\Encoding_UTF8.txt" 65001)
# return

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
        # ����s�X
        if ($DefaultEncoding) { # �ϥη�e�t�νs�X
            # $Enc = [Text.Encoding]::Default
            $Enc = PowerShell.exe -C "& {return [Text.Encoding]::Default}"
        } elseif ((!$Encoding) ) { # ���������w�w�]
            $Enc = New-Object System.Text.UTF8Encoding $False
            # $Enc = [Text.Encoding]::Default
        } elseif ($Encoding -eq 65001) { # ���wUTF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        } else { # �ϥΪ̫��w
            $Enc = [Text.Encoding]::GetEncoding($Encoding)
        }

        # �إ��ɮ�
        if (!$Append) { 
            (New-Item $Path -ItemType:File -Force) | Out-Null
        } $Path = [IO.Path]::GetFullPath($Path)
        
    } process{
        [IO.File]::AppendAllText($Path, "$_`n", $Enc);
    }
    END { }
}
# �U�ؽs�XŪ�g�d��
# (ReadContent "enc\Encoding_BIG5.txt" 950)|WriteContent "Out_BIG5.txt" 950
# (ReadContent "enc\Encoding_UTF8.txt")|WriteContent "Out_BIG5.txt" 950
# (ReadContent "enc\Encoding_BIG5.txt" -Def)|WriteContent "Out.txt"

function cvEnc{
    [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $srcPath,
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [string] $dstPath,
        [Parameter(Position = 2, ParameterSetName = "A")]
        [Parameter(Position = 1, ParameterSetName = "B")]
        [int] $srcEnc = [Text.Encoding]::Default.CodePage,
        [Parameter(Position = 3, ParameterSetName = "A")]
        [Parameter(Position = 2, ParameterSetName = "B")]
        [int] $dstEnc = 65001,
        
        [Parameter(ParameterSetName = "B")]
        [switch] $Temp,
        [Parameter(ParameterSetName = "")]
        [System.Object] $Filter = @("*.*"),
        [Parameter(ParameterSetName = "")]
        [switch] $Preview,
        [Parameter(ParameterSetName = "")]
        [switch] $TrimFile
    )
    # �����e��m
    if ($PSScriptRoot) { $curDir = $PSScriptRoot } else { $curDir = (Get-Location).Path }
    # ��X��m���Ůɦ۰ʫ��w��Ȧs�ؿ�
    if ($Temp) {
        $dstPath = $env:TEMP+"\cvEncode"
        $dstPath_bk = $env:TEMP + "\cvEncode_bk"
        if (Test-Path $dstPath -PathType:Container) {
            New-Item $dstPath_bk -ItemType:Directory -ErrorAction:SilentlyContinue
            (Get-ChildItem "$dstPath" -Recurse) | Move-Item -Destination:$dstPath_bk -Force
        }
    }
    # �s�X�W��
    $srcEncName = [Text.Encoding]::GetEncoding($srcEnc).WebName
    $dstEncName = [Text.Encoding]::GetEncoding($dstEnc).WebName
    if (!$srcEncName -or !$dstEncName) { Write-Error "[���~]:: �s�X��J���~, �ˬd�O�_�������X�F" }
    # �ɮרӷ�
    Write-Host ("Convert Files:: [$srcEncName($srcEnc) --> $dstEncName($dstEnc)]")

    if (Test-Path $srcPath -PathType:Leaf) { # ��J�����|���ɮ�
        if ($Temp) { $dstPath = "$dstPath\" + (Get-Item $srcPath).Name }
        if (Test-Path $dstPath -PathType:Container){
            Write-Error "[���~]:: `$dstPath=$dstPath �O��Ƨ�, �������ɮשΪŸ��|"
            return
        }
        # ��X���|
        $F1 = (Get-Item $srcPath).FullName
        $F2 = $dstPath
        Write-Host "  From: " -NoNewline
        Write-Host "$F1" -ForegroundColor:White
        Write-Host "  �|�wTo: " -NoNewline
        Write-Host "$F2" -ForegroundColor:Yellow
        # ��X�ɮ�
        $Content = (ReadContent $F1 $srcEnc)
        if ($TrimFile) { $Content = (TrimFile $Content) }
        if (!$Preview) { $Content|WriteContent $F2 $dstEnc }
        # �}�ҼȦs�ؿ�
        if ($Temp) { explorer "$($env:TEMP)\cvEncode" }
        return
    } elseif (Test-Path $srcPath -PathType:Container) { # ��J�����|����Ƨ�
        if (Test-Path $dstPath -PathType:Leaf){
            Write-Error "[���~]:: `$dstPath=$dstPath �O�ɮ�, ��������Ƨ��ΪŸ��|"
            return
        }
        $collection = Get-ChildItem $srcPath -Recurse -Include:$Filter
        foreach ($item in $collection) {
            # ����۹���|
            Set-Location $srcPath;
            $rela = ($item|Resolve-Path -Relative) -replace("\.\\", "")
            Set-Location $curDir
            # ��X���|
            $F1=$item.FullName
            $F2=$dstPath.TrimEnd('\') + "\$rela"
            Write-Host "  From: " -NoNewline
            Write-Host "$rela" -ForegroundColor:White
            Write-Host "  �|�wTo: " -NoNewline
            Write-Host "$F2" -ForegroundColor:Yellow
            # ��X�ɮ�
            $Content = (ReadContent $F1 $srcEnc)
            if ($TrimFile) { $Content = TrimFile $Content }
            if (!$Preview) { $Content|WriteContent $F2 $dstEnc }
        }
        Write-Host ("Convert Files:: [$srcEncName($srcEnc) --> $dstEncName($dstEnc)]")
        # �}�ҼȦs�ؿ�
        if ($Temp) { explorer $dstPath }
        return
    }
    else {
        Write-Error "[���~]:: `$srcPath=$srcPath �Ӹ��|���~"
    }
}

# function __Test_cvEnc__ {
    # �ഫ�۹���|��ƴ���
    # $path1 = ".\enc\932"
    # $path2 = ".\out"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # �ഫ�۹���|�ɮ״���
    # cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932
    # cvEnc ".\enc\Trim.txt" ".\out.txt" -TrimFile
    #
    # �ഫ������|��Ƨ�����
    # $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932"
    # $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # �ഫ������|�ɮ״���
    # $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932\Trim.txt"
    # $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out.txt"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # 
    # �Ÿ��|�۰ʫ��w��Ȧs�ؿ�
    # cvEnc ".\enc\932\kyouto.txt" 932 -Temp
    # cvEnc ".\enc\932\kyouto.txt" 932 65001
    # cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932 65001
    # cvEnc ".\enc\932" 932 65001
# } __Test_cvEnc__
