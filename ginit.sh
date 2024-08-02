#!/bin/bash

# Obtener la ruta del directorio donde se encuentra el script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar variables de entorno desde el archivo .env
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
else
    echo "Error: archivo .env no encontrado en $SCRIPT_DIR."
    exit 1
fi

# Verificar si el nombre del repositorio fue proporcionado
if [ -z "$1" ]; then
    echo "Uso: $0 NOMBRE_DEL_REPOSITORIO"
    exit 1
fi

REPO_NAME=$1

# Asegurarse de que el token de GitHub esté disponible como variable de entorno
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: La variable de entorno GITHUB_TOKEN no está configurada."
    exit 1
fi

# Verificar si el repositorio remoto ya existe en GitHub
REPO_EXIST=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/acuervoa/$REPO_NAME)

if [ $REPO_EXIST -eq 200 ]; then
    echo "Error: El repositorio '$REPO_NAME' ya existe en GitHub."
    exit 1
fi

# Verificar si el directorio local ya tiene un repositorio remoto configurado
if git remote | grep origin > /dev/null; then
    echo "Error: El directorio local ya tiene un repositorio remoto configurado."
    exit 1
fi

# Comando curl para crear el repositorio privado
REPO_CREATE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -d "{\"name\":\"$REPO_NAME\", \"private\": true}" \
     https://api.github.com/user/repos)

# Verificar si el repositorio fue creado exitosamente
if echo "$REPO_CREATE" | grep -q '"full_name":'; then
    echo "Repositorio '$REPO_NAME' creado exitosamente como privado."
else
    echo "Error al crear el repositorio '$REPO_NAME'."
    echo "$REPO_CREATE"
    exit 1
fi

# Inicializar el repositorio local si no está ya inicializado
if [ ! -d .git ]; then
    git init
fi

# Crear un archivo README.md si no existe
if [ ! -f README.md ]; then
    echo "# $REPO_NAME" > README.md
    echo "Este es un repositorio para $REPO_NAME." >> README.md
    echo "Repositorio creado automáticamente con un script." >> README.md
fi


# Añadir todos los archivos al repositorio local y hacer el primer commit
git add .
git commit -m "Initial commit"

# Añadir el repositorio remoto y hacer push utilizando SSH
git remote add origin git@github.com:acuervoa/$REPO_NAME.git
git branch -M main

# Verificar si la clave SSH está configurada correctamente
ssh -T git@github.com
if [ $? -ne 1 ]; then
    echo "Error: no se pudo autenticar con GitHub mediante SSH. Verifique su configuración de SSH."
    exit 1
fi

# Hacer push al repositorio remoto
git push -u origin main
if [ $? -ne 0 ]; then
    echo "Error: no se pudo hacer push al repositorio remoto. Verifique los permisos y la URL remota."
    exit 1
fi

echo "Directorio local rastreado como el repositorio remoto '$REPO_NAME'."

