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
    # ファイルのエンコードの変換
    [Void]convert($srcFile, $dstFile) {
        New-Item -ItemType File -Path $dstFile -Force | Out-Null
        $ct = Get-Content -Encoding $this.srcEnc $srcFile
        $ct | Out-File -Encoding $this.dstEnc -FilePath $dstFile
    }
    [Void]convert($srcFile) {
        if ($PSScriptRoot) { $curDir = $PSScriptRoot } else { $curDir = (Get-Location).Path }
        $FileName = (Get-Item $srcFile).Name
        $this.convert($srcFile, ("cvEncode_OUT\"+$FileName))
    }
    # フォルダのエンコードの変換
    [Void]convertDir($srcPath, $dstPath){
        if ($PSScriptRoot) { $curDir = $PSScriptRoot } else { $curDir = (Get-Location).Path }
        $srcPath = (Resolve-Path $srcPath).Path
        $dstPath.TrimEnd('\') -replace("\/", "\")
        Set-Location $srcPath
        $collection = Get-ChildItem $srcPath -R -I $this.Filter
        Write-Host ("Convert Files:: [" +$this.srcEnc+ " --> " +$this.dstEnc+ "]")
        
        foreach ($item in $collection) {
            $F1=$item.FullName
            $Relative = ($F1 | Resolve-Path -Relative) -replace("\.\\", "")
            $F2=$dstPath.TrimEnd('\') + "\$Relative"
            Write-Host "  From: " -NoNewline
            Write-Host "$Relative" -ForegroundColor:White
            Write-Host "  └─To: " -NoNewline
            Write-Host "$F2" -ForegroundColor:Yellow
            $this.convert($F1, $F2)
        }
        Set-Location $curDir
    }
    [Void]convertDir($srcPath){
        $this.convertDir($srcPath, "cvEncode_OUT")
    }
}
# ==============================================================================
# プログラム開始
# ==============================================================================
function __main__ {
    ############### Shift-JIS　-＞　UTF8 ###############
    # $cvEnc = [cvEncode]::new('Shift-JIS', 'UTF8')
    # $cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS')
    # $cvEnc.convert("DirCoverToUtf8.ps1")
    ############### UTF8　-＞　Shift-JIS ###############
    # $cvEnc = [cvEncode]::new('UTF8', 'Shift-JIS', @("*.*"))
    $cvEnc = [cvEncode]::new('Shift-JIS', 'UTF8', @("*.*"))
    $srcDir = "Z:\Work\doc_1130\source_before"
    $dstDir = "Z:\Work\cvEncode\doc_1130"
    $cvEnc.convertDir($srcDir, $dstDir)
} 
# __main__
# ==============================================================================
