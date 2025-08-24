# PowerShell Login Guide for Azure Dev Container

## 🎯 Problem Solved

The PowerShell login script had two main issues that have been fixed:

1. **Environment Variables Not Loaded**: The script was trying to access environment variables that weren't loaded from the `.env` file
2. **Parameter Set Conflict**: The `Connect-AzAccount` command was using conflicting parameters (`-ServicePrincipal` and `-ApplicationId` together)

## ✅ Solution Implemented

### 1. New Login Script: `login-with-env.ps1`

This script:
- Loads environment variables from the `.env` file
- Then runs the original login script
- Provides clear error messages if the `.env` file is missing

### 2. Fixed PowerShell Login Command

The `Connect-AzAccount` command has been corrected to remove the conflicting `-ApplicationId` parameter:
- **Before**: `Connect-AzAccount -ServicePrincipal -ApplicationId $env:AZURE_CLIENT_ID -Credential $credential -Tenant $env:AZURE_TENANT_ID`
- **After**: `Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $env:AZURE_TENANT_ID`

### 3. Helper Script: `update-env.ps1`

This script shows you exactly what values to put in your `.env` file based on the service principal creation output.

## 🚀 How to Use

### Step 1: Create Your Service Principal

```bash
# Get your subscription ID first
az account show --query id -o tsv

# Create service principal with subscription scope
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### Step 2: Set Up Your .env File

```bash
# Copy the example file
cp env.example .env

# Edit the .env file with your values
```

Your `.env` file should look like this:
```env
# Azure Service Principal Configuration
AZURE_CLIENT_ID=12345678-1234-1234-1234-123456789012
AZURE_CLIENT_SECRET=your-secret-password
AZURE_TENANT_ID=12345678-1234-1234-1234-123456789012
AZURE_SUBSCRIPTION_ID=your-subscription-id
```

### Step 3: Login with PowerShell

```powershell
# Use the new login script that loads environment variables
pwsh -File login-with-env.ps1
```

## 🔧 Available Scripts

| Script | Purpose |
|--------|---------|
| `login-with-env.ps1` | Main login script that loads `.env` and authenticates |
| `update-env.ps1` | Helper script showing how to map service principal values |
| `login-with-sp.ps1` | Original login script (used internally by `login-with-env.ps1`) |

## 🛠️ Troubleshooting

### Environment Variables Not Found
If you get an error about missing environment variables:
1. Make sure you have a `.env` file in the current directory
2. Check that the `.env` file has the correct format (no spaces around `=`)
3. Verify that your service principal credentials are correct

### Login Fails
If login fails:
1. Verify your service principal credentials are correct
2. Check that the service principal has the correct permissions
3. Ensure the service principal hasn't expired
4. Try the manual login command:
   ```powershell
   $credential = New-Object PSCredential("YOUR_CLIENT_ID", (ConvertTo-SecureString "YOUR_CLIENT_SECRET" -AsPlainText -Force))
   Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant "YOUR_TENANT_ID"
   ```

### Service Principal Creation Issues
If you can't create a service principal:
1. Make sure you're logged in with `az login`
2. Verify you have the necessary permissions in your Azure subscription
3. Try creating with a more restrictive scope (resource group instead of subscription)

## 📋 Environment Variable Mapping

When you create a service principal, the output maps to your `.env` file like this:

| Service Principal Output | .env Variable |
|-------------------------|---------------|
| `appId` | `AZURE_CLIENT_ID` |
| `password` | `AZURE_CLIENT_SECRET` |
| `tenant` | `AZURE_TENANT_ID` |
| (from `az account show`) | `AZURE_SUBSCRIPTION_ID` |

## 🔒 Security Best Practices

1. **Use the most restrictive scope possible** for your service principal
2. **Regularly rotate service principal secrets**
3. **Never commit your `.env` file** to version control
4. **Use resource group scope** instead of subscription scope when possible
5. **Consider using managed identities** for production workloads

## 📝 Example Workflow

```bash
# 1. Create service principal
az ad sp create-for-rbac --name "dev-container-sp" --role "Contributor" --scopes "/subscriptions/12345678-1234-1234-1234-123456789012"

# 2. Create .env file with the output values
echo "AZURE_CLIENT_ID=appId-from-output" > .env
echo "AZURE_CLIENT_SECRET=password-from-output" >> .env
echo "AZURE_TENANT_ID=tenant-from-output" >> .env
echo "AZURE_SUBSCRIPTION_ID=12345678-1234-1234-1234-123456789012" >> .env

# 3. Login with PowerShell
pwsh -File login-with-env.ps1
```

## ✅ Success Indicators

When the login is successful, you should see:
- ✅ Environment variables loaded successfully!
- ✅ Login successful!
- ✅ Account information retrieved successfully
- Current account details displayed in a table format
