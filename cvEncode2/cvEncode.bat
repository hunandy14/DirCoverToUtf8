:: ファイル
pwsh -Command "& {.\cvEncode.ps1 Shift-JIS utf8 dir\Shift-JIS.txt Output.txt}"
:: フォルダ
:: pwsh -Command "& {.\cvEncode.ps1 Shift-JIS utf8 dir Output -Filter *.txt}"
:: フォルダ（フィルター付け）
:: pwsh -Command "& {.\cvEncode.ps1 Shift-JIS utf8 dir Output -Filter @('*.txt', '*.md')}"