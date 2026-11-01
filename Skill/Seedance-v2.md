---
name: seedance-V2
description: Specialized video generation workflow using the Seedance 2.5 model for full-length continuous 30-second cinematic sequences. Handles both text-to-video and image-to-video pipelines with structured narrative pacing and pre-generation confirmation.
---

# Seedance 2.5 – 30s Video Generation Workflow

## Overview & Default Configuration

This skill guides the creation of high-quality, continuous 30-second videos using the Seedance 2.5 model. It focuses on single-take continuity and structured narrative progression.

- **Target Model:** `seedance_2.5` (specify explicitly in all requests)
- **Standard Duration:** 30 seconds (`duration: 30`)
- **Execution Mode:** Single continuous segment per request
- **Supported Aspect Ratios:** 21:9, 16:9, 4:3, 1:1, 3:4, 9:16
- **Maximum Videos per Response:** Up to 2 independent variations
- **Duration Exceptions:** If the user explicitly asks for a shorter runtime (e.g., 10s or 15s), adjust `duration` accordingly while keeping the single-call workflow.

---

## Narrative Structure (30-Second Arc)

To ensure visual consistency and prevent pacing degradation across the 30-second duration, structure every prompt around a three-act timeline:

1. **Act I: Opening (0–5s):** Establish environment, atmosphere, lighting, and primary subject.
2. **Act II: Development (5–20s):** Primary action sequence, escalating movement, dynamic camera paths, and evolving scene dynamics.
3. **Act III: Resolution (20–30s):** Climax of the action, narrative payoff, and stabilized closing composition.

Include explicit details for framing, lens characteristics, lighting temperature, color grading, and physical motion.

---

## Workflow Stages

### Step 1: Concept & Prompt Preparation
- Translate user requirements into a unified 30-second cinematic scenario using the three-act structure.
- Determine camera movements, lighting setup, stylistic palette, and negative constraints.

### Step 2: Specification Confirmation
Before initiating tool execution, present a concise specification summary to the user:

- **Model:** Seedance 2.5 (`seedance_2.5`)
- **Duration:** 30 seconds (single continuous take)
- **Aspect Ratio:** (e.g., 16:9, 9:16)
- **Visual Style & Lighting:** Key aesthetic references and lighting configuration
- **Scene & Character Details:** Subjects, environment, and key props
- **Narrative Progression:** 0–5s opening, 5–20s action, 20–30s resolution
- **Negative Constraints:** Visual artifacts or elements to avoid
- **Audio Note:** Confirm whether generation focuses on visual assets or requires post-production audio design.

*Wait for positive confirmation from the user (e.g., "confirm", "proceed", "go") before calling generation tools.*

### Step 3: Tool Execution

Upon user confirmation, invoke the appropriate generation tool.

#### A. Text-to-Video Workflow
Call `text_to_video` with the confirmed parameters:

```json
{
  "model_version": "seedance_2.5",
  "duration": 30,
  "ratio": "<confirmed-ratio>",
  "prompt": "<detailed 30-second narrative prompt with 3-act progression>"
}