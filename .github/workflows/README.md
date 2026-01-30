# GitHub Actions Workflow for Windows Container

This workflow **fully automates** building Windows Server Core containers using GitHub Actions variables.

## 🤖 Fully Automated Setup

### 1. Set Variables (One-time setup)

**Settings → Secrets and variables → Actions → Variables tab → New repository variable**

Add this variable:
- `DOCKER_USERNAME` - Your Docker Hub username (e.g., `casjaysdevdocker`)

**Settings → Secrets and variables → Actions → Secrets tab → New repository secret**

Add this secret:
- `DOCKER_PASSWORD` - Your Docker Hub password or access token

### 2. That's It! 🎉

The workflow automatically:
- ✅ Builds on every push to main/master/develop
- ✅ Builds monthly (1st of month at 2 AM UTC)
- ✅ Auto-detects repo name from GitHub
- ✅ Auto-generates image name: `<username>/<repo-name>`
- ✅ Auto-creates tags: `latest` and `YYMM` format
- ✅ Auto-extracts metadata from git
- ✅ Auto-pushes to Docker Hub (if credentials set)
- ✅ Creates build summary in Actions tab

## 🏷️ Automatic Image Tags

**Format**: `<DOCKER_USERNAME>/<repo-name>:<tag>`

Examples for January 2026:
- `casjaysdevdocker/windows:latest`
- `casjaysdevdocker/windows:2601`

## ⚙️ Automatic Metadata

All OCI labels and annotations automatically include:
- Build date and time
- Git commit hash (short)
- Repository URL from GitHub
- Docker Hub URL
- Version (YYMM format)

## 🔄 When Builds Run

1. **On Push** - Any push to main/master/develop branches
2. **On Pull Request** - Tests build but doesn't push
3. **Monthly** - Automatic rebuild on 1st of each month at 2 AM UTC
4. **Manual** - Click "Run workflow" in Actions tab

## 📊 Build Summary

After each successful build, check the Actions tab for:
- Image name and tags
- Build date and commit
- Pull command
- Image size
- All metadata labels

## 🚫 No Variables? No Problem!

If `DOCKER_USERNAME` variable is not set:
- Falls back to repository owner name
- Example: `owner/windows:latest`

If `DOCKER_PASSWORD` secret is not set:
- Build and test still run
- Push step is automatically skipped
- Perfect for testing or forked repos

## 📝 Example Output

```
## 📦 Container Build Summary

**Image:** `casjaysdevdocker/windows`
**Tags:**
- `latest`
- `2601`

**Build Date:** 202601231800
**Commit:** `a1b2c3d`

### 🚀 Pull Command
```powershell
docker pull casjaysdevdocker/windows:latest
```

## 🔧 Advanced: Override Image Name

Want to use a different Docker Hub username? Just set the variable:

**Settings → Secrets and variables → Actions → Variables**
- `DOCKER_USERNAME` = `yourusername`

Result: `yourusername/windows:latest`

## 🛠️ Troubleshooting

### Build succeeds but doesn't push
- Check that `DOCKER_PASSWORD` secret is set
- Verify `DOCKER_USERNAME` variable or repo owner is correct
- Ensure you're not building from a pull request

### Wrong image name
- Set `DOCKER_USERNAME` variable to your Docker Hub username
- Or it defaults to GitHub repo owner

### Need different tags?
- Edit `.github/workflows/build-windows.yml`
- Modify the `TAG_YYMM` format in the metadata step

## 📅 Monthly Auto-Build

The workflow includes a cron schedule:
```yaml
schedule:
  - cron: '0 2 1 * *'  # 1st of month at 2 AM UTC
```

This ensures:
- Fresh base image updates
- Latest security patches
- Regular image rebuilds

To disable: Remove the `schedule:` section from the workflow file.
