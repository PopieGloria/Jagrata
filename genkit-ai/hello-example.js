// import the Genkit and Google AI plugin libraries
import { gemini15Flash, googleAI } from '@genkit-ai/googleai';
import { genkit } from 'genkit';
import config from './config.js';

// Set the API key as environment variable
process.env.GOOGLE_GENAI_API_KEY = config.GOOGLE_GENAI_API_KEY;

// configure a Genkit instance
const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash, // set default model
});

const helloFlow = ai.defineFlow('helloFlow', async (name) => {
  // make a generation request
  const { text } = await ai.generate(`Hello Gemini, my name is ${name}. Tell me about Jagrata corruption reporting platform.`);
  console.log(text);
  return text;
});

// Test the flow
if (process.argv[2]) {
  helloFlow(process.argv[2]);
} else {
  helloFlow('Jagrata User');
}

export { helloFlow, ai }; 