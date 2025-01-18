
import pyttsx3
# Write code to take command line arguments for text, rate, volume, and voice_id
import argparse



def text_to_speech(text, rate=150, volume=1.0, voice_id=None):
    """
    Convert text to speech using local TTS engine
    
    Args:
        text (str): Text to convert to speech
        rate (int): Speech rate (words per minute)
        volume (float): Volume level from 0 to 1
        voice_id (str): Optional voice ID to use specific voice
    """
    # Initialize the TTS engine
    engine = pyttsx3.init()
    
    # Configure properties
    engine.setProperty('rate', rate)
    engine.setProperty('volume', volume)
    
    # Set voice if specified
    if voice_id:
        engine.setProperty('voice', voice_id)
    
    # Convert text to speech
    engine.say(text)
    engine.runAndWait()

def list_available_voices():
    """List all available TTS voices"""
    engine = pyttsx3.init()
    voices = engine.getProperty('voices')
    
    for idx, voice in enumerate(voices):
        print(f"Voice {idx}:")
        print(f" - ID: {voice.id}")
        print(f" - Name: {voice.name}")
        print(f" - Languages: {voice.languages}")
        print(f" - Gender: {voice.gender}")
        print("------------------------")

def parse_arguments():
    """Parse command line arguments for text-to-speech"""
    parser = argparse.ArgumentParser(description='Convert text to speech')
    parser.add_argument('--text', type=str, help='Text to convert to speech', default='Goodbye! This is a test of text to speech.')
    parser.add_argument('--rate', type=int, help='Speech rate (words per minute)', default=20)
    parser.add_argument('--volume', type=float, help='Volume level from 0 to 1', default=1.0)
    parser.add_argument('--voice-id', type=str, help='Voice ID to use specific voice', default=9)
    parser.add_argument('--list-voices', action='store_true', help='List available voices')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    
    if args.list_voices:
        list_available_voices()
    else:
        text_to_speech(
            text=args.text,
            rate=args.rate, 
            volume=args.volume,
            voice_id=args.voice_id
        )