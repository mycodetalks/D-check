# ⚖️ D-Check: Anti-Discrimination Assistant

A professional mobile application built with Flutter designed to guide users through identifying, logging, and reporting legal discrimination incidents.

---

## 📱 App Screenshots


| Triage Flow | Legal Chat Support | Case Evidence |
| :-: | :-: | :-: |
| <img src="assets/triage_screen.png" width="240"> | <img src="assets/chat_screen.png" width="240"> | <img src="assets/evidence_screen.png" width="240"> |

---

## ✨ Features

- **Local RAG Support Engine**: Fast local search fallback covering legal foundations and documentation workflows.
- **Remote AI Model Integration**: Optional advanced deep analysis streaming via Hugging Face model endpoints.
- **Discrimination Ground Detection**: Auto-flags priority legal grounds (e.g., race, gender, disability) dynamically as users type.
- **Secure Architecture**: Environment variables remain strictly isolated locally using encrypted setups.

---

## 🛠️ Installation & Setup

Follow these quick setup instructions to build and test the project locally.

### 1. Prerequisites
Ensure you have the Flutter SDK installed on your system.
```bash
flutter doctor
```

### 2. Clone the Repository
```bash
git clone https://github.com
cd D-check
```

### 3. Setup Secrets Config
Create a `.env` file in the root directory and add your Hugging Face API credential:
```text
HUGGING_FACE_TOKEN=your_token_here
```

### 4. Install Dependencies & Run
```bash
flutter pub get
flutter run
```

<img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/5281e215-73e8-477c-879a-8e88d994faf0" />


