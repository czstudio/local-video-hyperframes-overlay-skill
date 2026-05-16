# Kimi Task Prompt Template

你现在要执行 `local-video-hyperframes-overlay` 这个 skill。

## 输入

- 源视频：`{{SOURCE_VIDEO}}`
- 参考图：`{{REFERENCE_IMAGE}}`
- 输出目录：`{{OUTPUT_DIR}}`
- 输出比例：固定 `16:9`
- 风格目标：`{{STYLE_GOAL}}`
- 必须校正的词：`{{EXPECTED_TERMS}}`
- 是否需要先确认字幕/分段：`{{CONFIRM_SEGMENTS}}`
- 顶部进度条风格：`{{PROGRESS_STYLE}}`
- 字幕转写模型：默认 `Systran/faster-whisper-small`，按 `references/transcription.md` 下载和使用

## 绝对要求

0. 如果用户要求 HyperFrames CLI，必须先运行 `npx hyperframes info` 或 `npx hyperframes doctor` 验证；失败要报告真实错误，不能冒充已经安装/使用。
1. 最终效果必须叠加在源视频上，不是重新生成一个动画。
2. 横屏只能有一个人物画面；禁止把同一个人物视频再做成模糊背景。
3. 人物必须在人物画面内居中；不允许半张脸贴边、头部贴边、默认裁半边画面。
3.1. 只能输出 16:9 横屏；禁止生成 9:16、720x1280、`final-9x16.mp4`、`.overlay-9x16` 或竖屏 contact sheet。
3.2. 人物画面不能失真：禁止非等比拉伸，禁止把横屏源强裁成竖屏大头，禁止头发/脸侧/下巴贴边。
4. 学参考图：大字/重点数字、半透明高级文字、底部半透明字幕条、少量高级 glass HUD。
5. 整体必须像高质量 YouTube 科技/AI 教学视频开场：抓人、现代、干净、科技感，不像廉价模板。
6. 前 0-8 秒优先放最抓人的信息，节奏要明显 stronger。
7. 合理加大字、加字幕、加 callout/信息卡/少量图表，并在合适节点做人物位置切换。
8. V1 不要塞太多效果；不要粒子雨、不要满屏卡片、不要厚重黑色 dashboard。
9. 先识别或清洗 SRT 时间轴。没有 SRT 时，必须先按 `references/transcription.md` 使用 `uv run --with faster-whisper` + `Systran/faster-whisper-small` 生成 `captions.raw.srt/json`，再清洗成 `captions.cleaned.srt/json`。
10. HTML/HyperFrames 只渲染透明 overlay，最终用 ffmpeg 和源视频合成。
11. 输出前必须给关键帧 contact sheet，证明视频在动、人物只有一个且人物居中，并且风格接近参考图。
12. 屏幕文字必须精简：每个 beat 默认只保留一个小 label、一个大标题、一个薄荷/青色强调词、一句补充；不要同时堆 chips/stat/callout/chart。
13. 产品名、人名、数字必须校正；不要把 `{{EXPECTED_TERMS}}` 写错。发现字幕误识别时只修明显错词，不大改时间轴。
14. 如果你做完后自查或另一个 agent 复核为 FAIL，必须继续修，不要报告完成。
15. 默认先输出 `segment-plan.md`，让用户确认字幕文案、智能分段、进度条 label、图表/信息卡点位后再渲染；除非 `{{CONFIRM_SEGMENTS}}` 明确写“否/直接生成”。
16. 视频顶部要有语义进度条：按文案分段显示，当前段高亮，一个跑步小人沿轨道移动；不能遮脸、遮标题或遮字幕。
17. 图表/信息卡必须少而准：每个都写清时间点、类型、内容、为什么需要；没有补充价值就不要加。
18. 如果 `OPENAI_API_KEY` 缺失或 `openai-whisper` 模型 checksum 失败，不要反复重试，也不要伪造字幕；改用 faster-whisper 工作流，仍失败就报告 blocker。

## 交付物

- `captions.raw.srt`
- `captions.raw.json`
- `captions.cleaned.srt`
- `captions.cleaned.json`
- `segment-plan.md`
- `overlay.html` 或等价 HTML
- `final-16x9.mp4`
- `qa/contact-16x9.png`
- `report.md`

## 完成报告格式

```markdown
完成：
- 16:9: ...

效果：
- ...

验收：
- ...

问题/限制：
- ...
```
