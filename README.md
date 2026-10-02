# Archivo para iOS

Aplicación nativa SwiftUI conectada a la API de producción de Archivo.

## Requisitos

- macOS con Xcode 16 o posterior
- XcodeGen (`brew install xcodegen`)
- iOS 17 o posterior

## Generar y abrir

```bash
cd ios
xcodegen generate
open Archivo.xcodeproj
```

En Xcode, selecciona el target **Archivo**, elige tu equipo en **Signing & Capabilities** y ejecuta en un simulador o dispositivo. El bundle ID predeterminado es `com.societext.archivo`; cámbialo si tu cuenta ya lo utiliza.

## Compilación por terminal

```bash
xcodebuild -project Archivo.xcodeproj -scheme Archivo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

La configuración no contiene secretos. La sesión se conserva mediante las cookies seguras que devuelve la API HTTPS. Los permisos de cámara, fotos, micrófono y ubicación están declarados en `Info.plist`.

