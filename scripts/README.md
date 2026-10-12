# Carpeta scripts — Parche español Messiah (2003)

Tres pasos, en orden:

1. `crear-respaldo.bat` — Guarda los ficheros originales en `scripts/backup`.
   No necesita permisos de Administrador.
2. `instalar-parche-es.bat` — Instala el parche y activa el español.
   Pide permiso de Administrador solo (pulsa "Sí" en el aviso).
   Necesita que exista el respaldo del paso 1.
3. `restaurar-respaldo.bat` — Devuelve el juego a inglés usando el respaldo.
   Pide permiso de Administrador solo.

Doble clic en cada uno y sigue lo que dice la ventana.
El respaldo (`scripts/backup`) nunca se sube a git.

Extra: `jugar-messiah.bat` — arranca el juego en modo D3D con los
switches estables (`-i +!`). Úsalo si el juego no abre