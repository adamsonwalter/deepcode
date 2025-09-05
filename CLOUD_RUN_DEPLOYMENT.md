# 🚀 DeepCode Cloud Run Deployment Guide

## Understanding Google Cloud Projects & Services

### ❌ **Common Misconception**
> "I need multiple Google Cloud projects for different apps"

### ✅ **Correct Understanding** 
**One Google Cloud Project** = **Multiple Cloud Run Services**

```
📁 Your Single Google Cloud Project
├── 🧬 deepcode-service        (DeepCode app)
├── 🌐 my-website-service      (Another app)
├── 📊 analytics-service       (Another app)
└── 🔧 api-service            (Another app)
```

When you deploy or update a service, you're only affecting **that specific service**, not the entire project!

---

## 🛠️ Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud CLI** installed ([Install guide](https://cloud.google.com/sdk/docs/install))
3. **Docker** installed (for local testing - optional)

---

## 🚀 Quick Deployment

### Method 1: Automated Script (Recommended)

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Enable required APIs
- ✅ Build your container
- ✅ Deploy to Cloud Run
- ✅ Provide you with the live URL

### Method 2: Manual Deployment

```bash
# 1. Set your project
gcloud config set project YOUR_PROJECT_ID

# 2. Enable APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# 3. Build the container
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/deepcode .

# 4. Deploy to Cloud Run
gcloud run deploy deepcode-service \
    --image gcr.io/YOUR_PROJECT_ID/deepcode \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8080 \
    --memory 2Gi \
    --cpu 2 \
    --timeout 900 \
    --max-instances 10
```

---

## 🔐 Setting Up API Keys

After deployment, you need to configure your API keys:

### Option 1: Cloud Console (Recommended)
1. Go to [Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Cloud Run** → **deepcode-service**
3. Click **"Edit & Deploy New Revision"**
4. Go to **"Variables & Secrets"** tab
5. Add these environment variables:

```
OPENAI_API_KEY=your-openai-key-here
ANTHROPIC_API_KEY=your-claude-key-here
BRAVE_API_KEY=your-brave-search-key-here
BOCHA_API_KEY=your-bocha-key-here
```

### Option 2: Command Line
```bash
gcloud run services update deepcode-service \
    --region us-central1 \
    --set-env-vars="OPENAI_API_KEY=your-key,ANTHROPIC_API_KEY=your-key"
```

---

## 📊 Managing Multiple Services

Here's how to properly manage multiple apps in one project:

### Deploy Additional Services
```bash
# Deploy a second app (e.g., a website)
gcloud run deploy my-website-service \
    --image gcr.io/YOUR_PROJECT_ID/my-website \
    --region us-central1

# Deploy a third app (e.g., an API)
gcloud run deploy my-api-service \
    --image gcr.io/YOUR_PROJECT_ID/my-api \
    --region us-central1
```

### List All Your Services
```bash
gcloud run services list
```

### Update Specific Service
```bash
# Only affects deepcode-service, not others!
gcloud run services update deepcode-service \
    --region us-central1 \
    --memory 4Gi
```

---

## 💰 Cost Management

### Resource Configuration
```yaml
# Current configuration (adjust based on usage)
Memory: 2Gi           # ~$0.0000024 per GB-second
CPU: 2 vCPUs          # ~$0.0000024 per vCPU-second  
Max Instances: 10     # Scales down to 0 when not used
Timeout: 900s         # 15 minutes max per request
```

### Cost Optimization Tips
- ✅ **Use optimized mode** in DeepCode for faster processing
- ✅ **Set appropriate max-instances** to control costs
- ✅ **Services scale to zero** when not used (no cost)
- ✅ **Monitor usage** in Cloud Console

---

## 🔧 Troubleshooting

### Common Issues

#### 1. "Project not found" Error
```bash
# Set your project correctly
gcloud config set project YOUR-ACTUAL-PROJECT-ID
gcloud config list  # Verify it's set
```

#### 2. "Permission denied" Error
```bash
# Login and set permissions
gcloud auth login
gcloud auth application-default login
```

#### 3. "Service timeout" Error
- Increase timeout: `--timeout 900`
- Use optimized mode in DeepCode
- Check memory/CPU allocation

#### 4. "Build failed" Error
- Check Dockerfile syntax
- Ensure all dependencies in requirements.txt
- Check build logs: `gcloud builds log BUILD_ID`

### Viewing Logs
```bash
# View service logs
gcloud run services logs deepcode-service --region us-central1

# Follow logs in real-time
gcloud run services logs deepcode-service --region us-central1 --follow
```

---

## 🔄 Updating Your Application

### Quick Update
```bash
# Just run the deploy script again
./deploy.sh
```

### Manual Update
```bash
# Rebuild and redeploy
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/deepcode .
gcloud run deploy deepcode-service --image gcr.io/YOUR_PROJECT_ID/deepcode --region us-central1
```

---

## 🌐 Custom Domain (Optional)

```bash
# Map a custom domain
gcloud run domain-mappings create \
    --service deepcode-service \
    --domain your-domain.com \
    --region us-central1
```

---

## 📈 Monitoring & Scaling

### View Service Details
```bash
gcloud run services describe deepcode-service --region us-central1
```

### Scale Configuration
```bash
# Adjust scaling parameters
gcloud run services update deepcode-service \
    --region us-central1 \
    --min-instances 0 \
    --max-instances 20 \
    --concurrency 80
```

---

## 🛡️ Security Best Practices

1. **Never commit secrets** to Git
2. **Use environment variables** for API keys
3. **Enable authentication** if needed:
   ```bash
   gcloud run services update deepcode-service \
       --region us-central1 \
       --no-allow-unauthenticated
   ```
4. **Use IAM** for fine-grained access control

---

## ❓ FAQ

**Q: Will updating deepcode-service affect my other services?**
A: No! Each Cloud Run service is independent.

**Q: How much will this cost?**
A: Cloud Run charges only when your service is processing requests. With the free tier, you get 2 million requests/month free.

**Q: Can I run multiple versions simultaneously?**
A: Yes! You can deploy different services or use traffic splitting for A/B testing.

**Q: What happens to my data?**
A: Cloud Run is stateless. Use Cloud Storage, Firestore, or Cloud SQL for persistent data.

---

## 🆘 Need Help?

1. **Check logs**: `gcloud run services logs deepcode-service --region us-central1`
2. **Cloud Console**: [console.cloud.google.com](https://console.cloud.google.com)
3. **DeepCode Issues**: [GitHub Issues](https://github.com/HKUDS/DeepCode/issues)
4. **Google Cloud Support**: [cloud.google.com/support](https://cloud.google.com/support)

---

**🎉 You now have DeepCode running on Google Cloud Run with proper service management!**
