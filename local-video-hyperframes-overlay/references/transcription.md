# Transcription Model Setup

Use this reference whenever the source video has no reliable SRT.

The default speech-to-text stack for this skill is:

- model: `Systran/faster-whisper-small`
- runner: `faster-whisper`
- install/runtime: `uv run --with faster-whisper`
- output: `captions.raw.srt`, `captions.raw.json`, then manually cleaned `captions.cleaned.srt`, `captions.cleaned.json`

Do not hide transcription failures. If the model cannot be downloaded or loaded, stop and report the blocker before planning overlays.

## 1. Check required tools

```bash
ffmpeg -version
uv --version
```

If `uv` is missing, install it first or use an existing Python environment that can install `faster-whisper`.

## 2. Extract audio

```bash
ffmpeg -hide_banner -loglevel error -y \
  -i source.mp4 \
  -vn -ac 1 -ar 16000 \
  audio.wav
```

Keep `audio.wav` beside the video work files so later agents can reproduce the transcript.

## 3. Download the model

Preferred one-time download:

```bash
uv run --with faster-whisper python - <<'PY'
from faster_whisper import WhisperModel

WhisperModel("Systran/faster-whisper-small", device="cpu", compute_type="int8")
print("faster-whisper-small ready")
PY
```

This downloads the model into the Hugging Face cache, usually under:

```text
~/.cache/huggingface/hub/models--Systran--faster-whisper-small/snapshots/<revision>/
```

To find the local model directory:

```bash
find "$HOME/.cache/huggingface/hub/models--Systran--faster-whisper-small/snapshots" \
  -mindepth 1 -maxdepth 1 -type d | head -1
```

On this workstation, a known working cache path was:

```text
/Users/cz/.cache/huggingface/hub/models--Systran--faster-whisper-small/snapshots/536b0662742c02347bc0e980a01041f333bce120
```

Do not hard-code that path for other machines. Treat it as an example and discover the cache path locally.

## 4. Transcribe to raw SRT and JSON

Use the Hugging Face model id when network/cache is healthy:

```bash
uv run --with faster-whisper python - <<'PY'
import json
from pathlib import Path
from faster_whisper import WhisperModel

audio = Path("audio.wav")
out_srt = Path("captions.raw.srt")
out_json = Path("captions.raw.json")

model = WhisperModel("Systran/faster-whisper-small", device="cpu", compute_type="int8")
segments, info = model.transcribe(
    str(audio),
    language="zh",
    vad_filter=True,
    beam_size=5,
    initial_prompt="请按中文口播转写。保留产品名、人名、数字、AI、SaaS、Sell AI Pro 等专有词。"
)

def ts(seconds: float) -> str:
    ms = int(round(seconds * 1000))
    h, ms = divmod(ms, 3600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

items = []
for i, seg in enumerate(segments, 1):
    text = " ".join(seg.text.strip().split())
    if not text:
        continue
    items.append({
        "index": i,
        "start": round(float(seg.start), 3),
        "end": round(float(seg.end), 3),
        "text": text,
    })

out_srt.write_text(
    "\n\n".join(
        f"{item['index']}\n{ts(item['start'])} --> {ts(item['end'])}\n{item['text']}"
        for item in items
    ) + "\n",
    encoding="utf-8"
)
out_json.write_text(
    json.dumps({"language": info.language, "segments": items}, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
print(f"wrote {out_srt} and {out_json}, segments={len(items)}")
PY
```

If the machine is offline but the model already exists in cache, use the discovered local directory:

```bash
export MODEL_DIR="$(find "$HOME/.cache/huggingface/hub/models--Systran--faster-whisper-small/snapshots" -mindepth 1 -maxdepth 1 -type d | head -1)"
test -n "$MODEL_DIR"

uv run --with faster-whisper python - <<'PY'
import json
import os
from pathlib import Path
from faster_whisper import WhisperModel

model_dir = os.environ["MODEL_DIR"]
audio = Path("audio.wav")
out_srt = Path("captions.raw.srt")
out_json = Path("captions.raw.json")

model = WhisperModel(model_dir, device="cpu", compute_type="int8", local_files_only=True)
segments, info = model.transcribe(
    str(audio),
    language="zh",
    vad_filter=True,
    beam_size=5,
    initial_prompt="请按中文口播转写。保留产品名、人名、数字、AI、SaaS、Sell AI Pro 等专有词。"
)

def ts(seconds: float) -> str:
    ms = int(round(seconds * 1000))
    h, ms = divmod(ms, 3600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

items = []
for i, seg in enumerate(segments, 1):
    text = " ".join(seg.text.strip().split())
    if not text:
        continue
    items.append({
        "index": i,
        "start": round(float(seg.start), 3),
        "end": round(float(seg.end), 3),
        "text": text,
    })

out_srt.write_text(
    "\n\n".join(
        f"{item['index']}\n{ts(item['start'])} --> {ts(item['end'])}\n{item['text']}"
        for item in items
    ) + "\n",
    encoding="utf-8"
)
out_json.write_text(
    json.dumps({"language": info.language, "segments": items}, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
print(f"wrote {out_srt} and {out_json}, segments={len(items)}")
PY
```

## 5. Clean only obvious words

Create:

- `captions.cleaned.srt`
- `captions.cleaned.json`

Allowed cleanup:

- product names, people names, brand names
- domain terms
- numbers
- English tokens such as `AI`, `SaaS`, `API`
- repeated filler caused by recognition errors

Do not rewrite the speaker's meaning. Do not move timecodes unless a segment is clearly broken.

## 6. Known local failures

If `OPENAI_API_KEY` is missing, do not call OpenAI transcription APIs.

If the `whisper` CLI from `openai-whisper` fails with a SHA256 checksum error such as:

```text
RuntimeError: Model has been downloaded but the SHA256 checksum does not not match.
```

stop retrying `whisper` and use the `faster-whisper` workflow above.

If Hugging Face cannot download the model and no cache exists, report a blocker. Do not invent subtitles.
