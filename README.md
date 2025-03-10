# Dynamic String Web Service

This project implements a cloud-based service that serves an HTML page with a dynamically updatable string without requiring redeployment. The solution is built using AWS serverless services and Infrastructure as Code (Terraform).

## Architecture

The solution uses the following AWS services:
- **API Gateway (HTTP API)**: Handles HTTP requests with low latency and cost
- **Lambda**: Serves the HTML page and processes string updates via Python 3.9 runtime
- **DynamoDB**: Stores the dynamic string with on-demand capacity
- **IAM**: Provides least-privilege permissions for service components

## Project Structure

```
/terraform/             # Root Terraform configuration
/modules/dynamodb/      # Defines the DynamoDB table with PAY_PER_REQUEST billing
/modules/iam/           # Defines IAM roles and policies following least privilege
/modules/lambda/        # Defines Lambda function configuration for Python 3.9
/modules/api_gateway/   # Defines API Gateway HTTP API configuration
/lambda/                # Python-based Lambda function for serving HTML and API endpoints
/docs/                  # Technical documentation
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (v1.2.0 or later)
- Python 3.9 installed (for local development)

## Setup and Deployment

1. Clone this repository
2. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Deploy the infrastructure:
   ```bash
   terraform apply
   ```
5. Note the API endpoint URL from the output

## Usage

### View the Dynamic String Page

Open the API endpoint URL in a web browser to see the current dynamic string. The page displays the string in an H1 element.

### Update the String via API

The string can only be updated via API calls. To update the string programmatically, send a POST request to the `/update` endpoint:

```bash
curl -X POST \
  [API_ENDPOINT]/update \
  -H 'Content-Type: application/json' \
  -d '{"value": "new dynamic string"}'
```

### Example Requests

After deployment, Terraform will output example curl commands for accessing and updating the string:

```
api_url = "https://[API_ID].execute-api.[REGION].amazonaws.com"
curl_get_example = "curl https://[API_ID].execute-api.[REGION].amazonaws.com"
curl_update_example = "curl -X POST https://[API_ID].execute-api.[REGION].amazonaws.com/update -H 'Content-Type: application/json' -d '{\"value\":\"new string value\"}'"
```

## Implementation Details

### DynamoDB Table

- Table Name: `StringTable`
- Partition Key: `key` (String)
- Item Format: `{ "key": "string", "value": "the saved string" }`
- Billing Mode: PAY_PER_REQUEST (auto-scaling)
- Initial Value: "hello world"

### Lambda Function

The Python Lambda function (`lambda/lambda.py`) handles:
- GET requests: Serves HTML with the current string value fetched from DynamoDB
- POST requests: Updates the string in DynamoDB
- Dynamic HTML Generation: Creates HTML at runtime, reflecting the latest string value

### IAM Permissions

The Lambda function has permissions to:
- Read and write to the specific DynamoDB table
- Create and write to CloudWatch Logs
- No excessive permissions, following least privilege principle

## How It Works Without Redeployment

The key to updating the string without redeployment is:
1. The string is stored in DynamoDB, not in the application code
2. HTML is generated dynamically at runtime by the Lambda function
3. The Lambda retrieves the current string value from DynamoDB for each request
4. Updates change only the database value, not the code or infrastructure

## Clean Up

To remove all created resources:

```bash
cd terraform
terraform destroy
```

## Documentation

For more detailed information about the architecture, design decisions, and trade-offs, refer to the [technical solution document](docs/dynamic_string_solution.md).

## Future Improvements

1. Add authentication for string updates (API Gateway authorizers or Cognito)
2. Implement caching for better performance (API Gateway caching or CloudFront)
3. Add CloudFront for global content delivery and lower latency
4. Implement CI/CD pipeline for automated testing and deployment
5. Add monitoring, alerting, and observability enhancements
6. Support multiple dynamic strings with more complex data models
7. Implement change history and audit logging