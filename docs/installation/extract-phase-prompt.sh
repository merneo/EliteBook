#!/bin/bash
# Extract AI prompt for a specific phase from README_COMPLETE.md
# Usage: ./extract-phase-prompt.sh <phase_number>
# Example: ./extract-phase-prompt.sh 13

README_FILE="$HOME/Documents/README_COMPLETE.md"

if [ ! -f "$README_FILE" ]; then
    echo "❌ Error: $README_FILE not found"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <phase_number>"
    echo "Example: $0 13"
    echo ""
    echo "Available phases:"
    grep -E "^## Phase [0-9]" "$README_FILE" | sed 's/^## Phase /  - Phase /' | head -20
    exit 1
fi

PHASE_NUM="$1"

# Extract prompt for the phase
PROMPT=$(grep -A 20 "AI Assistant Prompt for Phase $PHASE_NUM" "$README_FILE" | \
    sed -n '/```/,/```/p' | \
    sed '1d;$d' | \
    sed 's/^```$//')

if [ -z "$PROMPT" ]; then
    echo "❌ No prompt found for Phase $PHASE_NUM"
    echo ""
    echo "Available phases:"
    grep -E "^## Phase [0-9]" "$README_FILE" | sed 's/^## Phase /  - Phase /'
    exit 1
fi

echo "📋 AI Prompt for Phase $PHASE_NUM:"
echo ""
echo "$PROMPT"
echo ""
echo "---"
echo "💡 Tip: Copy the prompt above and use it with your AI assistant:"
echo "   cursor --prompt \"$PROMPT\""
echo "   or paste it into Claude/ChatGPT"
