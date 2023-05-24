function __Test_cvEnc__ {
    # 轉換相對路徑資料測試
    $path1 = ".\enc\932"
    $path2 = ".\out"
    cvEnc $path1 $path2 932
    cvEnc $path1 $path2 932 -TrimFile
    # 轉換相對路徑檔案測試
    cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932
    cvEnc ".\enc\Trim.txt" ".\out.txt" -TrimFile
    
    # 轉換絕對路徑資料夾測試
    $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932"
    $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out"
    cvEnc $path1 $path2 932
    cvEnc $path1 $path2 932 -TrimFile
    # 轉換絕對路徑檔案測試
    $path1 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\enc\932\Trim.txt"
    $path2 = "C:\Users\hunan\OneDrive\Git Repository\pwshApp\cvEncode\out.txt"
    cvEnc $path1 $path2 932
    cvEnc $path1 $path2 932 -TrimFile
    
    # 空路徑自動指定到暫存目錄
    cvEnc ".\enc\932\kyouto.txt" 932 -Temp
    cvEnc ".\enc\932\kyouto.txt" 932 65001
    cvEnc ".\enc\932\kyouto.txt" ".\out.txt" 932 65001
    cvEnc ".\enc\932" 932 65001
    
    # 預選編碼測試
    cvEnc "enc\Encoding_UTF8.txt" -ConvertToUTF8 -Temp
    cvEnc "enc\Encoding_BIG5.txt" -ConvertToSystem -Temp
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    # cvEnc "f001.data" "R:\file1.data" 65001 65001                                                 # 250
    cvEnc "enc\Encoding_UTF8.txt" "R:\file1.data" 65001 65001
    $stopwatch.Stop()
    Write-Host "Time for buffered2 writing: $($stopwatch.Elapsed.TotalSeconds*1000)m seconds"     # ReadToEnd
} __Test_cvEnc__