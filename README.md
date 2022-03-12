PowerShell 檔案編碼轉換器
===

### API使用說明
- @param 1 : 輸入路徑(自動判別目錄或檔案)
- @param 2 : 輸出路徑(自動判別目錄或檔案)
- @param 3 : 輸入檔案編碼代號(省略則為當前系統編碼)
- @param 4 : 輸出檔案編碼代號(省略則為UTF8編碼)

- @param -TrimFile : 消除行末空白與結尾多餘換行
- @param -Filter   : 僅轉換特定副檔名的檔案

#### 查詢編碼代號

```sh
[Text.Encoding]::GetEncoding('GB2312')
```

### API 使用範例

``` ps1
# 載入函式
irm bit.ly/3pkjAtp|iex; 

# 設定目錄
$path1 = ".\enc\932"
$path2 = ".\out"
$file1 = ".\enc\932\kyouto.txt"
$file2 = ".\out.txt"

# 轉換檔案 932 -> UTF8
irm bit.ly/3pkjAtp|iex;cvEnc $file1 $file2 932
# 轉換檔案 932 -> big5
irm bit.ly/3pkjAtp|iex;cvEnc $file1 $file2 932 950

# 轉換目錄 932 -> UTF8
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932
# 轉換目錄 932 -> big5
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 950

# 輸出時消除行末空白與結尾多餘換行
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 -TrimFile
# 僅輸出txt與md檔案
irm bit.ly/3pkjAtp|iex;cvEnc $path1 $path2 932 -Filter:@("*.txt", "*.md")

```

cmd用法

```bat
SET path1=".\enc\932"
SET path2=".\out"
powershell -c "irm bit.ly/3pkjAtp|iex; cvEnc %path1% %path2% 932"

```
