# QA Checklist

Run this before saying the video is done.

## Technical

```bash
ffprobe -hide_banner -v error \
  -show_entries format=duration \
  -show_entries stream=index,codec_type,codec_name,width,height,avg_frame_rate,duration \
  -of json final.mp4
```

Expected:

- video stream exists
- audio stream exists unless user asked for silent
- fps matches requested fps
- duration matches source within one frame
- dimensions match target aspect
- target aspect must be 16:9; fail any 9:16 / 720x1280 output
- expected brand/product terms are corrected in captions and overlay text

Frame count:

```bash
ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=nb_read_frames \
  -of default=nk=1:nw=1 final.mp4
```

## Contact Sheet

Create sampled frames:

```bash
mkdir -p qa
for sec in 0 6 24 55 96 139; do
  ffmpeg -hide_banner -loglevel error -ss "$sec" -i final.mp4 -frames:v 1 "qa/$sec.png" -y
done
```

Then make a contact sheet with the helper script:

```bash
bash scripts/make-contact-sheet.sh qa contact.png
```

For short videos, sample timestamps that fit the actual duration, for example `0, 6, 12, 20, 30, 39`. Do not use timestamps past the end of the file.

## Centered Person Gate

For every sampled frame:

- the visible face/head should sit in the middle third of the person panel
- both sides of the head should have breathing room unless the source video itself lacks those pixels
- the face must not touch the left/right panel edge
- the crop must not show only half a face when a better crop/scale is possible
- the person must not be stretched, squeezed, or non-uniformly scaled
- the face/head must not be over-zoomed into a giant close-up unless the source itself is already that close
- if the source includes shoulders or chest, the final should preserve enough shoulder/neck context to feel natural

If the source is horizontal but the final layout uses a narrower person panel, inspect the sampled source frames and compute crop from the face center:

```text
crop_x = clamp(face_center_x - crop_w / 2, 0, source_w - crop_w)
```

## 16:9 Only Gate

Fail if any are true:

- final deliverable is 9:16, 720x1280, or named `final-9x16.mp4`
- the workspace creates `.overlay-9x16`, `cs-9x16-*.jpg`, or `qa/contact-9x16.png` as claimed output
- a horizontal source was forced through a tall-frame crop such as `scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280`
- the contact sheet shows a giant face close-up caused by format conversion

Pass only when the final deliverable is 16:9 and the person looks like the original source, not a distorted crop.

## Reference Style Gate

Sample the opening frame and each beat change. Fail if the frame does not resemble the user's reference image.

Required visual signals:

- large hook text or key number appears in the first 0-8 seconds
- text feels semi-transparent and premium, not flat default UI text
- mint/green or cyan highlight is used for the key number/phrase
- bottom subtitle is in a translucent glass bar, not a solid black slab
- HUD is sparse: thin line, small label, light chips/callout, at most one chart/info card cluster
- original video remains the visual base and stays clear
- overall tone is high-quality YouTube tech/AI teaching opener

Fail if any are true:

- looks like a generic dark dashboard instead of an overlay on the real video
- primary text is too small to be a hook
- overlay is too opaque and hides the original video environment
- effects are too busy: particle rain, full-screen neon, too many cards, or cheap template motion
- the strongest information is not front-loaded

## Text-Density Gate

Fail if any are true:

- the same key phrase appears in headline, accent, chip, stat, callout, and subtitle at once
- the frame has more than one chip/stat/callout cluster in V1
- product names are guessed or wrong
- the frame looks like a UI dashboard rather than a video with a few premium overlays

Pass only when each beat shows:

- one small label
- one large headline
- one highlighted phrase/number
- one support sentence
- bottom subtitle bar

## Segment Plan Gate

Before a long render, confirm `segment-plan.md` exists unless the user explicitly asked to render without confirmation.

Fail if any are true:

- cleaned subtitle text was not reviewed before writing screen text
- semantic segments are equal time slices instead of content-based sections
- progress labels are generic or unrelated to the transcript
- chart/info-card points have no timestamp, type, content, and reason
- chart/info-card content repeats the headline or subtitle

Pass only when the user has a clear table showing subtitle corrections, 5-8 semantic segments, top progress bar labels, and every planned chart/info-card insertion.

## Delivery Gate

Run this after render QA passes.

Pass only when one of these is true:

- `final-16x9.mp4` was sent back through Feishu / OpenClaw / Codex bridge and a real `message_id` was recorded in `report.md`
- delivery is explicitly marked `blocked` in `report.md` with the reason, failed command/error, and local `final-16x9.mp4` path

Fail if any are true:

- the report says the video was sent but has no `message_id`
- only a local file path was produced when a Feishu/OpenClaw source context was available
- the sent file path is an old artifact, a 9:16 output, a contact sheet, or not from the current work directory
- the original request came through OpenClaw/Codex bridge with an attached video, but the agent asked the user to upload the same video again instead of processing the inbound media

Before sending, check artifact freshness:

```bash
test -f final-16x9.mp4
test -f qa/contact-16x9.png
ffprobe -hide_banner -v error \
  -show_entries format=duration \
  -show_entries stream=index,codec_type,width,height,avg_frame_rate \
  -of json final-16x9.mp4
```

See `references/delivery.md`.

## Progress Bar Gate

Sample the opening frame and each segment transition.

Fail if any are true:

- top progress bar covers the speaker's face, hook title, or subtitles
- running marker is too large, too bright, or distracting
- progress track looks like a generic app dashboard instead of a light video overlay
- segment labels are too dense to read
- asset source/license for the runner marker is missing from `report.md`

Pass only when the progress bar reads as a clean content navigator with a subtle running marker.

## Visual Gates

Fail if any are true:

- horizontal frame shows two people or a blurred duplicate person
- final output is 9:16 or any non-16:9 aspect
- person is not centered inside the person panel
- face/head is cropped or stuck to the panel edge when a better crop/scale is possible
- person is stretched, squeezed, over-zoomed, or visually distorted
- reference style is missing: no large semi-transparent hook text, no glass subtitle, no premium tech HUD
- screen text is not compressed to the core message plus one support line
- progress bar or chart plan was skipped when confirmation was required
- Feishu/OpenClaw delivery was skipped even though a source context or configured target was available
- the video is frozen across multiple timestamps
- subtitle bar covers the speaker's mouth
- headline/card covers the face
- overlay accidentally has black background
- output is a standalone animation rather than the user's video
- user reference style is ignored

Pass only when sampled frames show the original video is moving, effects are a transparent overlay, the person is centered, and the reference style is visibly matched.
