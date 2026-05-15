# Progress Segmentation And Runner Bar

Use this reference when the video needs a top progress bar, semantic sections, or chart/info-card planning before render.

## Goal

The progress bar should help the viewer know where they are in the story. It is not a decorative loading bar.

Before rendering the full video, generate `segment-plan.md` and ask the user to confirm it unless the user explicitly says to render directly.

## Required Planning Flow

1. Read or create `captions.cleaned.srt`.
2. Correct obvious transcript errors, especially product names, people names, domain terms, numbers, and CTA words.
3. Split the transcript into 5-8 semantic segments.
4. For each segment, choose one display label and one screen message.
5. Mark any chart/info-card insertion. If no chart is needed, write `none`.
6. Ask for confirmation before full render.

Do not skip this planning gate. It prevents wrong text, repeated text, and irrelevant charts from being baked into a long render.

## `segment-plan.md` Schema

Use this table:

| Segment | Time Range | Progress Label | Transcript Summary | Headline | Accent | Support | Chart / Info Card | Person Position / Transition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | `00:00-00:08` | `钩子` | ... | ... | ... | ... | `none` or `00:06 comparison card: ...` | `center, none` |

Then add:

- `Corrected terms`: list transcript fixes.
- `Progress bar style`: track, active color, label placement, runner asset.
- `Chart rationale`: why each chart helps; delete charts that only decorate.
- `Awaiting confirmation`: tell the user rendering will start after confirmation.

## Segment Rules

- Use content meaning, not equal time slices.
- Put the strongest hook in the first segment.
- Keep labels short: 2-5 Chinese chars is best.
- A segment label should name the viewer's current stage, such as `钩子`, `问题`, `证据`, `拆解`, `方法`, `案例`, `结论`.
- Avoid repeated labels like `重点1 / 重点2 / 重点3` unless the source script truly has numbered points.

## Chart And Info-Card Rules

Charts are allowed only when they clarify a concept, data relationship, before/after contrast, process, or decision.

Good chart types:

- `comparison card`: compare two choices or states.
- `before/after`: show a shift in method, cost, or outcome.
- `mini timeline`: show cause -> process -> result.
- `funnel`: show filtering, conversion, or narrowing.
- `checklist`: show a decision or execution list.
- `bar/sparkline`: show a trend or metric change.
- `definition card`: explain a term the viewer may not know.

Each chart entry must include:

- timestamp
- type
- exact text/content
- reason it is needed

V1 limit:

- 1-3 chart/info-card insertions across the whole video.
- At most one chart/info-card visible at a time.
- Delete any chart that repeats the headline, accent, support, or subtitle.

## Top Progress Bar Spec

Default visual style:

- Top safe area, usually `24-42px` from the top in 16:9 and `32-56px` in 9:16.
- Thin glass track with 1px translucent border and soft blur.
- Active segment in mint/cyan.
- Segment labels small and sparse; show all labels only if they fit cleanly.
- A running marker moves along the track.
- No percentage text unless the user asks.
- No dense node map, route map, or dashboard-style progress UI.

Motion:

```text
overall_progress = current_time / duration
runner_x = track_left + overall_progress * track_width
```

For segmented progress, highlight the active segment when:

```text
segment.start <= current_time < segment.end
```

The runner can move smoothly across the full track while segment highlight changes discretely.

## Runner Marker Options

Prefer simple and reusable options:

- `system emoji`: render `🏃‍♀️` or `🏃` as text. Fastest, no bundled asset, but appearance varies by platform.
- `Noto Emoji SVG`: open-source emoji assets. Source: `https://github.com/googlefonts/noto-emoji`. Record Noto Emoji and its license note in `report.md`.
- `Twemoji SVG/PNG`: clean cross-platform style. Source: `https://github.com/jdecked/twemoji`. Graphics are CC-BY-4.0, so record attribution/license in `report.md`.
- `pure CSS marker`: simple circle/person silhouette when asset licensing or rendering is a concern.
- `ProgressBar.js`: useful for SVG path animation. Source: `https://github.com/kimmobrunfeldt/progressbar.js`, MIT. Use it for the track only, not as a reason to over-design the UI.

Do not import a random CodePen/demo project into the skill. Use stable libraries/assets with clear licenses.

## Acceptance Gate

Fail the render if any are true:

- `segment-plan.md` was skipped when the user did not opt out.
- Progress labels do not match the transcript.
- Runner overlaps the speaker's face, main title, or subtitle.
- Progress bar is so bright or tall that it competes with the hook text.
- A chart appears without a timestamp and rationale.
- More than one chart/info-card is visible in V1.
- The screen text repeats the same phrase across headline, accent, support, chart, and subtitle.

Pass only when the progress bar is a clean content navigator and the chart plan is confirmed before rendering.
