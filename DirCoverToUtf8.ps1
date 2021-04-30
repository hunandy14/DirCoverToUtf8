function CopyFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0,
        [bool] $Overwrite=0
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
    for ($i = 0; $i -lt $ExcludeItem.Count; $i++) {
        $F1=$FilePath+"\"+$ExcludeItem[$i]
        $F2=$TempPath+"\"+$MainDirName+"\"+$ExcludeItem[$i]
        # $Dir2=$F2.Substring(0, $F2.LastIndexOf('\'))
        if ($DontPreview) {      # 複製檔案
            if ((Test-Path -Path $MainDirName) -and (!$Overwrite)) {
                Write-Output "CopyFiles::目錄已經存在，請清除後重新執行"
                return
            } else {
                New-Item -ItemType File -Path $F2 -Force | Out-Null
                Copy-Item $F1 $F2
            }
        } else {                 # 預覽路徑
            Write-Output "CopyFiles::預覽"
            Write-Output "  From: $F1"
            Write-Output "  To  : $F2"
        }
    }
    
}

function CoverFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0,
        [bool] $Overwrite=0
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
    for ($i = 0; $i -lt $ExcludeItem.Count; $i++) {
        $F1=$FilePath+"\"+$ExcludeItem[$i]
        $F2=$TempPath+"\"+$MainDirName+"\"+$ExcludeItem[$i]
        # $Dir2=$F2.Substring(0, $F2.LastIndexOf('\'))
        if ($DontPreview) {      # 轉換檔案
            if ((Test-Path -Path $MainDirName) -and (!$Overwrite)) {
                Write-Output "CoverFiles::目錄已經存在，請清除後重新執行"
                return
            } else {
                New-Item -ItemType File -Path $F2 -Force | Out-Null
                $ct = (Get-Content -Encoding $En1 $F1)
                $ct | Out-File -Encoding $En2 -FilePath $F2
            }
        } else {                 # 預覽路徑
            Write-Output "CoverFiles::預覽 [$En1 --> $En2]"
            Write-Output "  From: $F1"
            Write-Output "  To  : $F2"
        }
    }
    
}

function DirCoverToUtf8 {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0
    )
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 資料夾名稱
    $MainDirName = $FilePath.Substring($FilePath.LastIndexof("\")+1)
    
    # 預覽
    CopyFiles $FilePath $TempPath 1 0
    CoverFiles $FilePath $TempPath 1 0
    # 寫入
    if (Test-Path -Path $MainDirName) {
        Write-Output "資料夾已經存在是否覆蓋？(按下 Y 或 Enter 覆蓋檔案)"
        $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
        
        if(($key.Character -eq "y") -or ($key.VirtualKeyCode -eq 13)){
            Write-Output "轉換完畢"
            # 寫入
            CopyFiles $FilePath $TempPath 1 1
            CoverFiles $FilePath $TempPath 1 1
        } else {
            Write-Output "取消覆蓋 程式即將結束"
            return
        }
    } else {
        # 寫入
        CopyFiles $FilePath $TempPath 1 0
        CoverFiles $FilePath $TempPath 1 0
    }
    
    
}

# 路徑
$FilePath = "Z:\SourceCode\28\mystruts"
$TempPath = $PSScriptRoot
cd $PSScriptRoot

DirCoverToUtf8 $FilePath $TempPath 0