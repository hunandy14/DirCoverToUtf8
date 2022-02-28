檔案編碼轉換器
===

懶人包封裝後的 API

- 預設讀取編碼是系統語言，輸出編碼是UTF8
- 第一個編碼是檔案來源，第二個編碼是輸出

``` ps1
# 載入函式
irm bit.ly/3pkjAtp|iex; 

# 轉換檔案
$path1 = "Z:\Work_Hita\doc_1130\source_after\js\DMWA0010.js"
$path2 = "Z:\cvEncoding\DMWA0010.js"
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932

# 轉換目錄
$path1 = "Z:\Work_Hita\doc_1130\source_after\js"
$path2 = "Z:\cvEncoding"
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 950

# 輸出時順便去除結尾空白與結尾多餘換行
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 -TrimFile
# 僅輸出js與css檔案
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 -Filter:@("*.css", "*.js")
```
