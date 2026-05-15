# Visual Reference Rules

Use this when the user provides a reference image similar to a YouTube/AI teaching opener.

## What To Copy

- One talking-head video frame only.
- Centered person inside the talking-head frame.
- Large concise headline or key number on the open side of the frame.
- Semi-transparent premium typography: white at slightly reduced opacity, mint/green or cyan highlight, subtle shadow, thin underline.
- Small top-left label and thin line, like a light HUD marker.
- Bottom translucent subtitle bar that still shows the video through it.
- One short support line. Tags, callouts, info cards, or charts are off by default and only allowed when they add new information.
- Warm original video tone plus clean AI/tech HUD. It should feel like a high-quality YouTube tech/AI teaching opener.
- Strong opening: the most clickable idea appears in the first 0-8 seconds.
- Natural transitions: soft fade, glass wipe, subtle push, or a single person-position switch at a sentence boundary.

## What Not To Copy

- Do not duplicate the person as a blurred background.
- Do not crop the person so the face is stuck to the edge.
- Do not cover the face with metrics.
- Do not fill the whole screen with cards.
- Do not repeat the same idea in headline, accent, chips, metrics, callout, and subtitle.
- Do not leave wrong product names or obvious transcript mistakes on screen.
- Do not use noisy particle effects.
- Do not create a standalone animation that replaces the user's video.
- Do not turn the composition into a dark dashboard if the reference is a warm video frame with light translucent overlays.
- Do not use tiny text, opaque black boxes, heavy borders, or generic SaaS UI cards as the primary look.

## Horizontal Layout From Vertical Source

Recommended layout:

- Canvas: `1280x720` or `1920x1080`.
- Single video panel: right side or center-right.
- Person must be centered within that panel; adjust crop/scale from face center.
- Left side: title and one highlighted phrase. Metrics/chips are off by default.
- Background: dark/warm abstract color, subtle grid, or non-person surface.
- Subtitle: bottom center, glass bar.

If the source video is already horizontal:

- Keep full original frame.
- Place text in empty negative space.
- Do not crop face or important objects.
- If you crop into a panel, compute the crop from face center instead of taking the left/right half by default.
- Prefer a translucent wash over the original environment instead of replacing half the frame with an opaque panel.

## Reference-Style Acceptance

A frame passes only if it reads as:

- one clear talking-head video
- large semi-transparent hook text
- mint/cyan highlight or key number
- bottom glass subtitle
- sparse HUD/callout elements
- clean modern tech/AI opener
- sparse screen text: small label + large title + highlighted phrase + one support line
- no repeated wording across headline/accent/support/subtitle

If the frame reads as a generic dark dashboard, a template intro, or a standalone motion graphic, it fails.

## Text-Density Gate

Before rendering, compress each beat to this structure:

```text
micro label: 2-6 Chinese chars or a short product/context label
headline: 3-8 Chinese chars, one idea only
accent: one keyword, number, or short phrase
support: one short sentence under the underline
```

Default to no chips, no stat cards, no callout cards, and no chart. Add one extra element only when the viewer cannot understand the beat without it.

Fail examples:

- `没人用` appears in headline, accent, stat, and callout at the same time.
- `真实卖家/用户调研/闭门造车/访谈 0` are all shown together.
- product name is guessed and appears wrong on screen.

Pass examples:

- `做了几个月` + `没人用？` + `问题不在功能多，而在需求是不是真的。`
- `不是推广` + `没人需要` + `方向错了，打磨越久越危险。`
