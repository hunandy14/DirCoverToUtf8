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

```ps1
# 日文::Shift-JIS (932)
[Text.Encoding]::GetEncoding('Shift-JIS')
# 簡體中文::GB2312 (936)
[Text.Encoding]::GetEncoding('GB2312')
# 繁體中文::BIG5 (950)
[Text.Encoding]::GetEncoding('BIG5')
# 萬國碼::UTF8 (65001)
[Text.Encoding]::GetEncoding('UTF-8')

# 萬國碼::UTF8-BOM (65001)
(New-Object System.Text.UTF8Encoding $True)
# 萬國碼::UTF8-NonBOM (65001)
(New-Object System.Text.UTF8Encoding $False)

# 當前系統編碼
PowerShell -Nop "& {return [Text.Encoding]::Default}"
# 當前 PowerShell 編碼
[Text.Encoding]::Default
```

## API 使用範例

``` ps1
# 載入函式
irm bit.ly/cvEncoding|iex; 

# 設定目錄
$path1 = ".\enc\932"
$path2 = ".\out"
$file1 = ".\enc\932\kyouto.txt"
$file2 = ".\out.txt"

# 轉換檔案 932 -> UTF8
irm bit.ly/cvEncoding|iex;cvEnc $file1 $file2 932
# 轉換檔案 932 -> big5
irm bit.ly/cvEncoding|iex;cvEnc $file1 $file2 932 950

# 轉換目錄 932 -> UTF8
irm bit.ly/cvEncoding|iex;cvEnc $path1 $path2 932
# 轉換目錄 932 -> big5
irm bit.ly/cvEncoding|iex;cvEnc $path1 $path2 932 950

# 輸出時消除行末空白與結尾多餘換行
irm bit.ly/cvEncoding|iex;cvEnc $path1 $path2 932 -TrimFile
# 僅輸出txt與md檔案
irm bit.ly/cvEncoding|iex;cvEnc $path1 $path2 932 -Filter:@("*.txt", "*.md")

```

cmd用法

```bat
SET path1=".\enc\932"
SET path2=".\out"
powershell -c "irm bit.ly/cvEncoding|iex; cvEnc %path1% %path2% 932"

```

## API 使用範例2
載入函式
```ps1
irm bit.ly/cvEncoding|iex; 
```

ReadContent
```ps1
# 讀取檔案 (系統編碼)
ReadContent "enc\Encoding_UTF8.txt"
# 讀取檔案 (UTF8)
ReadContent "enc\Encoding_UTF8.txt" UTF8
# 讀取檔案 (依照PowerShell編碼)
ReadContent "enc\Encoding_UTF8.txt" -Encoding default
```

WriteContent
```ps1
# 輸出到檔案 (依照作業系統編碼)
"中文BIG5"|WriteContent "out\Out.txt"
# 追加到檔案
"中文BIG5"|WriteContent "out\Out.txt" -Append
# 輸出到檔案 (依照PowerShell編碼)
"中文BIG5"|WriteContent "out\Out.txt" -Encoding default
# 輸出到檔案 (UTF-8 無 BOM)
"中文BIG5"|WriteContent "out\Out.txt" UTF8
# 輸出到檔案 (UTF-8 有 BOM)
"中文BIG5"|WriteContent "out\Out.txt" UTF8BOM
"中文BIG5"|WriteContent "out\Out.txt" utf-8
"中文BIG5"|WriteContent "out\Out.txt" 65001
```
