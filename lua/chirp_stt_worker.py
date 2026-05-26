import os

import pyaudio
from google.cloud.speech_v2 import SpeechClient
from google.cloud.speech_v2.types import cloud_speech

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION", "eu")
RATE = 16000
CHUNK = 512

client = SpeechClient(
    client_options={"api_endpoint": f"{LOCATION}-speech.googleapis.com"}
)
recognition_config = cloud_speech.RecognitionConfig(
    explicit_decoding_config=cloud_speech.ExplicitDecodingConfig(
        encoding=cloud_speech.ExplicitDecodingConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=RATE,
        audio_channel_count=1,
    ),
    language_codes=["en-US"],
    model="chirp_3",
)
streaming_config = cloud_speech.StreamingRecognitionConfig(
    config=recognition_config,
    streaming_features=cloud_speech.StreamingRecognitionFeatures(
        interim_results=True,
        enable_voice_activity_events=True,
    ),
)
config_request = cloud_speech.StreamingRecognizeRequest(
    recognizer=f"projects/{PROJECT_ID}/locations/{LOCATION}/recognizers/_",
    streaming_config=streaming_config,
)


def emit(kind, text):
    print(f"{kind}\t{text}", flush=True)


pyaudio_client = pyaudio.PyAudio()
stream = pyaudio_client.open(
    format=pyaudio.paInt16,
    channels=1,
    rate=RATE,
    input=True,
    frames_per_buffer=CHUNK,
)


def requests():
    yield config_request

    while True:
        yield cloud_speech.StreamingRecognizeRequest(
            audio=stream.read(CHUNK, exception_on_overflow=False)
        )


try:
    emit("STATUS", "listening...")
    responses = client.streaming_recognize(requests=requests())

    for response in responses:
        for result in response.results:
            if not result.alternatives:
                continue

            transcript = result.alternatives[0].transcript.strip()
            if transcript == "":
                continue

            if result.is_final:
                emit("FINAL", transcript)
            else:
                emit("INTERIM", transcript)
finally:
    stream.stop_stream()
    stream.close()
    pyaudio_client.terminate()
