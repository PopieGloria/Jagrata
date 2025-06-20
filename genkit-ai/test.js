import { categorizeIncident, generateSummary, ai } from './index.js';

async function testGeminiAPI() {
  console.log('🧪 Testing Gemini API integration...\n');

  try {
    // Test 1: Basic AI generation
    console.log('📝 Test 1: Basic AI Response');
    const { text } = await ai.generate('Explain how AI can help fight corruption in 2 sentences.');
    console.log('✅ Response:', text);
    console.log('');

    // Test 2: Incident categorization
    console.log('📝 Test 2: Incident Categorization');
    const incidentData = {
      description: 'A government official demanded a bribe of ₹5000 to approve my building permit. The officer said without this payment, my application would be delayed for months.',
      location: 'Mumbai Municipal Corporation',
      department: 'Building Permits'
    };

    const categorization = await categorizeIncident(incidentData);
    console.log('✅ Categorization Result:', JSON.stringify(categorization, null, 2));
    console.log('');

    // Test 3: Summary generation
    console.log('📝 Test 3: Summary Generation');
    const incident = {
      title: 'Bribery in Building Permit Process',
      description: incidentData.description,
      location: incidentData.location,
      date: new Date().toISOString(),
      category: 'Bribery'
    };

    const summary = await generateSummary({ incident });
    console.log('✅ Summary Result:', JSON.stringify(summary, null, 2));

    console.log('\n🎉 All tests passed! Genkit AI integration is working correctly.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('Full error:', error);
  }
}

// Run the tests
testGeminiAPI(); 