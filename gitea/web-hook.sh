#!/bin/bash

# Set variables
GITEA_HOST=http://192.168.11.102:3000/
GITEA_USERNAME=vagrant
GITEA_PASSWORD=docker
REPO_OWNER=vagrant
REPO_NAME=gitea-bgapp
WEBHOOK_URL=http://192.168.11.101:8080/gitea-webhook/post
WEBHOOK_SECRET=$(openssl rand -hex 20)

# Authenticate with Gitea and generate a new access token
ACCESS_TOKEN=$(curl -s -X POST --header "Content-Type: application/json" -d '{"name": "My Token", "scopes": ["repo", "user"]}' "https://$GITEA_HOST/api/v1/user/token?access_token=$GITEA_USERNAME:$GITEA_PASSWORD" | jq -r '.token')

# Create the webhook
curl -s -X POST --header "Content-Type: application/json" --header "Authorization: token $ACCESS_TOKEN" -d "{\"type\": \"gitea\", \"config\": { \"url\": \"$WEBHOOK_URL\", \"content_type\": \"json\", \"secret\": \"$WEBHOOK_SECRET\", \"insecure_ssl\": \"0\", \"events\": [ \"push\" ] }, \"active\": true, \"events\": [ \"push\" ] }" "https://$GITEA_HOST/api/v1/repos/$REPO_OWNER/$REPO_NAME/hooks"

# Print the webhook URL and secret
echo "Webhook URL: $WEBHOOK_URL"
echo "Webhook secret: $WEBHOOK_SECRET"
