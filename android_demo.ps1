param (
    [string]$env = "development"
)

$emulatorPath = "C:\AndroidSdk\emulator\emulator.exe"
$emulatorName = "Pixel_3a_API_34_extension_level_7_x86_64"

$emuladorEnEjecucion = flutter devices | Select-String "emulator-"
if (-not $emuladorEnEjecucion) {
    Write-Host "No hay emulador corriendo. Lanzando..."
    Start-Process $emulatorPath -ArgumentList $emulatorName
    Start-Sleep -Seconds 10
} else {
    Write-Host "Ya hay un emulador en ejecución."
}

do {
    $dispositivos = flutter devices
    Start-Sleep -Seconds 2
} until ($dispositivos -match "emulator-")

Write-Host "No hay base de datos corriendo. Lanzando..."
.\lib\src\sql\postgres_config\startup.ps1 $env

flutter pub get

flutter run --dart-define=ENVIRONMENT=$env -t .\lib\src\main.dart