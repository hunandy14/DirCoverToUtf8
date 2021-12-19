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
function __main__ {
    ############### Shift-JIS　-＞　UTF8 ###############
    $cvEnc = [cvEncode]::new('Shift-JIS', 'UTF8')
    $cvEnc.convert("JIS_File\A.txt")
    # $cvEnc.convert("JIS_File\B.md", "Output\convertTest2.md")
    ############### UTF8　-＞　Shift-JIS ###############
    $cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
    $cvEnc.convertDir("UTF8_File")
    # $cvEnc.convertDir("UTF8_File", "Output")
} 
# __main__
# ==============================================================================
