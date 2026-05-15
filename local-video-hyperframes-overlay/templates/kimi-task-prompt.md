# Kimi Task Prompt Template

你现在要执行 `local-video-hyperframes-overlay` 这个 skill。

## 输入

- 源视频：`{{SOURCE_VIDEO}}`
- 参考图：`{{REFERENCE_IMAGE}}`
- 输出目录：`{{OUTPUT_DIR}}`
- 输出比例：`{{ASPECTS}}`
- 风格目标：`{{STYLE_GOAL}}`
- 必须校正的词：`{{EXPECTED_TERMS}}`

## 绝对要求

0. 如果用户要求 HyperFrames CLI，必须先运行 `npx hyperframes info` 或 `npx hyperframes doctor` 验证；失败要报告真实错误，不能冒充已经安装/使用。
1. 最终效果必须叠加在源视频上，不是重新生成一个动画。
2. 横屏只能有一个人物画面；禁止把同一个人物视频再做成模糊背景。
3. 人物必须在人物画面内居中；不允许半张脸贴边、头部贴边、默认裁半边画面。
4. 学参考图：大字/重点数字、半透明高级文字、底部半透明字幕条、少量高级 glass HUD。
5. 整体必须像高质量 YouTube 科技/AI 教学视频开场：抓人、现代、干净、科技感，不像廉价模板。
6. 前 0-8 秒优先放最抓人的信息，节奏要明显 stronger。
7. 合理加大字、加字幕、加 callout/信息卡/少量图表，并在合适节点做人物位置切换。
8. V1 不要塞太多效果；不要粒子雨、不要满屏卡片、不要厚重黑色 dashboard。
9. 先识别或清洗 SRT 时间轴。
10. HTML/HyperFrames 只渲染透明 overlay，最终用 ffmpeg 和源视频合成。
11. 输出前必须给关键帧 contact sheet，证明视频在动、人物只有一个且人物居中，并且风格接近参考图。
12. 屏幕文字必须精简：每个 beat 默认只保留一个小 label、一个大标题、一个薄荷/青色强调词、一句补充；不要同时堆 chips/stat/callout/chart。
13. 产品名、人名、数字必须校正；不要把 `{{EXPECTED_TERMS}}` 写错。发现字幕误识别时只修明显错词，不大改时间轴。
14. 如果你做完后自查或另一个 agent 复核为 FAIL，必须继续修，不要报告完成。

## 交付物

- `captions.cleaned.srt`
- `overlay.html` 或等价 HTML
- `final-16x9.mp4`
- `final-9x16.mp4`
- `qa/contact-16x9.png`
- `qa/contact-9x16.png`
- `report.md`

## 完成报告格式

```markdown
完成：
- 16:9: ...
- 9:16: ...

效果：
- ...

验收：
- ...

问题/限制：
- ...
```
