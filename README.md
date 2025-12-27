<p align="center">
  <img src="assets/icons/app_icon.png" alt="Secure Ledger Logo" width="120" height="120">
</p>

<h1 align="center">📒 Secure Ledger</h1>

<p align="center">
  <strong>Offline-First Business Ledger with Military-Grade Encryption</strong>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey" alt="Platform"></a>
  <a href="#"><img src="https://img.shields.io/github/stars/Mohammad007/offline_khatabook_app?style=social" alt="Stars"></a>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-screenshots">Screenshots</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-contributing">Contributing</a>
</p>

---

## 🎯 Overview

**Secure Ledger** is a production-ready, offline-first Flutter application designed for small businesses and freelancers to manage their customer transactions, track payments, and maintain accurate financial records — all without requiring an internet connection.

Built with security as a priority, all data is encrypted using **SQLCipher** (AES-256) and protected with PIN + Biometric authentication.

> 💡 *Perfect for shopkeepers, freelancers, and small business owners who need a reliable, secure, and offline solution for managing customer ledgers.*

---

## ✨ Features

### 🔐 Security & Privacy
- **PIN + Biometric Authentication** — Secure app access with 4-digit PIN and fingerprint/Face ID
- **AES-256 Encryption** — All data encrypted at rest using SQLCipher
- **Auto-Lock** — App automatically locks when backgrounded
- **Reset via OTP** — Secure PIN recovery with simulated OTP verification
- **No Cloud Dependency** — Your data stays on your device

### 📊 Core Functionality
- **Customer Management** — Add, edit, and organize customers with favorites
- **Transaction Tracking** — Record "You Gave" and "You Got" transactions
- **Real-time Balances** — Instant calculation of receivables and payables
- **Smart Search** — Filter customers by name or mobile number
- **Transaction History** — Complete audit trail with timestamps

### 📈 Analytics & Reports
- **Dashboard Overview** — Quick stats for total receivables/payables
- **Period-based Reports** — Daily, weekly, monthly, yearly analytics
- **Top Customers** — Identify your most active customers
- **Cash Flow Visualization** — Visual representation of money flow
- **Export Reports** — Generate reports for record-keeping

### 🔔 Smart Features
- **Payment Reminders** — Schedule reminders for pending payments
- **Recurring Reminders** — Set up weekly/monthly payment alerts
- **Quick Notes** — Jot down business notes with color coding
- **Categories** — Organize transactions by type (Sales, Purchase, Loan, etc.)
- **Favorites** — Star important customers for quick access

### 💾 Data Management
- **Encrypted Backup** — Export encrypted backup files
- **Restore Functionality** — Seamlessly restore from backup
- **Data Integrity** — ACID-compliant SQLite database

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/home.png" width="200" alt="Home Screen">
  <img src="screenshots/customer_detail.png" width="200" alt="Customer Detail">
  <img src="screenshots/reports.png" width="200" alt="Reports">
  <img src="screenshots/reminders.png" width="200" alt="Reminders">
</p>

<p align="center">
  <img src="screenshots/categories.png" width="200" alt="Categories">
  <img src="screenshots/notes.png" width="200" alt="Notes">
  <img src="screenshots/settings.png" width="200" alt="Settings">
  <img src="screenshots/lock.png" width="200" alt="Lock Screen">
</p>

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/secure-ledger.git
   cd secure-ledger
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Database & Riverpod)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a feature-first folder structure:

```
lib/
├── core/                          # Shared utilities & config
│   ├── constants/                 # App colors, strings, dimensions
│   ├── router/                    # GoRouter navigation configuration
│   ├── services/                  # Security, backup services
│   ├── theme/                     # Material 3 theming
│   └── widgets/                   # Reusable UI components
│
├── data/                          # Data layer
│   └── local/
│       └── db/                    # Drift database & DAOs
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication (PIN, biometric, onboarding)
│   │   ├── logic/                 # Riverpod providers
│   │   └── presentation/          # UI screens
│   │
│   ├── dashboard/                 # Home screen & customer list
│   ├── ledger/                    # Transaction management
│   ├── settings/                  # App settings & PIN change
│   ├── reports/                   # Analytics & reporting
│   ├── reminders/                 # Payment reminders
│   ├── categories/                # Transaction categories
│   └── notes/                     # Quick notes
│
└── main.dart                      # App entry point
```

### Design Patterns Used

| Pattern | Implementation |
|---------|----------------|
| **Repository Pattern** | Database abstraction layer |
| **Provider Pattern** | Riverpod for state management |
| **Observer Pattern** | Reactive streams with Drift |
| **Factory Pattern** | Database connection setup |
| **Singleton** | Database instance management |

---

## 🛠️ Tech Stack

### Core Framework
| Technology | Purpose |
|------------|---------|
| ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) | Cross-platform UI framework |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) | Programming language |

### State Management & Navigation
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | Reactive state management |
| `riverpod_annotation` | Code generation for providers |
| `go_router` | Declarative routing |

### Database & Storage
| Package | Purpose |
|---------|---------|
| `drift` | Type-safe SQLite wrapper |
| `sqlcipher_flutter_libs` | AES-256 database encryption |
| `flutter_secure_storage` | Encrypted key-value storage |
| `path_provider` | File system access |

### Security & Authentication
| Package | Purpose |
|---------|---------|
| `local_auth` | Biometric authentication |
| `crypto` | Cryptographic functions |
| `pointycastle` | PIN hashing (PBKDF2) |

### UI & Design
| Package | Purpose |
|---------|---------|
| `google_fonts` | Typography (Inter font) |
| `gap` | Spacing widgets |
| `pinput` | PIN input fields |
| `intl` | Date/number formatting |

---

## 📊 Database Schema

```sql
-- Core Tables
Customers (id, name, mobile, email, address, notes, avatarColor, isFavorite, createdAt)
Transactions (id, customerId, amount, isCredit, notes, categoryId, date, isDeleted)
Categories (id, name, icon, color, isSystem)
Reminders (id, customerId, amount, message, reminderDate, isCompleted, isRecurring)
QuickNotes (id, content, color, isPinned, createdAt)
BusinessProfiles (id, businessName, ownerName, mobile, email, gstNumber, upiId)
ActivityLogs (id, action, entityType, entityId, details, timestamp)
```

---

## 🔒 Security Implementation

### Encryption Flow
```
User PIN → PBKDF2 (10,000 iterations) → Derived Key → SQLCipher AES-256
```

### Authentication Flow
```
App Launch → Check PIN exists? 
  → No  → Onboarding → Mobile OTP → Set PIN → Dashboard
  → Yes → Lock Screen → PIN/Biometric → Dashboard
```

### Data Protection
- ✅ All database fields encrypted at rest
- ✅ PIN stored as salted hash (never plaintext)
- ✅ Biometric data handled by OS secure enclave
- ✅ Backup files encrypted with user PIN
- ✅ Auto-lock on app background

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Generate code coverage
flutter test --coverage
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Drift](https://drift.simonbinder.eu/) for type-safe database operations
- [Riverpod](https://riverpod.dev/) for reactive state management
- [SQLCipher](https://www.zetetic.net/sqlcipher/) for database encryption

---

## 📬 Contact

**Your Name** - [@Mohammad Bilal](https://www.linkedin.com/in/mohammad-bilal-b98a42105/)

Project Link: [https://github.com/Mohammad007/offline_khatabook_app](https://github.com/Mohammad007/offline_khatabook_app)

---

<p align="center">
  Made with ❤️ and Flutter
</p>

<p align="center">
  <a href="#-secure-ledger">Back to top ⬆️</a>
</p>
