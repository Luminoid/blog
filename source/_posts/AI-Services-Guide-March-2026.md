---
title: "AI services guide: subscriptions, free tiers, and APIs (March 2026)"
date: 2026-03-11 12:00:00
categories:
- AI
tags:
- ai
- api
- llm
- subscription
- agent
---

A detailed breakdown of every major AI provider in March 2026 -- free tiers, chat subscriptions, API pricing, coding agents, model capabilities, mobile SDKs, and open source status.

<!-- more -->

## Two ways to use AI models

Every provider offers two access layers. They are almost always billed separately:

1. **Chat product** -- the app you talk to (ChatGPT, Claude, Gemini, Grok, Le Chat, Qwen, Copilot, Perplexity, Nova). Every provider has a free tier with limited usage, and paid subscriptions ($8-300/mo) that unlock premium models, higher limits, and features like image gen, voice, and video.
2. **API** -- pay-per-token programmatic access for building apps. Separate billing, separate account, separate pricing.

The only overlaps: Google AI Pro/Ultra subscribers get Google Cloud credits ($10/$100 per month) toward Gemini API usage. Perplexity Pro subscribers get $5/month in API credits. Everyone else: your subscription gets you the chat app, not programmatic access.

## Quick comparison

| Provider | Chat product | Cheapest API (in/out per 1M) | Free API tier | Max context | Open source |
|----------|-------------|------------------------------|--------------|-------------|-------------|
| **Google Gemini** | Gemini | $0.10/$0.40 (Flash-Lite 2.5) | Unlimited, no card | 1M | Gemma (open weights) |
| **OpenAI** | ChatGPT | $0.10/$0.40 (GPT-4.1 Nano) | Limited trial credits | 1M+ | GPT-OSS (Apache 2.0) |
| **Anthropic** | Claude | $1/$5 (Haiku 4.5) | $5 trial credits | 200K (1M beta) | No |
| **xAI** | Grok | $0.20/$0.50 (Grok 4.1 Fast) | $25 sign-up credits | 2M | Partial |
| **DeepSeek** | DeepSeek | $0.028/$0.42 (V3.2 cached) | 5M tokens free | 128K | Yes (MIT) |
| **Mistral** | Le Chat | $0.02/$0.04 (Nemo) | API trial credits | 256K | Partial |
| **Meta Llama** | -- | Free (self-host) | Models are free | 10M (Scout) | Yes |
| **Alibaba Qwen** | Qwen | $0.05/$0.20 (Qwen3-8B) | 1M tokens/model | 10M (Qwen-Long) | Yes (Apache 2.0) |
| **Amazon Nova** | Nova | $0.035/$0.14 (Nova Micro) | $200 AWS credits | 1M (Premier) | No |
| **Microsoft Phi** | Copilot | $0.075/$0.30 (Phi-4-mini) | GitHub Models free | 128K | Yes (MIT) |
| **Perplexity** | Perplexity | $1/$1 (Sonar) + per-req fee | No free tier | 200K | No |
| **Groq** | -- | $0.05/$0.08 (Llama 3.1 8B) | Rate-limited, no card | 256K | Hosts OSS only |

{% note info %}
**"Open weights" vs "open source"**: The "Open source" column above uses industry shorthand. Strictly speaking, most providers release **open weights** (trained model parameters you can download and run) but not full training code or data. Here's the distinction:

| Term | Model weights | Training code | Training data |
|------|:---:|:---:|:---:|
| **Open weights** | ✓ | ✗ | ✗ |
| **Open source** (OSI definition) | ✓ | ✓ | ✓ |

In practice: Apache 2.0 / MIT models (Qwen, DeepSeek, Phi, GPT-OSS) are the closest to true open source. Gemma and Llama release weights under more restrictive licenses. Anthropic, Amazon, and Perplexity release no weights at all.
{% endnote %}

---

## Subscription comparison

### All 12 providers at a glance

| Provider | Chat product | Free tier | Cheapest paid | ~$20 tier | High-end |
|----------|-------------|-----------|--------------|-----------|----------|
| **Google Gemini** | [Gemini](https://gemini.google.com) | 50 daily credits | AI Plus $8/mo | AI Pro $20/mo | AI Ultra $250/mo |
| **OpenAI** | [ChatGPT](https://chatgpt.com) | ~10 msgs / 5 hrs | Go $8/mo | Plus $20/mo | Pro $200/mo |
| **Anthropic** | [Claude](https://claude.ai) | ~15-40 msgs / 5 hrs | -- | Pro $20/mo | Max 20x $200/mo |
| **xAI** | [Grok](https://grok.com) | ~10 msgs / 2 hrs | X Premium $8/mo | SuperGrok $30/mo | Heavy $300/mo |
| **DeepSeek** | [DeepSeek](https://chat.deepseek.com) | Unlimited (no sub) | -- | -- | -- |
| **Mistral** | [Le Chat](https://chat.mistral.ai) | ~25 msgs | Student $6/mo | Pro $15/mo | Enterprise (custom) |
| **Meta Llama** | -- | Models are free | -- | -- | -- |
| **Alibaba Qwen** | [Qwen](https://chat.qwen.ai) | Unlimited (no sub) | -- | -- | -- |
| **Amazon Nova** | [Nova](https://nova.amazon.com) | Free (US only) | -- | -- | -- |
| **Microsoft** | [Copilot](https://copilot.microsoft.com) | Limited GPT-5.x | -- | Copilot Pro $20/mo | M365 Enterprise $30/seat/mo |
| **Perplexity** | [Perplexity](https://www.perplexity.ai) | Limited Pro Searches | -- | Pro $20/mo | Max $200/mo |
| **Groq** | -- | Rate-limited API | Pay-as-you-go | -- | -- |

### Feature comparison (~$20 tier)

Seven providers offer a tier around $15-30/month. Here's what you get:

| Feature | ChatGPT Plus ($20) | Claude Pro ($20) | Gemini AI Pro ($20) | SuperGrok ($30) | Le Chat Pro ($15) | Copilot Pro ($20) | Perplexity Pro ($20) |
|---------|-------------------|-----------------|-------------------|----------------|------------------|------------------|---------------------|
| Top model | GPT-5.2 Thinking | Opus 4.6 | Gemini 3.1 Pro | Grok 4.1 | Mistral Large 3 | GPT-5.x | GPT-5.4, Claude, Gemini |
| Context | 32K | 200K (1M beta) | 128K+ | 128K | 128K | -- | 200K |
| Image gen | DALL-E (~180/day) | No | Nano Banana Pro | Aurora/Imagine | Yes | DALL-E (M365 only) | Yes |
| Video gen | Sora (720p, 20s) | No | Veo (limited) | Imagine (720p, 6s) | No | No | Yes |
| Voice mode | Advanced (video/screen) | No | Yes | Extended | No | No | No |
| Web search | Yes | Yes | Deep Search | DeepSearch | AFP-verified | Bing | Grounded (citations) |
| Coding agent | Codex | Claude Code | Jules (5x free) | Grok Build (waitlist) | Vibe 2.0 | -- | -- |
| Deep reasoning | GPT-5.2 Thinking | Extended Thinking | Deep Research | Big Brain Mode | Flash Answers | -- | Deep Research |
| No training | No | Yes | No | No | Yes | No | No |
| API credits | No | No | $10/mo GCP | No | No | No | $5/mo |
| Unique value | Broadest features | Best coding | Workspace + API credits | 2M context, X data | Cheapest, no telemetry | M365 integration | Search + multi-model |

**Best free tier**: [DeepSeek](https://chat.deepseek.com) and [Qwen](https://chat.qwen.ai) (both unlimited, no sub) or [Gemini](https://gemini.google.com) (50 daily credits).

**Best value at ~$20**: Claude Pro for coding depth. ChatGPT Plus for broadest features. Gemini AI Pro for Workspace integration and the only one with API credits. Perplexity Pro for search + access to third-party models. Le Chat Pro is cheapest at $15 with no-telemetry.

**High-end tiers**: Claude Max 20x ($200) for near-unlimited Opus 4.6 + Claude Code. ChatGPT Pro ($200) for unlimited everything + Sora 4K. Google AI Ultra ($250) for 25K credits + YouTube Premium + Deep Think. SuperGrok Heavy ($300) for Grok 4 Heavy multi-agent.

---

## Coding agents comparison

Every major provider now ships a coding agent. Plus a growing ecosystem of third-party agents that use their APIs.

### First-party agents

| Agent | Provider | Type | Cheapest access | Rules | Memory | MCP | Sub-agents |
|-------|----------|------|----------------|-------|--------|-----|------------|
| [Codex](https://openai.com/index/introducing-codex/) | OpenAI | Cloud sandbox | Plus $20/mo | `AGENTS.md` | No | Yes | Yes |
| [Claude Code](https://claude.com/product/claude-code) | Anthropic | Terminal CLI | Pro $20/mo | `CLAUDE.md` | Yes | Yes | Yes |
| [Jules](https://jules.google/docs/usage-limits/) | Google | Async GitHub | Free (15 tasks/day) | `AGENTS.md` | Partial | Yes | No |
| [Gemini CLI](https://geminicli.com) | Google | Terminal CLI | Free (1K req/day) | `GEMINI.md` | Yes | Yes | Yes |
| [Gemini Code Assist](https://cloud.google.com/products/gemini-code-assist) | Google | IDE assistant | Free | -- | -- | -- | -- |
| [Antigravity](https://developers.googleblog.com/build-with-google-antigravity-our-new-agentic-development-platform/) | Google | Agentic IDE | Free (preview) | `.agents/workflows/` | Yes | Yes | Yes |
| [Grok Build](https://grokai.build) | xAI | Local CLI | Waitlist | `.grok/GROK.md` | Partial | Yes | Yes (8x) |
| [Vibe 2.0](https://mistral.ai/news/mistral-vibe-2-0) | Mistral | Terminal CLI | Le Chat Pro $15/mo | `AGENTS.md` | No | Yes | Yes |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | Alibaba | Terminal CLI | Free (1K req/day) | `QWEN.md` | Yes | Yes | Yes |
| [Amazon Q Developer](https://aws.amazon.com/q/developer/) | Amazon | IDE + CLI | Free (50 agentic/mo) | `.amazonq/rules/` | Partial | Yes | No |

**Other first-party agents** (not coding-specific): [Agent Mode](https://openai.com/index/introducing-chatgpt-agent/) (OpenAI, web automation, Plus $20/mo), [Cowork](https://claude.com/blog/cowork-research-preview) (Anthropic, desktop agent, Pro $20/mo), [Computer Use](https://platform.claude.com/docs/en/agents-and-tools/computer-use) (Anthropic, screen automation, API only).

### Third-party agents

These use the APIs above. You pick the model, they provide the IDE/workflow.

| Agent | Type | Pricing | Rules | Memory | MCP | Sub-agents |
|-------|------|---------|-------|--------|-----|------------|
| [Cursor](https://cursor.com) | VS Code fork | Free / Pro $20 / Ultra $200 | `.cursor/rules/*.mdc` | Yes | Yes | Yes |
| [Windsurf](https://windsurf.com) | Agentic IDE | Free / Pro $15 / Teams $30 | `.windsurf/rules/*.md` | Yes | Yes | No |
| [GitHub Copilot](https://github.com/features/copilot/plans) | IDE integration | Free / Pro $10 / Pro+ $39 | `.github/copilot-instructions.md` | Yes | Yes | Yes |
| [Cline](https://cline.bot) | VS Code extension | Free (OSS, pay API) / Teams $20 | `.clinerules` | Yes | Yes | No |
| [Aider](https://aider.chat) | Terminal | Free (OSS, pay API) | `CONVENTIONS.md` | No | Partial | No |
| [Continue](https://www.continue.dev) | VS Code / JetBrains | Solo free / Team $10/dev | `.continue/rules/*.md` | No | Yes | No |

{% note info %}
**Rules**: Every agent now supports project-level instruction files, but there is no standard. `AGENTS.md` is gaining traction across OpenAI, Google, and Mistral tools. GitHub Copilot also reads `AGENTS.md` and `CLAUDE.md`.

**MCP**: Near-universal. 18 of 19 agents support MCP natively. Aider has only community/experimental support.

**Memory**: Split. About half have true persistent cross-session memory. Others rely on rules files as static context.
{% endnote %}

Note: GitHub Copilot is a Microsoft product. The Pro+ tier ($39/mo) includes an autonomous coding agent that creates PRs from GitHub issues and model choice across providers.

---

## Google Gemini

[gemini.google.com](https://gemini.google.com) | [AI Studio](https://aistudio.google.com) | [API docs](https://ai.google.dev/gemini-api/docs)

The most generous free tier of any provider. No credit card, no trial period, just get an API key and go.

### Models

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Gemini 3.1 Pro | 1M | $2.00 / $12.00 | Flagship reasoning, agentic workflows, 77.1% ARC-AGI-2 |
| Gemini 3 Flash | 1M | $0.50 / $3.00 | Near-Pro reasoning at fraction of cost |
| Gemini 3.1 Flash-Lite | 1M | $0.25 / $1.50 | Most cost-efficient, high-volume workloads |
| Gemini 2.5 Pro | 1M | $1.25 / $10.00 | Deep reasoning, coding, math, science |
| Gemini 2.5 Flash | 1M | $0.30 / $2.50 | Best price-performance for reasoning |
| Gemini 2.5 Flash-Lite | 1M | $0.10 / $0.40 | Fastest and cheapest multimodal model |

All models accept text, image, audio, video, and PDF input. 1M token context across the board.

**Specialized models**: Imagen 4 (image gen, $0.02-0.06/image), Veo 3.1 (video gen), Gemini Embedding 2 (multimodal embeddings), Computer Use (UI automation).

### Subscriptions

| Tier | Price | Storage | Models | Key features | API access |
|------|-------|---------|--------|-------------|-----------|
| Free | $0 | 15 GB | Gemini 3 | 50 daily AI credits, basic NotebookLM (100 notebooks, 50 queries/day), limited image gen | No |
| AI Plus | $7.99/mo | 200 GB | Gemini 3 Pro | 200 monthly credits, limited Veo 3.1 Fast video, limited Workspace AI, share with 5 family members | No |
| AI Pro | $19.99/mo | 2 TB | Gemini 3.1 Pro | 1,000 monthly credits, Deep Research, Deep Search, NotebookLM (500 notebooks, 300 sources, 500 queries/day), full Workspace AI (Gmail/Docs/Sheets/Slides), Jules (5x free), Gemini Code Assist, Gems (custom AI personas), family sharing | $10/mo GCP credits |
| AI Ultra | $249.99/mo | 30 TB | Gemini 3.1 Pro, Deep Think | 25,000 monthly credits, Deep Think (extended reasoning, exclusive), highest Deep Research access, Veo 3.1 full + early Veo 3.16, Jules (20x free, multi-agent), YouTube Premium included, early access to experimental features, family sharing | $100/mo GCP credits |

Credits do NOT roll over. See [subscription plans](https://gemini.google/subscriptions/) and [Google One AI plans](https://one.google.com/about/google-ai-plans/) for details.

### Free tier (API)

| Model | Requests/min | Tokens/min | Requests/day |
|-------|-------------|-----------|-------------|
| Gemini 3 Flash | 10 | 250K | 250 |
| Gemini 3.1 Flash-Lite | 15 | 250K | 1,000 |
| Gemini 2.5 Pro | 5 | 250K | 100 |
| Gemini 2.5 Flash | 10 | 250K | 250 |
| Gemini 2.5 Flash-Lite | 15 | 250K | 1,000 |

Free tier covers Flash and Flash-Lite models across generations (not Pro). No credit card required. Content on free tier may be used to improve Google's products.

### Open source

Gemini itself is proprietary. [Gemma](https://ai.google.dev/gemma) (1B-27B params) is Google's open-weight alternative, built on the same research. Free for commercial use.

### Mobile SDK

Google consolidated mobile access under [Firebase AI Logic](https://firebase.google.com/products/firebase-ai-logic). SDKs for Swift (iOS), Kotlin (Android), Flutter, React Native, Unity, and Web. The older standalone Google AI SDKs are deprecated.

### Links

- [Subscription plans](https://gemini.google/subscriptions/)
- [API pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [Models reference](https://ai.google.dev/gemini-api/docs/models)
- [Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Firebase AI Logic SDKs](https://firebase.google.com/products/firebase-ai-logic)

---

## OpenAI

[chatgpt.com](https://chatgpt.com) | [platform.openai.com](https://platform.openai.com) | [API docs](https://developers.openai.com/api/docs)

The largest model lineup. GPT-5.x for general use, o-series for reasoning, GPT-4.1 for low-latency tool calling.

### Models

**GPT-5 series:**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| GPT-5.4 | 1M+ | $2.50 / $15.00 | Latest flagship, computer-use, 33% fewer errors vs 5.2 |
| GPT-5.4 Pro | 1M+ | $30.00 / $180.00 | Extended reasoning |
| GPT-5.2 | 400K | $1.75 / $14.00 | Workhorse model, cached input at $0.175 |
| GPT-5 | 400K | $1.25 / $10.00 | Original GPT-5 |
| GPT-5 Mini | 400K | $0.25 / $2.00 | Faster, cheaper |
| GPT-5 Nano | 400K | $0.05 / $0.40 | Cheapest GPT-5, edge-friendly |

**O-series (reasoning):**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| o3 | 200K | $2.00 / $8.00 | Advanced reasoning (math, science, coding) |
| o3 Pro | 200K | $20.00 / $80.00 | Extended compute |
| o4 Mini | 200K | $1.10 / $4.40 | Fast reasoning, efficient |
| o4 Mini High | 200K | $1.10 / $4.40 | Same per-token price, higher reasoning compute budget |

O-series models use hidden "reasoning tokens" billed as output. A 500-token visible response may cost 2,000+ tokens total.

**GPT-4.1 series (still available):**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| GPT-4.1 | 1M | $2.00 / $8.00 | Instruction following, tool calling |
| GPT-4.1 Mini | 1M | $0.40 / $1.60 | Same strengths, lower cost |
| GPT-4.1 Nano | 1M | $0.10 / $0.40 | Cheapest in the lineup |

All models accept text and image input. Batch API available at 50% off across all models.

### Subscriptions

**Individual plans:**

| Tier | Price | Models | Message limits | Key features |
|------|-------|--------|---------------|-------------|
| Free | $0 | GPT-5.2 Instant (lightweight) | ~10 per 5 hours, falls back to Mini | Basic DALL-E (2-3 images/day), limited Sora 2, limited Deep Research, basic voice, can use GPTs but not create them |
| ChatGPT Go | $8/mo | GPT-5.2 Instant (unlimited) | ~10x Free | DALL-E, file upload, code interpreter, web browsing, create custom GPTs. No Sora, no Deep Research, no Agent Mode, no Codex |
| ChatGPT Plus | $20/mo | GPT-5.2, GPT-5.2 Thinking, o3-pro | ~3,000/week (Thinking) | DALL-E (~180 images/day), Sora (1,000 credits/mo, 720p, 20s clips), Deep Research, Agent Mode, Codex, Canvas, Tasks, Advanced Voice (video/screen sharing), 32K context |
| ChatGPT Pro | $200/mo | All Plus models + GPT-5.2 Pro | Effectively unlimited | Unlimited DALL-E, Sora (10,000 credits + unlimited relaxed mode, 1080p/4K, 90s clips, no watermark), 128K context (4x Plus), ChatGPT Pulse (exclusive), early access to new features |

**Business plans:**

| Tier | Price | Notes |
|------|-------|-------|
| Team | $25-30/user/mo | Same as Plus models + higher Thinking caps, admin console, conversations NOT used for training, shared workspace GPTs |
| Enterprise | Custom | Unlimited higher-speed GPT-5.2, extended context, SSO, SCIM, SOC 2 + ISO compliance, custom data retention, not trained on |

None of these include API credits. See [ChatGPT plans](https://chatgpt.com/pricing/) for details. API is a completely separate billing system at [platform.openai.com](https://platform.openai.com).

### Free tier (API)

The free trial credit program ($5) was discontinued in mid-2025. Reports conflict on whether new accounts still receive credits. Check [platform.openai.com](https://platform.openai.com) directly. Pay-as-you-go with no minimum spend once you add a payment method.

### Open source

OpenAI released two open-weight models under **Apache 2.0**:
- **GPT-OSS-120B**: ~117B params (5.1B active via MoE), runs on a single 80GB GPU. Matches o4-mini on reasoning.
- **GPT-OSS-20B**: Runs on 16GB memory. Matches o3-mini.

Both on [Hugging Face](https://huggingface.co/openai) with MXFP4 quantization.

### Mobile SDK

No official native iOS/Android SDK. The API is standard REST/HTTP. Community options:
- [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) -- third-party Swift package for iOS/macOS

OpenAI also offers an **Apps SDK** (preview) for building apps that run inside ChatGPT, and a **Realtime API** via WebRTC for client-side voice/text streaming.

### Links

- [ChatGPT plans](https://chatgpt.com/pricing/)
- [API pricing](https://openai.com/api/pricing/)
- [Models docs](https://developers.openai.com/api/docs/models)
- [Open models](https://openai.com/open-models/)

---

## Anthropic Claude

[claude.ai](https://claude.ai) | [console.anthropic.com](https://console.anthropic.com) | [API docs](https://platform.claude.com/docs)

The smallest model lineup but strong across the board. Known for instruction following, safety, and coding quality.

### Models

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Claude Opus 4.6 | 200K (1M beta) | $5 / $25 | Most intelligent; agents, coding, complex reasoning |
| Claude Sonnet 4.6 | 200K (1M beta) | $3 / $15 | Best balance of speed and intelligence |
| Claude Haiku 4.5 | 200K | $1 / $5 | Fastest, near-frontier intelligence |

All models support text + image input and PDF processing (up to 100 images per request). Extended thinking available on all three. 1M context in beta for Opus and Sonnet (via `context-1m-2025-08-07` header).

**Prompt caching**: Cache hits cost 0.1x input price (90% savings). Cache write costs 1.25x-2x depending on TTL (5 min or 1 hour).

**Batch API**: 50% discount on all models.

### Subscriptions

**Individual plans:**

| Tier | Price | Models | Usage | Key features |
|------|-------|--------|-------|-------------|
| Free | $0 | Sonnet 4.6 | ~15-40 msgs per 5-hour window | 200K context, up to 20 file uploads (30 MB each), web search, Projects, Artifacts. No Extended Thinking, no Computer Use, no Claude Code, no Opus. Conversations may be used for training |
| Pro | $20/mo ($17 annual) | Sonnet 4.6, Opus 4.5, Opus 4.6, Haiku 4.5 | 5x Free (~75-200 per 5 hours) | Extended Thinking, Claude Code, Cowork, unlimited Projects, limited Computer Use, priority access. NOT used for training |
| Max 5x | $100/mo | All models including Opus 4.6 | 5x Pro / 25x Free | Higher Extended Thinking compute, Computer Use, 200K context (1M beta, 128K max output) |
| Max 20x | $200/mo | All models including Opus 4.6 | 20x Pro / 100x Free | Everything in Max 5x with 4x the usage ceiling. Best for heavy developers needing near-unlimited Opus 4.6 |

**Business plans:**

| Tier | Price | Notes |
|------|-------|-------|
| Team Standard | $25/seat/mo | Same as Pro, shared project folders, admin console, SSO, domain capture. Min 5 seats. NOT trained on |
| Team Premium | $150/seat/mo | Everything in Standard + Claude Code included |
| Enterprise | Custom | Fine-grained RBAC, SCIM provisioning, SAML 2.0 SSO, compliance API, audit logs, custom data retention, usage-based billing with admin spending caps, Claude Code included |

See [Claude plans](https://claude.com/pricing) for details. API is separate at [console.anthropic.com](https://console.anthropic.com).

### Free tier (API)

$5 in free credits upon creating a developer account (phone verification required, region-dependent). After that, pure pay-as-you-go with tier-based rate limits.

### Open source

Not open source. No model weights released. Anthropic has been explicit about this as a safety position. The [Model Context Protocol (MCP)](https://modelcontextprotocol.io) is open source.

### Mobile SDK

No official Swift or Kotlin SDK. Seven official server-side SDKs: Python, TypeScript, Java, Go, Ruby, C#, PHP. Community mobile options:
- [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) -- third-party Swift package
- [AnthropicKit](https://guitaripod.github.io/AnthropicKit/) -- third-party Swift SDK

### Links

- [Claude plans](https://claude.com/pricing)
- [API pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- [Models overview](https://platform.claude.com/docs/en/about-claude/models/overview)
- [Client SDKs](https://platform.claude.com/docs/en/api/client-sdks)

---

## xAI (Grok)

[grok.com](https://grok.com) | [x.ai/api](https://x.ai/api) | [API docs](https://docs.x.ai)

Largest context window (2M tokens) and aggressive sign-up credits. Built into X (Twitter) with real-time social data access.

### Models

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Grok 4.20 Multi-Agent | 2M | $2.00 / $6.00 | Multi-agent orchestration |
| Grok 4.20 (reasoning) | 2M | $2.00 / $6.00 | Flagship reasoning |
| Grok 4.1 Fast (reasoning) | 2M | $0.20 / $0.50 | Best value |
| Grok Code Fast 1 | 256K | $0.20 / $1.50 | Code-specialized |

Image input supported on Grok 4.x models. Image generation ($0.02-0.07/image) and video generation ($0.05/second) available as separate endpoints.

### Subscriptions

| Tier | Price | Models | Limits | Key features |
|------|-------|--------|--------|-------------|
| Free | $0 | Grok 3 (limited) | ~10 msgs per 2 hours | ~10 Aurora images per 2 hours, basic voice. No DeepSearch, no Think mode |
| X Premium | $8/mo | Grok 3, limited Grok 4 | Higher than Free | Image gen, voice, basic memory. Bundled with blue checkmark + reduced ads. 50% off SuperGrok |
| X Premium+ | $40/mo | Grok 4, Grok 4.1 | ~100 prompts per 2 hours | Limited DeepSearch, limited Think (~30 per 2 hours), extended voice + memory. Bundled with ad revenue sharing + ad-free browsing. 50% off SuperGrok |
| SuperGrok | $30/mo | Grok 4, Grok 4.1 | ~30 per 2 hours (Think/DeepSearch) | 128K context memory, full DeepSearch, Big Brain Mode (extended reasoning), Imagine (image gen + 720p 6s video), Aurora image editing, priority routing |
| SuperGrok Heavy | $300/mo | Grok 4 Heavy (multi-agent) | Dramatically higher | 256K context (2x SuperGrok), maximum compute priority, 100% AIME 2025, Grok 4 Heavy exclusive |
| Grok Business | $30-300/seat/mo | Standard or Heavy | Team-managed | Admin controls, API access included |

See [Grok plans](https://grok.com/plans) for details. API is separate pay-as-you-go for non-Business tiers. $25 in free sign-up credits.

### Open source

Grok 1 and Grok 2.5 weights are on [Hugging Face](https://huggingface.co/xai-org/grok-2). Grok 3 open-source planned. Current frontier models (4.x) are proprietary.

### Mobile SDK

No dedicated SDK. The API is OpenAI-compatible, so any OpenAI client library works. Grok mobile app available on iOS and Android.

### Links

- [Grok plans](https://grok.com/plans)
- [API pricing](https://x.ai/api)
- [Models docs](https://docs.x.ai/developers/models)

---

## DeepSeek

[chat.deepseek.com](https://chat.deepseek.com) | [platform.deepseek.com](https://platform.deepseek.com) | [API docs](https://api-docs.deepseek.com)

The price disruptor. V3.2 costs roughly 95% less than GPT-4 Turbo with competitive quality.

### Models

| Model | Context | Input/Output (per 1M) | Cache hit | Notes |
|-------|---------|----------------------|-----------|-------|
| deepseek-chat (V3.2) | 128K | $0.28 / $0.42 | $0.028 | Non-thinking, 8K max output |
| deepseek-reasoner (V3.2) | 128K | $0.28 / $0.42 | $0.028 | Thinking mode, 64K max output |

Text-only as of March 2026. V4 with multimodal is in development.

Off-peak discount: 50-75% off during 16:30-00:30 GMT.

### Subscriptions

No subscription model. The [chat app](https://chat.deepseek.com) (web + mobile) is completely **free** with unlimited messages within daily quotas. No paid tier exists -- they just give you the models for free. API is pure pay-as-you-go at [platform.deepseek.com](https://platform.deepseek.com). New accounts get 5M free tokens (30-day validity).

### Open source

**Fully open source under MIT license.** Weights on [Hugging Face](https://huggingface.co/deepseek-ai) for V3.2 and R1. Self-host on your own hardware. A quantized 7B version runs on Android.

### Mobile SDK

No dedicated SDK. Official apps on iOS and Android (free). The API is OpenAI-compatible.

### Links

- [Chat app](https://chat.deepseek.com) (free)
- [API pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [API docs](https://api-docs.deepseek.com)

---

## Mistral AI

[chat.mistral.ai](https://chat.mistral.ai) | [console.mistral.ai](https://console.mistral.ai) | [API docs](https://docs.mistral.ai)

European provider with the widest range from ultra-cheap (Nemo at $0.02/M) to frontier.

### Models

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Mistral Large 3 | 128K | $0.50 / $1.50 | Flagship |
| Mistral Medium 3 | 128K | $0.40 / $2.00 | Mid-tier |
| Mistral Small 3.1 (24B) | 128K | $0.35 / $0.56 | Efficient |
| Mistral Nemo | 128K | $0.02 / $0.04 | Ultra-budget |
| Codestral | 256K | Varies | Code specialist (22B, 80+ languages) |
| Devstral 2 | 128K | $0.40 / $2.00 | Powers Vibe 2.0 coding agent |
| Pixtral Large | 128K | Varies | Multimodal (124B, text + image, up to 30 images) |

### Subscriptions (Le Chat)

| Tier | Price | Limits | Key features |
|------|-------|--------|-------------|
| Free | $0 | ~25 msgs before throttling | 128K context, code interpreter, document uploads, web search (AFP-verified), Canvas (web pages/graphs/presentations), image gen. Prompts may be used for training |
| Pro | $14.99/mo | ~6x Free (soft cap, fair use) | 150 Flash Answers/day (ultra-fast, 1,000 words/sec), Vibe 2.0 coding agent, No Telemetry Mode (never trained on), priority responses, early feature access |
| Student | $5.99/mo | Same as Pro | >50% discount, verified students, 12-month validity |
| Team | $24.99/user/mo | Pro per seat | 30 GB/user shared RAG libraries, admin console, data training opt-out default |
| Enterprise | Custom | Custom | On-prem deployment, custom models, multi-step agent pipelines |

See [Le Chat pricing](https://mistral.ai/pricing) for details. API is separate pay-as-you-go at [console.mistral.ai](https://console.mistral.ai).

### Open source

Mixed. **Apache 2.0**: Mistral 7B, Mixtral 8x7B, Mistral Nemo, Mistral Small 3. **Non-production license**: Codestral. **Proprietary**: Large, Medium, Pixtral Large.

### Mobile SDK

No dedicated SDK. Python and JavaScript/TypeScript client libraries available.

### Links

- [Le Chat pricing](https://mistral.ai/pricing)
- [API docs](https://docs.mistral.ai)
- [Models](https://docs.mistral.ai/getting-started/models)

---

## Meta Llama

[llama.com](https://www.llama.com) | [Hugging Face](https://huggingface.co/meta-llama)

Not a service -- it's a family of models you can run anywhere. Free weights, massive ecosystem.

### Models

| Model | Params (Active/Total) | Context | Multimodal |
|-------|----------------------|---------|------------|
| Llama 4 Scout | 17B / 109B (16 experts) | **10M** | Text, image, video |
| Llama 4 Maverick | 17B / 400B (128 experts) | **1M** | Text, image, video |
| Llama 4 Behemoth | 288B / 2T (16 experts) | TBD | Yes (still training) |
| Llama 3.3 70B | 70B | 128K | Text only |
| Llama 3.1 8B | 8B | 128K | Text only |

Scout's 10M token context is the longest of any open model. Scout fits on a single H100 with INT4 quantization.

### API pricing (via providers)

| Provider | Llama 4 Scout | Llama 3.3 70B | Speed |
|----------|--------------|--------------|-------|
| Groq | $0.11 / $0.34 | $0.59 / $0.79 | 594 t/s |
| Together AI | -- | ~$0.88 / $0.88 | -- |
| DeepInfra | -- | ~$0.15 / $0.15 | Budget |
| Self-hosted | Free | Free | You pay compute |

Prices vary up to 6.8x across providers for the same model.

### Open source

**Yes.** Llama Community License -- free for commercial use (companies under 700M MAU). Weights on [Hugging Face](https://huggingface.co/meta-llama) and [llama.com](https://www.llama.com).

### Mobile SDK

No official SDK. On-device inference via llama.cpp, MLX, ONNX. Llama 3.1 8B and Scout can run locally on capable devices.

### Links

- [Llama official site](https://www.llama.com)
- [Hugging Face](https://huggingface.co/meta-llama)
- [Llama 4 announcement](https://ai.meta.com/blog/llama-4-multimodal-intelligence/)

---

## Alibaba Qwen

[qwen.ai](https://qwen.ai) | [chat.qwen.ai](https://chat.qwen.ai) | [API platform](https://qwen.ai/apiplatform) | [API docs](https://www.alibabacloud.com/help/en/model-studio/qwen-api-reference/)

China's strongest open-source model family. Massive lineup from 0.8B to 480B, all Apache 2.0. The chat app is completely free.

### Models

**Text generation (API):**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Qwen3-Max (235B MoE) | 262K | $1.20 / $6.00 | Flagship reasoning |
| Qwen3-Max Thinking | 262K | $0.78 / $3.90 | Thinking mode, flat rate |
| Qwen3.5-Plus (MoE) | 1M | $0.26 / $1.56 | Balanced performance |
| Qwen3.5-Flash (MoE) | 1M | $0.10 / $0.40 | Fast and cheap |
| QwQ-Plus (32B reasoning) | 131K | $0.80 / $2.40 | Reasoning specialist |
| Qwen-Long | **10M** | Tiered | Ultra-long document analysis |

**Coding models:**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Qwen3-Coder-Plus (480B MoE) | 1M | $0.65 / $3.25 | Flagship coding, SWE-bench leading |
| Qwen3-Coder-Next (80B MoE) | 262K | $0.07 / $0.30 | Open-weight (Apache 2.0), hybrid attention |

**Vision / multimodal**: Qwen3-VL-Plus (262K), QVQ-Max (visual reasoning), Qwen3-Omni-Flash (audio + video + text). **Specialized**: Qwen3-Deep-Research (1M), Qwen-OCR, Qwen-MT (translation, 92 languages).

Tiered pricing: rates increase as input length grows (0-32K cheapest, 128K+ most expensive). Batch API: 50% off.

### Open-weight models

| Model | Params (Active) | Context | License |
|-------|----------------|---------|---------|
| Qwen3.5-397B-A17B | 397B (17B) | 262K | Apache 2.0 |
| Qwen3.5-122B-A10B | 122B (10B) | 262K | Apache 2.0 |
| Qwen3.5-27B (dense) | 27B | 262K | Apache 2.0 |
| Qwen3.5-9B (dense) | 9B | 262K | Apache 2.0 |
| Qwen3.5-4B (dense) | 4B | 262K | Apache 2.0 |
| Qwen3.5-2B (dense) | 2B | 262K | Apache 2.0 |
| Qwen3.5-0.8B (dense) | 0.8B | 262K | Apache 2.0 |
| QwQ-32B | 32B | 32K | Apache 2.0 |

All on [Hugging Face](https://huggingface.co/Qwen) and [ModelScope](https://modelscope.cn/organization/qwen). Apache 2.0 = full commercial use.

### Subscriptions

**Qwen Chat** (web, iOS, Android, desktop) is completely **free** -- full access to Qwen3, image gen, video understanding, deep thinking, web search, artifacts. No paid tier.

**Coding Plan** (developer subscription, Feb 2026): Flat-rate alternative to per-token billing for coding workflows.

| Tier | Price | Requests/month | Works with |
|------|-------|---------------|------------|
| Lite | ~$10/mo | 18,000 | Claude Code, Qwen Code, Cline, Cursor |
| Pro | ~$50/mo | 90,000 | Same + higher rate limits |

### Free tier (API)

New accounts: 1M tokens free per model (90-day validity). [Qwen Code](https://github.com/QwenLM/qwen-code) OAuth: 1,000 free requests/day with no billing setup.

### Open source

**Yes.** All Qwen3 and Qwen3.5 open-weight models are **Apache 2.0** -- full commercial use, no restrictions. Proprietary models (Qwen-Max, QwQ-Plus) are API-only.

### Mobile SDK

No official SDK. On-device via llama.cpp, MLX, Ollama, ONNX. The 0.8B-4B models are designed for on-device use. Qwen3.5-2B runs at 30-50 t/s on iPhone/M-series Macs via MLX.

### Links

- [Qwen Chat](https://chat.qwen.ai) (free)
- [API pricing](https://www.alibabacloud.com/help/en/model-studio/model-pricing)
- [Models list](https://www.alibabacloud.com/help/en/model-studio/models)
- [Coding Plan](https://www.alibabacloud.com/help/en/model-studio/coding-plan)
- [GitHub](https://github.com/QwenLM)
- [Hugging Face](https://huggingface.co/Qwen)

---

## Amazon Nova

[aws.amazon.com/nova](https://aws.amazon.com/nova/models/) | [nova.amazon.com](https://nova.amazon.com) | [Bedrock pricing](https://aws.amazon.com/bedrock/pricing/)

AWS's in-house model family. Cheapest token pricing in the industry at the low end (Nova Micro $0.035/1M input). Consumer chat launched at [nova.amazon.com](https://nova.amazon.com).

### Models

**Nova 1 (understanding):**

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Nova Micro | 128K | $0.035 / $0.14 | Text only, lowest cost |
| Nova Lite | 300K | $0.06 / $0.24 | Text + image + video |
| Nova Pro | 300K | $0.80 / $3.20 | Best accuracy/cost balance |
| Nova Premier | 1M | $2.50 / $12.50 | Most capable, 200+ languages |

**Nova 2 (reasoning, Dec 2025):**

| Model | Context | Notes |
|-------|---------|-------|
| Nova 2 Lite | 1M | Built-in code interpreter, web grounding, MCP support |
| Nova 2 Pro | 1M | Advanced multi-step reasoning, agentic workflows (Preview) |
| Nova 2 Omni | -- | All modalities (text, image, video, speech in/out) (Preview) |

**Creative**: Nova Canvas (image gen), Nova Reel (video gen, 1280x720 24fps). **Other**: Nova Sonic (speech-to-speech), Nova Act ($4.75/agent-hour browser automation).

Batch API: 50% off on-demand pricing.

### Subscriptions

**[Nova Chat](https://nova.amazon.com)** -- free consumer chat app. Uses your Amazon.com account (not AWS). Powered by Nova Pro. Image creation, code gen. US only at launch.

**[Alexa+](https://www.amazon.com/alexa-plus)** -- consumer voice assistant upgraded with Nova models under the hood.

No traditional subscription tiers like ChatGPT/Claude. Access is either free (Nova Chat) or pay-per-token (Bedrock API).

### Free tier (API)

No permanent free API tier. New AWS accounts get **$200 in credits** ($100 sign-up + $100 onboarding). Credits apply to all AWS services including Bedrock, valid for 6 months. At Nova Micro pricing, that's ~5.7B input tokens.

### Open source

**No.** All Nova models are proprietary. Weights not released. Amazon publishes detailed [technical reports](https://www.amazon.science/publications/the-amazon-nova-family-of-models-technical-report-and-model-card) but not weights. Bedrock also hosts third-party open models (Llama, Mistral).

### Mobile SDK

[AWS Amplify AI Kit](https://docs.amplify.aws/react/ai/concepts/models/) for React Native and Android. Direct Bedrock API calls via AWS SDK with SigV4 signing. Also supported via [Vercel AI SDK](https://ai-sdk.dev/providers/ai-sdk-providers/amazon-bedrock). No first-party Swift SDK (use Objective-C bindings from Swift).

### Links

- [Nova models](https://aws.amazon.com/nova/models/)
- [Nova pricing](https://aws.amazon.com/nova/pricing/)
- [Bedrock pricing](https://aws.amazon.com/bedrock/pricing/)
- [Nova Chat](https://nova.amazon.com)
- [Q Developer](https://aws.amazon.com/q/developer/)
- [Q Developer pricing](https://aws.amazon.com/q/developer/pricing/)

---

## Microsoft Phi

[azure.microsoft.com/products/phi](https://azure.microsoft.com/en-us/products/phi) | [GitHub Models](https://github.com/features/models) | [Azure AI pricing](https://azure.microsoft.com/en-us/pricing/details/ai-foundry-models/microsoft/)

Best small models in the industry. All MIT-licensed. Phi-4-mini at 3.8B params punches far above its weight.

### Models

| Model | Params | Context | Input/Output (per 1M) | Notes |
|-------|--------|---------|----------------------|-------|
| Phi-4 | 14B | 16K | $0.125 / $0.50 | Base reasoning/instruction |
| Phi-4-mini | 3.8B | 128K | $0.075 / $0.30 | Grouped-query attention, function calling |
| Phi-4-multimodal | 5.6B | 128K | $0.08 / $0.32 | Text + vision + audio in one model |
| Phi-4-reasoning | 14B | 32K | -- | Chain-of-thought fine-tune |
| Phi-4-reasoning-plus | 14B | 32K | -- | Higher RL compute |
| Phi-4-reasoning-vision-15B | 15B | 32K | -- | Multimodal reasoning (MIT, Mar 2026) |
| Phi-3.5-MoE | 42B (6.6B active) | 128K | $0.16 / $0.64 | 16 experts, efficient inference |

Pricing is on Azure AI Foundry. Phi-4-mini is cheaper per token than GPT-4o-mini.

### Subscriptions

Microsoft's consumer AI is **Copilot**, not Phi directly:

| Tier | Price | Notes |
|------|-------|-------|
| Copilot Free | $0 | GPT-5.x limited, Bing integration |
| Copilot Pro | $20/mo | Priority GPT-5.x, M365 integration (Word, Excel, Outlook, Teams) for M365 subscribers |
| M365 Copilot Business | $18-25/user/mo | Full M365 Copilot in all business apps, meeting recap |
| M365 Copilot Enterprise | $30/user/mo | Compliance, audit, data residency, Copilot Studio |

Copilot Pro is the ~$20 tier. It's an M365 productivity tool, not a general chatbot -- useful if you're deep in the Microsoft ecosystem.

### Free tier (API)

**[GitHub Models](https://github.com/features/models)** is the easiest entry point -- free playground + API with rate limits (50-150 req/day). Just needs a GitHub account, no credit card. Phi-4 and Phi-4-mini both available. Paid usage mirrors Azure AI Foundry rates.

Azure free account: $200 credits for 30 days.

### Open source

**Yes.** All Phi models are **MIT license** -- full commercial use, modification, distribution. Weights on [Hugging Face](https://huggingface.co/microsoft/phi-4). MAI-1 (Microsoft's ~500B frontier model) is proprietary and not publicly available.

### Mobile SDK

No dedicated SDK. On-device via **ONNX Runtime Mobile** (iOS with CoreML, Android with NNAPI). Pre-quantized ONNX weights on Hugging Face. Phi-4-mini at 3.8B is feasible on devices with 6-8GB RAM.

### Links

- [Phi product page](https://azure.microsoft.com/en-us/products/phi)
- [Azure AI pricing](https://azure.microsoft.com/en-us/pricing/details/ai-foundry-models/microsoft/)
- [Phi-4 on Hugging Face](https://huggingface.co/microsoft/phi-4)
- [GitHub Models](https://github.com/features/models)
- [GitHub Copilot plans](https://github.com/features/copilot/plans)
- [Copilot Pro](https://www.microsoft.com/en-us/microsoft-365-copilot/pricing)

---

## Perplexity

[perplexity.ai](https://www.perplexity.ai) | [API docs](https://docs.perplexity.ai) | [API platform](https://www.perplexity.ai/api-platform)

Search-first AI. Every response is grounded in web sources with citations. The Pro subscription includes access to third-party models (GPT-5.4, Claude, Gemini).

### Models

| Model | Context | Input/Output (per 1M) | Notes |
|-------|---------|----------------------|-------|
| Sonar | 128K | $1 / $1 + per-req fee | Lightweight search + summarization |
| Sonar Pro | 200K | $3 / $15 + per-req fee | 2x search results, deeper retrieval |
| Sonar Reasoning Pro | 128K | $2 / $8 + per-req fee | Chain-of-thought reasoning |
| Sonar Deep Research | 128K | $2 / $8 + per-req fee | Long-form synthesis, hundreds of sources |

Per-request fees: $5-14 per 1,000 requests depending on model and search context size. This hybrid pricing (tokens + requests) makes Perplexity more expensive per call than pure token-based providers.

**Search API**: $5 per 1,000 requests (raw web results, no generation).

### Subscriptions

| Tier | Price | Key features |
|------|-------|-------------|
| Free | $0 | Basic search, limited Pro Searches |
| Pro | $20/mo ($200/yr) | Unlimited Pro queries, file uploads, image/video gen, third-party models (GPT-5.4, Claude Sonnet/Opus, Gemini 3.1 Pro), $5/mo API credits |
| Max | $200/mo | Everything in Pro + Perplexity Computer (multi-agent), unlimited Labs, early access |
| Enterprise Pro | $40/seat/mo | Team features, SSO, shared Spaces, admin controls |

**Pro subscribers get $5/month in API credits.** Third-party model access in Pro means you can use GPT-5.4 and Claude Opus through Perplexity's interface without separate subscriptions.

### Free tier (API)

No free API tier. Requires payment method. Pro subscribers get $5/mo in API credits. [Startup program](https://www.perplexity.ai/startups): 6 months free Enterprise Pro + $5,000 in API credits.

### Open source

**No.** Sonar models are proprietary (fine-tuned from Llama 3.3 70B and DeepSeek R1, but Perplexity's weights and search infrastructure are closed).

### Mobile SDK

No dedicated SDK. Official Python and TypeScript SDKs. MCP server for Cursor, VS Code, Claude Desktop. OpenAI-compatible API. iOS and Android apps available.

### Links

- [Perplexity Pro](https://www.perplexity.ai)
- [API pricing](https://docs.perplexity.ai/docs/getting-started/pricing)
- [API docs](https://docs.perplexity.ai)
- [Enterprise pricing](https://www.perplexity.ai/enterprise/pricing)

---

## Groq

[groq.com](https://groq.com) | [console.groq.com](https://console.groq.com) | [API docs](https://console.groq.com/docs)

Not a model provider -- an inference provider. Runs open-source models on custom LPU hardware at the fastest speeds in the industry.

### Models & pricing

| Model | Input/Output (per 1M) | Speed |
|-------|----------------------|-------|
| Llama 4 Maverick | $0.20 / $0.60 | 562 t/s |
| Llama 4 Scout | $0.11 / $0.34 | 594 t/s |
| Llama 3.3 70B | $0.59 / $0.79 | 394 t/s |
| Llama 3.1 8B | $0.05 / $0.08 | 840 t/s |
| GPT-OSS 120B | $0.15 / $0.60 | 500 t/s |
| GPT-OSS 20B | $0.075 / $0.30 | 1,000 t/s |
| Qwen3 32B | $0.29 / $0.59 | 662 t/s |
| Whisper V3 Large (STT) | $0.111/hr | -- |
| Whisper V3 Turbo (STT) | $0.04/hr | -- |

### Free tier

No credit card required. Rate-limited access (e.g., ~6K tokens/min for 70B models, ~500K tokens/day). Never charged -- just 429 errors at the limit.

Paid tier (pay-as-you-go) gets 10x the rate limits plus batch processing at 50% off.

### Open source

N/A -- Groq doesn't make models. They host open-source models (Llama, Qwen, GPT-OSS) on custom LPU hardware.

### Links

- [Pricing](https://groq.com/pricing)
- [API docs](https://console.groq.com/docs)
- [Models](https://console.groq.com/docs/models)

---

## Mobile SDK summary

| Provider | Official iOS SDK | Official Android SDK | Notes |
|----------|-----------------|---------------------|-------|
| **Google Gemini** | Yes (Firebase AI Logic, Swift) | Yes (Firebase AI Logic, Kotlin) | Also Flutter, React Native, Unity |
| **OpenAI** | No | No | Community: [MacPaw/OpenAI](https://github.com/MacPaw/OpenAI) (Swift) |
| **Anthropic** | No | No | Community: [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) |
| **xAI** | No | No | OpenAI-compatible API (any client works) |
| **DeepSeek** | No | No | OpenAI-compatible API |
| **Mistral** | No | No | Python/JS SDKs only |
| **Meta Llama** | No | No | On-device via llama.cpp, MLX, ONNX |
| **Alibaba Qwen** | No | No | On-device via MLX, Ollama, llama.cpp |
| **Amazon Nova** | Partial (Amplify AI Kit) | Partial (Amplify AI Kit) | React Native + Android. No native Swift SDK |
| **Microsoft Phi** | No | No | ONNX Runtime Mobile (iOS CoreML, Android NNAPI) |
| **Perplexity** | No | No | Python/TS SDKs, MCP server |
| **Groq** | No | No | OpenAI-compatible API |

Google is the only provider with first-party mobile SDKs. Amazon has partial coverage via Amplify. Everyone else: use REST directly, community packages, or on-device inference (MLX, ONNX, llama.cpp).

---

## Bottom line

**Best free chat**: [DeepSeek](https://chat.deepseek.com) (unlimited, no sub), [Qwen](https://chat.qwen.ai) (full-featured, also free), or [Gemini](https://gemini.google.com) (50 daily credits). All genuinely useful without paying.

**Best ~$20 subscription**: Claude Pro for coding depth. ChatGPT Plus for broadest features (image, video, voice, agents). Gemini AI Pro for Workspace integration. Perplexity Pro for search + access to third-party models. Le Chat Pro is cheapest at $15 with no-telemetry.

**Best free API**: [Gemini](https://aistudio.google.com). No credit card, generous limits. [Groq](https://console.groq.com) for fastest open-model inference. [Qwen](https://qwen.ai/apiplatform) for 1M free tokens per model.

**Best budget API**: DeepSeek at $0.28/M input (or $0.028 cached). Mistral Nemo at $0.02/M for ultra-cheap. Amazon Nova Micro at $0.035/M for AWS users.

**Best coding agent**: [Claude Code](https://claude.com/product/claude-code) (Pro $20/mo) or [Codex](https://openai.com/index/introducing-codex/) (Plus $20/mo) for first-party. [Cursor](https://cursor.com) ($20/mo) or [Cline](https://cline.bot) (free, BYOM) for third-party. [Amazon Q Developer](https://aws.amazon.com/q/developer/) free tier (50 agentic requests/mo) if you're on AWS.

**Best open-source models**: [Llama 4 Scout](https://www.llama.com) (10M context), [Qwen3.5](https://huggingface.co/Qwen) (Apache 2.0, up to 397B), [DeepSeek V3.2](https://huggingface.co/deepseek-ai) (MIT), [Phi-4](https://huggingface.co/microsoft/phi-4) (MIT, best small models).

**Best mobile SDK**: Gemini via [Firebase AI Logic](https://firebase.google.com/products/firebase-ai-logic) -- only first-party option for iOS/Android/Flutter.

**Highest capability**: Claude Opus 4.6, GPT-5.4, and Gemini 3.1 Pro are the three frontier models. Pick based on your use case and budget.

Subscriptions and APIs are separate worlds. Pick your subscription for daily use, pick your API for building things. Or just use Gemini/Qwen's free tier for both.
