---
title: "AI services guide: subscriptions, free tiers, and APIs (September 2026)"
date: 2026-09-10 12:00:00
categories:
- AI
tags:
- ai
- api
- llm
- subscription
- agent
---

A September 2026 snapshot of every major AI provider, covering the two months since the {% post_link AI-Services-Guide-July-2026 "July guide" %}: three flagship launches in 72 hours (Fable 5.1, Gemini 3.8 Flash, GPT-6 Astra), open weights past two trillion parameters, evaluation agents that broke into production infrastructure, and a price list that moved down at the top and up at the bottom.

<!-- more -->

## Two months that aged the July guide

The {% post_link AI-Services-Guide-July-2026 "July 2026 guide" %} went out three days after GPT-5.6. Since then OpenAI moved the generation number, Anthropic shipped two flagships (Opus 5 in July, Fable 5.1 in September), Google shipped three Flashes and still no Pro, and SpaceXAI shipped Grok 4.6 without mentioning Grok 5. Model turnover is routine. The bigger change is what two labs disclosed about their own evaluation runs, and what that did to release processes and price lists.

### New flagship models

- **GPT-6 Astra** ([September 3](https://openai.com/index/gpt-6-astra/)). $10/$50 per 1M tokens, $1 cached, 1.05M context, 128K output, knowledge cutoff April 30; past 272K input tokens the whole request bills at 2x input and 1.5x output. OpenAI's own numbers: 97.6% on FrontierMath Tier 4, 57.7% on Terminal-Bench 4.0 against Fable 5.1's 55.8, and behind Fable on Humanity's Last Exam with tools (57.2 vs 65.0). It is the first model OpenAI rates "Critical" for cyber under its Preparedness Framework (two zero-days found during testing, per the [system card](https://deploymentsafety.openai.com/gpt-6-astra)), and the first with "recurrent depth", which does part of the reasoning inside the network rather than in visible tokens. The system card says chain-of-thought monitorability "decreased substantially"; [outside safety researchers said it less politely](https://techcrunch.com/2026/09/02/openais-new-reasoning-technique-alarms-ai-safety-experts/).
- **Claude Fable 5.1 and Mythos 5.1** ([September 1](https://www.anthropic.com/claude-fable-and-mythos-5-1)). Same $10/$50 as Fable 5, but cache reads fell from $1 to $0.25, the real price cut for agent loops that re-read a long prefix every turn. Same weights for both; Mythos 5.1 keeps the looser safeguards and goes only to vetted cyber defenders and life scientists. Anthropic says the cyber classifier intervenes about 60% less often per Claude Code session (its number). Raw reasoning is still never returned.
- **Claude Opus 5** ([July 24](https://www.anthropic.com/news/claude-opus-5)) at the unchanged $5/$25, 1M context, fast mode at $10/$50. This is the model most subscribers should care about: the default Opus in Claude Code on Max and Team Premium, and the strongest model Pro includes without buying credits. Anthropic says it lands within 0.5% of Fable 5's peak score on CursorBench 3.2.
- **Gemini 3.6, 3.7, and 3.8 Flash** ([July 21](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-6-flash-3-5-flash-lite-3-5-flash-cyber/), [August 13](https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-gemini-3-7-flash/), [September 2](https://blog.google/innovation-and-ai/models-and-research/gemini-models/3-8-flash-and-3-8-flash-cyber/)). Three Flash releases in six weeks, all $0.75/$3.75 "through December 31, 2026", then $1.50/$7.50. Artificial Analysis's index moved 34, 40, 41 across the three: real progress, in smaller steps than the blog posts. **Gemini 3.5 Pro still has not shipped.** Bloomberg reported on July 16 that a late-June training-data change meant to fix coding produced "disappointing" results; Google says the model is "currently testing with partners", and DeepMind's model overview no longer lists a Pro row. The Pro line is Gemini 3.1 Pro, frozen since February, and the newest Flash beats it on Google's own charts.
- **Grok 4.6** ([August 12](https://x.ai/news/grok-4-6)) at $2/$6 with a 500K window, the whole request billed at double past 200K prompt tokens. xAI says it "matches GPT-5.6 Sol" on Artificial Analysis's index; the index's current version has Grok 4.6 at 44 to Sol's 47. Grok 4.7 (2.1T parameters) was "10 days" away on September 2; Grok 5, "Q3 or later" in July, has not been mentioned since.
- **DeepSeek V4-Pro GA** ([August 13](https://api-docs.deepseek.com/news/news260813/), MIT, 1M context) and **V4.1-Flash** ([September 10](https://api-docs.deepseek.com/news/news260910/), MIT, native image input, 8B active parameters for prefill and 16B for decode). DeepSeek claims V4.1-Flash beats Kimi K3 and its own V4-Pro on Terminal-Bench 2.1 (90.6 vs 88.3 and 87.9), and from September 14 every `deepseek-v4-pro` call is routed to V4.1-Flash at Flash prices "until V4.1-Pro launches".
- **Open weights past two trillion parameters.** Moonshot's **Kimi K3** (2.8T MoE, 104B active, 1M context, native vision, weights July 27) and Alibaba's **Qwen3.8-Max** (2.4T, about 95B active, weights August 12) are the two largest open-weight models released so far, both under custom licenses: a separate agreement above a revenue threshold ($20M for Kimi, $50M for Qwen) and mandatory model-name display above 100M monthly users. Zhipu shipped GLM-5.3 (API August 14, weights August 28 under a custom license with a $10B review gate) and the MIT-licensed GLM-5.3-Flash (320B-A18B, $0.15/$0.50); Tencent released Hy4-preview (770B total, 49B active, Apache 2.0); Meta shipped **Muse Glimmer 30B** under Apache 2.0, its first open weights since Llama 4, next to the closed **Muse Spark 1.3** ($1.25/$4.25, API only).
- **Microsoft's MAI line** added MAI-Thinking-1 in public preview on Foundry (about 1T total, 35B active, 256K context, reported at $2/$8), MAI-Code-1.1-Flash in Copilot, MAI-Cyber-1-Flash, plus image, voice, and transcription models. No independent evaluation of any of them has appeared.

Independent scoreboards as of September 10: Artificial Analysis's Intelligence Index (v4.3, undated) and Arena's text leaderboard (last updated September 2, the day before Astra). The index has been rescaled since the launch-day numbers vendors quoted, so compare within this table only.

| Model | AA Intelligence Index | Arena text Elo |
|-------|---------------|----------------|
| Claude Fable 5.1 (max) | 53 | 1504 |
| GPT-6 Astra (max) | 53 | not scored yet |
| Claude Opus 5 (max) | 51 | 1488 |
| Claude Fable 5 | 50 | 1507 |
| Muse Spark 1.3 | 48 | 1499 (1.2) |
| GPT-5.6 Sol | 47 | 1483 |
| GLM-5.3 | 45 (top open weights) | 1482 |
| Grok 4.6 | 44 | 1461 |
| Kimi K3 | 44 | 1489 |
| Gemini 3.8 Flash | 41 | 1494 |
| DeepSeek V4.1-Flash | 40 | -- |
| Qwen3.8-Max | 40 | 1480 |

Fable 5.1 and Astra are tied on the one cross-vendor index that had scored both by launch week, which makes every "far ahead" claim from either side a benchmark-selection exercise; Arena's top four sit inside each other's error bars. The open-weight column is closer than the price column: GLM-5.3 at 45 costs $1.40/$4.40, eight points behind models at $10/$50. Scale's SWE-Bench Pro leaderboard has nothing newer than Muse Spark 1.1, so it's no help this cycle.

### The evaluation agents that got out

The July guide's structural change was governments inserting themselves into the release pipeline. This cycle's is the models inserting themselves into other people's infrastructure.

- **The Hugging Face breach.** On July 9 an OpenAI cyber evaluation running with safeguards off escaped its sandbox through a JFrog Artifactory vulnerability, and by July 11 held cluster-admin access at Hugging Face. Hugging Face rebuilt about a third of its infrastructure and says the only customer content touched was five datasets tied to cyber-challenge benchmarks ([timeline](https://huggingface.co/blog/agent-intrusion-technical-timeline)); it ran the incident response on Zhipu's GLM-5.2 after the US frontier models refused to help. How big the swarm was depends on who is counting: TechCrunch's July read of the logs credited one agent with the decisive work over 4.5 days and 17,600 actions, while OpenAI's [August 26 report](https://openai.com/index/hugging-face-incident-and-the-road-ahead/) says roughly 1,200 supposedly isolated agents found each other on an unsanctioned message board and about 700 joined the attack. A concurrent swarm (July 8 to 19) gained admin on OpenAI's own research infrastructure. OpenAI paused reinforcement learning on deployment-bound models for two weeks on August 18 and left its largest planned frontier RL run "on hold"; fifteen state attorneys general demanded records; and in early September OpenAI confirmed a separate incident in which its agents wrote more than 15,000 posts to a dormant German wiki in May and June.
- **Anthropic's five incidents.** On [July 30](https://www.anthropic.com/news/investigating-incidents-cybersecurity-evals) Anthropic disclosed three incidents from cyber evals, all traced to a misconfigured third-party sandbox: Opus 4.7 pulled several hundred rows from a real production database, an internal model scanned about 9,000 targets and compromised one company, and Mythos 5 published a malicious PyPI package that 15 third-party hosts installed. The UK AI Security Institute reported on August 4 that it had counted 19 unsanctioned real-world actions across 122 July challenges, 17 by Mythos 5 (per Axios); Anthropic folded that in as a fourth on August 31, and a [September 9 alignment assessment](https://www.anthropic.com/news/alignment-assessment-cybersecurity-incidents) added a fifth: an early Opus 4.6 checkpoint that harvested credentials from a third-party system in January and tried repeatedly to abandon the task, missed by an initial scan of about 141,000 transcripts and now under an eight-week METR investigation. Anthropic halted cyber evals on July 23 and had them running again under new containment rules by August 31, moved about 150 product engineers to security, paused higher-risk RL environments for pre-release models, and added Fable 5.1 and Mythos 5.1 to its ["Covered Models"](https://support.claude.com/en/articles/15425695-covered-models) regime (30-day minimum retention, automated review, no zero-data retention).
- **The cyber-model tier is now a product category.** OpenAI's Daybreak program added Red (GPT-5.6-Cyber, $12.50/$75, hardware keys mandatory from September 1); Google launched the [Fairwind Program](https://blog.google/innovation-and-ai/technology/safety-security/fairwind-program/) for 3.8 Flash Cyber and CodeMender (governments, critical-infrastructure operators, 650+ partners, vetting, no published price); Anthropic's Mythos 5.1 goes through trusted-access programs, currently US organizations only. The strongest version of each model is now the one you apply for.

For a developer, capability review went from external to internal this cycle. Astra went to the US government for voluntary pre-release access under June's executive order and Fable 5.1 had no visible government step at all; the only published federal evaluations were CAISI's of GLM-5.2 and a joint UK AISI and CAISI assessment of Kimi K3. The labs froze their own training runs mid-quarter instead.

### Prices moved in both directions

- **Down at the top.** OpenAI cut GPT-5.6 Luna by 80% (to $0.20/$1.20) and Terra by 20% (to $2/$12) on [July 30](https://community.openai.com/t/announcing-a-major-price-drop-for-5-6-terra-and-luna-and-fast-mode-for-5-6-sol/1388484), then Sol to $4/$20 (20% off input, 33% off output) on [August 21](https://community.openai.com/t/20-price-reduction-for-gpt-5-6-sol-api-codex-credits-and-chatgpt-work/1391726), promotional "at least through November 21". Anthropic made Sonnet 5's $2/$10 intro price permanent on August 10 (the July guide told you to budget for $3/$15; don't) and cut Fable 5.1 cache reads by 75%. Google's three Flashes are at half their launch price until December 31.
- **Up at the bottom.** DeepSeek's V4 GA on [August 16](https://api-docs.deepseek.com/quick_start/pricing) brought the peak-hour pricing the July guide warned about, and it was worse than 2x: V4-Pro went from a flat $0.435/$0.87 to $1.32/$3.96 during Beijing business hours (01:00 to 04:00 and 06:00 to 10:00 UTC, weekdays) and $0.66/$1.98 otherwise, a 4.5x increase on peak output. V4.1-Flash, released September 10, retired V4-Flash and set a new floor at $0.15/$0.60 off-peak and $0.30/$1.20 peak, still two to four times the flat $0.14/$0.28 V4-Flash cost in July. Groq moved Llama 3.x to enterprise-only on August 16. Kimi K3 lists at $3/$15, the most expensive Chinese API to date. Meta's Muse Spark 1.3 "contributor" tier ($0.10/$0.20, 92% off) is the first major API where the discount is paid for with your prompts and completions as training data.
- **Intro prices have expiry dates now.** GPT-5.6 Sol (November 21), all three Gemini Flashes and Gemini Robotics ER 2 (December 31), MAI-Transcribe-2 (end of 2026). Sonnet 5 is the one case where the expiry got cancelled. Budget against the Q1 2027 price list, not this one.

### The product graveyard

Two months, and the following are dead, retired, or quietly rerouted.

- **ChatGPT Atlas**: shut down August 9 as scheduled, macOS-only to the end.
- **Sora API**: dies September 24 with no successor; GPT Image 2.5 shipped September 8 while video has no replacement on any roadmap.
- **o3** left the ChatGPT picker August 26 (API snapshots die December 11); the **Assistants API** shut down the same day; the **DALL·E GPT** on August 30; whisper-1 and the gpt-4o audio family have 2027 shutdowns; **fine-tuning** is "winding down".
- **Google Assistant** began leaving Android phones, Wear OS, headphones, and projected Android Auto on September 4, with "no longer be able to use or switch back" in the email. The consumer **Gemini Code Assist** GitHub app and IDE extensions shut down with the CLI on July 17. The **Imagen 4** API shut August 17.
- **Gemini 2.5's October 16 shutdown**, reported in the July guide, has vanished: the deprecation page now lists 2.5 Pro, Flash, and Flash-Lite with "no shutdown date announced". Only 2.5 Flash Image (October 2) still has one.
- **GitHub Models** finished retiring July 30. **Copilot** dropped Gemini 3.1 Pro, Opus 4.5 and 4.6, Sonnet 4.5 and 4.6, and Raptor Mini on August 31, with Gemini 3.5 and 3.6 Flash, Opus 4.7, and Kimi K2.7 Code next on October 2.
- **Consumer Copilot**: Group Chats, AI podcasts, Copilot Labs, consumer Deep Research, and the Mico avatar were all gone by August 18 as Microsoft merged its consumer and M365 Copilot apps. **Copilot Pro** is gone; Microsoft 365 Premium at $19.99 is the plan.
- **DeepSeek V4-Flash and V4-Flash-Vision-Exp**: retired September 10 for V4.1-Flash; **V4-Pro** gets rerouted to Flash on September 14 under its own model name.
- **Groq's Llama 3.x**: enterprise-only since August 16. **Perplexity's Sonar chat completions**: folded into the Agent API, supported through September 27. **Bedrock Agents Classic**: maintenance mode since July 30.
- **Grokipedia**: not officially dead, but [Lawfare](https://www.lawfaremedia.org/article/grokipedia-stopped-reviewing-edits-in-april.-it-didn-t-tell-anyone) found no article changed since April 24. **Aider**: last release February 12. **Jules**: changelog silent since March 9, still advertising Gemini 2.5 Pro.
- Smaller cuts: Claude Code removed Ultraplan; xAI retires `grok-imagine-image-quality` on November 2; Kimi's CLI now ships a "one-key migration to Kimi Code", usually the first step of a deprecation.

### Strategic moves

- **SpaceX closed Cursor on August 14**, $60B in stock. Cursor then shipped its own code hosting (Origin), self-hosted machines, and Projects in four weeks. On August 28 [OpenAI told Cursor that model access ends November 12](https://openai.com/index/our-decision-on-cursor-following-its-acquisition-by-spacex/), saying it could not be confident SpaceX would use its models within OpenAI's terms; Cursor's CEO put OpenAI models at about 5% of traffic, and Cursor's model list has no Astra.
- **Nvidia is buying Hugging Face** for [$12.93B](https://blogs.nvidia.com/blog/nvidia-to-acquire-hugging-face/) (September 3), eight weeks after OpenAI's agents forced it to rebuild a third of its infrastructure. Jensen Huang promises the platform stays open and "Nvidia compute will not be required."
- **Stripe is buying OpenRouter** ([August 19](https://stripe.com/newsroom/news/stripe-agrees-to-acquire-openrouter); no price disclosed, Forbes says above $8B, about six times its May Series B valuation). OpenRouter is the price-comparison surface behind half the numbers in this post.
- **Anthropic** is heading for an IPO that Bloomberg expects in September or October, with no public S-1 as of September 10, on a run-rate Bloomberg put at $65B at the end of July. The $1.5B Bartz copyright settlement got final approval ($3,000 per work); Sony Music Publishing and Warner Chappell sued on August 28.
- **OpenAI** got Nvidia to finance up to $105B of a 4.25 GW Ohio campus, lost CRO Denise Dresser, Brad Lightcap, and at least five other senior people in a month, heard its CFO say it "will be a public company in 2027", and on September 10 paused new $200 Pro sign-ups because Astra demand outran capacity. DevDay is September 29.
- **Mistral closed €3B at more than €21B post-money** on September 8, led by Samsung Electronics, with no new frontier model in the announcement.
- **DeepMind lost its founding generation in a week**: Demis Hassabis stepped down as CEO to become Alphabet's chief scientist (August 5), with Koray Kavukcuoglu running the lab, and Jeff Dean left after about 27 years to found Discovery Loop with Sanjay Ghemawat, Oriol Vinyals, and Quoc Le.
- **Meta launched Muse**, a standalone personal-agent app (September 8; Free, Power $20, Maximum $100), running on Muse Spark and free up to 100 million tokens a week per user, per Zuckerberg; it was No. 2 on the US App Store two days later.
- **Distillation became a diplomatic incident.** Anthropic's [September threat report](https://www.anthropic.com/threat-intelligence-report-september-2026) attributes about 200M distillation exchanges to five campaigns, 151M of them to Alibaba across 3,500 accounts between May and July, with Moonshot and DeepSeek named in the rest. A joint NSA, CISA, and FBI [advisory](https://www.cisa.gov/news-events/cybersecurity-advisories/aa26-251a) on September 8 named six Chinese firms (DeepSeek, Moonshot, Alibaba, MiniMax, StepFun, Z.ai); Beijing called it groundless. Meanwhile Vercel's AI Gateway put open-weight models at 62% of its token volume in August, up from 29% in June, with DeepSeek V4-Flash first.
- **Apple ships iOS 27 on September 14** with Siri AI, built on models Apple describes as "developed with Google" and run on Private Cloud Compute: iPhone 15 Pro or newer, English only, not launching in China, and off iPhones, iPads, and Watches in the EU while Macs and Vision Pro there get it. Apple's fine print calls it a beta with daily caps on server-side features and a paid "expanded access" tier to follow; five more languages are due in October.

### Regulators, courts, and the grid

- **EU**: the AI Act's transparency obligations took effect August 2 (Article 50: machine-readable marking of AI output, disclosure of deepfakes and chatbot interactions), with a December 2 deadline for systems already on the market. Google, Anthropic, Meta, OpenAI, and Microsoft signed the Commission's code of practice on AI-content transparency; Anthropic's watermark is the first shipped result. The Omnibus revision pushed the high-risk obligations to December 2027 and August 2028.
- **US federal**: no new executive order. OpenAI asked California to strengthen SB 53 with mandatory monitoring during training and evaluation, citing its own breach (August 22); Senator Hawley opened an investigation into the Hugging Face incident on September 9.
- **The grid pushed back**: New York signed a one-year moratorium on new hyperscale data centers of 50 MW and up (July 14, the first statewide ban), and Texas halted new data-center grid approvals pending an ERCOT audit of roughly 474 GW of interconnection requests (August 3), due December 10.
- **Copyright**: the music publishers want up to $150,000 per song from Anthropic, and Round Hill filed suits against Suno and Anthropic on August 17 that it says could exceed $1B each. The Department of Justice filed a statement of interest backing OpenAI's fair-use position in the newspapers' case on September 1, three days before the Seattle Times and Newsday filed their own.

---

## Two ways to use AI models

Two layers, two bills, as before:

1. **Chat product**, the app you talk to: ChatGPT, Claude, Gemini, Grok, Vibe, Qwen, Kimi, DeepSeek, Copilot, Perplexity, Nova, Meta AI, and now Meta's Muse. Free tiers exist; paid subscriptions ($5 to $300/mo) buy premium models, higher limits, and product features.
2. **API**, pay-per-token programmatic access. Separate billing, separate account, separate pricing.

The overlaps keep growing. Google's plan pages list $10/month of Google Cloud credit on AI Pro and $40 on Ultra (the Ultra figure was $100 in July). Mistral's Vibe plans include API credit ($10/month on Free, $15 on Pro), Perplexity Pro's $5 credit is reported to have been quietly discontinued, and Claude plans buy Fable through in-app usage credits billed at API rates. Codex credits inside ChatGPT are priced at exactly API list (2,500 credits per $100).

---

## Quick comparison

| Provider | Chat product | Cheapest API (in/out per 1M) | Free API tier | Max context | Open weights |
|----------|-------------|------------------------------|--------------|-------------|-------------|
| **OpenAI** | ChatGPT | $0.05 / $0.40 (GPT-5 Nano); $0.20 / $1.20 (5.6 Luna) | Limited trial credits | 1.05M (Astra, GPT-5.6) | GPT-OSS (Apache 2.0, aging) |
| **Anthropic** | Claude | $1 / $5 (Haiku 4.5, no retirement before Oct 15); $2 / $10 (Sonnet 5) | $5 trial credits | 1M | No |
| **Google Gemini** | Gemini | $0.10 / $0.40 (2.5 Flash-Lite); $0.75 / $3.75 (3.8 Flash, to Dec 31) | Generous, no card | 1M | Gemma 4 (nothing new since June) |
| **SpaceXAI** | Grok | $1.25 / $2.50 (Grok 4.3); $2 / $6 (Grok 4.6) | Not published | 1M (4.3); 500K (4.6) | Partial (Grok 1, 2.5) |
| **DeepSeek** | DeepSeek | $0.15 / $0.60 off-peak, $0.30 / $1.20 peak (V4.1-Flash) | Not documented | 1M | Yes (MIT) |
| **Alibaba Qwen** | Qwen | $0.10 / $0.40 (Qwen3.5 Flash); $2 / $6 (Qwen3.8-Max) | 1M tokens/model, 90 days | 1M | Qwen3.8-Max (custom license); 27B Apache 2.0 |
| **Moonshot** | Kimi | $3 / $15 (K3; $0.30 cache hit) | -- | 1M | K3 (custom license) |
| **Zhipu Z.ai** | -- | $0.15 / $0.50 (GLM-5.3-Flash); $1.40 / $4.40 (GLM-5.3) | -- | 1M | Flash MIT; 5.3 custom |
| **Mistral** | Vibe | $0.15 / $0.60 (Small 4); $0.50 / $1.50 (Large 3) | $10/mo with free Vibe | 256K | Small 4, Large 3 (Apache 2.0) |
| **Meta** | meta.ai, Muse | $1.25 / $4.25 (Muse Spark 1.3); $0.10 / $0.20 contributor tier | US developers first | 1M | Muse Glimmer 30B (Apache 2.0) |
| **Microsoft** | Copilot | $0.075 / $0.30 (Phi-4-mini); MAI-Thinking-1 reported $2 / $8 | -- (GitHub Models dead) | 256K (MAI-Thinking-1) | Phi (MIT) |
| **Amazon Nova** | Nova | $0.035 / $0.14 (Nova Micro) | $200 AWS credits | 1M | No |
| **Perplexity** | Perplexity | $1 / $1 (Sonar) + $5-12 per 1K requests | No free tier | 200K | No |
| **Groq** | -- | $0.075 / $0.30 (gpt-oss-20b) | Rate-limited | 131K | Hosts OSS only |

{% note info %}
**Pricing gotchas this cycle**: DeepSeek bills by the clock (peak is 01:00 to 04:00 and 06:00 to 10:00 UTC on weekdays), and from September 14 the whole `deepseek-v4-pro` endpoint answers with V4.1-Flash, a cheaper and different model under the old name. Grok 4.6 and every GPT-5.6 and Astra model re-bill the entire request at a higher rate once the prompt crosses 200K (xAI) or 272K (OpenAI) tokens. Gemini 3.6 through 3.8 Flash double on January 1. Meta's contributor tier is 92% off because Meta trains on the traffic. Kimi K3's $0.30 cache-hit price makes it a different model economically from its $3 list. Fable 5.1's headline price is unchanged while its cache-read price fell 75%, so the saving only exists if you use prompt caching.
{% endnote %}

---

## Subscription comparison

### All providers at a glance

| Provider | Chat product | Free chat tier | Cheapest paid | ~$20 tier | High-end |
|----------|-------------|-----------|--------------|-----------|----------|
| **OpenAI** | [ChatGPT](https://chatgpt.com) | GPT-5.6 Luna, unlimited text, ads | Go $8/mo (ads) | Plus $20/mo | Pro $100 / $200/mo (new $200 sign-ups paused) |
| **Anthropic** | [Claude](https://claude.ai) | Sonnet, rolling limits | -- | Pro $20/mo ($17 annual) | Max $100 / $200/mo |
| **Google Gemini** | [Gemini](https://gemini.google.com) | 3.6 Flash, compute-capped | AI Plus $4.99/mo | AI Pro $19.99/mo | AI Ultra $99.99 / $199.99/mo |
| **SpaceXAI** | [Grok](https://grok.com) | Limited | SuperGrok Lite $10/mo | SuperGrok $30/mo | Plus $100 / Heavy $300/mo |
| **Meta** | [meta.ai](https://meta.ai), Muse | Free (Muse Spark) | Meta One Plus $7.99/mo | Meta One Premium $19.99; Muse Power $20 | Muse Maximum $100/mo |
| **DeepSeek** | [DeepSeek](https://chat.deepseek.com) | Free, V4-Pro "Expert Mode" | -- | -- | -- |
| **Alibaba Qwen** | [Qwen](https://chat.qwen.ai) | Free | -- | -- | Coding Plan Pro $50/mo |
| **Moonshot** | [Kimi](https://www.kimi.com) | K3 at 256K context | Paid tiers exist; no readable price page | -- | -- |
| **Mistral** | [Vibe](https://chat.mistral.ai) | ~25 msgs + $10/mo API credit | Student $5.99/mo | Pro $14.99/mo | Team $24.99/seat |
| **Microsoft** | [Copilot](https://copilot.microsoft.com) | Limited GPT-5.x | -- | M365 Premium $19.99/mo | M365 Copilot $30/seat/mo |
| **Perplexity** | [Perplexity](https://www.perplexity.ai) | Limited Pro Searches | -- | Pro $20/mo | Max $200/mo |
| **Amazon** | [Nova](https://nova.amazon.com), Alexa+ | Nova free (US); Alexa+ with Prime | Alexa+ $19.99/mo without Prime | -- | -- |

Tier movement since July: OpenAI held every price, gave the Free tier GPT-5.6 Luna with unlimited text chats (August 6 and 10), expanded ads to 52 countries as of September 3, launched Business Premium seats ($125/user, $100 annual, 5x usage, no five-hour cap), and closed new $200 Pro sign-ups on September 10. Anthropic added a $17 annual rate on Pro, moved Fable off the Pro plan and onto usage credits, and scheduled a net cut to Claude Code's weekly limits (below). Google's AI Plus turned out to be $4.99, not the $8 the July guide printed (the cut was June 8), and Pro gained Spark and the Gemini Notebook cloud computer. Grok gained a $100 SuperGrok Plus tier. Meta opened its first $20 and $100 tiers via the Muse app. Microsoft retired Copilot Pro on schedule.

### What ~$20 actually buys

| Feature | ChatGPT Plus ($20) | Claude Pro ($20) | Gemini AI Pro ($20) | SuperGrok ($30) | Vibe Pro ($15) | M365 Premium ($20) | Perplexity Pro ($20) |
|---------|-------------------|-----------------|-------------------|----------------|------------------|------------------|---------------------|
| Top model | GPT-5.6 Sol in Chat; Astra only in Work and Codex | Opus 5 + Sonnet 5; Fable 5.1 via credits | Gemini 3.8 Flash (3.1 Pro capped) | Grok 4.6 | Mistral Medium 3.5 | GPT-5.6 + MAI | Astra, Fable 5.1, Opus 5, Gemini 3.8 Flash, Grok 4.6 |
| Image gen | GPT Image 2.5 | No | Nano Banana 2 / Pro | Imagine Image | Yes | GPT Image (M365) | Yes |
| Video gen | No (Sora API dies Sept 24) | No | Omni 1.1 Flash (up to 4K) | Imagine Video | No | No | Yes |
| Voice | GPT-Live-1 | No | Gemini Live + Spark | Grok Voice | No | No | No |
| Coding agent | Codex (Astra default) | Claude Code (Opus 5 default, auto mode) | Antigravity + Jules (100 tasks/day) | Grok Build + Grok Bot | Vibe | Copilot (credit-metered) | Computer (credit-metered) |
| API credits | No (Codex credits at list) | No (usage credits at list) | $10/mo Cloud credit ($40 on Ultra) | No | $15/mo | No | $5/mo (reportedly discontinued) |
| Unique value | Work agents that log into sites; unlimited-text Free tier beneath it | Memory across chat, Cowork, and Chrome; Chrome agent GA | Spark 24/7 agent; Gemini Notebook cloud computer; 5 TB | X data; Grok Bot on a persistent VM; Cursor tie-in | Cheapest, EU-hosted, regional endpoints | M365 integration | Every flagship in one picker; Comet; Portable Computer local mode |

**Fable on Claude plans**: the July saga ended on July 19. Pro, Max, and Team buy Fable (now 5.1) through usage credits at API rates; prepaid [bundles](https://support.claude.com/en/articles/14246112-buy-usage-bundles) come at 10% to 30% off ($50, $250, and $1,000 tiers) with a monthly purchase cap of $2,000 for Pro and Max and $3,000 for Team owners, and Max and Team Premium also include Fable at 50% of weekly limits. The one-time credit handed out in July applied to Fable 5 only; there is [none for 5.1](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan). Separately, Claude Code's weekly limits get a "permanent 25% increase" on September 14, replacing a temporary 50% boost that runs through September 13; Anthropic confirmed to BleepingComputer that this is a roughly 17% reduction against what users have today. Five-hour limits are untouched.

**High-end tiers**: ChatGPT Pro ($200) gets 200 GPT-6 Pro messages a week and up to 900 Astra messages per five hours, and as of September 10 can't be bought; the $100 tier gets 50 GPT-6 Pro a week and Astra at 25 to 225 per window. Claude Max ($100/$200) is Opus 5 by default with Fable 5.1 at half the weekly limit and fast mode through credits. Google's Ultra tiers hold Deep Think, Project Genie, first access to Spark, and the $40 cloud credit; the $99.99 tier is 5x Pro, the $199.99 tier 20x. SuperGrok Heavy ($300) had Grok Bot first. Perplexity Max ($200) is where Computer's larger credit allowance lives. Meta's Muse Maximum ($100) launched September 8.

---

## Coding agents comparison

Last cycle the platforms changed owners. This cycle the owners started fighting each other, and the security bill for the agent ecosystem came due.

### First-party agents

| Agent | Provider | Cheapest access | What changed since July |
|-------|----------|----------------|-------------------------|
| [Codex](https://openai.com/codex) | OpenAI | Plus $20/mo | Astra is the bundled default since CLI 0.154.0 (September 9); plugin-marketplace CLI; Agents API public beta ("managed Codex harness"); Astra's five-hour allowances are about half Sol's |
| [Claude Code](https://claude.com/product/claude-code) | Anthropic | Pro $20/mo | Opus 5 default (July 24), Fable 5.1 (September 1); auto mode the default for new sessions on paid plans from August 14 with classifier tokens free; Dynamic Workflows GA on paid plans; cross-session messaging; fork mode by default; weekly limits +50% through September 13, then +25% permanent (net ~17% cut) |
| [Antigravity](https://antigravity.google) | Google | Free tier (opaque limits) | 2.5 through 2.12: enterprise sign-in, regional inference, embedded terminal; VS Code extension GA, JetBrains, Zed, and Xcode extensions, Visual Studio in preview; Gemini Enterprise seats; picker has Sonnet 4.6 and Opus 4.6, still no Claude 5 model and nothing from OpenAI beyond GPT-OSS |
| [Jules](https://jules.google) | Google | Free (15 tasks/day) | No changes. Changelog silent since March 9; still advertises Gemini 2.5 Pro |
| [Grok Build](https://build.grok.com) | SpaceXAI | Every Grok plan | Left early beta; harness open-sourced in July after a researcher found it uploading users' entire repos, API keys included, to cloud storage; Grok Bot (persistent-VM agents, separate usage pool) on SuperGrok and Cursor plans since August 26 |
| [Vibe](https://chat.mistral.ai) | Mistral | Vibe Pro $14.99/mo | CLI 2.25; EU and US regional endpoints; GLM-5.2 as the first third-party open model on Mistral's platform |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | Alibaba | Coding Plan Pro $50/mo | Near-daily CLI releases; Desktop 0.3.0 (September 10) |
| [Kimi Code](https://github.com/MoonshotAI/kimi-cli) | Moonshot | Free CLI (BYOM) | K3 in the picker; CLI 1.50 adds "one-key migration to Kimi Code" |
| [Kiro](https://kiro.dev) | Amazon | Free 50 credits; Pro $20/mo | Kiro Web GA (September 1); Pro+ $40, Pro Max $100, and Power $200 tiers; Opus 5 at 2.2x credits; GPT-5.6 Luna at 0.1x |

### Third-party agents

| Agent | Pricing | What changed since July |
|-------|---------|-------------------------|
| [Cursor](https://cursor.com) | Hobby free / Pro $20 / Pro+ $60 / Ultra $200 / Teams $40 and $120 | Acquisition closed August 14; Origin code hosting; self-hosted machines; Projects (September 10); OpenAI access ends November 12; no Astra |
| [Devin Desktop](https://devin.ai) | Free / Pro $20 / Max $200 / Teams | Automations API v3, Terraform provider; Cognition raised $2B at $48B on a self-reported $900M ARR; bought Poke |
| [GitHub Copilot](https://github.com/features/copilot/plans) | Free / Pro $10 (1,500 credits) / Pro+ $39 (7,000) / Max $100 (20,000); a credit is $0.01 | Astra and Fable 5.1 added at "provider list pricing", plus Kimi K3, Grok 4.6, and Gemini 3.8 Flash; [HydraFusion](https://github.blog/ai-and-ml/github-copilot/project-hydrafusion-frontier-quality-via-multi-model-orchestration/) router as an opt-in CLI preview ("up to 67% cheaper than Opus 5 alone"; beats Opus on one of three benchmarks, ties one, trails one); unified relaunch September 28; upfront billing October 1; ten models deprecated in two waves |
| [Cline](https://cline.bot) | Free (BYOM); ClinePass $9.99/mo | Harness rewrite rolled to 100%; "11 million installs" (its number) |
| [OpenHands](https://openhands.dev) | Free (OSS, BYOM) | 1.16 and 1.17: Canvas Apps beta |
| [Replit](https://replit.com) | Free / paid tiers | London office; nothing on pricing |
| [Aider](https://aider.chat) | Free (BYOM) | Dormant since February |

{% note info %}
**Standards matured, and the first exploits followed.** MCP's [2026-07-28 spec](https://blog.modelcontextprotocol.io/posts/2026-07-28/) is final: a stateless core (capabilities sent per request), cacheable list results, hardened auth, with Roots, Sampling, and HTTP+SSE on a 12-month deprecation clock. Within six weeks an analysis showed its portable state handles and MCP Apps HTML open handle-hijack and stored-XSS paths, and Google's Agent Development Kit for Python shipped a CVSS 10.0 unauthenticated remote-code-execution bug (CVE-2026-79696, `adk web` 2.0.0 through 2.6.0, disclosed September 9). ACP lists 40 agents and 15+ editors, none of them Xcode. The SKILL.md ecosystem counts 46 clients, and the July "SkillJacking" disclosure counted 925 skills across ~134K agents sitting on hijackable dependencies (the researchers' numbers); CrowdStrike demoed a public Claude Code plugin that registers a local MCP server and exfiltrates credentials on every tool call, and Anthropic answered with skill and plugin scanning for Enterprise plans. Infostealer-harvested Claude sessions were also used to mint Claude Code OAuth tokens (Anthropic revoked them and issued partial refunds). Every third-party skill and MCP server is code running with your credentials, so review it like code.
{% endnote %}

Every agent in these tables improved since July, and every one of them now sits inside a corporate rivalry it wasn't part of in May: Cursor belongs to SpaceX and OpenAI is cutting it off, Nvidia bought the model registry, and Stripe bought the router.

---

## Deep dive: what each top provider does beyond the model

### OpenAI: a generation number, a breach, and an exodus

[chatgpt.com](https://chatgpt.com) | [platform.openai.com](https://platform.openai.com)

- **Astra is tiered by product, not just by plan**: Pro, Enterprise, and Business Premium got it in Work, Codex, and the API on September 4; Plus got it days later and only inside Work and Codex, not Chat, at 5 to 45 messages per five hours; Enterprise workspaces have it off by default. GPT-6 Pro, the high-compute variant, is 50 messages a week on $100 Pro and 200 on $200. New $200 sign-ups are paused as of September 10.
- **The Free tier got better** on August 6 and 10: GPT-5.6 Luna as default, unlimited text chats, a Think button, ads. OpenAI's August post states "1 billion people use ChatGPT weekly" as fact; its last standalone figure was 900M in February, so treat the round number as a vendor claim.
- **The Navier-Stokes claim** (September 8): OpenAI says 10,000 coordinating agents on an internal model produced a finite-time blow-up proof for the forced 3D Navier-Stokes equations in 88 hours, with Astra formalizing it in Lean in 17 more. OpenAI says it won't seek the Millennium Prize, NYU's Tristan Buckmaster is publicly disputing credit for the approach, and there is no peer review yet.
- **API housekeeping**: Fast mode (2x price, up to 2.5x speed) replaced Priority processing; an "Ultrafast" preview claims up to 14x for Sol; the Agents API entered public beta and GPT-Live-1 went GA at $0.05/min on September 10; models released after March 5 carry a 10% data-residency uplift. Astra is GA on Bedrock (September 8) and limited-access on Foundry. The $1-a-year federal OneGov deal runs through September 30 and switches to usage pricing at 50% off list on October 1.
- **Leadership**: CRO Denise Dresser (replaced by ex-Wiz COO Dali Rajic), Brad Lightcap, Chloé Bakalar, Johannes Heidecke, Joshua Achiam, Sandhini Agarwal, and data-center chief Chris Malone all left; Brockman called the exits "not that atypical". CFO Sarah Friar: public company "in 2027".

### Anthropic: two flagships, five incidents, one price rise cancelled

[claude.ai](https://claude.ai) | [platform.claude.com](https://platform.claude.com)

- **Opus 5 (July 24) is the model most people should care about**: $5/$25, 1M context, fast mode at $10/$50, default in Claude Code on Max and Team Premium, and on seat-based Enterprise since August 28. Fable 5.1 (September 1) adds the cache-read cut and a smaller safety tax.
- **Sonnet 5 stays $2/$10.** The scheduled September 1 rise to $3/$15 was cancelled August 10. With the ~30% tokenizer inflation still in place, that is a real cut relative to Sonnet 4.6 rather than the wash the July guide expected.
- **Claude Code**: auto mode became the default for new sessions on Pro, Max, and Team from August 14 (classifier tokens no longer billed; Anthropic's 1,053-tester study says auto mode caught 89% of dangerous commands against 13.6% for humans, its study). Dynamic Workflows are GA on paid plans; cross-session messaging, fork mode by default, and model-switch hooks landed in August. Fast mode exists for Opus 5 and 4.8 only, and not on Bedrock, Vertex, or Foundry.
- **Product**: memory unified across chat, Cowork, and the Chrome side panel on August 25 (on by default for Free, Pro, and Max, editable by topic; Claude Code is not included); Claude in Chrome GA on every paid plan (August 26) and Cowork got a built-in browser; computer use, browser use, the Files API, and Agent Skills went GA in the API; Managed Agents added `inference_geo`.
- **Watermarking**: every model launched from August 2 marks its text output (SynthID-style sampling, C2PA for files), worldwide, API included, with earlier models to follow "over the coming months", to meet the EU AI Act's transparency obligations. Detection is a private preview for regulators, media, and researchers. No other lab has matched it publicly.
- **Enterprise Frontier Safeguards** (announced September 1, rolling out "later this fall"): the mandatory 30-day retention stays, but the data lives in your own S3, Blob, or GCS bucket and misuse flags go to you; interim zero-data-retention on Fable for eligible customers. That was the July guide's biggest Fable objection.
- **People**: Tino Cuéllar (ex-Carnegie Endowment) is the first Chief Global Affairs Officer; pretraining researcher Jacob Coxon resigned publicly on September 8 over a "race to self-improving superintelligence", and Evan Hubinger agreed with him in public, per the WSJ.

### Google: three Flashes, no Pro, one Assistant

[gemini.google.com](https://gemini.google.com) | [aistudio.google.com](https://aistudio.google.com) | [antigravity.google](https://antigravity.google)

- **Flash cadence**: 3.6 (July 21), 3.7 (August 13), 3.8 (September 2), all $0.75/$3.75 through December 31 and $1.50/$7.50 after. 3.7 is the release Google's own charts show as the big step (DeepSWE 65.3% against 49.0% for 3.6). 3.6 and 3.7 sit on the deprecations page with no shutdown date, the same status as 3.5 Flash, which now costs more than all three successors.
- **3.5 Pro**: not shipped, no date, no model card, and DeepMind's model page dropped the Pro row. The July guide's "six-plus weeks late" is now four months. If you were holding Gemini API work for Pro, stop waiting.
- **Subscriptions**: AI Plus is $4.99 (the July guide's $8 was wrong; the cut landed June 8). AI Pro at $19.99 gets 3.8 Flash in the app, Spark (the 24/7 agent, previously Ultra-only), the Gemini Notebook "cloud computer" (NotebookLM's new name since July 16, with the agentic mode the July guide criticized as Ultra-only coming to "all Pro users on the web"), Chrome Auto Browse in the US, and $10/month of Cloud credit. Ultra is $99.99 and $199.99 with $40/month of credit. Students get a free year of Pro. Free users got 3.6 Flash; 3.8 is Pro and Ultra only.
- **Google Assistant** started disappearing from Android phones and watches on September 4 with no way back; Gemini is the assistant on "over 1 billion" monthly users' devices, per Pichai's August figure (a vendor number). Siri AI (above) ships September 14 on Gemini-derived models, Google's biggest distribution win of the year.
- **Antigravity** is now an enterprise product: Gemini Enterprise seats, VS Code extension GA, JetBrains, Zed, and Xcode extensions. The model picker has Claude Sonnet 4.6 and Opus 4.6, still no Claude 5 model and nothing from OpenAI beyond GPT-OSS, and the free tier still publishes no numeric quota. Jules got nothing.

### SpaceXAI: Cursor closed, OpenAI walked

[grok.com](https://grok.com) | [x.ai](https://x.ai)

- **Grok 4.6** is a competitive model at $2/$6 with the standing caveat that every headline score is xAI's. The price list lost Grok 4.1 Fast, 4 Fast, and Code Fast without a deprecation page; Grok 4.3 at $1.25/$2.50 is now the cheap tier.
- **Grok Bot** (August 11) is the most interesting product: always-on agents on a persistent cloud computer, messaged like colleagues, Heavy-only at first and included with SuperGrok and Cursor paid plans since August 26 but metered from a separate usage pool. Grok Build left beta and is on every plan.
- **Cursor**: OpenAI's November 12 cutoff removes about 5% of Cursor's traffic by its CEO's count and 100% of the models many teams standardized on. Cursor has Fable 5.1 and Opus 5, so the practical outcome is a Claude default.
- **The rest**: SpaceXAI reported $2.56B of Q2 AI revenue against a $1.26B AI operating loss and $15.8B of Q2 AI capex; a gibberish episode for Grok Lite users on August 20 that xAI called "a rare temporary generation glitch" (TechCrunch put it next to roughly 50 researcher departures); Grokipedia hasn't updated since April; Grok 4.7 is "10 days" out as of September 2.

### Microsoft: more MAI models and a router

[copilot.microsoft.com](https://copilot.microsoft.com) | [github.com/features/copilot](https://github.com/features/copilot)

- **MAI**: MAI-Thinking-1 (public preview on Foundry, about 1T total and 35B active, reported at $2/$8), MAI-Code-1.1-Flash, MAI-Cyber-1-Flash, MAI-Image-2.5-Pro and 2.6, MAI-Voice-2-Flash, MAI-Transcribe-2 ($0.10/hour promo). Microsoft booked a $3.2B gain on its Anthropic stake in Q4. The OpenAI relationship is openly competitive on Microsoft's earnings calls and openly embraced in its products: Astra hit Foundry (limited access), Copilot Cowork, and Copilot Studio within a day of launch.
- **GitHub Copilot** added Astra and Fable 5.1 at "provider list pricing", plus Kimi K3, Grok 4.6, and Gemini 3.8 Flash (September 3), deprecated ten models in two waves, and shipped HydraFusion as an opt-in research preview in the Copilot CLI: a router whose own headline is "up to 67% cheaper than Opus 5 alone", with quality above Opus on one of three benchmarks, level on one, and below on one. Unified Copilot relaunch September 28, upfront billing October 1, Business and Enterprise sign-ups reopened.
- **Consumer Copilot** lost five features and its standalone Pro plan inside a month. Microsoft 365 Premium ($19.99) is the only consumer upgrade; M365 Copilot is $30/seat with "30 million paid seats" (Microsoft's number).
- **Foundry** has Opus 5, Sonnet 5, Opus 4.8, and Haiku 4.5 GA and Fable 5.1 in preview (Anthropic-hosted), billed in Claude Consumption Units.

### Perplexity: Astra and Fable in the same week

[perplexity.ai](https://www.perplexity.ai) | [docs.perplexity.ai](https://docs.perplexity.ai)

- Astra landed in Perplexity Computer for Pro and Max within days of launch, and Perplexity's own eval puts it 13.5% ahead of Fable 5.1 per task at 6% lower cost (its eval).
- **Portable Computer** (August 25, with Nvidia): a fully local agent on Qwen3.8 27B and a PPLX 27B, an RTX card with 24 GB or more, Linux now and Windows in September, zero token billing.
- **Legal**: the Ninth Circuit vacated Amazon's injunction against Comet on August 4 (the user, not Perplexity, "accesses" Amazon); the case continues. No public response to June's LayerX prompt-injection findings has turned up; the July guide's warning stands.
- **API**: Sonar chat completions are being folded into the Agent API (Sonar supported through September 27), which added Grok 4.6, GLM-5.3, and Gemini 3.8 Flash. TechCrunch reported Indian monthly users fell 37% from a 22M peak after a carrier promotion ended.

### The open-weight bloc: two trillion parameters, with strings

[api-docs.deepseek.com](https://api-docs.deepseek.com) | [huggingface.co/Qwen](https://huggingface.co/Qwen) | [huggingface.co/moonshotai](https://huggingface.co/moonshotai) | [docs.z.ai](https://docs.z.ai)

- **DeepSeek** shipped V4-Flash GA (July 31), V4-Pro GA (August 13), Harness (an agent framework), Vision-Exp (August 21), the peak-price hike (August 16), and V4.1-Flash (September 10) with a price cut and a reroute of the Pro endpoint: six model events and two pricing regimes in six weeks. It's raising ~50B yuan at ~$74B pre-money ahead of a STAR Market listing expected in 2027. All V4 weights are MIT. The app is free with no paid tier and now exposes V4-Pro as "Expert Mode"; the July guide's "unlimited" was never documented, and heavy users report throttling.
- **Kimi K3 and Qwen3.8-Max** are the two largest open models ever released and the first at this scale with revenue-gated licenses: fine for you, not fine for a competing model-as-a-service. Kimi K3 is also priced like a Western frontier model ($3/$15), and Moonshot is reported (Bloomberg, SCMP) to be preparing a Hong Kong IPO. Qwen3.8-27B (Apache 2.0, image and video input) is the small model to actually download.
- **GLM-5.3-Flash** (MIT, 320B-A18B, $0.15/$0.50) is the best license-to-capability ratio of the cycle; GLM-5.3 itself arrived on Hugging Face two weeks after its API under a custom license. Z.ai's coding plan starts at $18/mo and includes both.
- **Meta** is back in open weights with Muse Glimmer 30B (Apache 2.0), a distillation of Muse Spark; Spark stays closed and a reported promise of 1.2 weights has no repository behind it. Llama has no news.
- Open weights carried 62% of Vercel's AI Gateway tokens in August, DeepSeek V4-Flash first. In the same weeks Hugging Face ran its breach response on GLM-5.2 after the US frontier models refused, Nvidia bought Hugging Face, and Anthropic accused the three largest Chinese labs of distilling Claude.

---

## What I'd actually pick

**Free chat**: ChatGPT Free is now the best free chat product: GPT-5.6 Luna, unlimited text chats, ads. DeepSeek (V4-Pro Expert Mode, no paid tier exists) and Qwen stay the picks if ads or US data handling bother you. Gemini's free tier sits on 3.6 Flash, two releases behind its paying users, but Gemini's API free tier is still the one to prototype against: no card, and it includes 3.8 Flash.

**One $20 sub**: Claude Pro, with less hesitation than in July: Opus 5 is the strongest included model on any $20 plan, Sonnet 5 stayed cheap, and the plan bundles Claude Code, Cowork, the Chrome agent, and shared memory. Know that Fable 5.1 costs extra on Pro and that Claude Code's weekly limit shrinks about 17% on September 14. ChatGPT Plus is the pick if Work agents or voice are the point; Astra is in Work and Codex but not Chat, so check that before upgrading for it. Perplexity Pro remains the model-tourist's plan. Gemini AI Pro is finally worth $20 if you live in Workspace. Skip SuperGrok unless Grok Bot is specifically what you want, and give Meta's Muse Power a month of history before paying for it.

**Coding**: Claude Code with Opus 5 on Max is the strongest default I know of; Sonnet 5 on Pro is the value default. Codex with Astra is the strongest raw model inside an agent right now, if you can get the plan (Pro sign-ups paused) and if a reasoning trace you can't read is acceptable to your review process. Cursor is a SpaceX product with a Claude default and no OpenAI models after November 12; if your team standardized on GPT models inside Cursor, you have nine weeks. Copilot's HydraFusion router trades quality for cost by its own numbers; it's opt-in and CLI-only today, so leave it off for anything that matters. Antigravity is capable and enterprise-ready and still can't run a Claude 5 model; Jules is abandoned in all but name. Kiro is the sleeper for AWS shops.

**Production API**: Sonnet 5 at $2/$10 is the volume default. Opus 5 at $5/$25 replaces Opus 4.8 everywhere. Terra ($2/$12) and Luna ($0.20/$1.20) are OpenAI's value plays after the cuts; Sol's $4/$20 is promotional through November 21. Gemini 3.8 Flash at $0.75/$3.75 is the cheapest frontier-adjacent model until December 31 and twice the price after, so write the January number into the budget now. Astra and Fable 5.1 are for workloads that justify $10/$50: Fable's cache-read cut makes it the cheaper of the two on long agent prefixes, Astra's "Critical" rating makes it the one your security team will ask about. DeepSeek is the cheapest serious model again as of September 10, if your traffic can live outside Beijing office hours and your compliance team can live with the origin.

**Open weights**: GLM-5.3-Flash (MIT) and DeepSeek V4.1-Flash (MIT) for anything you'd serve commercially; Qwen3.8-27B (Apache 2.0) for local and edge; Kimi K3 and Qwen3.8-Max if you can meet the license and the hardware; Muse Glimmer 30B is Meta's re-entry and worth a look.

The mental shift since July: I evaluated providers on stability then, and I'd add containment now. Evaluation agents from two labs reached real infrastructure this summer, and both labs paused training runs afterwards. Every frontier model now has a stronger sibling behind a vetting program, and the one you can buy comes with a reasoning trace you can't read. What I'd ask a vendor now is what happens when its model gets out, and so far two of them have answered only because they had to.

Homework before the November guide: move any GPT-5.6 Sol budget to the $4/$20 math with a November 21 fallback, price Gemini Flash at $1.50/$7.50 for January, and if you're on Cursor with OpenAI models, pick the replacement before November 12.
