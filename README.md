PowerShell 檔案編碼轉換器
===

## API使用說明
- @param 1 : 輸入路徑(自動判別目錄或檔案)
- @param 2 : 輸出路徑(自動判別目錄或檔案)
- @param 3 : 輸入檔案編碼代號(省略則為當前系統編碼)
- @param 4 : 輸出檔案編碼代號(省略則為UTF8編碼)

- @param -TrimFile : 消除行末空白與結尾多餘換行
- @param -Filter   : 僅轉換特定副檔名的檔案

### 查詢編碼代號

```sh
# 查詢 GB2312 的編碼 (936)
[Text.Encoding]::GetEncoding('GB2312')
# 查詢 UTF8 的編碼 (65001)
[Text.Encoding]::GetEncoding('UTF-8')
# 查詢 本機 編碼
PowerShell -C "& {return [Text.Encoding]::Default}"
# 查詢 Pwsh 當前編碼
[Text.Encoding]::Default
```

## API 使用範例

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

## API 使用範例2
ReadContent
```ps1
# 載入函式
irm bit.ly/3pkjAtp|iex; 

# 讀取檔案
ReadContent "enc\Encoding_UTF8.txt"
ReadContent "enc\Encoding_BIG5.txt" 950
```

WriteContent
```ps1
# 載入函式
irm bit.ly/3pkjAtp|iex; 

# 輸出到檔案 (依照PowerShell編碼)
"中文BIG5"|WriteContent "Out_BIG5.txt"
# 輸出到檔案 (依照作業系統編碼)
"中文BIG5"|WriteContent "Out_BIG5.txt" -SystemEncoding
# 追加到檔案 (BIG5)
"中文BIG5"|WriteContent "Out_BIG5.txt" 65001 -Append

# 輸出到檔案 (UTF-8 無 BOM)
"中文BIG5"|WriteContent "Out_BIG5.txt" 65001
# 輸出到檔案 (UTF-8 有 BOM)
"中文BIG5"|WriteContent "Out_BIG5.txt" 65001 -BOM_UTF8
```
