# Jugar Messiah (2003) en Windows 11

Juego GOG en `C:\GOG Games\Messiah`. Seguir en orden.

## 1. Desactivar Nahimic
1. `Win+R` -> `services.msc` -> Enter.
2. Doble clic en **Nahimic service** -> **Detener**.
3. En esa misma ventana (Propiedades), **Tipo de inicio -> Deshabilitado**.
4. Reiniciar el PC.

## 2. Exe modificado Widescreen
1. Descargar `Messiah - Widescreen.7z` de
   https://www.wsgf.org/dr/messiah/en (tu aspecto de pantalla).
2. Copiar `C:\GOG Games\Messiah\MessiahD3D.exe` a otra carpeta (respaldo).
3. Pasar el `.7z` por el antivirus, descomprimirlo y copiar su
   `MessiahD3D.exe` a `C:\GOG Games\Messiah`, reemplazando.

## 3. winmm actualizado
1. Copiar `C:\GOG Games\Messiah\winmm.dll` a otra carpeta (respaldo).
2. Descargar `winmm-1.2.2.zip` de
   https://github.com/adambiser/ogg-winmm/releases.
3. Copiar su `winmm.dll` a `C:\GOG Games\Messiah`, reemplazando.

## 4. Sin modo compatibilidad
1. No se debe tener el modo compatibilidad activado. Clic derecho en `MessiahD3D.exe` -> Propiedades -> Compatibilidad.
2. Desmarcar TODO. Aceptar. (Igual para `MessiahGlide3x.exe`.)

## 5. Arrancar el juego
1. Doble clic en `scripts\jugar-messiah.bat` (nunca el `.exe` directo
   ni el boton de GOG Galaxy).
2. Dialogo de video: pantalla completa + Direct3D T&L HAL -> **Run game**.
3. Si pide el CD2: **Aceptar** hasta 3 veces -> menu.

## 6. Ajustes dentro del juego
1. Opciones de video -> desactivar `pre-load cached files`.
2. Jugar en pantalla completa (en ventana va acelerado; el juego no
   tiene VSync).

## 8. Notas de la version GOG
1. Los videos pueden ir sin voces en algun punto (fallo propio de
   esta version, no del parche).
2. Si el juego ofrece arrancar en modo seguro tras un cuelgue,
   aceptalo una vez para pasar el punto problematico y luego
   vuelve a entrar normal.

## 7. Parche espanol (cuando el juego abra estable)
1. Doble clic en `scripts\crear-respaldo.bat` (crea `scripts\backup`).
2. Doble clic en `scripts\instalar-parche-es.bat` (pulsa Si en el UAC).
3. Para volver a ingles: `scripts\restaurar-respaldo.bat`.
