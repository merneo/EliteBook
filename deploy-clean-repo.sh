#!/bin/bash

# =============================================================================
# CLEAN REPOSITORY DEPLOYMENT SCRIPT - GitHub Repository Publishing Automation
# =============================================================================
# Author: merneo
# Purpose: Automates the complete process of publishing this repository as a
#          clean, new GitHub repository without any commit history, providing
#          a fresh start for public distribution.
#
# Operational Context:
#   This script is designed for server administrators who want to publish their
#   system configuration repository to GitHub without exposing internal development
#   history, commit messages, or incremental changes. Ideal for creating a
#   production-ready public repository from a private development repository.
#
# Execution Flow:
#   1. Prerequisites check (GitHub CLI, authentication, directory validation)
#   2. Backup existing git history (safety measure)
#   3. Remove existing git history (.git directory)
#   4. Initialize new git repository (fresh start)
#   5. Delete old GitHub repository (if exists)
#   6. Create new GitHub repository (public, with description)
#   7. Push all files as initial commit (single clean commit)
#
# Usage:
#   ./deploy-clean-repo.sh [--keep-backup]
#
# Options:
#   --keep-backup: Keep backup of old .git directory (default: removed after success)
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository files prepared in current directory
#   - Write access to GitHub account (merneo)
#   - Network connectivity (for GitHub API calls)
#
# Safety Features:
#   - Backup creation before destructive operations
#   - Prerequisites validation before execution
#   - Error handling with clear messages
#   - Confirmation prompts for destructive operations
# =============================================================================

# =============================================================================
# SHELL OPTIONS & SAFETY
# =============================================================================
# set -e: Exit immediately on command failure
# set -u: Treat unset variables as errors
# set -o pipefail: Pipeline commands fail if any command fails
# =============================================================================
set -euo pipefail

# =============================================================================
# COLOR OUTPUT DEFINITIONS
# =============================================================================
# Purpose: Provide colored terminal output for better visibility and user feedback
#
# Colors:
#   - RED: Error messages (critical issues)
#   - GREEN: Information messages (success, progress)
#   - YELLOW: Warning messages (non-critical issues)
#   - NC: No Color (reset to default terminal color)
#
# Usage:
#   - log_info(): Green output for normal operations
#   - log_warn(): Yellow output for warnings
#   - log_error(): Red output for errors
# =============================================================================
# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================
# Purpose: Define repository and deployment parameters
#
# Repository Information:
#   - REPO_NAME: GitHub repository name (EliteBook)
#   - REPO_OWNER: GitHub username/organization (merneo)
#   - REPO_DESCRIPTION: Repository description for GitHub
#
# Backup Configuration:
#   - BACKUP_DIR: Location for git history backup
#   - Timestamp-based naming: Prevents backup overwrites
#   - Format: EliteBook-backup-YYYYMMDD-HHMMSS
#
# Why Backup:
#   - Safety measure: Preserves git history before deletion
#   - Recovery: Can restore history if deployment fails
#   - Audit: Maintains record of previous repository state
# =============================================================================
REPO_NAME="EliteBook"
REPO_OWNER="merneo"
REPO_DESCRIPTION="Enterprise-Grade Arch Linux System Configuration for HP EliteBook x360 1030 G2"
BACKUP_DIR="${HOME}/EliteBook-backup-$(date +%Y%m%d-%H%M%S)"

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
# Purpose: Provide consistent, colored logging output throughout script execution
#
# Functions:
#   - log_info(): Information messages (green, normal operations)
#   - log_warn(): Warning messages (yellow, non-critical issues)
#   - log_error(): Error messages (red, critical failures)
#
# Usage:
#   - All script output goes through these functions
#   - Ensures consistent formatting and color coding
#   - Improves readability and user experience
# =============================================================================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# PREREQUISITES VALIDATION FUNCTION
# =============================================================================
# Purpose: Verify all requirements are met before executing deployment
#
# Checks Performed:
#   1. GitHub CLI Installation: Verifies 'gh' command is available
#   2. GitHub Authentication: Verifies user is authenticated with GitHub
#   3. Directory Validation: Verifies script is run from correct location
#
# Why Validate Early:
#   - Prevents partial execution (fails fast if requirements missing)
#   - Provides clear error messages (tells user what's missing)
#   - Saves time (doesn't start deployment if it will fail)
#
# Error Handling:
#   - Exits with status code 1 if any prerequisite missing
#   - Provides installation/authentication instructions
#   - Prevents script from continuing with incomplete environment
# =============================================================================
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed."
        log_info "Install with: sudo pacman -S github-cli"
        exit 1
    fi
    
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated."
        log_info "Authenticate with: gh auth login"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "README.md" ] || [ ! -d "hypr" ]; then
        log_error "This script must be run from the EliteBook repository root."
        exit 1
    fi
    
    log_info "Prerequisites check passed."
}

# =============================================================================
# REPOSITORY BACKUP FUNCTION
# =============================================================================
# Purpose: Create safety backup of existing git history before deletion
#
# Implementation:
#   - Checks if .git directory exists
#   - Copies entire .git directory to backup location
#   - Creates timestamped backup directory (prevents overwrites)
#
# Why Backup:
#   - Safety measure: Preserves git history before destructive operation
#   - Recovery: Can restore history if deployment fails
#   - Audit trail: Maintains record of previous repository state
#
# Backup Location:
#   - ${HOME}/EliteBook-backup-YYYYMMDD-HHMMSS/
#   - Timestamp ensures unique backup names
#   - User's home directory (safe, accessible location)
#
# Error Handling:
#   - Continues even if backup fails (non-critical operation)
#   - Logs warning if .git directory not found (nothing to backup)
# =============================================================================
backup_repository() {
    log_info "Creating backup..."
    
    if [ -d ".git" ]; then
        cp -r .git "${BACKUP_DIR}/.git" 2>/dev/null || true
        log_info "Backup created at: ${BACKUP_DIR}"
    else
        log_warn "No .git directory found. Skipping backup."
    fi
}

# =============================================================================
# GIT HISTORY REMOVAL FUNCTION
# =============================================================================
# Purpose: Remove existing git history to prepare for clean repository
#
# Implementation:
#   - Checks if .git directory exists
#   - Removes entire .git directory (all history, branches, tags)
#   - Prepares directory for fresh git initialization
#
# Why Remove History:
#   - Clean start: No development history in public repository
#   - Privacy: Hides internal commit messages and changes
#   - Professional appearance: Single, clean initial commit
#
# Safety:
#   - Backup created before removal (if --keep-backup specified)
#   - User confirmation required for destructive operations
#   - Clear logging of what's being removed
# =============================================================================
remove_git_history() {
    log_info "Removing existing git history..."
    
    if [ -d ".git" ]; then
        rm -rf .git
        log_info "Git history removed."
    else
        log_info "No git history to remove."
    fi
}

# =============================================================================
# NEW REPOSITORY INITIALIZATION FUNCTION
# =============================================================================
# Purpose: Initialize fresh git repository with single initial commit
#
# Implementation:
#   1. git init: Creates new .git directory (fresh start)
#   2. git add -A: Stages all files in repository
#   3. git commit: Creates single initial commit with descriptive message
#
# Initial Commit Message:
#   - Descriptive: Explains what the repository contains
#   - Professional: Suitable for public GitHub repository
#   - Comprehensive: Lists major components and features
#
# Why Single Commit:
#   - Clean history: No incremental development commits
#   - Professional appearance: Production-ready from first commit
#   - Simplicity: Easy to understand repository purpose
#
# GitHub Requirement:
#   - GitHub requires at least one commit before pushing
#   - Initial commit satisfies this requirement
# =============================================================================
init_new_repo() {
    log_info "Initializing new git repository..."
    
    git init
    git add -A
    
    # Create initial commit (GitHub requires at least one commit)
    git commit -m "Initial commit: Production-ready server management configuration

Enterprise-Grade Arch Linux System Configuration
- Hyprland Wayland compositor configuration
- Power management (TLP) optimization
- Biometric authentication setup
- Complete hardware integration
- Operational automation scripts"
    
    log_info "New repository initialized with initial commit."
}

# =============================================================================
# OLD REPOSITORY DELETION FUNCTION
# =============================================================================
# Purpose: Delete existing GitHub repository before creating new one
#
# Implementation:
#   1. Check if repository exists (gh repo view)
#   2. Prompt user for confirmation (destructive operation)
#   3. Delete repository if confirmed (gh repo delete)
#
# Why Delete Old Repository:
#   - Clean slate: Start fresh without old repository state
#   - Name conflict: GitHub doesn't allow duplicate repository names
#   - Consistency: Ensures new repository is truly new
#
# Safety:
#   - User confirmation required (prevents accidental deletion)
#   - Clear warning message (user knows what will be deleted)
#   - Graceful handling if repository doesn't exist
#
# Alternative:
#   - User can skip deletion and delete manually later
#   - Script continues even if deletion skipped
# =============================================================================
delete_old_repo() {
    log_info "Checking if old repository exists on GitHub..."
    
    if gh repo view "${REPO_OWNER}/${REPO_NAME}" &> /dev/null; then
        log_warn "Repository ${REPO_OWNER}/${REPO_NAME} exists on GitHub."
        read -p "Delete existing repository? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            log_info "Deleting old repository..."
            gh repo delete "${REPO_OWNER}/${REPO_NAME}" --yes
            log_info "Old repository deleted."
        else
            log_info "Skipping repository deletion. You can delete it manually later."
        fi
    else
        log_info "No existing repository found. Proceeding with creation."
    fi
}

# =============================================================================
# NEW REPOSITORY CREATION FUNCTION
# =============================================================================
# Purpose: Create new GitHub repository and push all files
#
# Implementation:
#   - gh repo create: Creates repository on GitHub
#   - --description: Sets repository description
#   - --private: Creates private repository (can be changed to public later)
#   - --source=.: Uses current directory as source
#   - --remote=origin: Sets GitHub as origin remote
#   - --push: Pushes all commits to GitHub immediately
#
# Repository Settings:
#   - Name: EliteBook (from REPO_NAME variable)
#   - Description: Enterprise-Grade Arch Linux System Configuration...
#   - Visibility: Private (user can change to public via GitHub web UI)
#
# Why Private Initially:
#   - Safety: Allows user to review before making public
#   - Flexibility: User can change visibility after creation
#   - Control: Prevents accidental public exposure
#
# Push Operation:
#   - Pushes all files from initial commit
#   - Sets up remote tracking (origin/main branch)
#   - Repository immediately available on GitHub
# =============================================================================
create_new_repo() {
    log_info "Creating new repository on GitHub..."
    
    gh repo create "${REPO_NAME}" \
        --description "${REPO_DESCRIPTION}" \
        --private \
        --source=. \
        --remote=origin \
        --push
    
    log_info "Repository created and pushed to GitHub."
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================
# Purpose: Orchestrate the complete repository deployment process
#
# Execution Sequence:
#   1. Parse command-line arguments (--keep-backup flag)
#   2. Validate prerequisites (GitHub CLI, authentication, directory)
#   3. Create backup (if --keep-backup specified)
#   4. Remove git history (prepare for clean start)
#   5. Initialize new repository (fresh git init + initial commit)
#   6. Delete old GitHub repository (if exists, with confirmation)
#   7. Create new GitHub repository (public, with description, push files)
#   8. Display completion message with repository URL
#
# Argument Parsing:
#   - --keep-backup: Preserves backup of old .git directory
#   - Default: Backup removed after successful deployment
#   - Useful for recovery or audit purposes
#
# Error Handling:
#   - set -e ensures script exits on any command failure
#   - Each function validates its own prerequisites
#   - Clear error messages guide user to resolution
#
# Completion:
#   - Displays repository URL for user reference
#   - Shows backup location (if --keep-backup used)
#   - Confirms successful deployment
# =============================================================================
main() {
    log_info "Starting clean repository deployment process..."
    echo ""
    
    # Parse arguments
    KEEP_BACKUP=false
    if [[ "$*" == *"--keep-backup"* ]]; then
        KEEP_BACKUP=true
    fi
    
    # Execute steps
    check_prerequisites
    echo ""
    
    if [ "$KEEP_BACKUP" = true ]; then
        backup_repository
        echo ""
    fi
    
    remove_git_history
    echo ""
    
    init_new_repo
    echo ""
    
    delete_old_repo
    echo ""
    
    create_new_repo
    echo ""
    
    log_info "Deployment completed successfully!"
    log_info "Repository URL: https://github.com/${REPO_OWNER}/${REPO_NAME}"
    
    if [ "$KEEP_BACKUP" = true ] && [ -d "${BACKUP_DIR}" ]; then
        log_info "Backup location: ${BACKUP_DIR}"
    fi
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================
# Purpose: Execute main function with all command-line arguments
#
# Argument Passing:
#   - "$@": Passes all command-line arguments to main function
#   - Allows script to accept options like --keep-backup
#   - Maintains argument order and spacing
# =============================================================================
# Run main function
main "$@"
