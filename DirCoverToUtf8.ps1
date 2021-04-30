function CopyFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0
    )
    ########################### 控制項目 ###########################
    # 排外檔案
    $ExcludeFile = @("*.java", "*.class")
    ###############################################################
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 資料夾名稱
    $MainDirName = $FilePath.Substring($FilePath.LastIndexof("\")+1)
    # 獲取複製項目相對路徑
    $ExcludeItem = Get-ChildItem -Path $FilePath `
                        -Recurse -Exclude $ExcludeFile -File -Name | Sort-Object
    ###############################################################
    if (Test-Path -Path $MainDirName) {
        Write-Output "目錄已經存在，請清除後重新執行"
        return
    }
    for ($i = 0; $i -lt $ExcludeItem.Count; $i++) {
        $F1=$FilePath+"\"+$ExcludeItem[$i]
        $F2=$TempPath+"\"+$MainDirName+"\"+$ExcludeItem[$i]
        # $Dir2=$F2.Substring(0, $F2.LastIndexOf('\'))
        if ($DontPreview) {      # 複製檔案
            New-Item -ItemType File -Path $F2 -Force | Out-Null
            Copy-Item $F1 $F2
        } else {                 # 預覽路徑
            Write-Output "From: $F1"
            Write-Output "To  : $F2"
            Write-Output ""
        }
    }
    
}

function CoverFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0
    )

    ########################### 控制項目 ###########################
    # 原始檔案編碼
    $En1 = "GBK"
    # 目標檔案編碼
    $En2 = "UTF8"
    # 轉換檔案
    $FilterFile = @("*.java")
    ###############################################################
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 資料夾名稱
    $MainDirName = $FilePath.Substring($FilePath.LastIndexof("\")+1)
    # 獲取複製項目相對路徑
    $ExcludeItem =  Get-ChildItem -Path $FilePath `
                        -Recurse -Include $FilterFile -Name | Sort-Object
    ###############################################################
    if (Test-Path -Path $MainDirName) {
        Write-Output "資料夾已經存在是否覆蓋？(按下 Y 或是 Enter 覆蓋檔案)"
        $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
        $key
        if($key.Character -eq "y"){
            Write-Output "複寫檔案"
        } else {
            Write-Output "取消覆蓋 程式即將結束"
            return
        }
    }
    for ($i = 0; $i -lt $ExcludeItem.Count; $i++) {
        $F1=$FilePath+"\"+$ExcludeItem[$i]
        $F2=$TempPath+"\"+$MainDirName+"\"+$ExcludeItem[$i]
        # $Dir2=$F2.Substring(0, $F2.LastIndexOf('\'))
        if ($DontPreview) {      # 轉換檔案
            New-Item -ItemType File -Path $F2 -Force | Out-Null
            $ct = (Get-Content -Encoding $En1 $F1)
            $ct | Out-File -Encoding $En2 -FilePath $F2
        } else {                 # 預覽路徑
            Write-Output "From: $F1"
            Write-Output "To  : $F2"
            Write-Output ""
        }
    }
    
}

function DirCoverToUtf8 {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0
    )
    
}

# 路徑
$FilePath = "Z:\SourceCode\28\mystruts"
$TempPath = $PSScriptRoot
cd $PSScriptRoot

# CopyFiles $FilePath $TempPath 0
CoverFiles $FilePath $TempPath 0