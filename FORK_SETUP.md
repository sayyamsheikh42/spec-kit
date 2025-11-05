# Fork Setup Guide

This guide helps you set up a fork of spec-kit with custom branding and repository references.

## Step 1: Fork on GitHub

1. Go to https://github.com/github/spec-kit
2. Click "Fork" button
3. Choose your GitHub account/organization
4. Clone your fork locally

## Step 2: Update Repository References

### Files to Update:

1. **`src/specify_cli/__init__.py`**:
   - Line 562-563: Update `repo_owner` and `repo_name`
   - Line 168: Update `TAGLINE`
   - Line 160-165: Update ASCII banner (optional)
   - Line 383-399: Update version/package name references (if publishing separately)

2. **`pyproject.toml`** (if publishing to PyPI separately):
   - Line 2: Update `name` field
   - Line 4: Update `description`
   - Line 16: Update script command name (optional)

3. **`.github/workflows/pypi.yml`** (if publishing):
   - Update package name modifications in the workflow

## Step 3: Customization Options

### Option A: Keep Same Package Name (Recommended for private forks)
- Keep `specify-cli` as package name
- Keep `specify` as CLI command
- Only update repository references

### Option B: Separate Package (For public forks with different branding)
- Create new package name (e.g., `spec-kit-custom`)
- Create new CLI command (e.g., `specify-custom`)
- Update all references

### Option C: Dual Package (Like peer's approach)
- Keep `src/specify_cli/` for reference
- Create `src/your_package_cli/` for your version
- Update `pyproject.toml` to build from your package

## Step 4: Required Changes

### Minimum Changes (Repository References Only)

```python
# In src/specify_cli/__init__.py

# Line 562-563: Update these
repo_owner = "YOUR_GITHUB_USERNAME"  # or organization
repo_name = "YOUR_FORK_NAME"

# Line 168: Update tagline (optional but recommended)
TAGLINE = "Your Fork Name - Spec-Driven Development Toolkit"
```

### Full Customization (If Publishing Separately)

1. **Update package name in `pyproject.toml`**:
   ```toml
   [project]
   name = "your-package-name"
   ```

2. **Update CLI command name** (optional):
   ```toml
   [project.scripts]
   your-command = "specify_cli:main"
   ```

3. **Update version function** in `__init__.py`:
   ```python
   def get_version() -> str:
       try:
           return version("your-package-name")
       except PackageNotFoundError:
           return "unknown"
   ```

## Step 5: Test Your Fork

1. **Test locally**:
   ```bash
   pip install -e .
   your-command --help
   ```

2. **Test template download**:
   ```bash
   your-command init test-project --ai claude
   ```

3. **Verify repository references**:
   - Check that templates download from your fork
   - Verify release package names match your fork

## Step 6: Publishing (Optional)

If you want to publish to PyPI:

1. Update `.github/workflows/pypi.yml` with your package name
2. Set up PyPI API token in GitHub Secrets
3. Create a release tag to trigger publishing

## Quick Reference

### Current Values (Base spec-kit):
- Repository: `github/spec-kit`
- Package: `specify-cli`
- Command: `specify`
- Tagline: `GitHub Spec Kit - Spec-Driven Development Toolkit`

### Your Fork Values (Example):
- Repository: `YOUR_USERNAME/YOUR_FORK_NAME`
- Package: `YOUR_PACKAGE_NAME` (optional)
- Command: `YOUR_COMMAND` (optional)
- Tagline: `Your Fork Name - Spec-Driven Development Toolkit`

## Notes

- **Keep it simple**: If you're just experimenting, only update repository references
- **Separate package**: Only needed if you want to publish to PyPI with a different name
- **Maintain compatibility**: Consider keeping the same command name for user familiarity
- **Document changes**: Keep a CHANGELOG of your fork-specific modifications

