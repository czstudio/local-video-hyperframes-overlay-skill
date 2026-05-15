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
5. 安装后请回复：
   已安装 local-video-hyperframes-overlay，并说明 SKILL.md 的绝对路径。

不要只阅读 GitHub 页面；必须真正复制 skill 文件到本地 skills 目录。
```

一行命令版本：

```bash
mkdir -p ~/.agents/skills && tmp="$(mktemp -d)" && git clone https://github.com/czstudio/local-video-hyperframes-overlay-skill "$tmp/local-video-hyperframes-overlay-skill" && cp -R "$tmp/local-video-hyperframes-overlay-skill/local-video-hyperframes-overlay" ~/.agents/skills/
```
