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

function CopyFiles {
    param (
        [String] $FilePath,
        [String] $TempPath
    )
    $ExcludeFile = "*.java"

    # 獲取直接複製的檔案
    $listCopy = Get-ChildItem -Path $FilePath -Recurse -Exclude $ExcludeFile -File
    # 獲取直接複製的檔案相對路徑
    $listCopyN = Get-ChildItem -Path $FilePath -Recurse -Exclude $ExcludeFile -File  -Name

    for ($i = 0; $i -lt $listCopy.Count; $i++) {
        $F1=$FilePath+"\"+$listCopyN[$i]
        $F2=$TempPath+"\"+$listCopyN[$i]
        $DirFullName=$listCopy.DirectoryName
        $DirName=$listCopy.Directory.Name

        $F1
        $F2
        # $DirFullName
    }

}

# 轉換FilePath目錄下的所有java檔案，到TempPath目錄
function CovertDirEncoding($FilePath, $TempPath, $go=0) {
    $copyOtherFile=1
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


    if ($copyOtherFile) {
        CopyFiles $FilePath $TempPath
    }
}

# 路徑
$FilePath = "Z:\SourceCode\28\mystruts"
$TempPath = $PSScriptRoot
cd $PSScriptRoot
CovertDirEncoding $FilePath $TempPath 1
