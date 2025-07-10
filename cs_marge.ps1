# -------------------- 設定 --------------------
# 1. 結果を保存する親フォルダを指定します
$outputBaseDirectory = "C:\Users\USER\Documents\MergedOutput"

# 2. 処理対象のフォルダパスを複数指定します
$targetPaths = @(
    "C:\Users\USER\source\repos\IN4A.DataAccess\IN4A.DataAccess.Core",
    "C:\Users\USER\source\repos\IN4A.DataAccess\IN4A.DataAccess.Dapper",
    "C:\Users\USER\source\repos\AmaneQuest\AmaneQuest.Core",
    "C:\Users\USER\source\repos\AmaneQuest\AmaneQuest.Infrastructure",
    "C:\Users\USER\source\repos\AmaneQuest\AmaneQuest.Business"
) 

# 3. マージしたいファイルの拡張子を指定します
$extension = "cs"


# -------------------- スクリプト本体 --------------------

# 1. 日時ベースの出力先フォルダを作成
$timestampFolder = Get-Date -Format "yyyyMMdd-HHmmss"
$finalOutputDir = Join-Path -Path $outputBaseDirectory -ChildPath $timestampFolder
New-Item -Path $finalOutputDir -ItemType Directory -Force | Out-Null

# 2. ログ出力を開始
$logFilePath = Join-Path -Path $finalOutputDir -ChildPath "execution_log.txt"
Start-Transcript -Path $logFilePath -Force

Write-Host "結果は以下のフォルダに保存されます:"
Write-Host "   $finalOutputDir"

# 3. 指定された各ソースフォルダに対してループ処理
foreach ($path in $targetPaths) {
    Write-Host "--------------------------------------------------"
    Write-Host "処理中のフォルダ: $path"

    # フォルダが存在するかチェック
    if (-not (Test-Path -Path $path -PathType Container)) {
        Write-Warning "フォルダが見つかりません。スキップします: $path"
        continue
    }

    # 対象ファイルを再帰的に検索
    $filesToMerge = Get-ChildItem -Path $path -Recurse -Filter "*.$($extension)"

    # マージ対象のファイルが存在するかチェック
    if ($null -eq $filesToMerge) {
        Write-Host "対象ファイルが見つからなかったため、処理をスキップしました。"
        continue
    }
    
    # 出力ファイル名をソースフォルダ名から生成
    $outputFileName = "$((Split-Path -Path $path -Leaf)).txt"
    $fullOutputPath = Join-Path -Path $finalOutputDir -ChildPath $outputFileName

    # 検索したファイルをマージして一つのファイルに出力
    $filesToMerge | ForEach-Object {
        # ヘッダーとしてファイル名を出力
        "# $($_.Name)"
        # ファイルの内容を出力
        Get-Content -Path $_.FullName
        # 2行の空行を追加
        ""
        ""
    } | Set-Content -Path $fullOutputPath -Encoding UTF8

    # 完了メッセージ
    Write-Host "ファイルのマージが完了しました。"
    Write-Host "   出力ファイル: $fullOutputPath"
}

Write-Host "--------------------------------------------------"
Write-Host "すべての指定フォルダの処理が完了しました。"

# 4. ログ出力を終了
Stop-Transcript