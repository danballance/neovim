This section demonstrates how to transcribe streaming audio, like the input from
a microphone, to text.

_Streaming speech recognition_ lets you stream audio to Cloud Speech-to-Text and
receive a stream speech recognition results in real time as the audio is
processed. See also the [audio limits](https://docs.cloud.google.com/speech-to-text/quotas) for streaming speech
recognition requests. Streaming speech recognition is available [through gRPC](https://docs.cloud.google.com/speech-to-text/docs/reference/rpc/google.cloud.speech.v2) only.

## Before you begin

1. Client libraries can use [Application Default Credentials](https://docs.cloud.google.com/docs/authentication/application-default-credentials) to easily authenticate with Google APIs and send requests to those APIs. With Application Default Credentials, you can test your application locally and deploy it without changing the underlying code. For more information, see [Authenticate for using client libraries](https://docs.cloud.google.com/docs/authentication/client-libraries).
2. If you're using a local shell, then create local authentication credentials for your user
   account:

   ```bash
   gcloud auth application-default login
   ```

   You don't need to do this if you're using Cloud Shell.

   If an authentication error is returned, and you are using an external identity provider
   (IdP), confirm that you have
   [signed in to the gcloud CLI with your federated identity](https://docs.cloud.google.com/iam/docs/workforce-log-in-gcloud).

Also ensure you have [installed the client library](https://docs.cloud.google.com/speech-to-text/docs/libraries).

## Perform streaming speech recognition on a local file

The following code block contains an example of performing streaming speech
recognition on a local audio file. There is a 25 KB limit on audio sent in the
requests of a stream. This limit applies to to both the initial
`StreamingRecognize` request and the size of each individual message in the
stream. Exceeding this limit will throw an error.

### Python

    import os

    from google.cloud.speech_v2 import SpeechClient
    from google.cloud.speech_v2.types import cloud_speech as cloud_speech_types

    PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")

    def transcribe_streaming_v2(
        stream_file: str,
    ) -> cloud_speech_types.StreamingRecognizeResponse:
        """Transcribes audio from an audio file stream using Google Cloud Speech-to-Text API.
        Args:
            stream_file (str): Path to the local audio file to be transcribed.
                Example: "resources/audio.wav"
        Returns:
            list[cloud_speech_types.StreamingRecognizeResponse]: A list of objects.
                Each response includes the transcription results for the corresponding audio segment.
        """
        # Instantiates a client
        client = SpeechClient()

        # Reads a file as bytes
        with open(stream_file, "rb") as f:
            audio_content = f.read()

        # In practice, stream should be a generator yielding chunks of audio data
        chunk_length = len(audio_content) // 5
        stream = [
            audio_content[start : start + chunk_length]
            for start in range(0, len(audio_content), chunk_length)
        ]
        audio_requests = (
            cloud_speech_types.StreamingRecognizeRequest(audio=audio) for audio in stream
        )

        recognition_config = cloud_speech_types.RecognitionConfig(
            auto_decoding_config=cloud_speech_types.AutoDetectDecodingConfig(),
            language_codes=["en-US"],
            model="chirp_3",
        )
        streaming_config = cloud_speech_types.StreamingRecognitionConfig(
            config=recognition_config
        )
        config_request = cloud_speech_types.StreamingRecognizeRequest(
            recognizer=f"projects/{PROJECT_ID}/locations/global/recognizers/_",
            streaming_config=streaming_config,
        )

        def requests(config: cloud_speech_types.RecognitionConfig, audio: list) -> list:
            yield config
            yield from audio

        # Transcribes the audio into text
        responses_iterator = client.streaming_recognize(
            requests=requests(config_request, audio_requests)
        )
        responses = []
        for response in responses_iterator:
            responses.append(response)
            for result in response.results:
                print(f"Transcript: {result.alternatives[0].transcript}")

        return responses

While you can stream a local audio file to the Speech-to-Text API, it is recommended
that you perform [synchronous](https://docs.cloud.google.com/speech-to-text/docs/sync-recognize) audio recognition.

## Clean up

To avoid incurring charges to your Google Cloud account for the resources used on this page, follow these steps.

1.  Optional: Revoke the authentication credentials that you created, and delete the local
    credential file.

    ```bash
    gcloud auth application-default revoke
    ```

2.  Optional: Revoke credentials from the gcloud CLI.

    ```bash
    gcloud auth revoke
    ```

### Console

> [!CAUTION]
> **Caution** : Deleting a project has the following effects:
>
> - **Everything in the project is deleted.** If you used an existing project for the tasks in this document, when you delete it, you also delete any other work you've done in the project.
> - **Custom project IDs are lost.** When you created this project, you might have created a custom project ID that you want to use in the future. To preserve the URLs that use the project ID, such as an `appspot.com` URL, delete selected resources inside the project instead of deleting the whole project.
>
> If you plan to explore multiple architectures, tutorials, or quickstarts, reusing projects
> can help you avoid exceeding project quota limits.

- In the Google Cloud console, go to the **Manage resources** page.

  [Go to Manage resources](https://console.cloud.google.com/iam-admin/projects)

- In the project list, select the project that you want to delete, and then click **Delete**.
- In the dialog, type the project ID, and then click **Shut down** to delete the project.

### gcloud

> [!CAUTION]
> **Caution** : Deleting a project has the following effects:
>
> - **Everything in the project is deleted.** If you used an existing project for the tasks in this document, when you delete it, you also delete any other work you've done in the project.
> - **Custom project IDs are lost.** When you created this project, you might have created a custom project ID that you want to use in the future. To preserve the URLs that use the project ID, such as an `appspot.com` URL, delete selected resources inside the project instead of deleting the whole project.
>
> If you plan to explore multiple architectures, tutorials, or quickstarts, reusing projects
> can help you avoid exceeding project quota limits.

Delete a Google Cloud project:

```
gcloud projects delete PROJECT_ID
```

<br />

## What's next

- See the [reference documentation](https://docs.cloud.google.com/speech-to-text/docs/reference/rpc/google.cloud.speech.v2#google.cloud.speech.v2.Speech.StreamingRecognize) for streaming recognition.
- Learn how to [transcribe short audio files](https://docs.cloud.google.com/speech-to-text/docs/sync-recognize).
- Learn how to [transcribe long audio files](https://docs.cloud.google.com/speech-to-text/docs/batch-recognize).
- For best performance, accuracy, and other tips, see the [best practices](https://docs.cloud.google.com/speech-to-text/docs/best-practices) documentation.
