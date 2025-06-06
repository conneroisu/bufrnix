#!/usr/bin/env node

/**
 * Multi-Language Multi-Project Example - JavaScript Implementation
 * 
 * This example demonstrates how to use the generated protobuf code across
 * multiple services and packages in a large-scale system using JavaScript.
 */

import { readFileSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

// Get the directory of the current module
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Path to generated protobuf files
const protoGenPath = join(__dirname, '../../proto/gen');

// Dynamic import helper for protobuf modules
async function loadProtoModule(modulePath) {
  try {
    const fullPath = join(protoGenPath, modulePath);
    if (!existsSync(fullPath)) {
      console.warn(`Proto module not found: ${fullPath}`);
      return null;
    }
    
    // For this example, we'll simulate the protobuf usage
    // In a real implementation, you would import the actual generated JS files
    return {
      // Simulated protobuf module structure
      messages: {},
      enums: {},
      services: {}
    };
  } catch (error) {
    console.error(`Error loading proto module ${modulePath}:`, error.message);
    return null;
  }
}

class MultiProjectExample {
  constructor() {
    this.protoModules = new Map();
  }

  async initialize() {
    console.log('Multi-Language Multi-Project Example - JavaScript Implementation');
    console.log('================================================================');
    
    // Load protobuf modules (simulated for this example)
    await this.loadProtoModules();
    
    return this;
  }

  async loadProtoModules() {
    const modules = [
      'javascript/lib',
      'javascript/api/v1',
      'javascript/asr/v1',
      'javascript/edi/v1',
      'javascript/emb/v1',
      'javascript/img/v1',
      'javascript/llm/v1',
      'javascript/seg/v1',
      'javascript/tts/v1',
      'javascript/vari/v1',
      'javascript/vid/v1'
    ];

    for (const modulePath of modules) {
      const module = await loadProtoModule(modulePath);
      if (module) {
        this.protoModules.set(modulePath, module);
      }
    }

    console.log(`Loaded ${this.protoModules.size} protobuf modules`);
  }

  demonstrateLibraryTypes() {
    console.log('\n--- Library Types Demo ---');
    
    // Language code example (simulated)
    const preferredLang = 'LANGUAGE_EN';
    console.log(`Preferred Language: ${preferredLang}`);
    
    // Media types example (simulated)
    const imageSize = {
      width: 1920,
      height: 1080
    };
    console.log(`Image Size: ${imageSize.width}x${imageSize.height}`);
    
    const audioFormat = 'AUDIO_FORMAT_MP3';
    console.log(`Audio Format: ${audioFormat}`);
  }

  demonstrateAPIUsage() {
    console.log('\n--- API Usage Demo ---');
    
    // Example chat completion request (simulated structure)
    const chatReq = {
      model: 'gpt-4',
      messages: [
        {
          role: 'CHAT_MESSAGE_ROLE_USER',
          content: 'Hello, how are you?'
        }
      ],
      maxTokens: 100,
      temperature: 0.7
    };
    console.log(`Chat Request - Model: ${chatReq.model}, Messages: ${chatReq.messages.length}`);
    
    // Example image generation request
    const imageReq = {
      prompt: 'A futuristic cityscape at sunset',
      size: 'IMAGE_SIZE_1024X1024',
      n: 1
    };
    console.log(`Image Request - Prompt: ${imageReq.prompt}, Size: ${imageReq.size}`);
    
    // Example embedding request
    const embeddingReq = {
      model: 'text-embedding-ada-002',
      input: ['Hello world', 'How are you?']
    };
    console.log(`Embedding Request - Model: ${embeddingReq.model}, Inputs: ${embeddingReq.input.length}`);
  }

  demonstrateServiceIntegrations() {
    console.log('\n--- Service Integrations Demo ---');
    
    // ASR (Automatic Speech Recognition) example
    const asrReq = {
      model: 'whisper-1',
      language: 'en'
    };
    console.log(`ASR Request - Model: ${asrReq.model}, Language: ${asrReq.language}`);
    
    // Text-to-Speech example
    const ttsReq = {
      model: 'tts-1',
      input: 'Hello, this is a text-to-speech example',
      voice: 'VOICE_ALLOY'
    };
    console.log(`TTS Request - Model: ${ttsReq.model}, Voice: ${ttsReq.voice}`);
    
    // LLM completion example
    const llmReq = {
      model: 'gpt-3.5-turbo-instruct',
      prompt: 'Once upon a time',
      maxTokens: 50,
      temperature: 0.8
    };
    console.log(`LLM Request - Model: ${llmReq.model}, Max Tokens: ${llmReq.maxTokens}`);
    
    // Image processing example
    const imgReq = {
      prompt: 'Add a rainbow to this image',
      size: 'IMAGE_SIZE_512X512'
    };
    console.log(`Image Edit Request - Prompt: ${imgReq.prompt}, Size: ${imgReq.size}`);
    
    // Text editing example
    const editReq = {
      model: 'text-davinci-edit-001',
      input: 'What day of the wek is it?',
      instruction: 'Fix the spelling mistakes'
    };
    console.log(`Edit Request - Model: ${editReq.model}, Instruction: ${editReq.instruction}`);
    
    // Embedding example
    const embReq = {
      model: 'text-embedding-ada-002',
      input: ['Sample text for embedding']
    };
    console.log(`Embedding Request - Model: ${embReq.model}, Inputs: ${embReq.input.length}`);
    
    // Text segmentation example
    const segReq = {
      text: 'This is a sample text. It contains multiple sentences. We want to segment it.',
      model: 'sentence-segmenter'
    };
    console.log(`Segmentation Request - Model: ${segReq.model}, Text Length: ${segReq.text.length}`);
    
    // Video processing example
    const vidReq = {
      prompt: 'A time-lapse of a flower blooming',
      duration: 10
    };
    console.log(`Video Request - Prompt: ${vidReq.prompt}, Duration: ${vidReq.duration}s`);
    
    // Variation example
    const variReq = {
      input: 'Original text to create variations from',
      n: 3
    };
    console.log(`Variation Request - Input Length: ${variReq.input.length}, Variations: ${variReq.n}`);
  }

  demonstrateSerialization() {
    console.log('\n--- Serialization Demo ---');
    
    // Create a complex message (simulated)
    const originalReq = {
      model: 'gpt-4',
      messages: [
        {
          role: 'CHAT_MESSAGE_ROLE_USER',
          content: 'Hello, how are you?'
        },
        {
          role: 'CHAT_MESSAGE_ROLE_ASSISTANT',
          content: "I'm doing well, thank you for asking!"
        }
      ],
      maxTokens: 100,
      temperature: 0.7,
      topP: 0.9
    };
    
    // Simulate serialization to bytes
    const serialized = JSON.stringify(originalReq);
    console.log(`Serialized size: ${serialized.length} bytes`);
    
    // Simulate deserialization
    const reconstructed = JSON.parse(serialized);
    
    // Verify they're the same
    const isEqual = JSON.stringify(originalReq) === JSON.stringify(reconstructed);
    console.log(`Original and reconstructed are equal: ${isEqual}`);
    console.log(`Reconstructed model: ${reconstructed.model}`);
    console.log(`Reconstructed messages: ${reconstructed.messages.length}`);
  }

  demonstrateAsyncOperations() {
    console.log('\n--- Async Operations Demo ---');
    
    // Simulate async API calls
    const operations = [
      this.simulateAPICall('chat', 'gpt-4'),
      this.simulateAPICall('image', 'dall-e-3'),
      this.simulateAPICall('embedding', 'text-embedding-ada-002'),
      this.simulateAPICall('tts', 'tts-1'),
      this.simulateAPICall('asr', 'whisper-1')
    ];

    return Promise.all(operations)
      .then(results => {
        console.log('All operations completed:');
        results.forEach((result, index) => {
          console.log(`  ${index + 1}. ${result.service}: ${result.status} (${result.duration}ms)`);
        });
      })
      .catch(error => {
        console.error('Error in async operations:', error);
      });
  }

  async simulateAPICall(service, model) {
    const startTime = Date.now();
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, Math.random() * 100 + 50));
    
    const duration = Date.now() - startTime;
    
    return {
      service,
      model,
      status: 'success',
      duration
    };
  }

  async run() {
    await this.initialize();
    
    this.demonstrateLibraryTypes();
    this.demonstrateAPIUsage();
    this.demonstrateServiceIntegrations();
    this.demonstrateSerialization();
    
    await this.demonstrateAsyncOperations();
    
    console.log('\n--- Example Complete ---');
    console.log('This example demonstrates the structure and usage patterns');
    console.log('for a multi-language, multi-project protobuf system.');
    console.log('In a real implementation, you would use the actual generated');
    console.log('protobuf JavaScript modules from the proto/gen directory.');
  }
}

// Run the example
const example = new MultiProjectExample();
example.run().catch(console.error);