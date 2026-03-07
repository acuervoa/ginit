# Changelog

English version: [`CHANGELOG.md`](CHANGELOG.md)

Las release notes se redactan por defecto en ingles. Para futuras releases, parte de [`.github/RELEASE_TEMPLATE.md`](.github/RELEASE_TEMPLATE.md).

## v1.1.0

- prepara el proyecto para publicarlo con licencia MIT, CI en GitHub Actions y documentacion mas completa
- anade badges al README y aclara instalacion, permisos del token y troubleshooting
- actualiza las pruebas para que `--version` siga el ultimo tag real del repo

## v1.0.3

- mejora `ginit --help` para mostrar el nombre real del comando invocado
- anade una descripcion corta al inicio de la ayuda

## v1.0.2

- anade `--version` para mostrar el ultimo tag disponible
- incorpora `CHANGELOG.md`
- documenta el nuevo flag y lo cubre con una prueba automatizada

## v1.0.1

- corrige la perdida de `API_STATUS` al salir de subshells
- anade una prueba de regresion para el flujo de autenticacion

## v1.0.0

- endurece `ginit.sh` con validaciones mas estrictas y manejo de errores mas claro
- anade `--dry-run` para previsualizar cambios sin tocar estado local ni remoto
- actualiza la documentacion y `.env.EXAMPLE`

## v1.0.0-rc.1

- publica la release candidate inicial de la refactorizacion endurecida
