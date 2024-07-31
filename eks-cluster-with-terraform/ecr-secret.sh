#!/bin/bash

# Set variables
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=257070983248

# Get the ECR login password
ECR_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})

# Create the containerd config directory if it doesn't exist
sudo mkdir -p /etc/containerd

# Backup the existing config.toml if it exists
if [ -f /etc/containerd/config.toml ]; then
    sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
fi

# Write a new config.toml for containerd
sudo tee /etc/containerd/config.toml > /dev/null <<EOL
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"]
          [plugins."io.containerd.grpc.v1.cri".registry.configs."${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com".auth]
            username = "AWS"
            password = "${ECR_PASSWORD}"
EOL

# Restart containerd to apply the changes
sudo systemctl restart containerd

echo "Containerd configured for ECR registry."
