# 🔥 URGENT: Fix GitHub Token Issue

## ❌ Current Error
```
RepositoryToken is invalid. Please ensure the Github repository exists and the RepositoryToken is for an admin of the repository
```

## ✅ Solution

You need to create a **GitHub Personal Access Token** with admin permissions and add it as a repository secret.

### Quick Fix Steps:

1. **Create Personal Access Token**:
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `admin:repo_hook` (Full control of repository hooks)
     - ✅ `workflow` (Update GitHub Action workflows)
   - Copy the generated token

2. **Add Repository Secret**:
   - Go to: https://github.com/Jandev/guid-api/settings/secrets/actions
   - Click "New repository secret"
   - Name: `DEPLOYMENT_PAT`
   - Value: (paste your token from step 1)
   - Click "Add secret"

3. **Re-run the workflow**:
   - The deployment should now work

## 🤔 Why is this needed?

Azure Static Web Apps needs to:
- Create GitHub Actions workflows in your repository
- Set up webhooks for automatic deployments
- Manage deployment keys and secrets

The default `GITHUB_TOKEN` doesn't have admin permissions to do this.

## 🔒 Security Note

- The token should be created by a repository admin
- Set an expiration date (90 days recommended)
- Store it as a repository secret (never commit to code)
- You can revoke it anytime from GitHub settings

---

💡 **After adding the `DEPLOYMENT_PAT` secret, your deployment will work!**