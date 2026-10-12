@echo off
REM ============================================================
REM  Crear paquete release - Parche espanol Messiah (2003)
REM  Ensambla release\ (ignorado por git) con todo lo necesario
REM  para instalar: txts, patch-es, scripts y guia Win11.
REM  Tambien genera messiah-parche-es.zip al lado de release\.
REM  Uso: doble clic en crear-release.bat (no requiere admin).
REM ============================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1

set "ROOT=%~dp0.."
set "DST=%ROOT%\release"
set "ZIP=%ROOT%\messiah-parche-es.zip"
for %%d in ("!DST!") do set "DSHOW=%%~fd"

echo.
echo  Armando release en !DSHOW! ...
echo.

REM ---- [1/4] Validar fuentes ----
set "FALTA=0"
if not exist "!ROOT!\patch-es\pc\sound\sspeek.dta" set "FALTA=1"
if not exist "!ROOT!\patch-es\pc\language\Spanish\All_Spanish.txt" set "FALTA=1"
if not exist "%~dp0instalar-parche-es.bat" set "FALTA=1"
if not exist "%~dp0crear-respaldo.bat" set "FALTA=1"
if not exist "%~dp0restaurar-respaldo.bat" set "FALTA=1"
if not exist "%~dp0jugar-messiah.bat" set "FALTA=1"
if not exist "%~dp0utils\LEEME.txt" set "FALTA=1"
if not exist "%~dp0utils\LICENSE.txt" set "FALTA=1"
if "!FALTA!"=="1" (
  echo  [ERROR] Faltan ficheros fuente en el repo. Revisa patch-es y scripts.
  pause
  exit /b 1
)

REM ---- [2/4] Limpiar y copiar ----
if exist "!DST!" rmdir /S /Q "!DST!"
mkdir "!DST!\patch-es" 2>nul
mkdir "!DST!\scripts" 2>nul
mkdir "!DST!\docs" 2>nul
xcopy "!ROOT!\patch-es" "!DST!\patch-es\" /E /I /Y >nul
if errorlevel 1 (
  echo  [ERROR] Fallo la copia de patch-es.
  pause
  exit /b 2
)
copy /Y "%~dp0instalar-parche-es.bat" "!DST!\scripts\" >nul
copy /Y "%~dp0crear-respaldo.bat" "!DST!\scripts\" >nul
copy /Y "%~dp0restaurar-respaldo.bat" "!DST!\scripts\" >nul
copy /Y "%~dp0jugar-messiah.bat" "!DST!\scripts\" >nul
copy /Y "%~dp0utils\LEEME.txt" "!DST!\" >nul
copy /Y "%~dp0utils\LICENSE.txt" "!DST!\" >nul
if exist "!ROOT!\docs\jugar-en-windows-11.md" copy /Y "!ROOT!\docs\jugar-en-windows-11.md" "!DST!\docs\" >nul

REM ---- [3/4] Verificar contenido ----
set "VG=0"
if not exist "!DST!\patch-es\pc\sound\sspeek.dta" set "VG=1"
if not exist "!DST!\scripts\instalar-parche-es.bat" set "VG=1"
if not exist "!DST!\LEEME.txt" set "VG=1"
if not exist "!DST!\LICENSE.txt" set "VG=1"
if "!VG!"=="1" (
  echo  [ERROR] Verificacion del release fallo.
  pause
  exit /b 3
)

REM ---- [4/4] ZIP ----
if exist "!ZIP!" del "!ZIP!"
powershell -NoProfile -Command "Compress-Archive -LiteralPath '!DST!' -DestinationPath '!ZIP!' -Force"
if errorlevel 1 (
  echo  [AVISO] No se pudo crear el ZIP; la carpeta release si esta lista.
  pause
  exit /b 4
)
echo.
echo  Release OK:
set "N=0"
for /f %%f in ('dir "!DST!" /S /B /A-D 2^>nul') do set /a N+=1
echo  !N! ficheros en !DSHOW!
for %%z in ("!ZIP!") do echo  ZIP: %%~nxz (%%~zz bytes^)
pause
endlocal
exit /b 0
