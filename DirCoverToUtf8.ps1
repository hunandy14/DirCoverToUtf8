# 輸入 來源檔案全名, 格式, 目標檔案全名, 格式
function  CovertFileEncoding_basic ($F1, $En1, $En2, $F2){
    $ct = (Get-Content -Encoding $En1 $F1)
    $ct | Out-File -Encoding $En2 -FilePath $F2
}

# F2=檔案相對路徑, $tempPath=相對路徑前的路徑
function  CovertFileEncoding ($F1, $En1, $En2, $F2, $tempPath){
    $F2=$tempPath+"\"+$F2
    mkdir $F2 | Out-Null
    Remove-Item $F2
    # New-Item -ItemType File -Path $destination -Force
    CovertFileEncoding_basic $F1 $En1 $En2 $F2
}

function FixFilePath($Path){
    
}
function CopyFiles {
    param (
        [String] $FilePath,
        [String] $TempPath,
        [bool] $DontPreview=0
    )
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    ########################### 控制項目 ###########################
    # 排外檔案
    $ExcludeFile = @("*.java", "*.class")
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
        $Dir2=$F2.Substring(0, $F2.LastIndexOf('\'))
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

# 轉換FilePath目錄下的所有java檔案，到TempPath目錄
function CovertDirEncoding($FilePath, $TempPath, $go=0) {
    $copyOtherFile=1
    # 修復路徑
    $FilePath = $FilePath.TrimEnd('\')
    $TempPath = $TempPath.TrimEnd('\')
    # 暫存資料夾
    $dirName = "utf8File"
    $srcEncoding = "GBK"
    $dstEncoding = "UTF8"
    #====================================================
    $TempPath = $TempPath+"\"+$dirName
    
    # 資料夾不存在
    if (!(Test-Path -Path $TempPath)) {
        # mkdir $dirName  | Out-Null
    }  else {
        Write-Output "資料夾已經存在，請清除後重新執行"
        return
    }
    # 獲取絕對路徑
    $list = Get-ChildItem -Path $FilePath -Recurse -Filter *.java
    # 獲取相對路徑
    $listN = Get-ChildItem -Path $FilePath -Recurse -Filter *.java -Name
    # 轉檔
    for ($i = 0; $i -lt $list.Count; $i++) {
        $F1=$list[$i].FullName
        $F2=$listN[$i]
        if ($go -eq 0) {
            $F2
            $TempPath+"\"+$F2
            ' '
        } elseif ($go -eq 1){
            # CovertFileEncoding $F1 $srcEncoding $dstEncoding $F2 $TempPath
        }
    }

    
}

# 路徑
$FilePath = "Z:\SourceCode\28\mystruts"
$TempPath = $PSScriptRoot
cd $PSScriptRoot
# CovertDirEncoding $FilePath $TempPath 1

CopyFiles $FilePath $TempPath 1