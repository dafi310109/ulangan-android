# 🪙 Coin Flip Simulator - Neumorphic Soft UI

> **Flutter Speed Code Challenge**  
> **Nama Peserta**: Dafi Al Fajar  
> **Topik**: Coin Flip (Acak koin, tampilkan hasil, hitung kepala/ekor, catat streak)  
> **Gaya Desain**: Neumorphism (Soft UI) - *Ice Blue Palette*

---

## 📱 Tentang Proyek

Aplikasi **Coin Flip Simulator** ini dikembangkan menggunakan Flutter dengan menerapkan filosofi desain **Neumorphism (Soft UI)** yang modern, taktil, dan dinamis. Terinspirasi dari palet warna *Powder Ice-Blue* dengan bayangan ganda (*dual diffused shadows*), antarmuka piringan koin konsentris, serta kapsul kontrol melayang (*floating pill dock*).

Aplikasi ini memenuhi seluruh ketentuan praktikum:
1. **Menghasilkan sisi koin secara acak** dengan fisika putaran 3D dinamis dan proyeksi bayangan lantai realistis.
2. **Menampilkan hasil** secara instan dengan banner status adaptif ("Kepala" atau "Ekor").
3. **Menghitung jumlah kepala/ekor**, total lemparan, rasio persentase, dan bilah distribusi interaktif.
4. **Mencatat streak**: Streak saat ini beruntun dan rekor terpanjang sepanjang sesi.
5. **Fitur Pendukung Interaktif**:
   - **Mode Bebas (Free Flip)**: Ketuk koin atau tombol lempar.
   - **Mode Tebak (Prediction Mode)**: Prediksi sisi koin dengan pelacakan akurasi kemenangan dan selebrasi partikel confetti.
   - **Mode 2 Koin (Double Coin Flip)**: Simulasi dua koin sekaligus.
   - **Trending Material Selector**: Pilihan material koin (Emas, Perak, Perunggu).
   - **Tema Terang & Gelap Neumorphism**: Beralih tema secara mulus.
   - **Riwayat Lemparan (News Style)**: Log lemparan lengkap dengan waktu kejadian.

---

## 🎨 Desain & Arsitektur

- **Palet Warna**:
  - Background: `#D6E6F5` (Soft Ice-Blue)
  - Card: `#DCEAF7`
  - Bayangan Terang: `Colors.white (opacity 0.95)`
  - Bayangan Gelap: `#9CB8D4 (opacity 0.70)`
  - Aksen Tanda Tangan: `#E63946` (Ikon Hati Merah), `#2B5C8F` (Biru Utama), `#F5B041` (Emas Garuda)
- **Komponen Utama**:
  - `NeuBox`: Kontainer Neumorphic (flat, convex, concave, inset)
  - `NeuButton`: Tombol taktil dengan animasi depresan dan getaran haptic
  - `CoinWidget`: Render koin 3D dengan relief Garuda Pancasila dan 1000 Rupiah
  - `StatSummaryCard`: Kartu statistik bergaya playlist cover art

---

## 📂 Struktur Berkas

```
lib/
├── main.dart                      # Entry point, Outfit typography, theme switcher
├── theme/
│   └── neu_theme.dart             # Neumorphic tokens, dual shadow math, and gradients
├── models/
│   └── flip_record.dart           # History & guess record data model
├── widgets/
│   ├── neu_box.dart               # Universal Neumorphic container
│   ├── neu_button.dart            # Tactile press button
│   ├── neu_icon_button.dart       # Circular Neumorphic button
│   ├── coin_widget.dart           # 3D perspective coin & shadow
│   ├── stat_badge.dart            # Playlist-style stats & progress bar
│   └── confetti_particles.dart    # Celebration particle engine
└── screens/
    └── coin_flip_screen.dart      # Main screen layout and game logic
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK (>= 3.12.0)
- Google Chrome atau Windows Desktop target

### Menjalankan di Chrome
```bash
flutter run -d chrome
```

### Menjalankan di Windows Desktop
```bash
flutter run -d windows
```

### Menjalankan Pengujian Unit & Widget
```bash
flutter test
```
