import moviepy.editor as mp
import speech_recognition as sr

def convert_mp4_to_wav_and_transcribe(mp4_filepath, wav_filepath, txt_filepath):
    # Load the MP4 video file
    video = mp.VideoFileClip(mp4_filepath)

    # Extract the audio
    audio = video.audio

    # Export the audio as a WAV file
    audio.write_audiofile(wav_filepath)

    # Close the video file
    video.close()

    # Initialize the recognizer
    recognizer = sr.Recognizer()

    # Load the WAV audio file
    with sr.AudioFile(wav_filepath) as source:
        audio = recognizer.record(source)

    # Transcribe the audio
    try:
        text = recognizer.recognize_google(audio)
        with open(txt_filepath, "w") as f:
            f.write(text)
    except sr.UnknownValueError:
        print("Could not understand audio")
    except sr.RequestError as e:
        print(f"Could not request results from Google Speech Recognition service; {e}")

# Example usage
mp4_filepath = "input.mp4"
wav_filepath = "output.wav"
txt_filepath = "output.txt"
convert_mp4_to_wav_and_transcribe(mp4_filepath, wav_filepath, txt_filepath)
