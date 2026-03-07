# ginit.sh

`ginit.sh` crea un repositorio de GitHub desde el directorio actual, inicializa Git cuando hace falta, realiza un primer commit, configura `origin` y publica `main`.

## Caracteristicas

- Funciona desde cualquier directorio y resuelve su propio archivo `.env`.
- Soporta usuarios y organizaciones de GitHub.
- Crea repositorios privados por defecto.
- Soporta remotos `ssh` o `https`.
- Bloquea archivos sensibles comunes antes de hacer staging.
- Puede omitir el primer commit con `--no-commit`.
- Incluye un modo `--dry-run` para validar sin tocar nada.

## Requisitos

- `git`
- `curl`
- Un personal access token de GitHub con permisos para crear repositorios.
- SSH configurado para GitHub si usas el modo remoto `ssh`, que es el predeterminado.

## Configuracion

Crea un archivo `.env` junto a `ginit.sh` usando `.env.EXAMPLE` como plantilla:

```env
GITHUB_TOKEN=your_token_here
GITHUB_OWNER=your_github_user_or_org
```

## Uso

```bash
./ginit.sh [repo-name] [--private|--public] [--remote ssh|https] [--no-commit] [--dry-run]
```

Ejemplos:

```bash
./ginit.sh
./ginit.sh my-new-repo
./ginit.sh my-public-repo --public
./ginit.sh my-repo --remote https
./ginit.sh my-repo --no-commit
./ginit.sh my-repo --dry-run
```

Si omites `repo-name`, el script usa el nombre del directorio actual.

## Controles de seguridad

Antes de publicar, el script:

- valida el token de GitHub
- detecta si `GITHUB_OWNER` es un usuario o una organizacion
- comprueba que el repositorio de destino no exista ya
- se niega a continuar si `origin` ya existe en local
- verifica la autenticacion SSH cuando usas `--remote ssh`
- aborta si detecta archivos probablemente sensibles que no estan ignorados

## Notas

- `--private` es el modo predeterminado.
- Con `--no-commit`, se crea el remoto y se configura `origin`, pero no se hace ningun push.
- Con `--dry-run`, el script muestra las acciones que haria y evita cambios locales y remotos.
- El script avisa si el repositorio remoto llego a crearse pero un paso posterior fallo.
