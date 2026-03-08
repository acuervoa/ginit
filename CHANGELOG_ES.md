# Changelog

English version: [`CHANGELOG.md`](CHANGELOG.md)

Las release notes se redactan por defecto en ingles. Para futuras releases, parte de [`.github/RELEASE_TEMPLATE.md`](.github/RELEASE_TEMPLATE.md).

## Unreleased

### Added
- validacion local del nombre del repositorio antes de llamar a la API de GitHub
- regresiones para validar nombres de repo y el flujo smoke de `--dry-run`
- comprobaciones de CI con `actionlint` y `gitleaks`

### Changed
- la guia de release ahora asume una seccion `Unreleased` al inicio del changelog

## v1.1.3

- anade un `CHANGELOG.md` en ingles y un `CHANGELOG_ES.md` en espanol
- hace que CI recupere tags y endurece la prueba de version para entornos sin tags
- anade `.github/RELEASE_TEMPLATE.md` para que las futuras release notes arranquen en ingles por defecto

## v1.1.2

- deja el ingles como README por defecto en GitHub
- mueve la guia en espanol a `README_ES.md`
- mantiene enlaces cruzados entre ambas versiones de la documentacion

## v1.1.1

- anade `README_EN.md` con una guia completa en ingles
- enlaza entre si la documentacion en espanol e ingles
- enlaza la guia en ingles con el changelog

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
