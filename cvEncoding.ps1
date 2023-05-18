# 載入Get-Encoding函式
Invoke-RestMethod 'raw.githubusercontent.com/hunandy14/Get-Encoding/master/Get-Encoding.ps1'|Invoke-Expression

# 讀取檔案
function ReadContent {
    [CmdletBinding(DefaultParameterSetName = "Encoding")]
    param (
        # 輸入路徑
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path,
        # 編碼處理
        [Parameter(Position = 1, ParameterSetName = "Encoding")]
        [object] $Encoding,
        [Parameter(Position = 1, ParameterSetName = "UTF8")]
        [switch] $UTF8,
        [Parameter(Position = 1, ParameterSetName = "UTF8BOM")]
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
            [IO.Directory]::SetCurrentDirectory(((Get-Location -PSProvider FileSystem).ProviderPath))
            $Path = [IO.Path]::GetFullPath($Path)
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
        # 補償結尾換行
        $reader.BaseStream.Position -= 1
        if ([char]$reader.Read() -eq "`n") { "" }
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
    [CmdletBinding(DefaultParameterSetName = "Encoding")]
    param (
        # 輸出路徑
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path,
        [Parameter(ValueFromPipeline, ParameterSetName = "")]
        [System.Object] $InputObject,
        # 編碼處理
        [Parameter(Position = 1, ParameterSetName = "Encoding")]
        [object] $Encoding,
        [Parameter(Position = 1, ParameterSetName = "UTF8")]
        [switch] $UTF8,
        [Parameter(Position = 1, ParameterSetName = "UTF8BOM")]
        [switch] $UTF8BOM,
        # 輸出參數
        [Parameter(ParameterSetName = "")]
        [switch] $Append,
        [switch] $TrimWhiteSpace, # 清除行尾空白
        [switch] $AutoAppendEndLine, # 保持結尾至少有一行空白
        [switch] $ForceOneEndLine, # 修剪結尾空行
        [Parameter(ParameterSetName = "")]
        [switch] $LF
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
        # 換行符號
        if (-not $LF) {
            $LineTerminator = "`r`n"
        } else { $LineTerminator = "`n" }
        
        # 修復路徑
        [IO.Directory]::SetCurrentDirectory(((Get-Location -PSProvider FileSystem).ProviderPath))
        $Path = [IO.Path]::GetFullPath($Path)
        
        # 檢查路徑是否為資料夾
        if (Test-Path -PathType:Container $Path) {
            Write-Error "The Path `"$Path`" cannot be a folder"; break
        }
        # 檔案不存在新增空檔
        if (!(Test-Path $Path)) {
            New-Item $Path -ItemType:File -Force | Out-Null
        }
        
        # 根據 $Append 參數決定 FileMode
        $FileMode = $Append ? [IO.FileMode]::Append : [IO.FileMode]::Create

        # 建立 FileStream
        $FileStream = New-Object IO.FileStream($Path, $FileMode)
        $StreamWriter = New-Object IO.StreamWriter($FileStream, $Enc)
        $emptyLines = 0
        $firstLine = $true
    }
    
    process {
        $line = $InputObject
        
        # 清除行尾空白
        if ($TrimWhiteSpace) {
            $line = $line.TrimEnd()
        }
        # 追加換行(首行不換)
        if(-not $firstLine) {
            $line = $LineTerminator + $line
        } else { $firstLine = $false }
        # 寫入檔案
        if ($line -notmatch "^\s*$" -or !$ForceOneEndLine) {
            if ($emptyLines -gt 0) {
                for ($i = 0; $i -lt $emptyLines; $i++) {
                    $line = $LineTerminator + $line
                } $emptyLines = 0
            }
            $StreamWriter.Write($line)
        } else { $emptyLines++ }
    }
    
    end {
        # 保持結尾至少有一行空白
        if (($AutoAppendEndLine -and ($line -ne $LineTerminator)) -or ($emptyLines -gt 0)) {
            $StreamWriter.Write($LineTerminator)
        }
        # 關閉檔案
        $StreamWriter.Close()
        $FileStream.Close()
    }
}
## 種編碼讀寫範例
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out1.txt"
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out2.txt" big5
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out3.txt" UTF8
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out4.txt" -UTF8BOM
# "あいうえお日本語の入力テスト                  "|WriteContent "out\Out5.txt" 932
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\Out1.txt" -Append
# "ㄅㄆㄇㄈ這是中文，到底要幾個字才可以自動判別呢"|WriteContent "out\new\Out1.txt" -Append
## 結尾空行測試
# "0行空格測試"|WriteContent "out\Out11.txt" -UTF8BOM
# @("1行空格測試", "")|WriteContent "out\Out12.txt" -UTF8BOM
# @("2行空格測試", "", "")|WriteContent "out\Out13.txt" -UTF8BOM
## 組合測試
# ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Out21.txt" -UTF8
# ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Out21.txt" -UTF8 -LF
# ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Out21.txt" -UTF8 -AutoAppendEndLine
# ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Out21.txt" -UTF8 -TrimWhiteSpace





# 批量轉換編碼
function cvEnc {
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
        if (!$Preview) {
            ReadContent $F1 $srcEnc | 
            WriteContent $F2 $dstEnc -AutoAppendEndLine:$TrimFile -TrimWhiteSpace:$TrimFile -ForceOneEndLine:$TrimFile
        }
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
            if (!$Preview) {
                ReadContent $F1 $srcEnc | 
                WriteContent $F2 $dstEnc -AutoAppendEndLine:$TrimFile -TrimWhiteSpace:$TrimFile -ForceOneEndLine:$TrimFile
            }
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
    # cvEnc "enc\Encoding_UTF8.txt" -ConvertToUTF8 -Temp
    # cvEnc "enc\Encoding_BIG5.txt" -ConvertToSystem -Temp
# } __Test_cvEnc__
