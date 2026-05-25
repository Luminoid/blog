---
title: "Agent: an LLM, in a loop, with tools"
date: 2026-05-27 12:00:00
categories:
- AI
tags:
- agent
- tool-use
- function-calling
- MCP
- ReAct
- multi-agent
- computer-use
- browser-use
- memory
- evals
- agent-evals
- prompt-injection
- sandboxing
- Claude-Code
- Cursor
---

The third post in the series after {% post_link What-Is-an-LLM %} and {% post_link Context-Is-the-Whole-Game %}. Those covered what the model is and what feeding it well looks like. This one is about what happens when you stop typing the next prompt yourself and hand the keyboard over: the model picks a tool, the tool runs, the result comes back, the model picks the next tool. That loop, with a few hundred lines of code around it, is what every product in 2026 is calling an "agent." The post is written for people who **use** agent products (Claude Code, Cursor, GitHub Copilot agent mode, ChatGPT's agent mode) and want to know why their tools behave the way they do. It also has the underlying details (wire formats, MCP server authoring, eval design) called out separately for anyone building one, but the technical detail is opt-in, not the default reading path.

<!-- more -->

## The one big idea

An **agent** is an LLM, running in a loop, that can call tools. That's the whole definition. Strip everything else (planning, memory, multi-agent orchestration, browser control) and the load-bearing thing is the loop. The pseudocode below is what happens inside Claude Code, Cursor, ChatGPT's agent mode, and every other agent product: you didn't write the loop, but the product around you is running it on every turn.

```python
def agent(task, tools):
    messages = [{"role": "user", "content": task}]
    while True:
        response = llm.generate(messages, tools=tools)
        messages.append(response)
        if response.is_final():
            return response.text
        for call in response.tool_calls:
            result = run_tool(call.name, call.arguments)
            messages.append({"role": "tool", "content": result})
```

Three things follow from those ten lines.

**The model controls the loop.** It decides, on each turn, whether the next step is a tool call or a final answer. The harness doesn't have a state machine that says "first search, then summarize." If the model decides to skip search and answer from memory, the harness has no idea anything was skipped. That's the source of most of the new failure modes (premature stopping, runaway tool loops) and most of the new capabilities (recovering from a failed tool call by trying a different one).

**Each tool call is a real side effect.** Search hits an API. `write_file` mutates the disk. `send_email` goes out. Unlike a chatbot, where the worst that happens is a wrong answer, an agent that picks the wrong tool can ship the email, delete the file, or charge the card. Safety stops being a soft thing about hallucinated facts and becomes a hard thing about what actions the loop is allowed to take.

**The context grows every iteration.** Every tool result gets appended. A non-trivial coding task can run 30 to 50 tool calls before finishing, and each `read_file` returns a few thousand tokens of source. Five turns in, the context is mostly tool outputs. This is where the {% post_link Context-Is-the-Whole-Game %} machinery (caching, compaction, scratchpad memory) stops being a nice-to-have and becomes the difference between an agent that finishes a 40-step task and one that times out at step 15 because the model is now reading mostly stale tool results.

The rest of the post is corollaries.

## The parts of an agent

Before going further it helps to name the boxes. Most of the confusion in agent writing comes from mixing the model (the thing you call over the network) with the harness (the code that runs the loop) with the tools (the things the model decides to invoke). They're all part of "the agent" colloquially, but they live in different places and fail in different ways.

```text
┌──────────────────────────────────────────────────────────────────┐
│                         AGENT HARNESS                            │
│   (Claude Code, Cursor, Agents SDK, LangChain, custom scripts)   │
│                                                                  │
│  ┌────────────────────────────────┐                              │
│  │     Conversation state         │ ◄── grows every turn         │
│  │  - system prompt               │                              │
│  │  - tool definitions (JSON)     │                              │
│  │  - user message                │                              │
│  │  - assistant responses         │                              │
│  │  - tool calls + tool results   │                              │
│  └────────────────────────────────┘                              │
│                │                                                 │
│                ▼  one HTTP request per loop iteration            │
│  ┌────────────────────────────────┐    ┌──────────────────────┐  │
│  │         LLM API call           │───►│       Model          │  │
│  │   (Anthropic / OpenAI /        │◄───│   (Opus, GPT-5,      │  │
│  │      Google endpoint)          │    │    Gemini, ...)      │  │
│  └────────────────────────────────┘    └──────────────────────┘  │
│                │                                                 │
│                ▼  response contains tool_use blocks              │
│  ┌────────────────────────────────┐                              │
│  │       Tool dispatcher          │                              │
│  └────────────────────────────────┘                              │
│       │             │             │                              │
│       ▼             ▼             ▼                              │
│  ┌─────────┐  ┌───────────┐  ┌────────────┐                      │
│  │  Local  │  │    MCP    │  │  Sandbox   │                      │
│  │  tools  │  │  servers  │  │  (Docker / │                      │
│  │ (read,  │  │ (GitHub,  │  │   VM, for  │                      │
│  │  grep,  │  │  Slack,   │  │  bash /    │                      │
│  │  write) │  │  Linear)  │  │  exec)     │                      │
│  └─────────┘  └───────────┘  └────────────┘                      │
│       │             │             │                              │
│       └─────────────┴─────────────┘                              │
│                     │                                            │
│                     ▼  tool_result blocks                        │
│        (appended back to conversation state, loop continues)     │
│                                                                  │
│  ┌────────────────────────────────┐                              │
│  │   Scratchpad / memory files    │ ◄── persists across turns    │
│  │  - TODO.md, PROGRESS.md        │     and across sessions      │
│  │  - MEMORY.md + per-fact files  │                              │
│  └────────────────────────────────┘                              │
└──────────────────────────────────────────────────────────────────┘
```

A walking tour, since this is the map the rest of the post hangs off:

1. **The harness** is whatever code runs the while-loop from the previous section. For almost everyone reading this, the harness is the product you're using: Claude Code, Cursor's agent mode, GitHub Copilot agent mode, ChatGPT's agent mode. You don't touch its code; you just type. If you're writing your own harness, you're using a framework (Anthropic / OpenAI Agents SDK, LangChain, PydanticAI) or writing from scratch, and almost everything interesting about an "agent product" lives here, not in the model. That's why so many companies ship a harness around the same handful of frontier models and compete on that layer.
2. **The conversation state** is the list of messages the harness sends to the model on every call. It starts as `[system_prompt, user_message]` and grows by one entry every time the model speaks or a tool returns. Context engineering (covered in {% post_link Context-Is-the-Whole-Game %}) is the discipline of keeping this list useful as it grows.
3. **The model** is whatever LLM you're calling. The model never holds state between calls; the harness re-sends the entire conversation state every iteration. Tool definitions are part of the system prompt, so the model "knows" what tools exist only because they're in front of it on every call.
4. **The tool dispatcher** is the harness component that reads the model's `tool_use` block, finds the right tool function (locally registered, or proxied to an MCP server), executes it, and packages the result as a `tool_result` block to append back to the conversation state.
5. **Local tools** are functions defined in the harness itself: `read_file`, `grep`, `bash`. Section 1 covers their wire format.
6. **MCP servers** are external processes (local subprocess via stdio, or remote service via HTTP) that expose additional tools through a standard protocol. Section 2 covers them.
7. **The sandbox** is where destructive tools run: usually a Docker container or a VM, so the agent can run `bash` without touching your real filesystem. Section 9 covers why that boundary matters.
8. **The scratchpad / memory files** are state the harness writes to disk and re-injects into conversation state on demand. Unlike conversation state (which is one growing list per task), scratchpad files persist across tasks and sessions. Sections 3 and 6 use them heavily.

Every section below operates on one of these boxes. Tool use is the wire between dispatcher and model. MCP is a way to add servers to the dispatcher. Planning is what the model does inside one call. Memory is what the scratchpad holds. Safety is mostly about where the sandbox boundary sits. Eval is "did the trajectory through this diagram make sense?" The sections explain what the harness does on your behalf when you use Claude Code or Cursor; the deeper technical bits (wire formats, MCP server code, eval methodology) are flagged inline so you can skip them if you're not writing your own harness.

## Agent vs chatbot vs workflow

It's worth pinning the word "agent" against its neighbours, because the term is now slapped on every LLM product that does more than one thing.

| | **Chatbot** | **Workflow** | **Agent** |
|---|---|---|---|
| Who picks the next step | The user (with each new turn) | The author (DAG / state machine, fixed at design time) | The model (at each iteration of the loop) |
| Number of LLM calls per "task" | 1 per user turn | N, fixed, branching baked in | N, unbounded until the model decides it's done |
| Tools / side effects | None, or one (retrieval) | Yes, but only at predefined steps | Yes, model chooses which to call when |
| Failure mode | Wrong answer | Wrong branch taken in the DAG | Wrong tool call, infinite loop, premature stop |
| Latency | One forward pass | Predictable, sum of fixed steps | Unbounded, model decides when to stop |
| Where it lives in 2026 | ChatGPT free tier, basic chat UIs | Most "AI features" inside SaaS products (extract entities, classify ticket, draft reply, all in a fixed order) | Claude Code, Cursor agent mode, Copilot agent mode, ChatGPT's "agent mode," Devin, computer-use products |

The workflow / agent boundary is the interesting one. Anthropic's [Building effective agents](https://www.anthropic.com/research/building-effective-agents) makes the same distinction with a load-bearing recommendation: **use a workflow when the task is predictable, use an agent when it isn't.** A workflow that classifies a support ticket into one of five buckets and routes it is more reliable and cheaper than an agent for the same task. An agent that debugs an arbitrary failing test is more capable than any workflow you could write for the same task. Pick the level of dynamism that matches the task's variance.

The trap, in 2025 and into 2026, was to call everything an agent because the word was hot. A "research agent" that runs three prescribed steps (search, fetch top 5, summarize) is a workflow. That's fine. Call it a workflow. The pattern of "use a DAG when you can, an agent when you must" is the one worth internalising.

## 1. Tool use, the wire format

The model can't "call" a function directly. What actually happens is that the model emits a structured token sequence that the harness recognizes as a tool-call request, then the harness runs the tool and feeds the result back.

If you're using Claude Code or Cursor, the user-facing version of this is the "I'll use the Read tool" or "I'll run grep" line that shows up before each action. The structured request below is what the model actually emitted; the harness translated it into the human-readable label you see. The takeaway for users: the model can only invoke tools the harness registered with it at startup, and the *quality* of how those tools are described (next subsection) determines which one the model picks. When Claude Code feels surprisingly good or surprisingly dumb on a task, the description quality of the tools available for that task is usually the reason.

### What "a tool" actually is, concretely

To make this less abstract: when Claude Code starts a session in mid-2026, the harness registers roughly two dozen tools with the model. They split into two tiers based on how the harness manages prompt-token cost.

**Always loaded** (full JSON schema lives in the system prompt, callable immediately):

- `Agent`: spawn a specialized sub-agent (Explore, Plan, general-purpose, ios-reviewer, claude-code-guide, etc.) with its own context window
- `AskUserQuestion`: present the user a multiple-choice question and wait for the answer
- `Bash`: run a shell command (this is what executes `gh`, `git`, `xcodebuild`, `npm`, anything on `$PATH`)
- `Edit`: exact string replacement inside an existing file
- `Read`: read a file, image, PDF, or notebook from disk
- `Write`: create or overwrite a file
- `ScheduleWakeup`: schedule the next iteration when running in `/loop` dynamic mode
- `ShareOnboardingGuide`: upload `ONBOARDING.md` and return a share link
- `Skill`: invoke an installed skill (a packaged prompt + tool bundle) by name
- `ToolSearch`: load full schemas for the deferred tools below so they become callable

**Deferred** (names and one-line descriptions advertised, full schema fetched on demand via `ToolSearch`):

- Task and todo: `TodoWrite`, `TaskOutput`, `TaskStop`
- Planning and worktree: `EnterPlanMode`, `ExitPlanMode`, `EnterWorktree`, `ExitWorktree`
- Scheduling: `CronCreate`, `CronList`, `CronDelete`, `Monitor`
- Notifications: `PushNotification`, `RemoteTrigger`
- Notebook: `NotebookEdit`
- Web: `WebFetch`, `WebSearch`
- MCP servers (OAuth-gated): Gmail, Google Calendar, Google Drive, each as an `authenticate` / `complete_authentication` pair

The split is the same problem the "Description bloat" subsection of Section 2 will name for MCP, solved one layer up: every tool whose schema lives permanently in the prompt costs tokens on every turn, so the harness keeps the hot path (file IO, shell, sub-agents) inline and pushes everything else behind a meta-tool that the model only invokes when it actually needs the schema. The cost is one extra round trip the first time a deferred tool is needed in a session; the benefit is that the resident system prompt stays small even as the catalog grows.

Notice what's not in the list: there is no `git_commit`, no `npm_install`, no `xcodebuild`. Those all run as `Bash` commands. One general-purpose `Bash` tool covers most of what you'd otherwise need fifty specialized tools for, at the cost of letting the model write the command string instead of filling in typed arguments. This is the typical 2026 harness shape: a small set of high-leverage primitives plus shell, not a giant menu of typed verbs.

### Schemas: what the model sees

If you're writing your own harness, this is the API you'll use. If you're just a user, skim: the takeaway lower down (the `description` field is part of the prompt) is the part that explains behaviour you actually see.

You declare each tool with a JSON Schema. Anthropic, OpenAI, Google, and the open-source providers (vLLM, Ollama, llama.cpp) all converged on roughly the same shape:

```json
{
  "name": "read_file",
  "description": "Read a file from the local filesystem. Returns its contents as a string.",
  "input_schema": {
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Absolute path to the file."
      }
    },
    "required": ["path"]
  }
}
```

The schema goes into the system prompt, with a stylized format the model was trained to recognize. At runtime, when the model decides to call a tool, it produces something the API exposes as a structured tool-use block:

```json
{
  "type": "tool_use",
  "id": "toolu_01A3...",
  "name": "read_file",
  "input": { "path": "/Users/me/proj/main.py" }
}
```

Three things matter about the wire format. The first one is the only one that affects you as a user; the other two are details for harness authors.

**The `description` field on the tool and on every property is part of the prompt.** This is the single highest-leverage thing in agent design and it gets overlooked constantly. A good description tells the model when to use the tool, what its preconditions are, what it returns, and what failure modes look like. A bad description says "Reads a file." The classic failure mode this produces: an agent that keeps calling `list_files` and then `read_file` on the first match because the `grep` tool description was three words long and the model doesn't know `grep` is the better fit. Whatever you don't write in the description, the model has to guess at, and it guesses wrong on exactly the dispatch decisions that determine whether the agent feels smart.

**The `required` array is enforced by the harness, not the model.** If you mark `path` as required, most harnesses will reject a tool call without it before re-prompting the model. But if you leave it optional and the model omits it, the tool runs with `path=None` and crashes in the function body. Use `required` aggressively. The model is not a strict typer.

**There's no return-type schema in the standard.** The tool returns a string (or a list of content blocks, on the multimodal providers). What's inside that string is up to you. Most production tools return JSON-stringified output so the model can parse fields; some return prose. The model is good at both. The tradeoff is that JSON gives the model structured fields to reason over, prose is more compact and caches better.

### Parallel tool calls

You'll see this in Claude Code as "running 5 tools in parallel" or in Cursor as a row of simultaneous file reads. It's the single most visible speedup since 2024, and worth understanding because it's also the source of one specific annoyance (GPT-5-based agents that feel slow because they don't batch as eagerly).

The 2024 default was: model emits one tool call, harness runs it, result goes back, model emits the next call. Round-trip per call. For an agent that needs to read five files, that was five sequential LLM calls.

Modern frontier models (Opus 4.7, Sonnet 4.6, GPT-5.5, Gemini 3.1 Pro) emit **multiple tool calls in a single response**, and the harness runs them in parallel. The five `read_file` calls become one model turn:

```python
# response.tool_calls is now a list, not a singleton
results = await asyncio.gather(*[
    run_tool(call.name, call.arguments)
    for call in response.tool_calls
])
for call, result in zip(response.tool_calls, results):
    messages.append({
        "role": "tool",
        "tool_use_id": call.id,
        "content": result,
    })
```

This is roughly a 3-5x speedup on read-heavy tasks when the model uses it (the entire "explore the codebase" phase of a coding agent is parallelizable). It's also where most of the new harness bugs live: tool calls that depend on each other (`mkdir` then `write_file` inside it) need to be detected as serial, and the model needs the result format to make clear which `tool_use_id` each `tool_result` belongs to.

How aggressively the model actually batches is model-dependent. Claude 4.x models lean into parallel calls; Gemini 3 Pro does too. GPT-5 shipped with a known regression where parallel calling fires far less often than GPT-4.1 did, even with `parallel_tool_calls=True` on by default, and OpenAI has flagged it as a behaviour gap rather than a config issue. Anthropic's [tool use docs](https://docs.claude.com/en/docs/build-with-claude/tool-use) cover the wire-level details; Google's Gemini API exposes the same shape under `function_calls: []`.

### Tool results: what the model sees back

The tool result block looks like this:

```json
{
  "type": "tool_result",
  "tool_use_id": "toolu_01A3...",
  "content": "def hello():\n    return 'world'\n"
}
```

Two non-obvious bits.

**Results can be marked as errors.** `"is_error": true` flags a failed tool call so the model knows to retry or escalate, rather than treating the error message as the requested data. Without this, "FileNotFoundError: /tmp/foo" gets ingested as if it were the file's contents on a flaky day.

**Results can include images.** All four major providers now support image content blocks inside tool results, which is the entire mechanism behind computer-use and browser-use agents: the screenshot tool returns an image block, the model "sees" the screen, picks the next click.

## 2. MCP: the integration layer that won

This is the one section in this post where the user-facing reality and the harness-author reality overlap. If you've installed a GitHub or Linear or filesystem MCP server into Claude Desktop, Cursor, or Claude Code, you've used MCP directly. This section explains what was actually installed and why so many products converged on the same protocol.

Tool use as described in section 1 is per-provider: each agent runtime writes a `read_file` schema for Anthropic, a separate one for OpenAI, a separate one for Gemini, and wires each to its code. That doesn't scale, and it's what stalled the agent ecosystem through most of 2024.

**Model Context Protocol** (MCP), introduced by Anthropic in November 2024, is the standard that fixed it. By mid-2026 every serious agent runtime and every major IDE speaks it: Claude Desktop and Claude Code, Cursor (early 2025), VSCode (via Continue), Zed, OpenAI's Agents SDK and ChatGPT Connectors (March 2025), Google's Gemini CLI (with native FastMCP integration in September 2025), JetBrains AI (in IntelliJ-family 2025.2, mid-2025), Microsoft Copilot Studio. In December 2025, Anthropic donated MCP to the Agentic AI Foundation under the Linux Foundation, with Block, OpenAI, Google, Microsoft, AWS, and Cloudflare backing the move. The full adoption history is in the [MCP Wikipedia entry](https://en.wikipedia.org/wiki/Model_Context_Protocol). The official spec lives at [modelcontextprotocol.io](https://modelcontextprotocol.io).

The pitch in one line: MCP is to LLM tools what LSP is to editor tooling. Write your filesystem server once, and Claude, Cursor, and ChatGPT can all use it.

### What MCP actually is

It's a JSON-RPC 2.0 protocol over either stdio (local subprocess) or HTTP+SSE (remote service). An MCP **server** exposes three kinds of capability:

- **Tools.** Functions the model can call. Same JSON-Schema shape as native tool use.
- **Resources.** Read-only content the host can pull in (a file, a database row, a webpage). Addressed by URI. The model doesn't call these; the host (the IDE or chat app) decides when to surface them.
- **Prompts.** Reusable prompt templates with parameters, exposed to the user as slash commands or similar.

An MCP **client** (your agent runtime) discovers what a server offers, registers the tools with the model, and routes calls.

A trivial Python server using the official SDK (skip the code if you're not writing one; the point of the example is that "MCP server" is a small thing, not a big framework):

```python
# echo_server.py
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("echo")

@mcp.tool()
def echo(message: str) -> str:
    """Echo back the provided message."""
    return message

if __name__ == "__main__":
    mcp.run()
```

Configure Claude Desktop or Claude Code to invoke `python echo_server.py`, and the `echo` tool is now available to the model. No SDK lock-in. The same server works in Cursor.

### Why it caught on

Three forces pushed adoption past the tipping point.

**The ecosystem effect.** Once Cursor shipped MCP support in February 2025 and OpenAI followed in March, server authors had two reasons to publish (their server works for more users) and clients had two reasons to support it (more servers exist). A canonical server registry at [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) hit 1,000+ entries by late 2025. The "Awesome MCP Servers" lists track it.

**OAuth 2.1 in the spec.** The June 2025 revision standardized authentication, which is what made enterprise adoption (Block, Apollo, ServiceNow, Atlassian) tractable. Before that, every remote MCP server invented its own auth. After, the same client can connect to GitHub, Linear, and an internal Snowflake instance with one auth model.

**It's just JSON-RPC.** No bespoke binary protocol, no SDK required (though SDKs exist for Python, TypeScript, Go, Rust, Java/Kotlin, C#, Swift, PHP, Ruby). You can write a server in 50 lines in any language and it works.

### Where MCP runs into limits

It's not all upside. Three rough edges worth knowing.

**Description bloat.** Every MCP server you install adds its tool descriptions to the system prompt of every model call, whether you used them or not. Plug in ten servers each exposing ten tools, and you've added several thousand tokens of permanent system-prompt overhead. The fix is dynamic loading (only register servers the current task needs) but most clients don't do it yet.

**Tool-name collisions.** Two servers both exposing a `search` tool will collide. MCP namespacing exists but isn't uniformly enforced by clients.

**Trust boundary.** Installing an MCP server is installing code that can read whatever resources you grant it. The npm-style supply chain attack surface is now an MCP-style supply chain attack surface. A malicious or compromised server can exfiltrate any context the host hands it. The community is starting to ship registries with signing, but in 2026 the trust model is still "check the source before you install."

For an authoritative reference, the [MCP spec](https://modelcontextprotocol.io/specification) is short and readable; Anthropic's [introduction post](https://www.anthropic.com/news/model-context-protocol) covers the motivation.

## 3. Planning

What you see as Claude Code's `Plan mode`, Cursor's agent thinking box, or Devin's plan tab is the harness asking the model to plan before it acts. Two patterns sit underneath those UIs (ReAct and plan-then-execute), and knowing which one your tool is doing helps you understand why it's slow or fast on a given task.

The bare loop says "the model picks the next tool." For trivial tasks that's enough. For tasks that span 20+ tool calls, the loop benefits from making the planning step explicit instead of implicit.

### ReAct: reason, then act, in alternation

The classic pattern, from the 2022 [ReAct paper](https://arxiv.org/abs/2210.03629). Each turn the model produces a `Thought` then an `Action`. The thought is plain language reasoning; the action is the tool call.

```
Thought: I need to find files that import the old API.
Action: grep("from old_api import")
Observation: [3 files matched]

Thought: I'll check the first match to see what's used.
Action: read_file("src/main.py")
Observation: ...
```

ReAct works because the model can correct itself between thought and action, and because the thought trace gives later turns context for *why* a tool was called. The downside is verbosity (the thoughts eat context) and that on simple tasks the thoughts add latency without adding accuracy. Modern frontier models often emit a similar trace by default when given freedom (Opus 4.7's extended thinking, Gemini 3.1 Pro's "thinking traces," GPT-5.5's reasoning mode) so explicit ReAct prompting is less load-bearing than it was in 2023.

### Plan-then-execute

The other pole: ask the model to write a full plan up front, then execute it. The plan is a list of steps; the agent works through them in order.

This is what Claude Code's plan mode does. Cursor's agent mode has a similar pattern. Devin and Manus are aggressive about it: the plan is a visible artifact, the user can edit it, the agent re-plans when it gets stuck.

The tradeoff against ReAct: plan-then-execute is more reliable on long tasks (the model has the whole shape in front of it instead of one step at a time) but worse at recovery (a plan written before any tool calls is a plan based on guesses about what the codebase looks like). The 2026 standard is hybrid: write a plan, execute it, re-plan when an observation contradicts a plan step.

### When planning actually helps

Anthropic's writeup on [building effective agents](https://www.anthropic.com/research/building-effective-agents) draws the boundary cleanly. Planning helps when:

- The task has a non-obvious structure (refactor across 8 files, where step 3 depends on what step 1 finds)
- The cost of a wrong tool call is high (modifying a database schema)
- The task is long enough that the model will lose track of the goal without an external anchor

Planning hurts when:

- The task is one-shot or near-one-shot (planning adds latency for no accuracy gain)
- The state is too uncertain to plan against (planning becomes a pile of conditionals)
- The plan steps end up matching tool calls 1:1 (you've reinvented ReAct with extra ceremony)

A good rule of thumb: if the plan would fit in five steps and each step maps to one tool call, skip the plan.

## 4. Multi-agent: when more agents actually help

In the products you use, you'll see this as Claude Code's Task tool spawning sub-agents, ChatGPT's Deep Research running a parallel investigation, Manus or Devin fanning out across multiple research threads. The user-facing question is: when is "this task is using multiple agents" a feature versus when is it the harness burning your token budget for no benefit? The answer below is "depends on the shape of the task," but the shape is knowable in advance.

The 2024 hype cycle said: more agents, talking to each other, are smarter than one. The 2025-26 reality is messier. The honest answer is: sometimes, on specific shapes of task, with significant orchestration cost.

The pattern that does work is **orchestrator + sub-agent**. One coordinating agent decomposes the task and delegates each subtask to a fresh sub-agent with its own context window. The sub-agent returns a summary; the orchestrator integrates summaries into the final answer.

Anthropic's [multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) describes the production version. The lead agent gets the user's question, plans subqueries, spawns sub-agents (each with its own clean context and its own tool budget), and synthesizes their findings. The reported numbers: a multi-agent system using Opus as orchestrator with Sonnet sub-agents outperformed single-agent Opus by 90.2% on internal research evals. The cost: about 15x the tokens of a chat conversation, because each sub-agent reads the system prompt and tool definitions from scratch.

That cost is the whole story.

Multi-agent helps when:

- The task **parallelizes**: research across 20 sources, audit 50 files, summarize 100 documents. Each sub-agent handles one independent chunk
- Each subtask has a **clean handoff**: the sub-agent's output is a short summary, not a long trace, so the orchestrator's context stays clean
- The value of the final answer is **high enough** to justify 15x tokens (deep research, legal review, complex coding tasks)

Multi-agent hurts when:

- The task is **sequential** (each step depends on the last, no parallelism, you've just paid 15x for nothing)
- The sub-agents need to **share state** beyond a final summary (now you're rebuilding distributed-systems consistency on top of LLM calls, which goes about as well as you'd expect)
- The task is **small** enough that one agent in a tight loop finishes faster than the orchestrator can decompose it

Cognition's [Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents) is the influential dissent from the same period, and it makes a sharp point: most multi-agent systems fail because of *context fragmentation*. Sub-agents make decisions without the full picture, and their outputs don't compose. Their recommendation is to push every long task through a single agent with aggressive context engineering instead.

Both are right at different scales. Multi-agent works for embarrassingly-parallel decomposition (research, audit, breadth-first exploration). Single-agent works for tight, sequential, cumulative work (writing a feature in a single codebase). The mistake is reaching for multi-agent because the task is "big."

## 5. Computer use and browser use

If you've tried ChatGPT's agent mode booking a flight, Anthropic's Claude with computer use filling a form, or Google's Project Mariner running shopping in a tab, you've used this. It's the same loop as the other agents in this post, just with the screen as a "tool result" the model has to read.

The natural extension of "the model picks a tool" is "the model controls the mouse." If the screenshot is an image block and `move_mouse` and `click` are tools, the agent can drive any GUI the way a human does.

Anthropic shipped this first as [computer use](https://docs.claude.com/en/docs/build-with-claude/computer-use), in October 2024, as a beta tool on Claude. The full set was small: `screenshot`, `cursor_position`, `left_click`, `right_click`, `type`, `key`, `mouse_move`. A virtual machine runs the OS; the model sees a screenshot, picks coordinates, the harness drives xdotool or its equivalent, takes a new screenshot, loops. OpenAI's [Computer-Using Agent](https://openai.com/index/computer-using-agent/) (January 2025), Google's [Project Mariner](https://deepmind.google/technologies/project-mariner/) and the browser-use community library all sit on the same primitive.

Browser-only variants (Browserbase, Playwright-based agents, OpenAI's Operator) are a constrained version: the harness gives the model accessibility-tree snapshots or annotated screenshots of a single browser tab, plus tools like `click(selector)`, `type(text)`, `navigate(url)`. The accessibility tree is more reliable than pixels (the model gets element IDs and roles instead of guessing what's under the cursor), but it doesn't generalize to native apps.

A few things that fall out of how this works.

**It's slow.** Every action is a screenshot-and-model-call round trip. A 50-step task that a human could do in two minutes takes the agent ten. The bottleneck is the model, not the OS.

**Pixel coordinates are unreliable.** Frontier models can read GUIs well enough to identify "the blue submit button," but precise coordinates drift, especially on high-DPI displays. The benchmarks (OSWorld, WebArena) showed dramatic accuracy improvements from late 2024 through 2026, with the leaders now in the low 80s, but a 75% success rate on a multi-step task still means 25% of the time the agent did the wrong thing on a screen the user wasn't watching.

**The blast radius is enormous.** A computer-use agent has the same authority as the user account it's running under: their browser sessions, their saved passwords, their files, their email. Sandboxing matters more here than anywhere else. Production deployments run the agent in a VM with no access to the user's real session and a fresh login each time. See section 9.

The honest 2026 take: computer use works for well-bounded tasks on simple GUIs (filling forms, scraping data from a web app with no API, basic e-commerce flows). It's not yet reliable enough for arbitrary "do my work for me" tasks, and the failure modes (clicked the wrong button, submitted the wrong form) are visible only after the fact.

## 6. Memory: what survives between turns and between sessions

This was covered in {% post_link Context-Is-the-Whole-Game %} from the context-engineering angle. For agents specifically, there are two memory horizons that matter.

**Within-task memory** is the agent's working state during a single task. Tool results, intermediate plans, decisions about which approach to try. The naive design keeps all of it in the conversation history. The better design **externalizes** state: the agent writes a scratchpad file (`PROGRESS.md`, `TODO.md`, `findings.json`) that the harness re-injects on each turn. The conversation history can be compacted aggressively; the scratchpad is the durable state.

This is exactly how Claude Code's `TodoWrite` tool works. The model maintains a todo list in a structured store; on each turn the current list is in the prompt. Old turns describing how items got added or completed get compacted out, but the list itself survives. The result: a 200-turn coding task stays coherent because the model is always reasoning over the current todo list, not over a 200-turn transcript of how the list evolved.

**Across-session memory** is what persists when the agent stops and restarts (or when a new conversation begins). Three patterns in production:

- **User-edited project files.** Claude Code reads `CLAUDE.md`, Cursor reads `.cursorrules`, Aider reads `.aider.conf.yml`. The user writes preferences and project conventions; the agent reads them every session. Simple, transparent, the user is in full control.
- **Auto-extracted facts.** A separate LLM call after each conversation extracts user facts ("user prefers TypeScript," "user is building an iOS app called Petfolio") and stores them in a KV store that the next session loads. ChatGPT's Memory, Claude's project memory, Gemini's "personalize" feature. Less transparent, harder for the user to audit, but lower friction.
- **Vector memory.** Past conversations get chunked and embedded; the current conversation retrieves relevant ones. Blurs into RAG; mechanically identical. Used by some research-agent products (Mem0, Letta) but not the default in the chat products.

The big trap across all three is the same one as RAG: **more memory is not better memory**. A memory layer that injects every past fact about the user dilutes attention and burns budget. Production designs forget aggressively: summarize old facts into shorter facts, drop facts that haven't been used in N sessions, let the user prune.

The design that works in practice for long-running agent memory: a directory of small markdown files (one fact or one rule per file) indexed by a `MEMORY.md` table of contents. The table of contents lives in the system prompt; full files are loaded on demand. The "active context" at any moment is the table of contents plus a handful of files the current task pulled in. Claude Code's auto-memory feature works this way; the equivalent in Cursor and other agent runtimes follows the same shape. The win over a single growing memory file is that growth happens by adding files, not by appending to one file the model has to re-read in full every turn.

## 7. Failure modes

Agents fail in ways chatbots can't, and most of them come from the loop being unbounded. The failure modes below are the ones you'll see in Claude Code, Cursor, ChatGPT's agent mode when something goes wrong; the defenses listed underneath each are what mature harnesses already implement, and what to add if you're writing your own. The gap between "a Python while-loop calling the OpenAI SDK" and Claude Code is mostly these defenses, not anything fancier.

### The infinite loop

The model calls a tool, the tool fails, the model retries the same tool with the same arguments, the tool fails again, repeat. Or: the model finishes a subtask, decides it isn't done, restarts the subtask, finishes again, decides it still isn't done. Easy to land in: an agent that runs `npm install` thirty times in a row because the first run had a transient warning the model decided was a problem to "fix," then re-runs the same install hoping the warning will go away. The model has no notion that it's stuck; from inside the loop, each retry feels like a new attempt at a slightly different problem.

Defenses:

- **Hard step limit.** Cap at 50 or 100 tool calls per task. Bail with an error message that surfaces to the user.
- **Recent-call deduplication.** If the model emits the exact same tool call three times in a row, refuse and tell the model so.
- **Budget tracking.** Show token spend and tool count in the agent's context. Models adjust their behaviour when they can see they're spending too much.

Claude Code, Cursor, Cline, Aider all have variants of all three. The patterns are convergent.

### Runaway tool calls

A relative of the loop: the model spawns ten parallel tool calls when one would do, or fans out a search over a million results, or recursively calls itself via sub-agents. The cost spikes by 100x without a visible failure. The user sees "agent is working" for half an hour and a bill at the end.

Defenses are mostly about visibility: surface the tool call count and token usage live, alert on outliers, let the user cancel. Hard caps on parallelism and recursion depth.

### Premature giving up

The opposite failure: the model decides it's done before the task is done, or hits a tool error and bails instead of trying an alternative. "I was unable to find a file matching that pattern" when the correct response was to try a different search.

This one is harder to fix because the failure mode is "agent emits a final answer too soon." Defenses are at the prompt and eval layer: instruct the model to verify the result, run an eval that catches premature-stop trajectories, train against the failure mode (most frontier model RLHF in 2025-26 specifically penalized premature stopping in agent settings).

### Context exhaustion

The 50-turn coding task whose context is now mostly stale `read_file` outputs of files the model has long since moved past. The model starts confusing the current state of the codebase with what it was 30 turns ago, and "fixes" land on imaginary code.

Defenses: aggressive compaction (summarize old turns, especially old tool results, into a paragraph), externalized state (the scratchpad / todo list / progress file pattern), and the ability for the model to re-read a file rather than relying on what it saw earlier.

### Spec drift

The user asked for a feature. Thirty tool calls later, the agent is shipping something tangentially related because it kept "improving" along the way. The intermediate steps each made local sense; the global trajectory did not.

This is where having an externalized plan (or todo list) matters: the plan is the anchor. Every turn, the model is supposed to be making progress against the plan, not improvising. Models that re-read the plan on each turn drift less. Cursor's agent has explicit "are we still on track" prompts injected mid-loop for this reason.

## 8. Evals: trajectories, not just final outputs

This section is mostly for people shipping agent products, since "running evals" isn't part of the day-to-day if you're just using one. Worth skimming anyway: the benchmark names (SWE-bench, OSWorld, τ-bench, GAIA) are the ones quoted in every model release post, and knowing what they actually measure helps you read claims like "Opus 4.7 hits 87.6% on SWE-bench Verified" with the right amount of skepticism.

Eval methodology for agents is different from eval methodology for chatbots, and most teams are still catching up.

For a chatbot, the eval question is: did the final output answer the question? You score the last assistant message and you're done. Datasets like MMLU, GSM8K, MT-Bench all work this way.

For an agent, the final output ("done!") is almost never what you want to score. You want to score the **trajectory**: did it call the right tools, in a reasonable order, without spinning, without exceeding budget, with appropriate handling of intermediate failures? Two agents that produce the same final output can have wildly different trajectories, one finishing in 5 steps and one in 50.

The benchmark community caught up over 2024-25. The standards now:

- **SWE-bench Verified** (Princeton, 500 human-validated Python issues from real GitHub repos): the canonical "can your agent fix a bug?" benchmark. Final pass/fail is on test suite results, but secondary metrics track tool calls used, files touched, and patch size. Frontier models in mid-2026 cluster at 80-88% pass rate (Opus 4.7 at 87.6%, Opus 4.5 at 80.9%, Gemini 3.1 Pro at 80.6%); the gap from 2024 (~15%) to now is mostly agent loop quality and tool design, not raw model capability. OpenAI has stopped reporting SWE-bench Verified scores entirely after their audit found every frontier model could reproduce gold patches verbatim, so treat the top of the leaderboard with that caveat in mind
- **OSWorld** and **WebArena**: computer-use / browser-use benchmarks. Score is task completion on real OSes and real web apps; trajectory metrics (steps taken, dead-ends explored) are reported alongside. Top frontier models in 2026 (GPT-5.5 around 75% on OSWorld-Verified, Claude Sonnet 4.6 at 73%, Opus 4.6 at 72.7%) now approach the 72-84% human baseline
- **τ-bench** (Sierra, June 2024; "tau-bench"): multi-turn agent benchmarks with realistic customer-service tools and a simulated user. Specifically designed to expose context-loss and tool-misuse failure modes. Extended in 2025 with τ²-bench (multi-domain) and τ-voice (real-time voice agents)
- **GAIA** (Meta + Hugging Face, 466 questions across reasoning, multi-modality, web browsing, tool use): general-purpose assistant benchmarks. Humans get 92%; Level 1 is now saturated by frontier models, Level 3 is where 2026 capability differences still show (top score around 52%)

For internal evals, the patterns that work in production:

- **Record real trajectories.** Save the full message-and-tool-call sequence for every production task. This is the dataset; without it you can't do anything else
- **LLM-as-judge on trajectories.** Frontier-model graders score "did the agent take reasonable steps?" alongside "did it get the right answer?" The grader sees the full trace, not just the last message
- **Regression tests on known tasks.** Pick 20-50 representative tasks. Run them on each model update. Watch for degradation in trajectory quality even when final-output accuracy is unchanged. This catches subtle regressions like "model now uses search_files where it used to use grep" before they bite users
- **Cost and latency as first-class metrics.** Token spend per task, wall-clock time, tool call count. A model that "scores the same" but uses 2x the tokens is a real regression. The 2026 frontier-model evaluations now report these alongside accuracy because the wins are no longer "is the answer right?" but "is the answer right for an acceptable cost?"

The harder eval problem is open-ended tasks where there's no automatic grader. "Refactor my codebase to use the new auth library" has no single correct answer. The best 2026 production answer is still a sample of expert human reviewers grading trajectories, plus LLM-as-judge for scaled secondary signal.

## 9. Safety: the loop has hands

You feel this section every time Claude Code asks "should I delete this file?" or Cursor asks "should I apply this edit?" or ChatGPT's agent stops to confirm a purchase. The permission prompts can feel like friction; this section is why they exist and which ones to never let your tool turn off.

Most of the safety story in {% post_link Context-Is-the-Whole-Game %} carries over (the prompt-injection problem is the same; trust boundaries between content sources is the same). Agents add one specifically agent-shaped problem: **the model can take actions**.

The framing that's stuck is **blast radius**. For each tool the agent can call, what's the worst that can happen if the model gets fooled into calling it on the wrong inputs? Three rough tiers:

- **Reversible, sandboxed, local.** Reading files in a project directory, running a script in a container, querying a read-only database. Worst case: the model wastes tokens. Default-allow.
- **Irreversible local, or external read.** Writing files, hitting external APIs that return data, running a script outside a container. Worst case: corrupted local state, leaked context to a third party. Default-prompt.
- **External writes, payments, communications.** Sending an email, making a payment, posting to a public channel, deleting from a shared resource. Worst case: real-world consequences. Default-deny without explicit confirmation per action.

Production agent harnesses are built around this tiering. Claude Code has read/edit/execute permission tiers and asks for confirmation before each destructive operation in non-`--dangerously-skip-permissions` mode. Cursor has an "apply" gate before file writes. Devin runs in a remote VM. The pattern is convergent because it's the only thing that works: the model is not trustworthy enough to autonomously execute high-blast-radius actions, and probably won't be for the foreseeable future.

Other defenses worth pairing with permission tiering:

- **Sandboxing**: run tools in containers, restrict filesystem and network access. A `bash` tool that runs in a Docker container with `--network=none` is much safer than one that runs on the host
- **Capability restriction**: an agent that doesn't need filesystem write access shouldn't have a `write_file` tool. The smallest viable tool set is the safest one. This is the reverse of "expose every MCP server you can find"
- **Prompt injection assumption**: any content the agent didn't author (web pages, file contents, tool results from third parties) can contain instructions. Treat them as data. The defenses from the {% post_link Context-Is-the-Whole-Game %} prompt-injection section all apply, with the extra teeth that the consequences are now actions instead of just words
- **Human-in-the-loop on consequential actions**: the irreplaceable defense. The model proposes, the user approves. Annoying. Necessary

The 2026 picture: we've made agents capable enough to do real work, but not safe enough to do it autonomously at high blast radius. Every production agent product is a negotiation between those two facts. The good ones make the tradeoff visible to the user. The bad ones hide it and ship eventually-newsworthy outages.

## What the loop costs

A back-of-envelope for what a serious agent run looks like on the bill, mid-2026:

| Task | Model | Tool calls | Input tokens | Output tokens | Cost |
|---|---|---|---|---|---|
| Fix a small bug, single file | Sonnet 4.6 | 8 | 35K (cached: 5K) | 4K | ~$0.15 |
| Refactor across 8 files | Opus 4.7 | 35 | 280K (cached: 220K) | 18K | ~$0.90 |
| Deep research, 12 sources, multi-agent | Opus orchestrator + 4 Sonnet sub-agents | 60 | 950K total | 45K | ~$6 |
| Hour-long computer-use session | Opus 4.7 + vision | 220 | 1.2M (mostly screenshots) | 12K | ~$7 |

Caching keeps the bill roughly half what it would otherwise be on long-running tasks; for short tasks with little reused context, the savings are marginal. Without caching the long-context lines double; for the multi-agent and refactor rows above, that's the difference between an affordable run and a wince. The arithmetic is exactly the one from {% post_link Context-Is-the-Whole-Game %}, just compounded across 50 tool turns instead of one. If anything, agents are the place where context engineering has the highest leverage, because every turn is paying input cost on the accumulated transcript.

## Putting it together

A 2026 agent isn't one new idea; it's a tight loop wrapped around four older ideas (LLM, tool use, context engineering, evals) plus the operational scaffolding to keep the loop from running away.

For users, the takeaway is: the difference between Claude Code feeling sharp on one task and feeling lost on another is rarely about the underlying model. The model is the same Opus 4.7 either way. What changed is whether the harness had the right tools registered, whether the descriptions made the model pick well, whether the permission boundary was sensible, whether memory and scratchpad state survived the long context. Those are all harness decisions you don't see but feel constantly.

For people writing harnesses, the interesting design work is:

- Picking which tools to expose, and writing their descriptions like they're prompts (because they are)
- Caching the system prompt and tool definitions so the per-turn cost stays bounded
- Externalizing state to scratchpad files instead of trusting the context to hold everything
- Drawing the permission boundary at the right place for the task's blast radius
- Logging trajectories so you can eval them, regress them, and learn from them

The model gets better every six months. The harness around the model is what your product actually is.

## Reading list

- [Building effective agents](https://www.anthropic.com/research/building-effective-agents): Anthropic's reference piece. The workflow / agent distinction in this post comes from here
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system): the production writeup with real numbers on orchestrator + sub-agent
- [Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents): Cognition's counterpoint. Read alongside the Anthropic piece, don't pick one
- [Model Context Protocol spec](https://modelcontextprotocol.io/specification): short, readable, and the protocol now half the agent ecosystem speaks
- [Anthropic's tool use docs](https://docs.claude.com/en/docs/build-with-claude/tool-use): the cleanest reference for what tool calls look like on the wire
- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629): the 2022 paper that named the pattern
- [Computer use documentation](https://docs.claude.com/en/docs/build-with-claude/computer-use): the first production-grade computer-use API, useful for understanding what the primitive set looks like
- [SWE-bench](https://www.swebench.com/) and [τ-bench](https://github.com/sierra-research/tau-bench): the agent eval benchmarks worth caring about

If you read one thing: *Building effective agents*. If you read two, add Cognition's *Don't build multi-agents* for the friction. Everything else is implementation detail.
