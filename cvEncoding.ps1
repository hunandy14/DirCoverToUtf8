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
}
# ReadContent "enc\Encoding_SHIFT.txt" 932
# ReadContent "enc\Encoding_UTF8.txt" UTF8
# ReadContent "enc\Encoding_UTF8_0.txt" UTF8
# ReadContent "enc\Encoding_UTF8_1.txt" UTF8

# function WriteContent2 {
#     param (
#         [Parameter(ValueFromPipeline, ParameterSetName = "")]
#         [System.Object] $InputObject
#     )
# }
# $CT = ReadContent "f001.data" 65001 -ShowTimeTaken
# ReadContent "f001.data" 65001 -ShowTimeTaken | WriteContent2




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
    
    
    # process { # 107/200
    #     $StreamWriter.WriteLine($InputObject)
    # }
    
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
    
    # process { #164/290
    #     $line = $InputObject
    #     # $str = "" # BBB
    #     # 清除行尾空白
    #     if ($TrimWhiteSpace) {
    #         $line = $line.TrimEnd()
    #     }
    #     # 追加換行(首行不換)
    #     if(-not $firstLine) {
    #         # $str = $str + $LineTerminator # BBB# AAA
    #         $StreamWriter.Write($LineTerminator) 
    #     } else { $firstLine = $false }
    #     # # 寫入檔案 (遇到非空白行時)
    #     if ($line -notmatch "^\s*$" -or !$ForceOneEndLine) {
    #         if ($emptyLines -gt 0) {
    #             for ($i = 0; $i -lt $emptyLines; $i++) {
    #                 # $str = $str + $LineTerminator # BBB
    #                 $StreamWriter.Write($LineTerminator) # AAA
    #             } $emptyLines = 0
    #         }
    #         # 寫入記憶體緩存
    #         # $StreamWriter.Write($str) # BBB
    #         # $StreamWriter.Write($line) # BBB 平均::174
    #         $StreamWriter.Write($line) # AAA 平均::161
    #     } else {
    #         $emptyLines += 1
    #     }
        
    #     # $StreamWriter.WriteLine($InputObject)
    # }
    
    end {
        if ($ShowTimeTaken) { $stopwatch.Stop() }
        # 保持結尾至少有一行空白
        # if (($AutoAppendEndLine -and ($InputObject -ne $LineTerminator)) -or ($emptyLines -gt 0)) {
        #     $StreamWriter.Write($LineTerminator)
        # }
        
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
# @("1行空格測試`r`n")|WriteContent "out\Out12.txt" -UTF8BOM
# @("2行空格測試", "", "")|WriteContent "out\Out13.txt" -UTF8BOM
# @("2行空格測試", "`r`n")|WriteContent "out\Out13.txt" -UTF8BOM -ShowTimeTaken

# @"
# 2行空格測試


# 123



# 33
# "@ | WriteContent "out\Out13.txt" -UTF8BOM
## 組合測試 230
# $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# ReadContent "f001.data" 65001 | WriteContent "R:\file1.data" -UTF8
# $stopwatch.Stop()
# $time = $stopwatch.Elapsed.TotalSeconds*1000
# Write-Host "Elapsed time: $time milliseconds"

# 跑分測試
# $ct = ReadContent "f001.data" 65001 -ShowTimeTaken
# $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $tt = 0
# $cc = 20
# for ($i = 0; $i -lt $cc; $i++) {
#     $ct|WriteContent "R:\file1.data" -UTF8 -ShowTimeTaken
#     $tt += $time
# } 
# Write-Host "平均:" $($tt/$cc)

# 空行缺失測試
# $CT = ReadContent "enc\Encoding_UTF8.txt" 65001 -ShowTimeTaken
# $CT | WriteContent "R:\Out21.txt" -UTF8 

# ReadContent "enc\Encoding_UTF8.txt" 65001 | WriteContent "out\Out21.txt" -UTF8 -AutoAppendEndLine
# Write-Host "Time for WriteContent writing: $($stopwatch.Elapsed.TotalSeconds*1000)m seconds"





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
            $StreamReader = New-Object System.IO.StreamReader($F1, [Text.Encoding]::GetEncoding($srcEnc))
            $StreamWriter = New-Object System.IO.StreamWriter($F2, $false, [Text.Encoding]::GetEncoding($dstEnc))
            $LineTerminator = if ($LF) { "`n" } else { "`r`n" }
            $emptyLines = 0
            while ($null -ne ($line = $StreamReader.ReadLine())) {
                # 清除行尾空白
                if ($TrimFile) { $line = $line.TrimEnd() }
                # 寫入檔案 (遇到非空白行時)
                if ($line) {
                    $StreamWriter.Write($LineTerminator*$emptyLines)
                    $StreamWriter.Write($line); $emptyLines = 0
                }
                $emptyLines += 1
            }
            # 補償結尾換行
            $StreamReader.BaseStream.Position -= 1
            if ([char]$StreamReader.Read() -eq "`n") { $emptyLines += 1 }
            # 輸出剩餘的換行 
            $emptyLines -= 1
            if ($ForceOneEndLine -or ($EnsureOneEndLine -and $emptyLines -eq 0)) { $emptyLines = 1 }
            $StreamWriter.Write($LineTerminator*$emptyLines); $emptyLines = 0
            # 關閉檔案
            $StreamReader.Close()
            $StreamWriter.Close()
            
            # 測試用呼叫單獨函式
            # ReadContent $F1 $srcEnc | WriteContent $F2 $dstEnc -TrimWhiteSpace:$TrimFile -ForceOneEndLine:$TrimFile -ShowTimeTaken
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
                $StreamReader = New-Object System.IO.StreamReader($F1, [Text.Encoding]::GetEncoding($srcEnc))
                $StreamWriter = New-Object System.IO.StreamWriter($F2, $false, [Text.Encoding]::GetEncoding($dstEnc))
                $LineTerminator = if ($LF) { "`n" } else { "`r`n" }
                $emptyLines = 0
                while ($null -ne ($line = $StreamReader.ReadLine())) {
                    # 清除行尾空白
                    if ($TrimFile) { $line = $line.TrimEnd() }
                    # 寫入檔案 (遇到非空白行時)
                    if ($line) {
                        $StreamWriter.Write($LineTerminator*$emptyLines)
                        $StreamWriter.Write($line); $emptyLines = 0
                    }
                    $emptyLines += 1
                }
                # 補償結尾換行
                $StreamReader.BaseStream.Position -= 1
                if ([char]$StreamReader.Read() -eq "`n") { $emptyLines += 1 }
                # 輸出剩餘的換行 
                $emptyLines -= 1
                if ($ForceOneEndLine -or ($EnsureOneEndLine -and $emptyLines -eq 0)) { $emptyLines = 1 }
                $StreamWriter.Write($LineTerminator*$emptyLines); $emptyLines = 0
                # 關閉檔案
                $StreamReader.Close()
                $StreamWriter.Close()
                
                # 測試用呼叫單獨函式
                # ReadContent $F1 $srcEnc | WriteContent $F2 $dstEnc -TrimWhiteSpace:$TrimFile -ForceOneEndLine:$TrimFile -ShowTimeTaken
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
    
    # $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    # cvEnc "f001.data" "R:\file1.data" 65001 65001
    # # cvEnc "enc\Encoding_UTF8.txt" "R:\file1.data" 65001 65001 -BufferedWrite
    # $stopwatch.Stop()
    
    # Write-Host "Time for buffered2 writing: $($stopwatch.Elapsed.TotalSeconds*1000)m seconds"     # ReadToEnd
# } __Test_cvEnc__
