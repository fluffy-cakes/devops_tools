#!/bin/bash

set -euo pipefail

HCL_PACKER="1.7.8"
HCL_TERRAFORM="1.1.3"
HCL_TFDOCS="0.16.0"
HCL_TOJSON="0.3.3"
SHELLCHECK="0.8.0"
POWERSHELL="7.2.1"

apt-get update

list=(
    apt-transport-https
    ca-certificates # also pwsh
    curl
    gawk
    git
    jq
    nano
    unzip
    xz-utils
    zsh
    # all else below for pwsh
    less
    locales
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
    DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -y "$i"
done

cd ~ || exit
mkdir ./downloads && cd ./downloads || exit

# Azure CLI
printf "\n\n***** Azure CLI\n"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Bicep via Azure CLI
printf "\n\n***** Bicep\n"
az bicep install
cp /root/.azure/bin/bicep /bin/bicep

# HCL Packer
printf "\n\n***** HCL Packer\n"
curl -L -o "packer_${HCL_PACKER}_linux_amd64.zip" "https://releases.hashicorp.com/packer/${HCL_PACKER}/packer_${HCL_PACKER}_linux_amd64.zip"
unzip "./packer_${HCL_PACKER}_linux_amd64.zip"
mv ./packer /usr/local/bin/packer

# HCL Terraform
printf "\n\n***** HCL Terraform\n"
curl -L -o "terraform_${HCL_TERRAFORM}_linux_amd64.zip" "https://releases.hashicorp.com/terraform/${HCL_TERRAFORM}/terraform_${HCL_TERRAFORM}_linux_amd64.zip"
unzip "./terraform_${HCL_TERRAFORM}_linux_amd64.zip"
mv ./terraform /usr/local/bin/terraform

# HCL TF Docs
printf "\n\n***** HCL TF Docs\n"
curl -L -o tfdocs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/v${HCL_TFDOCS}/terraform-docs-v${HCL_TFDOCS}-linux-amd64.tar.gz"
tar -zxvf ./tfdocs.tar.gz
chmod +x ./terraform-docs
mv ./terraform-docs /usr/local/bin/tfdocs

# HCL to JSON
printf "\n\n***** HCL to JSON\n"
curl -L -o hcl2json "https://github.com/tmccombs/hcl2json/releases/download/v${HCL_TOJSON}/hcl2json_linux_amd64"
chmod +x ./hcl2json
mv ./hcl2json /usr/local/bin/hcl2json

# Oh My ZSH
printf "\n\n***** Oh My ZSH\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo $'alias ll=\'ls -lah\'' >> /root/.zshrc

# ls = List information about the FILEs
# -a = All; do not ignore entries starting with .
# -h = Human readable
# -l = Use a long listing format

# ZSH and large repos can take time to populate the git refresh, disabling for performance gain
git config --global --add oh-my-zsh.hide-info 1

# ShellCheck
printf "\n\n***** ShellCheck\n"
curl -L -o "shellcheck_${SHELLCHECK}_linux.x86_64.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK}/shellcheck-v${SHELLCHECK}.linux.x86_64.tar.xz"
tar -xvf "shellcheck_${SHELLCHECK}_linux.x86_64.tar.xz"
mv "./shellcheck-v${SHELLCHECK}/shellcheck" /usr/local/bin/shellcheck

# PowerShell
# based on https://github.com/PowerShell/PowerShell-Docker/blob/master/release/preview/ubuntu20.04/docker/Dockerfile
printf "\n\n***** PowerShell\n"
PS_INSTALL_VERSION=$(echo "${POWERSHELL}" | tr "." "-")
curl -L -o /tmp/linux.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL}/powershell-${POWERSHELL}-linux-x64.tar.gz"
PS_INSTALL_FOLDER="/opt/microsoft/powershell/${PS_INSTALL_VERSION}"
mkdir -p "${PS_INSTALL_FOLDER}"
tar zxf /tmp/linux.tar.gz -C "${PS_INSTALL_FOLDER}"

DOTNET_SYSTEM_GLOBALIZATION_INVARIANT="false"
LC_ALL="en_US.UTF-8"
LANG="en_US.UTF-8"
PSModuleAnalysisCachePath="/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache"
POWERSHELL_DISTRIBUTION_CHANNEL="PSDocker-Ubuntu-20.04"

apt-get dist-upgrade -y
apt-get clean
rm -rf /var/lib/apt/lists/*
locale-gen "$LANG" && update-locale

chmod a+x,o-w "${PS_INSTALL_FOLDER}/pwsh"
ln -s "${PS_INSTALL_FOLDER}/pwsh" /usr/bin/pwsh
export POWERSHELL_TELEMETRY_OPTOUT="1"

pwsh \
    -NoLogo \
    -NoProfile \
    -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        Write-Host \"Installing Module Az (...takes a while)\" ; \
        Install-Module -Name Az -AllowClobber -Confirm:\$false -scope CurrentUser -Force ; \
        Write-Host \"Installing Module Az Subscription\" ; \
        Install-Module -Name Az.Subscription -AllowClobber -Confirm:\$false -scope CurrentUser -Force ; \
        Write-Host \"Installing Module Pester\" ; \
        Install-Module -Name Pester -AllowClobber -Confirm:\$false -scope CurrentUser -Force"

cd ~ || exit
rm -rf ~/downloads

mkdir -p ~/.vscode-server/extensions
mkdir -p ~/.vscode-server-insiders/extensions


verList=(
    "awk            --version"
    "2>/dev/null az --version"
    "bicep          --version"
    "curl           --version"
    "git            --version"
    "jq             --version"
    "nano           --version"
    "packer"
    "pwsh           -c '\$psversiontable'"
    "shellcheck     -V"
    "terraform      --version"
    "tfdocs         --version"
    "unzip          -v"
    "zsh            --version"
)

printf "\n\n***** Printing Versions\n\n"

for i in "${verList[@]}"; do
    if [[ $i != "packer" ]]; then
        eval "$i" | awk -f /tmp/apps.awk
    else
        printf '-'
        printf ' [Packer v%s](https://www.packer.io/downloads)\n' "$(packer --version)"
    fi
done

