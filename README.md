# Lucid State App (Flutter)

Project ini adalah frontend Lucid State berbasis Flutter untuk membantu pelacakan aktivitas dan peningkatan self-awareness.

## Prasyarat

- Flutter SDK sudah terpasang (`flutter --version`)
- Chrome / Edge (untuk jalur development web)
- Android SDK + Android Studio (untuk build APK Android)
- JDK 17 (untuk Android build tools)

## Inisialisasi Project

Project ini sudah diinisialisasi menggunakan:

```bash
flutter create . --project-name lucid_state_app --org com.lucidstate
```

## Struktur Project

Fokus struktur aplikasi ada di folder `lib`:

```text
lib/
	main.dart
	app/
		app.dart
		theme/
			app_theme.dart
	core/
		constants/
			app_strings.dart
	features/
		home/
			presentation/
				pages/
					home_page.dart
```

Ringkasnya:

- `main.dart`: entry point aplikasi
- `app/`: konfigurasi level aplikasi (MaterialApp, theme)
- `core/`: shared constants/util lintas fitur
- `features/`: modul per fitur (saat ini `home`)

## Jalankan Cepat (Web)

Langkah ini paling cepat untuk development awal.

1. Ambil dependency:

```bash
flutter pub get
```

2. Jalankan di browser:

```bash
flutter run -d chrome
```

Alternatif browser Edge:

```bash
flutter run -d edge
```

## Jalankan Android (Saat Toolchain Siap)

Jika ingin run/build Android, pastikan Android toolchain sudah beres.

1. Set `JAVA_HOME` ke JDK 17 (PowerShell, sementara per sesi):

```powershell
$env:JAVA_HOME = "C:\Path\To\JDK-17"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

2. Accept Android licenses:

```bash
flutter doctor --android-licenses
```

3. Cek status environment:

```bash
flutter doctor
```

4. Jalankan di emulator/device Android:

```bash
flutter run -d <android_device_id>
```

## Build APK Android

1. Build release APK:

```bash
flutter build apk
```

2. Lokasi output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Untuk build debug APK:

```bash
flutter build apk --debug
```

## Referensi Device

List device yang tersedia:

```bash
flutter devices
```

Jika ada lebih dari satu device, pilih pakai `-d`:

```bash
flutter run -d <device_id>
```

Contoh Windows desktop (butuh Visual Studio C++ workload):

```bash
flutter run -d windows
```

Contoh Android emulator:

```bash
flutter run -d emulator-5554
```

## Validasi Cepat

```bash
flutter analyze
flutter test
```

## Catatan Pengembangan

- Untuk hot reload saat `flutter run` aktif, tekan `r`
- Untuk hot restart, tekan `R`
- Untuk keluar dari proses run, tekan `q`
