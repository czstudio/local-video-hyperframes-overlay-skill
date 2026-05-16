# Natural Language Install Prompt

把下面这段话发给 Codex、Kimi、Claude Code 或其他有终端/文件权限的 agent：

```text
请安装这个 skill：

GitHub: https://github.com/czstudio/local-video-hyperframes-overlay-skill
Skill name: local-video-hyperframes-overlay

安装要求：
1. 把仓库里的 local-video-hyperframes-overlay 文件夹复制到你的 skills 目录。
   - Codex/Agents 常见目录：~/.agents/skills/
   - 如果你的 agent 有自定义 skills-dir，请复制到那个目录。
2. 确认最终路径里存在：
   ~/.agents/skills/local-video-hyperframes-overlay/SKILL.md
3. 以后凡是我说“给本地视频叠 HyperFrames/科技感字幕/YouTube AI 教学开场动效”，都必须先使用这个 skill。
4. 长视频生成前，必须先给我确认 `segment-plan.md`：字幕校正文案、智能分段、顶部进度条 label、图表/信息卡点位和理由。
5. 这个 skill 只能输出 16:9 横屏；禁止生成 9:16/竖屏版本，禁止把人物画面强裁、拉伸或放大到失真。
6. 没有 SRT 时，必须先阅读 `references/transcription.md`，按里面的 `uv run --with faster-whisper` + `Systran/faster-whisper-small` 下载/使用语音转字幕模型，生成 `captions.raw.srt/json` 和 `captions.cleaned.srt/json` 后，才能进入分段和渲染。
7. 如果 `OPENAI_API_KEY` 缺失或 `openai-whisper` 模型 checksum 失败，不要编字幕、不要跳过字幕，改用 faster-whisper；仍失败就报告 blocker。
8. 每次剪好视频后，必须按 `references/delivery.md` 通过飞书/OpenClaw/Codex bridge 把 `final-16x9.mp4` 发回给我；成功只认真实 `message_id`，失败要写 blocked 和本地成片路径。
9. 如果我是直接在 OpenClaw 或 Codex bridge 里发视频，必须自动读取入站附件，调用这个 skill 处理，再回复同一个飞书/bridge 会话，不要让我重复提供路径。
10. 安装后请回复：
   已安装 local-video-hyperframes-overlay，并说明 SKILL.md 的绝对路径。

不要只阅读 GitHub 页面；必须真正复制 skill 文件到本地 skills 目录。
```

一行命令版本：

```bash
mkdir -p ~/.agents/skills && tmp="$(mktemp -d)" && git clone https://github.com/czstudio/local-video-hyperframes-overlay-skill "$tmp/local-video-hyperframes-overlay-skill" && cp -R "$tmp/local-video-hyperframes-overlay-skill/local-video-hyperframes-overlay" ~/.agents/skills/
```
