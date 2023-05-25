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
        [switch] $UTF8BOM,
        [switch] $ShowTimeTaken
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
        if ($Path) {
            $Path = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location -PSProvider FileSystem).ProviderPath, $Path))
            if (!(Test-Path -PathType:Leaf -Path $Path)) { Write-Error "Input file `"$Path`" does not exist" -ErrorAction:Stop }
        }
        # 開啟檔案
        $StreamReader = New-Object System.IO.StreamReader($Path, $Enc)
    }
    
    process {
        # 讀取檔案
        if ($ShowTimeTaken) { $stopwatch = [System.Diagnostics.Stopwatch]::StartNew() }
        while ($null -ne ($line = $StreamReader.ReadLine())) {
            $line
        }
        if ($ShowTimeTaken) { $stopwatch.Stop() }
    }
    
    end {
        # 補償結尾換行
        $StreamReader.BaseStream.Position -= 1
        if ([char]$StreamReader.Read() -eq "`n") { "" }
        # 關閉檔案
        if ($null -ne $StreamReader) { $StreamReader.Dispose() }
        # 顯示時間消耗
        if ($ShowTimeTaken) {
            $file = $path -replace '^(.*[\\/])'
            $time = $stopwatch.Elapsed.TotalSeconds*1000
            Write-Host "Elapsed time: " -NoNewline
            Write-Host $time -NoNewline -ForegroundColor Yellow
            Write-Host " milliseconds in ReadContent() for reading file '$file'"
        }
    }
} # ReadContent "enc\Encoding_UTF8_1.txt" UTF8



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
        [switch] $EnsureOneEndLine, # 保持結尾至少有一行空白
        [switch] $ForceOneEndLine, # 修剪結尾空行
        [Parameter(ParameterSetName = "")]
        [switch] $LF,
        [switch] $ShowTimeTaken
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
        
        # 檢查路徑
        if ($Path) {
            $Path = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location -PSProvider FileSystem).ProviderPath, $Path))
            # 檢查路徑是否為資料夾
            if (Test-Path -PathType:Container -Path $Path) {
                Write-Error "The Path `"$Path`" cannot be a folder"; break
            }
            # 檔案不存在新增空檔
            if (!(Test-Path -Path $Path)) {
                New-Item $Path -ItemType:File -Force | Out-Null
            }
        }
        
        # 換行符號
        $LineTerminator = if ($LF) { "`n" } else { "`r`n" }
        # FileMode 參數
        $FileMode = if ($Append) { [IO.FileMode]::Append } else { [IO.FileMode]::Create }
        # 建立 Stream
        $FileStream = New-Object IO.FileStream($Path, $FileMode)
        $StreamWriter = New-Object IO.StreamWriter($FileStream, $Enc)
        # 換行數
        $emptyLines = 0
        # 計時開始
        if ($ShowTimeTaken) { $stopwatch = [System.Diagnostics.Stopwatch]::StartNew() }
    }
    
    process { # 125/290
        # 清除行尾空白
        if ($TrimWhiteSpace) { $InputObject = $InputObject.TrimEnd() }
        # 寫入檔案 (遇到非空白行時)
        if ($InputObject) {
            $StreamWriter.Write($LineTerminator*$emptyLines)
            $StreamWriter.Write($InputObject); $emptyLines = 0
        }
        $emptyLines += 1
    }
    
    end {
        # 計時結束
        if ($ShowTimeTaken) { $stopwatch.Stop() }
        
        # 輸出剩餘的換行 
        $emptyLines -= 1
        if ($ForceOneEndLine -or ($EnsureOneEndLine -and $emptyLines -eq 0)) { $emptyLines = 1 }
        $StreamWriter.Write($LineTerminator*$emptyLines); $emptyLines = 0
        
        # 關閉檔案
        $StreamWriter.Close()
        $FileStream.Close()
        
        # 顯示時間消耗
        if ($ShowTimeTaken) {
            $file = $path -replace '^(.*[\\/])'
            $script:time = $stopwatch.Elapsed.TotalSeconds*1000
            Write-Host "Elapsed time: " -NoNewline
            Write-Host $time -NoNewline -ForegroundColor Yellow
            Write-Host " milliseconds in ReadContent() for reading file '$file'"
        }
    }
} # ReadContent "enc\Encoding_UTF8.txt" -UTF8 | WriteContent "out\Encoding_TrimFile_UTF8BOM.txt" -UTF8BOM -TrimWhiteSpace -ForceOneEndLine



# 獲取檔案項目
function Get-FilePathItem {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path,
        [Parameter(ParameterSetName = "")]
        [regex] $MatchPath,
        [regex] $NotMatchPath,
        [Parameter(ParameterSetName = "")]
        [array] $Include
    )
    # 獲取檔案並透過管道進行過濾
    if (Test-Path -Path $Path -PathType Leaf) {
        Get-Item $Path
    } elseif (Test-Path -Path $Path -PathType Container) {
        Get-ChildItem -Path $Path -Include $Include -Recurse -File |
            ForEach-Object {
                # 過濾檔案路徑
                if ($MatchPath -and $_.FullName -notmatch $MatchPath) {
                    return
                }
                if ($NotMatchPath -and $_.FullName -match $NotMatchPath) {
                    return
                }
                # 輸出符合條件的物件
                $_
            }
    } else {
        return
    }
} # (Get-FilePathItem "R:\AAA" -NotMatchPath "CCC").FullName



# 批量轉換編碼
function Convert-FileEncoding {
    [Alias("cvEnc")] [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $srcPath,
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [string] $dstPath,
        
        [Parameter(Position = 2, ParameterSetName = "A")]
        [Parameter(Position = 1, ParameterSetName = "B")]
        [object] $srcEnc, # 預設值為系統編碼
        [Parameter(Position = 3, ParameterSetName = "A")]
        [Parameter(Position = 2, ParameterSetName = "B")]
        [object] $dstEnc, # 預設值為UTF8
        [switch] $ConvertToUTF8,
        [switch] $ConvertToSystem,
        
        [Parameter(ParameterSetName = "B")]
        [switch] $Temp,
        [Parameter(ParameterSetName = "")]
        [object] $Filter,
        [Parameter(ParameterSetName = "")]
        [switch] $Preview,
        [Parameter(ParameterSetName = "")]
        [switch] $TrimFile
    )
    
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
    if (!$srcEnc) { $srcEnc = $__SysEnc__ }
    if (!$dstEnc) { $dstEnc = [Text.Encoding]::GetEncoding(65001) }
    # 預選
    if ($ConvertToUTF8) {
        $srcEnc = ($__SysEnc__)
        $dstEnc = (New-Object System.Text.UTF8Encoding $False)
    } elseif ($ConvertToSystem) {
        $srcEnc = (New-Object System.Text.UTF8Encoding $False)
        $dstEnc = ($__SysEnc__)
    } else {
        if ($srcEnc -isnot [Text.Encoding]) { $srcEnc = Get-Encoding $srcEnc }
        if ($dstEnc -isnot [Text.Encoding]) { $dstEnc = Get-Encoding $dstEnc }
    }
    if (!$srcEnc.WebName -or !$dstEnc.WebName) { Write-Error "[錯誤]:: 編碼輸入有誤, 檢查是否打錯號碼了" -ErrorAction Stop}
    
    # 檢查 $srcPath 是否存在
    if (!(Test-Path -Path $srcPath)) { Write-Error "錯誤: $srcPath 路徑不存在" -EA:Stop }
    # 檢查 $srcPath 和 $dstPath 參數
    $srcPathType = if (Test-Path -Path $srcPath -PathType Leaf) {"File"} else {"Directory"}
    $dstPathType = if (Test-Path -Path $dstPath -PathType Leaf) {"File"} elseif (Test-Path -Path $dstPath -PathType Container) {"Directory"} else { if ($dstPath -match '\.\w+$') {"File"} else {"Directory"} }
    # 如果 $srcPath 是目錄，而 $dstPath 是文件，則輸出錯誤並停止執行
    if ($srcPathType -eq "Directory" -and $dstPathType -eq "File") {
        Write-Error "錯誤: 無法將資料夾複製到檔案中" -ErrorAction Stop
    }
    # 如果 $srcPath 是文件，而 $dstPath 是目錄，則修改 $dstPath 並將 $dstPathType 設置為 "File"
    if ($srcPathType -eq "File" -and $dstPathType -eq "Directory") {
        $dstPath = Join-Path -Path $dstPath -ChildPath ($srcPath -replace '^(.*[\\/])')
        $dstPathType = "File"
    }
    
    
    # 開始轉換檔案
    $TrimWhiteSpace = $ForceOneEndLine = $TrimFile
    Write-Host ("Convert Files:: [$($srcEnc.WebName)($($srcEnc.CodePage)) --> $($dstEnc.WebName)($($dstEnc.CodePage))]") -ForegroundColor DarkGreen
    foreach ($_ in (Get-FilePathItem $srcPath -Include:$Filter).FullName) {
        # 獲取路徑
        $F1 = $_
        $F2 = if ($dstPathType -eq "File") { $dstPath } else { Join-Path $dstPath ([System.IO.Path]::GetRelativePath($srcPath, $_)) }
        # 輸出信息
        Write-Host "  From: " -NoNewline
        Write-Host "$F1" -ForegroundColor:White
        Write-Host "  └─To: " -NoNewline
        Write-Host "$F2" -ForegroundColor:Yellow
        # 輸出檔案
        if (!$Preview) {
            if (!(Test-Path -Path $F2)) { New-Item -ItemType:File $F2 -Force | Out-Null }
            $StreamReader = New-Object System.IO.StreamReader($F1, $srcEnc)
            $StreamWriter = New-Object System.IO.StreamWriter($F2, $false, $dstEnc)
            $LineTerminator = if ($LF) { "`n" } else { "`r`n" }
            $emptyLines = 0
            while ($null -ne ($line = $StreamReader.ReadLine())) {
                # 清除行尾空白
                if ($TrimWhiteSpace) { $line = $line.TrimEnd() }
                # 寫入檔案 (遇到非空白行時)
                if ($line) {
                    $StreamWriter.Write($LineTerminator*$emptyLines)
                    $StreamWriter.Write($line); $emptyLines = 0
                }
                $emptyLines += 1
            }
            # 補償結尾換行 (最後一行沒有換行符則不補償換行)
            $StreamReader.BaseStream.Position -= 1
            if ([char]$StreamReader.Read() -ne "`n") { $emptyLines -= 1 }
            # 輸出剩餘的換行
            if ($ForceOneEndLine -or ($EnsureOneEndLine -and $emptyLines -eq 0)) { $emptyLines = 1 }
            $StreamWriter.Write($LineTerminator*$emptyLines); $emptyLines = 0
            # 關閉檔案
            $StreamReader.Close()
            $StreamWriter.Close()
            
            # 測試用呼叫單獨函式
            # ReadContent $F1 $srcEnc | WriteContent $F2 $dstEnc -TrimWhiteSpace:$TrimFile -ForceOneEndLine:$TrimFile -ShowTimeTaken
        }        
    }
    
    
    # 開啟暫存目錄
    if ($Temp) { explorer "$($env:TEMP)\cvEncode" }
}

# cvEnc "enc\Encoding_BIG5.txt" "R:\cvEnd"
# cvEnc "enc\Encoding_UTF8.txt" "R:\cvEnd\file1.txt" 932
# cvEnc "enc" "R:\cvEnd\enc" 932 65001
# cvEnc "enc" "R:\cvEnd\file1.txt" 932 65001
