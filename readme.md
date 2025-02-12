# Jagrata

Corruption remains a major challenge in governance, affecting transparency and public trust. Jagrata is a mobile-based anti-corruption platform that allows citizens to securely report bribery and misconduct by government officials. Reports are submitted with video, image, audio, and document evidence, and users are verified through *email and mobile authentication* to prevent misuse. The app features *multilingual support* and a *direct integration mechanism* with authorities for streamlined case resolution. By leveraging technology, *Jagrata* empowers citizens to take a stand against corruption while ensuring *privacy, security, and accountability*.

## Features

- **Secure Digital Reporting:** Users can submit evidence of corruption with end-to-end encryption.
- **AI-Powered Case Prioritization:** AI models classify case severity to ensure urgent matters receive immediate attention.
- **Multi-Language Support:** Automatic translation enables reporting in different languages.
- **Anonymous Reporting:** Protects whistleblowers' identities while ensuring their voices are heard.
- **Data Integrity & Confidentiality:** Robust security measures prevent tampering and unauthorized access.
- **Automated Routing:** Cases are categorized and sent to the relevant authorities for prompt action.
- **User-Friendly Interface:** Simple and intuitive UI for effortless case submission and tracking.
- **Firebase Integration:** Authentication and database management are implemented using Firebase.

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Firestore, Firebase Authentication
- **AI Integration:** Python, LLaMA/Mistral LLM (for classification & translation)
- **Cloud Storage:** Firebase Storage (for secure document handling)
- **Security:** Firebase Authentication, AES Encryption

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/jagrata.git
   cd jagrata
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Set up environment variables (create a `.env` file):
   ```env
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
   FIREBASE_PROJECT_ID=your_firebase_project_id
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## Future Enhancements

- Blockchain-based immutable records for enhanced transparency.
- Advanced AI models for detecting forged documents.
- Community engagement features for collective action.

## Contribution

Contributions are welcome! Feel free to open issues and submit pull requests.

## Presentation

The project presentation should contain the following sections:
- **Introduction**
- **Objective**
- **Timeline**
- **Features & Implementation**

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For inquiries, reach out via email: `your.email@example.com` or connect on [LinkedIn](https://linkedin.com/in/your-profile).
