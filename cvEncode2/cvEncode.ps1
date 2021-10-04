[CmdletBinding()]
Param(
    [String]$srcEnc,
    [String]$dstEnc,
    [String]$srcPath,
    [String]$dstPath, 
    [String]$Filter
)
# =========================
class cvEncode {
    [string]$srcEnc
    [string]$dstEnc
    [System.Object]$Filter = @("*.*", "*.*")
    # Constructor
    cvEncode($srcEnc, $dstEnc){
        $this.srcEnc=$srcEnc
        $this.dstEnc=$dstEnc
    }
    cvEncode($srcEnc, $dstEnc, $Filter){
        $this.srcEnc=$srcEnc
        $this.dstEnc=$dstEnc
        $this.Filter=$Filter
    }
    # フォルダのリストを獲得
    [System.Object]getFoldList($srcPath) {
        return (dir $srcPath.TrimEnd('\') -R -I $this.Filter)
    }
    # ファイルのエンコードの変換
    [Void]convert($srcPath, $dstPath) {
        New-Item -ItemType File -Path $dstPath -Force | Out-Null
        $ct = Get-Content -Encoding $this.srcEnc $srcPath
        $ct | Out-File -Encoding $this.dstEnc -FilePath $dstPath
    }
    [Void]convert($srcPath) {
        $dstPath = $srcPath.Substring($srcPath.LastIndexOf("\"))
        $this.convert($srcPath, ("Output\"+$dstPath))
    }
    # フォルダのエンコードの変換
    [Void]convertDir($srcPath, $dstPath){
        $fileItem = $this.getFoldList($srcPath)
        $srcPath = $srcPath.TrimEnd('\')
        $dirName = $srcPath.Substring($srcPath.LastIndexof("\")+1)
        Write-Warning ("Convert Files:: [" +$this.srcEnc+ " --> " +$this.dstEnc+ "]")
        for ($i = 0; $i -lt $fileItem.Count; $i++) {
            $F1=$fileItem[$i].FullName
            $F2=$dstPath.TrimEnd('\')+"\"+$dirName+"\"+$fileItem[$i].Name
            Write-Warning "  From: $F1"
            Write-Warning "  └─To: $F2"
            $this.convert($F1, $F2)
        }
    }
    [Void]convertDir($srcPath){
        $this.convertDir($srcPath, "Output")
    }
}
# ==============================================================================
# プログラム開始
# ==============================================================================
# .\cvEncode.ps1 Shift-JIS utf8 dir\Shift-JIS.txt utf8.txt
$srcEnc = 'Shift-JIS'
$dstEnc = 'utf8'
$srcPath = 'dir\Shift-JIS.txt'
$srcPath = 'dir'
$dstPath = 'utf8.txt'
$dstPath = 'Output'
if ([System.IO.Directory]::Exists($srcPath)) {
    "dir Go"
    [cvEncode]::new($srcEnc, $dstEnc, @("*.*")).convertDir($srcPath, $dstPath)
}if ([system.IO.File]::Exists($srcPath)) {
    "File Go"
    [cvEncode]::new($srcEnc, $dstEnc).convert($srcPath, $dstPath)
}
# ==============================================================================

