#!/bin/bash

HCL_PACKER="1.7.0"
HCL_TERRAFORM="0.14.7"
HCL_TFDOCS="0.11.2"
HCL_TOJSON="0.3.2"
POWERSHELL="7.1.2"

apt-get update

list=(
    apt-transport-https
    curl
    gawk
    git
    shellcheck
    unzip
    # all else below for pwsh
    less
    locales
    ca-certificates
    gss-ntlmssp
    libicu66
    libssl1.1
    libc6
    libgcc1
    libgssapi-krb5-2
    libstdc++6
    zlib1g
    openssh-client
)

for i in "${list[@]}"; do
    printf "\n\n***** Installing %s\n" "$i"
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y "$i"
done

cd ~ || exit
mkdir ./downloads && cd ./downloads || exit

# Azure CLI
printf "\n\n***** Azure CLI\n"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# HCL Packer
printf "\n\n***** HCL Packer\n"
curl -L -o packer_${HCL_PACKER}_linux_amd64.zip https://releases.hashicorp.com/packer/${HCL_PACKER}/packer_${HCL_PACKER}_linux_amd64.zip
unzip ./packer_${HCL_PACKER}_linux_amd64.zip
mv ./packer /usr/local/bin/packer

# HCL Terraform
printf "\n\n***** HCL Terraform\n"
curl -L -o terraform_${HCL_TERRAFORM}_linux_amd64.zip https://releases.hashicorp.com/terraform/${HCL_TERRAFORM}/terraform_${HCL_TERRAFORM}_linux_amd64.zip
unzip ./terraform_${HCL_TERRAFORM}_linux_amd64.zip
mv ./terraform /usr/local/bin/terraform

# HCL TF Docs
printf "\n\n***** HCL TF Docs\n"
curl -L -o tfdocs https://github.com/terraform-docs/terraform-docs/releases/download/v${HCL_TFDOCS}/terraform-docs-v${HCL_TFDOCS}-linux-amd64
chmod +x ./tfdocs
mv ./tfdocs /usr/local/bin/tfdocs

# HCL to JSON
printf "\n\n***** HCL to JSON\n"
curl -L -o hcl2json https://github.com/tmccombs/hcl2json/releases/download/v${HCL_TOJSON}/hcl2json_linux_amd64
chmod +x ./hcl2json
mv ./hcl2json /usr/local/bin/hcl2json

# PowerShell
# based on https://github.com/PowerShell/PowerShell-Docker/blob/master/release/preview/ubuntu20.04/docker/Dockerfile
printf "\n\n***** PowerShell\n"
PS_INSTALL_VERSION=$(echo ${POWERSHELL} | tr "." "-")
curl -L -o /tmp/linux.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL}/powershell-${POWERSHELL}-linux-x64.tar.gz
PS_INSTALL_FOLDER=/opt/microsoft/powershell/${PS_INSTALL_VERSION}
mkdir -p "${PS_INSTALL_FOLDER}"
tar zxf /tmp/linux.tar.gz -C "${PS_INSTALL_FOLDER}"

DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache
POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-Ubuntu-20.04

apt-get dist-upgrade -y
apt-get clean
rm -rf /var/lib/apt/lists/*
locale-gen $LANG && update-locale

chmod a+x,o-w "${PS_INSTALL_FOLDER}/pwsh"
ln -s "${PS_INSTALL_FOLDER}/pwsh" /usr/bin/pwsh
export POWERSHELL_TELEMETRY_OPTOUT=1

pwsh \
    -NoLogo \
    -NoProfile \
    -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
        }"

pwsh \
    -NoLogo \
    -NoProfile \
    -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        Write-Host \"Installing Module Az\" ; \
        Install-Module -Name Az -AllowClobber -Confirm:\$false -scope CurrentUser -Force ; \
        Write-Host \"Installing Module Pester 4.6.0\" ; \
        Install-Module -Name Pester -RequiredVersion \"4.6.0\" -AllowClobber -Confirm:\$false -scope CurrentUser -Force"

cd ~ || exit
rm -rf ~/downloads
