variable "VERSION" {
  default = "source"
}

variable "VERSION_URL" {
  default = ""
}

variable "VERSION_DATE" {
  default = ""
}

variable "GITHUB_REF_NAME" {
  default = ""
}

target "fpm" {
  inherits =  ["_defaults"]
  context = "backend"
  args = {
    VERSION = "${VERSION}"
    VERSION_URL = "${VERSION_URL}"
    VERSION_DATE = "${VERSION_DATE}"
  }
}


target "web" {
  inherits =  ["_defaults"]
  context = "client"
  args = {
    VERSION = "${VERSION}"
    VERSION_URL = "${VERSION_URL}"
    VERSION_DATE = "${VERSION_DATE}"
  }
}


target "fpm-release" {
  inherits = ["fpm", "_release"]
  output = ["type=image,push=true,annotation.org.opencontainers.image.description=Pilcrow FPM Container Image version: ${ VERSION }@${VERSION_DATE } (${ VERSION_URL })"]
}

target "web-release" {
  inherits = ["web", "_release"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=image,push=true,annotation.org.opencontainers.image.description=Pilcrow WEB Container Image version: ${ VERSION }@${VERSION_DATE } (${ VERSION_URL })"]
}

target "_release" {
}

group "default" {
  targets = ["fpm", "web"]
}


group "release" {
  targets = ["fpm-release", "web-release"]

}
