# Azure Login Troubleshooting Guide

This guide helps you resolve common issues with Azure service principal authentication in the dev container.

## 🔍 Common Issues and Solutions

### 1. "AADSTS700016: Application with identifier was not found"

**Cause**: The service principal (client ID) doesn't exist or is incorrect.

**Solution**:
```bash
# Verify the service principal exists
az ad sp show --id YOUR_CLIENT_ID

# If it doesn't exist, create a new one
./create-service-principal.sh -s YOUR_SUBSCRIPTION_ID
```

### 2. "AADSTS7000215: Invalid client secret is provided"

**Cause**: The client secret is incorrect or has expired.

**Solution**:
```bash
# Create a new service principal with a fresh secret
./create-service-principal.sh -s YOUR_SUBSCRIPTION_ID

# Or reset the secret for existing service principal
az ad sp credential reset --id YOUR_CLIENT_ID --append
```

### 3. "AADSTS50034: The user account does not exist"

**Cause**: The tenant ID is incorrect.

**Solution**:
```bash
# Get the correct tenant ID
az account show --query tenantId -o tsv

# Update your .env file with the correct tenant ID
```

### 4. "AADSTS50020: User account from a foreign directory"

**Cause**: The service principal exists in a different tenant.

**Solution**:
```bash
# Create the service principal in the correct tenant
az login  # Login with your user account first
./create-service-principal.sh -s YOUR_SUBSCRIPTION_ID
```

### 5. "AADSTS50105: The signed in user is not assigned to a role"

**Cause**: The service principal doesn't have the necessary permissions.

**Solution**:
```bash
# Check current role assignments
az role assignment list --assignee YOUR_CLIENT_ID

# Add Contributor role to subscription
az role assignment create \
  --assignee YOUR_CLIENT_ID \
  --role "Contributor" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### 6. "AADSTS50011: The reply URL specified in the request does not match"

**Cause**: This error typically occurs with web applications, not service principals.

**Solution**: This shouldn't happen with service principal authentication. Check if you're using the correct authentication method.

## 🔧 Debugging Steps

### Step 1: Verify Environment Variables

```bash
# Check if environment variables are set
echo "AZURE_CLIENT_ID: ${AZURE_CLIENT_ID:0:8}..."
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID"

# Check if .env file exists and is loaded
ls -la .env
source .env
```

### Step 2: Test Manual Login

```bash
# Try manual login with debug output
az login --service-principal \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID" \
  --debug
```

### Step 3: Verify Service Principal

```bash
# Check if service principal exists
az ad sp show --id "$AZURE_CLIENT_ID"

# Check role assignments
az role assignment list --assignee "$AZURE_CLIENT_ID"
```

### Step 4: Check Azure CLI Version

```bash
# Verify Azure CLI version
az version

# Update if needed
az upgrade
```

## 🛠️ PowerShell Troubleshooting

### Common PowerShell Issues

1. **Module not found**:
   ```powershell
   # Install Az module
   Install-Module -Name Az -Repository PSGallery -Force
   ```

2. **Execution policy**:
   ```powershell
   # Check execution policy
   Get-ExecutionPolicy

   # Set if needed (run as administrator)
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Credential issues**:
   ```powershell
   # Test with explicit credential
   $credential = New-Object PSCredential($env:AZURE_CLIENT_ID, (ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force))
   Connect-AzAccount -ServicePrincipal -ApplicationId $env:AZURE_CLIENT_ID -Credential $credential -Tenant $env:AZURE_TENANT_ID
   ```

## 🔒 Security Best Practices

### 1. Use Least Privilege
```bash
# Use resource group scope instead of subscription scope
az ad sp create-for-rbac \
  --name "dev-container-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP"
```

### 2. Regular Secret Rotation
```bash
# Rotate service principal secrets regularly
az ad sp credential reset --id YOUR_CLIENT_ID --append
```

### 3. Monitor Usage
```bash
# Check service principal sign-ins
az monitor activity-log list \
  --resource-id "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --query "[?contains(claimsMap.appid, 'YOUR_CLIENT_ID')]"
```

## 📋 Quick Fix Checklist

- [ ] Verify service principal exists: `az ad sp show --id YOUR_CLIENT_ID`
- [ ] Check role assignments: `az role assignment list --assignee YOUR_CLIENT_ID`
- [ ] Verify tenant ID: `az account show --query tenantId -o tsv`
- [ ] Test manual login with debug: `az login --service-principal --debug`
- [ ] Check Azure CLI version: `az version`
- [ ] Verify environment variables are loaded
- [ ] Try creating a new service principal

## 🆘 Getting Help

If you're still having issues:

1. **Check the logs**: The updated login scripts now provide detailed error messages
2. **Use debug mode**: Add `--debug` to manual login commands
3. **Verify permissions**: Ensure your user account can create service principals
4. **Check Azure status**: Visit [Azure Status](https://status.azure.com/)

## 📞 Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| AADSTS700016 | Application not found | Create new service principal |
| AADSTS7000215 | Invalid client secret | Reset or create new secret |
| AADSTS50034 | User account doesn't exist | Check tenant ID |
| AADSTS50020 | Foreign directory | Create in correct tenant |
| AADSTS50105 | No role assigned | Assign Contributor role |
| AADSTS50011 | Reply URL mismatch | Use service principal auth |

## 🔄 Alternative Authentication Methods

If service principal authentication continues to fail, consider:

1. **Managed Identity** (if running in Azure)
2. **User Authentication** (for development)
3. **Certificate-based authentication**
4. **Azure CLI token authentication**
