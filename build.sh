#! /usr/bin/env bash

echo "Building image with Packer. This will take several minutes."
export IMAGE_ID=$(packer build -force packer.json | grep "ManagedImageId" | sed 's/.* //g')
echo "image_id=\"${IMAGE_ID}\"" > terraform.tfvars
echo "Stored Image ID in terraform.tfvars. Edit this file with any further desired modifications."
