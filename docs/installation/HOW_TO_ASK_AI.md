# Jak se ptát AI asistenta - Quick Guide

**Purpose:** Examples of how to ask AI assistant (Cursor CLI, Claude, ChatGPT) for help with HP EliteBook x360 1030 G2 installation and configuration.

---

## Základní princip

Když potřebujete pomoc, AI asistent by měl:
1. Otevřít `~/Documents/AI_ASSISTANT_CONTEXT.md` pro kontext
2. Najít relevantní sekci
3. Použít dokumentaci z `~/Documents/README_COMPLETE.md`
4. Poskytnout instrukce podle dokumentace

---

## Příklady zpráv

### Fingerprint Authentication

**Jednoduchá fráze:**
```
Potřebuji nastavit fingerprint na HP notebooku
```

**S odkazem na kontext:**
```
Potřebuji nastavit fingerprint - podívej se do AI_ASSISTANT_CONTEXT.md
```

**Kompletní:**
```
Potřebuji nastavit fingerprint na HP EliteBook x360 1030 G2. 
Podívej se do ~/Documents/AI_ASSISTANT_CONTEXT.md pro kontext 
a použij dokumentaci z ~/Documents/README_COMPLETE.md Phase 15.
```

---

### Face Recognition (Howdy)

**Jednoduchá fráze:**
```
Instaluju face recognition na HP notebooku
```

**S odkazem:**
```
Potřebuji nastavit Howdy - je to zdokumentováno v AI_ASSISTANT_CONTEXT.md
```

**Kompletní:**
```
Potřebuji nastavit face recognition (Howdy) na HP EliteBook. 
Použij AI_ASSISTANT_CONTEXT.md jako referenci a README_COMPLETE.md Phase 15c.
```

---

### Window Manager (Hyprland)

**Jednoduchá fráze:**
```
Nastavuji Hyprland na HP notebooku
```

**S odkazem:**
```
Potřebuji konfigurovat window manager - podívej se do AI_ASSISTANT_CONTEXT.md
```

**Kompletní:**
```
Potřebuji nastavit Hyprland window manager. 
Je to zdokumentováno v AI_ASSISTANT_CONTEXT.md a README_COMPLETE.md Phase 13/17.
```

---

### Browser Themes

**Jednoduchá fráze:**
```
Nastavuji browser themes
```

**S odkazem:**
```
Potřebuji deploynout Firefox/Brave theme - použij AI_ASSISTANT_CONTEXT.md
```

**Kompletní:**
```
Potřebuji nastavit Catppuccin Mocha Green theme pro Firefox a Brave. 
Podívej se do AI_ASSISTANT_CONTEXT.md a browsers/THEME_DEPLOYMENT.md.
```

---

### Dotfiles Deployment

**Jednoduchá fráze:**
```
Deployuji dotfiles z repository
```

**S odkazem:**
```
Potřebuji nasadit konfigurační soubory - je to v AI_ASSISTANT_CONTEXT.md
```

**Kompletní:**
```
Potřebuji deploynout dotfiles z ~/EliteBook repository. 
Použij AI_ASSISTANT_CONTEXT.md a README_COMPLETE.md Phase 17.
```

---

## Šablony zpráv

### Šablona 1: Jednoduchá (doporučeno)
```
Potřebuji [úkol] na HP notebooku
```

**Příklady:**
- "Potřebuji nastavit fingerprint na HP notebooku"
- "Potřebuji konfigurovat Hyprland na HP notebooku"
- "Potřebuji deploynout browser themes na HP notebooku"

---

### Šablona 2: S odkazem na kontext
```
Potřebuji [úkol] - podívej se do AI_ASSISTANT_CONTEXT.md
```

**Příklady:**
- "Potřebuji nastavit fingerprint - podívej se do AI_ASSISTANT_CONTEXT.md"
- "Instaluju Howdy - je to zdokumentováno v AI_ASSISTANT_CONTEXT.md"
- "Nastavuji window manager - použij AI_ASSISTANT_CONTEXT.md jako referenci"

---

### Šablona 3: Kompletní (nejlepší)
```
Potřebuji [úkol] na HP EliteBook x360 1030 G2. 
Podívej se do ~/Documents/AI_ASSISTANT_CONTEXT.md pro kontext 
a použij dokumentaci z ~/Documents/README_COMPLETE.md Phase [číslo].
```

**Příklady:**
- "Potřebuji nastavit fingerprint na HP EliteBook x360 1030 G2. Podívej se do ~/Documents/AI_ASSISTANT_CONTEXT.md pro kontext a použij dokumentaci z ~/Documents/README_COMPLETE.md Phase 15."
- "Instaluju face recognition na HP EliteBook. Použij AI_ASSISTANT_CONTEXT.md jako referenci a README_COMPLETE.md Phase 15c pro detaily."

---

## Co AI asistent udělá

Když napíšete například:
```
Potřebuji nastavit fingerprint na HP notebooku
```

AI asistent by měl:
1. ✅ Otevřít `~/Documents/AI_ASSISTANT_CONTEXT.md`
2. ✅ Najít sekci "Fingerprint Authentication Setup"
3. ✅ Zjistit hardware: Validity Sensors 138a:0092
4. ✅ Zjistit, že je to zdokumentováno v Phase 15
5. ✅ Otevřít `~/Documents/README_COMPLETE.md` Phase 15
6. ✅ Poskytnout instrukce podle dokumentace
7. ✅ Vědět, že to už bylo děláno dříve

---

## Tipy

💡 **Nejjednodušší způsob:**
```
Potřebuji [úkol] na HP notebooku
```
AI asistent by měl automaticky zkontrolovat AI_ASSISTANT_CONTEXT.md

💡 **Pokud chcete být explicitní:**
```
Potřebuji [úkol] - podívej se do AI_ASSISTANT_CONTEXT.md
```

💡 **Pokud znáte číslo fáze:**
```
Potřebuji [úkol] - je to v README_COMPLETE.md Phase [číslo]
```

💡 **Pro více kontextu:**
```
Potřebuji [úkol] na HP EliteBook x360 1030 G2. 
Použij AI_ASSISTANT_CONTEXT.md a README_COMPLETE.md Phase [číslo].
```

---

## Seznam běžných úkolů

| Úkol | AI_ASSISTANT_CONTEXT.md sekce | README_COMPLETE.md fáze |
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

**Soubor:** `~/Documents/HOW_TO_ASK_AI.md`  
**Datum vytvoření:** 2025-12-02
