import torch
import TTS.api import TTS

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

print(TTS().list_models())

engine = pyttsx3.init()
voices = engine.getProperty('voices')

for voice in voices:
    # if voice.languages and voice.languages[0].startswith('en') and voice.gender == 'female':  # Check for English and female
        print(f"Voice ID: {voice.id}")
        print(f"Name: {voice.name}")
        print(f"Languages: {voice.languages}")
        print(f"Gender: {voice.gender}")def        print(f"Age: {voice.age}")
        print("-" * 20)  # Separator
