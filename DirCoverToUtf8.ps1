function DirCoverToUtf8_CopyFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [switch] $Preview
    )
    ########################### 控制項目 ###########################
    # 排外檔案
    $ExcludeFile = @("*.java", "*.class", ".classpath", 
        ".mymetadata", ".project", "MANIFEST.MF")
    $ExcludeDir = "\\WebRoot\\WEB-INF\\classes\\|\\.settings\\"
    ###############################################################
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 資料夾名稱
    $MainDirName = $FilePath.Substring($FilePath.LastIndexof("\")+1)
    # 獲取複製項目相對路徑
    $FileItem = ((Get-ChildItem -Recurse `
        -Path $FilePath -Exclude $ExcludeFile -File)`
        -notmatch "$ExcludeDir") | Sort-Object
    ###############################################################
    for ($i = 0; $i -lt $FileItem.Count; $i++) {
        $F1=$FileItem[$i].FullName
        $F2=$TempPath+"\"+$MainDirName+$F1.Substring($FilePath.Length)
        # $Dir2=$F2 | Split-Path
        if ($Preview) {
            Write-Output "CopyFiles::預覽"
            Write-Output "  From: $F1"
            Write-Output "  To  : $F2"
        } else {
            New-Item -ItemType File -Path $F2 -Force | Out-Null
            Copy-Item $F1 $F2
        }
    }
}

function DirCoverToUtf8_CoverFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [switch] $Preview
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
    $FileItem =  Get-ChildItem -Path $FilePath `
                        -Recurse -Include $FilterFile | Sort-Object
    ###############################################################
    for ($i = 0; $i -lt $FileItem.Count; $i++) {
        $F1=$FileItem[$i].FullName
        $F2=$TempPath+"\"+$MainDirName+$F1.Substring($FilePath.Length)
        # $Dir2=$F2 | Split-Path
        if ($Preview) {
            Write-Output "CoverFiles::預覽 [$En1 --> $En2]"
            Write-Output "  From: $F1"
            Write-Output "  To  : $F2"
        } else {
            New-Item -ItemType File -Path $F2 -Force | Out-Null
            $ct = (Get-Content -Encoding $En1 $F1)
            $ct | Out-File -Encoding $En2 -FilePath $F2
        }
    }
}

function DirCoverToUtf8 {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [switch] $Preview,
        [switch] $Force,
        [switch] $NoCopy
    )
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 資料夾名稱
    $MainDirName = $FilePath.Substring($FilePath.LastIndexof("\")+1)
    
    if ($Preview) {
        DirCoverToUtf8_CoverFiles $FilePath $TempPath -Preview
        if (!$NoCopy) { DirCoverToUtf8_CopyFiles $FilePath $TempPath -Preview }
    } else {
        if (!(Test-Path -Path $MainDirName)) {
            # 不衝突直接寫入
        } else {
            if ($Forece) {
                # 有衝突但Forece照樣寫入
            } else {
                DirCoverToUtf8_CoverFiles $FilePath $TempPath -Preview
                if (!$NoCopy) { DirCoverToUtf8_CopyFiles $FilePath $TempPath -Preview }
                
                Write-Output "#######################################################"
                Write-Output "下列資料夾已經存在是否覆蓋？(按下 Y 或 Enter 覆蓋檔案)"
                Write-Output "[$TempPath\$MainDirName]"
                Write-Output "#######################################################"
                $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
                if(($key.Character -eq "y") -or ($key.VirtualKeyCode -eq 13)){
                    # 有衝突但按下Enter確認
                } else {
                    Write-Output "程序中斷::資料夾已存在（下面方式擇一處理）"
                    Write-Output "    - 加上命令 -Force"
                    Write-Output "    - 移除 $MainDirName ] 資料夾"
                    return
                }
            }
        }
        DirCoverToUtf8_CoverFiles $FilePath $TempPath
        if (!$NoCopy) { DirCoverToUtf8_CopyFiles $FilePath $TempPath }
        Write-Output "轉換完畢 $FilePath --> $TempPath\$MainDirName"
    }
}

# 路徑
$FilePath = "Z:\SourceCode\30"
$TempPath = $PSScriptRoot
cd $PSScriptRoot

DirCoverToUtf8 $FilePath $TempPath -Preview
DirCoverToUtf8 $FilePath $TempPath