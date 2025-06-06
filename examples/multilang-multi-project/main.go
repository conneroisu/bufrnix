package main

import (
	"fmt"
	"log"

	// Generated protobuf packages
	libpb "github.com/pegwings/pegwings/proto/gen/go/lib"
	apipb "github.com/pegwings/pegwings/proto/gen/go/api/v1"
	asrpb "github.com/pegwings/pegwings/proto/gen/go/asr/v1"
	edipb "github.com/pegwings/pegwings/proto/gen/go/edi/v1"
	embpb "github.com/pegwings/pegwings/proto/gen/go/emb/v1"
	imgpb "github.com/pegwings/pegwings/proto/gen/go/img/v1"
	llmpb "github.com/pegwings/pegwings/proto/gen/go/llm/v1"
	segpb "github.com/pegwings/pegwings/proto/gen/go/seg/v1"
	ttspb "github.com/pegwings/pegwings/proto/gen/go/tts/v1"
	varipb "github.com/pegwings/pegwings/proto/gen/go/vari/v1"
	vidpb "github.com/pegwings/pegwings/proto/gen/go/vid/v1"
)

func main() {
	fmt.Println("Multi-Language Multi-Project Example - Go Implementation")
	fmt.Println("========================================================")

	// Demonstrate using shared library types
	demonstrateLibraryTypes()

	// Demonstrate API usage examples
	demonstrateAPIUsage()

	// Demonstrate service integrations
	demonstrateServiceIntegrations()
}

func demonstrateLibraryTypes() {
	fmt.Println("\n--- Library Types Demo ---")

	// Language code example
	preferredLang := libpb.LanguageCode_LANGUAGE_EN
	fmt.Printf("Preferred Language: %s\n", preferredLang.String())

	// Media types example
	imageSize := &libpb.ImageSize{
		Width:  1920,
		Height: 1080,
	}
	fmt.Printf("Image Size: %dx%d\n", imageSize.Width, imageSize.Height)

	audioFormat := libpb.AudioFormat_AUDIO_FORMAT_MP3
	fmt.Printf("Audio Format: %s\n", audioFormat.String())
}

func demonstrateAPIUsage() {
	fmt.Println("\n--- API Usage Demo ---")

	// Example chat completion request
	chatReq := &apipb.CreateChatCompletionRequest{
		Model: "gpt-4",
		Messages: []*apipb.ChatCompletionRequestMessage{
			{
				Role:    apipb.ChatMessageRole_CHAT_MESSAGE_ROLE_USER,
				Content: "Hello, how are you?",
			},
		},
		MaxTokens:   100,
		Temperature: 0.7,
	}
	fmt.Printf("Chat Request - Model: %s, Messages: %d\n", chatReq.Model, len(chatReq.Messages))

	// Example image generation request
	imageReq := &apipb.CreateImageRequest{
		Prompt: "A futuristic cityscape at sunset",
		Size:   apipb.ImageSize_IMAGE_SIZE_1024X1024,
		N:      1,
	}
	fmt.Printf("Image Request - Prompt: %s, Size: %s\n", imageReq.Prompt, imageReq.Size.String())

	// Example embedding request
	embeddingReq := &apipb.CreateEmbeddingRequest{
		Model: "text-embedding-ada-002",
		Input: []string{"Hello world", "How are you?"},
	}
	fmt.Printf("Embedding Request - Model: %s, Inputs: %d\n", embeddingReq.Model, len(embeddingReq.Input))
}

func demonstrateServiceIntegrations() {
	fmt.Println("\n--- Service Integrations Demo ---")

	// ASR (Automatic Speech Recognition) example
	asrReq := &asrpb.CreateTranscriptionRequest{
		Model:    "whisper-1",
		Language: "en",
	}
	fmt.Printf("ASR Request - Model: %s, Language: %s\n", asrReq.Model, asrReq.Language)

	// Text-to-Speech example
	ttsReq := &ttspb.CreateSpeechRequest{
		Model: "tts-1",
		Input: "Hello, this is a text-to-speech example",
		Voice: ttspb.Voice_VOICE_ALLOY,
	}
	fmt.Printf("TTS Request - Model: %s, Voice: %s\n", ttsReq.Model, ttsReq.Voice.String())

	// LLM completion example
	llmReq := &llmpb.CreateCompletionRequest{
		Model:       "gpt-3.5-turbo-instruct",
		Prompt:      "Once upon a time",
		MaxTokens:   50,
		Temperature: 0.8,
	}
	fmt.Printf("LLM Request - Model: %s, Max Tokens: %d\n", llmReq.Model, llmReq.MaxTokens)

	// Image processing example
	imgReq := &imgpb.CreateImageEditRequest{
		Prompt: "Add a rainbow to this image",
		Size:   imgpb.ImageSize_IMAGE_SIZE_512X512,
	}
	fmt.Printf("Image Edit Request - Prompt: %s, Size: %s\n", imgReq.Prompt, imgReq.Size.String())

	// Text editing example
	editReq := &edipb.CreateEditRequest{
		Model:       "text-davinci-edit-001",
		Input:       "What day of the wek is it?",
		Instruction: "Fix the spelling mistakes",
	}
	fmt.Printf("Edit Request - Model: %s, Instruction: %s\n", editReq.Model, editReq.Instruction)

	// Embedding example
	embReq := &embpb.CreateEmbeddingRequest{
		Model: "text-embedding-ada-002",
		Input: []string{"Sample text for embedding"},
	}
	fmt.Printf("Embedding Request - Model: %s, Inputs: %d\n", embReq.Model, len(embReq.Input))

	// Text segmentation example
	segReq := &segpb.CreateSegmentationRequest{
		Text:  "This is a sample text. It contains multiple sentences. We want to segment it.",
		Model: "sentence-segmenter",
	}
	fmt.Printf("Segmentation Request - Model: %s, Text Length: %d\n", segReq.Model, len(segReq.Text))

	// Video processing example
	vidReq := &vidpb.CreateVideoRequest{
		Prompt:   "A time-lapse of a flower blooming",
		Duration: 10,
	}
	fmt.Printf("Video Request - Prompt: %s, Duration: %ds\n", vidReq.Prompt, vidReq.Duration)

	// Variation example
	variReq := &varipb.CreateVariationRequest{
		Input: "Original text to create variations from",
		N:     3,
	}
	fmt.Printf("Variation Request - Input Length: %d, Variations: %d\n", len(variReq.Input), variReq.N)
}

func init() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
}