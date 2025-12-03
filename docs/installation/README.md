# Installation Documentation - HP EliteBook x360 1030 G2

**Purpose:** Complete installation and configuration documentation for Arch Linux on HP EliteBook x360 1030 G2.

**Usage Modes:** This documentation can be used in three ways:
1. **AI Knowledge Base** - For AI assistants (Cursor CLI, Claude, ChatGPT) to automatically access system context
2. **AI Instructions** - Direct instructions for AI assistants on how to help with tasks
3. **Manual Guide** - Step-by-step command-by-command instructions for manual execution

---

## Files in This Directory

### Main Installation Guides

- **`README_COMPLETE.md`** - Complete installation guide combining pre-reboot and post-reboot phases

### Installation Templates

- **`blank_arch.md`** - Core Arch Linux installation (vendor-neutral)
  - Complete installation guide without Intel/AMD specific drivers
  - Percentage-based disk partitioning
  - Academic documentation with references and citations
  - Suitable as base template for any hardware configuration

- **`blank_intel_arch.md`** - Arch Linux with Intel hardware
  - Intel CPU microcode updates (`intel-ucode`)
  - Intel graphics drivers (Mesa, Vulkan, VA-API)
  - Intel-specific configuration notes
  - For Intel processors and integrated graphics

- **`blank_amd_arch.md`** - Arch Linux with AMD hardware
  - AMD CPU microcode updates (`amd-ucode`)
  - AMD graphics drivers (Mesa, Vulkan, VA-API)
  - AMD-specific configuration notes
  - For AMD processors and Radeon graphics

- **`gigabyte_brix_5300_arch_installation.md`** - GIGABYTE Brix 5300 specific installation
  - GIGABYTE Brix 5300 barebone system specifications
  - AMD Ryzen 3 5300U (4C/8T, 2.6-3.8 GHz, Zen 2, 15W)
  - AMD Radeon RX Vega graphics (6 compute units, integrated)
  - Complete installation guide with hardware-specific notes
  - DDR4 SO-DIMM and M.2 NVMe SSD configuration

### AI Assistant Documentation

- **`AI_ASSISTANT_CONTEXT.md`** - Context file for AI assistants (Cursor CLI, Claude, ChatGPT)
- **`HOW_TO_ASK_AI.md`** - Guide on how to ask AI assistants for help
- **`AI_ASSISTANT_CONTEXT_USAGE.md`** - Comprehensive academic documentation on purpose, structure, and usage
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
User: "I need to setup fingerprint on HP notebook"
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
I need to setup fingerprint on HP notebook
```

The AI assistant should automatically:
1. Check `AI_ASSISTANT_CONTEXT.md` for context
2. Find relevant section
3. Use `README_COMPLETE.md` for detailed instructions
4. Know that this is HP EliteBook x360 1030 G2

**See `HOW_TO_ASK_AI.md` for more examples.**

---

## Usage Modes

### 1. AI Knowledge Base

The documentation serves as a knowledge base for AI assistants. When users interact with AI assistants, the AI can automatically:

- Access `AI_ASSISTANT_CONTEXT.md` for hardware and system context
- Reference `README_COMPLETE.md` for detailed procedures
- Provide hardware-specific instructions based on documented procedures

**Example:** User asks "I need to setup fingerprint on HP notebook" → AI automatically checks context file and provides instructions.

### 2. AI Instructions

The documentation provides explicit instructions for AI assistants on:

- How to respond to user queries
- What information to extract from context files
- Which documentation sections to reference
- How to provide step-by-step guidance

**See:** `AI_ASSISTANT_CONTEXT.md` contains "Your response should:" sections with specific instructions for AI assistants.

### 3. Manual Guide

All documentation can be used manually, command-by-command:

- `README_COMPLETE.md` provides complete step-by-step procedures
- Each phase includes exact commands to execute
- Commands can be copied and pasted directly into terminal
- No AI assistant required - follow instructions manually

**Example:** Open `README_COMPLETE.md` Phase 15, follow each command sequentially.

---

## Hardware Information

**Device:** HP EliteBook x360 1030 G2  
**CPU:** Intel Core i5-7300U (7th Gen, 2 cores / 4 threads, 2.60 GHz base, 3.50 GHz turbo)  
**Graphics:** Intel HD Graphics 620 (integrated)  
**Audio:** Conexant CX8200 HD Audio Codec (HDA Intel PCH)  
**Display:** 1920×1080 13.3" FHD touchscreen (AU Optronics 0x422D)  
**Network:** Intel Wireless 8265 (802.11ac), wlp58s0 interface, Bluetooth 4.2  
**Fingerprint:** Validity Sensors 138a:0092  
**IR Camera:** Chicony IR Camera (04f2:b58e) at /dev/video2  
**HD Camera:** HP HD Camera (04f2:b58f) at /dev/video0  
**Smart Card:** Alcor Micro AU9560 (PC/SC compatible, optional)  

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
