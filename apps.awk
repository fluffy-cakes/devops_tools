/GNU Awk/ {
    gsub(",", "")
    printf("- AWK v%s\n", $3)
}

/azure-cli/ {
    printf("- [Azure CLI v%s](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli)\n", $2)
}

/Bicep/ {
    printf("- Bicep v%s\n", $4)
}

/curl/ {
    printf("- Curl v%s\n", $2)
}

/git/ {
    printf("- Git v%s\n", $3)
}

/jq/ {
    gsub("jq-", "")
    printf("- [JQ v%s](https://github.com/stedolan/jq)\n", $1)
}

/GNU nano/ {
    printf("- Nano v%s\n", $4)
}

/PSVersion/ {
    printf("- [PowerShell v%s](https://github.com/PowerShell/PowerShell)\n", $2)
}

# shellcheck
/version:/ {
    printf("- [Shellcheck v%s](https://github.com/koalaman/shellcheck)\n", $2)
}

/Terraform/ {
    printf("- [Terraform %s](https://www.terraform.io/downloads.html)\n", $2)
}

/terraform-docs/ {
    printf("- [Terraform Docs %s](https://github.com/terraform-docs/terraform-docs)\n", $3)
}

# unzip
/Debian/ {
    printf("- UnZip v%s\n", $2)
}

/zsh/ {
    printf("- Zsh v%s\n", $2)
}