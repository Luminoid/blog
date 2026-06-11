---
title: "Embodied intelligence in 2026: a field guide for software engineers"
date: 2026-06-07 14:30:00
categories:
- AI
tags:
- embodied-AI
- robotics
- embodied-cognition
- VLA
- foundation-models
- imitation-learning
- reinforcement-learning
- diffusion-policy
- sim-to-real
- autonomous-vehicles
- LeRobot
- ROS2
- MuJoCo
- Isaac-Lab
- Open-X-Embodiment
- humanoid-robots
- OpenVLA
- GR00T
- world-models
- morphological-computation
---

There's a strange gap at the center of modern AI. The same systems that pass the bar exam and write working code still can't reliably fold a towel, plug in a USB cable, or tidy a kitchen. The intelligence that lives in a chat box turned out to be the easy part; the intelligence that moves a body through the physical world is the hard part. And it's a different field, with its own history, its own methods, and its own brutal form of honesty: in the physical world the grader is physics, and physics does not accept a fluent excuse.

Embodied intelligence is that field. It's AI that perceives and acts in the real world, in cars, arms, drones, quadrupeds, and humanoids. It is decades older than ChatGPT, and it's now colliding with the language-model boom in a way that's pulling in enormous money and a lot of software engineers. This post is a tour of the whole thing for someone who writes software but has never touched a robot. It's layered: the first part is the mental model in plain language, the middle is how these systems are actually built and why data is the wall, and the last part is what a software engineer can do to get involved without a robotics PhD or a lab budget. Stop reading whenever you have enough.

<!-- more -->

If you've read the earlier posts in this series, {% post_link What-Is-an-LLM %} and {% post_link Agent-LLM-In-A-Loop-With-Tools %}, there's a one-line bridge: an embodied system is that same observe-decide-act loop, except the tools are motors, the observations are sensor readings, the loop runs fifty times a second, and there is no undo.

## The one big idea

Strip away the hype, and every embodied system runs the same ancient loop: sense the world, decide what to do, act, repeat. A Waymo car, an Amazon warehouse robot, a Boston Dynamics quadruped, and a humanoid in a demo video are all doing this. Roboticists have drawn this loop since the 1980s. It is also, not by coincidence, the exact shape of an LLM agent.

```python
# the text agent from the earlier post in this series
def agent(task, tools):
    messages = [{"role": "user", "content": task}]
    while True:
        response = llm.generate(messages, tools=tools)
        if response.is_final():
            return response.text
        for call in response.tool_calls:
            result = run_tool(call.name, call.arguments)   # API, file, browser
            messages.append(result)

# the same loop, embodied
def embodied_agent(instruction, robot):
    while True:
        obs = robot.read_sensors()             # camera frames, joint angles, force
        action = decide(obs, instruction)      # control math? a search? a neural net?
        robot.execute(action)                  # turn a motor; cannot be undone
```

Same shape: observe, decide, act, repeat. What changes from one robot to the next is what sits in the `decide` box. It might be hand-written control math, a search algorithm, a reinforcement-learned policy, or a giant neural network, and a lot of this post is about that box. But four things change the instant the body is real, whatever's in the box, and almost every hard problem in the field falls out of these four.

| | A text agent (Claude Code, ChatGPT) | An embodied system (a robot, a car) |
|---|---|---|
| What it sees | the full state, as clean text | partial, noisy streams from physical sensors |
| The clock | turn-based; think as long as you like | real-time; the world keeps moving whether or not you're ready |
| Mistakes | undo, retry, rerun the prompt | the glass is already on the floor |
| The grader | a reward number or a text corpus | physics, which does not care about your loss function |

That last row is the one to hold onto. A language model is graded against text humans wrote. A robot is graded against the world, and the world is the one source of truth that cannot be gamed, cached, or hallucinated. If the policy thinks the cup is 2cm to the left of where it actually is, the hand closes on air. There's no partial credit for a fluent explanation of why it should have worked.

## It's not just a brain with motors

Here's the first thing that trips up software engineers. It's tempting to picture embodied AI as a brain in a jar that we've wired up to some motors: take the model, give it a chassis, done. The field's own name pushes back. The word *embodied* comes from a decades-old idea in robotics and cognitive science: intelligence is not a pure computation that happens in a head and then gets piped out to a body. The body is part of the intelligence.

The cleanest illustration is a machine called a [passive dynamic walker](https://journals.sagepub.com/doi/10.1177/027836499000900206). In 1990 Tad McGeer built a pair of legs that walk down a gentle slope with a convincing human gait and no motors, no sensors, and no controller at all. Gravity and the mechanics of the limbs do the walking; the "control" is baked into the shape. Roboticists call this morphological computation: the physical body, its geometry, its springiness, its materials, does work that a controller would otherwise have to do in software. A soft gripper that conforms around an odd-shaped object isn't running a grasp-planning algorithm; its squishiness *is* the algorithm. An octopus arm solves much of its own motion in the muscle, not the brain.

Rodney Brooks made the radical version of this argument in a 1991 paper bluntly titled ["Intelligence without representation"](https://people.csail.mit.edu/brooks/papers/representation.pdf). His insect-like robots kept almost no internal model of the world; they reacted to it directly through tight loops of sensing and acting, and his slogan (from the companion paper ["Elephants Don't Play Chess"](https://people.csail.mit.edu/brooks/papers/elephants.pdf)) was that "the world is its own best model." Rolf Pfeifer and Josh Bongard wrote the book on the idea in 2006: *[How the Body Shapes the Way We Think](https://direct.mit.edu/books/book/2035/How-the-Body-Shapes-the-Way-We-ThinkA-New-View-of)*.

For a software engineer the practical upshot is concrete: you can't treat the body as a deployment detail. A policy trained on one robot often won't transfer to a differently-shaped one. The choice of gripper, the compliance of a joint, the placement of a camera, all change what the software has to compute and what it even can. Brain and body are co-designed. That's the part "an LLM with motors" misses.

(Whether intelligence *requires* a body at all is a genuinely live debate, not a settled fact. A January 2026 USC preprint, ["Intelligence Requires Grounding But Not Embodiment,"](https://arxiv.org/abs/2601.17588) argues that what matters is grounding, linking abstract symbols to real-world referents, and that grounding doesn't strictly need a body. You don't have to resolve the philosophy to follow the engineering, but the embodiment hypothesis is contested.)

## Why folding laundry is harder than passing the bar

Back to the gap from the opening. We have AI that writes passable code, drafts legal arguments, and scores well on graduate exams. We don't have AI that can reliably fold a towel, plug in a USB cable, or pick up a sock. The chatbot got the PhD before it got the toddler.

This is old news to roboticists. Hans Moravec wrote it down in 1988 (*[Mind Children](https://www.hup.harvard.edu/books/9780674576186)*): it's comparatively easy to get computers to do well on intelligence tests or play checkers, and very hard to give them the perception and mobility of a one-year-old. Steven Pinker put it more bluntly in 1994: the main lesson of decades of AI research is that the hard problems are easy and the easy problems are hard.

The usual explanation is evolutionary. Abstract reasoning is a few thousand years old and runs slowly even in humans, so it was never heavily optimized, which paradoxically makes it easy to reverse-engineer. Perception and motor control are a billion years old, baked deep into the nervous system, and run so well we never notice them, which is exactly why they're so hard to rebuild. You're a world-class expert at grasping things and you have no idea how you do it.

([Moravec's paradox](https://en.wikipedia.org/wiki/Moravec%27s_paradox) is a heuristic observation, not a proven law. Critics note it has never been rigorously tested and doesn't predict well which specific problems AI will find hard. Useful framing, not gospel.)

There's a second reason embodied AI is hard, and it's about how you build that `decide` box. The field has tried three broad approaches, and in 2026 it uses all three, often in the same machine.

The **classical** approach, sometimes called good-old-fashioned robotics, builds the loop as a pipeline of hand-engineered modules: perception turns pixels into a model of the world, a planner reasons over that model, a controller turns the plan into motion. It's brittle in open-ended environments, because every module feeds the next and small errors compound down the line. But here's the part the hype skips: it's precise, predictable, and it's how the most reliable robots in the world actually work. Boston Dynamics' famous parkour-and-backflip Atlas videos were not learned end-to-end; they ran on [model-predictive control and trajectory optimization](https://bostondynamics.com/blog/picking-up-momentum/), classical control math that plans motion against a physics model of the robot. A Waymo doesn't drive with one big neural net either; it's a modular stack of perception, prediction, planning, and control, with machine learning inside each module and decades of classical robotics (mapping, sensor fusion, state estimation) holding it together.

The **reactive** approach is Brooks's style from the section above: skip the world model, wire sensing straight to action.

The **end-to-end learning** approach is the new one, and it's why the field caught fire: one neural network maps sensors straight to motor commands, trained from data instead of hand-designed. It's the same recipe that made ChatGPT work, pointed at robots.

```
Classical (sense-plan-act): a relay race of hand-built modules
  camera ──▶ [perception] ──▶ [world model] ──▶ [planner] ──▶ [controller] ──▶ motors

End-to-end learning (the modern bet): one trained net does the whole thing
  camera + "fold the towel" ──▶ [   one neural network   ] ──▶ motors

In practice, most shipped robots are a hybrid of the two.
```

The interesting question is which approach wins where. There's a famous essay in AI by Richard Sutton, ["The Bitter Lesson"](http://www.incompleteideas.net/IncIdeas/BitterLesson.html) (2019): over the long run, general methods that scale with computation and learning beat methods that bake in human knowledge, because compute keeps getting cheaper. It's been right about chess, Go, vision, and language. Robotics is where it's most contested, because the most reliable shipped systems still lean on hand-engineered control, and the physical data needed to feed the learning is brutally scarce (the back half of this post is about that scarcity). The field's current bet is that learning will eat more and more of the stack over time. Even Boston Dynamics, the high temple of classical control, has been bolting reinforcement learning and foundation models onto the electric Atlas through a string of partnerships: [Toyota Research Institute in late 2024](https://bostondynamics.com/news/boston-dynamics-toyota-research-institute-announce-partnership-to-advance-robotics-research/), [the RAI Institute in early 2025](https://techcrunch.com/2025/02/05/boston-dynamics-joins-forces-with-its-former-ceo-to-speed-the-learning-of-its-atlas-humanoid-robot/), [Google DeepMind at the start of 2026](https://bostondynamics.com/blog/boston-dynamics-google-deepmind-form-new-ai-partnership/). But it's adding learning on top of classical control, not throwing the control math away. Hold both ideas at once and you understand the field.

## Embodied AI is already everywhere (it just isn't shaped like a person)

Read the popular coverage and you'd think embodied AI means humanoid robots. It mostly doesn't. The most successful embodied AI in the world is already deployed, already reliable, and already making money, and almost none of it is humanoid.

The clearest example is the self-driving car. Waymo gave [around 15 million paid, fully driverless rides in 2025](https://waymo.com/blog/2025/12/2025-year-in-review/), more than 20 million over its lifetime, with no human in the driver's seat, across eleven US metros, and reached [about half a million rides a week](https://techcrunch.com/2026/03/27/waymo-skyrocketing-ridership-in-one-chart/) by spring 2026. By any reasonable definition that's an embodied AI: it perceives a chaotic real environment and acts in it at speed, with lives on the line. It's the most consequential embodied-AI deployment on earth, and it happens to be car-shaped.

It has company. Amazon [passed a million mobile robots](https://www.aboutamazon.com/news/operations/amazon-million-robots-ai-foundation-model) across its warehouses in 2025, coordinated by a fleet-level foundation model called DeepFleet, with robotics and automation involved in roughly three of every four packages it ships. The world's factories ran [about 4.66 million industrial robot arms in 2024](https://ifr.org/ifr-press-releases/news/global-robot-demand-in-factories-doubles-over-10-years) (most pre-programmed rather than "intelligent," but they're the canonical embodied machines, and learning is creeping in). Zipline has flown [more than 2 million autonomous deliveries](https://www.zipline.com/newsroom/zipline-surpasses-2-million-deliveries-raises-more-than-600m-to-power-next-phase-of-growth-and-expands-operations-to-houston-and-phoenix) (medical supplies at first, retail goods increasingly); Starship has done [more than 10 million sidewalk deliveries](https://www.starship.xyz/press/autonomous-delivery-moves-into-the-mainstream-as-starship-technologies-passes-10-million-deliveries/) with a fleet of thousands of small wheeled robots. Embodied intelligence, in other words, isn't a someday technology. It's a deployed, multi-billion-dollar reality. The successful versions just picked narrow, structured problems instead of trying to be a person.

That's the key to the whole zoo of robot shapes. Difficulty scales almost perfectly with how unstructured the environment is and how much the body has to do at once.

| Embodiment | Environment | Why it's easy / hard | Where it is in 2026 |
|---|---|---|---|
| Robot arm (fixed base) | bolted down, known workspace | repeatable, mature control / can't generalize to novel objects | ~4.66M deployed worldwide |
| Mobile base / warehouse robot | flat, mapped floor | 2D navigation is solved / fleet coordination at density is hard | Amazon at 1M+ units |
| Quadruped (Spot) | rough terrain, stairs | four legs make balance easy / payload and battery are tight | shipped, inspection and security |
| Drone | open 3D airspace | no ground contact, fixed routes work / payload, weather, regulation | Zipline at 2M+ deliveries |
| Autonomous vehicle | road network with rules | constrained problem / open-world long-tail safety at speed | Waymo, fully driverless at scale |
| Humanoid | human spaces, open tasks | one body for everything / it bites off *everything* at once | mostly pilots and demos |
| Soft robot | contact with fragile things | compliant and safe / precise control of a squishy body is hard | mostly research |

The humanoid sits at the far end on purpose. It takes on bipedal balance, dexterous hands, and open-ended tasks all at once, in spaces built for people. That generality is the dream, one robot that uses our tools, our stairs, our kitchens, and it's exactly why humanoids are still overwhelmingly pilots and demos while the boring shapes quietly run the economy.

## How the decide box gets built

So what goes in the `decide` box? It depends on the body and the job, and the field splits cleanly along those lines.

**Locomotion (walking, running, getting back up after a shove) is mostly reinforcement learning in simulation.** You let a simulated robot practice in a physics engine millions of times against a simple reward, "stay upright and move forward," which is feasible because simulation runs far faster than real time and a simulated robot that falls over costs nothing. The trick that makes it survive contact with reality is **domain randomization**: jitter the gravity, friction, motor strength, and sensor noise, and shove the robot at random, every single episode, so the real world looks like just one more variation the policy has already handled. Policies trained this way in [NVIDIA's Isaac Lab](https://isaac-sim.github.io/IsaacLab/main/index.html) now walk on real Unitree and Boston Dynamics hardware with no real-world fine-tuning. The lineage traces back to ANYmal's learned locomotion ([Hwangbo et al., *Science Robotics* 2019](https://arxiv.org/abs/1901.08652)).

**Driving and navigation are the classical-plus-learned hybrids** from earlier: mapping, planning, and control doing the safety-critical work, with learned components for perception and prediction. Waymo even has an end-to-end model ([EMMA](https://waymo.com/blog/2024/10/introducing-emma/)), but it ships as research, not as the production driver.

**Manipulation, using hands to do things, is the hard, unsolved, exciting one,** and it's where the LLM-style approach has taken over. The workhorse that ships today is **imitation learning**: record a human doing the task, then train a network with supervised learning to copy what the human did given the same camera view. The label is "what the human's hand did next." It's literally `model.fit(observations, human_actions)`. The standard recipe is **ACT** (Action Chunking with Transformers), from the 2023 [ALOHA project](https://tonyzhaozh.github.io/aloha/), which hit 80 to 90% success on delicate two-handed tasks from about 50 demonstrations and ten minutes of data. **[Diffusion Policy](https://diffusion-policy.cs.columbia.edu/)** (also 2023) does the same job with a diffusion model and handles the "several right answers" problem better.

Imitation's fatal weakness has a name: **compounding error**. The robot is only trained on states a competent human visited, so the first time it drifts slightly off course, it's in a state it never saw, where its predictions are garbage, which pushes it further off course. The next idea (action chunking, below) helps but doesn't cure it.

### The VLA: a language model that outputs motor commands

The frontier on top of imitation is the **Vision-Language-Action model**, or VLA, and this is the part that looks most like the LLM world. Start with a **vision-language model** (VLM), a transformer that takes images and text as input; that's the thing that lets Claude or Gemini look at a screenshot and describe it. A VLA takes a pretrained VLM and bolts an **action head** on the end, so instead of emitting word tokens it emits robot actions. Same transformer machinery, same "predict the next thing" loop, different output vocabulary. The reason it works is that the VLM arrives already understanding what a "towel" is and what "fold" means from internet-scale text and images, so the robot doesn't have to learn the entire concept of the world from its few thousand demonstrations. It only has to learn the extra skill of moving a body.

That's also the answer to "why did this field get hot exactly now." The LLM recipe generalized: take a big transformer, pre-train it on a mountain of data, point it at robots, and the output tokens become motor commands. Physical Intelligence's pi-0 (October 2024) and NVIDIA's GR00T N1 (March 2025) brought that foundation-model recipe to robots. Jim Fan at NVIDIA frames the goalpost as a ["physical Turing test"](https://inferencebysequoia.substack.com/p/the-physical-turing-test-jim-fan): forget whether a machine can chat like a human, can it cook your dinner and clean your apartment so well you can't tell a robot did it? Nobody's close. But for the first time the approach feels like a known quantity being scaled rather than a research mystery, and that shift is what's pulling in the money and the people.

Two design decisions split the whole VLA field.

**How do you spell an action?** There are two dialects:

```python
# Autoregressive (RT-2, OpenVLA): emit actions like words, one token at a time
# Each action value is quantized into one of 256 discrete "bins"
tokens = []
for _ in range(chunk_len):
    tokens.append(argmax(model(obs, instruction, tokens)))
joints = detokenize(tokens)            # discrete, simple, reuses the LLM stack as-is

# Flow matching (pi-0, GR00T, SmolVLA): sculpt a smooth trajectory from noise
# Start from random noise, iteratively bend it toward a valid motion
a = random_noise(chunk_len, n_joints)
for t in range(num_steps):             # often just a handful of steps
    a += model.velocity(a, obs, instruction) * dt
joints = a                             # continuous, smooth, good for fast control
```

The autoregressive style treats motor commands like text: chop each action value into 256 buckets and predict bucket numbers. Dead simple, reuses the entire language-model stack untouched. The downside is that smooth physical motion doesn't love being quantized into 256 steps. The other style, **diffusion** or its faster cousin **flow matching**, starts from random noise and iteratively reshapes it into a valid action sequence, the same way image generators turn noise into a picture. It produces smooth, high-frequency motion and naturally represents the fact that there are often several correct ways to do something. Most of the strongest open models in 2025 use flow matching (Figure's closed Helix is a notable holdout, using plain regression for its fast loop).

**Action chunking** is the other near-universal trick. Instead of predicting one motor command, looking again, predicting the next, the model predicts a chunk: roughly a second of future motion (say 50 steps) in one forward pass, then re-plans. It's the difference between reading a whole sentence ahead versus one word at a time. This matters because the big VLM "brain" is slow (it can only think a few times a second) but the motors need commands at 50 to 200Hz to move smoothly. Chunking decouples the two. The fanciest version is the **dual-system** design, named after Kahneman's *Thinking, Fast and Slow*: a slow VLM plans at a few Hz (System 2), feeding a small fast network that actually drives the joints at over 100Hz (System 1). Figure's Helix (200Hz) and NVIDIA's GR00T (120Hz) both work this way.

Here's the landscape of VLA models people actually name, with dates and openness, because this is the part that's easy to get wrong:

| Model | Who | When | Action style | Open weights? |
|---|---|---|---|---|
| [RT-1](https://arxiv.org/abs/2212.06817) | Google | Dec 2022 | discrete tokens | predates the "VLA" label |
| [RT-2](https://arxiv.org/abs/2307.15818) | Google DeepMind | Jul 2023 | discrete tokens | closed |
| [Octo](https://octo-models.github.io/) | UC Berkeley et al. | May 2024 | diffusion | open |
| [OpenVLA (7B)](https://arxiv.org/abs/2406.09246) | Stanford et al. | Jun 2024 | discrete tokens | open |
| [pi-0 (π0)](https://www.pi.website/blog/pi0) | Physical Intelligence | Oct 2024 | flow matching | open (via [`openpi`](https://github.com/Physical-Intelligence/openpi)) |
| [Figure Helix](https://www.figure.ai/news/helix) | Figure AI | Feb 2025 | dual-system, regression | closed |
| [Gemini Robotics](https://deepmind.google/blog/gemini-robotics-brings-ai-into-the-physical-world/) | Google DeepMind | Mar 2025 | not disclosed | closed (partners) |
| [GR00T N1](https://arxiv.org/abs/2503.14734) | NVIDIA | Mar 2025 | dual-system, flow | open |
| [pi-0.5](https://www.pi.website/blog/pi05) | Physical Intelligence | Apr 2025 | hybrid | open (Sept 2025) |
| [GR00T N1.5 (3B)](https://huggingface.co/nvidia/GR00T-N1.5-3B) | NVIDIA | May 2025 | dual-system, flow | open |
| [SmolVLA (~450M)](https://huggingface.co/blog/smolvla) | Hugging Face | Jun 2025 | flow matching | open |
| [π\*0.6](https://arxiv.org/abs/2511.14759) | Physical Intelligence | Nov 2025 | flow matching + RL | closed |
| [GR00T N1.6 (3B)](https://research.nvidia.com/labs/gear/gr00t-n1_6/) | NVIDIA | Dec 2025 | dual-system, flow | open |
| [pi-0.7 (π0.7)](https://www.pi.website/blog/pi07) | Physical Intelligence | Apr 2026 | flow matching | closed |

Two things to read off that table. First, the open/closed split mirrors the LLM world almost exactly: OpenVLA, pi-0, GR00T, and SmolVLA are the Llama-style open models you can download and run, while RT-2, Gemini Robotics, and Helix are the GPT-4-style closed ones you only get through a partnership. Second, look at the parameter counts when listed. OpenVLA is 7B and beat the 55B RT-2-X on its benchmarks. SmolVLA is 450M and runs on a MacBook. These are tiny next to frontier LLMs, and the reason is the thing the next section is about: there isn't enough data to train anything bigger usefully.

That table is a snapshot, and the snapshot moved fast. The past six months brought a wave the clean open-versus-closed reading already strains to hold. Physical Intelligence's pi-0.7 (April 2026) is the one to know: a single model that recombines skills it already has to handle tasks it was never trained on, including folding laundry on a robot type that saw no laundry data, at the level of a fine-tuned specialist. It's the closest thing yet to the compositional generalization that makes LLMs feel general, and like the RL-trained π*0.6 before it, it's closed; Physical Intelligence's open weights stop at pi-0.5. NVIDIA went the other way: GR00T N1.6 (December) added whole-body control, locomotion and manipulation in one policy, and the [early-access N1.7](https://huggingface.co/blog/nvidia/gr00t-n1-7) (April) swapped in a stronger reasoning backbone and finger-level dexterity, both open. Figure's [Helix 02](https://www.figure.ai/news/helix-02) (January 2026) folded walking, balance, and manipulation into one learned controller and slid a 1kHz whole-body layer underneath it, called System 0, that retired roughly 110,000 lines of hand-written C++. Google's Gemini Robotics grew an on-device version and a separate reasoning model, [ER 1.6](https://deepmind.google/models/gemini-robotics/gemini-robotics-er/). None of it changes the shape of this post; all of it confirms the pace.

### The methods, on one card

Across all three jobs (locomotion, navigation, manipulation), here's how the learning paradigms line up. Notice that every row is, at bottom, a different bet on where to get training data cheaply. That's not a coincidence; it's the rest of this post.

| Paradigm | Learns from | Needs a reward? | Where it is in 2026 |
|---|---|---|---|
| Behavior cloning / ACT | human teleop demos | no, it's supervised | ships, manipulation |
| Diffusion / flow policy | human teleop demos | no | ships, manipulation |
| RL + domain randomization | trial and error in sim | yes (easy for walking) | ships, locomotion |
| Cross-embodiment pre-train | many robots' pooled data | no | the base-model layer |
| Learning from human video | egocentric footage | no | emerging |
| World-model planning | predicted futures | varies | mostly research |

The last two are the frontier: learning from data the robot never generated. **World models** are learned simulators (a network that, given a state and an action, predicts the next state) so the robot can imagine outcomes or generate unlimited synthetic training data. Meta's [V-JEPA 2](https://ai.meta.com/blog/v-jepa-2-world-model-benchmarks/) (June 2025) is trained on over a million hours of internet video and does zero-shot pick-and-place by predicting futures. Today this family mostly powers research and synthetic-data pipelines rather than shipping autonomy.

## The data wall

This is the real story. Everything above is downstream of one brutal fact: there is no internet of robot actions.

LLMs work because the open web handed us tens of trillions of tokens of text for free, already labeled with the next word. Vision models work because there are billions of image-caption pairs lying around. Robots get none of this. Every single training example, every "given this camera view, the hand moved like *this*," has to be physically produced by a real robot or a real person, one at a time, in real time. The numbers aren't close:

| Data | Roughly how much exists |
|---|---|
| Text (trains a frontier LLM) | ~30,000,000,000,000 tokens |
| Image-text pairs (trains vision models) | ~5,850,000,000 |
| Robot action episodes (largest open dataset) | ~1,000,000 |

A million episodes sounds like a lot until you put it next to tens of trillions. The algorithms in this post are mostly borrowed from the LLM world and are ready and waiting; the GPT-3-scale dataset to feed them doesn't exist yet. Robotics in 2026 is roughly where natural-language processing was before GPT-2: the architecture is solved, the data is the wall. (The classical-control systems, Waymo and the parkour Atlas, partly sidestep this by not learning end-to-end in the first place, which is a big reason they shipped first.)

So the learning side of the field is a set of strategies for manufacturing data:

**Teleoperation.** A human puppets the robot and the robot records the result. The clever low-cost version is ALOHA: two cheap "leader" arms wired to two "follower" arms, so when you move the leaders by hand, the followers mimic and the whole motion gets logged as a demonstration. The full rig costs under $20k, far below the price of traditional research-grade bimanual setups. High quality, but it costs one human's full attention per robot, in real time. [DROID](https://droid-dataset.github.io/), a major open dataset, took 50 collectors across 13 institutions twelve months to gather 76,000 trajectories.

**Skip the robot entirely.** The [UMI](https://umi-gripper.github.io/) project is a handheld 3D-printed gripper with a GoPro strapped on. You collect demonstrations by just doing tasks with the gripper in your hand, no robot needed, then transfer the learned skill to a real arm afterward. A data-collection rig that costs a few hundred dollars (a 3D-printed gripper plus a GoPro) instead of a $20k teleoperation setup.

**Pool everyone's data.** [Open X-Embodiment](https://robotics-transformer-x.github.io/) is a federation: 60 datasets from 34 labs, pooled into one pile of a million-plus trajectories across 22 different robot types. A model pre-trained on the pile transfers to each individual robot far better than that robot's own data could manage alone. This was robotics' "ImageNet moment."

**Use human video.** Datasets like [Ego4D](https://ego4d-data.org/) (thousands of hours of first-person footage of people doing ordinary things) have no robot action labels, but they teach a model how hands approach objects and how tasks unfold, cheaply and abundantly. Georgia Tech's [EgoMimic](https://egomimic.github.io/) project, which records first-person video through Meta's Aria camera glasses, found that an extra hour of human footage improved task performance more than an extra hour of robot teleoperation, and the footage is far cheaper to collect.

**Manufacture it.** Two flavors. Drop a handful of real demos into a physics engine and perturb them into new variations: NVIDIA's [DexMimicGen](https://developer.nvidia.com/blog/building-a-synthetic-motion-generation-pipeline-for-humanoid-robot-learning/) spun a small seed set into 780,000 simulated trajectories, about 6,500 hours, in 11 hours of compute. Or skip the physics engine and have a fine-tuned video-generation model dream the data: the GR00T N1 team expanded 88 hours of real teleoperation into 827 hours of these ["neural trajectories"](https://github.com/NVIDIA/GR00T-Dreams). NVIDIA's marketing reports manipulation success-rate gains as high as 40% from mixing synthetic data in; the controlled ablations in the GR00T N1 paper are more modest, in the single digits. Cheap and fast, but you pay the sim-to-real tax: neither the simulator nor the video model is quite reality.

The modern training recipe stacks these into a pyramid, a little expensive real data on top, a lot of cheap synthetic and human-video data underneath:

```
        ▲          real robot demos          (scarce, expensive, gold standard)
      ▲ ▲ ▲      simulation / synthetic       (cheap, pays a sim-to-real tax)
    ▲ ▲ ▲ ▲ ▲   passive human video           (abundant, no action labels)
```

One non-obvious finding from a [late-2024 scaling-laws study](https://data-scaling-laws.github.io/) out of Tsinghua: for generalization, the *diversity* of environments and objects matters far more than the raw *number* of demos. Fifty demonstrations all in one environment generalize badly; fifty demonstrations in each of thirty-two different environments generalize well. Collecting more of the same teaches the model almost nothing new. This is why everyone is so obsessed with breadth of data rather than volume, and why "go collect demos in a thousand different homes" is a real business plan and not a joke.

## What the robots are made of

The hardware discourse in 2026 is mostly humanoid hype, so two things are worth pinning down: what a robot physically is, and how much of the humanoid story is real.

Structurally, a robot is three layers: a body (sensors and actuators), a brain (the policy), and an onboard computer to run the brain.

- **Sensors** are the inputs: RGB cameras for color, depth cameras or LiDAR for 3D shape and distance, an IMU for balance and orientation (the same accelerometer-plus-gyro your phone has), force-torque sensors for how hard it's pushing, joint encoders for proprioception (where its own limbs are), and increasingly fine **tactile** sensors in the fingertips. Touch is the current frontier; [Figure's latest hand](https://www.figure.ai/news/introducing-figure-03) reportedly senses forces as small as three grams.
- **Actuators** are the muscles. Today's humanoids are almost all electric-motor-driven (the old hydraulic Atlas was [retired in 2024](https://bostondynamics.com/blog/electric-new-era-for-atlas/)), which is cleaner and more controllable but power-hungry, hence the two-to-five-hour battery lives that quietly cap most deployments.
- **Onboard compute** is the constraint people forget. The brain has to run on a battery-powered body, not in a datacenter. The de-facto 2026 chip for the flagship humanoids (Atlas, Digit, Figure; Tesla rolls its own silicon) is NVIDIA's [Jetson Thor](https://www.therobotreport.com/nvidia-jetson-thor-brings-2k-teraflops-of-ai-compute-to-robots/), available August 2025: 2,070 FP4 TFLOPS in a 40 to 130W power envelope, with a dev kit at $3,499. That power budget, far below a datacenter GPU, is a real ceiling on how big the onboard model can be.

The end-effector deserves its own note because it's where the difficulty concentrates. A simple parallel-jaw gripper has one or two degrees of freedom: cheap and reliable, the industrial default. A human-like dexterous hand has twenty-plus degrees of freedom and dense tactile sensing, which makes it far more capable and far harder to control. Nobody has really cracked dexterous manipulation yet.

As for the humanoids themselves, the single most useful distinction is **shipped and doing real work** versus **demoed and promised**. "In production" almost never means "autonomously doing a job." Usually it means "in a factory collecting training data or running a narrow scripted pilot."

| Platform | Maker | Status, mid-2026 | Reality check |
|---|---|---|---|
| [Spot](https://bostondynamics.com/products/spot/) (quadruped) | Boston Dynamics | shipped, working | ~$75k; industrial inspection; years in the field |
| [Digit](https://www.agilityrobotics.com/content/digit-moves-over-100k-totes) | Agility Robotics | shipped, working | rare real humanoid deployment: moving totes at a GXO warehouse |
| [Atlas (electric)](https://bostondynamics.com/blog/boston-dynamics-unveils-new-atlas-robot-to-revolutionize-industry/) | Boston Dynamics | early pilot | entire 2026 run committed to just Hyundai and Google DeepMind |
| Apollo | Apptronik | pilot | Mercedes-Benz and GXO pilot zones; [raised $935M+](https://www.cnbc.com/2026/02/11/apptronik-raises-520-million-at-5-billion-valuation-for-apollo-robot.html) |
| Figure 03 | Figure AI | announced, partner pilots | home robot built around the Helix model; no consumer pre-orders or sales yet |
| [Neo](https://www.therobotreport.com/1x-announces-pre-order-launch-neo-humanoid-robot/) | 1X | pre-order | $20k or $499/mo; leans heavily on remote human teleoperation |
| Optimus | Tesla | demoed, delayed | reveal slipped to ~mid-2026; [admitted to do no useful work yet](https://electrek.co/2026/01/28/musk-admits-no-optimus-robots-are-doing-useful-work-at-tesla-after-claiming-otherwise/) |
| [G1 / R1](https://shop.unitree.com/products/unitree-g1) | Unitree | sold (research) | the price-collapse story: G1 from $16k, R1 from $5,900 |

The honest summary: among humanoids, Agility's Digit moving totes is close to the only example of a robot doing a paid job somewhat autonomously. Everything else is a pilot, a pre-order, or a demo, and a striking number of the slick autonomy demos are secretly teleoperated. 1X's Neo openly ships with an ["Expert Mode"](https://www.humanoidsdaily.com/feed/1x-ceo-details-neo-s-two-modes-and-defends-teleoperation-as-more-secure-than-a-cleaner) where a remote human in a VR headset takes over for anything the robot can't handle, which is most things, and which raises an obvious privacy question about a stranger seeing through your home robot's cameras.

## What's actually hard

The demos look incredible. The honest state of the field is more sober, and the unifying reason is arithmetic.

A multi-step physical task only succeeds if every step succeeds, and probabilities multiply. If each step works 95% of the time, a ten-step chore works `0.95^10`, which is about 60%. This is the whole problem in one table:

| Per-step success | 5-step task | 10-step task | 20-step task |
|---|---|---|---|
| 90% | 59% | 35% | 12% |
| 95% | 77% | 60% | 36% |
| 99% | 95% | 90% | 82% |
| 99.99% | ~100% | ~100% | ~100% |

A robot that nails individual motions 95% of the time, which is genuinely impressive, still fails a routine chore four times out of ten. The bar for leaving a robot unsupervised in a home is closer to the bottom row, around 99.99% per step, and almost nothing is there. Estimates for crossing that gap range wildly, from the late 2020s at the optimistic end (some robotics founders) to the mid or late 2030s (Goldman Sachs, [Morgan Stanley](https://www.morganstanley.com/insights/articles/humanoid-robot-market-5-trillion-by-2050)), and the error bars are enormous.

Even the flagship makes the point. In May 2026 Waymo, the most reliable embodied AI on the road, [suspended all freeway rides](https://techcrunch.com/2026/05/21/waymo-halts-freeway-rides-after-robotaxis-struggle-in-construction-zones/) (offered in San Francisco, Los Angeles, Phoenix, and Miami) after its cars struggled in construction zones, and paused service in Atlanta, Dallas, Houston, and San Antonio during flooding, after one robotaxi drove into floodwater and was swept away, triggering a recall of nearly 3,800 vehicles. The everyday drive was solved years ago; the long tail, a sudden lane closure or a flooded intersection, is the part that keeps even a half-million-rides-a-week system from being left fully alone. It's the same wall the kitchen robot hits, at 65 miles an hour.

The brittleness underneath those numbers is worse than the averages suggest. A 2025 benchmark called [LIBERO-Plus](https://arxiv.org/abs/2510.13626) found VLAs scoring near 95% would collapse below 30% under a simple camera-angle shift, and in some cases were ignoring the language instruction entirely and just running on visual muscle memory.

And there's no good way to even measure progress, because **there is no MMLU for robots**. You can't run a physical robot on a benchmark a million times. Evaluations are slow, expensive, and wildly non-reproducible: the same policy on the same task can score anywhere from 0% to 100% depending on who set it up, the lighting, and how the objects were placed. A 2025 effort ([RoboArena](https://arxiv.org/abs/2506.18123)) tries to fix this with distributed, double-blind, real-robot evaluation across institutions, which tells you how unsolved the basics are. When you can't measure reliably, you can't tell which of two models is better, and the whole feedback loop that drove LLM progress sputters.

Berkeley's Ken Goldberg [argued in *Science Robotics*](https://www.science.org/doi/10.1126/scirobotics.aea7390) (August 2025) that the root cause of all of this is, again, data scarcity, which he frames as a hundred-thousand-year data gap: there's an internet-scale corpus of human-written text for an LLM to learn from, and nothing remotely comparable for physical action. The bottleneck is not cleverness. It's that the data doesn't exist yet, and producing it is slow physical labor.

None of this means the field is stuck. It means the headline demos are the ceiling of cherry-picked conditions, not the floor of reliable behavior, and the interesting work is the unglamorous grind of closing that gap. Which is exactly where a software engineer turns out to be useful.

## What a software engineer can actually do

If you're reading this as someone who writes software for a living: most of the work in embodied AI right now is software, and a lot of it is software you already know how to write.

The mechanical engineering is largely solved or commoditized. The control theory is a specialist's job. But the field is bottlenecked on data and infrastructure: collecting demonstrations, building pipelines to clean terabytes of sensor logs, running distributed training, standing up evaluation harnesses, serving models on edge hardware, building teleoperation tooling, building and speeding up simulators. Look at actual job postings from Serve Robotics, Amazon's robotics teams, Waymo, or Skild AI, and a large fraction are titled "ML Infrastructure Engineer" or "Software Engineer, Training & Infrastructure." That's a data-pipelines-and-distributed-systems job that happens to point at robots.

Be honest about the boundary, though: the genuinely robotics-specific layer, the real-time control loops written in C++ to hit millisecond-deterministic timing (Python can't, because of the GIL and garbage collection), the kinematics, the hardware integration, does *not* transfer from general software work and takes real study. The claim isn't "robotics is just software." It's that the cloud, data, and ML-infra half of robotics is conventional software work, and that half is hiring.

The on-ramp is unusually gentle now because Hugging Face built **[LeRobot](https://github.com/huggingface/lerobot)**, which is to robot learning roughly what their `transformers` library is to NLP: one `pip install` gives you pretrained policies, datasets, and a standard data format. You start in Python, not soldering. Here's the ladder, easiest first, most of it free and hardware-free:

| Tier | What you do | Cost | Hardware | Skill you already have |
|---|---|---|---|---|
| 0 | Hugging Face Robotics Course; run a pretrained policy in sim | free | none | Python, PyTorch |
| 1 | Load and explore Open X-Embodiment / DROID datasets | free | none | data wrangling |
| 2 | Train a policy in simulation (MuJoCo Playground, Isaac Lab) | free | a GPU helps | training loops, infra |
| 3 | Build an SO-101 arm, collect your own demos, fine-tune | ~$120 to $230 | a 3D-printed arm | the full loop |

**Tier 0 and 1** need nothing but a laptop. The free [Hugging Face Robotics Course](https://huggingface.co/learn/robotics-course) walks you up from zero, entirely in simulation; the early units are live, with the imitation-learning and RL units still rolling out as of mid-2026. A robot dataset, it turns out, is just a normal dataset:

```python
# pip install lerobot
from lerobot.datasets import LeRobotDataset

ds = LeRobotDataset("lerobot/droid_100")      # a slice of DROID, a real teleop dataset
frame = ds[0]
print(frame["observation.images.exterior_image_1_left"].shape)  # a camera frame: just a tensor
print(frame["action"])                        # the joint commands a human demonstrated

# training is a normal PyTorch loop with an action-chunking model:
#   lerobot-train --policy.type=act --dataset.repo_id=lerobot/droid_100 ...
```

That's the whole conceptual leap. A "policy" is a neural network whose inputs are camera frames and joint angles and whose outputs are the next joint movements. Training it is an ordinary supervised-learning loop. The eval harness measures task success instead of classification accuracy. If you've trained any model, you can train this.

**Tier 2** is simulation, and this is where game-engine and graphics people have a real edge, for any embodiment, not just arms. The simulators are [MuJoCo](https://github.com/google-deepmind/mujoco) (now maintained by Google DeepMind, with [`MuJoCo Playground`](https://github.com/google-deepmind/mujoco_playground) as the friendly entry point), NVIDIA's Isaac Lab (the heavy industrial-strength option, GPU-parallel RL), and the newer all-Python [Genesis](https://github.com/Genesis-Embodied-AI/Genesis) (led by a CMU PhD student as part of a 20-plus-lab collaboration, now also the startup Genesis AI; treat its [eye-popping speed claims](https://stoneztao.substack.com/p/the-new-hyped-genesis-simulator-is) as vendor marketing until you benchmark them yourself). You can train a policy on thousands of simulated robots in parallel on a single GPU, then transfer it to reality. No hardware, no broken servos.

**Tier 3** is when you want a real robot on your desk without a lab budget. The **[SO-101](https://github.com/TheRobotStudio/SO-ARM100)** is a 3D-printable robot arm, designed for LeRobot, that costs roughly $120 for a single arm or $230 for the leader-follower teleoperation pair. You print the parts, buy a handful of servos, assemble it, puppet it by hand to collect your own demonstrations, and fine-tune a policy on data you generated. The exact same code that ran in simulation runs on the physical arm. It's a Raspberry-Pi-grade weekend project that happens to be a real robot.

The map from what you already do to what the field needs:

| Your software skill | Where it lands in robotics |
|---|---|
| Data pipelines / ETL | ingesting and cleaning terabytes of sensor logs |
| Distributed training infra | training policies across many GPUs |
| CI and test harnesses | evaluation harnesses (a wide-open problem, see above) |
| MLOps / model serving | running inference onboard a power-constrained robot |
| Game engines / graphics | building and speeding up simulators |
| Web / frontend | teleoperation interfaces for data collection |
| Embedded / edge | deploying models to Jetson and Raspberry Pi |

If you want a concrete first month: spend week one installing LeRobot and running a pretrained policy in sim from the course. Week two, load Open X-Embodiment and DROID and get comfortable with the data format. Week three, fine-tune a small ACT or diffusion policy in simulation on one GPU. Week four, either send a real pull request to LeRobot (dataset ports, docs, and sim environments are friendly first contributions and the Discord is active) or order the parts for an SO-101 and teleoperate your way to a dataset of your own. By the end you'll have done end-to-end what the labs do at scale, which is more hands-on robotics than most CS graduates ever get.

The honest pitch is this. Embodied intelligence in 2026 is a field with solved-enough hardware, borrowed-and-ready algorithms, and a gaping hole where the data and the infrastructure to handle it should be. That hole is software. You don't need to become a roboticist to help dig it out. You need to be the engineer who's good at data pipelines, training infrastructure, and evaluation, and who's willing to point those skills at a problem where the test set is the physical world.

## Where to go deeper

A reading order, roughly easiest to hardest, all primary sources:

- [The Hugging Face Robotics Course](https://huggingface.co/learn/robotics-course) and the [LeRobot repo](https://github.com/huggingface/lerobot). Start here. It's the `transformers`-library moment for robotics, and it's free.
- [Jim Fan on the Physical Turing Test](https://inferencebysequoia.substack.com/p/the-physical-turing-test-jim-fan) (Sequoia AI Ascent, 2025). The clearest short framing of why this is the successor problem to LLMs, and why data is the wall.
- [Rodney Brooks, "Intelligence without representation"](https://people.csail.mit.edu/brooks/papers/representation.pdf) (1991). The argument that intelligence can come from tight sensor-action loops with no central world model. The intellectual root of "embodied."
- [RT-2](https://arxiv.org/abs/2307.15818) (Google DeepMind, 2023). The paper that coined "vision-language-action" and showed an internet-pretrained VLM could drive a robot.
- [OpenVLA](https://arxiv.org/abs/2406.09246) (Stanford et al., 2024). The open 7B model that beat the closed 55B one. The cleanest open VLA to read end to end.
- [pi-0](https://www.pi.website/blog/pi0) (Physical Intelligence, 2024). The flow-matching generalist policy, with weights you can actually download.
- [Open X-Embodiment](https://robotics-transformer-x.github.io/) (2023). The "pool everyone's data" paper. This is the data story in one place.
- [ALOHA](https://tonyzhaozh.github.io/aloha/) and [Diffusion Policy](https://diffusion-policy.cs.columbia.edu/) (2023). The two imitation-learning methods everything else builds on, both with code and video.
- [Richard Sutton, "The Bitter Lesson"](http://www.incompleteideas.net/IncIdeas/BitterLesson.html) (2019). Why learning tends to beat hand-engineering, and the essay the whole control-versus-learning debate argues with.
- *[How the Body Shapes the Way We Think](https://direct.mit.edu/books/book/2035/How-the-Body-Shapes-the-Way-We-ThinkA-New-View-of)* (Pfeifer & Bongard, MIT Press, 2006). Book-length case that the body is part of the intelligence, if the "embodied" idea grabbed you.
- [Ken Goldberg in *Science Robotics*](https://www.science.org/doi/10.1126/scirobotics.aea7390) (2025). The sober counterweight to the hype: why the bottleneck is data, and why that's an engineering problem, not a mystery.

And if you only do one thing, `pip install lerobot` and run the first notebook. The gap between reading about this field and touching it is one afternoon wide now, which was not true even two years ago.
