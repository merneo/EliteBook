# How to Backup Documentation to Private GitHub Repository

**Purpose:** Guide for backing up installation documentation files to a private GitHub repository.

---

## Files to Backup

**Location:** `~/Documents/`

**Files:**
- `README_COMPLETE.md` (223K) - Complete installation guide with AI prompts
- `AI_ASSISTANT_CONTEXT.md` (8.2K) - Helper for AI assistants
- `HOW_TO_ASK_AI.md` (5.3K) - Guide on how to ask AI assistants
- `extract-phase-prompt.sh` (1.2K) - Script to extract phase prompts

**Total size:** ~237 KB

---

## Step 1: Create Private GitHub Repository

1. **Go to GitHub:**
   - Open https://github.com/new
   - Or: GitHub → New repository

2. **Repository settings:**
   - **Repository name:** `elitebook-installation-docs` (or your choice)
   - **Description:** "Arch Linux installation documentation for HP EliteBook x360 1030 G2"
   - **Visibility:** ☑ **Private** (IMPORTANT!)
   - **Initialize:** ☐ Don't initialize with README, .gitignore, or license
   - Click **Create repository**

3. **Copy repository URL:**
   - Example: `https://github.com/merneo/elitebook-installation-docs.git`
   - Or SSH: `git@github.com:merneo/elitebook-installation-docs.git`

---

## Step 2: Initialize Local Repository

```bash
# Navigate to Documents directory
cd ~/Documents

# Initialize git repository
git init

# Add remote repository
git remote add origin https://github.com/merneo/elitebook-installation-docs.git
# Or with SSH:
# git remote add origin git@github.com:merneo/elitebook-installation-docs.git
```

---

## Step 3: Create .gitignore

```bash
# Create .gitignore file
cat > ~/Documents/.gitignore << 'EOF'
# Temporary files
*.tmp
*.swp
*~
.DS_Store

# Backup files
*.bak
*.backup
*~

# Editor files
.vscode/
.idea/
*.sublime-*

# Logs
*.log
EOF
```

---

## Step 4: Add and Commit Files

```bash
cd ~/Documents

# Add all documentation files
git add README_COMPLETE.md
git add AI_ASSISTANT_CONTEXT.md
git add HOW_TO_ASK_AI.md
git add extract-phase-prompt.sh
git add .gitignore

# Verify what will be committed
git status

# Create initial commit
git commit -m "docs: Add complete installation documentation with AI prompts

- README_COMPLETE.md: Complete installation guide (pre-reboot + post-reboot)
- AI_ASSISTANT_CONTEXT.md: Helper file for AI assistants with quick reference
- HOW_TO_ASK_AI.md: Guide on how to ask AI assistants for help
- extract-phase-prompt.sh: Script to extract AI prompts for specific phases

All files contain installation procedures for HP EliteBook x360 1030 G2.
No sensitive data (passwords, keys) included."
```

---

## Step 5: Push to GitHub

```bash
# Push to GitHub (first time)
git branch -M main
git push -u origin main

# Enter GitHub credentials if prompted
# Username: merneo
# Password: [use Personal Access Token, not password]
```

**Note:** If using HTTPS, GitHub requires Personal Access Token instead of password:
- Go to: https://github.com/settings/tokens
- Generate new token (classic) with `repo` scope
- Use token as password

---

## Step 6: Verify Backup

1. **Check GitHub repository:**
   - Open: https://github.com/merneo/elitebook-installation-docs
   - Verify all files are present
   - Verify repository is **Private**

2. **Verify locally:**
```bash
cd ~/Documents
git log --oneline
git remote -v
```

---

## Future Updates

**To update documentation in repository:**

```bash
cd ~/Documents

# Make changes to files
# ...

# Add changes
git add README_COMPLETE.md  # or other files
git add -A  # to add all changes

# Commit
git commit -m "docs: Update installation documentation"

# Push
git push origin main
```

---

## Alternative: Backup to Existing Repository

**If you want to add to existing EliteBook repository:**

```bash
cd ~/EliteBook

# Create docs directory
mkdir -p docs/installation

# Copy files
cp ~/Documents/README_COMPLETE.md docs/installation/
cp ~/Documents/AI_ASSISTANT_CONTEXT.md docs/installation/
cp ~/Documents/HOW_TO_ASK_AI.md docs/installation/
cp ~/Documents/extract-phase-prompt.sh docs/installation/

# Add and commit
git add docs/installation/
git commit -m "docs: Add complete installation documentation with AI prompts"

# Push
git push origin main
```

---

## Security Checklist

Before pushing, verify:

- ✅ **No passwords** in files
- ✅ **No API keys** in files
- ✅ **No personal data** (except username which is already public)
- ✅ **Repository is Private** (not public)
- ✅ **No sensitive paths** (like `/home/linuxloser` is OK, but no actual secrets)

---

## Quick Backup Script

Create a script for easy backup:

```bash
cat > ~/Documents/backup-docs.sh << 'EOF'
#!/bin/bash
# Backup installation documentation to GitHub

cd ~/Documents

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git not initialized. Run backup setup first."
    exit 1
fi

# Add all documentation files
git add README_COMPLETE.md AI_ASSISTANT_CONTEXT.md HOW_TO_ASK_AI.md extract-phase-prompt.sh

# Check for changes
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Commit
git commit -m "docs: Update installation documentation ($(date +%Y-%m-%d))"

# Push
git push origin main

echo "✅ Documentation backed up to GitHub"
EOF

chmod +x ~/Documents/backup-docs.sh
```

**Usage:**
```bash
~/Documents/backup-docs.sh
```

---

## Repository Structure

After backup, repository structure:

```
elitebook-installation-docs/
├── README_COMPLETE.md          # Complete installation guide
├── AI_ASSISTANT_CONTEXT.md     # AI assistant helper
├── HOW_TO_ASK_AI.md           # How to ask AI assistants
├── extract-phase-prompt.sh     # Prompt extraction script
└── .gitignore                  # Git ignore rules
```

---

## Restore from Backup

**To restore on another machine:**

```bash
# Clone repository
git clone https://github.com/merneo/elitebook-installation-docs.git ~/Documents/backup

# Or if already in Documents:
cd ~/Documents
git clone https://github.com/merneo/elitebook-installation-docs.git backup

# Copy files
cp backup/*.md ~/Documents/
cp backup/*.sh ~/Documents/
chmod +x ~/Documents/extract-phase-prompt.sh
```

---

**Repository URL:** `https://github.com/merneo/elitebook-installation-docs.git`  
**Visibility:** Private  
**Last Updated:** 2025-12-02
