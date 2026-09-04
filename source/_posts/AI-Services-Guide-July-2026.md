---
title: "AI services guide: subscriptions, free tiers, and APIs (July 2026)"
date: 2026-07-12 12:00:00
categories:
- AI
tags:
- ai
- api
- llm
- subscription
- agent
---

A July 2026 snapshot of every major AI provider, covering the nine weeks of releases since the {% post_link AI-Services-Guide-May-2026 "May guide" %}: a full model-generation turnover, the first government-ordered model shutdown, and a product graveyard that deserves its own section.

<!-- more -->

## Nine weeks that aged the May guide

The {% post_link AI-Services-Guide-May-2026 "May 2026 guide" %} went out the week Opus 4.7 and GPT-5.5 were the frontier. Both are now previous-generation. That part is routine. What's new this cycle: two governments inserted themselves into the release pipeline, and vendors killed more products than they launched.

### New flagship models

- **Claude 5 family** ([June 9](https://www.anthropic.com/news/claude-fable-5-mythos-5)). **Claude Fable 5** at $10/$50 per 1M tokens, 1M context, described by Anthropic as "a Mythos-class model that we've made safe for general use." **Claude Mythos 5** is the same model without safety classifiers, restricted to vetted organizations via Project Glasswing. Fable's classifiers target cyber and bio content plus distillation attempts; a refusal falls back to Opus 4.8 in the Claude apps, and Anthropic claims over 95% of sessions never hit one. Two catches: 30-day data retention is mandatory (no zero-data-retention option), and the raw reasoning chain is never returned, only summaries.
- **Claude Opus 4.8** ([May 28](https://www.anthropic.com/news/claude-opus-4-8)) at the same $5/$25, and **Claude Sonnet 5** ([June 30](https://www.anthropic.com/news/claude-sonnet-5)) at an introductory $2/$10 through August 31, then $3/$15. Sonnet 5 ships a new tokenizer that produces roughly 30% more tokens for the same text, so the sticker price undersells the real cost of switching from Sonnet 4.6.
- **GPT-5.6: Sol, Terra, Luna** ([July 9](https://techcrunch.com/2026/07/09/openai-launches-its-new-family-of-models-with-gpt-5-6/)). Sol at $5/$30 (flagship), Terra at $2.50/$15 (GPT-5.5-class at half price), Luna at $1/$6. The long-context premium survives: past 272K input tokens everything bills at 2x input / 1.5x output. OpenAI's own numbers put Sol 2.8 points above Fable 5 on the Artificial Analysis Coding Agent Index at less than half the output tokens; on SWE-Bench Pro, where Fable 5 posts 80% to Sol's 64.6%, OpenAI now argues the benchmark itself is broken (~30% of tasks, it claims). Pick your scoreboard.
- **Gemini 3.5 Flash** shipped at [I/O on May 19](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-5/) at $1.50/$9, with Google claiming 4x faster output than other frontier models. **Gemini 3.5 Pro** was promised for June and has slipped twice; no such model has shipped, and the Pro line is still topped by Gemini 3.1 Pro (frozen since February).
- **Grok 4.5** ([July 8](https://docs.x.ai/developers/grok-4-5)) at $2/$6 with a 500K context window, "trained alongside Cursor" in xAI's own framing (how much Cursor session data went in, it doesn't say). xAI's own benchmarks show it beating GPT-5.5 on SWE-Bench Pro while using about a quarter of the output tokens Opus 4.8 needs; Artificial Analysis ranks it fourth overall. **Grok 5 missed its second consecutive quarter** and is now "Q3 or later."
- **Microsoft MAI models** ([Build, June 2](https://microsoft.ai/news/building-a-hillclimbing-machine-launching-seven-new-mai-models/)): seven in-house models including MAI-Thinking-1 ("preferred to Sonnet 4.6 in blind evaluations," per Microsoft's own testing) and MAI-Code-1-Flash, now inside GitHub Copilot. The subtext is OpenAI dependency reduction, and nobody is pretending otherwise.
- **Meta finally sells an API.** [Muse Spark 1.1](https://ai.meta.com/blog/introducing-muse-spark-meta-model-api/) opened the Meta Model API on July 9 at $1.25/$4.25 (US-only preview, $20 in credits), Meta's first official developer access to the closed-weight Muse line; Muse Image, its first in-house image model, rolled into Meta AI two days earlier. Llama 4 Behemoth was quietly shelved and Llama 5 forecasts have slipped to 2027; the open-weight era at Meta is over in everything but name.
- **China kept shipping**: Qwen3.7-Max (1M context, $2.50/$7.50 list) and multimodal Qwen3.7-Plus ($0.40/$1.60); Zhipu's GLM-5.2 (MIT license, 744B MoE, 1M context, $1.40/$4.40), while Zhipu itself, up roughly 15x since its January Hong Kong IPO, priced a ~$4.3B share placement this week; DeepSeek made its 75% V4-Pro discount permanent at $0.435/$0.87.

### Washington enters the release cycle

The single biggest structural change since May, and it happened twice in three weeks.

- **Fable 5 was shut down by export controls.** On June 12, three days after launch, the US Commerce Department applied export controls to Fable 5 and Mythos 5 after Amazon researchers reported a technique that bypassed the cyber safeguards. Anthropic couldn't verify user nationality in real time, so it [suspended access for everyone, worldwide](https://www.anthropic.com/news/redeploying-fable-5). Controls lifted June 30; access returned July 1 with a new classifier. A frontier model was on the market for three days, gone for nineteen, and back with a patch. That sequence had never happened before.
- **GPT-5.6 launched through a government review.** Under a June executive order on AI cybersecurity, OpenAI voluntarily submitted GPT-5.6 to a 30-day review by the Commerce Department's CAISI before public release; from June 26 only ~20 government-vetted organizations could use it. GA came July 9 when the review wrapped early. OpenAI said government sign-off should not become the "long-term default." It might anyway.

Both models are rated by their own makers as significantly cyber-capable (OpenAI's Preparedness Framework marks all three GPT-5.6 models "High" in cyber and bio). The pattern to internalize: for top-tier models, capability review is now part of the release timeline, and access can be revoked after you've built on it.

### The product graveyard

Nine weeks, and the following are dead, dying, or rebranded. If a tool is free and strategic rather than revenue-generating, treat it as provisional.

- **ChatGPT Atlas**: dead August 9, roughly nine months after launch. It never shipped beyond macOS despite launch-day promises of Windows/iOS/Android. Replaced by an in-app browser and a Chrome extension.
- **ChatGPT Pulse**: dead, folded into Scheduled Tasks (June 17). The $200/mo-exclusive feature launched last September lasted about nine months.
- **Gemini CLI**: killed June 18 in favor of the Antigravity CLI, with roughly four weeks between announcement and cutoff for individual users. Enterprise Code Assist licenses keep working; everyone else gets a new binary and no published free-tier limits.
- **Project Mariner**: shut down May 4; its capabilities scattered into Gemini Agent, Chrome's auto-browse features, and the Gemini API's computer-use surface.
- **Amazon Q Developer**: sunset in favor of Kiro; new signups stopped May 15, end of support April 2027.
- **Windsurf**: the brand no longer exists. It became Devin Desktop on June 2 via an over-the-air update after Cognition's acquisition.
- **GitHub Models**: closed to new customers June 16; full retirement July 30, announced July 1 with 29 days' notice.
- **Copilot Pro (consumer)**: retired; remaining subscriptions end by August 1. Microsoft 365 Premium at $19.99/mo is the designated replacement.
- **Qwen Code free inference**: the OAuth free tier was cut from 1,000 to 100 requests/day, then shut down entirely on April 15. The CLI stays open source; hosted inference now needs a paid Coding Plan.
- **Aider**: no release since February. Effectively dormant.
- **Sora API**: still scheduled to die September 24. No video successor has shipped in ChatGPT despite the winddown announcement back in March.

### Strategic moves

- **SpaceX went public and bought Cursor.** The IPO priced June 12 at a $1.77T valuation; xAI had been absorbed in the spring and formally rebranded as **SpaceXAI** on July 6. On June 16, SpaceX exercised its option to acquire Anysphere (Cursor) for $60B in stock, the largest acquisition of a VC-backed startup ever, expected to close Q3. The most popular AI IDE is about to be owned by a rocket company.
- **Anthropic raised $65B at a $965B valuation** ([Series H, May 28](https://www.anthropic.com/news/series-h)) and confidentially filed for an IPO on June 1. OpenAI confirmed its own confidential S-1 a week later. Both may list within a year of each other.
- **Compute money is flowing in strange directions**: Anthropic is paying SpaceX $1.25B per month for Colossus capacity through 2029, Google pays $920M per month for the same cluster (per SEC filings), Reflection signed a ~$6.3B Colossus 2 deal in June, and Google simultaneously launched a Blackstone-funded joint venture to sell TPU capacity directly. Anthropic also signed a ~$19B, 20-year lease at TeraWulf's Kentucky campus this week.
- **DeepSeek took outside money for the first time**: ~$7.4B at a $52-59B valuation with Tencent and CATL as the largest external backers, on terms (5-year lockup, zero voting rights) that read more like a patriotic donation than venture capital. The round closed in late June.
- **Meta started charging**: Meta One Plus at $7.99/mo and Premium at $19.99/mo gate heavy Meta AI usage, announced May 27 and piloting first in Singapore, Guatemala, and Bolivia.
- **Apple picked Gemini.** At WWDC (June 8), Siri was rebuilt as "Siri AI" on a custom Gemini, reportedly around $1B/year to Google. No paid Claude-in-Siri deal, though iOS 27's Apple Intelligence Extensions will let users swap in Claude (or ChatGPT, or Grok) for Siri and Writing Tools this fall; Anthropic's deeper Apple presence is developer-side, in Xcode 27.
- **Cognition raised $1B+ at $26B**; Cerebras IPO'd in May (opened up 108%, closed day one +68%); Together AI raised $800M at $8.3B on July 1; Perplexity's ARR topped $450M in March (its much-cited $20B raise was last September); Mistral is reportedly raising ~€3B at ~€20B while pivoting to being "a cloud company."

---

## Two ways to use AI models

Two layers, two bills:

1. **Chat product**, the app you talk to: ChatGPT, Claude, Gemini, Grok, Vibe (ex-Le Chat), Qwen, Copilot, Perplexity, Nova, DeepSeek, and now Meta AI. Free tiers exist; paid subscriptions ($8-$300/mo) unlock premium models, higher limits, and product features.
2. **API**, pay-per-token programmatic access. Separate billing, separate account, separate pricing.

The overlaps remain small: Google AI Pro/Ultra include $10/$100 per month in Google Cloud API credits, Perplexity Pro includes $5/month in API credits, and from July 20 Claude subscriptions meter Fable 5 through in-app usage credits billed at API rates (a chat-side meter, not API access). Everyone else: the subscription buys the app, not the endpoint.

---

## Quick comparison

| Provider | Chat product | Cheapest API (in/out per 1M) | Free API tier | Max context | Open weights |
|----------|-------------|------------------------------|--------------|-------------|-------------|
| **Google Gemini** | Gemini | $0.10 / $0.40 (Flash-Lite 2.5) | Generous, no card | 1M | Gemma 4 |
| **OpenAI** | ChatGPT | $0.05 / $0.40 (GPT-5 Nano) | Limited trial credits | 1M (GPT-5.6) | GPT-OSS (Apache 2.0, aging) |
| **Anthropic** | Claude | $1 / $5 (Haiku 4.5) | $5 trial credits | 1M | No |
| **SpaceXAI (xAI)** | Grok | $0.20 / $0.50 (Grok 4.1 Fast) | $25 sign-up credits | 2M | Partial (Grok 1, 2.5) |
| **DeepSeek** | DeepSeek | $0.14 / $0.28 (V4-Flash) | 5M tokens free | 1M | Yes (MIT) |
| **Mistral** | Vibe | $0.02 / $0.04 (Nemo) | API trial credits | 256K | Partial (+ Leanstral 1.5) |
| **Meta** | meta.ai | $1.25 / $4.25 (Muse Spark 1.1) | $20 preview credits (US); Llama self-host | 10M (Llama 4 Scout) | Llama only; Muse closed |
| **Alibaba Qwen** | Qwen | $0.05 / $0.20 (Qwen-Turbo) | 1M tokens/model, one-time | 1M (Qwen3.7) | 3.6 open; 3.7 closed so far |
| **Zhipu Z.ai** | -- | $1.40 / $4.40 (GLM-5.2) | -- | 1M | Yes (MIT) |
| **Amazon Nova** | Nova | $0.035 / $0.14 (Nova Micro) | $200 AWS credits | 1M | No |
| **Microsoft** | Copilot | $0.075 / $0.30 (Phi-4-mini) | GitHub Models (dies July 30) | 128K (Phi) | Phi (MIT); MAI hosted-tunable |
| **Perplexity** | Perplexity | $1 / $1 (Sonar) + per-req fee | No free tier | 200K | No |
| **Groq** | -- | $0.05 / $0.08 (Llama 3.1 8B, deprecated) | Rate-limited, no card | 131K | Hosts OSS only |

{% note info %}
**Pricing gotchas this cycle**: Sonnet 5's intro price ($2/$10) expires August 31 and its new tokenizer inflates token counts ~30%, so budget on $3/$15 with the fatter counts. GPT-5.6 keeps OpenAI's long-context surcharge (2x/1.5x past 272K input). DeepSeek's upcoming V4 GA introduces the industry's first **peak-hour surge pricing**: 2x during Beijing business hours. Groq is purging its catalog: qwen3-32b and llama-4-scout die July 17, Llama 3.x on August 16. And Fable 5 at $10/$50 is double Opus for workloads that must also accept 30-day retention and occasional classifier refusals.
{% endnote %}

---

## Subscription comparison

### All providers at a glance

| Provider | Chat product | Free tier | Cheapest paid | ~$20 tier | High-end |
|----------|-------------|-----------|--------------|-----------|----------|
| **Google Gemini** | [Gemini](https://gemini.google.com) | Compute-capped | AI Plus $8/mo | AI Pro $20/mo | AI Ultra $100 / $200/mo |
| **OpenAI** | [ChatGPT](https://chatgpt.com) | GPT-5.5 Instant, with ads | Go $8/mo (ads) | Plus $20/mo | Pro $100 / $200/mo |
| **Anthropic** | [Claude](https://claude.ai) | Sonnet 5, rolling limits | -- | Pro $20/mo | Max $100 / $200/mo |
| **SpaceXAI** | [Grok](https://grok.com) | ~10 msgs / 2 hrs | X Premium $8 / SuperGrok Lite $10 | SuperGrok $30/mo | Heavy $300/mo |
| **Meta** | [meta.ai](https://meta.ai) | Free (Muse) | Meta One Plus $7.99/mo | Meta One Premium $19.99/mo | -- |
| **DeepSeek** | [DeepSeek](https://chat.deepseek.com) | Unlimited (no sub) | -- | -- | -- |
| **Mistral** | [Vibe](https://chat.mistral.ai) | ~25 msgs | Student $5.99/mo | Pro $14.99/mo | Team $24.99/seat |
| **Alibaba Qwen** | [Qwen](https://chat.qwen.ai) | Unlimited (no sub) | -- | -- | -- |
| **Amazon Nova** | [Nova](https://nova.amazon.com) | Free (US only) | -- | -- | -- |
| **Microsoft** | [Copilot](https://copilot.microsoft.com) | Limited GPT-5.x | -- | M365 Premium $19.99/mo | M365 Copilot $30/seat/mo |
| **Perplexity** | [Perplexity](https://www.perplexity.ai) | Limited Pro Searches | -- | Pro $20/mo | Max $200/mo |

Notable tier movement: Google cut its top Ultra tier from $250 to $200 and inserted a $100 Ultra below it; Google also swapped daily prompt limits for a compute-used model (5-hour refresh windows against a weekly cap, with automatic fallback to smaller models). OpenAI's second $100 tier is officially just "Pro" at $100 ("Pro Lite" is the community's name, not OpenAI's), and that tier's bundled Codex capacity was quietly halved on June 1 when the launch 2x promo expired. Ads now run on ChatGPT's Free and Go tiers. Microsoft retired the consumer Copilot Pro plan outright; remaining subscriptions end by August 1 and Microsoft 365 Premium ($19.99) inherits the slot.

### What ~$20 actually buys

| Feature | ChatGPT Plus ($20) | Claude Pro ($20) | Gemini AI Pro ($20) | SuperGrok ($30) | Vibe Pro ($15) | M365 Premium ($20) | Perplexity Pro ($20) |
|---------|-------------------|-----------------|-------------------|----------------|------------------|------------------|---------------------|
| Top model | GPT-5.6 | Sonnet 5 + Opus 4.8 | Gemini 3.5 Flash | Grok 4.3 (4.5 rolling out) | Mistral Medium 3.5 | GPT-5.x + MAI | Opus 4.8, Sonnet 5, Gemini 3.5, Grok 4.5 (GPT-5.6 pending) |
| Image gen | GPT Image 1.5 | No | Nano Banana 2 / Pro | Aurora / Imagine | Yes | GPT Image 1.5 (M365) | Yes |
| Video gen | No (Sora dead, no successor) | No | Gemini Omni Flash | Imagine video (720p) | No | No | Yes |
| Voice | GPT-Live-1 (full duplex) | No | Yes | Grok Voice | No | No | No |
| Coding agent | Codex (in desktop app) | Claude Code | Antigravity + Jules | Grok Build (public beta) | Vibe | Copilot (credit-metered) | -- |
| API credits | No | No | $10/mo GCP | No | No | No | $5/mo |
| Unique value | The super-app: Chat + Work + Codex in one desktop app | Skills + Cowork + Claude Code | Workspace + NotebookLM + Omni video | X data, Tesla, 2M context | Cheapest, EU-hosted | M365 integration | Every flagship in one picker + Comet |

The interesting column changes since May: ChatGPT Plus traded the Atlas browser for the unified desktop app and real-time voice; Claude Pro gained Sonnet 5 as default plus capped Fable 5 access (Cowork's web and mobile apps are Max-only for now); Gemini AI Pro gained Omni video but is still waiting on 3.5 Pro; Perplexity Pro added every new flagship within days of each launch, per its own changelog.

**A note on Fable 5 and subscriptions**: paid Claude plans have had capped Fable 5 access since the July 1 restoration, and the cutoff keeps slipping under user pushback: July 7 became July 12, and July 12 just became July 19. From July 20, Fable 5 in the Claude apps runs on metered usage credits billed at API rates ($10/$50), and there is no automatic fallback: a plan without usage credits enabled simply loses Fable when the included window ends. Anthropic says it hopes to restore Fable as a standard plan benefit "once capacity allows." Plan accordingly rather than assuming it returns.

**High-end tiers**: Claude Max ($100/$200) buys 5x or 20x Pro usage on Opus 4.8, plus the opt-in `/fast` mode in Claude Code (billed through usage credits, not included in plan limits). ChatGPT Pro ($200) gets GPT-5.6 Sol at Extra High reasoning; ChatGPT Work, notably, is metered on every plan rather than being a Pro perk. Google's $200 Ultra holds Project Genie and Gemini Spark (a 24/7 personal agent on a dedicated VM); NotebookLM's new agentic research mode needs Ultra too, though the $100 tier suffices. SuperGrok Heavy ($300) has full Grok 4.5 while the $30 tier waits on a staged rollout.

---

## Coding agents comparison

More changed here in nine weeks than in the previous six months, and most of it was corporate rather than technical.

### First-party agents

| Agent | Provider | Cheapest access | What changed since May |
|-------|----------|----------------|------------------------|
| [Codex](https://openai.com/index/codex-for-every-role-tool-workflow/) | OpenAI | Plus $20/mo | Merged into the ChatGPT desktop app July 9; 5M weekly users; six non-engineering "role plugins"; can import Claude Code workflows |
| [Claude Code](https://claude.com/product/claude-code) | Anthropic | Pro $20/mo | Dynamic Workflows research preview (a JS orchestration script fans out up to 1,000 subagents, 16 concurrent); `/fast` mode on Opus 4.8; Auto mode expansion |
| [Antigravity](https://antigravity.google) | Google | Free tier (opaque limits) | 2.0 turned it into an agent platform (app + CLI + SDK + Managed Agents); the update broke installs and stripped the classic IDE; absorbed Gemini CLI |
| [Jules](https://jules.google) | Google | Free (15 tasks/day) | Nothing. Changelog silent since March. |
| [Grok Build](https://build.grok.com) | SpaceXAI | API pay-as-you-go | Public beta since May 25; Composer 2.5 landed in the CLI June 1 at $0.50/$2.50 |
| [Vibe](https://chat.mistral.ai) | Mistral | Vibe Pro $15/mo | Le Chat renamed to Vibe (May 28) with unified Chat + Work + Code modes; VS Code extension |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | Alibaba | Free CLI (BYOM) | Hosted free tier killed April 15; inference now needs a $50/mo Coding Plan |
| [Kimi Code CLI](https://www.marktechpost.com/2026/06/06/moonshot-ai-releases-kimi-code-cli-a-terminal-ai-coding-agent-built-in-typescript-for-next-gen-agents/) | Moonshot | Free (MIT, BYOM) | New entrant (June 6): TypeScript CLI with built-in coder/explore/plan subagents |
| [Kiro](https://kiro.dev) | Amazon | Free tier; Pro $20/mo | Official successor to Amazon Q Developer; new $100 Pro Max tier; iOS app in preview |

### Third-party agents

| Agent | Pricing | What changed since May |
|-------|---------|------------------------|
| [Cursor](https://cursor.com) | Free / Pro $20 / Pro+ $60 / Ultra $200 | Being acquired by SpaceX for $60B (closes Q3); iOS app; Composer 2.5 and a jointly-trained Grok 4.5 as house models; releases 3.4 through 3.11 |
| [Devin Desktop](https://devin.ai) | Free / Pro $20 / Max $200 / Teams $80 + $40/seat | This is Windsurf, rebranded June 2 under Cognition; Cascade replaced by Rust-based Devin Local; ACP support for running Codex/Claude/other agents inside it |
| [GitHub Copilot](https://github.com/features/copilot/plans) | Pro $10 / Pro+ $39 / Max $100 (+ flex credits) | Moved to usage-based billing June 1 (AI Credits at per-model token rates); dropped ALL Gemini models from web chat in May; desktop app GA June 17, opened to all plans July 7 |
| [Cline](https://cline.bot) | Free (BYOM) | SDK + runtime rebuild; ClinePass hosted open-weight access |
| [OpenHands](https://openhands.dev) | Free (OSS, BYOM) | Agent Canvas ships as a new surface alongside the SDK and CLI; drives third-party agents via ACP |
| [Replit](https://replit.com) | Free / paid tiers | Agent 4 since March; $9B valuation; claims $1B run-rate by year end (its own projection) |
| [Aider](https://aider.chat) | Free (BYOM) | Dormant since February |

{% note info %}
**Two quiet standards won this quarter.** The **SKILL.md format** is now supported by 30+ products including Copilot, Cursor, Codex, and Xcode 27, with marketplaces indexing over a million public skills of, frankly, mixed quality (one analysis of 47K public skills scored the average 6.2/12). And the **Agent Client Protocol (ACP)** had a breakout: Devin Desktop, OpenHands Agent Canvas, and Apple's Xcode 27 all adopted it in June, which means "which editor" and "which agent" are now separate purchasing decisions. MCP itself is getting a stateless core in the 2026-07-28 spec release, dropping the session handshake so servers scale behind ordinary load balancers.
{% endnote %}

The uncomfortable theme: coding agents are no longer small, stable tools. Cursor is becoming a SpaceX subsidiary, Windsurf's brand vanished mid-subscription, Copilot's flat pricing turned into a token meter with multipliers, and Google gave individual Gemini CLI users four weeks to migrate. The tools are better than they were in May; the ground under them is not.

---

## Deep dive: what each top provider does beyond the model

### OpenAI: the super-app shipped, the browser didn't survive it

[chatgpt.com](https://chatgpt.com) | [platform.openai.com](https://platform.openai.com)

The March promise came true on July 9: ChatGPT, Codex, and agents merged into one desktop application, with the Codex app updating in place to become it and the old app demoted to "ChatGPT Classic."

- **ChatGPT Work** is the headline agent: point it at connected apps, get back finished spreadsheets, decks, docs, and small web apps. It's metered like Codex rather than flat-rate, which is worth watching on a Plus budget. **Sites** (public beta) builds hosted interactive sites from chat.
- **Atlas is dead.** The AI browser that anchored the super-app narrative shuts down August 9 having never left macOS. Its capabilities scattered into an in-app browser, a Chrome extension, and a cloud browser for agents. If you reorganized your workflow around Atlas in the last nine months, you've been churned.
- **GPT-Live-1** finally makes voice mode conversational rather than walkie-talkie: full duplex, backchannels, and it delegates hard questions to a frontier model mid-conversation.
- **Codex** keeps broadening past engineering: six role plugins (sales, finance, design...) and 5M weekly users, about a fifth of them not developers, per OpenAI.
- Corporate turbulence is real: the No. 2 exec (Fidji Simo) stepped down July 9 citing health reasons, the safety lead is leaving after safety was folded into research (the sixth safety leader out in two years), and the S-1 is filed. Products are shipping fast partly because the IPO window demands it.

Production note: OpenAI models are now GA on Amazon Bedrock at first-party prices, the first visible fruit of the loosened Microsoft agreement.

### Anthropic: three models in five weeks, one government intervention

[claude.ai](https://claude.ai) | [platform.claude.com](https://platform.claude.com)

- **The lineup turned over completely**: Opus 4.8 (May 28), Fable 5/Mythos 5 (June 9), Sonnet 5 (June 30). Sonnet 5 is the volume play, near-Opus coding at $2/$10 intro pricing and the new default for Free and Pro. Fable 5 is the ceiling, and the first Anthropic model whose launch, shutdown, and relaunch made national news (see above).
- **Fast mode** on Opus 4.8 dropped to $10/$50 (from $30/$150 on 4.7) for up to 2.5x output speed. It stays an opt-in research preview (`/fast` in Claude Code), and on subscription plans it bills through usage credits rather than plan limits: a speed you buy per-use, not a perk.
- **Claude Code** gained a Dynamic Workflows research preview: Claude writes a JavaScript orchestration script that fans out up to 1,000 subagents per workflow (16 concurrent). Cowork reached web and mobile on July 7 (Max subscribers first), and Claude Tag brought task delegation into Slack.
- **Managed Agents** keeps compounding: scheduled cron deployments, vault credentials that inject secrets at the network boundary (the sandbox only ever sees a placeholder, which is the right answer to prompt-injection exfiltration), and self-hosted sandboxes for tool execution inside your own network.
- **Glasswing numbers are startling if you take them at face value**: 10,000+ high/critical vulnerabilities surfaced in the first four weeks, per Anthropic's own accounting, though that's Mythos plus the ~50 partner orgs collectively, not the model alone. Of the 1,752 findings independently assessed, 90.6% were valid (only 62.4% confirmed as genuinely high/critical). The program expanded to ~150 more critical-infrastructure orgs across 15+ countries with NATO and ENISA involved.
- API housekeeping worth knowing: rate limits rose across the board in June (Sonnet/Haiku now match Opus limits), refused-before-output requests are no longer billed, and a beta Swift package plugs Claude into Apple's Foundation Models framework.

The sour note is the Fable subscription saga: included free at launch, suspended, restored at 50% caps, the cutoff pushed from July 7 to July 12 to July 19, and from July 20 it's pay-per-use credits inside a $20+ subscription. Each step had a defensible reason; the sequence still trained users not to depend on the top model being there tomorrow.

### Google: excellent models, hostile product management

[gemini.google.com](https://gemini.google.com) | [aistudio.google.com](https://aistudio.google.com) | [antigravity.google](https://antigravity.google)

*Update (2026-08-03): On July 21, nine days after this post, Google released Gemini 3.6 Flash (the new fast flagship, $1.50/$7.50 per 1M tokens, roughly 17% lower token usage), Gemini 3.5 Flash-Lite (GA, $0.30/$2.50), and Gemini 3.5 Flash Cyber. No Pro shipped: the Pro line is still topped by Gemini 3.1 Pro, frozen since February. The Gemini 2.5 API family now has an announced shutdown date of October 16, 2026.*

- **Gemini 3.5 Flash** is genuinely strong for its price and speed, and it's everywhere: app, Search AI Mode, API, Antigravity. But the flagship **3.5 Pro is six-plus weeks late** and counting, an unusual public slip for Google, reportedly after a ground-up rebuild of the base model. A 2M context window and a July 17 date are now widely reported, but Google has confirmed neither; no model card, no pricing.
- **The Ultra restructure** helps: $100 gets 5x Pro limits, the top tier dropped to $200. The switch from daily prompts to compute-based metering with 5-hour windows is harder to reason about, which one suspects is not accidental.
- **Antigravity 2.0** is now a full agent platform, and its I/O demo (93 parallel subagents building a toy OS in 12 hours for under $1,000) was the most impressive stunt of the season. It's also the tool whose forced update stripped users' IDE overnight, whose quotas remain opaque, and whose model picker is still missing every current Claude (no Opus 4.7, 4.8, Sonnet 5, or Fable 5, with user threads going unanswered). The free tier is a land grab with unpublished limits, and meaningful quotas hang off paid Google AI plans; behave accordingly.
- **Gemini Omni** replaces Veo in the app for video generation (the Veo 3.1 API lives on with no announced sunset), with the Omni Flash API at roughly $0.10/second at 720p. **NotebookLM's** agentic upgrade (runs code, sources autonomously, exports decks and spreadsheets) is the best research-tool release this cycle and it's gated behind the Ultra tiers ($100 and up), which is a genuinely bad decision for its most natural users: students. AlphaEvolve, Google's algorithm-discovery agent, also went GA in Gemini Enterprise on July 9.
- **The Apple deal is the distribution coup of the year**: Siri AI runs on a custom Gemini, reportedly ~$1B/year. Between Siri, Samsung's earlier Perplexity deal, and Android itself, the default-assistant layer is being carved up while OpenAI builds destination apps.

### SpaceXAI: cheap, fast, and radioactive

[grok.com](https://grok.com) | [x.ai](https://x.ai)

- **Grok 4.5 is the price aggressor**: $2/$6 for near-flagship coding scores (xAI's own benchmarks, standard caveats; Artificial Analysis places it fourth overall) and roughly 4x fewer output tokens per task than Opus 4.8. If those numbers survive independent testing, this is the best cost-per-solved-task on the market.
- Everything around the model is in motion: xAI dissolved into SpaceX and formally took the SpaceXAI name on July 6, the combined company IPO'd, Cursor is being bought for $60B, and Grok 5 has now missed two quarters. The S-1 shows a $6.36B FY2025 loss on $3.2B revenue.
- Two things enterprise buyers should weigh honestly. First, The Information reports well over half of Grok's traffic is adult content, and its web traffic fell 22% January through May, the steepest decline among major chatbots (Similarweb; the count excludes Grok use inside X). Second, the compute business is now load-bearing: Anthropic ($1.25B/mo), Google ($920M/mo), and Reflection are Colossus tenants, meaning Grok's training rivals are also its landlords' customers.
- The Cursor integration is the actual strategy: xAI says Grok 4.5 was trained alongside Cursor, and it ships inside Cursor as a house model. Buying the most popular AI IDE is a distribution answer to a product problem.

### Microsoft: seven models and a meter

[copilot.microsoft.com](https://copilot.microsoft.com) | [github.com/features/copilot](https://github.com/features/copilot)

- **The MAI drop at Build** (seven models: reasoning, coding, image, voice, transcription) is Microsoft's declaration that the OpenAI dependency is optional. The eval claims ("preferred to Sonnet 4.6," "surpasses Nano Banana Pro") are all Microsoft's own; no independent scores yet. MAI-Code-1-Flash pricing under Haiku-class is the part that matters for CI pipelines.
- Five weeks after Build, on July 9, **GPT-5.6 became the "preferred model" for Microsoft 365 Copilot**, and Microsoft now also calls OpenAI's API directly, a first. Read the two announcements together: hedge and embrace, simultaneously.
- **GitHub Copilot's billing rewrite** is the change that will actually hit your invoice. Flat premium-requests died June 1; new billing draws AI Credits at straight per-model token rates, while legacy annual plans keep request multipliers, where Opus 4.7 went from 7.5x to 15x to 27x in sixty days. Completions stay unlimited. Budget-predictability was the product's main virtue over API keys; that's gone.
- **Claude went GA on Microsoft Foundry** June 29 with Opus 4.8 and Haiku 4.5 (Sonnet 5 and Fable 5 aren't in the GA lineup yet): the core Messages API under Entra auth and Azure billing, with several features still beta. For Azure-committed shops this is the lowest-friction Claude there is.
- Copilot dropped all Gemini models from its picker in May, one day after Gemini 3.5 Flash went GA. "Reliability and simplification," says GitHub. Competitive hygiene, says everyone else.

### Perplexity: the aggregator thesis keeps compounding

[perplexity.ai](https://www.perplexity.ai) | [docs.perplexity.ai](https://docs.perplexity.ai)

- The pitch is unchanged and strengthening: one $20 subscription, every flagship. Grok 4.5, Sonnet 5, and Gemini 3.5 all appeared in Perplexity's model roster within days of their launches, per its changelog; GPT-5.6, three days old, hasn't shown up in the picker yet but the pattern says it will. In a quarter where models turned over this fast, not being locked to one vendor was worth real money.
- **Computer** (no longer Max-only; Pro gets it too) reached Microsoft 365 and local Mac files; Deep Research now produces presentations and structured outputs, not just reports.
- ARR topped $450M in March per the FT; the much-cited $200M-at-$20B raise was last September, and an early-2026 round nudged the valuation to about $21B. The multiple assumes the Samsung-style OS distribution deals keep coming.
- One black mark to weigh: in LayerX's June "BioShocking" prompt-injection research, agentic browsers including Comet were tricked into copying credentials from signed-in sessions. OpenAI patched; Perplexity reportedly closed the report without acting. For a product whose whole premise is "let the browser act as you," that response is disqualifying for sensitive accounts until proven otherwise.

---

## What I'd actually pick

**Free chat**: unchanged. DeepSeek and Qwen give the most for $0, and both stayed unlimited while Meta started charging. Gemini's API free tier is still the most generous for tinkering, no card required, though since April it covers Flash-class models only.

**One $20 sub**: Claude Pro remains my pick for builders: Sonnet 5 as the daily default is a real upgrade, and the sub includes Claude Code, Cowork, and Skills. Know that Fable 5 goes metered after July 19 (a deadline that has already slipped twice, so verify before you budget around it). ChatGPT Plus is the broadest it has ever been now that the desktop app unifies chat, Codex, and Work agents, and GPT-Live voice is the best conversational interface anyone ships. Perplexity Pro stretches the dollar furthest if model choice is the point. Skip SuperGrok until Grok 4.5 actually reaches the $30 tier.

**Coding**: Claude Code with Sonnet 5 is the best value it has ever been; Opus 4.8 fast mode is the throughput play. Codex inside the ChatGPT app closed most of the remaining gap and its plugin ecosystem is now the widest. I would not start a new team on Cursor until the SpaceX acquisition closes and the roadmap survives it, and I'd model GitHub Copilot costs on the new credit meter before renewing seats. Antigravity is capable and free at the entry level, and Google spent this quarter demonstrating exactly how much notice free-tier users get when priorities shift: four weeks.

**Production API**: Sonnet 5 at intro pricing is the obvious volume choice through August, with the tokenizer caveat priced in. Terra is the value play in OpenAI's lineup. Grok 4.5 is worth a bake-off strictly on cost-per-task, with eyes open about the vendor's stability. Fable 5 is for the workloads that justify $10/$50 and can tolerate both mandatory retention and the (small but nonzero) chance of a classifier refusal; wire up the server-side fallback parameter, which exists for exactly this.

**Open weights**: the center of gravity is now fully in China and, increasingly, Paris. GLM-5.2 (MIT, 1M context) and DeepSeek V4 are the serious options; Gemma 4's unified multimodal 12B is the best small westerner; Mistral's Leanstral is a genuinely novel Apache-2.0 release and its "fat but sparse" frontier family is worth watching this summer. Meta has left the field, Qwen 3.7 hasn't published weights, and GPT-OSS is a year old. The March guide's open-weights column keeps shrinking in exactly the direction skeptics predicted.

The mental shift since May: I now evaluate providers on stability as much as capability. This quarter a model I was testing was switched off by a government, a browser I recommended got a shutdown date, a CLI was killed with a month's notice, and an IDE changed owners mid-sprint. The models have never been better. The platforms have never been less trustworthy. Buy accordingly: keep two subscriptions, keep your prompts and skills portable (SKILL.md and MCP make this easier than it's ever been), and never build a workflow on a free tier you couldn't rebuild in a weekend.

Nine more weeks and the model column will turn over again. This time I'm less sure the product column will still be standing.
