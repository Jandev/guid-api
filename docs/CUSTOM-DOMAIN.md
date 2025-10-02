# Custom Domain Setup for Azure Static Web Apps

This guide explains how to configure the custom domain `guid.codes` for your Azure Static Web Apps deployment.

## 🌐 Overview

Your Azure Static Web App will be configured with:
- **Primary Domain**: `guid.codes`
- **Default Azure Domain**: `{app-name}.azurestaticapps.net` (fallback)
- **SSL Certificate**: Automatically provisioned by Azure
- **CDN**: Global content delivery network

## 📋 Prerequisites

1. **Azure Static Web App with Standard SKU** (required for custom domains)
2. **Domain ownership** of `guid.codes`
3. **DNS management access** for the domain
4. **Azure CLI** or Azure Portal access

## 🚀 Automated Setup (via GitHub Actions)

The GitHub Actions workflow automatically:

1. **Deploys infrastructure** with Standard SKU
2. **Configures custom domain** in Azure Static Web App
3. **Provides DNS instructions** in deployment output

### Required Configuration

Set these GitHub repository variables (optional, with defaults):

| Variable | Default | Description |
|----------|---------|-------------|
| `CUSTOM_DOMAIN_NAME` | `guid.codes` | Your custom domain |
| `ENABLE_CUSTOM_DOMAIN` | `true` | Enable custom domain setup |

## 🔧 DNS Configuration

After deployment, configure DNS for your domain:

### Option 1: CNAME Record (Recommended)

Create a CNAME record in your DNS provider:

```
Type: CNAME
Name: @  (or leave blank for root domain)
Value: <your-static-web-app>.azurestaticapps.net
```

### Option 2: APEX Domain with ALIAS/ANAME

For root domains, if your DNS provider supports ALIAS or ANAME records:

```
Type: ALIAS (or ANAME)
Name: guid.codes
Value: <your-static-web-app>.azurestaticapps.net
```

### Option 3: A Record with IP Address

If CNAME/ALIAS not supported for root domain:

```
Type: A
Name: @
Value: [Get IP from Azure portal]
```

## 📋 Step-by-Step Setup

### 1. Deploy with Custom Domain

The GitHub Actions workflow will automatically deploy with custom domain configuration when you push to main branch.

### 2. Verify Azure Configuration

Check that the Static Web App was created with custom domain:

```bash
# List static web apps
az staticwebapp list --output table

# Show custom domain configuration
az staticwebapp hostname show \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api" \
  --hostname "guid.codes"
```

### 3. Configure DNS

Set up the CNAME record with your DNS provider pointing to the Azure Static Web App default hostname.

### 4. Validate Domain

Azure will automatically validate domain ownership and provision SSL certificate:

```bash
# Check domain validation status
az staticwebapp hostname show \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api" \
  --hostname "guid.codes" \
  --query "status"
```

## 🔍 Manual Configuration (Alternative)

If you prefer manual setup:

### 1. Add Custom Domain via Azure CLI

```bash
# Add custom domain
az staticwebapp hostname set \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api" \
  --hostname "guid.codes"
```

### 2. Add Custom Domain via Azure Portal

1. Go to Azure Portal → Static Web Apps
2. Select your app (`guid-api-swa`)
3. Navigate to **Custom domains**
4. Click **+ Add**
5. Enter `guid.codes`
6. Follow validation instructions

## 🔐 SSL Certificate

Azure automatically provisions and manages SSL certificates:

- **Automatic renewal**: No manual intervention required
- **TLS 1.2/1.3 support**: Modern encryption standards
- **Certificate validation**: Automatic domain validation
- **Multiple domains**: Supports www and non-www variants

## 🌍 DNS Provider Examples

### Cloudflare

```
Type: CNAME
Name: guid.codes
Target: <your-app>.azurestaticapps.net
Proxy status: DNS only (grey cloud)
```

### GoDaddy

```
Type: CNAME
Host: @
Points to: <your-app>.azurestaticapps.net
TTL: 600 (or default)
```

### Route 53 (AWS)

```
Type: CNAME
Name: guid.codes
Value: <your-app>.azurestaticapps.net
```

## 📊 Verification

### Test Domain Resolution

```bash
# Check DNS resolution
nslookup guid.codes

# Test HTTP response
curl -I https://guid.codes

# Verify SSL certificate
openssl s_client -connect guid.codes:443 -servername guid.codes
```

### Monitor in Azure Portal

1. **Static Web Apps** → Your app → **Custom domains**
2. Check validation status
3. Monitor SSL certificate status
4. View domain configuration

## 🔧 Troubleshooting

### Common Issues

1. **DNS Propagation Delay**
   - Wait 24-48 hours for global DNS propagation
   - Use different DNS resolvers to test
   - Clear local DNS cache

2. **CNAME Conflicts**
   - Remove existing A records for the domain
   - Ensure no conflicting DNS entries
   - Use DNS checker tools

3. **SSL Certificate Issues**
   - Ensure DNS points correctly to Azure
   - Wait for automatic certificate provisioning
   - Check domain validation status

4. **Domain Validation Failed**
   - Verify CNAME record is correct
   - Check DNS propagation globally
   - Ensure no proxy/CDN interference

### Verification Commands

```bash
# Check Azure Static Web App status
az staticwebapp show \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api"

# List all hostnames
az staticwebapp hostname list \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api"

# Check specific domain status
az staticwebapp hostname show \
  --name "guid-api-swa" \
  --resource-group "rg-guid-api" \
  --hostname "guid.codes"
```

### DNS Debugging Tools

- **DNS Checker**: https://dnschecker.org/
- **DNS Propagation**: https://www.whatsmydns.net/
- **SSL Test**: https://www.ssllabs.com/ssltest/

## 📝 Notes

1. **Standard SKU Required**: Custom domains require Azure Static Web Apps Standard tier
2. **Root Domain Support**: Use CNAME for www, ALIAS/ANAME for root domain if supported
3. **Multiple Domains**: You can add both `guid.codes` and `www.guid.codes`
4. **Staging Environments**: Custom domains apply to production environment only
5. **Geographic Distribution**: Azure provides global CDN automatically

## 🔄 Post-Setup

After successful domain configuration:

1. **Update API documentation** to reference `https://guid.codes/api/`
2. **Test all endpoints** with custom domain
3. **Monitor SSL certificate** renewal (automatic)
4. **Set up monitoring** for domain availability
5. **Configure redirects** if needed (www → non-www or vice versa)

---

**🎉 Success!** Your GUID API will be available at `https://guid.codes/` with automatic SSL and global CDN distribution.