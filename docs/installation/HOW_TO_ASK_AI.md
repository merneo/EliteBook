# How to Ask AI Assistants - Quick Guide

**Purpose:** Examples of how to ask AI assistant (Cursor CLI, Claude, ChatGPT) for help with HP EliteBook x360 1030 G2 installation and configuration.

---

## Basic Principle

When you need help, the AI assistant should:
1. Open `docs/installation/AI_ASSISTANT_CONTEXT.md` for context
2. Find the relevant section
3. Use documentation from `docs/installation/README_COMPLETE.md`
4. Provide instructions according to the documentation

---

## Example Queries

### Fingerprint Authentication

**Simple phrase:**
```
I need to setup fingerprint on HP notebook
```

**With context reference:**
```
I need to setup fingerprint - check AI_ASSISTANT_CONTEXT.md
```

**Complete:**
```
I need to setup fingerprint on HP EliteBook x360 1030 G2. 
Check docs/installation/AI_ASSISTANT_CONTEXT.md for context 
and use documentation from docs/installation/README_COMPLETE.md Phase 15.
```

---

### Face Recognition (Howdy)

**Simple phrase:**
```
I'm installing face recognition on HP notebook
```

**With reference:**
```
I need to setup Howdy - it's documented in AI_ASSISTANT_CONTEXT.md
```

**Complete:**
```
I need to setup face recognition (Howdy) on HP EliteBook. 
Use AI_ASSISTANT_CONTEXT.md as reference and README_COMPLETE.md Phase 15c.
```

---

### Window Manager (Hyprland)

**Simple phrase:**
```
I'm configuring Hyprland on HP notebook
```

**With reference:**
```
I need to configure window manager - check AI_ASSISTANT_CONTEXT.md
```

**Complete:**
```
I need to setup Hyprland window manager. 
It's documented in AI_ASSISTANT_CONTEXT.md and README_COMPLETE.md Phase 13/17.
```

---

### Browser Themes

**Simple phrase:**
```
I'm configuring browser themes
```

**With reference:**
```
I need to deploy Firefox/Brave theme - use AI_ASSISTANT_CONTEXT.md
```

**Complete:**
```
I need to setup Catppuccin Mocha Green theme for Firefox and Brave. 
Check AI_ASSISTANT_CONTEXT.md and browsers/THEME_DEPLOYMENT.md.
```

---

### Dotfiles Deployment

**Simple phrase:**
```
I'm deploying dotfiles from repository
```

**With reference:**
```
I need to deploy configuration files - it's in AI_ASSISTANT_CONTEXT.md
```

**Complete:**
```
I need to deploy dotfiles from ~/EliteBook repository. 
Use AI_ASSISTANT_CONTEXT.md and README_COMPLETE.md Phase 17.
```

---

## Query Templates

### Template 1: Simple (Recommended)
```
I need to [task] on HP notebook
```

**Examples:**
- "I need to setup fingerprint on HP notebook"
- "I need to configure Hyprland on HP notebook"
- "I need to deploy browser themes on HP notebook"

---

### Template 2: With context reference
```
I need to [task] - check AI_ASSISTANT_CONTEXT.md
```

**Examples:**
- "I need to setup fingerprint - check AI_ASSISTANT_CONTEXT.md"
- "I'm installing Howdy - it's documented in AI_ASSISTANT_CONTEXT.md"
- "I'm configuring window manager - use AI_ASSISTANT_CONTEXT.md as reference"

---

### Template 3: Complete (Best)
```
I need to [task] on HP EliteBook x360 1030 G2. 
Check docs/installation/AI_ASSISTANT_CONTEXT.md for context 
and use documentation from docs/installation/README_COMPLETE.md Phase [number].
```

**Examples:**
- "I need to setup fingerprint on HP EliteBook x360 1030 G2. Check docs/installation/AI_ASSISTANT_CONTEXT.md for context and use documentation from docs/installation/README_COMPLETE.md Phase 15."
- "I'm installing face recognition on HP EliteBook. Use AI_ASSISTANT_CONTEXT.md as reference and README_COMPLETE.md Phase 15c for details."

---

## What the AI Assistant Will Do

When you write, for example:
```
I need to setup fingerprint on HP notebook
```

The AI assistant should:
1. ✅ Open `docs/installation/AI_ASSISTANT_CONTEXT.md`
2. ✅ Find section "Fingerprint Authentication Setup"
3. ✅ Identify hardware: Validity Sensors 138a:0092
4. ✅ Identify that it's documented in Phase 15
5. ✅ Open `docs/installation/README_COMPLETE.md` Phase 15
6. ✅ Provide instructions according to documentation
7. ✅ Know that this has been done before

---

## Tips

💡 **Simplest way:**
```
I need to [task] on HP notebook
```
The AI assistant should automatically check AI_ASSISTANT_CONTEXT.md

💡 **If you want to be explicit:**
```
I need to [task] - check AI_ASSISTANT_CONTEXT.md
```

💡 **If you know the phase number:**
```
I need to [task] - it's in README_COMPLETE.md Phase [number]
```

💡 **For more context:**
```
I need to [task] on HP EliteBook x360 1030 G2. 
Use AI_ASSISTANT_CONTEXT.md and README_COMPLETE.md Phase [number].
```

---

## List of Common Tasks

| Task | AI_ASSISTANT_CONTEXT.md Section | README_COMPLETE.md Phase |
|------|-------------------------------|-------------------------|
| Fingerprint setup | Fingerprint Authentication Setup | Phase 15 |
| Face recognition | Face Recognition (Howdy) Setup | Phase 15c |
| Window manager | Window Manager (Hyprland) Configuration | Phase 13, 17 |
| Browser themes | Browser Theme Configuration | browsers/THEME_DEPLOYMENT.md |
| Dotfiles | Dotfiles Deployment | Phase 17 |
| eObčanka reader | (not in context yet) | Phase 15b |
| Timeshift snapshots | (not in context yet) | Phase 16 |
| GPG keys | (not in context yet) | Phase 18 |

---

**File:** `docs/installation/HOW_TO_ASK_AI.md`  
**Created:** 2025-12-02
