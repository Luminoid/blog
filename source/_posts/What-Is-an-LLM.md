---
title: "What is an LLM"
date: 2026-05-24 12:00:00
categories:
- AI
tags:
- LLM
- transformer
- attention
- tokenization
- pretraining
- RLHF
- scaling-laws
- MoE
- inference
---

A working mental model of large language models, written for an engineer who has shipped real software but never trained a neural network. The post is layered: the first stretch is the whole thing in plain language with one or two grounded formulas; the middle goes into the architecture with every symbol defined; the last part covers training, inference economics, and what's actually new at the frontier in 2026. Stop reading whenever you have enough.

<!-- more -->

## The whole thing in one sentence

An LLM is a function that takes a sequence of tokens and returns a probability distribution over what the next token should be. Everything else, the chat experience, the reasoning, the tool use, the apparent understanding, is built on top of that one operation, applied repeatedly.

That's the whole job. The model never sees a question and a separate "answer slot." It sees a prefix of text and produces a probability for every possible next token. Sample one. Append it. Feed the new sequence back in. Repeat until you hit a stop token or a length cap.

If you internalise nothing else from this post, internalise that. Most of the surprising behaviours of LLMs (hallucination, sensitivity to prompts, the fact that "let's think step by step" works at all) fall out of the structure of that loop.

Pseudocode for "what an LLM does at runtime":

```python
def generate(prompt: str, stop_token: int, max_tokens: int) -> str:
    tokens = tokenize(prompt)                 # ["The", " cat", " sat"] -> [791, 8415, 8696]
    for _ in range(max_tokens):
        logits = model(tokens)                # a score for every word in the vocabulary
        probs = softmax(logits)               # turn scores into a probability distribution
        next_token = sample(probs)            # pick one
        if next_token == stop_token:
            break
        tokens.append(next_token)
    return detokenize(tokens)
```

`model(tokens)` is the entire transformer: hundreds of billions of parameters, dozens of layers of attention, the works. Everything that follows is detail about what's inside that one call.

---

## The six ideas the rest of the post is about

Before any math, here are the six concepts you need. Each is one paragraph. The deeper sections later in the post unpack them.

### 1. Text becomes integers (and the integers are coarse)

A **tokenizer** chops your text into pieces (usually subword fragments) and looks each piece up in a fixed vocabulary, returning an integer ID. Modern vocabularies sit around 100K-200K entries. The model never sees characters. It sees a list of integers. This is why Claude is bad at counting the letter `r` in "strawberry": Claude doesn't see letters, it sees `straw|berry`, two tokens, no visible `r`s. The tokenizer is upstream of everything; the model's view of the world is constrained by what the tokenizer can represent.

### 2. Each integer becomes a vector that means something

The first thing the model does with a token ID is look it up in an **embedding table**: a giant 2D array, one row per vocabulary entry, each row a list of (say) 4096 floating-point numbers. That row is the token's "meaning" as far as the model is concerned. It was learned from scratch during training, not designed. Semantically related tokens (`cat`, `kitten`, `feline`) end up with similar vectors. The whole network from this point onward is operations on vectors; the original integers are gone.

Think of the embedding as a hash table where the values are coordinates in a 4096-dimensional space, and the geometry of that space encodes meaning.

The embedding table for Llama-3 8B is a `128,000 × 4096` matrix. Each of its `~524 million` cells is one **parameter**: a single number the training process learned. (A linear function `y = w·x + b` has two parameters, `w` and `b`; a transformer has billions of them, organized into matrices, applied in layers. Each is one "dial" gradient descent tuned. The dials don't have human-readable meanings individually; their collective behaviour is what produces fluent text.) The embedding table alone is half a billion of Llama-3 8B's parameters; the rest live in the attention and feed-forward weight matrices of every layer.

### 3. Every layer asks the same question: which earlier tokens matter for this one?

The transformer's core operation is **self-attention**. For each token, the model looks back at every earlier token in the sequence and computes a weighted blend of their information, where the weights are computed on the fly from the tokens themselves. The "weight" answers: how relevant is this earlier token to figuring out what comes after the current one? Pronouns lean heavily on the noun they refer to. Code tokens lean on the variable's declaration. Then the same operation runs again, on the updated vectors, then again, dozens of times. Each layer rewrites every token's vector in light of every other token's vector.

If you've used SQL: imagine that at every layer, every token runs a query against every earlier token, gets back a relevance score, and pulls a blended snippet of their data into its own row. Now imagine 80 layers of that.

### 4. Position has to be added back in by hand

Self-attention is permutation-invariant. If you shuffle the tokens in the input, the math gives the exact same answer. That's a problem for language, where "dog bites man" and "man bites dog" mean different things. The architecture handles this with a separate **positional encoding** that gets baked into each token's vector before attention sees it. Modern models use **Rotary Position Embedding (RoPE)**, which encodes a token's position by rotating its vector by an angle proportional to where the token sits in the sequence. The math is clever but the consequence is plain: position is not an implicit property of the input, it's a learned signal added explicitly.

### 5. Training is one objective applied to trillions of tokens

Pretraining shows the model trillions of tokens of text and asks it, at every position, "what comes next?" The loss is the negative log-likelihood of the actual next token (technical phrasing for: "how surprised was the model by what actually came next? lower is better"). That loss is what gradient descent uses to nudge every parameter in the model, one tiny step at a time, in the direction that would have lowered the surprise. No labels, no human in the loop, no engineered task. The internet is the dataset, and the dataset comes with its own answer key (the next token is already in the file).

This is called **causal language modeling**. The objective is absurdly general. To predict the next token of a Stack Overflow answer the model has to learn Python syntax. To predict the next token of a Wikipedia article on the French Revolution it has to learn 18th-century history. To predict the next token after "17 × 23 = " it has to learn arithmetic. The model absorbs whatever it has to in order to lower that one loss. Everything the base model knows is downstream of this single objective.

### 6. The "chat" model is the base model after some additional manners training

A raw pretrained model isn't a chatbot. It's a text completer. If you give it "How do I deploy a Next.js app?" it might continue with three more questions in the same format, because it pattern-matches the prompt to a Stack Overflow post or an interview.

To turn that completer into something that answers, you run it through **post-training**: a few rounds of fine-tuning on curated `(question, good-answer)` pairs, then preference optimization on `(question, better-answer, worse-answer)` triples. The model learns to play a role (assistant) and to follow the formatting (user turn → assistant turn → user turn). The knowledge is essentially all from pretraining. The conversational shape is from post-training.

### End-to-end: a tiny example

Take the prompt `The cat sat on the`. The tokenizer turns it into roughly `[791, 8415, 8696, 389, 279]`. Each integer gets looked up in the embedding table, producing five vectors of 4096 numbers each. The five vectors enter the first transformer layer; each one looks at all four earlier vectors (and itself) via attention, blends in their information, and comes out as a slightly different vector of the same shape. That happens at every one of the 32-or-80-or-120 layers. The last layer's output for the *fifth* position (the rightmost token, `the`) is projected back into vocabulary space, producing 200,000 logits, one per possible next token. Softmax turns those into probabilities. `mat` gets a high probability; so does ` floor`; so does ` couch`. Sample one. Append. Repeat.

If you stop reading here, you have a correct, complete mental model. The architecture details below explain *how* the layers do their thing; the training details explain *where the weights came from*; the inference details explain *what makes the bills so big*. None of them change the model above.

---

## The architecture, with every symbol defined

This section assumes you're comfortable with the six ideas above and want to see the inside of one transformer layer. The math is real but every symbol gets a one-line gloss the first time it appears.

### Tokenization, in more detail

The dominant tokenizer algorithm is **Byte Pair Encoding (BPE)**, originally a 1994 data-compression algorithm (Philip Gage), adapted to neural machine translation by Sennrich et al. in 2016, and brought into LLM tokenization at scale by GPT-2 in 2019. The training loop:

1. Start with a vocabulary of every byte (256 entries: 0x00 through 0xFF).
2. Count every adjacent pair of tokens in the training corpus.
3. Merge the most common pair into a new token. Add it to the vocabulary.
4. Repeat until you hit your target vocabulary size (~100K-200K).

The output is a list of merge rules. At inference time, you apply the same merges in the same order to any new text. The result is a sequence of token IDs.

Why BPE wins: common sequences (English words, frequent code patterns) end up as single tokens, so a typical document compresses 4x to 5x relative to characters. Rare sequences fall back to character or byte fragments. Because the vocabulary includes all 256 bytes, the tokenizer can encode literally any byte string, including emoji and Chinese characters it has never seen as a merged token.

Trade-offs in practice:

| Tokenizer | Vocab size | Implementation | Used by | Quirks |
|-----------|-----------|----------------|---------|--------|
| GPT-2 BPE | 50,257 | OpenAI, Python | Original GPT-2 | Whitespace handled awkwardly; "Hello" and " Hello" are different tokens |
| `tiktoken` (cl100k, o200k) | ~100K, ~200K | OpenAI, Rust | GPT-3.5/4/5, Llama 3+, Mistral Tekken | 3-6x faster than alternatives; UTF-8 byte BPE |
| SentencePiece (BPE or Unigram) | varies | Google, C++ | Gemini, Gemma, T5, Llama 1/2 | Operates on Unicode code points; encodes spaces as `▁` |
| Claude tokenizer | ~200K (Opus 4.7) | Anthropic, internal | Claude 3+ | Not publicly documented; users report that the same English text tokenizes to slightly more tokens than under earlier Claude versions |

A token of English averages about 4 characters, a token of Chinese averages about 1 character, a token of base64 is basically a byte. When you compare prices across providers, normalize on characters or on a fixed corpus.

### Context window

The number of tokens the model can attend to at once is its **context window**. This is a hard architectural limit, set at training time by how far position encodings have been stretched and how much memory the KV cache (the per-token state attention needs to keep around; we'll get to it) can hold during inference.

1M is now table stakes at the frontier (Opus 4.7, GPT-5.5, Gemini 3 all sit there). Grok pushes to 2M. Llama 4 Scout markets 10M, though the practical eval drops off well before the headline. Attention is quadratic in sequence length at train time and linear at inference per token (after the KV cache), but it's also lossy: models routinely "forget" things buried in the middle of a long context, a phenomenon usually called context rot. The next post in this series is entirely about how to use the context window without falling into its traps.

Context length is a property of the model, not the API. You can't ask a 128K-context model to attend to a million tokens, no matter what wrapper you put around it.

### Inside one transformer layer

A modern transformer is one block stacked many times. Inside one block, on one token:

```
input vector (e.g. 4096 numbers)
       │
       ▼
┌──────────────────────────────────────────┐
│ RMSNorm                                  │  rescale activations to unit norm
└──────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ Multi-head self-attention (with RoPE)    │  this token looks at every earlier token
│   Q, K, V projections                    │
│   output projection                      │
└──────────────────────────────────────────┘
       │
       ▼  (residual: add the original input back in)
       │
       ▼
┌──────────────────────────────────────────┐
│ RMSNorm                                  │
└──────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────┐
│ Feed-forward (SwiGLU)                    │  per-token MLP, ~4x wider than input
└──────────────────────────────────────────┘
       │
       ▼  (residual: add the pre-MLP value back in)
       │
       ▼
output vector (same shape as input)
```

Three concepts in there need unpacking before the diagram makes sense:

- **RMSNorm (Root Mean Square Normalization)** rescales a vector so its values have a consistent magnitude. Without it, activations would drift toward exploding or vanishing as they flow through dozens of layers. Cheap, side-effect-free, applied before each sublayer.
- **Residual connection** ("add the input back in") means the sublayer's job is not to *replace* the input but to *add a refinement to* it. The original input flows past the sublayer along a "shortcut," and the sublayer's output gets summed in. This is the single most important trick that lets deep networks train at all; without residuals, gradients during training would die out long before reaching the early layers.
- **Feed-forward (SwiGLU)** is a small per-token transform: a two-layer network applied independently to each token's vector. Where attention mixes information *between* positions, the feed-forward layer transforms each token's vector *in place*, expanding it to ~4x wider (e.g. 4096 → 16384) and projecting it back. SwiGLU is the specific activation used: `Swish(xW) ⊙ (xV)`, a gated activation that outperforms ReLU at the same parameter count.

Stack 32 (Llama-3 8B) to 80 (Llama-3 70B) to 120+ (frontier MoE) of these blocks. The final block's output goes through one more `RMSNorm` and a projection to vocabulary size, producing the logits.

A few details have shifted since the original 2017 transformer:

- **Pre-norm, not post-norm.** The original transformer normalized after each sublayer. Everyone now normalizes before, because pre-norm trains more stably at depth.
- **RMSNorm, not LayerNorm.** Cheaper, same downstream performance.
- **SwiGLU, not ReLU.** Stronger activation for the same parameter count.
- **GQA, not MHA.** Inference optimization; we'll get to it.
- **Decoder-only, not encoder-decoder.** The 2017 paper had both halves. Everyone now uses just the decoder side, because next-token prediction is enough.

### Where the 8 billion parameters in Llama-3 8B actually live

The block diagram is enough to do the arithmetic. Meta's published Llama-3 8B config: vocabulary 128,256; hidden size `d_model` 4,096; 32 layers; 32 query heads grouped into 8 KV groups; head dimension 128; feed-forward intermediate size 14,336; input and output embeddings *not* tied.

**Embeddings.** The input embedding table is `128,256 × 4,096 ≈ 525M` parameters. The output projection (the "LM head" that maps the final hidden state back to vocabulary logits) is a separate matrix of the same shape: another `~525M`. Combined: **~1.05B**.

**One attention block.** GQA means `K` and `V` projections shrink while `Q` and the output projection stay full-size.

- `W_Q`: `4,096 × 4,096 ≈ 16.8M`
- `W_K`: `4,096 × 1,024 ≈ 4.2M` (8 KV heads × 128 dim instead of 32 × 128)
- `W_V`: `4,096 × 1,024 ≈ 4.2M`
- `W_O`: `4,096 × 4,096 ≈ 16.8M`

Attention per layer: **~42M**. (A non-GQA version would put `W_K` and `W_V` at ~16.8M each, total ~67M. GQA shaves ~25M off every layer; multiply by depth and that's where the cache savings come from.)

**One feed-forward block.** SwiGLU uses three matrices instead of the classic transformer's two: a gate projection, an up projection, and a down projection.

- `W_gate`: `4,096 × 14,336 ≈ 58.7M`
- `W_up`: `4,096 × 14,336 ≈ 58.7M`
- `W_down`: `14,336 × 4,096 ≈ 58.7M`

FFN per layer: **~176M**.

**Norms.** Two RMSNorms per layer, each with 4,096 learnable scale parameters. About 8K per layer. Rounding error.

**Per-layer total**: `42M + 176M ≈ 218M`. **All 32 layers**: `32 × 218M ≈ 6.97B`. Plus one more RMSNorm after the final layer (negligible).

Adding it up:

| Component | Parameters |
|-----------|-----------|
| Input embedding | 525M |
| Output embedding (LM head) | 525M |
| 32 × attention | 1.34B |
| 32 × feed-forward | 5.63B |
| Norms (×64 + final) | ~270K |
| **Total** | **~8.03B** |

Hence "8B." Meta rounds down in the model name; "70B" is actually ~70.6B, "405B" is ~406B.

A few things worth noticing about where the dials live in a modern LLM:

- **Feed-forward dominates.** ~5.6B of the 8B parameters are in SwiGLU blocks. Attention is the famous part of a transformer, but the FFN is where most of the weights sit. The 4x-wider intermediate dimension is doing a lot of work.
- **GQA's savings compound with depth.** Saving ~25M per layer × 32 layers ≈ 800M parameters, or ~10% of the model. For a 70B model with 80 layers the savings are much larger, both in parameter count and (more importantly) in KV-cache memory at inference.
- **Embeddings are non-trivial at small scale.** ~1B of the 8B is just embedding tables. For a 70B model with the same 128K vocab, embeddings are still ~1B but a much smaller fraction of total. Small models get hit hardest by tokenizer-vocabulary choices.

If you want to repeat this for any open-weight model, the relevant fields in HuggingFace's `config.json` are `hidden_size`, `intermediate_size`, `num_hidden_layers`, `num_attention_heads`, `num_key_value_heads`, `vocab_size`, and `tie_word_embeddings`. The arithmetic above generalizes.

### Self-attention, with the equation

The attention operation, in words: for each token, you compute a relevance score against every earlier token, normalize the scores so they sum to 1, then use them as weights to take a weighted sum of those tokens' content.

The equation from the 2017 [Attention Is All You Need](https://arxiv.org/abs/1706.03762) paper:

```
Attention(Q, K, V) = softmax( Q · Kᵀ / √d_k ) · V
```

Symbols:
- **`Q` (queries)**: a matrix where each row is one token's "what am I looking for?" vector. Computed by `X · W_Q`, where `X` is the token vectors going into this layer and `W_Q` is a learned weight matrix.
- **`K` (keys)**: each row is one token's "here's what I am" vector. Computed by `X · W_K`.
- **`V` (values)**: each row is one token's "here's what I'd contribute" vector. Computed by `X · W_V`.
- **`Q · Kᵀ`**: dot product of every query against every key. Big when a query and key point in similar directions, small otherwise. This is the *score* that says how relevant token *j* is to token *i*.
- **`√d_k`**: the square root of the dimension of one key vector. Dividing by it keeps the dot products from getting so large that softmax saturates into a one-hot (which would kill gradients during training).
- **`softmax(...)`**: converts each row of scores into a probability distribution over earlier tokens. `softmax(z)_i = exp(z_i) / Σⱼ exp(z_j)`.
- **`... · V`**: weighted sum of value vectors using those probabilities as weights. The output is each token's updated representation.

In one sentence: every token forms a query, every token publishes a key and a value, attention matches queries to keys and pulls in a blend of the corresponding values.

`W_Q`, `W_K`, `W_V` are three of the trainable weight matrices per layer (millions of parameters each). They're learned during pretraining; nobody designs them. The role specialization (this head tracks subject-verb agreement, that head tracks coreference) emerges from gradient descent on next-token prediction.

### Positional encoding (RoPE)

The 2017 paper added position information as a fixed sinusoidal signal to each token vector before attention. Modern models almost all use **Rotary Position Embedding (RoPE)** instead. RoPE encodes position by rotating each pair of dimensions in `Q` and `K` by an angle proportional to the token's position. Two consequences fall out of the rotation algebra:

- **Relative positions are free.** The dot product `Qᵢ · Kⱼ` (the attention score from token *i* to token *j*) depends only on `i - j`, the gap between them, not their absolute positions. This matches how language actually works.
- **The encoding extrapolates (with caveats) beyond the training context length.** A model trained on 8K context can attend to 32K tokens with some quality degradation, which gave the field the headroom to push to 1M.

Llama, Mistral, Gemma, Qwen, DeepSeek all use RoPE. It is the single biggest "small thing" that changed in the architecture between 2017 and 2026.

---

## Training, inference, and what's actually new

This section is for someone who's ingested the architecture above and now wants the operational story: how the weights got there, what they cost to compute against, how the post-training stack works, what's actually new in 2026.

### Scaling laws, and what changed after Chinchilla

You have a compute budget. You want the best model possible. How do you spend it?

The 2020 [Kaplan scaling laws](https://arxiv.org/abs/2001.08361) (OpenAI) said: make the model bigger. They ran experiments on small models and extrapolated, concluding that compute should be spent mostly on parameters.

The 2022 [Chinchilla paper](https://arxiv.org/abs/2203.15556) (DeepMind, Hoffmann et al.) re-ran the experiments more carefully and arrived at a different answer: parameters and tokens should scale **together**, roughly 20 tokens per parameter. Their 70B model "Chinchilla" trained on 1.4T tokens beat the 280B "Gopher" trained on 300B tokens, with the same compute. Bigger model, less data was the wrong trade.

The headline numbers:

| Model | Parameters | Tokens trained | Tokens/param |
|-------|-----------|----------------|--------------|
| GPT-3 (2020) | 175B | 300B | 1.7 |
| Gopher (2021) | 280B | 300B | 1.1 |
| Chinchilla (2022) | 70B | 1.4T | 20 |
| Llama 1 (2023) | 65B | 1.4T | 22 |
| Llama 3 (2024) | 70B | 15T | 215 |
| Llama 3 405B (2024) | 405B | 15T | 37 |
| DeepSeek V3 (2024) | 671B (37B active) | 14.8T | 22 on total, ~400 on active |

Llama 3 and onward broke the Chinchilla ratio deliberately. The argument: Chinchilla optimizes loss-per-compute at training time, but in production, inference dominates total cost. A smaller model trained on far more tokens is more expensive to train but cheaper to serve forever. Llama 3 70B at 215 tokens/param is "over-trained" by Chinchilla's definition, and that's the point.

The 2025 [Farseer paper](https://arxiv.org/abs/2506.10972) revised the scaling-law functional form further and suggested the optimal ratio grows with compute, which matches what Llama 3, Qwen 3, and DeepSeek V3 actually do.

### Pretraining, end to end

The high-level recipe hasn't changed much since GPT-3, but every step has gotten more careful.

**Data.** Start with the open web (Common Crawl), then filter aggressively. Deduplicate, remove low-quality content, balance domains, mix in code, math, books, and (increasingly) synthetic data generated by smaller models. Modern pretraining corpora are 10T-20T tokens. The mix is the part labs guard most carefully.

**Compute.** Tens of thousands of GPUs (Nvidia H100s, H200s, B200s) for months. The training loop is conceptually one PyTorch step: forward pass, compute loss, backward pass, optimizer step. Scaled across thousands of GPUs with tensor parallelism, pipeline parallelism, data parallelism, and (for MoE models) expert parallelism. Frontier runs cost $100M-$1B in compute.

The back-of-envelope for total training compute is `C ≈ 6 × N × D`, where `N` is the number of parameters and `D` is the number of training tokens. The factor of 6 comes from the forward pass (2 FLOPs per parameter per token: one multiply and one add per weight) and the backward pass (4 FLOPs, because you compute gradients with respect to both weights and inputs). The optimizer step is a separate `O(N)` cost folded into the constant. A 70B model trained on 15T tokens is `6 × 7e10 × 1.5e13 ≈ 6.3 × 10^24` FLOPs. Divide by the sustained throughput of an H100 (~700 TFLOP/s in BF16, vs. ~989 TFLOP/s peak) and you get ~9 billion GPU-seconds, or about 280 H100s running for a year. The actual Llama-3 70B run used much more in wall-clock because real training never hits sustained peak.

(**FLOP** = one floating-point operation, an add or a multiply. **FLOPs** with lowercase s is a count of operations, a measure of total work. **FLOP/s** is a rate, used for hardware throughput. TFLOP = 10^12 ops, PFLOP = 10^15.)

**Optimization.** AdamW with cosine learning-rate decay, warmup, gradient clipping. Nothing exotic. Mixed-precision (BF16 weights, FP32 master copy) for memory and speed.

**Curriculum.** Many labs anneal the data mix over training: early steps see broad web text, later steps see higher-quality code, math, and instruction data. There's also a final "midtraining" phase that biases the model toward useful behaviour before any post-training begins.

The single most important thing to understand: pretraining produces a **base model**, a text completer with broad knowledge, no chat skills, no safety properties, no preference for being helpful over being correct or vice versa. Everything that makes Claude or GPT feel like an assistant happens after pretraining.

### Post-training: how a completer becomes an assistant

Through the end of 2024, the dominant recipe was SFT followed by RLHF with PPO (proximal policy optimization). That recipe has been replaced. The 2026 stack is modular and mostly looks like this:

**1. Supervised fine-tuning (SFT).** Show the model 10K-100K curated conversation examples. The format teaches it the assistant role. The content teaches it the right kinds of answers. Cheap, fast, but only as good as the data.

**2. Preference optimization.** Collect pairs of responses to the same prompt, labelled as "A is better than B" (sometimes by humans, increasingly by other models or rubric-based judges). The modern algorithm is **Direct Preference Optimization (DPO)** or one of its variants (SimPO, KTO, ORPO). DPO collapses the reward model and the RL loop into a single supervised loss on preference pairs.

The DPO loss, for completeness:

```
L_DPO = −log σ( β · log[π_θ(y_w|x) / π_ref(y_w|x)]
              − β · log[π_θ(y_l|x) / π_ref(y_l|x)] )
```

Symbols:
- **`x`**: the prompt.
- **`y_w`**: the winning (preferred) response. **`y_l`**: the losing response.
- **`π_θ(y|x)`**: probability the model being trained assigns to response `y` given prompt `x`. `θ` are the trainable parameters.
- **`π_ref(y|x)`**: probability a frozen *reference* model (usually the SFT model) assigns to the same. The ratio measures how much the new model has shifted from the reference on this example.
- **`β`**: a temperature-like knob (typical values 0.1 to 0.5) that controls how far the new model can drift from the reference. Larger β = stronger push.
- **`σ`**: sigmoid, squashing the bracketed score into (0, 1).
- **`−log σ(...)`**: standard binary cross-entropy loss. Becomes small when the new model assigns higher probability to the winner relative to the loser than the reference model did.

In one sentence: train the model to assign higher probability to good responses and lower probability to bad ones, relative to where it started. It trains like SFT, no sampling loop, no separate reward model. This is why DPO swept the field: it gave you most of RLHF's benefits for a fraction of the engineering pain.

**3. Verifiable-reward RL (RLVR).** For problems where you can mechanically check the answer (does the unit test pass, is the math right, does the JSON parse), you can skip human preferences entirely. The reward is 1 if the answer is correct, 0 otherwise, and you train with **GRPO** (Group Relative Policy Optimization) or **DAPO**. DeepSeek R1 popularised this approach. It's where the recent jump in reasoning capability comes from.

**4. Safety training.** A separate pass with adversarial prompts, jailbreak attempts, and red-team data. Often layered on top of everything else with constitutional AI techniques (the model critiques and revises its own outputs against a set of principles).

The order matters. SFT establishes format. DPO adjusts style and preferences. RLVR sharpens reasoning on hard, checkable problems. Safety training shapes refusals. Doing them in a different order, or skipping a step, gives a model with visibly different behaviour.

One thing that surprised me when I first dug into this: **most of what feels like a model's "personality" comes from post-training, not pretraining**. The leaked open-weight base models (Llama 2 base, Mistral base) feel almost interchangeable when you prompt them raw; their chat-tuned descendants don't. The preferences encoded in the post-training data are what make one assistant feel cautious-and-thorough and another feel chatty-and-confident.

### Inference, where the bills come from

You have a trained model. Someone sends a prompt. What happens?

**Step 1: prefill.** The model processes the entire prompt in one forward pass. Every token attends to every previous token. For each layer and each token, the K and V vectors (computed once) get stored in memory: this is the **KV cache**. This phase is *compute-bound*: the GPU's matrix-multiply units stay busy.

**Step 2: decode.** The model generates one token at a time. Each step is a forward pass on just the new token, using the cached K and V from prefill (no need to recompute them for earlier tokens). Each step is *memory-bandwidth-bound*: most of the time is spent reading the cache out of high-bandwidth memory (HBM, the fast memory next to the GPU chip), not computing.

The split has consequences:

| Phase | Bottleneck | Per token | Optimization |
|-------|-----------|----------|--------------|
| Prefill | Compute (FLOPs) | ~50-200 tokens/sec processed | Bigger batches, more FLOPs |
| Decode | Memory bandwidth | 30-200 tokens/sec generated | Smaller cache (GQA), faster memory, speculative decoding |

Production systems at the major providers now split prefill and decode onto different GPU pools, because the optimal hardware for each is different. Prefill wants raw compute. Decode wants memory bandwidth and big aggregate cache.

The KV cache is the big inference cost driver. For a 70B model at 128K context, the cache can be 40-80 GB. Hold that in HBM for every concurrent request, and you understand why long-context pricing exists.

### Multi-head, multi-query, grouped-query attention

The original attention formula gets computed many times in parallel, with different `Q`, `K`, `V` projections. Each parallel copy is a "head." Heads can specialize in different things (one head tracks subject-verb agreement, another tracks coreference). The outputs concatenate and project back to the original vector size.

The catch shows up at inference: every head needs its own K and V stored in the cache for every previously seen token. For a 70B model at 128K context, that's tens of gigabytes of memory bandwidth on every output token. Decode time is dominated by reading the cache.

The fix is to let multiple query heads share K and V:

- **Multi-Head Attention (MHA)**: every head has its own Q, K, V. Best quality, worst memory.
- **Multi-Query Attention (MQA)**: many Q heads share one K and one V. Smallest cache, noticeable quality drop.
- **Grouped-Query Attention (GQA)**: groups of Q heads share one K and one V. Splits the difference.

GQA won. Common configuration in Llama 3, Mistral, Qwen, Gemma, GPT-OSS: 32 query heads grouped into 8 KV groups, a 4:1 ratio. The cache shrinks 4x, the quality stays within noise of full MHA.

### Inference tricks that show up everywhere

- **Prompt caching.** If you send the same system prompt repeatedly, the provider can cache its K and V from prefill. Anthropic, OpenAI, and Google all offer this. Discounts vary: Anthropic and Google charge ~10% of the uncached rate on a cache hit (a 10x reduction), OpenAI charges ~50% (a 2x reduction).
- **Speculative decoding.** A smaller, faster "draft" model (trained to approximate the big one) proposes the next N tokens. The big model verifies them in parallel via one forward pass. If the draft was right, you generate N tokens for one big-model forward pass. Latency drops 2-3x without changing the output distribution.
- **Continuous batching.** Instead of waiting for every request in a batch to finish, the server slots new requests into freed positions as old ones complete. This is what lets a single GPU serve dozens of simultaneous chats.
- **Quantization.** Storing weights in INT8 (8-bit integers) or INT4 instead of BF16 (16-bit brain-float) cuts memory and bandwidth 2x-4x with usually small quality loss. Open-weight models are often shipped quantized.

### Sampling at the output

The model's final layer produces a vector of logits, one per token in the vocabulary. To turn that into a single chosen token, you sample.

The simplest method, **greedy**, picks the highest-probability token. Fast and deterministic, but tends to produce repetitive, lifeless text.

To inject variety, you apply a transform before sampling.

**Temperature** scales the logits before softmax:

```
p_i = exp(z_i / T) / Σⱼ exp(z_j / T)
```

`z_i` is the logit for token *i*. `T = 1.0` is the raw distribution. `T < 1.0` sharpens it toward the top tokens, more deterministic. `T > 1.0` flattens it, more random. `T = 0` is greedy.

**Top-k** keeps only the k highest-probability tokens, zeroes out the rest, renormalizes, and samples. Hard cap on the candidate set.

**Top-p (nucleus)** keeps the smallest set of tokens whose cumulative probability exceeds p. Dynamic cap: when the model is confident, the nucleus is small; when it's uncertain, the nucleus widens. Common values: `p = 0.9` to `p = 0.95`.

**Min-p** (newer) keeps tokens whose probability is at least `p × max_prob`. Adapts to how peaked the distribution is.

You pick one. The folk rule: tune temperature *or* top-p, not both. Temperature 0 for code and structured output. Temperature ~0.7-1.0 with top-p 0.95 for chat. Higher temperatures for creative writing.

Sampling doesn't make the model more accurate or add new knowledge. It only controls how the model spends its uncertainty. A wrong model at temperature 0 gives you the same wrong answer every time; at temperature 1, a distribution of wrong answers.

### Mixture of experts: the scaling cheat code

By 2024 it became clear that scaling parameters past 500B with every parameter active on every token was bumping into a wall. The cost grew linearly. The quality gains shrank.

**Mixture of Experts (MoE)** breaks the symmetry. Replace each feed-forward block with a bank of expert FFNs (8, 64, 256, sometimes more) and a small router network that picks 1-8 experts per token. *Total* parameters (every dial in the model, including all the experts) explode, but *active* parameters (the dials that actually participate in computing this particular token) stay bounded. A 671B-total / 37B-active model has 671B dials sitting in memory but only does the math of a 37B model on each token.

The 2026 landscape:

| Model | Total params | Active params | Sparsity | Experts |
|-------|--------------|---------------|----------|---------|
| Mixtral 8x7B (2023) | 47B | 13B | 28% | 8 (top-2) |
| DeepSeek V3 | 671B | 37B | 5.5% | 256 routed + 1 shared (top-8) |
| Qwen3 235B-A22B | 235B | 22B | 9.4% | 128 (top-8) |

GPT-5.5 is widely believed to be MoE; OpenAI hasn't published numbers since GPT-4. Anthropic doesn't disclose either; the rumour mill on whether Claude is dense or sparse has flipped multiple times. The DeepSeek/Qwen pattern (many small fine-grained experts + one always-on shared expert) is the dominant 2026 shape among labs that publish.

The trade-off MoE makes: huge capacity at low active cost (training and inference FLOPs scale with active params, not total), but the full weight set has to sit in memory somewhere, which is brutal for single-GPU inference. MoE models are cheap to serve at scale, expensive to serve locally.

### Reasoning models, extended thinking, and what's actually new

Through 2024 the gain from "let's think step by step" prompts was already known: getting the model to write out its reasoning before its final answer dramatically improves performance on multi-step problems. The 2024-2025 jump was teaching the model to do that on its own, and to do it for much longer than a user would ever paste into a prompt.

OpenAI's o1 (September 2024) was the first model marketed this way. The model generates a long chain of thought, often thousands of tokens, before producing its visible answer. Then DeepSeek R1 (January 2025) showed you could produce a similar capability via RLVR on math and code, and published the recipe. Claude added "extended thinking" the same year. By 2026 it's no longer a separate mode on flagship models, it's a knob: "think for N tokens before answering."

Empirically, on math-heavy benchmarks, accuracy scales roughly logarithmically with thinking tokens. Doubling the thinking budget gives a fixed accuracy bump. There's a ceiling, but it's far higher than you can reach with a one-shot answer.

What this is *not*: the model isn't running new algorithms. It's the same next-token prediction loop, just allowed to run for longer before the visible response starts. The "reasoning" is text the model is writing for itself.

What this *is*: a way to spend more inference compute on harder problems. Inference-time scaling has become a third lever alongside parameters and training tokens.

### What LLMs structurally cannot do

A list of things that aren't going to be fixed by a bigger model.

**Reliable arithmetic on long numbers.** Tokenization fragments long numbers in ways the model can't reliably handle. The fix is tools (give the model a calculator), not more parameters.

Counting characters inside a token. "How many r's in strawberry" works only because the model has memorised the answer; ask about a token it hasn't seen and it'll guess.

Knowing what it doesn't know is the deepest of these. The 2026 [calibration literature](https://modelslab.com/blog/llm/llm-hallucination-rates-2026) keeps reaching the same conclusion: models present false information with the same fluent confidence they use for true information, because both come out of the same next-token loop. The plausibility space and the truth space are not the same space. No amount of fine-tuning makes them the same. The field has stopped trying to drive hallucination to zero and is instead working on bounding it: retrieval, citations, refusal-on-uncertainty training, verifier passes that re-check the model's own claims against a reference. Each of these moves a fraction of the problem out of the model and into a system around it.

**Reasoning about things that aren't in the training distribution.** Models extrapolate well within the distribution and poorly outside it. You can usually tell when you've fallen off the edge: the output gets confident and wrong rather than confident and right.

**Persistent memory across conversations.** Unless something writes to a database or a memory file, every conversation starts blank. The model itself is read-only at inference time. "Memory" in chat products is a separate layer (a file the system loads into context, not something the model learned).

Anything that requires more compute than the inference budget allows. A model with 8K thinking tokens cannot solve a problem that requires 80K. No compression cheat.

The interesting research direction now is less "fix these" and more "design systems that work around them." Tool use replaces internal arithmetic. Retrieval replaces internal recall. Verifiers replace internal calibration. The model is one component in a larger system, not a do-everything oracle. Which is exactly where the next post in this series picks up.

### A note on multimodality

Nothing above assumed the input was text. Modern flagships (GPT-5.5, Claude Opus 4.7, Gemini 3) are natively multimodal: they take images, audio, and sometimes video as input, and a few can produce images and audio as output. The trick is that everything still becomes tokens.

An image is fed to a vision encoder (usually a ViT, a transformer trained on image patches) that turns the picture into a sequence of patch embeddings. Those embeddings get projected into the LLM's embedding space and concatenated with the text tokens. From the language model's view, an image is just a few hundred tokens that happen to encode visual content. Audio works the same way: a separate encoder turns waveforms into a sequence of vectors the LLM can consume.

The interesting consequence: long-context attention works across modalities. A model can attend from a text question to a specific region of an image, because both live in the same token stream. The not-so-interesting consequence: images are expensive. A single high-resolution image is often 1,000-3,000 tokens.

---

## A useful reading order for going deeper

If you want the formal foundation, in roughly this order:

- [Attention Is All You Need](https://arxiv.org/abs/1706.03762) (Vaswani et al., 2017). The transformer paper. Skip the encoder-decoder details, focus on Section 3.2.
- [The Annotated Transformer](http://nlp.seas.harvard.edu/2018/04/03/attention.html) (Rush, 2018). The transformer paper with executable PyTorch alongside the math. Best introduction to the architecture.
- [Language Models are Few-Shot Learners](https://arxiv.org/abs/2005.14165) (Brown et al., 2020). GPT-3. Establishes the scaling story before Chinchilla refined it.
- [Training Compute-Optimal Large Language Models](https://arxiv.org/abs/2203.15556) (Hoffmann et al., 2022). Chinchilla. The data-vs-parameters paper.
- [Direct Preference Optimization](https://arxiv.org/abs/2305.18290) (Rafailov et al., 2023). DPO. Why the post-training stack changed.
- [DeepSeekMoE](https://arxiv.org/abs/2401.06066) (2024). Fine-grained expert specialization and the shared-expert design that the 2026 MoE landscape converged on.
- [DeepSeek-V3 Technical Report](https://arxiv.org/abs/2412.19437). The most detailed modern frontier-model paper, including the auxiliary-loss-free load balancing and FP8 training tricks.
- [DeepSeek-R1](https://arxiv.org/abs/2501.12948) (2025). The reasoning paper. Shows how RLVR produces reasoning without supervised CoT data.

And one thing not on arXiv but worth your time: Karpathy's [Let's build GPT](https://www.youtube.com/watch?v=kCc8FmEb1nY) video. Three hours from scratch to a working tiny transformer. After watching it once, the math above stops being abstract.

The next post, {% post_link Context-Is-the-Whole-Game %}, walks through **context**: the substrate everything in this post operates on, and what changes when you move from a one-shot prompt to RAG to long-running agents that manage their own memory. Most of the practical engineering of working with LLMs lives there.
