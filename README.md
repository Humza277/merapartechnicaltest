# Dynamic String Web Service

This project implements a cloud-based service that serves an HTML page with a dynamically updatable string without requiring redeployment. The solution is built using AWS services and Infrastructure as Code (Terraform).

## Architecture

The solution uses the following AWS services:
- **API Gateway**: Handles HTTP requests
- **Lambda**: Serves the HTML page and processes string updates
- **DynamoDB**: Stores the dynamic string

## Project Structure

```
/terraform/             # Root Terraform configuration
/modules/dynamodb/      # Defines the DynamoDB table
/modules/iam/           # Defines IAM roles and policies
/modules/lambda/        # Defines Lambda function configuration
/modules/api_gateway/   # Defines API Gateway configuration
/lambda/                # Python-based Lambda function for serving HTML
/docs/                  # Documentation including solution.pdf
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

Open the API endpoint URL in a web browser to see the current dynamic string. The page displays the string in an H1 element and provides a form to update it.

### Update the String via Web UI

1. Enter a new string value in the text input field on the web page
2. Click the "Update" button
3. The page will refresh automatically after the update

### Update the String via API

To update the string programmatically, send a POST request to the `/update` endpoint:

```bash
curl -X POST \
  [API_ENDPOINT]/update \
  -H 'Content-Type: application/json' \
  -d '{"value": "new dynamic string"}'
```

### Example Requests

After deployment, Terraform will output example curl commands for accessing the service.

## Implementation Details

### DynamoDB Table

- Table Name: `StringTable`
- Partition Key: `key` (String)
- Item Format: `{ "key": "string", "value": "the saved string" }`
- Billing Mode: PAY_PER_REQUEST

### Lambda Function

The Lambda function (`lambda/lambda.py`) handles:
- GET requests: Serves HTML with the current string value
- POST requests: Updates the string in DynamoDB

### IAM Permissions

The Lambda function has permissions to:
- Read and write to the DynamoDB table
- Create and write to CloudWatch Logs

## Clean Up

To remove all created resources:

```bash
cd terraform
terraform destroy
```

## Documentation

For more detailed information about the architecture, design decisions, and trade-offs, refer to the [solution document](docs/solution.pdf).

## Future Improvements

1. Add authentication for string updates
2. Implement caching for better performance
3. Add CloudFront for global content delivery
4. Implement CI/CD pipeline for automated deployment
5. Add monitoring and alerting