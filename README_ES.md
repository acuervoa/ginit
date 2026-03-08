# ginit

[![CI](https://github.com/acuervoa/ginit/actions/workflows/ci.yml/badge.svg)](https://github.com/acuervoa/ginit/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/acuervoa/ginit)](https://github.com/acuervoa/ginit/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English version: [`README.md`](README.md)

Ultimas notas de release: [`CHANGELOG_ES.md`](CHANGELOG_ES.md)

Changelog en ingles: [`CHANGELOG.md`](CHANGELOG.md)

`ginit` crea un repositorio de GitHub desde el directorio actual, inicializa Git cuando hace falta, realiza un primer commit, configura `origin` y publica `main`.

## Caracteristicas

- Funciona desde cualquier directorio y resuelve su propio archivo `.env`.
- Soporta usuarios y organizaciones de GitHub.
- Soporta sobrescribir el owner objetivo con `--owner`.
- Crea repositorios privados por defecto.
- Soporta remotos `ssh` o `https`.
- Bloquea archivos sensibles comunes antes de hacer staging.
- Puede omitir el primer commit con `--no-commit`.
- Incluye un modo `--dry-run` para validar sin tocar nada.
- Muestra la version instalada con `--version`.
- Las instalaciones guardan su version de release en un archivo local `VERSION`.

## Instalacion

Instalacion recomendada:

```bash
bash install.sh
```

Tambien puedes hacer una instalacion manual si prefieres un clon estable del repo:

```bash
mkdir -p ~/.local/share
git clone https://github.com/acuervoa/ginit.git ~/.local/share/ginit
chmod +x ~/.local/share/ginit/ginit.sh
ln -sf ~/.local/share/ginit/ginit.sh ~/.local/bin/ginit
```

Asegurate de tener `~/.local/bin` en tu `PATH`.

## Requisitos

- `git`
- `curl`
- `bash`
- `ssh` si usas el modo remoto `ssh`, que es el predeterminado

## Configuracion

`ginit` carga el archivo `.env` que vive junto al script instalado, no el del proyecto donde lo ejecutas.

Si instalaste el comando como en el ejemplo anterior, crea este archivo:

```env
# ~/.local/share/ginit/.env
GITHUB_TOKEN=your_token_here
GITHUB_OWNER=your_github_user_or_org
```

Tambien puedes copiar `.env.EXAMPLE` y completarlo.

### Permisos del token

- PAT clasico: permiso `repo`
- Fine-grained token: permisos para crear repositorios en el owner que uses
- Si `GITHUB_OWNER` es una organizacion, el token debe poder crear repos en esa organizacion

## Uso

```bash
ginit [repo-name] [--private|--public] [--remote ssh|https] [--owner OWNER] [--no-commit] [--dry-run] [--version]
```

Ejemplos:

```bash
ginit
ginit my-new-repo
ginit my-new-repo --owner my-org
ginit my-public-repo --public
ginit my-repo --remote https
ginit my-repo --no-commit
ginit my-repo --dry-run
ginit --version
ginit --help
```

Si omites `repo-name`, el script usa el nombre del directorio actual.

Si omites `--owner`, `ginit` usa `GITHUB_OWNER` desde `.env`.

No uses `ginit .`: `.` no es un nombre de repositorio valido en GitHub.

## Controles de seguridad

Antes de publicar, el script:

- valida el token de GitHub
- detecta si `GITHUB_OWNER` es un usuario o una organizacion
- comprueba que el repositorio de destino no exista ya
- se niega a continuar si `origin` ya existe en local
- verifica la autenticacion SSH cuando usas `--remote ssh`
- aborta si detecta archivos probablemente sensibles que no estan ignorados

## Troubleshooting

- `Bad credentials`
  - revisa `GITHUB_TOKEN` en el `.env` del directorio de instalacion de `ginit`
- `invalid remote mode`
  - usa solo `ssh` o `https`
- `repository '.' already exists` o nombre invalido
  - ejecuta `ginit` o `ginit nombre-del-repo`, no `ginit .`
- fallo con SSH
  - prueba `ginit --remote https` o configura tu clave SSH en GitHub

## Desarrollo

Comprobaciones locales:

```bash
bash -n ginit.sh
bash -n install.sh
bash tests/version_flag.sh
bash tests/api_status_regression.sh
bash tests/repo_name_validation.sh
bash tests/owner_flag.sh
bash tests/dry_run_smoke.sh
actionlint
gitleaks detect --no-git --source . --redact --exit-code 1
shellcheck ginit.sh install.sh tests/*.sh
```

El repo incluye CI en GitHub Actions para ejecutar estas comprobaciones en cada push y pull request.

Las notas de release se redactan por defecto en ingles. Usa `.github/RELEASE_TEMPLATE.md` como punto de partida para futuras releases.

## Licencia

MIT. Consulta `LICENSE`.
