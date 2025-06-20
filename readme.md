# **Jagrata – A Secure AI-Powered Platform for Corruption Reporting**  

Jagrata is a **secure, AI-driven corruption reporting platform** that enables citizens to **anonymously report corruption cases** with supporting evidence. It ensures **efficient case management, transparency, and accountability** by leveraging AI for report categorization and summarization.  

## 🚀 **Features**  

- **Secure Complaint Submission** – Users can report incidents with images, videos, and documents.  
- **AI-Powered Categorization** – Automatically classifies reports based on severity and department.  
- **AI-Generated Summaries** – Provides concise summaries for quick assessment by officials.  
- **Admin Panel** – Enables authorities to view, manage, and resolve complaints.  
- **Role-Based Access** – Only relevant departments (ULB, Central Vigilance, State Vigilance, Chief Vigilance Officer) can access specific reports.  
- **Email Verification** – Ensures secure authentication using Firebase Authentication.  
- **Real-Time Status Tracking** – Users get updates on complaint progress.  
- **Cross-Platform Accessibility** – Fully deployed on **Vercel**, making it accessible on mobile and web.  

## 🛠 **Tech Stack**  

- **Frontend** – Flutter (Web & Mobile)  
- **Backend** – Firebase Firestore (NoSQL Database)  
- **Authentication** – Firebase Authentication (Email Verification)  
- **AI Model** – Gemini 2.0 Flash for Categorization & Summarization  
- **Deployment** – Vercel for Web Accessibility  

## 📌 **Installation & Setup**  

### **Prerequisites**  
Ensure you have the following installed:  
- **Flutter SDK** ([Download Flutter](https://flutter.dev/docs/get-started/install))  
- **Firebase CLI** ([Setup Firebase](https://firebase.google.com/docs/cli))  
- **Dart SDK**  

### **Steps to Run Locally**  

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/your-username/jagrata.git
   cd jagrata
   ```

2. **Set Up Firebase Configuration**  
   ```bash
   # Run the setup script to create Firebase config files from templates
   ./setup_firebase.sh
   
   # Or manually copy template files:
   # cp lib/firebase_options.template.dart lib/firebase_options.dart
   # cp lib/firebase_options_web.template.dart lib/firebase_options_web.dart
   # cp lib/firebase_options_ios.template.dart lib/firebase_options_ios.dart
   ```
   
   **⚠️ Important:** You need to replace the placeholder values in these files with your actual Firebase configuration. See `FIREBASE_SETUP.md` for detailed instructions.

3. **Install Dependencies**  
   ```bash
   flutter pub get
   ```

4. **Run the App**  
   ```bash
   flutter run
   ```

5. **Deploy Admin Panel** (Optional, for testing)  
   ```bash
   vercel deploy
   ```

### **🔐 Security & GitHub Setup**

This repository uses a secure setup to protect Firebase API keys and sensitive configuration:

- **Firebase configuration files** are **not included** in the repository
- Template files (`.template.dart`) are provided instead
- Actual configuration files are **automatically ignored** by Git
- Use `FIREBASE_SETUP.md` for complete setup instructions
- The `setup_firebase.sh` script helps create configuration files quickly

**Before committing to GitHub:**
1. Ensure your actual Firebase configuration files are not committed
2. Only commit the template files and setup scripts
3. The `.gitignore` file is configured to protect sensitive data

## 📷 **Screenshots**  

<p align="center">
  <img src="https://github.com/user-attachments/assets/516e0c10-e450-4509-a16f-ef47fd0a2f1b" width="250">
  <img src="https://github.com/user-attachments/assets/d03c8a21-134c-4877-8b96-ef558240917b" width="250">
  <img src="https://github.com/user-attachments/assets/d7497b93-7f46-4642-89ce-b5145aff8a57" width="250">
  <img src="https://github.com/user-attachments/assets/7e578172-1fc6-43e2-bb3f-995a44e1a115" width="250">
  <img src="https://github.com/user-attachments/assets/8a39ad7a-b3df-4204-acdc-a10a1e6c7f3a" width="250">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/89721d3e-f8b4-4a0d-9fb8-7b879cd884bb" width="250">
  <img src="https://github.com/user-attachments/assets/2bf99eda-e207-4064-a1ad-90aa34cb516a" width="250">
  <img src="https://github.com/user-attachments/assets/9bddb6f2-6186-4f1a-8c57-a0d4239bb86e" width="250">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/0ca84295-b689-4e4c-9b8e-968ffb0c2ebc" width="250">
  <img src="https://github.com/user-attachments/assets/d4080027-d90f-474d-8e4f-af09526c4b78" width="250">
  <img src="https://github.com/user-attachments/assets/c8810a00-f804-4bbb-848b-a874a566a5bc" width="250">
</p>


## 📌 **Future Enhancements**  

- **Government Collaboration** – Direct integration with e-governance platforms.  
- **Advanced AI Features** – Improved severity detection and fraud prevention.  
- **Blockchain-Based Integrity** – Ensuring tamper-proof complaint records.  
- **Multilingual Support** – Expanding accessibility across India.  

## 📜 **License**  

This project is licensed under the **MIT License** – feel free to contribute and improve!  

## 🤝 **Contributors**  

- **Arfan MT**  
- **Navaneeth Nandakumar**  
- **Syed Farhan PN**  
- **Thoufeer MA**  

We welcome **contributions**! If you’d like to improve Jagrata, feel free to fork the repo and submit a pull request.  

