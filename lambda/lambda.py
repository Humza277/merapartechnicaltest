#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Dynamic String Web Service - Lambda Function

This Lambda function serves as both the frontend and backend for the Dynamic String Web Service.
It handles two main operations:
1. Serving an HTML page with the current string value (GET /)
2. Updating the string value in DynamoDB (POST /update)

The key feature is that string updates don't require redeployment because:
- The string is stored in DynamoDB, not in the application code
- HTML is generated dynamically at runtime, incorporating the latest data
- Updates only change the database value, not the code or infrastructure

Environment Variables:
- TABLE_NAME: Name of the DynamoDB table storing the string (default: StringTable)
"""

import json
import os
import boto3
from botocore.exceptions import ClientError

# Initialize AWS resources and configuration
# Use environment variable for table name to make it configurable without code changes
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'StringTable')
table = dynamodb.Table(table_name)
string_key = 'string'  # Partition key value for the string item

def handler(event, context):
    """
    Lambda handler function - entry point for all requests
    
    This function routes requests based on HTTP method and path:
    - GET /: Display HTML page with the current string
    - POST /update: Update the string value in DynamoDB
    - All other paths/methods: Return 404 Not Found
    
    Parameters:
        event (dict): AWS Lambda event object containing request data
        context (object): AWS Lambda context object
        
    Returns:
        dict: Response object with statusCode, headers, and body
    """
    # Extract HTTP method and path from the API Gateway event structure
    http_method = event.get('requestContext', {}).get('http', {}).get('method', '')
    path = event.get('requestContext', {}).get('http', {}).get('path', '')
    
    # Route the request to the appropriate handler based on method and path
    if http_method == 'GET' and path == '/':
        return serve_html()
    elif http_method == 'POST' and path == '/update':
        return update_string(event)
    else:
        # Return 404 for any unhandled routes
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'text/plain'
            },
            'body': 'Not Found'
        }

def serve_html():
    """
    Generate and serve HTML page with the current dynamic string
    
    This function:
    1. Retrieves the current string value from DynamoDB
    2. Dynamically generates HTML that includes this string
    3. Returns the HTML response to be displayed in the user's browser
    
    The HTML includes:
    - The dynamic string displayed in an H1 element
    - API usage information for updating the string via curl
    
    Returns:
        dict: Response object with HTML content
    """
    try:
        # Get the current string from DynamoDB
        response = table.get_item(Key={'key': string_key})
        current_string = response.get('Item', {}).get('value', 'No string found')
        
        # Generate a responsive HTML page with the dynamic string and API usage info
        html = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Dynamic String Service</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    margin: 0;
                    padding: 20px;
                    max-width: 800px;
                    margin: 0 auto;
                    text-align: center;
                }}
                h1 {{
                    color: #333;
                    margin-bottom: 20px;
                }}
                .container {{
                    background-color: #f9f9f9;
                    border-radius: 8px;
                    padding: 20px;
                    margin-top: 20px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }}
                .info {{
                    margin-top: 30px;
                    padding: 20px;
                    background-color: #f0f0f0;
                    border-radius: 8px;
                    text-align: left;
                }}
                code {{
                    background-color: #e0e0e0;
                    padding: 2px 5px;
                    border-radius: 3px;
                    font-family: monospace;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>The saved string is: {current_string}</h1>
            </div>
            
            <div class="info">
                <h2>API Information</h2>
                <p>This page displays a dynamically updatable string from DynamoDB.</p>
                <p>The string can only be updated via API calls using the following curl command:</p>
                <pre><code>curl -X POST [API_URL]/update \\
  -H 'Content-Type: application/json' \\
  -d '{{"value":"new string value"}}'</code></pre>
                <p>Replace <code>[API_URL]</code> with the base URL of this application.</p>
            </div>
        </body>
        </html>
        """
        
        # Return HTML response with 200 OK status
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html'
            },
            'body': html
        }
        
    except ClientError as e:
        # Handle any DynamoDB-related errors
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }

def update_string(event):
    """
    Update the string value in DynamoDB
    
    This function:
    1. Parses the JSON request body to get the new string value
    2. Validates that a value was provided
    3. Updates the string in DynamoDB
    4. Returns a success or error response
    
    The update is performed using DynamoDB's update_item operation,
    which ensures atomic updates even with concurrent requests.
    
    Parameters:
        event (dict): AWS Lambda event object containing request data
        
    Returns:
        dict: Response object with success or error message
    """
    try:
        # Parse and extract the new string value from the request body
        body = json.loads(event.get('body', '{}'))
        new_string = body.get('value', '')
        
        # Validate that a string value was provided
        if not new_string:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'No value provided'
                })
            }
        
        # Update the string value in DynamoDB
        # Using expression attributes to avoid reserved word conflicts
        table.update_item(
            Key={'key': string_key},
            UpdateExpression='SET #val = :val',
            ExpressionAttributeNames={'#val': 'value'},  # Use #val because 'value' is a reserved word
            ExpressionAttributeValues={':val': new_string}
        )
        
        # Return success response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'success': True,
                'message': 'String updated successfully'
            })
        }
        
    except (ClientError, json.JSONDecodeError) as e:
        # Handle errors: either DynamoDB errors or invalid JSON in request body
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        } 