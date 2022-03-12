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
    # 從管道輸入
    if ($InputObject) { $Content = $InputObject }
    # 檢查檔案
    if (!(Test-Path $Path -PathType:Leaf)) {
        Write-Error "路徑不存在"
        return
    }

    # 獲取編碼
    if ($DefaultEncoding) { # 使用當前系統編碼
        $Enc = [Text.Encoding]::Default
    } elseif ((!$Encoding) ) { # 完全不指定預設
        # $Enc = New-Object System.Text.UTF8Encoding $False
        $Enc = [Text.Encoding]::Default
    } elseif ($Encoding -eq 65001) { # 指定UTF8
        $Enc = New-Object System.Text.UTF8Encoding $False
    } else { # 使用者指定
        $Enc = [Text.Encoding]::GetEncoding($Encoding)
    }

    # 讀取檔案
    $Content = [System.IO.File]::ReadAllLines($Path, $Enc)
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
        # 從管道輸入
        if ($InputObject) {
            Write-Host "intput==="$InputObject
            $Content = $InputObject
        }

        # 獲取編碼
        if ($DefaultEncoding) { # 使用當前系統編碼
            $Enc = [Text.Encoding]::Default
        } elseif ((!$Encoding) ) { # 完全不指定預設
            $Enc = New-Object System.Text.UTF8Encoding $False
            # $Enc = [Text.Encoding]::Default
        } elseif ($Encoding -eq 65001) { # 指定UTF8
            $Enc = New-Object System.Text.UTF8Encoding $False
        } else { # 使用者指定
            $Enc = [Text.Encoding]::GetEncoding($Encoding)
        }

        # 建立檔案
        if (!$Append) { (New-Item $Path -ItemType:File -Force) | Out-Null }
    } process{

        [System.IO.File]::AppendAllText($Path, "$_`n", $Enc);
    }
    END { }
}
# 各種編碼讀寫範例
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
    # 獲取當前位置
    if ($PSScriptRoot) { $curDir = $PSScriptRoot } else { $curDir = (Get-Location).Path }
    # 輸出位置為空時自動指定到暫存目錄
    if ($Temp) {
        $dstPath = $env:TEMP+"\cvEncode"
        $dstPath_bk = $env:TEMP + "\cvEncode_bk"
        if (Test-Path $dstPath -PathType:Container) {
            New-Item $dstPath_bk -ItemType:Directory -ErrorAction:SilentlyContinue
            (Get-ChildItem "$dstPath" -Recurse) | Move-Item -Destination:$dstPath_bk -Force
        }
    }
    # 編碼名稱
    $srcEncName = [Text.Encoding]::GetEncoding($srcEnc).WebName
    $dstEncName = [Text.Encoding]::GetEncoding($dstEnc).WebName
    if (!$srcEncName -or !$dstEncName) { Write-Error "[錯誤]:: 編碼輸入有誤, 檢查是否打錯號碼了" }
    # 檔案來源
    Write-Host ("Convert Files:: [$srcEncName($srcEnc) --> $dstEncName($dstEnc)]")

    if (Test-Path $srcPath -PathType:Leaf) { # 輸入的路徑為檔案
        if ($Temp) { $dstPath = "$dstPath\" + (Get-Item $srcPath).Name }
        if (Test-Path $dstPath -PathType:Container){
            Write-Error "[錯誤]:: `$dstPath=$dstPath 是資料夾, 必須為檔案或空路徑"
            return
        }
        # 輸出路徑
        $F1 = (Get-Item $srcPath).FullName
        $F2 = $dstPath
        Write-Host "  From: " -NoNewline
        Write-Host "$F1" -ForegroundColor:White
        Write-Host "  └─To: " -NoNewline
        Write-Host "$F2" -ForegroundColor:Yellow
        # 輸出檔案
        $Content = (ReadContent $F1 $srcEnc)
        if ($TrimFile) { $Content = (TrimFile $Content) }
        if (!$Preview) { $Content|WriteContent $F2 $dstEnc }
        # 開啟暫存目錄
        if ($Temp) { explorer "$($env:TEMP)\cvEncode" }
        return
    } elseif (Test-Path $srcPath -PathType:Container) { # 輸入的路徑為資料夾
        if (Test-Path $dstPath -PathType:Leaf){
            Write-Error "[錯誤]:: `$dstPath=$dstPath 是檔案, 必須為資料夾或空路徑"
            return
        }
        $collection = Get-ChildItem $srcPath -Recurse -Include:$Filter
        foreach ($item in $collection) {
            # 獲取相對路徑
            Set-Location $srcPath;
            $rela = ($item|Resolve-Path -Relative) -replace("\.\\", "")
            Set-Location $curDir
            # 輸出路徑
            $F1=$item.FullName
            $F2=$dstPath.TrimEnd('\') + "\$rela"
            Write-Host "  From: " -NoNewline
            Write-Host "$rela" -ForegroundColor:White
            Write-Host "  └─To: " -NoNewline
            Write-Host "$F2" -ForegroundColor:Yellow
            # 輸出檔案
            $Content = (ReadContent $F1 $srcEnc)
            if ($TrimFile) { $Content = TrimFile $Content }
            if (!$Preview) { $Content|WriteContent $F2 $dstEnc }
        }
        Write-Host ("Convert Files:: [$srcEncName($srcEnc) --> $dstEncName($dstEnc)]")
        # 開啟暫存目錄
        if ($Temp) { explorer $dstPath }
        return
    }
    else {
        Write-Error "[錯誤]:: `$srcPath=$srcPath 該路徑有誤"
    }
}

# function __Test_cvEnc__ {
    # 轉換相對路徑資料測試
    # $path1 = ".\enc\932"
    # $path2 = ".\out"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # 轉換相對路徑檔案測試
    # cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932
    # cvEnc ".\enc\Trim.txt" ".\out.txt" -TrimFile
    #
    # 轉換絕對路徑資料夾測試
    # $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932"
    # $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # 轉換絕對路徑檔案測試
    # $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932\Trim.txt"
    # $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out.txt"
    # cvEnc $path1 $path2 932
    # cvEnc $path1 $path2 932 -TrimFile
    # 
    # 空路徑自動指定到暫存目錄
    cvEnc ".\enc\932\kyouto.txt" 932 -Temp
    # cvEnc ".\enc\932\kyouto.txt" 932 65001
    # cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932 65001
    # cvEnc ".\enc\932" 932 65001
# } __Test_cvEnc__
