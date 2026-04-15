Write-Host "Baue Projekt..." -ForegroundColor Cyan
bun run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build fehlgeschlagen. Abbruch." -ForegroundColor Red
    exit 1
}

Write-Host "Lade Dateien auf den Server hoch..." -ForegroundColor Cyan
scp -r build/* hosting212287@202.61.233.108:cleli.de/httpdocs/

if ($LASTEXITCODE -ne 0) {
    Write-Host "Upload fehlgeschlagen." -ForegroundColor Red
    exit 1
}

Write-Host "Erfolgreich veröffentlicht!" -ForegroundColor Green
