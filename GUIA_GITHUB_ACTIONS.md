# Guía de Compilación en la Nube con GitHub Actions · Archivo iOS

Esta carpeta ya incluye la configuración lista en `.github/workflows/build-ios.yml` para compilar **Archivo iOS** en servidores Apple oficiales (**macOS Sonoma con Xcode 16 y XcodeGen**) y entregarte los ejecutables `.ipa` y `.app` listos para usar.

---

## ⚡ Proceso Automático

1. **XcodeGen en macOS**: Instala `xcodegen` vía Homebrew y genera `Archivo.xcodeproj` automáticamente a partir de `project.yml`.
2. **Compilación Nativa ARM64**: Compila con Xcode 16 para arquitectura de iPhone físico (`generic/platform=iOS`).
3. **Empaquetado IPA**: Crea la estructura `Payload/` y genera `Archivo.ipa`.
4. **Compilación para Simulador**: Compila también para simuladores de iOS y genera `Archivo-Simulator.app.zip`.
5. **Artefactos**: Se suben a la pestaña *Artifacts* de la ejecución de GitHub Actions y al Release correspondiente.

---

## 📲 Instalación en tu iPhone con Sideloadly

1. Conecta tu iPhone por cable USB.
2. Abre **Sideloadly** en Windows.
3. Arrastra `Archivo.ipa` a Sideloadly.
4. Ingresa tu Apple ID y pulsa **Start**.
5. En tu iPhone: ve a **Ajustes > General > VPN y gestión de dispositivos** y pulsa **Confiar**.
