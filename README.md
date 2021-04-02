# Fluffys DevOps Tools
Misc repo for devops tooling

Docker image contains
- Azure CLI
- HCL Packer
- HCL Terraform
- HCL Terraform Docs
- HCL to JSON
- PowerShell (Modules: Azure, Pester 4.6.0)
- curl
- git
- shellcheck
- unzip


```bash
docker run \
    --name=devtools \
    --restart unless-stopped \
    -td \
    -v /mnt/c/Users/asdf/asdf:/data \
    elfreako/devtools
```