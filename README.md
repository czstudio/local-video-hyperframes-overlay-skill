# local-video-hyperframes-overlay

本仓库是一个可直接安装到 agent skills 目录的本地视频动效叠加 SOP。

它用于把 HyperFrames/HTML/Remotion 风格动效叠加到已有 talking-head 视频上，重点约束包括：

- 原视频主体必须清晰，不能被独立动画替代。
- 人物画面只能出现一次，不能用同一个人物视频做模糊背景。
- 人像必须在人物画面内居中。
- 只输出 `16:9` 横屏，不再生成 `9:16` 或竖屏版本。
- 人物画面不能失真：禁止非等比拉伸、强裁大头、头发/脸侧/下巴贴边。
- 屏幕文字必须精简，参考 YouTube 科技/AI 教学开场：大字、半透明高级感、底部 glass 字幕条、少量 HUD。
- 长渲染前先产出 `segment-plan.md`，让用户确认字幕文案、智能分段、顶部进度条 label、图表/信息卡点位和理由。
- 顶部进度条按文案语义分段显示，使用细 glass track、当前段高亮和跑步小人 marker。
- 没有 SRT 时，按 `references/transcription.md` 使用 `uv run --with faster-whisper` + `Systran/faster-whisper-small` 下载/使用语音转字幕模型，先出 `captions.raw.srt/json`，再清理为 `captions.cleaned.srt/json`。
- 成片 QA 通过后默认通过飞书/OpenClaw/Codex bridge 回传 `final-16x9.mp4`；成功只认真实 `message_id`。
- 如果用户直接在 OpenClaw 或 Codex bridge 发视频，必须把入站附件当 `source_video` 处理，并回复同一个会话。

## Install

```bash
mkdir -p ~/.agents/skills && tmp="$(mktemp -d)" && git clone https://github.com/czstudio/local-video-hyperframes-overlay-skill "$tmp/local-video-hyperframes-overlay-skill" && cp -R "$tmp/local-video-hyperframes-overlay-skill/local-video-hyperframes-overlay" ~/.agents/skills/
```

确认：

```bash
test -f ~/.agents/skills/local-video-hyperframes-overlay/SKILL.md && echo "installed"
```

## Natural Language Install Prompt

把这段话发给 Codex、Kimi、Claude Code 或其他有终端/文件权限的 agent：

```text
请安装这个 skill：

GitHub: https://github.com/czstudio/local-video-hyperframes-overlay-skill
Skill name: local-video-hyperframes-overlay

安装要求：
1. 把仓库里的 local-video-hyperframes-overlay 文件夹复制到你的 skills 目录。
2. 确认最终路径里存在 ~/.agents/skills/local-video-hyperframes-overlay/SKILL.md。
3. 以后凡是我说“给本地视频叠 HyperFrames/科技感字幕/YouTube AI 教学开场动效”，都必须先使用这个 skill。
4. 长视频生成前，必须先给我确认 segment-plan.md：字幕校正文案、智能分段、顶部进度条 label、图表/信息卡点位和理由。
5. 这个 skill 只能输出 16:9 横屏；禁止生成 9:16/竖屏版本，禁止把人物画面强裁、拉伸或放大到失真。
6. 没有 SRT 时，必须先阅读 references/transcription.md，按里面的 uv run --with faster-whisper + Systran/faster-whisper-small 下载/使用语音转字幕模型，生成 captions.raw.srt/json 和 captions.cleaned.srt/json 后，才能进入分段和渲染。
7. 如果 OPENAI_API_KEY 缺失或 openai-whisper 模型 checksum 失败，不要编字幕、不要跳过字幕，改用 faster-whisper；仍失败就报告 blocker。
8. 每次剪好视频后，必须按 references/delivery.md 通过飞书/OpenClaw/Codex bridge 把 final-16x9.mp4 发回给我；成功只认真实 message_id，失败要写 blocked 和本地成片路径。
9. 如果我是直接在 OpenClaw 或 Codex bridge 里发视频，必须自动读取入站附件，调用这个 skill 处理，再回复同一个飞书/bridge 会话，不要让我重复提供路径。
10. 安装后请回复：已安装 local-video-hyperframes-overlay，并说明 SKILL.md 的绝对路径。

不要只阅读 GitHub 页面；必须真正复制 skill 文件到本地 skills 目录。
```

## Files

- `local-video-hyperframes-overlay/SKILL.md`: main SOP.
- `references/visual-reference.md`: reference-image visual rules.
- `references/qa-checklist.md`: required verification gates.
- `references/progress-segmentation.md`: subtitle segmentation, chart planning, and runner progress bar rules.
- `references/transcription.md`: faster-whisper small download, cache, transcription, and failure handling.
- `references/delivery.md`: Feishu/OpenClaw/Codex bridge delivery, source-context reply, and message_id truth gate.
- `templates/kimi-task-prompt.md`: prompt template for Kimi or similar models.
- `templates/install-prompt.md`: natural-language install prompt.
- `scripts/make-contact-sheet.sh`: QA contact-sheet helper.
