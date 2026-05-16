---
name: local-video-hyperframes-overlay
description: Use this skill whenever the user wants to add HyperFrames, HTML, Remotion, or motion-graphics effects onto an existing local talking-head video, especially for AI/tech/YouTube-style openings, subtitle-driven overlays, SRT timing, Feishu/OpenClaw/Codex bridge video requests, and 16:9 horizontal exports where the original video must remain clear. This skill prevents the common failure where the model creates a standalone animation, freezes a frame, duplicates the person, distorts the person, over-crops the face, outputs 9:16, fails to return the edited video through Feishu, or uses a blurred copy of the same person as the background.
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
   - 没有 SRT 时先按 `references/transcription.md` 下载/使用 `Systran/faster-whisper-small` 转写，先生成 `captions.raw.srt/json`，再生成 `captions.cleaned.srt/json`。
   - 如果 `OPENAI_API_KEY` 缺失或 `openai-whisper` 出现模型 checksum 错误，默认改用 `uv run --with faster-whisper`；不能编造字幕或跳过字幕。
   - 允许修正明显错词，但不要大改时间轴。
   - 每条字幕最多两行，底部 glass bar 内可读。

9. **屏幕文字必须极简，先重点再补充。**
   - 每个 beat 只允许：一个小 label、一个大标题、一个薄荷/青色强调词、一句补充。再多就默认失败。
   - 禁止把同一信息同时写进 headline、accent、chip、stat、callout、字幕里；重复表达必须删。
   - V1 默认隐藏 chips/stat/callout/chart；只有画面真的需要解释时，才加一个轻量元素。
   - 产品名、人名、数字必须按字幕/用户上下文校正；例如 `Sell AI Pro` 不能误写成别的产品名。
   - 字幕 glass bar 要有足够对比：浅色背景上也要读得清，不要为了“透明”牺牲可读性。

10. **生成前先给用户确认字幕、分段、图表点位。**
   - 默认先产出 `segment-plan.md`，包含清洗字幕摘要、智能分段、每段大字/强调词/补充句、顶部进度条 label、拟加入图表/信息卡的位置和理由。
   - 用户未确认前，不进入全量渲染；除非用户明确说“直接生成/不用确认”。
   - 图表只能补充概念或数据关系，不能为了装饰乱加。每个图表必须有时间点、类型、内容、为什么需要。

11. **顶部进度条是内容导航，不是装饰。**
   - 进度条按智能分段显示，放在顶部安全区，不能压字幕、脸、标题。
   - 默认风格：细线 glass track + 当前段高亮 + 小 label + 一个跑步小人沿进度移动。
   - 跑步小人可以用系统 emoji、Noto Emoji SVG、Twemoji SVG 或纯 CSS 图形；必须记录素材来源/许可证。
   - V1 进度条只表达段落进度，不要再加百分比、复杂节点图、满屏路线。

12. **只输出 16:9 横屏。**
   - 本 skill 不再生成 9:16、720x1280、竖屏 contact sheet 或竖屏 overlay。
   - 即使目标平台是短视频，也只交付 16:9 横屏版本；不要自作主张补竖屏。
   - 如果用户再次要求竖屏，先停下来说明这个 skill 已禁用竖屏，不要直接渲染。
   - 输出文件统一命名为 `final-16x9.mp4` 或清晰的横屏文件名。

13. **人物画面不能失真、不能过度放大。**
   - 必须保持源视频宽高比例；禁止非等比拉伸，禁止把人脸强行拉长或压扁。
   - 横屏源不要用 `scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280` 这类竖屏裁切链。
   - 如果源素材不是 16:9，优先等比缩放 + 留白/背景承接；不要为了填满画布把脸裁到贴边。
   - 说话人头发、脸侧、下巴、肩颈要有呼吸空间；若源画面本来包含肩颈，成片不能只剩大头特写。
   - contact sheet 里出现脸被过度放大、头发/脸侧/下巴贴边、肩颈被无故裁掉，即失败。

14. **剪好后默认通过飞书回传。**
   - 每次 `final-16x9.mp4` 通过 QA 后，必须按 `references/delivery.md` 把成片发回用户的飞书会话或来源 bridge 会话。
   - 如果视频来自 OpenClaw、Codex bridge、Feishu 群/私聊入站附件，默认直接下载/读取附件、运行本 skill、再回复同一个会话；不要让用户重复提供本地路径。
   - 发送成功只认真实 `message_id` 或 OpenClaw/Feishu 返回的等价消息 ID；不能把命令退出码、文件存在、本地渲染完成当成已发送。
   - 如果飞书发送失败，最终报告必须写 `delivery: blocked`、失败命令、错误摘要和本地成片绝对路径；不能说“已发”。
   - 发送前必须再次核对 artifact freshness：发送当前 run 的 `final-16x9.mp4`，禁止误发旧 V1、`final-9x16.mp4`、`cs-9x16-*.jpg` 或未通过 QA 的文件。

## Required Inputs

- `source_video`: 本地视频路径，例如 `01.mp4`
- `reference_image`: 用户给的风格参考图，可选但强烈建议看
- `output_aspects`: 固定只出 `16:9`
- `caption_source`: 已有 SRT 或转写生成的 SRT
- `visual_goal`: 例如“高质量 YouTube 科技/AI 教学视频开场”
- `expected_terms`: 必须校正的产品名、人名、专有词，例如 `Sell AI Pro`
- `transcription_model`: 默认 `Systran/faster-whisper-small`，见 `references/transcription.md`
- `delivery_target`: 飞书 `chat_id`、`user_id`、OpenClaw source context，或 bridge 原始会话；见 `references/delivery.md`

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

If no SRT exists, transcribe first using `references/transcription.md`.

Default model and runner:

- `Systran/faster-whisper-small`
- `uv run --with faster-whisper`
- source audio extracted to `audio.wav`

Then create:

- `captions.raw.srt`
- `captions.raw.json`
- `captions.cleaned.srt`
- `captions.cleaned.json`

Clean only obvious terms, especially domain terms, names, numbers, product words, and CTA words.
If the model cannot be downloaded or loaded, stop and report the blocker. Do not invent transcript text and do not continue to visual planning without a real subtitle timeline.

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

Create `segment-plan.md` and ask for confirmation unless the user explicitly opted out. See `references/progress-segmentation.md`.

The plan must include:

- cleaned subtitle text or a compact subtitle summary
- 5-8 semantic segments from the transcript
- per-segment: timestamp range, display label, headline, accent, support sentence
- progress-bar labels and active ranges
- chart/info-card insertions with timestamp, chart type, and why it clarifies the content
- terms corrected from the transcript

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

For tall or narrow source video exported to 16:9:

- place the single sharp video panel center-right or right
- do not duplicate video as full-screen blurred background
- fill unused space with dark/warm abstract background, not another copy of the person
- preserve aspect ratio and keep head/shoulders natural; pad/fill around the video instead of zooming into a giant face

For horizontal source video:

- start from the original frame, not from a cropped half-frame
- keep the person visually centered unless a beat intentionally switches the person to the other side
- put large text in the real negative space, or use a light translucent wash over the video
- avoid turning the whole left half into an opaque dark dashboard unless the reference asks for that

### 5. Reject non-horizontal deliverables

Do not design, render, export, or report a 9:16 deliverable. This skill is now 16:9 only.

If an existing workspace contains `.overlay-9x16`, `final-9x16.mp4`, `cs-9x16-*.jpg`, or `qa/contact-9x16.png`, ignore them and do not treat them as valid output.

If a previous run produced a 9:16 file, mark it as rejected because it risks face over-cropping and visual distortion.

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

Horizontal example for a tall/narrow talking-head source:

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

If the source is horizontal and you are cropping it into a narrower person panel, never hard-code `crop=half_width:height:0:0` or `crop=half_width:height:half_width:0`. Compute the crop from the face center:

```text
crop_x = clamp(face_center_x - crop_w / 2, 0, source_w - crop_w)
```

Example for a `1280x720` source placed into a `640x720` person panel when the face center is around `x=650`:

```bash
[0:v]crop=640:720:330:0,scale=640:720,setsar=1[person]
```

Do not use a blurred duplicate of `[0:v]` as background in horizontal unless the source does not contain a person.

Never render `final-9x16.mp4`; never create `.overlay-9x16`.

### 8. Verify before reporting done

Use the checklist in `references/qa-checklist.md`.

Minimum required checks:

- `ffprobe` confirms dimensions, duration, fps, audio.
- Count frames if needed: `ffprobe -count_frames`.
- Make a contact sheet at `0, 6, 24, 55, 96, 139` seconds.
- Confirm sampled frames show different mouth/head positions.
- Confirm horizontal has exactly one visible person.
- Confirm the person is centered inside the person panel.
- Confirm the person is not distorted, stretched, squeezed, or over-zoomed.
- Confirm the visual style matches the reference: large semi-transparent hook text, glass subtitle bar, sparse HUD, premium YouTube tech opener feel.
- Confirm no black overlay covers the video.
- Confirm subtitle does not cover face/mouth.
- Confirm text-density check passed: no duplicated screen text, no unnecessary chips/stat/cards, product names corrected.
- Confirm top progress bar follows semantic segments and the running marker does not overlap title/face.
- Confirm planned chart/info-card points match `segment-plan.md`.
- Confirm delivery target is resolved from the current Feishu/OpenClaw/Codex bridge context or configured user target.
- If Kimi or another model is available, run a read-only review against the contact sheets. Treat a FAIL as a blocker and revise before reporting done.

### 9. Deliver through Feishu / bridge

After QA passes, deliver the edited video using `references/delivery.md`.

Default delivery behavior:

- If invoked from Feishu / OpenClaw / Codex bridge with a source message context, reply to that same context with `final-16x9.mp4`.
- If invoked locally without a source message context, use the configured Feishu target if one exists; otherwise ask once for the target and report `delivery: blocked` for this run.
- Include a short text summary and, when useful, the contact sheet path or image.
- Record the returned `message_id` in `report.md`.
- Do not report completion as fully done until delivery has either succeeded with `message_id` or is explicitly marked blocked with the reason.

## Output Report

Report in this structure:

```markdown
完成：
- 16:9: [path]
- 飞书发送: [message_id or blocked reason]

做了哪些效果：
- ...

验收：
- dimensions/fps/duration/audio
- contact sheet path
- alpha overlay verified
- horizontal one-person check passed
- centered-person check passed
- no person distortion / no over-crop check passed
- reference-style check passed
- text-density check passed
- semantic progress bar check passed
- chart/info-card plan followed
- Feishu/OpenClaw delivery message_id or blocked reason
- optional Kimi/other-agent read-only review result

本次用到的 skill：
- local-video-hyperframes-overlay
```

## Kimi / Other Model Usage

If the executor is Kimi or another model, paste this whole `SKILL.md` plus `templates/kimi-task-prompt.md`.
Also paste `references/transcription.md` when the video has no reliable SRT, so the model knows exactly how to download and use the speech-to-text model.
Also paste `references/delivery.md` when the video should be returned through Feishu, OpenClaw, or Codex bridge.

Tell the model:

- Do not invent a different pipeline.
- Do not output only a plan if it has file access and terminal access.
- If it cannot run tools, it must output exact files/commands for a human or agent to run.
- It must include QA screenshots/contact sheets before claiming completion.
