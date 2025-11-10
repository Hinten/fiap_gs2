# Deployment Guide - Code Review Agent

This guide covers deploying the Code Review Agent to AWS Lambda using the Serverless Framework.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Serverless Framework** installed globally
4. **Docker** (for packaging Python dependencies)
5. **Node.js and npm** (for Serverless Framework)

## Setup

### 1. Install Serverless Framework

```bash
npm install -g serverless
npm install --save-dev serverless-python-requirements
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and Region
```

### 3. Prepare Environment Variables

Store secrets in AWS Systems Manager Parameter Store:

```bash
# GitHub Token
aws ssm put-parameter \
  --name /code-review-agent/github-token \
  --value "your_github_token" \
  --type SecureString

# OpenAI API Key
aws ssm put-parameter \
  --name /code-review-agent/openai-key \
  --value "your_openai_key" \
  --type SecureString

# JWT Secret
aws ssm put-parameter \
  --name /code-review-agent/jwt-secret \
  --value "your_jwt_secret" \
  --type SecureString
```

### 4. Copy Serverless Configuration

```bash
cp serverless.yml.example serverless.yml
# Edit serverless.yml to reference your SSM parameters
```

## Deployment

### Development Environment

```bash
# Deploy to dev stage
serverless deploy --stage dev

# View logs
serverless logs -f api --stage dev --tail

# Invoke function directly
serverless invoke -f api --stage dev
```

### Production Environment

```bash
# Deploy to production
serverless deploy --stage prod

# Note: Review all settings before deploying to production
```

## Post-Deployment

### 1. Note Your API Endpoint

After deployment, Serverless will output your API Gateway URL:

```
endpoints:
  ANY - https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/{proxy+}
```

### 2. Test the API

```bash
# Health check
curl https://your-api-url/health

# Get API info
curl https://your-api-url/

# View API documentation
open https://your-api-url/docs
```

### 3. Configure GitHub Webhook

1. Go to your GitHub repository settings
2. Navigate to Webhooks
3. Add webhook with:
   - URL: `https://your-api-url/api/v1/github/webhook`
   - Content type: `application/json`
   - Secret: Your webhook secret
   - Events: Pull requests, Push

## Monitoring

### View Logs

```bash
# Tail logs
serverless logs -f api --tail

# View specific time range
serverless logs -f api --startTime 1h
```

### CloudWatch Metrics

Access metrics in AWS Console:
- Lambda Invocations
- Error count
- Duration
- Throttles

## Troubleshooting

### Cold Start Issues

If Lambda cold starts are problematic:

1. **Provisioned Concurrency**:
```yaml
# In serverless.yml
functions:
  api:
    provisionedConcurrency: 2
```

2. **Keep-Warm Plugin**:
```bash
npm install --save-dev serverless-plugin-warmup
```

### Memory Issues

If running out of memory:

```yaml
# In serverless.yml
functions:
  api:
    memorySize: 2048  # Increase from 1024
```

### Timeout Issues

For long-running operations:

```yaml
# In serverless.yml
functions:
  api:
    timeout: 900  # Max 15 minutes
```

## Cleanup

To remove all deployed resources:

```bash
serverless remove --stage dev
```

**Warning**: This will delete the DynamoDB tables and all data!

## Cost Optimization

1. **Use Lambda free tier**: 1M requests/month free
2. **DynamoDB on-demand**: Pay only for what you use
3. **API Gateway**: Free tier covers 1M calls/month
4. **CloudWatch Logs**: Set retention period to reduce costs

## Security Checklist

- [ ] All secrets stored in AWS Secrets Manager or Parameter Store
- [ ] IAM roles follow least privilege principle
- [ ] API Gateway has throttling configured
- [ ] CloudWatch alarms set up for errors
- [ ] VPC configuration if accessing private resources
- [ ] Enable AWS WAF for API Gateway
- [ ] Regular security audits with AWS Trusted Advisor

## Alternative: Docker Deployment

If you prefer Docker over Lambda:

```bash
# Build Docker image
docker build -t code-review-agent .

# Run locally
docker run -p 8000:8000 --env-file .env code-review-agent

# Deploy to AWS ECS/Fargate
# (Requires additional configuration)
```

## References

- [Serverless Framework Documentation](https://www.serverless.com/framework/docs)
- [AWS Lambda Python](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [Mangum Documentation](https://mangum.io/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)

---

**Last Updated**: 2025-11-10
