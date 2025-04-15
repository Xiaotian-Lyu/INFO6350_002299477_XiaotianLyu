# HyperGarageSale (Flutter App)

A Flutter + Firebase-powered mobile marketplace app that allows users to post, browse, and preview second-hand listings with images.



---
## ✅ Project Overview

- This is the final project for a Mobile App Development course
- Currently **only supports iOS**
- Backend integration includes **Firebase Authentication, Firestore, and Storage**
- Core features implemented: anonymous login, post creation with photos, listing browsing, post detail view

---


## 🎥 Demo Video

👉 [Click here to view the demo video](https://youtube.com/shorts/aBc9Vl4sr2w?feature=share)  

---



## Firebase Integration
All post data is stored in **Firebase Firestore**, and images are stored in **Firebase Storage**.

- Firestore Collection: `posts`
- Document Fields:
  - `title` (String)
  - `price` (String)
  - `description` (String)
  - `images` (List of image URLs)
  - `createdAt` (Timestamp)

When a user posts through the app, the data is automatically synced to Firebase.

<img width="1525" alt="截屏2025-04-14 22 31 22" src="https://github.com/user-attachments/assets/69cc841d-65f0-41ac-aed2-a79573a981e5" />
<img width="1533" alt="截屏2025-04-14 22 32 22" src="https://github.com/user-attachments/assets/484837d1-08a3-4ff8-8384-b60f6c2c151b" />


