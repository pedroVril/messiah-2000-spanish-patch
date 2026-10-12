@echo off
REM ============================================================
REM  Jugar Messiah (2003) - lanzador D3D con switches estables
REM  -x -i +! combinacion de la guia 2024 (partida completa verificada):
REM  salta intros y evita el crash juego->menu (ver ReadMe 11.0)
REM  No requiere permisos de Administrador.
REM  Uso: doble clic, o: jugar-messiah.bat ["ruta del juego"]
REM ============================================================
setlocal EnableExtensions EnableDelayedExpansion

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
if not exist "!GAME_DIR!\MessiahD3D.exe" (
  echo  [ERROR] No se encontro MessiahD3D.exe en !GAME_DIR!
  pause
  exit /b 1
)
start "" /D "!GAME_DIR!" "!GAME_DIR!\MessiahD3D.exe" -x -i +! %*
endlocal
exit /b 0
