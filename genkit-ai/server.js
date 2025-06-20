import express from 'express';
import cors from 'cors';
import { categorizeIncident, generateSummary, ai } from './index.js';
import config from './config.js';

const app = express();
const PORT = config.PORT;

// Middleware
app.use(express.json());
app.use(cors());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Jagrata AI Server is running',
    model: config.GEMINI_MODEL
  });
});

// Basic AI generation endpoint
app.post('/api/generate', async (req, res) => {
  try {
    const { prompt } = req.body;
    
    if (!prompt) {
      return res.status(400).json({ error: 'Prompt is required' });
    }

    // make a generation request
    const { text } = await ai.generate(prompt);

    res.json({
      success: true,
      response: text,
      model: config.GEMINI_MODEL
    });

  } catch (error) {
    console.error('AI Generation Error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to generate AI response',
      message: error.message 
    });
  }
});

// Incident categorization endpoint
app.post('/api/categorize', async (req, res) => {
  try {
    const { description, location, department } = req.body;
    
    if (!description) {
      return res.status(400).json({ error: 'Description is required' });
    }

    const result = await categorizeIncident({
      description,
      location: location || '',
      department: department || ''
    });

    res.json({
      success: true,
      categorization: result
    });

  } catch (error) {
    console.error('Categorization Error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to categorize incident',
      message: error.message 
    });
  }
});

// Summary generation endpoint
app.post('/api/summarize', async (req, res) => {
  try {
    const { incident } = req.body;
    
    if (!incident || !incident.description) {
      return res.status(400).json({ error: 'Incident with description is required' });
    }

    const result = await generateSummary({ incident });

    res.json({
      success: true,
      summary: result
    });

  } catch (error) {
    console.error('Summary Error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to generate summary',
      message: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Jagrata AI Server running on http://localhost:${PORT}`);
  console.log('📋 Available endpoints:');
  console.log('  GET  /health - Health check');
  console.log('  POST /api/generate - Basic AI generation');
  console.log('  POST /api/categorize - Incident categorization');
  console.log('  POST /api/summarize - Incident summary generation');
});

export default app; 