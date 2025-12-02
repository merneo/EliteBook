# Installation Documentation - HP EliteBook x360 1030 G2

**Purpose:** Complete installation and configuration documentation for Arch Linux on HP EliteBook x360 1030 G2.

---

## Files in This Directory

- **`README_COMPLETE.md`** - Complete installation guide combining pre-reboot and post-reboot phases
- **`AI_ASSISTANT_CONTEXT.md`** - Context file for AI assistants (Cursor CLI, Claude, ChatGPT)
- **`HOW_TO_ASK_AI.md`** - Guide on how to ask AI assistants for help
- **`extract-phase-prompt.sh`** - Script to extract AI prompts for specific phases
- **`BACKUP_TO_GITHUB.md`** - Instructions for backing up documentation

---

## For AI Assistants

**When helping with this system, AI assistants should:**

1. **Read `AI_ASSISTANT_CONTEXT.md` first** - This file contains:
   - Hardware information (HP EliteBook x360 1030 G2)
   - Installation status
   - Quick reference for common tasks
   - Instructions on what to do when user asks about specific tasks

2. **Use `README_COMPLETE.md`** for detailed step-by-step instructions

3. **Know that this has been done before** - All procedures are documented and tested

**Example workflow:**
```
User: "Potřebuji nastavit fingerprint na HP notebooku"
AI: [Reads AI_ASSISTANT_CONTEXT.md] 
    → Finds "Fingerprint Authentication Setup" section
    → Knows: Hardware is Validity Sensors 138a:0092
    → Knows: Documented in README_COMPLETE.md Phase 15
    → Provides instructions from README_COMPLETE.md Phase 15
```

---

## For Users

**When asking AI assistant for help:**

Simply say:
```
Potřebuji nastavit fingerprint na HP notebooku
```

The AI assistant should automatically:
1. Check `AI_ASSISTANT_CONTEXT.md` for context
2. Find relevant section
3. Use `README_COMPLETE.md` for detailed instructions
4. Know that this is HP EliteBook x360 1030 G2

**See `HOW_TO_ASK_AI.md` for more examples.**

---

## Hardware Information

**Device:** HP EliteBook x360 1030 G2  
**CPU:** Intel Core i5-7300U (7th Gen)  
**Fingerprint:** Validity Sensors 138a:0092  
**IR Camera:** Chicony IR Camera (04f2:b58e)  
**HD Camera:** HP HD Camera (04f2:b58f)  

**Full hardware list:** See `AI_ASSISTANT_CONTEXT.md`

---

## Installation Phases

**Pre-Reboot (Phase 1-14):** Installation from live USB  
**Post-Reboot (Phase 14.5-18):** Configuration after first boot  

**Complete guide:** `README_COMPLETE.md`

---

## Quick Reference

| Task | Documentation | Context File Section |
|------|---------------|---------------------|
| Fingerprint | Phase 15 | Fingerprint Authentication Setup |
| Face Recognition | Phase 15c | Face Recognition (Howdy) Setup |
| Window Manager | Phase 13, 17 | Window Manager (Hyprland) Configuration |
| Browser Themes | browsers/THEME_DEPLOYMENT.md | Browser Theme Configuration |
| Dotfiles | Phase 17 | Dotfiles Deployment |

---

**Repository:** https://github.com/merneo/EliteBook  
**Last Updated:** 2025-12-02
