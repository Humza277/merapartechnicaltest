import json
import os
import boto3
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'StringTable')
table = dynamodb.Table(table_name)
string_key = 'string'  # Partition key value for the string item

def handler(event, context):
    """
    Lambda handler function to serve HTML with dynamic string or update the string
    """
    # Get HTTP method and path from the event
    http_method = event.get('requestContext', {}).get('http', {}).get('method', '')
    path = event.get('requestContext', {}).get('http', {}).get('path', '')
    
    # Handle GET request to serve HTML
    if http_method == 'GET' and path == '/':
        return serve_html()
    
    # Handle POST request to update string
    elif http_method == 'POST' and path == '/update':
        return update_string(event)
    
    # Handle any other request
    else:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'text/plain'
            },
            'body': 'Not Found'
        }

def serve_html():
    """
    Fetch the string from DynamoDB and serve HTML page
    """
    try:
        # Get the current string from DynamoDB
        response = table.get_item(Key={'key': string_key})
        current_string = response.get('Item', {}).get('value', 'No string found')
        
        # Create a simple HTML page with the string (no update form)
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
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html'
            },
            'body': html
        }
        
    except ClientError as e:
        # Handle DynamoDB errors
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
    Update the string in DynamoDB
    """
    try:
        # Parse the request body to get the new string
        body = json.loads(event.get('body', '{}'))
        new_string = body.get('value', '')
        
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
        
        # Update the string in DynamoDB
        table.update_item(
            Key={'key': string_key},
            UpdateExpression='SET #val = :val',
            ExpressionAttributeNames={'#val': 'value'},
            ExpressionAttributeValues={':val': new_string}
        )
        
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
        # Handle errors (DynamoDB or JSON parsing)
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        } 