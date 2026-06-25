# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of custom Claude Code skills published via `npx skills add estines/skills`. Each skill is a directory containing a `SKILL.md` file with YAML frontmatter and markdown instructions. Skills are installed into `~/.claude/skills/` on the consuming machine and exposed as slash commands.

## Skill file structure

Every skill lives at `{skill-name}/SKILL.md`. Required frontmatter fields:

```yaml
---
name: skill-name          # slug used to reference the skill
description: ...           # one-line description shown in skill lists and used for trigger matching
trigger: /skill-name       # slash command that invokes it
argument-hint: "..."       # optional; shown as autocomplete hint
---
```

The markdown body contains the skill's execution instructions — phases, decision rules, file templates, and output formats. These instructions are read by Claude at runtime.

## Skills in this repo

| Skill | Trigger | Purpose |
|-------|---------|---------|
| squad | `/squad` | Role-based SDLC squad (PO, BA, Architect, Principal reviewer, platform Seniors, QA, DevOps). Orchestrator `SKILL.md` spawns `general-purpose` agents with the `role-*.md` personas; gates on user sign-off. Modes: Greenfield (`/squad`), Brownfield (`/squad reverse <path>`), Feature (`/squad feature "<desc>"`). Every mode front-loads an Execution Preview. |
