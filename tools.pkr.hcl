source "docker" "ubuntu" {
    commit             = true
    image              = "ubuntu:20.04"
    changes            = [
        "ENTRYPOINT pwsh"
    ]
}

build {
    sources            = ["source.docker.ubuntu"]

    provisioner "shell" {
        script         = "./apps.sh"
    }

    post-processors {
        post-processor "docker-tag" {
            repository = "elfreako/devtools"
            tag        = ["latest"]
        }
    }
}
