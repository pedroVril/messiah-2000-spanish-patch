@echo off
REM ============================================================
REM  2/3 Instalar parche - Parche espanol Messiah (2003)
REM  Requiere haber ejecutado antes crear-respaldo.bat.
REM  Copia patch-es\ sobre el juego y fija Language=S.
REM  Solo se excluye pc\intro.mve (se conserva el original).
REM  Pide elevacion a Administrador solo para el registro.
REM  Uso: instalar-parche-es.bat ["ruta del juego"]
REM ============================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1

REM ---- Auto-elevar a Administrador (con goto, sin bloques: robusto ante rutas con parentesis) ----
REM Bypass solo para pruebas automatizadas: MESSIAH_NO_ELEVATE=1
if /i "%MESSIAH_NO_ELEVATE%"=="1" goto :elevated
net session >nul 2>&1
if %errorlevel% == 0 goto :elevated
echo  Solicitando permisos de Administrador...
if not "%~1"=="" goto :with_args
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
goto :elev_done
:with_args
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
:elev_done
if errorlevel 1 (
  echo.
  echo  [ERROR] No se pudo mostrar el aviso de Administrador (UAC^).
  echo  Si cancelaste el aviso, vuelve a intentarlo y pulsa "Si".
  echo  Alternativa manual: clic derecho en %~nx0 -^> Ejecutar como administrador.
  pause
  exit /b 1
)
exit /b
:elevated

set "SCRIPT_DIR=%~dp0"
set "PATCH_DIR=%SCRIPT_DIR%..\patch-es"
set "BK_LOCAL=%SCRIPT_DIR%backup"
set "GAME_DIR=%~1"
if not defined GAME_DIR (
  set "GAME_DIR=C:\GOG Games\Messiah"
  if not exist "C:\GOG Games\Messiah\MessiahD3D.exe" (
    if exist "C:\Program Files (x86)\Steam\steamapps\common\Messiah\MessiahD3D.exe" (
      set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Messiah"
    ) else (
      echo.
      echo  No se encontro el juego en la ruta por defecto.
      echo  Uso: %~nx0 ["ruta del juego"]
      echo.
      set /p "GAME_DIR=Escribe la ruta de la carpeta del juego (donde esta MessiahD3D.exe): "
    )
  )
)

REM Hashes esperados del parche (integridad)
set "EXP_ALL=7E4365B4658CC5D761EF4BE478FF893478D67E52A917F10E604B6475354BFDF1"
set "EXP_DTA=7121F52751D79C54675F2A3631F11F2C9743A16ADBE2D02A488FEEFD4884C0AC"
set "EXP_IDX=CF41704C231837542D39A794AC7094E589343D979DB2F0A0AA6D77FDEA71B602"
set "EXP_ENDY=48033A031957D3AC9635AB34BC62C3C3ABBE21396EE8CF7D511AE919770624FB"
set "EXP_SLOGO=4420E5EFEB028A8AFE7A0376C5D90E457BA75F67E4AD46136A491954FB4009C1"
set "EXP_TTS=1DE9BC4CD34D29700E00A028C6EFF37A8CE24ADF8F955E31D4FF41A67C080ED6"
set "REG_KEY=HKLM\SOFTWARE\WOW6432Node\Shiny\Messiah\1.00.000"
set "REG_KEY2=HKLM\SOFTWARE\WOW6432Node\GOG.com\Messiah"
set "REG_KEY2B=HKLM\SOFTWARE\GOG.com\Messiah"

echo.
echo  Juego:  !GAME_DIR!
echo  Parche: !PATCH_DIR!
echo.

REM ---- [1/6] El juego existe? ----
if not exist "!GAME_DIR!\MessiahD3D.exe" (
  echo  [ERROR] No se encontro MessiahD3D.exe en !GAME_DIR!
  pause
  exit /b 1
)

REM ---- [2/6] Hay respaldo? (local nuevo o ubicacion anterior en el juego) ----
set "BKDIR="
if exist "!BK_LOCAL!\Language.txt" set "BKDIR=!BK_LOCAL!"
if not defined BKDIR (
  if exist "!GAME_DIR!\backup-pre-parche-es\Language.txt" set "BKDIR=!GAME_DIR!\backup-pre-parche-es"
)
if not defined BKDIR (
  echo  [ERROR] No hay backup creado en la carpeta actual.
  echo  Ejecuta primero crear-respaldo.bat y vuelve a intentarlo.
  pause
  exit /b 2
)
echo  Respaldo encontrado en: !BKDIR!

REM ---- [3/6] El parche ya esta instalado? ----
call :hash "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" CUR_ALL
set "YA=0"
if exist "!GAME_DIR!\pc\sound\sspeek.dta" (
  if exist "!GAME_DIR!\pc\interfce\Menu\Spanish" (
    if /i "!CUR_ALL!"=="!EXP_ALL!" set "YA=1"
  )
)
if "!YA!"=="1" (
  reg query "%REG_KEY2%" /v Language | findstr /R /C:"REG_SZ.*S$" >nul
  if not errorlevel 1 (
    echo  El parche ya esta instalado. Nada que hacer.
    pause
    exit /b 0
  )
  echo  Ficheros ya instalados; completando el registro...
  goto :solo_registro
)

REM ---- [4/6] Integridad del parche antes de copiar ----
if exist "!PATCH_DIR!\pc\intro.mve" (
  echo  [ERROR] patch-es contiene pc\intro.mve, no contemplado en esta version.
  echo  Quitalo de patch-es\pc\ y vuelve a intentarlo.
  pause
  exit /b 3
)
call :hash "!PATCH_DIR!\pc\language\Spanish\All_Spanish.txt" H1
call :hash "!PATCH_DIR!\pc\sound\sspeek.dta" H2
call :hash "!PATCH_DIR!\pc\sound\sspeek.idx" H3
call :hash "!PATCH_DIR!\pc\endy.mve" H4
call :hash "!PATCH_DIR!\pc\Slogo.mve" H5
call :hash "!PATCH_DIR!\pc\ttslogo.mve" H6
set "BAD=0"
if /i not "!H1!"=="!EXP_ALL!" set "BAD=1"
if /i not "!H2!"=="!EXP_DTA!" set "BAD=1"
if /i not "!H3!"=="!EXP_IDX!" set "BAD=1"
if /i not "!H4!"=="!EXP_ENDY!" set "BAD=1"
if /i not "!H5!"=="!EXP_SLOGO!" set "BAD=1"
if /i not "!H6!"=="!EXP_TTS!" set "BAD=1"
if "!BAD!"=="1" (
  echo  [ERROR] Los ficheros de patch-es no coinciden con los hashes esperados.
  echo  Descarga o restaura patch-es y vuelve a intentarlo. No se copio nada.
  pause
  exit /b 3
)
echo  Integridad del parche: OK ^(6/6 hashes^)

REM ---- [5/6] Copia + verificacion ----
echo  Copiando ficheros en espanol...
xcopy "!PATCH_DIR!\pc" "!GAME_DIR!\pc\" /E /I /Y >nul
if errorlevel 1 (
  echo  [ERROR] Fallo la copia con xcopy.
  pause
  exit /b 4
)
set "VG=0"
if not exist "!GAME_DIR!\pc\sound\sspeek.dta" set "VG=1"
if not exist "!GAME_DIR!\pc\sound\sspeek.idx" set "VG=1"
if not exist "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" set "VG=1"
if not exist "!GAME_DIR!\pc\interfce\Menu\Spanish\MMainPlayGame1.tga" set "VG=1"
call :hash "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" V_ALL
call :hash "!GAME_DIR!\pc\sound\sspeek.dta" V_DTA
if /i not "!V_ALL!"=="!EXP_ALL!" set "VG=1"
if /i not "!V_DTA!"=="!EXP_DTA!" set "VG=1"
if "!VG!"=="1" (
  echo  [ERROR] La verificacion de la copia fallo. Restaura el backup y revisa el disco.
  pause
  exit /b 4
)
echo  Copia verificada: OK

REM ---- [6/6] Activar idioma S en el registro (Shiny + GOG Widescreen) ----
:solo_registro
echo  Fijando Language=S en el registro...
set "RG="
reg add "%REG_KEY%" /v Language /t REG_SZ /d S /f >nul
if errorlevel 1 set "RG=1"
reg add "%REG_KEY2B%" /v Language /t REG_SZ /d S /f >nul
if errorlevel 1 set "RG=1"
reg add "%REG_KEY2%" /v Language /t REG_SZ /d S /f >nul
if errorlevel 1 set "RG=1"
if defined RG (
  echo.
  echo  [AVISO] No se pudo escribir alguna clave del registro (falta permiso de Administrador^).
  echo  Los ficheros estan instalados y verificados; ejecuta este script
  echo  como Administrador para activar el idioma.
  pause
  exit /b 5
)
reg query "%REG_KEY%" /v Language | findstr /R /C:"REG_SZ.*S$" >nul
if errorlevel 1 set "RG=1"
reg query "%REG_KEY2%" /v Language | findstr /R /C:"REG_SZ.*S$" >nul
if errorlevel 1 set "RG=1"
if defined RG (
  echo  [AVISO] El registro no devuelve Language=S en ambas claves. Revisalo manualmente.
  pause
  exit /b 5
)
echo.
echo  Parche instalado y verificado. Solo pc\intro.mve quedo intacto (original^).
pause
endlocal
exit /b 0

REM ---- subrutina: calcula SHA256 de un fichero -> variable ----
:hash
set "HFILE=%~1"
set "%~2=?"
for /f "skip=1 delims=" %%h in ('certutil -hashfile "!HFILE!" SHA256 2^>nul') do (
  set "%~2=%%h"
  goto :hash_done
)
:hash_done
exit /b 0
