# Fluffy's DevOps Tools
Misc repo for DevOps tooling

https://hub.docker.com/u/elfreako

Docker image contains
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli) (inc. Bicep 💪)
- [HCL Packer](https://www.packer.io/downloads)
- [HCL Terraform](https://www.terraform.io/downloads.html)
- [HCL Terraform Docs](https://github.com/terraform-docs/terraform-docs)
- [HCL to JSON](https://github.com/tmccombs/hcl2json)
- [PowerShell](https://github.com/PowerShell/PowerShell) (Modules: Azure, Pester 4.6.0)
- Curl
- Git
- Nano
- [Oh My ZSH](https://github.com/ohmyzsh/ohmyzsh)
- [Shellcheck](https://github.com/koalaman/shellcheck)
- Unzip

### Running Container

Run the container in detached mode and always load on boot:

```bash
docker run \
    --name devtools \                           # Assign a name to the container
    --detach \                                  # Run container in background and print container ID (or -d)
    --restart unless-stopped \                  # Restart policy to apply when a container exits (default "no")
    --tty \                                     # Allocate a pseudo-TTY (or -t)
    --volume /mnt/c/Users/asdf/asdf:/data \     # Bind mount a volume (or -v)
    --volume /mnt/c/Users/zxcv/qwer:/data \     # Bind mount a volume (or -v)
    elfreako/devtools
```

Connect to container via ZSH:
```bash
docker exec -it devtools /bin/zsh

# -i = Keep STDIN open even if not attached
# -t = Allocate a pseudo-TTY
```

### VSCode

Recommended usage when flipping between computers is using Settings Sync within VSCode: https://code.visualstudio.com/docs/editor/settings-sync

The Docker extension also allows you to attach the running container as a shell: https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker

![](./imgs/docker_extension.png)

### WSL

Enabling container dropdown in Windows Terminal using WSL and Docker Desktop:
    Add a new profile in `settings.json` under `{}profiles.[]list`

```json
    {
        "commandline": "docker exec -it devtools /bin/zsh",
        "icon": "E:\\Downloads\\asdf\\qwer\\zxcv\\clover 2.png",
        "name": "Docker devtools",
        "tabColor": "#B018ED",
        "tabTitle": "Docker devtools"
    }
```

![](./imgs/windows_terminal_embedded.png)

Docker with WSL tends to eat up memory at times, to restrict it, perform the following...

Turn off all WSL instances including docker-desktop:
```powershell
wsl --shutdown
notepad "$env:USERPROFILE/.wslconfig"
```

Edit `.wslconfig` file with notepad, adding these settings:
```powershell
[wsl2]
memory=3GB   # Limits VM memory in WSL 2 up to 3GB
processors=4 # Makes the WSL 2 VM use two virtual processors
```
...restart WSL

### MacOS Terminal

To enable auto load in MacOS Terminal, edit your Preferences and create/duplicate a Profile. Under the Shell menu of the profile, add `docker exec -it devtools /bin/zsh` inside the Run Command.

![](./imgs/mac_terminal.png)