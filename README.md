# 📱 Pokédex hecha en Flutter

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange)
![Open Source](https://img.shields.io/badge/Open%20Source-GitHub-black)

![GitHub stars](https://img.shields.io/github/stars/samudev4/DexHub?style=social)
![GitHub forks](https://img.shields.io/github/forks/samudev4/DexHub?style=social)
![Last Commit](https://img.shields.io/github/last-commit/samudev4/DexHub)
![Issues](https://img.shields.io/github/issues/samudev4/DexHub)

Una **Pokédex hecha en Flutter** que consume datos de **PokeAPI**, permite **registro/login con Firebase**, y guarda tus **Pokémon favoritos** en la nube.  
Incluye **modo oscuro** y es un proyecto **Open Source**.

---

## 📌 Contenido
- [✨ Características](#-características)
- [🧰 Tecnologías](#-tecnologías)
- [📸 Capturas](#-capturas)
- [✅ Requisitos](#-requisitos)
- [🚀 Instalación y ejecución](#-instalación-y-ejecución)
- [🔥 Configuración de Firebase](#-configuración-de-firebase)
- [📁 Estructura del proyecto](#-estructura-del-proyecto)
- [🗺️ Roadmap](#️-roadmap)
- [🤝 Contribuir](#-contribuir)
- [📄 Licencia](#-licencia)
- [🧾 Créditos](#-créditos)

---

## ✨ Características

- ✅ Registro e inicio de sesión con **correo + contraseña**
- ✅ Backend con **Firebase** (Auth + base de datos para favoritos)
- ✅ Datos de Pokémon obtenidos desde **PokeAPI**
- ✅ Vista detallada del Pokémon (stats, tipos, etc.)
- ✅ Sistema de **favoritos por usuario**
- ✅ **Modo oscuro / claro**
- ✅ Proyecto **Open Source**

---

## 🧰 Tecnologías

- **Flutter / Dart**
- **Firebase Authentication**
- **Cloud Firestore** (o Realtime Database según implementación)
- **PokeAPI** (fuente de datos)

---

## 📸 Capturas

| Pantalla | Claro | Modo oscuro |
|---------|-------|-------------|
| Home | ![Home](screenshots/home.png) | ![Home (Modo oscuro)](screenshots/home_dark.png) |
| Detalles | ![Detalles](screenshots/details.png) | ![Detalles (Modo oscuro)](screenshots/details_dark.png) |
| Detalles 2 | ![Detalles 2](screenshots/details2.png) | ![Detalles 2 (Modo oscuro)](screenshots/details2_dark.png) |
| Detalles 3 | ![Detalles 3](screenshots/details3.png) | ![Detalles 3 (Modo oscuro)](screenshots/details3_dark.png) |
| Regiones | ![Regiones](screenshots/regions.png) | ![Regiones (Modo oscuro)](screenshots/regions_dark.png) |
| Favoritos | ![Favoritos](screenshots/favorites.png) | ![Favoritos (Modo oscuro)](screenshots/favorites_dark.png) |
| Cuenta | ![Cuenta](screenshots/account.png) | ![Cuenta (Modo oscuro)](screenshots/account_dark.png) |
| Cuenta 2 | ![Cuenta 2](screenshots/account2.png) | ![Cuenta 2 (Modo oscuro)](screenshots/account2_dark.png) |

---

## ✅ Requisitos

- Flutter SDK instalado
- Dart instalado
- Android Studio / VSCode
- Emulador o dispositivo físico
- Cuenta Firebase (para Auth + DB)

---

## 🚀 Instalación y ejecución

### 1) Clonar el repositorio
```bash
git clone https://github.com/samudev4/DexHub.git
cd DexHub
```

### 2) Instalar dependencias
```bash
flutter pub get
```

### 3) Ejecutar
```bash
flutter run
```

---

## 🔥 Configuración de Firebase

### ⚠️ Este repo NO incluye los archivos de configuración de Firebase por seguridad:

> - android/app/google-services.json
> - ios/Runner/GoogleService-Info.plist

### Opción recomendada: FlutterFire CLI

### 1) Instalar
```bash
dart pub global activate flutterfire_cli
```
### 2) Login
```bash
firebase login
```

### 3) Configurar
```bash
flutterfire configure
```