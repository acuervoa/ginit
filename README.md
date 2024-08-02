# create_repo.sh

Este script automatiza la creación de un repositorio en GitHub y configura el directorio local para rastrear ese repositorio. A continuación se detallan los pasos para su uso y configuración.

## Requisitos

- Tener `git` instalado en tu sistema.
- Tener una cuenta de GitHub.
- Generar un token de acceso personal en GitHub con permisos para crear repositorios.
- Configurar una clave SSH y añadirla a tu cuenta de GitHub para autenticación SSH.

## Preparación

1. Crea un archivo `.env` en el mismo directorio que `create_repo.sh` con el siguiente contenido:

    ```env
    GITHUB_TOKEN=tu_token_de_github
    ```

2. Asegúrate de que `create_repo.sh` tenga permisos de ejecución:

    ```bash
    chmod +x create_repo.sh
    ```

## Uso

Puedes ejecutar el script desde cualquier directorio. El script tomará el nombre del directorio actual como el nombre del repositorio si no se proporciona un nombre de repositorio como parámetro.

### Ejecución sin parámetros

Si ejecutas el script sin proporcionar un nombre de repositorio, usará el nombre del directorio actual:

```bash
/path/al/directorio/del/script/create_repo.sh

