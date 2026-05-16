# Feishu / Bridge Delivery

Use this reference after `final-16x9.mp4` passes QA.

The default user preference is:

- edited videos should be sent back through Feishu after rendering
- videos received through OpenClaw or Codex bridge should be processed with this skill and replied to in the same source conversation
- local file output alone is not enough unless Feishu/OpenClaw delivery is blocked

## Truth Gate

Delivery is successful only when the send command returns a real message identifier:

- Feishu / Lark: `message_id`, usually `om_...`
- OpenClaw: JSON result containing a delivered message id or equivalent provider message id

Do not claim delivery success from:

- command exit code only
- local MP4 path existing
- `ffprobe` passing
- contact sheet existing
- uploading a file without receiving a message id

If delivery fails, write `delivery: blocked` in `report.md` and the final answer. Include the exact error summary and the local `final-16x9.mp4` path.

## Resolve Target

1. If the request arrived from OpenClaw, Codex bridge, Feishu group, or Feishu DM, prefer the source message context:
   - original channel: `feishu`
   - original account id, usually `main`
   - source `chat_id` or DM user id
   - source `message_id` if available, so the reply can thread or reference it
2. If the request is local but the user has a configured Feishu target, use that configured target.
3. If there is no source context and no configured target, stop before sending and report `delivery: blocked: missing Feishu target`. Do not guess a group.

Current known local hints:

- OpenClaw Feishu default account is usually `main`.
- OpenClaw accepts local video paths through `--media`.
- `lark-cli im +messages-send` can send a local MP4 as a file attachment with `--file`; `--video` requires a cover image and is optional.

## Preferred: OpenClaw Bridge Delivery

Use this when the work was invoked from OpenClaw / Codex bridge or when an OpenClaw target is known.

```bash
openclaw message send \
  --channel feishu \
  --account main \
  --target "$FEISHU_TARGET" \
  --media final-16x9.mp4 \
  --message "已完成 16:9 科技感动效 V1。已通过 contact sheet / ffprobe 验收。" \
  --json
```

If replying to an inbound message and `reply_to` is available:

```bash
openclaw message send \
  --channel feishu \
  --account main \
  --target "$FEISHU_TARGET" \
  --reply-to "$SOURCE_MESSAGE_ID" \
  --media final-16x9.mp4 \
  --message "已完成 16:9 科技感动效 V1。已通过 contact sheet / ffprobe 验收。" \
  --json
```

Save the JSON output to the run folder:

```bash
openclaw message send ... --json | tee qa/delivery-openclaw.json
```

Then extract and record the message id. If the JSON shape changes, inspect it and copy the actual provider message id into `report.md`.

## Fallback: lark-cli Delivery

Use this when OpenClaw is not available but `lark-cli` is configured.

Important: `lark-cli im +messages-send --file/--video/--image` expects a relative path inside the current working directory. `cd` into the render work directory before sending, or use `./final-16x9.mp4`. Do not pass an absolute path to `--file`.

Send to a Feishu group chat:

```bash
cd "$WORK_DIR"

lark-cli im +messages-send \
  --as user \
  --chat-id "$FEISHU_CHAT_ID" \
  --file ./final-16x9.mp4 \
  --jq '.data.message_id // .message_id // .data.message_id_string'
```

Send to a Feishu DM user:

```bash
cd "$WORK_DIR"

lark-cli im +messages-send \
  --as user \
  --user-id "$FEISHU_USER_ID" \
  --file ./final-16x9.mp4 \
  --jq '.data.message_id // .message_id // .data.message_id_string'
```

Optionally send a short text message before or after the file:

```bash
cd "$WORK_DIR"

lark-cli im +messages-send \
  --as user \
  --chat-id "$FEISHU_CHAT_ID" \
  --text "已完成 16:9 科技感动效 V1。成片随后发送，验收图在本地 report 里。" \
  --jq '.data.message_id // .message_id // .data.message_id_string'
```

If using Feishu native video preview instead of file attachment, generate a cover image and use:

```bash
cd "$WORK_DIR"

lark-cli im +messages-send \
  --as user \
  --chat-id "$FEISHU_CHAT_ID" \
  --video ./final-16x9.mp4 \
  --video-cover ./qa/final/0.png \
  --jq '.data.message_id // .message_id // .data.message_id_string'
```

If this fails because of Feishu media limits or upload permissions, fall back to `--file`.

## Inbound Video From Bridge

When the user sends a video to OpenClaw or Codex bridge:

1. Read the inbound attachment/media path or downloaded local file path from the bridge context.
2. Treat it as `source_video`.
3. Create a fresh work directory named from the source filename and current timestamp.
4. Run this skill end to end:
   - inspect source
   - transcribe with `references/transcription.md` if no SRT
   - create or confirm `segment-plan.md`
   - render `final-16x9.mp4`
   - build `qa/contact-16x9.png`
   - deliver the final video back to the same bridge context
5. Keep the final answer short and include the delivery `message_id`.

Do not ask the user to upload the same video again if the bridge already provided the media.

## Artifact Freshness Gate

Before sending:

```bash
test -f final-16x9.mp4
ffprobe -hide_banner -v error -show_entries format=duration -show_entries stream=index,codec_type,width,height,avg_frame_rate -of json final-16x9.mp4
test -f qa/contact-16x9.png
```

Fail delivery if any are true:

- output path contains `9x16` or `final-9x16.mp4`
- file is not from the current work directory
- contact sheet is older than the final video
- `ffprobe` dimensions are not 16:9
- the report does not mention the current final path

Record in `report.md`:

```markdown
## Delivery

- target: Feishu / OpenClaw source context
- final video: `.../final-16x9.mp4`
- command: `openclaw message send ...` or `lark-cli im +messages-send ...`
- status: sent
- message_id: `om_...`
```

For blocked delivery:

```markdown
## Delivery

- status: blocked
- reason: missing Feishu target / upload failed / auth failed
- local final video: `.../final-16x9.mp4`
- error: `...`
```
