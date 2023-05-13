# 載入Get-Encoding函式
Invoke-RestMethod 'raw.githubusercontent.com/hunandy14/Get-Encoding/master/Get-Encoding.ps1'|Invoke-Expression



# 清理檔案中多餘的空白
function TrimFile {
    param (
        [System.Object] $Content,
        [string] $str
    )
    for ($i = 0; $i -lt $Content.Count; $i++) {
        $Content[$i] = $Content[$i].TrimEnd($str)
        if ($Content[$i] -ne "") { $Line = $i }
    } $Content = $Content[0..($Line)]
    return $Content
}



# 讀取檔案
function ReadContent {
    [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "A")]
        [object] $Encoding,
        [Parameter(Position = 1, ParameterSetName = "B")]
        [switch] $UTF8,
        [Parameter(Position = 1, ParameterSetName = "C")]
        [switch] $UTF8BOM
    )
    
    begin {
        # 處理編碼
        if ($Encoding) { # 自訂編碼
            if ($Encoding -is [Text.Encoding]) {
                $Enc = $Encoding
            } else { $Enc = Get-Encoding $Encoding }
        } else { # 預選項編碼
            if ($UTF8) {
                $Enc = New-Object System.Text.UTF8Encoding $False
            } elseif ($UTF8BOM) {
                $Enc = New-Object System.Text.UTF8Encoding $True
            } else { # 系統語言
                if (!$__SysEnc__) { $Script:__SysEnc__ = [Text.Encoding]::GetEncoding((powershell -nop "([Text.Encoding]::Default).WebName")) }
                $Enc = $__SysEnc__
            }
        }
        
        # 檢查檔案
        if ($Path -and (Test-Path -PathType:Leaf $Path)) {
            $Path = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location -PSProvider FileSystem).ProviderPath, $Path))
        } else { Write-Error "Input file `"$Path`" does not exist" -ErrorAction:Stop }
        # 開啟檔案
        $reader = New-Object System.IO.StreamReader($Path, $Enc)
    }
    
    process {
        # 讀取檔案
        while ($null -ne ($line = $reader.ReadLine())) {
            Write-Output $line
        }
    }
    
    end {
        # 關閉檔案
        if ($null -ne $reader) {
            $reader.Dispose()
        }
    }
}
# ReadContent "enc\Encoding_SHIFT.txt" 932
# ReadContent "enc\Encoding_UTF8.txt" UTF8
# TrimFile (ReadContent "enc\Encoding_UTF8.txt" 65001)



# 輸出檔案
function WriteContent {
    [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "A")] # 預設值是當前Powershell編碼
        [int] $Encoding = (([Text.Encoding]::Default).CodePage), # (Pwsh5=系統, Pwsh7=UTF8)
        [Parameter(Position = 1, ParameterSetName = "B")] # 指定成作業系統的編碼
        [switch] $SystemEncoding,
        [Parameter(ParameterSetName = "")]
        [switch] $Append, # 不清除原有的檔案
        [Parameter(ParameterSetName = "")]
        [switch] $BOM_UTF8, # 輸出BOM的UTF8檔案
        [Parameter(ValueFromPipeline, ParameterSetName = "")]
        [System.Object] $InputObject
    )
    BEGIN {
        # 獲取編碼
        if ($SystemEncoding) { # 把系統編碼覆蓋到Encoding
            $Encoding = PowerShell -NoP -C "([Text.Encoding]::Default).CodePage"
        } $Enc = [Text.Encoding]::GetEncoding($Encoding)
        # 修復 UTF-8 時預設帶有BOM問題
        if (($Enc -eq ([Text.Encoding]::GetEncoding(65001))) -and (!$BOM_UTF8)) {
            $Enc = (New-Object System.Text.UTF8Encoding $False)
        }
        # 修復路徑
        [IO.Directory]::SetCurrentDirectory(((Get-Location -PSProvider FileSystem).ProviderPath))
        $Path = [System.IO.Path]::GetFullPath($Path)
        # 建立並清空檔案
        if (Test-Path -PathType:Container $Path) {
            Write-Error "The Path `"$Path`" cannot be a folder"; break
        }elseif (!(Test-Path $Path)) { # 檔案不存在 -> 新增空檔
            (New-Item $Path -ItemType:File -Force)|Out-Null
        } else { # 檔案已存在 -> 依選項清空
            if (!$Append) { (New-Item $Path -ItemType:File -Force)|Out-Null }
        }
        $Object = ""
    } process{
        $Object += "$InputObject`r`n"
    } END {
        [IO.File]::AppendAllText($Path, $Object, $Enc)
    }
}
# 各種編碼讀寫範例
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out1.txt"
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out2.txt" -SystemEncoding
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out3.txt" -Encoding:65001
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out4.txt" -Encoding:65001 -BOM_UTF8
# "あいうえお日本語の入力テスト                  "|WriteContent "out\Out5.txt" -Encoding:932

# $Enc = (New-Object System.Text.UTF8Encoding $False)
# $a=[IO.File]::ReadAllLines("SpaceFile.txt", $Enc)
# $a=[IO.File]::ReadLines("SpaceFile.txt", $Enc)
# $a=$null
# $a=Get-Content "SpaceFile.txt"
# "a:: $($a.Count)"
# $a|WriteContent "out\Out6.txt" -Encoding:65001 -BOM_UTF8



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
        [switch] $ConvertToUTF8,
        [switch] $ConvertToSystem,
        
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
    if (!$__SysEnc__) { $Script:__SysEnc__ = [Text.Encoding]::GetEncoding((powershell -nop "([Text.Encoding]::Default).WebName")) }
    if ($ConvertToUTF8) {
        $srcEnc = ($__SysEnc__).CodePage
        $srcEncName = ($__SysEnc__).WebName
        $dstEnc = (New-Object System.Text.UTF8Encoding $False).CodePage
        $dstEncName = (New-Object System.Text.UTF8Encoding $False).WebName
    } elseif ($ConvertToSystem) {
        $srcEnc = (New-Object System.Text.UTF8Encoding $False).CodePage
        $srcEncName = (New-Object System.Text.UTF8Encoding $False).WebName
        $dstEnc = ($__SysEnc__).CodePage
        $dstEncName = ($__SysEnc__).CodePage
    } else {
        $srcEncName = [Text.Encoding]::GetEncoding($srcEnc).WebName
        $dstEncName = [Text.Encoding]::GetEncoding($dstEnc).WebName
    }
    if (!$srcEncName -or !$dstEncName) { Write-Error "[錯誤]:: 編碼輸入有誤, 檢查是否打錯號碼了" -ErrorAction Stop}
    
    
    # 檔案來源
    Write-Host ("Convert Files:: [$srcEncName($srcEnc) --> $dstEncName($dstEnc)]")

    if (Test-Path $srcPath -PathType:Leaf) { # 輸入的路徑為檔案
        if ($Temp) { $dstPath = "$dstPath\" + (Get-Item $srcPath).Name }
        if (Test-Path $dstPath -PathType:Container){
            Write-Error "[錯誤]:: `$dstPath=$dstPath 是資料夾, 必須為檔案或空路徑" -ErrorAction Stop
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
        Write-Error "[錯誤]:: `$srcPath=$srcPath 該路徑有誤"; -ErrorAction Stop
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
    # cvEnc ".\enc\932\kyouto.txt" 932 -Temp
    # cvEnc ".\enc\932\kyouto.txt" 932 65001
    # cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932 65001
    # cvEnc ".\enc\932" 932 65001
    # 
    # 預選編碼測試
    # cvEnc "enc\Encoding_BIG5.txt" -ConvertToUTF8 -Temp
    # cvEnc "enc\Encoding_UTF8.txt" -ConvertToSystem -Temp
# } __Test_cvEnc__
