# Jagrata AI Integration with Google Genkit

This directory contains the AI-powered features for the Jagrata corruption reporting platform using Google's Genkit framework and Gemini 2.0 Flash model.

## 🚀 Quick Start

### 1. Setup Configuration
```bash
# Copy the template and add your API key
cp config.template.js config.js
# Edit config.js and add your Google AI API key
```

### 2. Test the Integration
```bash
# Run from the root directory
npm run test-ai
```

### 3. Start the AI Server
```bash
# Start the AI API server
npm run start-ai
```

## 📋 Available Endpoints

Once the server is running on `http://localhost:3000`:

### Health Check
```bash
GET /health
```

### Basic AI Generation
```bash
POST /api/generate
Content-Type: application/json

{
  "prompt": "Your question or prompt here"
}
```

### Incident Categorization
```bash
POST /api/categorize
Content-Type: application/json

{
  "description": "Description of the corruption incident",
  "location": "Location (optional)",
  "department": "Department involved (optional)"
}
```

### Summary Generation
```bash
POST /api/summarize
Content-Type: application/json

{
  "incident": {
    "title": "Incident title",
    "description": "Detailed description",
    "location": "Location",
    "date": "Date",
    "category": "Category"
  }
}
```

## 🧪 Test Examples

### Test API with curl:
```bash
# Health check
curl http://localhost:3000/health

# Basic generation
curl -X POST http://localhost:3000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Explain corruption in 2 sentences"}'

# Categorize incident
curl -X POST http://localhost:3000/api/categorize \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Official demanded bribe for permit approval",
    "location": "Municipal Office",
    "department": "Building Permits"
  }'
```

## 🔧 Features

1. **AI-Powered Categorization**: Automatically categorizes corruption incidents by type and severity
2. **Smart Summarization**: Generates professional summaries for administrative review
3. **Department Routing**: Suggests appropriate departments to handle incidents
4. **RESTful API**: Easy integration with Flutter app or web interface
5. **Error Handling**: Robust error handling with fallback responses

## 🛠 Integration with Flutter

To integrate with your Flutter app, add HTTP requests to the running AI server:

```dart
// Example Flutter integration
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> categorizeIncident(String description) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/api/categorize'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'description': description,
      'location': location,
      'department': department,
    }),
  );
  
  return json.decode(response.body);
}
```

## 🔒 Security

- API key is stored in `config.js` (not committed to version control)
- Template file (`config.template.js`) is provided for setup
- Server includes CORS support for web integration
- Input validation on all endpoints

## 📁 File Structure

```
genkit-ai/
├── index.js              # Main Genkit flows and logic
├── server.js             # Express API server
├── test.js               # Test suite
├── config.js             # Configuration (not committed)
├── config.template.js    # Configuration template
└── README.md            # This file
```

## 🐛 Troubleshooting

1. **API Key Issues**: Ensure your Google AI API key is correctly set in `config.js`
2. **Schema Errors**: Make sure you have `zod` installed: `npm install zod`
3. **Server Won't Start**: Check if port 3000 is available or change PORT in config
4. **CORS Issues**: The server includes CORS middleware for web requests

## 🎯 Next Steps

1. Deploy the AI server to a cloud platform (Railway, Render, etc.)
2. Add authentication middleware
3. Implement rate limiting
4. Add logging and monitoring
5. Create more specialized AI flows for different corruption types 