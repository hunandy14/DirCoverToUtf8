class CoverEncode {
    [string]$srcEncode
    [string]$dstEncode
    [System.Object]$Filter = @("*.*", "*.*")
    # Constructor
    CoverEncode($srcEncode, $dstEncode){
        $this.srcEncode=$srcEncode
        $this.dstEncode=$dstEncode
    }
    CoverEncode($srcEncode, $dstEncode, $Filter){
        $this.srcEncode=$srcEncode
        $this.dstEncode=$dstEncode
        $this.Filter=$Filter
    }
    # フォルダのリストを獲得
    [System.Object]getFoldList($srcFold, $dstFold) {
        $FileItem =  Get-ChildItem -Path $srcFold.TrimEnd('\') `
                        -Recurse -Include $this.Filter | Sort-Object
        return $FileItem
    }
    # ファイルのエンコードの変換
    [Void]EncodChange($srcFile, $dstFile) {
        New-Item -ItemType File -Path $dstFile -Force | Out-Null
        $ct = Get-Content -Encoding $this.srcEncode $srcFile
        $ct | Out-File -Encoding $this.dstEncode -FilePath $dstFile
    }
    # フォルダのエンコードの変換
    [Void]EncodChangeDir($srcFold, $dstFold){
        $FileItem = $this.getFoldList($srcFold, $dstFold)
        $srcFold = $srcFold.TrimEnd('\')
        $MainDirName = $srcFold.Substring($srcFold.LastIndexof("\")+1)
        Write-Warning ("CoverFiles:: [" +$this.srcEncode+ " --> " +$this.dstEncode+ "]")
        for ($i = 0; $i -lt $FileItem.Count; $i++) {
            $F1=$FileItem[$i].FullName
            $F2=$dstFold.TrimEnd('\')+"\"+$MainDirName+$F1.Substring($srcFold.Length)
            Write-Warning "  From: $F1"
            Write-Warning "  To  : $F2"
            $this.EncodChange($F1, $F2)
        }
    }
    [Void]EncodChangeDir($srcFold){
        $this.EncodChangeDir($srcFold, ("$PSScriptRoot\Output\" + $this.dstEncode))
    }
}
# ==============================================================================
# プログラム開始
# ==============================================================================
# Shift-JIS　-＞　UTF8
$conver = [CoverEncode]::new('Shift-JIS', 'UTF8')
$conver.EncodChangeDir("$PSScriptRoot\JIS_File")
# UTF8　-＞　Shift-JIS
$conver = [CoverEncode]::new('UTF8', 'Shift-JIS', @("*.txt"))
$conver.EncodChangeDir("$PSScriptRoot\UTF8_File")
# ==============================================================================
