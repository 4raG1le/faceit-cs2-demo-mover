param([Parameter(Mandatory=$true)][string]$FilePath)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic
function Show-Err($msg) { [System.Windows.Forms.MessageBox]::Show($msg, "Move Demo to CS2", 'OK', 'Error') | Out-Null; exit 1 }
$steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
if (-not $steamPath) { $steamPath = "C:\Program Files (x86)\Steam" }
$cs2Path = Join-Path $steamPath "steamapps\common\Counter-Strike Global Offensive\game\csgo"
if (-not (Test-Path -LiteralPath $cs2Path)) { Show-Err "Could not find CS2 folder." }
$sevenZip = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path -LiteralPath $sevenZip)) { Show-Err "7-Zip not found. Download: https://www.7-zip.org/" }
$file = Get-Item -LiteralPath $FilePath
$ext  = $file.Extension.ToLower()
$temp = Join-Path $env:TEMP ("Faceit_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    $demPath = $null
    if ($ext -eq ".dem") { $demPath = $file.FullName }
    elseif ($ext -in @(".zst", ".gz", ".zip", ".rar", ".7z")) {
        & $sevenZip x $file.FullName -o"$temp" -y | Out-Null
        $dem = Get-ChildItem -Path $temp -Filter "*.dem" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $dem) { $dem = Get-ChildItem -Path $temp -File -Recurse -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 1 }
        if (-not $dem) { Show-Err "No files found in archive." }
        $demPath = $dem.FullName
    } else { Show-Err "Unsupported format: $ext" }
    $defaultName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $defaultName = ($defaultName -replace '[^\w\-\.]', '_')
    $userInput = [Microsoft.VisualBasic.Interaction]::InputBox("Enter demo name (without .dem):", "Move to CS2", $defaultName)
    if ([string]::IsNullOrWhiteSpace($userInput)) { exit 0 }
    $safeName = ($userInput -replace '[^\w\-\.]', '_')
    $destName = "$safeName.dem"
    $dest = Join-Path $cs2Path $destName
    $i = 1
    while (Test-Path -LiteralPath $dest) { $destName = "$($safeName)_$i.dem"; $dest = Join-Path $cs2Path $destName; $i++ }
    Copy-Item -LiteralPath $demPath -Destination $dest -Force
    $cmd = "playdemo " + [System.IO.Path]::GetFileNameWithoutExtension($destName)
    [Microsoft.VisualBasic.Interaction]::InputBox("Demo copied to CS2!`n`nCommand:", "Success", $cmd) | Out-Null
} catch { Show-Err "Error: $($_.Exception.Message)" }
finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue } }