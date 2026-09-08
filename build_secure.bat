@echo off
echo ========================================================
echo INICIANDO COMPILACION SEGURA (TITAN TIER) - ADUANA 801
echo ========================================================

echo Limpiando cache...
call flutter clean
call flutter pub get

echo Generando build ofuscado para Android...
call flutter build apk --release --obfuscate --split-debug-info=./debug_info

echo Generando build ofuscado para Web...
REM Para web no existe --obfuscate en el CLI de flutter, pero se compila a JS minificado por defecto.
call flutter build web --release --web-renderer canvaskit

echo.
echo ========================================================
echo COMPILACION TERMINADA
echo Los simbolos de debug fueron extraidos a ./debug_info
echo ========================================================
pause
