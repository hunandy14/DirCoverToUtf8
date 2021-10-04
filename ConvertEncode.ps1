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
    [System.Object]getFoldList($srcFold) {
        $fileItem =  dir $srcFold.TrimEnd('\') -R -I $this.Filter
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
        $this.convert($srcFile, ("Output\"+$dstFile))
    }
    # フォルダのエンコードの変換
    [Void]convertDir($srcFold, $dstFold){
        $fileItem = $this.getFoldList($srcFold)
        $srcFold = $srcFold.TrimEnd('\')
        $dirName = $srcFold.Substring($srcFold.LastIndexof("\")+1)
        Write-Warning ("Convert Files:: [" +$this.srcEncode+ " --> " +$this.dstEncode+ "]")
        for ($i = 0; $i -lt $fileItem.Count; $i++) {
            $F1=$fileItem[$i].FullName
            $F2=$dstFold.TrimEnd('\')+"\"+$dirName+"\"+$fileItem[$i].Name
            Write-Warning "  From: $F1"
            Write-Warning "  └─To: $F2"
            $this.convert($F1, $F2)
        }
    }
    [Void]convertDir($srcFold){
        $this.convertDir($srcFold, ("Output"))
    }
}
# ==============================================================================
# プログラム開始
# ==============================================================================
# Shift-JIS　-＞　UTF8
$cvEnc = [cvEncode]::new('Shift-JIS', 'UTF8')
$cvEnc.convert("JIS_File\A.txt")
# $cvEnc.convert("JIS_File\B.md", "$PSScriptRoot\Output\convertTest2.md")
# UTF8　-＞　Shift-JIS
$cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
$cvEnc.convertDir("UTF8_File")
# $cvEnc.convertDir("UTF8_File", "$PSScriptRoot\Output")
# ==============================================================================
