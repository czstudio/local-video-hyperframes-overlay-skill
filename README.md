# local-video-hyperframes-overlay

本仓库是一个可直接安装到 agent skills 目录的本地视频动效叠加 SOP。

它用于把 HyperFrames/HTML/Remotion 风格动效叠加到已有 talking-head 视频上，重点约束包括：

- 原视频主体必须清晰，不能被独立动画替代。
- 人物画面只能出现一次，不能用同一个人物视频做模糊背景。
- 人像必须在人物画面内居中。
- 屏幕文字必须精简，参考 YouTube 科技/AI 教学开场：大字、半透明高级感、底部 glass 字幕条、少量 HUD。
- 长渲染前先产出 `segment-plan.md`，让用户确认字幕文案、智能分段、顶部进度条 label、图表/信息卡点位和理由。
- 顶部进度条按文案语义分段显示，使用细 glass track、当前段高亮和跑步小人 marker。

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
5. 安装后请回复：已安装 local-video-hyperframes-overlay，并说明 SKILL.md 的绝对路径。

不要只阅读 GitHub 页面；必须真正复制 skill 文件到本地 skills 目录。
```

## Files

- `local-video-hyperframes-overlay/SKILL.md`: main SOP.
- `references/visual-reference.md`: reference-image visual rules.
- `references/qa-checklist.md`: required verification gates.
- `references/progress-segmentation.md`: subtitle segmentation, chart planning, and runner progress bar rules.
- `templates/kimi-task-prompt.md`: prompt template for Kimi or similar models.
- `templates/install-prompt.md`: natural-language install prompt.
- `scripts/make-contact-sheet.sh`: QA contact-sheet helper.
