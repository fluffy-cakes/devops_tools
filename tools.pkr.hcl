source "docker" "ubuntu" {
    commit             = true
    image              = "ubuntu:20.04"
    changes            = [
        "ENTRYPOINT /bin/bash"
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
            tags       = ["1.2.0", "latest"]
        }
    }
}
