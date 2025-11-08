# Wiki Setup Instructions

This directory contains all documentation for the Rails SaaS Kit. The documentation can be synced with the GitHub wiki repository for easy web access.

## Current Setup

The `wiki/` directory in this repository contains all documentation files that were previously in the root directory. This keeps the project root clean while maintaining all documentation in an organized structure.

## Syncing with GitHub Wiki (Optional)

If you want to make this documentation available through GitHub's wiki interface, follow these steps:

### Step 1: Initialize GitHub Wiki

1. Go to your GitHub repository: `https://github.com/aliumairdev/rails_saas_kit`
2. Click on the "Wiki" tab
3. Click "Create the first page" to initialize the wiki
4. Create a simple placeholder page (you can delete it later)

### Step 2: Clone the Wiki Repository

```bash
# Clone the wiki repository
git clone https://github.com/aliumairdev/rails_saas_kit.wiki.git temp_wiki
```

### Step 3: Copy Documentation to Wiki

```bash
# Copy all documentation from the wiki directory to the cloned wiki
cp -r wiki/* temp_wiki/

# Navigate to the wiki repository
cd temp_wiki

# Add and commit all files
git add -A
git commit -m "Initial wiki setup with comprehensive documentation"

# Push to GitHub
git push origin master
```

### Step 4: Set Up as Git Submodule (Optional)

If you want to manage the wiki as a git submodule in the main repository:

```bash
# From the main repository root
cd /path/to/rails_saas_kit

# Remove the current wiki directory
rm -rf wiki

# Add the wiki as a submodule
git submodule add https://github.com/aliumairdev/rails_saas_kit.wiki.git wiki

# Commit the submodule
git add .gitmodules wiki
git commit -m "Add wiki as git submodule"
git push
```

### Step 5: Updating Documentation

**If using as a regular directory (current setup):**
```bash
# Edit files in wiki/
# Commit changes to main repository
git add wiki/
git commit -m "Update documentation"
git push

# Manually sync to GitHub wiki if needed
```

**If using as a submodule:**
```bash
# Navigate to wiki directory
cd wiki

# Make changes and commit
git add .
git commit -m "Update documentation"
git push

# Go back to main repo and update submodule reference
cd ..
git add wiki
git commit -m "Update wiki submodule"
git push
```

## Documentation Structure

```
wiki/
├── Home.md                      # Wiki landing page with navigation
├── API_CLIENTS.md              # API client documentation
├── API_DOCUMENTATION.md        # Complete API reference
├── ATTRIBUTION.md              # Credits and acknowledgments
├── CHANGELOG.md                # Project changelog
├── COMPONENTS_README.md        # UI components guide
├── CONTRIBUTING.md             # Contribution guidelines
├── DEPLOYMENT.md               # Deployment instructions
├── IMPLEMENTATION_STATUS.md    # Feature implementation status
├── INTEGRATION_STATUS.md       # Integration status
├── JAVASCRIPT.md               # JavaScript documentation
├── OAUTH_SETUP.md              # OAuth configuration
├── README_DEPLOYMENT.md        # Additional deployment info
├── TAILWINDCSS.md              # TailwindCSS styling guide
├── TESTING_ROADMAP.md          # Testing strategy
├── TEST_SETUP_STATUS.md        # Test setup status
├── TEST_SUITE_SUMMARY.md       # Test suite overview
├── db-seeds/
│   └── README.md               # Database seeding docs
└── test/
    └── README.md               # Testing documentation
```

## Benefits of This Structure

1. **Clean Repository Root** - Main README stays focused on quick start and overview
2. **Organized Documentation** - All docs in one place with clear structure
3. **Easy Navigation** - Home.md provides clear navigation to all documentation
4. **GitHub Wiki Integration** - Can easily sync with GitHub wiki for web interface
5. **Version Control** - Documentation changes tracked alongside code changes
6. **Offline Access** - All documentation available locally

## Accessing Documentation

### In Repository
- Browse files directly in the `wiki/` directory
- Start at [Home.md](Home.md) for the full index

### On GitHub
- Files are browsable in the repository at `/wiki/`
- If synced to wiki: Access via the Wiki tab on GitHub

### Locally
```bash
# View in terminal
cat wiki/Home.md

# Open in browser (macOS)
open wiki/Home.md

# Open in browser (Linux)
xdg-open wiki/Home.md
```

## Maintenance

- Keep documentation up to date as features are added
- Update Home.md when adding new documentation files
- Consider syncing to GitHub wiki periodically for better web accessibility
- Update internal links if moving files between directories
