#!/usr/bin/env python3
"""
Multi-Language Multi-Project Example - Python Implementation

This example demonstrates how to use the generated protobuf code across
multiple services and packages in a large-scale system.
"""

import sys
import os

# Add the generated protobuf directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../proto/gen/python'))

# Import generated protobuf modules
try:
    from language.v1 import lang_pb2 as lib_lang
    from media.v1 import media_pb2 as lib_media
    from api.v1 import api_pb2 as api
    from asr.v1 import asr_pb2 as asr
    from edi.v1 import edit_pb2 as edit
    from emb.v1 import emb_pb2 as emb
    from img.v1 import img_pb2 as img
    from llm.v1 import llm_pb2 as llm
    from seg.v1 import seg_pb2 as seg
    from tts.v1 import tts_pb2 as tts
    from vari.v1 import vari_pb2 as vari
    from vid.v1 import vid_pb2 as vid
except ImportError as e:
    print(f"Error importing protobuf modules: {e}")
    print("Make sure to run 'nix build' first to generate the protobuf code.")
    sys.exit(1)


def main():
    """Main function demonstrating multi-service protobuf usage."""
    print("Multi-Language Multi-Project Example - Python Implementation")
    print("=" * 60)
    
    # Demonstrate using shared library types
    demonstrate_library_types()
    
    # Demonstrate API usage examples
    demonstrate_api_usage()
    
    # Demonstrate service integrations
    demonstrate_service_integrations()


def demonstrate_library_types():
    """Demonstrate usage of shared library types."""
    print("\n--- Library Types Demo ---")
    
    # Language code example
    preferred_lang = lib_lang.LanguageCode.LANGUAGE_EN
    print(f"Preferred Language: {lib_lang.LanguageCode.Name(preferred_lang)}")
    
    # Media types example
    image_size = lib_media.ImageSize(width=1920, height=1080)
    print(f"Image Size: {image_size.width}x{image_size.height}")
    
    audio_format = lib_media.AudioFormat.AUDIO_FORMAT_MP3
    print(f"Audio Format: {lib_media.AudioFormat.Name(audio_format)}")


def demonstrate_api_usage():
    """Demonstrate main API usage patterns."""
    print("\n--- API Usage Demo ---")
    
    # Example chat completion request
    chat_req = api.CreateChatCompletionRequest(
        model="gpt-4",
        messages=[
            api.ChatCompletionRequestMessage(
                role=api.ChatMessageRole.CHAT_MESSAGE_ROLE_USER,
                content="Hello, how are you?"
            )
        ],
        max_tokens=100,
        temperature=0.7
    )
    print(f"Chat Request - Model: {chat_req.model}, Messages: {len(chat_req.messages)}")
    
    # Example image generation request
    image_req = api.CreateImageRequest(
        prompt="A futuristic cityscape at sunset",
        size=api.ImageSize.IMAGE_SIZE_1024X1024,
        n=1
    )
    print(f"Image Request - Prompt: {image_req.prompt}, Size: {api.ImageSize.Name(image_req.size)}")
    
    # Example embedding request
    embedding_req = api.CreateEmbeddingRequest(
        model="text-embedding-ada-002",
        input=["Hello world", "How are you?"]
    )
    print(f"Embedding Request - Model: {embedding_req.model}, Inputs: {len(embedding_req.input)}")


def demonstrate_service_integrations():
    """Demonstrate integration with various specialized services."""
    print("\n--- Service Integrations Demo ---")
    
    # ASR (Automatic Speech Recognition) example
    asr_req = asr.CreateTranscriptionRequest(
        model="whisper-1",
        language="en"
    )
    print(f"ASR Request - Model: {asr_req.model}, Language: {asr_req.language}")
    
    # Text-to-Speech example
    tts_req = tts.CreateSpeechRequest(
        model="tts-1",
        input="Hello, this is a text-to-speech example",
        voice=tts.Voice.VOICE_ALLOY
    )
    print(f"TTS Request - Model: {tts_req.model}, Voice: {tts.Voice.Name(tts_req.voice)}")
    
    # LLM completion example
    llm_req = llm.CreateCompletionRequest(
        model="gpt-3.5-turbo-instruct",
        prompt="Once upon a time",
        max_tokens=50,
        temperature=0.8
    )
    print(f"LLM Request - Model: {llm_req.model}, Max Tokens: {llm_req.max_tokens}")
    
    # Image processing example
    img_req = img.CreateImageEditRequest(
        prompt="Add a rainbow to this image",
        size=img.ImageSize.IMAGE_SIZE_512X512
    )
    print(f"Image Edit Request - Prompt: {img_req.prompt}, Size: {img.ImageSize.Name(img_req.size)}")
    
    # Text editing example
    edit_req = edit.CreateEditRequest(
        model="text-davinci-edit-001",
        input="What day of the wek is it?",
        instruction="Fix the spelling mistakes"
    )
    print(f"Edit Request - Model: {edit_req.model}, Instruction: {edit_req.instruction}")
    
    # Embedding example
    emb_req = emb.CreateEmbeddingRequest(
        model="text-embedding-ada-002",
        input=["Sample text for embedding"]
    )
    print(f"Embedding Request - Model: {emb_req.model}, Inputs: {len(emb_req.input)}")
    
    # Text segmentation example
    seg_req = seg.CreateSegmentationRequest(
        text="This is a sample text. It contains multiple sentences. We want to segment it.",
        model="sentence-segmenter"
    )
    print(f"Segmentation Request - Model: {seg_req.model}, Text Length: {len(seg_req.text)}")
    
    # Video processing example
    vid_req = vid.CreateVideoRequest(
        prompt="A time-lapse of a flower blooming",
        duration=10
    )
    print(f"Video Request - Prompt: {vid_req.prompt}, Duration: {vid_req.duration}s")
    
    # Variation example
    vari_req = vari.CreateVariationRequest(
        input="Original text to create variations from",
        n=3
    )
    print(f"Variation Request - Input Length: {len(vari_req.input)}, Variations: {vari_req.n}")


def demonstrate_serialization():
    """Demonstrate protobuf serialization and deserialization."""
    print("\n--- Serialization Demo ---")
    
    # Create a complex message
    original_req = api.CreateChatCompletionRequest(
        model="gpt-4",
        messages=[
            api.ChatCompletionRequestMessage(
                role=api.ChatMessageRole.CHAT_MESSAGE_ROLE_USER,
                content="Hello, how are you?"
            ),
            api.ChatCompletionRequestMessage(
                role=api.ChatMessageRole.CHAT_MESSAGE_ROLE_ASSISTANT,
                content="I'm doing well, thank you for asking!"
            )
        ],
        max_tokens=100,
        temperature=0.7,
        top_p=0.9
    )
    
    # Serialize to bytes
    serialized = original_req.SerializeToString()
    print(f"Serialized size: {len(serialized)} bytes")
    
    # Deserialize back
    reconstructed_req = api.CreateChatCompletionRequest()
    reconstructed_req.ParseFromString(serialized)
    
    # Verify they're the same
    print(f"Original and reconstructed are equal: {original_req == reconstructed_req}")
    print(f"Reconstructed model: {reconstructed_req.model}")
    print(f"Reconstructed messages: {len(reconstructed_req.messages)}")


if __name__ == "__main__":
    main()
    demonstrate_serialization()