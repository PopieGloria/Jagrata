// import the Genkit and Google AI plugin libraries
import { gemini15Flash, googleAI } from '@genkit-ai/googleai';
import { genkit } from 'genkit';
import { z } from 'zod';
import config from './config.js';

// Set the API key as environment variable
process.env.GOOGLE_GENAI_API_KEY = config.GOOGLE_GENAI_API_KEY;

// configure a Genkit instance
const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash, // set default model
});

// Define a flow for incident categorization
const categorizeIncident = ai.defineFlow('categorizeIncident', async (input) => {
  const prompt = `
  Analyze this corruption incident report and provide:
  1. Category (e.g., bribery, misuse of funds, nepotism, etc.)
  2. Severity level (low, medium, high, critical)
  3. Brief summary
  4. Most appropriate department to handle this

  Incident Details:
  Description: ${input.description}
  Location: ${input.location || 'Not specified'}
  Reported Department: ${input.department || 'Not specified'}

  Respond in JSON format with keys: category, severity, summary, suggestedDepartment
  `;

  // make a generation request
  const { text } = await ai.generate(prompt);
  
  try {
    return JSON.parse(text);
  } catch (error) {
    // Fallback if JSON parsing fails
    return {
      category: 'General Corruption',
      severity: 'medium',
      summary: text.substring(0, 200),
      suggestedDepartment: input.department || 'ULB'
    };
  }
});

// Define a flow for generating incident summaries
const generateSummary = ai.defineFlow('generateSummary', async (input) => {
  const incident = input.incident;
  const prompt = `
  Create a concise administrative summary for this corruption incident:
  
  Title: ${incident.title || 'Corruption Report'}
  Description: ${incident.description}
  Location: ${incident.location || 'Not specified'}
  Date: ${incident.date || 'Not specified'}
  Category: ${incident.category || 'Not specified'}
  
  Generate a professional summary suitable for official review.
  `;

  // make a generation request
  const { text } = await ai.generate(prompt);

  return {
    summary: text,
    generatedAt: new Date().toISOString()
  };
});

export {
  categorizeIncident,
  generateSummary,
  ai
}; 