# Chirp STT

Minimal realtime speech-to-text for Neovim using:

- `lua/chirp_stt.lua` for the Neovim job wrapper
- `lua/chirp_stt_worker.py` for microphone capture and Google Speech-to-Text v2
- `lua/plugins/chirp_stt.lua` for the lazy.nvim keymap

## Getting Started

### 1. Enter the Python/GCP shell

```bash
nix develop ~/.nixos#python-gcp
```

This shell provides:

- `python3`
- `pyaudio`
- `google-cloud-speech`
- `pynvim`
- `gcloud`

### 2. Authenticate with Google Cloud

```bash
gcloud auth application-default login
```

### 3. Select a project

```bash
gcloud config set project <PROJECT_ID>
```

The `python-gcp` shell will export `GOOGLE_CLOUD_PROJECT` from the current
`gcloud` project if the variable is not already set.

### 4. Optional: choose a Speech-to-Text region

By default, the worker uses the `eu` Speech-to-Text region for `chirp_3`.
Override it if needed:

```bash
export GOOGLE_CLOUD_LOCATION=us
```

### 5. Launch Neovim from that shell

```bash
nvim
```

### 6. Start and stop transcription

- Press `<leader>c` to start recording
- Neovim enters Insert mode immediately
- Speak into your default microphone
- Live interim transcripts are shown inline at the cursor
- Finalized transcripts are inserted at the cursor
- Press `<leader>c` again to stop and return to Normal mode

## How `lua/chirp_stt.lua` Works

`lua/chirp_stt.lua` is intentionally small.

- `toggle()` decides whether to start or stop the worker
- `start()` runs `python3 lua/chirp_stt_worker.py` with `jobstart()`
- `on_stdout` parses worker status, interim, and final transcript messages
- interim text is rendered as inline virtual text near the cursor
- finalized transcript text is pasted into the buffer
- `on_stderr` filters harmless ALSA noise and forwards real worker errors
- `on_exit` clears the active job, clears interim text, and leaves Insert mode
- `stop()` kills the worker and exits Insert mode

The Lua side does not talk to Google directly. It only manages the worker
process, renders interim stdout updates, and inserts finalized text.

## Runtime Expectations

The current proof of concept assumes:

- Neovim was started from `nix develop ~/.nixos#python-gcp`
- `python3` can import `pyaudio` and `google.cloud.speech_v2`
- Application Default Credentials are available
- `chirp_3` is reached through the `eu` region by default
- your default system microphone works

## Notes

- The worker uses the streaming API with interim results enabled
- Interim recognition is shown as inline virtual text and is not written to the buffer
- Only final recognition results are inserted into the buffer
- Audio is captured from the default microphone
- Errors from Python or Google auth should appear via `nvim-notify`

## Quick Troubleshooting

### `ModuleNotFoundError`
You probably launched `nvim` outside the `python-gcp` shell.

### Google auth error
Run:

```bash
gcloud auth application-default login
```

### Project not set
Run:

```bash
gcloud config set project <PROJECT_ID>
```

Or export `GOOGLE_CLOUD_PROJECT` manually before launching `nvim`.

### Model/location error
If you see an error like `model "chirp_3" does not exist in the location ...`,
set a supported region before launching `nvim`:

```bash
export GOOGLE_CLOUD_LOCATION=eu
```

`eu` is the default used by the worker.
