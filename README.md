# traductor_creole

Aplicación Flutter para traducción Creole.

## Build Android optimizado en tamaño

Para reducir el tamaño de descarga en Android:

- El proyecto usa `minify` + `shrinkResources` en release.
- El proyecto genera APKs por arquitectura (ABI splits), evitando incluir binarios nativos no usados.

Comandos recomendados:

```bash
# Opción recomendada para Play Store (descarga dinámica por dispositivo)
flutter build appbundle --release

# Si necesitas APK directo, genera uno por arquitectura
flutter build apk --release --split-per-abi
```

## Desarrollo

```bash
flutter pub get
flutter run
```
