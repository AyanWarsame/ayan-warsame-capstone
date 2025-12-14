#!/bin/bash
# Script to create ECR pull secret for Kubernetes

set -e

AWS_REGION="eu-west-1"
ECR_REGISTRY="032068930750.dkr.ecr.eu-west-1.amazonaws.com"
NAMESPACE="ayan-warsame"
SECRET_NAME="ecr-registry-secret"

echo "Creating ECR pull secret for Kubernetes..."
echo "Registry: $ECR_REGISTRY"
echo "Namespace: $NAMESPACE"
echo "Secret name: $SECRET_NAME"
echo ""

# Check if namespace exists, create if not
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace "$NAMESPACE"
fi

# Delete existing secret if it exists
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "Deleting existing secret $SECRET_NAME..."
    kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE"
fi

# Create new secret
echo "Creating ECR pull secret..."
aws ecr get-login-password --region "$AWS_REGION" | \
  kubectl create secret docker-registry "$SECRET_NAME" \
    --docker-server="$ECR_REGISTRY" \
    --docker-username=AWS \
    --docker-password-stdin \
    --namespace="$NAMESPACE"

echo ""
echo "✅ ECR secret created successfully!"
echo ""
echo "Verify with:"
echo "  kubectl get secret $SECRET_NAME -n $NAMESPACE"
echo ""

