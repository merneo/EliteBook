# Git Workflow for Multiple Concurrent Tasks

**Purpose:** Manage multiple development tasks simultaneously using Git branches  
**Use Case:** Working on Howdy/Fingerprint while also developing browser configurations

---

## Current Situation

- **Howdy/Fingerprint:** Partially complete, all work committed to `main` branch
- **Browsers:** New task to start
- **Goal:** Work on browsers without losing Howdy/Fingerprint progress

---

## Solution: Git Branching Strategy

Git branches allow you to:
1. **Preserve current work** - All Howdy/Fingerprint work is safely in `main`
2. **Create isolated workspace** - New branch for browser work
3. **Switch between tasks** - Easily return to Howdy/Fingerprint later
4. **Merge when ready** - Combine work when tasks are complete

---

## Recommended Workflow

### Step 1: Verify Current State

```bash
cd ~/EliteBook
git status                    # Should show "working tree clean"
git log --oneline -5          # Verify recent commits
```

**Current state:** All Howdy/Fingerprint work is committed and pushed to GitHub.

### Step 2: Create Branch for Browser Work

```bash
# Create and switch to new branch for browsers
git checkout -b feature/browser-configuration

# Verify you're on new branch
git branch                    # Should show * feature/browser-configuration
```

**What this does:**
- Creates new branch from current `main`
- Switches to new branch
- All Howdy/Fingerprint work remains in `main`
- Browser work will be isolated in new branch

### Step 3: Work on Browsers

```bash
# Make browser configuration changes
# ... edit files, add configurations ...

# Commit browser work
git add .
git commit -m "feat: Add browser configuration"

# Push browser branch to GitHub
git push -u origin feature/browser-configuration
```

**Benefits:**
- Browser work is separate from Howdy/Fingerprint
- Can commit and push independently
- GitHub stores both branches

### Step 4: Switch Back to Howdy/Fingerprint (When Needed)

```bash
# Switch back to main branch (Howdy/Fingerprint work)
git checkout main

# Continue Howdy/Fingerprint work
# ... make changes ...

# Commit and push
git add .
git commit -m "feat: Continue Howdy improvements"
git push origin main
```

**Note:** You can switch between branches anytime:
- `git checkout main` → Work on Howdy/Fingerprint
- `git checkout feature/browser-configuration` → Work on browsers

### Step 5: Merge When Tasks Complete

When both tasks are finished:

```bash
# Switch to main branch
git checkout main

# Merge browser branch into main
git merge feature/browser-configuration

# Resolve any conflicts if they occur
# (Git will guide you through conflict resolution)

# Push merged work
git push origin main
```

---

## Branch Management Commands

### View All Branches

```bash
git branch                    # Local branches
git branch -a                 # All branches (local + remote)
```

### Create New Branch

```bash
git checkout -b branch-name   # Create and switch to new branch
# or
git branch branch-name        # Create branch (stay on current)
git checkout branch-name      # Switch to branch
```

### Switch Between Branches

```bash
git checkout main                          # Switch to main
git checkout feature/browser-configuration # Switch to browser branch
```

### Delete Branch (When Done)

```bash
# Delete local branch (after merging)
git branch -d feature/browser-configuration

# Delete remote branch
git push origin --delete feature/browser-configuration
```

---

## GitHub Integration

### View Branches on GitHub

1. Go to: https://github.com/merneo/EliteBook
2. Click "branches" dropdown (above file list)
3. See all branches: `main`, `feature/browser-configuration`, etc.

### Pull Request Workflow (Optional)

For code review or documentation:

1. Push branch to GitHub
2. Create Pull Request on GitHub website
3. Review changes
4. Merge via GitHub interface

---

## Best Practices

### 1. Branch Naming Convention

Use descriptive names:
- `feature/browser-configuration` - New feature
- `fix/howdy-enrollment` - Bug fix
- `docs/fingerprint-setup` - Documentation

### 2. Commit Frequently

```bash
# Commit small, logical changes
git add .
git commit -m "Descriptive commit message"
git push
```

### 3. Keep Branches Updated

```bash
# Before starting new work, update from main
git checkout main
git pull origin main
git checkout feature/browser-configuration
git merge main  # Bring latest changes into your branch
```

### 4. Document Branch Purpose

Create a note file in branch:

```bash
# In browser branch
echo "# Browser Configuration Work
# Status: In progress
# Started: $(date)
# Goal: Configure Firefox, Chromium, etc." > BROWSER_WORK.md
git add BROWSER_WORK.md
git commit -m "docs: Add browser work tracking"
```

---

## Example Workflow Timeline

### Day 1: Start Browser Work

```bash
git checkout -b feature/browser-configuration
# Work on browsers
git commit -m "feat: Add Firefox configuration"
git push -u origin feature/browser-configuration
```

### Day 2: Return to Howdy

```bash
git checkout main
# Continue Howdy work
git commit -m "feat: Improve Howdy enrollment"
git push origin main
```

### Day 3: Back to Browsers

```bash
git checkout feature/browser-configuration
# Continue browser work
git commit -m "feat: Add Chromium configuration"
git push origin feature/browser-configuration
```

### Day 4: Finish Both Tasks

```bash
# Finish browser work
git checkout feature/browser-configuration
git commit -m "feat: Complete browser configuration"
git push origin feature/browser-configuration

# Merge into main
git checkout main
git merge feature/browser-configuration
git push origin main
```

---

## Troubleshooting

### "Uncommitted changes" Error

If Git prevents switching branches due to uncommitted changes:

```bash
# Option 1: Commit changes
git add .
git commit -m "WIP: Work in progress"
git checkout other-branch

# Option 2: Stash changes (temporary save)
git stash                    # Save changes temporarily
git checkout other-branch
git stash pop               # Restore changes when you return
```

### Merge Conflicts

If branches have conflicting changes:

```bash
git merge feature/browser-configuration
# Git will show conflicts
# Edit files to resolve conflicts
git add .
git commit -m "Merge browser configuration into main"
```

---

## Summary

**GitHub/Git Solution:**
- ✅ **Preserves work** - All Howdy/Fingerprint work is safe in `main`
- ✅ **Isolates tasks** - Browser work in separate branch
- ✅ **Enables switching** - Work on either task anytime
- ✅ **Stores everything** - GitHub keeps all branches
- ✅ **Allows merging** - Combine work when ready

**Next Steps:**
1. Create branch: `git checkout -b feature/browser-configuration`
2. Work on browsers
3. Switch back: `git checkout main` (when needed)
4. Merge when done: `git merge feature/browser-configuration`

---

**References:**
- Git Branching: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell
- GitHub Branches: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches
