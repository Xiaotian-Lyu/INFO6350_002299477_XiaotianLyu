# HyperGarageSale (Flutter App)

A Flutter + Firebase-powered mobile marketplace app that allows users to post, browse, and preview second-hand listings with images.



---
## ✅ Project Overview

- This is the final project for INFO 6350
- Currently **only supports iOS**

- **Authentication**
  - Email/password registration and login
  - Anonymous login (for testing)
  - Auth status tracking via `authStateChanges`
  - Logout functionality

- **Post Management**
  - Create a new post with title, price, description, and up to 4 photos
  - Preview selected images before posting
  - View post details and enlarge photos in full screen
  - Edit and delete **only your own** posts (based on UID match)

- **Firebase Integration**
  - Firestore for post data storage (title, price, description, image URLs)
  - Firebase Storage for image uploads
  - Secure Firestore & Storage rules: only authenticated users can read/write

- **UI/UX**
  - Responsive layout with `SnackBar` feedback
  - Dynamic routing using `AuthGate` (login vs. post browsing)
  - Keyboard-aware layout to avoid button overlap
  - Clean, material design for both input and browsing experience
    
---


## 🎥 Demo Video

👉 [Click here to view the demo video](https://youtube.com/shorts/jJyI73QGyIA?feature=share)  

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



