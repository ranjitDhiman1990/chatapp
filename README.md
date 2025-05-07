# Simple Chat App (iOS)  

A lightweight, real-time chat application built with **SwiftUI** and **Firebase**, supporting one-on-one messaging with modern iOS features.  

## 📱 App Screenshots

<p float="left">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen1.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen2.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen3.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen4.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen5.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen6.png" width="250" height="480">
  <img src="https://raw.githubusercontent.com/ranjitDhiman1990/chatapp/main/screenshots/Screen7.png" width="250" height="480">
</p>

---

## 📁 Project Structure  

```bash
chatappdemo/
├── App/ # Core app setup
│ ├── AppDelegate.swift # App lifecycle
│ ├── AppSecrets # Sensitive configs (if any)
│
├── Core/ # Foundation layer
│ ├── ErrorHandler/ # Error management
│ ├── Router/ # Navigation logic
│ ├── Store/ # Data persistence
│ ├── Utils/ # Utilities
│
├── Features/ # Feature modules
│ ├── Authentication/ # Login/Signup flows
│ ├── Chat/ # 1:1 messaging
│ ├── ChatList/ # Recent conversations
│ ├── Onboarding/ # First-run experience
│ ├── Profile/ # User profile
│ ├── UsersList/ # User discovery
│
├── Services/ # Business logic
│ ├── DI/ # Dependency injection (Swinject)
│ ├── Models/ # Data models (User, Message, etc.)
│ ├── UIHelpers/ # Reusable UI components
│
├── SupportingFiles/ # Resources
│ ├── Assets.xcassets # App icons & images
│ ├── GoogleService-Info.plist # Firebase config
│ ├── Countries.json # Local data (if used)
│
└── Preview Content/ # Xcode previews
```

---

## Features  

✅ **Authentication**  
- Sign up/login via **Firebase Auth** (Google, Apple, or Mobile Number).  

✅ **Real-Time Messaging**  
- One-on-one chat with live updates.  
- Typing indicators.  
- Message timestamps & status (sent/delivered).  

✅ **Offline Support**  
- Last messages persist locally via `UserDefaults`.  

✅ **Chat List**  
- Displays recent conversations.  

---

## Technical Overview  

**Platform:** iOS 15.6+  
**Architecture:** MVVM  
**Dependency Injection:** Swinject  

### Dependencies  
| Purpose           | Library/Package |
|-------------------|-----------------|
| Real-Time Database | [Firebase Firestore](https://github.com/firebase/firebase-ios-sdk.git) |
| Image Caching      | [swiftui-cached-async-image](https://github.com/lorenzofiamingo/swiftui-cached-async-image) |
| Google Sign-In     | [GoogleSignIn-iOS](https://github.com/google/GoogleSignIn-iOS) |
| Image Storage      | [Cloudinary iOS](https://github.com/cloudinary/cloudinary_ios.git) |

---

## Installation  

1. Clone the repository:  
```bash
   git clone https://github.com/ranjitDhiman1990/chatapp.git
```
2. Navigate to the project:
```bash
   cd chatapp/chatappdemo
```
3. Install dependencies via Swift Package Manager (Xcode > File > Add Packages).
4. Add your GoogleService-Info.plist (Firebase config) to the project.
5. Build and run!

---

## Future Roadmap
🔜 Group Chats
🔜 Media Sharing (Images, Voice Notes)
🔜 Enhanced UI (Custom chat bubbles, animations)

