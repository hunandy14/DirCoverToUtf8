[CmdletBinding()]
Param(
    $srcEnc,
    $dstEnc,
    $srcFile,
    $dstFile
)
# =========================
class cvEncode {
    [string]$srcEncode
    [string]$dstEncode
    [System.Object]$Filter = @("*.*", "*.*")
    # Constructor
    cvEncode($srcEncode, $dstEncode){
        $this.srcEncode=$srcEncode
        $this.dstEncode=$dstEncode
    }
    cvEncode($srcEncode, $dstEncode, $Filter){
        $this.srcEncode=$srcEncode
        $this.dstEncode=$dstEncode
        $this.Filter=$Filter
    }
    # フォルダのリストを獲得
    [System.Object]getFoldList($srcFold, $dstFold) {
        $fileItem =  Get-ChildItem -Path $srcFold.TrimEnd('\') `
                        -Recurse -Include $this.Filter | Sort-Object
        return $fileItem
    }
    # ファイルのエンコードの変換
    [Void]convert($srcFile, $dstFile) {
        New-Item -ItemType File -Path $dstFile -Force | Out-Null
        $ct = Get-Content -Encoding $this.srcEncode $srcFile
        $ct | Out-File -Encoding $this.dstEncode -FilePath $dstFile
    }
    [Void]convert($srcFile) {
        $dstFile = $srcFile.Substring($srcFile.LastIndexOf("\"))
        $this.convert($srcFile, ("$PSScriptRoot\Output\"+$dstFile))
    }
    # フォルダのエンコードの変換
    [Void]convertDir($srcFold, $dstFold){
        $fileItem = $this.getFoldList($srcFold, $dstFold)
        $srcFold = $srcFold.TrimEnd('\')
        $dirName = $srcFold.Substring($srcFold.LastIndexof("\")+1)
        Write-Warning ("Convert Files:: [" +$this.srcEncode+ " --> " +$this.dstEncode+ "]")
        for ($i = 0; $i -lt $fileItem.Count; $i++) {
            $F1=$fileItem[$i].FullName
            $F2=$dstFold.TrimEnd('\')+"\"+$dirName+$F1.Substring($srcFold.Length)
            Write-Warning "  From: $F1"
            Write-Warning "  └─To: $F2"
            $this.convert($F1, $F2)
        }
    }
    [Void]convertDir($srcFold){
        $this.convertDir($srcFold, ("$PSScriptRoot\Output\" + $this.dstEncode))
    }
}
# ==============================================================================
# プログラム開始
# ==============================================================================
if ([System.IO.Directory]::Exists($srcFile)) {
    $cvEnc = [cvEncode]::new($srcEnc, $dstEnc, @("*.*"))
    $cvEnc.convertDir($srcFile, $dstFile)
}if ([system.IO.File]::Exists($srcFile)) {
    $cvEnc = [cvEncode]::new($srcEnc, $dstEnc)
    $cvEnc.convert($srcFile, $dstFile)
}
# ==============================================================================

