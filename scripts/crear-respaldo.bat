@echo off
REM ============================================================
REM  1/3 Crear respaldo - Parche espanol Messiah (2003)
REM  Guarda los ficheros originales del juego en scripts\backup
REM  (carpeta ignorada por git) + el idioma actual del registro.
REM  NO requiere permisos de Administrador.
REM  Uso: crear-respaldo.bat ["ruta del juego"]
REM ============================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1

set "SCRIPT_DIR=%~dp0"
set "BACKUP_DIR=%SCRIPT_DIR%backup"
set "PATCH_ALL=7E4365B4658CC5D761EF4BE478FF893478D67E52A917F10E604B6475354BFDF1"
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

set "REG_KEY=HKLM\SOFTWARE\WOW6432Node\Shiny\Messiah\1.00.000"
set "REG_KEY2=HKLM\SOFTWARE\WOW6432Node\GOG.com\Messiah"

echo.
echo  Juego:  !GAME_DIR!
echo  Backup: !BACKUP_DIR!
echo.

REM ---- [1/5] El juego existe? ----
if not exist "!GAME_DIR!\MessiahD3D.exe" (
  echo  [ERROR] No se encontro MessiahD3D.exe en !GAME_DIR!
  echo  Revisa la ruta e intentalo de nuevo.
  pause
  exit /b 1
)

REM ---- [2/5] El respaldo ya existe en la carpeta actual? ----
if exist "!BACKUP_DIR!\Language.txt" (
  echo  [ERROR] El respaldo ya existe en la carpeta actual:
  echo  !BACKUP_DIR!
  echo  Borra esa carpeta si quieres crear un respaldo nuevo desde cero.
  pause
  exit /b 2
)

REM ---- [3/5] El juego ya parece parchado? (el respaldo debe guardar ORIGINALES) ----
call :hash "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" CUR_ALL
if /i "!CUR_ALL!"=="!PATCH_ALL!" (
  echo  [ERROR] El All_Spanish.txt del juego ya es el del parche.
  echo  Un respaldo ahora guardaria ficheros parchados, no originales.
  echo  Restaura primero el juego a ingles y vuelve a intentarlo.
  pause
  exit /b 3
)
if exist "!GAME_DIR!\pc\sound\sspeek.dta" (
  echo  [ERROR] El juego ya contiene sspeek.dta (voces del parche^).
  echo  Restaura primero el juego a ingles y vuelve a intentarlo.
  pause
  exit /b 3
)
if exist "!GAME_DIR!\pc\interfce\Menu\Spanish" (
  echo  [ERROR] El juego ya contiene Menu\Spanish (menus del parche^).
  echo  Restaura primero el juego a ingles y vuelve a intentarlo.
  pause
  exit /b 3
)

REM ---- [4/5] Crear respaldo ----
mkdir "!BACKUP_DIR!" 2>nul
mkdir "!BACKUP_DIR!\pc\language\Spanish" 2>nul
echo  [1/3] Guardando idioma actual del registro...
reg query "%REG_KEY%" /v Language > "!BACKUP_DIR!\Language.txt" 2>&1
if errorlevel 1 (
  echo  DESCONOCIDO ^(no se pudo leer el registro^) > "!BACKUP_DIR!\Language.txt"
  echo  (Aviso: no se pudo leer el registro; se sigue con los ficheros.^)
)
type "!BACKUP_DIR!\Language.txt"
reg query "%REG_KEY2%" /v Language > "!BACKUP_DIR!\Language-gog.txt" 2>&1
if errorlevel 1 (
  echo  NO-EXISTIA ^(el exe Widescreen lee esta clave; se recreara al instalar^) > "!BACKUP_DIR!\Language-gog.txt"
)
type "!BACKUP_DIR!\Language-gog.txt"
if not exist "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" (
  echo  [ERROR] No existe pc\language\Spanish\All_Spanish.txt en el juego. Juego incompleto?
  pause
  exit /b 4
)
echo  [2/3] Copiando All_Spanish.txt original...
copy /Y "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" "!BACKUP_DIR!\pc\language\Spanish\All_Spanish.txt" >nul
if errorlevel 1 (
  echo  [ERROR] Fallo la copia del All_Spanish.txt.
  pause
  exit /b 4
)
echo  [3/3] Copiando .mve originales (si existen^)...
set "MVE_OK=0"
set "MVE_N=0"
for %%m in (endy.mve Slogo.mve ttslogo.mve) do (
  if exist "!GAME_DIR!\pc\%%m" (
    set /a MVE_N+=1
    copy /Y "!GAME_DIR!\pc\%%m" "!BACKUP_DIR!\pc\%%m" >nul
    if not errorlevel 1 (
      if exist "!BACKUP_DIR!\pc\%%m" set /a MVE_OK+=1
    )
  ) else (
    echo  (Aviso: pc\%%m no existe en el juego, se omite.^)
  )
)
echo  .mve respaldados: !MVE_OK! de !MVE_N!

REM ---- [5/5] Manifiesto + verificacion ----
(
echo # Respaldo original Messiah ^(2003^) - creado %DATE% %TIME%
echo Juego: !GAME_DIR!
echo --- registro ---
type "!BACKUP_DIR!\Language.txt"
type "!BACKUP_DIR!\Language-gog.txt"
echo --- ficheros ---
) > "!BACKUP_DIR!\MANIFIESTO.txt" 2>nul
call :hash "!BACKUP_DIR!\pc\language\Spanish\All_Spanish.txt" BK_ALL
call :hash "!GAME_DIR!\pc\language\Spanish\All_Spanish.txt" GM_ALL
echo All_Spanish.txt juego=!GM_ALL!>> "!BACKUP_DIR!\MANIFIESTO.txt"
echo All_Spanish.txt backup=!BK_ALL!>> "!BACKUP_DIR!\MANIFIESTO.txt"
if /i not "!BK_ALL!"=="!GM_ALL!" (
  echo  [ERROR] El respaldo no coincide con el original. Revisa el disco.
  pause
  exit /b 5
)
echo.
echo  Respaldo OK en !BACKUP_DIR!
echo  Siguiente paso: instalar-parche-es.bat
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
