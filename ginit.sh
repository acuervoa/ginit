#!/usr/bin/env bash
set -euo pipefail

# --- Resolución de ruta del script ---
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# --- Carga segura de .env (sin romper valores con espacios) ---
ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
else
  echo "Error: archivo .env no encontrado en $SCRIPT_DIR" >&2
  exit 1
fi

# --- Variables requeridas ---
: "${GITHUB_TOKEN:?Define GITHUB_TOKEN en .env}"
: "${GITHUB_OWNER:?Define GITHUB_OWNER (tu usuario/org de GitHub) en .env}"

# --- Nombre del repo ---
CURRENT_DIR_NAME=$(basename "$PWD")
REPO_NAME="${1:-$CURRENT_DIR_NAME}"

# --- Función HTTP simple que devuelve código de estado ---
http_code() {
  local method="$1"; shift
  curl -sS -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -X "$method" "$@"
}

# --- Verificación del token (debug rápido) ---
USER_CHECK_CODE=$(http_code GET "https://api.github.com/user")
if [[ "$USER_CHECK_CODE" != "200" ]]; then
  echo "Error: el token no es válido o no tiene permisos (HTTP $USER_CHECK_CODE)." >&2
  echo "Comprueba que el PAT es correcto y tiene permisos 'repo' (PAT clásico) o permisos finos para crear repos." >&2
  exit 1
fi

# --- Comprobar si el repo remoto ya existe ---
REPO_URL_API="https://api.github.com/repos/$GITHUB_OWNER/$REPO_NAME"
REPO_EXIST_CODE=$(http_code GET "$REPO_URL_API")
if [[ "$REPO_EXIST_CODE" == "200" ]]; then
  echo "Error: El repositorio '$REPO_NAME' ya existe en $GITHUB_OWNER." >&2
  exit 1
elif [[ "$REPO_EXIST_CODE" != "404" ]]; then
  echo "Aviso: respuesta inesperada al comprobar existencia (HTTP $REPO_EXIST_CODE)." >&2
fi

# --- Inicializar repo local si hace falta (antes de ejecutar comandos git) ---
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi

# --- Evitar colisión si ya hay un remoto 'origin' ---
if git remote | grep -q '^origin$'; then
  echo "Error: el repositorio local ya tiene un remoto 'origin' configurado." >&2
  exit 1
fi

# --- Crear repo privado en GitHub ---
CREATE_PAYLOAD=$(printf '{"name":"%s","private":true,"auto_init":false,"visibility":"private"}' "$REPO_NAME")
CREATE_RESP=$(curl -sS \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -X POST https://api.github.com/user/repos \
  -d "$CREATE_PAYLOAD")

if ! echo "$CREATE_RESP" | grep -q '"full_name"'; then
  echo "Error al crear el repositorio '$REPO_NAME'." >&2
  echo "$CREATE_RESP" >&2
  exit 1
fi
echo "Repositorio remoto '$REPO_NAME' creado en $GITHUB_OWNER (privado)."

# --- README por defecto si no existe ---
if [[ ! -f README.md ]]; then
  {
    echo "# $REPO_NAME"
    echo
    echo "Repositorio creado automáticamente."
  } > README.md
fi

# --- Primer commit ---
git add .
if ! git diff --cached --quiet; then
  git commit -m "Initial commit"
fi

# --- Configurar remoto y rama principal ---
git remote add origin "git@github.com:$GITHUB_OWNER/$REPO_NAME.git"
git branch -M main

# --- Verificación de SSH hacia GitHub (salida esperada code=1 y mensaje 'does not provide shell') ---
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  :
fi
# Nota: ssh -T suele devolver exit code 1 incluso en éxito. No abortamos por ese código.

# --- Push inicial ---
git push -u origin main
echo "OK: repositorio local vinculado y publicado como '$GITHUB_OWNER/$REPO_NAME'."

