---
name: local-video-hyperframes-overlay
description: Use this skill whenever the user wants to add HyperFrames, HTML, Remotion, or motion-graphics effects onto an existing local talking-head video, especially for AI/tech/YouTube-style openings, subtitle-driven overlays, SRT timing, horizontal or vertical exports, or when the user says the original video must remain clear. This skill prevents the common failure where the model creates a standalone animation, freezes a frame, duplicates the person, or uses a blurred copy of the same person as the background.
---

# Local Video HyperFrames Overlay SOP

目标：把动效叠加到用户的本地视频上，而不是重新做一个动画片。原视频是真相源，动效只是透明覆盖层。

## Hard Rules

0. **用户要 HyperFrames CLI 时，必须先验证 CLI。**
   - 官方入口是 `npx hyperframes`，不是臆造的全局 `hyperframes` 命令。
   - 先运行 `node -v`、`ffmpeg -version`、`npx hyperframes info` 或 `npx hyperframes doctor`。
   - 如果 `npx hyperframes` 因网络、npm、Chrome、FFmpeg 失败，必须把失败作为 blocker 写进报告；不能静默用自制渲染器冒充 HyperFrames CLI 已安装/已使用。
   - 只有用户接受 fallback 时，才允许改用本地 Playwright + FFmpeg 透明 overlay 流程。

1. **人物只能出现一次。**
   - 横屏里不能同时出现清晰人物和模糊放大人物。
   - 不要用同一个 talking-head 视频做模糊背景，因为这会出现第二个人像。
   - 需要填空时，用纯色、轻渐变、暗色面板、线框、网格、墙面色块，不要复制人物视频。

2. **人物必须在人物画面内居中。**
   - 人脸/头部不能贴左边、贴右边、半张脸出框，除非源视频本身已经永久缺失这部分画面。
   - 如果源视频要裁成右侧/中间人物面板，必须先抽关键帧看人脸中心，再按人脸中心计算 `crop=x:y:w:h`。
   - 不允许默认裁左半边或右半边。裁剪公式：`crop_x = clamp(face_center_x - crop_w / 2, 0, source_w - crop_w)`。
   - 如果无法让人物居中，优先改为保留更完整的源画面、缩放留边或调整版式，不要强行裁掉脸。
   - contact sheet 里人物不居中即失败，不能报告完成。

3. **主体视频必须是真的视频，不是截图帧。**
   - 最终成片必须由 `ffmpeg` 把原视频流和透明 overlay 合成。
   - 不要把隐藏 `<video>` draw 到 canvas 后当主体渲染。
   - 不要只看浏览器截图成功；浏览器逐帧截图视频元素容易冻结或错帧。

4. **HTML/HyperFrames 只负责透明动效层。**
   - overlay HTML 背景必须透明。
   - Playwright 截图必须用 `omitBackground: true`。
   - overlay PNG 必须是 `rgba`，用 `ffprobe` 验证。

5. **横屏参考图约束。**
   - 学用户参考图：一个人物视频画面，左侧大标题/重点数字，底部半透明字幕条，少量线框和小标签。
   - 字要大，重点信息在前 3-8 秒出现。
   - 效果高级、干净、半透明；不要粒子雨、不要满屏卡片、不要廉价模板。
   - 人脸、嘴巴、上半身不要被信息卡盖住。

6. **参考图风格是硬门槛，不是可选建议。**
   - 画面应像高质量 YouTube 科技/AI 教学开场：半透明、干净、现代、轻 HUD、轻科技感。
   - 大字必须明显：左侧或空白区放大关键词/数字，重点词用薄荷绿或浅青色，白字可略透明但必须清晰。
   - 底部字幕条必须是半透明 glass bar，能看到原视频底色；不要做成厚重纯黑条。
   - HUD 只保留少量：细线、短标签、轻描边信息卡、callout、小型图表。不要满屏卡片、粒子雨、霓虹模板。
   - 背景优先保留原视频真实环境的暖色/墙面质感；不要把横屏做成一块深色 dashboard，把人物视频缩成素材。
   - 如果 contact sheet 看起来不像参考图的“半透明高级感”，即失败。

7. **节奏必须 stronger，但 V1 不堆效果。**
   - 前 0-8 秒必须放最抓人的信息，不能等到中段才出现核心钩子。
   - 每 5-8 秒至少有一次明确的信息变化：大字、callout、信息卡、人物位置切换或自然转场。
   - 人物位置切换只能在合适句子节点做，切换后仍然只出现一个人物、人物仍居中、主体仍清晰。
   - V1 控制在 5-7 个 beat，最多 1 个轻图表/信息卡同时出现，避免廉价模板感。

8. **字幕时间轴先行。**
   - 没有 SRT 时先转写，生成 `captions.cleaned.srt`。
   - 允许修正明显错词，但不要大改时间轴。
   - 每条字幕最多两行，底部 glass bar 内可读。

9. **屏幕文字必须极简，先重点再补充。**
   - 每个 beat 只允许：一个小 label、一个大标题、一个薄荷/青色强调词、一句补充。再多就默认失败。
   - 禁止把同一信息同时写进 headline、accent、chip、stat、callout、字幕里；重复表达必须删。
   - V1 默认隐藏 chips/stat/callout/chart；只有画面真的需要解释时，才加一个轻量元素。
   - 产品名、人名、数字必须按字幕/用户上下文校正；例如 `Sell AI Pro` 不能误写成别的产品名。
   - 字幕 glass bar 要有足够对比：浅色背景上也要读得清，不要为了“透明”牺牲可读性。

## Required Inputs

- `source_video`: 本地视频路径，例如 `01.mp4`
- `reference_image`: 用户给的风格参考图，可选但强烈建议看
- `output_aspects`: 默认同时出 `16:9` 和 `9:16`
- `caption_source`: 已有 SRT 或转写生成的 SRT
- `visual_goal`: 例如“高质量 YouTube 科技/AI 教学视频开场”

## SOP

### 0. Verify HyperFrames CLI when requested

If the user explicitly asks for HyperFrames CLI:

```bash
node -v
ffmpeg -version
npx hyperframes info
npx hyperframes doctor
```

Record the result. If `npx hyperframes` needs installation, let `npx` install it. If install fails, stop and report the exact error unless the user explicitly accepts a fallback renderer.

### 1. Inspect source

Run:

```bash
ffprobe -hide_banner -i source.mp4
```

Record:

- duration
- width/height
- fps
- audio stream
- whether subtitles already exist

### 2. Build or clean subtitles

If no SRT exists, transcribe first. Use whichever local Whisper path is stable. Then create:

- `captions.cleaned.srt`
- `captions.cleaned.json`

Clean only obvious terms, especially domain terms, names, numbers, product words, and CTA words.

### 3. Plan overlay beats from SRT

Create 6-10 beat windows from the subtitle timeline:

- opening hook
- problem/signal
- proof/evidence
- method/system
- example/result
- CTA

For each beat define:

- `start`, `end`
- `headline`: one concise main idea
- `accent`: one highlighted number/phrase
- `support`: one short supporting sentence
- optional `micro_label`: top-left label only

Beat design must include:

- `hero_text`: the biggest on-screen phrase/number
- `visual_layer`: title, translucent text, subtitle bar, or one justified info/callout element
- `person_position`: centered, center-left, center-right; never edge-stuck
- `transition`: none, soft push, glass wipe, subtle zoom, or position switch

Before rendering, run a text-density pass:

- delete repeated nouns across headline/accent/support/subtitle
- remove chips/stat/callout unless each adds new information
- keep the reference-image hierarchy: big words first, small explanation second
- if a frame reads like a dashboard, reduce text layers before changing colors

### 4. Design the horizontal layout

Follow the reference image:

- one visible person video only
- person centered inside the visible person panel
- left/open side: small label + large headline + one highlight number or phrase
- text should feel semi-transparent and premium: white at ~0.86-0.94 alpha, mint/cyan highlights, subtle shadow, thin underline
- bottom: wide translucent subtitle bar that reveals the source video underneath
- optional: thin top-left line only; small tags/cards are off by default
- safe zones: keep face clear, keep text left, keep bottom bar below mouth/chest

Before choosing a crop:

- extract frames at representative timestamps
- estimate the face center in source coordinates
- choose crop/scale so the face center lands in the middle third of the person panel
- reject crops where the face touches the panel edge

For vertical source video exported to horizontal:

- place the single sharp video panel center-right or right
- do not duplicate video as full-screen blurred background
- fill unused space with dark/warm abstract background, not another copy of the person

For horizontal source video:

- start from the original frame, not from a cropped half-frame
- keep the person visually centered unless a beat intentionally switches the person to the other side
- put large text in the real negative space, or use a light translucent wash over the video
- avoid turning the whole left half into an opaque dark dashboard unless the reference asks for that

### 5. Design the vertical layout

For `9:16`, keep the original video full-frame or near full-frame:

- top: large headline only when needed
- middle: avoid face
- lower third: only one short support element if needed
- bottom: subtitle bar

The vertical version still needs the same reference feel: large translucent hook text, glass subtitle bar, sparse HUD, centered person.

### 6. Render transparent overlay frames

Overlay HTML must use transparent root/background in overlay mode:

```css
html.overlay-mode,
body.overlay-mode,
body.overlay-mode [data-composition-id="main"] {
  background: transparent;
}
```

Playwright screenshot:

```js
await page.screenshot({
  path: framePath,
  type: "png",
  omitBackground: true,
  scale: "css"
});
```

Verify alpha:

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=pix_fmt,width,height \
  -of default=nw=1 .overlay-16x9/frame-000181.png
```

Expected: `pix_fmt=rgba`.

### 7. Compose final video with ffmpeg

Horizontal example for a vertical talking-head source:

```bash
ffmpeg -y \
  -i source.mp4 \
  -framerate 30 -i .overlay-16x9/frame-%06d.png \
  -filter_complex "[0:v]scale=-1:720[person];color=c=#080b10:s=1280x720:r=30[bg];[bg][person]overlay=x=816:y=0[base];[base][1:v]overlay=0:0:format=auto[v]" \
  -map "[v]" -map 0:a \
  -t 156.967 \
  -c:v libx264 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -movflags +faststart \
  final-16x9.mp4
```

Vertical example:

```bash
ffmpeg -y \
  -i source.mp4 \
  -framerate 30 -i .overlay-9x16/frame-%06d.png \
  -filter_complex "[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280[base];[base][1:v]overlay=0:0:format=auto[v]" \
  -map "[v]" -map 0:a \
  -t 156.967 \
  -c:v libx264 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -movflags +faststart \
  final-9x16.mp4
```

If the source is horizontal and you are cropping it into a narrower person panel, never hard-code `crop=half_width:height:0:0` or `crop=half_width:height:half_width:0`. Compute the crop from the face center:

```text
crop_x = clamp(face_center_x - crop_w / 2, 0, source_w - crop_w)
```

Example for a `1280x720` source placed into a `640x720` person panel when the face center is around `x=650`:

```bash
[0:v]crop=640:720:330:0,scale=640:720,setsar=1[person]
```

Do not use a blurred duplicate of `[0:v]` as background in horizontal unless the source does not contain a person.

### 8. Verify before reporting done

Use the checklist in `references/qa-checklist.md`.

Minimum required checks:

- `ffprobe` confirms dimensions, duration, fps, audio.
- Count frames if needed: `ffprobe -count_frames`.
- Make a contact sheet at `0, 6, 24, 55, 96, 139` seconds.
- Confirm sampled frames show different mouth/head positions.
- Confirm horizontal has exactly one visible person.
- Confirm the person is centered inside the person panel.
- Confirm the visual style matches the reference: large semi-transparent hook text, glass subtitle bar, sparse HUD, premium YouTube tech opener feel.
- Confirm no black overlay covers the video.
- Confirm subtitle does not cover face/mouth.
- Confirm text-density check passed: no duplicated screen text, no unnecessary chips/stat/cards, product names corrected.
- If Kimi or another model is available, run a read-only review against the contact sheets. Treat a FAIL as a blocker and revise before reporting done.

## Output Report

Report in this structure:

```markdown
完成：
- 16:9: [path]
- 9:16: [path]

做了哪些效果：
- ...

验收：
- dimensions/fps/duration/audio
- contact sheet path
- alpha overlay verified
- horizontal one-person check passed
- centered-person check passed
- reference-style check passed
- text-density check passed
- optional Kimi/other-agent read-only review result

本次用到的 skill：
- local-video-hyperframes-overlay
```

## Kimi / Other Model Usage

If the executor is Kimi or another model, paste this whole `SKILL.md` plus `templates/kimi-task-prompt.md`.

Tell the model:

- Do not invent a different pipeline.
- Do not output only a plan if it has file access and terminal access.
- If it cannot run tools, it must output exact files/commands for a human or agent to run.
- It must include QA screenshots/contact sheets before claiming completion.
