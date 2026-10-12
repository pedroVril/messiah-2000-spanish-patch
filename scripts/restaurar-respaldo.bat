@echo off
REM ============================================================
REM  3/3 Restaurar respaldo - Parche espanol Messiah (2003)
REM  Devuelve el juego a ingles usando scripts\backup
REM  (acepta tambien la ubicacion anterior backup-pre-parche-es
REM  dentro del juego). El respaldo se conserva.
REM  Pide elevacion a Administrador solo para el registro.
REM  Uso: restaurar-respaldo.bat ["ruta del juego"]
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
set "BK_LOCAL=%SCRIPT_DIR%backup"
set "ORIG_ALL=C9EEDE81EBDD5130194F3B6C2354D845AD072DC8974E04809854BA6FEDC1F413"
set "GAME_DIR=%~1"
if not defined GAME_DIR (
  set "GAME_DIR=C:\GOG Games\Messiah"
  if not exist "C:\GOG Games\Messiah\MessiahD3D.exe" (
    if exist "C:\Program Files (x86)\Steam\steamapps\common\Messiah\MessiahD3D.exe" (
      set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\Messiah"
    ) else (
      set /p "GAME_DIR=Escribe la ruta de la carpeta del juego: "
    )
  )
)
set "REG_KEY=HKLM\SOFTWARE\WOW6432Node\Shiny\Messiah\1.00.000"
set "REG_KEY2=HKLM\SOFTWARE\WOW6432Node\GOG.com\Messiah"
set "REG_KEY2B=HKLM\SOFTWARE\GOG.com\Messiah"

echo.
echo  Juego: !GAME_DIR!
echo.

REM ---- [1/5] El juego existe? ----
if not exist "!GAME_DIR!\MessiahD3D.exe" (
  echo  [ERROR] No se encontro MessiahD3D.exe en !GAME_DIR!
  pause
  exit /b 1
)

REM ---- [2/5] Hay respaldo? ----
set "BKDIR="
if exist "!BK_LOCAL!\Language.txt" set "BKDIR=!BK_LOCAL!"
if not defined BKDIR (
  if exist "!GAME_DIR!\backup-pre-parche-es\Language.txt" set "BKDIR=!GAME_DIR!\backup-pre-parche-es"
)
if not defined BKDIR (
  echo  [ERROR] No hay backup creado en la carpeta actual.
  echo  Sin respaldo no se puede restaurar con seguridad.
  pause
  exit /b 2
)
echo  Respaldo encontrado en: !BKDIR!
if not exist "!BKDIR!\pc\language\Spanish\All_Spanish.txt" (
  echo  [ERROR] El respaldo esta incompleto (falta All_Spanish.txt^).
  pause
  exit /b 2
)

REM ---- [3/5] Devolver ficheros originales ----
echo  [1/3] Devolviendo All_Spanish.txt original...
copy /Y "!BKDIR!\pc\language\Spanish\All_Spanish.txt" "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" >nul
if errorlevel 1 (
  echo  [ERROR] Fallo la copia del All_Spanish.txt original.
  pause
  exit /b 3
)
fc /b "!BKDIR!\pc\language\Spanish\All_Spanish.txt" "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" >nul
if errorlevel 1 (
  echo  [ERROR] El All_Spanish.txt restaurado no coincide con el respaldo.
  pause
  exit /b 3
)
call :hash "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" R_ALL
if /i "!R_ALL!"=="!ORIG_ALL!" (
  echo  All_Spanish.txt original verificado: OK
) else (
  echo  (Aviso: el All_Spanish.txt restaurado no coincide con el original GOG conocido.^)
  echo  (Si tu juego es de Steam u otra version, puede ser normal.^)
)
echo  [2/3] Eliminando restos del parche...
if exist "!GAME_DIR!\pc\sound\sspeek.dta" del "!GAME_DIR!\pc\sound\sspeek.dta"
if exist "!GAME_DIR!\pc\sound\sspeek.idx" del "!GAME_DIR!\pc\sound\sspeek.idx"
if exist "!GAME_DIR!\pc\interfce\Menu\Spanish" rmdir /S /Q "!GAME_DIR!\pc\interfce\Menu\Spanish"
if exist "!GAME_DIR!\pc\sound\sspeek.dta" (
  echo  [ERROR] No se pudo eliminar sspeek.dta.
  pause
  exit /b 3
)
if exist "!GAME_DIR!\pc\interfce\Menu\Spanish" (
  echo  [ERROR] No se pudo eliminar Menu\Spanish.
  pause
  exit /b 3
)
echo  Restos del parche eliminados: OK
echo  [3/3] Devolviendo .mve originales (intro.mve nunca se toco^)...
for %%m in (endy.mve Slogo.mve ttslogo.mve) do (
  if exist "!BKDIR!\pc\%%m" (
    copy /Y "!BKDIR!\pc\%%m" "!GAME_DIR!\pc\%%m" >nul
  ) else (
    echo  (Aviso: el respaldo no incluye %%m, se deja como esta.^)
  )
)

REM ---- [4/5] Devolver idioma del registro ----
set "OLDLANG=E"
for /f "tokens=*" %%l in ('findstr /I "REG_SZ" "!BKDIR!\Language.txt" 2^>nul') do (
  for %%w in (%%l) do set "OLDLANG=%%w"
)
set "OLDLANG2=E"
set "DEL2=1"
if exist "!BKDIR!\Language-gog.txt" (
  findstr /I /C:"NO-EXISTIA" "!BKDIR!\Language-gog.txt" >nul
  if errorlevel 1 (
    set "DEL2=0"
    for /f "tokens=*" %%l in ('findstr /I "REG_SZ" "!BKDIR!\Language-gog.txt" 2^>nul') do (
      for %%w in (%%l) do set "OLDLANG2=%%w"
    )
  )
)
echo  Devolviendo registro Language=!OLDLANG! (Shiny + GOG^)...
reg add "%REG_KEY%" /v Language /t REG_SZ /d !OLDLANG! /f >nul
if errorlevel 1 set "RG=1"
if "!DEL2!"=="1" (
  reg delete "%REG_KEY2B%" /v Language /f >nul 2>&1
  reg delete "%REG_KEY2%" /v Language /f >nul 2>&1
  reg delete "%REG_KEY2B%" /f >nul 2>&1
  reg delete "%REG_KEY2%" /f >nul 2>&1
  echo  Clave GOG devuelta a su estado original (eliminada^).
) else (
  reg add "%REG_KEY2B%" /v Language /t REG_SZ /d !OLDLANG2! /f >nul
  if errorlevel 1 set "RG=1"
  reg add "%REG_KEY2%" /v Language /t REG_SZ /d !OLDLANG2! /f >nul
  if errorlevel 1 set "RG=1"
  echo  Clave GOG devuelta a Language=!OLDLANG2!.
)
if defined RG (
  echo  [AVISO] Sin permiso de Administrador: cambia manualmente Language=!OLDLANG!
  echo  Los ficheros ya estan restaurados; solo falta el registro.
  pause
  exit /b 4
)

REM ---- [5/5] Estado final ----
echo.
echo  Estado final:
reg query "%REG_KEY%" /v Language
if exist "!GAME_DIR!\pc\sound\sspeek.dta" (echo   [AVISO] sspeek.dta sigue presente) else (echo   [OK] sspeek eliminado)
if exist "!GAME_DIR!\pc\interfce\Menu\Spanish" (echo   [AVISO] Menu\Spanish sigue presente) else (echo   [OK] Menu\Spanish eliminado)
echo.
echo  Restauracion completa (el respaldo se conserva en !BKDIR!).
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
