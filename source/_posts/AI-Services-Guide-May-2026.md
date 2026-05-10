---
title: "AI services guide: subscriptions, free tiers, and APIs (May 2026)"
date: 2026-05-09 12:00:00
categories:
- AI
tags:
- ai
- api
- llm
- subscription
- agent
---

A May 2026 snapshot of every major AI provider, with the eight weeks of releases since the {% post_link AI-Services-Guide-March-2026 "March guide" %} and a deeper look at the platform stacks behind the top providers.

<!-- more -->

## Eight weeks that aged the March guide

I shipped the {% post_link AI-Services-Guide-March-2026 "March 2026 guide" %} the week Claude Opus 4.6 still felt new. Two months later it's already a previous-generation model, and most of the interesting movement is around the model rather than inside it.

### New flagship models

- **Claude Opus 4.7** ([April 16](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7)). Same $5 / $25 per 1M tokens, but 1M context is now standard with no long-context premium, image input goes to 2,576 px / 3.75 MP, and a new "task budgets" feature shows the model a token countdown for the full agentic loop (thinking + tool calls + output). SWE-bench Pro went 53% to 64%. The catch buried in the release: the new tokenizer can use up to 35% more tokens for the same text, so the per-token rate held but effective cost can creep.
- **GPT-5.5** ([April 23](https://openai.com/index/introducing-gpt-5-5/)) at $5 / $30, 1M context in the API, 400K in Codex. Anything past 272K input flips to 2x input / 1.5x output for the rest of the session. **GPT-5.5 Pro** at $30 / $180 for extended reasoning. **GPT-5.5 Instant** ([May 5](https://openai.com/index/gpt-5-5-instant/)) replaces GPT-5.3 Instant as the free-tier default, with the headline being lower hallucination rates in legal / medical / financial answers at the same latency.
- **DeepSeek V4 Preview** ([April 24](https://api-docs.deepseek.com/news/news260424)). V4-Flash (284B / 13B active) at $0.14 / $0.28 with cache hits at $0.0028. V4-Pro (1.6T / 49B active) at list price $1.74 input / $3.48 output, currently 75% off through May 31 ($0.435 / $0.87). Both ship with 1M context and 384K max output. Legacy `deepseek-chat` and `deepseek-reasoner` endpoints retire July 24. DeepSeek also disclosed [a Huawei Ascend 950 hardware partnership](https://www.cnbc.com/2026/04/24/deepseek-v4-llm-preview-open-source-ai-competition-china.html) covering part of the V4 training run.
- **Mistral Medium 3.5** ([April 29](https://mistral.ai/news/vibe-remote-agents-mistral-medium-3-5)). 128B dense, 256K context, 77.6% on SWE-Bench Verified, ahead of Devstral 2 and Qwen3.5 397B-A17B. It's the first Mistral "merged" model: instruction following, reasoning, and coding behind one set of weights, with a per-request reasoning-effort knob. It replaces Mistral Medium 3.1 and Magistral in Le Chat and Devstral 2 in Vibe; powers the new Vibe remote agents.
- **Qwen3.6-Plus** ([April 2](https://www.alibabacloud.com/blog/alibaba-unveils-qwen3-6-plus-to-accelerate-agentic-ai-deployment-for-enterprises-and-alibaba%E2%80%99s-ai-applications_603000)) with a 1M default context and an agentic-coding focus. **Qwen3.6-35B-A3B** (April 16) under Apache 2.0. Qwen3.5-Omni also dropped, but only on the Alibaba Cloud platform.
- **Meta Muse Spark** ([April 8](https://ai.meta.com/blog/introducing-muse-spark-msl/)). Meta's first proprietary closed-weight model from the new Superintelligence Labs unit. Available only on meta.ai. The Llama line continues, but Muse Spark is the real strategic break with "weights for everyone."

### New agent infrastructure

- **Anthropic Managed Agents** went public beta on [April 8](https://platform.claude.com/docs/en/managed-agents/overview) at $0.08 per session-hour plus tokens. May 6 added [three more pieces](https://claude.com/blog/new-in-claude-managed-agents): **Dreaming** (Claude reviews past sessions to find patterns and self-improve), **Outcomes** (you write a success rubric and a separate grader evaluates the agent's output in its own context window, pinpointing what to fix; up to 10 pp gain over a standard prompting loop), and **Multiagent Orchestration** (a lead agent decomposes work and delegates to specialists with their own model / prompt / tools). This is the first time Anthropic has shipped a hosted runtime, not just a coding tool.
- **[Claude Code on the web](https://code.claude.com/docs/en/claude-code-on-the-web)** runs at claude.ai/code. Sessions persist when you close the browser, and the iOS app monitors them.
- **Cursor 3** (April 2) added a dedicated Agents Window with parallel agents on cloud VMs, `/worktree` for isolated branch changes, and self-hosted runners. Multiple agents at once across multiple repos is the headline shift.
- **OpenAI Codex** picked up background computer use, an in-app browser, GitHub PR reviews, image generation, 90+ plugins, and an automatic-approval reviewer agent that handles routine permission prompts before they reach you. GPT-5.5 is the recommended model.
- **Claude Cowork** got an Enterprise group / role layer (with SCIM provisioning), a Zoom connector that pulls AI Companion meeting summaries into the agent context, and ten ready-to-run finance agent templates available across Cowork, Claude Code, and Managed Agents.

### New ideas

- **Claude [Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)**. Reusable filesystem-based capabilities packaged as `SKILL.md`. Progressive disclosure means Claude only loads a skill when it looks relevant. The same files now run inside Claude Code, Cursor, Codex CLI, Gemini CLI, and Antigravity, so it's effectively a portable standard rather than an Anthropic-only feature.
- **MCP changed hands**. Anthropic [donated](https://www.anthropic.com/news/donating-the-model-context-protocol-and-establishing-of-the-agentic-ai-foundation) the Model Context Protocol to the Linux Foundation's new Agentic AI Foundation, co-founded with OpenAI and Block, and backed by Google, Microsoft, AWS, Cloudflare, and Bloomberg. The Linux Foundation reports more than 10,000 active public MCP servers; the Python SDK alone passed 164 million monthly downloads in April. **MCP Apps** (interactive iframe / widget UI rendered inline in chat) shipped at the start of the year and is now a real authoring target.
- **The desktop super-app**. OpenAI confirmed in March it's [merging](https://thetechportal.com/2026/03/20/openai-could-launch-a-desktop-super-app-integrating-chatgpt-codex-and-the-atlas-browser/) ChatGPT, Codex, and the Atlas browser into a single desktop application. Atlas itself is on macOS now with multi-account support and an optional agent mode that drives the browser.

### Strategic moves

- **SpaceX [acquired](https://www.cnbc.com/2026/02/02/elon-musk-spacex-xai-ipo.html) xAI** on February 2 (announced; $1.25T combined valuation). **Grok 4.3** Beta rolled out as Early Access for SuperGrok / Premium+ on April 17, with formal launch [April 30](https://artificialanalysis.ai/articles/xai-launches-grok-4-3-with-improved-agentic-performance-and-lower-pricing) at $1.25 / $2.50 per 1M (with 2x premium past 200K input), aggressive pricing aimed straight at GPT-5.5 / Opus 4.7. Grok 5 (6T parameters, MoE, trained on the gigawatt-scale Colossus 2 cluster) slipped from Q1 to a Q2 public beta, expected May or June.
- **xAI's [Anysphere option](https://en.wikipedia.org/wiki/XAI_(company))** (April 21). xAI struck a deal for the right to acquire Cursor's parent company Anysphere for $60B later this year, the first time a frontier model lab has lined up a third-party agent vendor on its balance sheet.
- **Sora is winding down**. The standalone Sora app shut down [April 26](https://en.wikipedia.org/wiki/Sora_(text-to-video_model)); the API ends September 24, 2026. Reporting on the unit economics ranged from "around $1M/day" (early estimates) to ["$15M/day in inference costs against ~$2.1M lifetime revenue"](https://medium.com/@shubhamnv2/openai-sora-shutdown-15m-day-costs-2-1m-revenue-the-full-story-088380118243); active users had also fallen from ~1M to under 500K, and Disney pulled a $1B character-licensing deal. OpenAI says video generation continues inside ChatGPT under a model codenamed Spud.
- **Perplexity Comet** went free across iOS, Android, Mac, and Windows; the [iPad build](https://9to5mac.com/2026/04/28/perplexity-just-gave-its-comet-ai-browser-an-upgrade-for-ipad-users-with-these-features/) (April 28) supports multi-window. Samsung's Galaxy S26 wires Perplexity into Bixby and Samsung Internet at the OS level, the first OS-level distribution deal for a non-OpenAI/Google AI provider.

The headline pattern: less "new model, higher price, more capabilities" and more "same price, faster shipping cadence, much wider product surface." Nearly every interesting difference now sits around the model.

---

## Two ways to use AI models

Two layers, two bills:

1. **Chat product**, the app you talk to (ChatGPT, Claude, Gemini, Grok, Le Chat, Qwen, Copilot, Perplexity, Nova, DeepSeek). Free tiers exist; paid subscriptions ($8-$300/mo) unlock premium models, higher limits, and product-side features like image gen, voice, video, and agents.
2. **API**, pay-per-token programmatic access for building apps. Separate billing, separate account, separate pricing.

Three overlaps, all small. Google AI Pro / Ultra subscribers get $10 / $100 per month in Google Cloud credits toward Gemini API usage. Perplexity Pro subscribers get $5/month in API credits. xAI Business tier ($30-300/seat) bundles API access. Everyone else: your subscription only buys the chat app.

---

## Quick comparison

| Provider | Chat product | Cheapest API (in/out per 1M) | Free API tier | Max context | Open weights |
|----------|-------------|------------------------------|--------------|-------------|-------------|
| **Google Gemini** | Gemini | $0.10 / $0.40 (Flash-Lite 2.5) | Unlimited, no card | 1M | Gemma 4 |
| **OpenAI** | ChatGPT | $0.05 / $0.40 (GPT-5 Nano) | Limited trial credits | 1M (400K Codex) | GPT-OSS (Apache 2.0) |
| **Anthropic** | Claude | $1 / $5 (Haiku 4.5) | $5 trial credits | 1M (Opus 4.7 standard) | No |
| **xAI** | Grok | $0.20 / $0.50 (Grok 4.1 Fast) | $25 sign-up credits | 2M | Partial (Grok 1, 2.5) |
| **DeepSeek** | DeepSeek | $0.14 / $0.28 (V4-Flash) | 5M tokens free | 1M | Yes (MIT) |
| **Mistral** | Le Chat | $0.02 / $0.04 (Nemo) | API trial credits | 256K | Partial |
| **Meta** | -- | Free (self-host) | Models are free | 10M (Llama 4 Scout) | Yes (Llama); Muse Spark closed |
| **Alibaba Qwen** | Qwen | $0.05 / $0.20 (Qwen3-8B) | 1M tokens/model | 1M (Qwen3.6-Plus) | Yes (Apache 2.0) |
| **Amazon Nova** | Nova | $0.035 / $0.14 (Nova Micro) | $200 AWS credits | 1M (Premier / Nova 2) | No |
| **Microsoft Phi** | Copilot | $0.075 / $0.30 (Phi-4-mini) | GitHub Models free | 128K | Yes (MIT) |
| **Perplexity** | Perplexity | $1 / $1 (Sonar) + per-req fee | No free tier | 200K | No |
| **Groq** | -- | $0.05 / $0.08 (Llama 3.1 8B) | Rate-limited, no card | 256K | Hosts OSS only |

{% note info %}
**"Open weights" vs "open source"**: most providers in the column above release **open weights** (model parameters you can download and run) but not full training code or data. Apache 2.0 / MIT models (Qwen, DeepSeek, Phi, GPT-OSS, Gemma 4) are the closest to true open source. Llama uses a more restrictive community license. Anthropic, Amazon, Perplexity, and now Meta's Muse Spark line release nothing.
{% endnote %}

---

## Subscription comparison

### All providers at a glance

| Provider | Chat product | Free tier | Cheapest paid | ~$20 tier | High-end |
|----------|-------------|-----------|--------------|-----------|----------|
| **Google Gemini** | [Gemini](https://gemini.google.com) | 50 daily credits | AI Plus $8/mo | AI Pro $20/mo | AI Ultra $250/mo |
| **OpenAI** | [ChatGPT](https://chatgpt.com) | GPT-5.5 Instant, ~10 msgs / 5 hrs | Go $8/mo | Plus $20/mo | Pro $200/mo |
| **Anthropic** | [Claude](https://claude.ai) | ~15-40 msgs / 5 hrs | -- | Pro $20/mo | Max 20x $200/mo |
| **xAI** | [Grok](https://grok.com) | ~10 msgs / 2 hrs | X Premium $8/mo | SuperGrok $30/mo | Heavy $300/mo |
| **DeepSeek** | [DeepSeek](https://chat.deepseek.com) | Unlimited (no sub) | -- | -- | -- |
| **Mistral** | [Le Chat](https://chat.mistral.ai) | ~25 msgs | Student $6/mo | Pro $15/mo | Enterprise (custom) |
| **Meta** | [meta.ai](https://meta.ai) | Free (Muse Spark) | -- | -- | -- |
| **Alibaba Qwen** | [Qwen](https://chat.qwen.ai) | Unlimited (no sub) | -- | -- | -- |
| **Amazon Nova** | [Nova](https://nova.amazon.com) | Free (US only) | -- | -- | -- |
| **Microsoft** | [Copilot](https://copilot.microsoft.com) | Limited GPT-5.x | -- | Copilot Pro $20/mo | M365 Enterprise $30/seat/mo |
| **Perplexity** | [Perplexity](https://www.perplexity.ai) | Limited Pro Searches | -- | Pro $20/mo | Max $200/mo |
| **Groq** | -- | Rate-limited API | Pay-as-you-go | -- | -- |

### What ~$20 actually buys

| Feature | ChatGPT Plus ($20) | Claude Pro ($20) | Gemini AI Pro ($20) | SuperGrok ($30) | Le Chat Pro ($15) | Copilot Pro ($20) | Perplexity Pro ($20) |
|---------|-------------------|-----------------|-------------------|----------------|------------------|------------------|---------------------|
| Top model | GPT-5.5 Thinking | Opus 4.7 | Gemini 3.1 Pro | Grok 4.20 / 4.3 (rolling) | Mistral Medium 3.5 | GPT-5.x | Opus 4.7, GPT-5.5, Gemini 3.1 |
| Context | 32K (196K Thinking) | 200K (1M opt-in via /extra-usage) | 1M | 128K | 256K | -- | 200K |
| Image gen | gpt-image-1 (~180/day) | No | Nano Banana 2 | Aurora / Imagine | Yes | gpt-image-1 (M365 only) | Yes |
| Video gen | Limited (Spud preview) | No | Veo 3.1 (limited) | Imagine (720p, 6s) | No | No | Yes |
| Voice mode | Advanced (video / screen) | No | Yes | Extended | No | No | No |
| Web search | Yes | Yes | Deep Search | DeepSearch | AFP-verified | Bing | Grounded (citations) |
| Coding agent | Codex | Claude Code | Jules (5x) + Antigravity | Grok Build (waitlist) | Vibe remote agents | -- | -- |
| Deep reasoning | GPT-5.5 Thinking | Extended Thinking | Deep Research | Big Brain Mode | Configurable per request | -- | Deep Research |
| No training | No | Yes | No | No | Yes (Pro tier) | No | No |
| API credits | No | No | $10/mo GCP | No | No | No | $5/mo |
| Unique value | Atlas browser + super-app | Skills + Cowork + Claude Code | Workspace + Antigravity + Jules | 2M context, X data | Cheapest, no telemetry, EU | M365 integration | Multi-model + Comet browser |

The interesting column changes since March: ChatGPT Plus dropped Sora video and gained an AI browser; Claude Pro added Skills and a 1M default context on Opus 4.7; Gemini AI Pro added Antigravity at no extra cost; Perplexity Pro added Comet on every device.

**High-end tiers**: Claude Max 20x ($200) for near-unlimited Opus 4.7 plus Claude Code. ChatGPT Pro ($200) for unlimited everything. Google AI Ultra ($250) for 25K credits, Deep Think, multi-agent Jules, YouTube Premium. SuperGrok Heavy ($300) for Grok 4 Heavy multi-agent and (when it ships) priority Grok 5 access.

---

## Coding agents comparison

Every major provider ships one. The interesting change in the last two months is that the gap closed, mostly upward.

### First-party agents

| Agent | Provider | Type | Cheapest access | Rules | Memory | MCP | Sub-agents |
|-------|----------|------|----------------|-------|--------|-----|------------|
| [Codex](https://openai.com/index/introducing-codex/) | OpenAI | Cloud + IDE + browser | Plus $20/mo | `AGENTS.md` | Yes (browser memories) | Yes | Yes |
| [Claude Code](https://claude.com/product/claude-code) | Anthropic | Terminal CLI + web + mobile | Pro $20/mo | `CLAUDE.md`, Skills | Yes | Yes | Yes |
| [Jules](https://jules.google) | Google | Async GitHub | Free (15 tasks/day) | `AGENTS.md` | Partial | Yes | Multi-agent at AI Ultra |
| [Gemini CLI](https://geminicli.com) | Google | Terminal CLI | Free (1K req/day) | `GEMINI.md`, Skills | Yes | Yes | Yes |
| [Antigravity](https://developers.googleblog.com/build-with-google-antigravity-our-new-agentic-development-platform/) | Google | Agentic IDE | Free (preview) | Skills | Yes | Yes | Yes (manager surface) |
| [Grok Build](https://grokai.build) | xAI | Local CLI | Waitlist | `.grok/GROK.md` | Partial | Yes | Yes (8x) |
| [Vibe 2.0 + remote agents](https://mistral.ai/news/vibe-remote-agents-mistral-medium-3-5) | Mistral | CLI + cloud | Le Chat Pro $15/mo | `AGENTS.md` | No | Yes | Yes |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | Alibaba | Terminal CLI | Free (1K req/day) | `QWEN.md` | Yes | Yes | Yes |
| [Amazon Q Developer](https://aws.amazon.com/q/developer/) | Amazon | IDE + CLI | Free (50 agentic/mo) | `.amazonq/rules/` | Partial | Yes | No |

### Third-party agents

| Agent | Type | Pricing | Rules | Memory | MCP | Sub-agents |
|-------|------|---------|-------|--------|-----|------------|
| [Cursor 3](https://cursor.com) | VS Code fork + Agents Window | Free / Pro $20 / Ultra $200 | `.cursor/rules/*.mdc`, Skills | Yes | Yes | Yes (parallel) |
| [Windsurf](https://windsurf.com) | Agentic IDE | Free / Pro $15 / Teams $30 | `.windsurf/rules/*.md` | Yes | Yes | No |
| [GitHub Copilot](https://github.com/features/copilot/plans) | IDE + GitHub | Free / Pro $10 / Pro+ $39 | `.github/copilot-instructions.md` | Yes | Yes | Yes |
| [Cline](https://cline.bot) | VS Code extension | Free (BYOM) / Teams $20 | `.clinerules` | Yes | Yes | No |
| [Replit Agent 3](https://replit.com) | Hosted full-stack scaffolder (slower, ~3-10 min/prompt) | Free / paid tiers | -- | Yes | Yes | Yes |
| [Devin](https://devin.ai) | Autonomous task agent | $500/mo Team | -- | Yes | Yes | Yes |
| [OpenHands](https://github.com/OpenHands/OpenHands) | OSS agent platform (CLI + cloud) | Free (OSS, BYOM) / hosted Cloud | Skills (markdown) | Yes (event-sourced) | Yes | Yes |
| [Aider](https://aider.chat) | Terminal | Free (BYOM) | `CONVENTIONS.md` | No | Partial | No |

{% note info %}
**Skills format** (`SKILL.md`): now portable across Claude Code, Cursor, Gemini CLI, Codex CLI, and Antigravity. The same skill file invokes the same behaviour everywhere. This is the closest the agent ecosystem has come to a real cross-vendor standard, after MCP.

**Cloud sessions**: Claude Code, Codex, and Cursor 3 all ship cloud-hosted sessions on isolated VMs. The shape is converging: kick off a task, close the laptop, monitor from your phone, get a PR.
{% endnote %}

---

## Deep dive: what each top provider does beyond the model

The model is one component. Browser, desktop agent, IDE, mobile SDK, enterprise console, that's where the providers are diverging fast. Six are worth walking through.

### OpenAI: a desktop OS in waiting

[chatgpt.com](https://chatgpt.com) | [platform.openai.com](https://platform.openai.com) | [Atlas](https://chatgpt.com/atlas/)

OpenAI has the broadest product surface, and the announced direction is to collapse it into one desktop app.

- **[Atlas](https://chatgpt.com/atlas/)** is a Chromium-based AI browser, macOS today, with Windows / iOS / Android in the queue. Sidebar ChatGPT on every page; "browser memories" stores what you've looked at; an opt-in agent mode drives the browser for you (paid only). The March 2026 announcement of the [super-app](https://thetechportal.com/2026/03/20/openai-could-launch-a-desktop-super-app-integrating-chatgpt-codex-and-the-atlas-browser/) confirms ChatGPT, Codex, and Atlas merge into a single application: chat, code, browse, automate, all behind one window.
- **[Codex](https://openai.com/index/introducing-codex/)** is the most-changed agent in the field this spring. Background computer use, an in-app browser, GitHub PR reviews, image generation, 90+ plugins, and an automatic-approval reviewer agent that handles routine permission prompts. GPT-5.5 is the recommended model. Codex Cloud runs sessions on managed VMs.
- **[Apps SDK](https://platform.openai.com/docs/guides/apps-sdk)** (preview) lets you build apps that run inside ChatGPT, with the chat UI as the chrome. Distribution problem inverted: instead of getting users to install your app, you put it where they already type.
- **Realtime API** for client-side voice / text streaming over WebRTC. Build voice agents that handle interruptions natively.
- **ChatGPT Pulse** (Pro $200/mo) sends proactive briefings based on your context.
- **Sora sunset**. The standalone Sora app shut down April 26, the API ends September 24, 2026. Video generation continues inside ChatGPT (codename Spud) at lower fidelity and lower cost. OpenAI was, by their own framing, burning ~$1M/day on Sora compute, and the unit economics didn't shake out.

If you're shipping production: pure REST against the API, OpenAI-compatible client libraries everywhere. No first-party native iOS/Android SDK, but [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) is the standard Swift pick.

### Anthropic: agents, skills, and a coding-tool monoculture

[claude.ai](https://claude.ai) | [console.anthropic.com](https://console.anthropic.com) | [Skills repo](https://github.com/anthropics/skills)

The smallest model lineup of any major provider, paired with the most aggressive agent-platform investment.

- **[Claude Code](https://claude.com/product/claude-code)** is still the daily driver for many developers. Three new surfaces this spring: web at claude.ai/code with persistent cloud sessions, the iOS app for monitoring and resuming those sessions, and `CLAUDE.md` plus Skills auto-loaded from the project filesystem.
- **[Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)** package domain expertise as `SKILL.md` files with progressive disclosure. The agent only loads a skill when the task calls for it. Anthropic ships official Excel / Word / PowerPoint / PDF skills; the [GitHub repo](https://github.com/anthropics/skills) hosts thousands of community skills. Cross-tool portability is the real story: the same file works in Claude Code, Cursor, Codex CLI, Gemini CLI, and Antigravity.
- **[Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview)** (public beta April 8, $0.08/session-hour + tokens) is the hosted runtime: sandboxing, state persistence, permissions, error recovery, all behind a hosted session. May 6 added [**Dreaming**](https://claude.com/blog/new-in-claude-managed-agents) (Claude reviews past sessions to extract patterns and self-improve), **Outcomes** (rubric-driven grader runs in its own context window and pinpoints what to fix; +10 pp over a standard prompting loop in internal tests), and **Multiagent Orchestration** (lead agent decomposes work and delegates to specialists with their own model / prompt / tools). This is Anthropic's first real production deployment story.
- **[Cowork](https://claude.com/product/cowork)** is the desktop agent for non-developers: researchers, analysts, ops, legal, finance. It reads, edits, and creates files in folders you grant access to. April 9 brought general availability across all paid plans, Enterprise group / role provisioning via SCIM, and a [Zoom MCP connector](https://news.zoom.com/zoom-meeting-intelligence-in-claude/) that pulls meeting summaries, transcripts, and recordings into the agent's context. May 5 added ten ready-to-run finance agent templates plus Microsoft 365 add-ins for Excel, PowerPoint, and Word (Outlook coming soon).
- **[Claude Design](https://www.anthropic.com/news/claude-design-anthropic-labs)** (April 17), a collaborative visual creation tool at [claude.ai/design](https://claude.ai/design), powered by Opus 4.7. Prompts in, designs / prototypes / slides / one-pagers out. Available in research preview to Pro, Max, Team, and Enterprise.
- **[Mythos Preview](https://red.anthropic.com/2026/mythos-preview/)** (April 7) is Anthropic's most capable model yet, with cybersecurity capabilities so strong Anthropic is deliberately *not* releasing it broadly: Mythos has already been used to find thousands of zero-day vulnerabilities across major OSes and browsers. Instead, [**Project Glasswing**](https://www.anthropic.com/glasswing) bundles it with 12 launch partners (AWS, Apple, Broadcom, Cisco, CrowdStrike, Google, JPMorganChase, Linux Foundation, Microsoft, NVIDIA, Palo Alto Networks, plus Anthropic) and 40+ critical-infrastructure orgs, with $100M in usage credits and $4M in donations to OSS security work.
- **[Advisor tool](https://www.builder.io/blog/the-claude-advisor-pattern)** (API beta since April 9): Sonnet or Haiku executes; Opus advises on demand inside a single API call. Haiku-with-Opus-advisor more than doubles solo Haiku on SWE-bench Multilingual at 85% lower cost than running Sonnet directly.

No first-party mobile SDK. Seven server-side SDKs (Python, TypeScript, Java, Go, Ruby, C#, PHP). [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) is the de facto Swift package. **No model weights released**, ever, by design.

### Google: ecosystem maximalist

[gemini.google.com](https://gemini.google.com) | [AI Studio](https://aistudio.google.com) | [Antigravity](https://antigravity.google)

The widest product surface and the only first-party mobile SDK. Most of what's new this spring is around the model rather than a new flagship.

- **[Antigravity](https://developers.googleblog.com/build-with-google-antigravity-our-new-agentic-development-platform/)** is Google's agentic IDE, in public preview, free for individuals. Two surfaces: an Editor View with the usual tab completions, plus a Manager Surface where you spawn, orchestrate, and observe multiple agents working asynchronously across workspaces. Runs on Gemini 3.1 Pro / Flash by default. Claude Sonnet 4.6, Claude Opus 4.6, and GPT-OSS 120B are selectable from settings, billed through Google with no separate API key required, which is the unique part. (Caveat: [Opus 4.7 still hasn't shipped to the picker](https://discuss.ai.google.dev/t/claude-opus-4-7-has-been-available-for-24-hours-antigravity-is-now-the-only-major-ai-coding-tool-without-it/140842) three weeks after launch, leaving Antigravity as the only major coding tool without it.)
- **[Jules](https://jules.google)** is the async GitHub agent: ship it a task, it returns a PR. AI Pro gets 5x the free tier, AI Ultra gets 20x and multi-agent Jules.
- **Gemini Code Assist** in IDEs, **Gemini CLI** in the terminal, all free at hobbyist rate limits.
- **[Workspace AI](https://workspace.google.com/solutions/ai/)**: Gemini directly in Gmail, Docs, Sheets, Slides, Meet, and Drive. The integration competitors haven't matched.
- **[NotebookLM](https://notebooklm.google.com)** for research workflows. AI Pro raises the cap to 500 notebooks / 300 sources / 500 queries/day; AI Ultra further.
- **[Cloud Next '26](https://cloud.google.com/blog/topics/google-cloud-next/welcome-to-google-cloud-next-26)** (April) introduced the **Gemini Enterprise Agent Platform** and eighth-generation TPUs, alongside [Gemma 4](https://blog.google/technology/developers/gemma-4/) (the most capable open model byte-for-byte, per Google).
- **Image and video gen**: [Nano Banana 2](https://blog.google) and Gemini 3.1 Flash Image Preview for fast image gen at low cost; Veo 3.1 for video; Gemini 3.1 Flash TTS for speech.
- **[Firebase AI Logic SDKs](https://firebase.google.com/products/firebase-ai-logic)** are still the only first-party mobile story for Gemini: Swift, Kotlin, Flutter, React Native, Unity, Web. Everyone else, you write REST.

Google I/O 2026 lands May 19. Gemini 3.5 hasn't shipped yet despite Polymarket bets and a Thomas Kurian "very, very soon" tease on April 24. Bet accordingly.

### xAI: the social-data play

[grok.com](https://grok.com) | [x.ai/api](https://x.ai/api)

The narrowest deep-dive in this list. xAI's value isn't a sprawling product surface, it's a corpus and a distribution channel nobody else has.

- **Real-time X data**. Grok is the only frontier-model chat with live access to the entire X firehose. For news, sentiment, market chatter, breaking events, this is genuinely differentiating.
- **Grok in Tesla**. In-vehicle voice assistant on Model 3 / Y / S / X / Cybertruck running recent firmware. Hands-on a steering wheel, the only competitor with this kind of car-cabin distribution is the Apple / Google / Amazon trio with their respective in-car offerings.
- **[Imagine](https://x.ai/imagine)**: text-to-image and 720p / 6-second video generation, available from SuperGrok onward.
- **Aurora** image editing in the chat interface.
- **SuperGrok Heavy** ($300/mo) runs Grok 4 Heavy multi-agent, the most expensive consumer subscription on the market. 256K context, 100% AIME 2025, dramatic priority routing.
- **OpenAI-compatible API** means any OpenAI client library works against [x.ai/api](https://x.ai/api). $25 sign-up credits; pay-as-you-go after.
- **SpaceX acquisition** (announced February 2). On paper, this folds xAI into a single Elon-controlled entity with deep-pocketed compute backing. Grok 5 (6T params, MoE on Colossus 2) is targeting a Q2 public beta, expected May or June.

If you're using Grok in a product: Grok 4.20 still offers a 2M-token context window (the largest among hosted closed-weight models; Llama 4 Scout's 10M is open-weight self-host), while Grok 4.3 is 1M. The per-request fee structure is leaner than Perplexity's.

### Microsoft: where work already lives

[copilot.microsoft.com](https://copilot.microsoft.com) | [GitHub Models](https://github.com/features/models) | [Azure AI Foundry](https://azure.microsoft.com/en-us/products/ai-foundry/)

Microsoft's strategy is to be the cheapest place to *deploy* anyone's model and the deepest place to integrate any AI into the apps people already use.

- **GitHub Copilot** is now a marketplace, not a single product. Free / Pro $10 / Pro+ $39. Pro+ includes an autonomous coding agent that creates PRs from issues, and you choose the underlying model (GPT-5.5, Claude Opus 4.7, Gemini 3.1, others) per task.
- **[GitHub Models](https://github.com/features/models)** is the easiest free playground in the industry: pick any of 30+ frontier and open models, get a chat UI plus an API endpoint, no credit card. Rate-limited (50-150 req/day) but enough for evaluation.
- **Microsoft 365 Copilot**: Copilot inside Word, Excel, PowerPoint, Outlook, Teams. New this spring: meeting recap, a redesigned Edge with built-in Copilot controls, AI-generated icons, multi-agent workflows, richer connector understanding, Foundry agents, expanded Copilot Studio extensibility. None of this is replicable on a competitor stack.
- **[Azure AI Foundry](https://azure.microsoft.com/en-us/products/ai-foundry/)** hosts your model, anyone's model, including direct competitors. GPT-5.5, Claude, Gemini, Llama, Mistral, Qwen, all behind one billing relationship and one compliance posture.
- **[Copilot Studio](https://www.microsoft.com/en-us/microsoft-copilot/microsoft-copilot-studio)** for low-code agent building. The 2026 release wave 1 added publishing pipelines, multi-agent orchestration, governance controls.
- **Phi-Silica** on Copilot+ PCs runs Microsoft's small models (Phi-4-mini, Phi-4-multimodal) on the device's NPU, on Windows, with no network call. The first credible Apple Intelligence equivalent on the PC side.
- **MAI-1**, Microsoft's own ~500B frontier model, is internal so far; the [Phi family](https://huggingface.co/microsoft/phi-4) (MIT-licensed, 3.8B-14B) covers the open-weight position.

For app developers: ONNX Runtime Mobile (CoreML on iOS, NNAPI on Android) is Microsoft's pre-quantized on-device pipeline.

### Perplexity: search-shaped surface

[perplexity.ai](https://www.perplexity.ai) | [docs.perplexity.ai](https://docs.perplexity.ai) | [Comet](https://www.perplexity.ai/comet)

Perplexity is the only top-tier provider that doesn't really sell its own model. The pitch is shape: every response is grounded in citations, every product is search-first, and the subscription gives you third-party models in one place.

- **[Comet](https://www.perplexity.ai/comet)** went free across iOS, Android, Mac, and Windows this spring. The April 28 [iPad build](https://9to5mac.com/2026/04/28/perplexity-just-gave-its-comet-ai-browser-an-upgrade-for-ipad-users-with-these-features/) added multi-window and Split View. Comet hit #3 overall on the US App Store within 48 hours of iOS launch.
- **Samsung Galaxy S26** is the first phone to integrate Perplexity at the OS level: Bixby uses Perplexity for real-time search and reasoning, and Samsung Internet inherits Comet's agentic browsing. This is the first OS-level distribution deal a non-OpenAI / non-Google AI provider has landed.
- **Multi-model access in Pro**. $20/mo unlocks GPT-5.5, Claude Opus 4.7, Sonnet 4.6, and Gemini 3.1 Pro through one interface. If you only want one chat sub and want to compare models, this is the strongest value proposition, full stop.
- **Computer** (Max $200/mo) is Perplexity's multi-agent system: spawn long-running agents that browse, research, and synthesize, with citations that survive the full chain.
- **Spaces** for shared research workspaces and **Comet Plus** for premium publisher access (NYT, Reuters, etc.) without separate subscriptions.
- **[Search API](https://docs.perplexity.ai/api-reference/search-post)** at $5/1K requests gives you raw web results without the generation layer. Useful as a grounding primitive for your own agents.
- **API credits**: $5/month included with Pro, the only ~$20 sub that bundles them.

API itself is hybrid pricing: tokens *plus* per-request fees ($5-$14 per 1K calls depending on model and search depth). Pure token-based providers usually beat it on price-per-call; Perplexity wins on retrieval quality.

---

## What I'd actually pick

**Free chat**: DeepSeek and Qwen still give you the most for $0. DeepSeek V4 in the chat app is unlimited. Gemini's free API is the most generous of the API-side free tiers.

**One $20 sub**: Claude Pro is the strongest single sub for builders, with Skills, Cowork, Claude Code on web + mobile, and Opus 4.7 at 200K context (1M opt-in via `/extra-usage`; the auto-1M default is Max-and-up). Plus is the broadest if you want everything-in-one. Perplexity Pro stretches the dollar by giving you GPT-5.5, Opus 4.7, and Gemini 3.1 in one interface plus the Comet browser. Le Chat Pro at $15 stays the cheapest with no telemetry.

**Coding**: Claude Code is still the daily driver here. Cursor 3's Agents Window matches it on parallelism and beats it on inline UX. Codex is the gap-closer of 2026, the April update made it credible for agentic tasks for the first time. Antigravity is the wildcard if you live in Google's ecosystem.

**Production app**: Google's Firebase AI Logic remains the only first-party native mobile SDK story. Everyone else is REST or community packages. If your app is Mac/Windows desktop and AI-first, the OpenAI super-app architecture and Anthropic's Skills + Managed Agents are both betting that you'll integrate at a chat-shaped surface, not a chat completion endpoint.

**Open weights**: DeepSeek V4 (MIT, 1M context, hardware-portable), Qwen3.6-35B-A3B (Apache 2.0, agentic), Gemma 4, Llama 4 Scout (10M context if you can afford to run it), Phi-4 family (MIT, the best small models). Meta's Muse Spark is the news that *isn't* on this list, and probably won't be.

The mental shift since March: I now pick a provider partly for its model and largely for what it bundles. Anthropic for skills + agents. Google for Workspace. OpenAI for browser + super-app. Microsoft for M365 and GitHub. xAI for X data and Tesla. Perplexity for grounded search and Comet. Run two or three subs without much overlap, because each is reaching for a different surface.

Eight more weeks and the model column will turn over again. The platform column won't.
