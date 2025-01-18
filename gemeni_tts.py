import os
import google.generativeai as genai
import pyttsx3
from dotenv import load_dotenv


load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable not set.")

try:
    genai.configure(api_key=API_KEY)
    model = genai.GenerativeModel('gemini-pro') # Or your specific model name
    engine = pyttsx3.init()
    engine.setProperty('rate', 150)
#    engine.setProperty('pitch', 150)
    engine.setProperty('volume', 1.0)
    engine.setProperty('voice_id', 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens\TTS_MS_EN-US_ZIRA_11.0')
    voices = engine.getProperty('voices')

    for voice in voices:
        if voice.languages and voice.languages[0].startswith('en') and voice.gender == 'female':
            print(f"Name: {voice.name}")
            print(f"ID: {voice.id}")
            print("-" * 20)


    def speak_gemini(prompt):
        try:
            response = model.generate_content(prompt) # Pass the prompt directly
            
            for candidate in response.candidates:
                    # print("Gemini:", response.candidates)
                    print("Gemini:", response.text)
                    #engine.say(response.candidates)
                    # Add code to generate audio using python module TTS 
                    engine.say(response.text)
                    engine.runAndWait()
                
        except Exception as e:
            print(f"An error occurred during text generation or speech: {e}")

    speak_gemini("Tell me a 20 word short story about a robot.")

except Exception as e:
    print(f"An error occurred during initialization: {e}")


