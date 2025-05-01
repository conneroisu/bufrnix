#!/bin/bash
# Reset Git History - Make Current Version First Commit
# This script resets your Git history and makes the current state the initial commit

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed or not in PATH"
    exit 1
fi

# Check if current directory is a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Current directory is not a Git repository"
    exit 1
fi

# Function to confirm dangerous operations
confirm_action() {
    read -p "This action will COMPLETELY RESET your Git history and cannot be undone. Continue? (y/N): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
}

echo "This script will reset your Git history and make your current version the first commit."
echo "WARNING: This is a destructive operation that cannot be undone."
confirm_action

# Create a temporary branch to store the current state
echo "Step 1: Creating a temporary branch with your current changes..."
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse HEAD)
temp_branch="temp_branch_$(date +%s)"
git checkout -b "$temp_branch"

# Make sure all changes are committed
if [[ -n $(git status --porcelain) ]]; then
    echo "Uncommitted changes detected. Committing them before proceeding..."
    git add -A
    git commit -m "Temporary commit before history reset"
fi

# Create an orphan branch
echo "Step 2: Creating an orphan branch..."
new_branch="new_history_$(date +%s)"
git checkout --orphan "$new_branch"

# Add all files from the temporary branch
echo "Step 3: Adding all current files to the new orphan branch..."
git reset
git add -A

# Commit the current state as the first commit
echo "Step 4: Creating initial commit with current state..."
git commit -m "Initial commit"

# Verify branches
echo "Step 5: Verifying the new branch..."
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Number of commits: $(git rev-list --count HEAD)"

# Rename the new branch to main/master (depending on what was used)
echo "Step 6: Replacing main branch with new history..."
if git show-ref --verify --quiet refs/heads/main; then
    target_branch="main"
elif git show-ref --verify --quiet refs/heads/master; then
    target_branch="master"
else
    target_branch="$current_branch"
fi

echo "Replacing $target_branch branch with new history..."
git branch -D "$target_branch"
git branch -m "$target_branch"

# Clean up
echo "Step 7: Cleaning up temporary branch..."
git branch -D "$temp_branch" 2>/dev/null || true

echo
echo "History reset complete! Your current state is now the initial commit."
echo "To push this to a remote repository, you will need to force push:"
echo "  git push -f origin $target_branch"
echo
echo "WARNING: Force pushing will overwrite the remote repository history!"
echo "Make sure any other contributors are aware of this change."
echo
echo "Current Git status:"
git status --short

exit 0
