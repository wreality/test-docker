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

target "fpm-ci" {
  inherits =  ["fpm", "_ci"]
  tags = ["ci.local/wreality/fpm:latest"]
  output = ["type=docker,dest=/tmp/fpm.tar"]
  cache-to = ["type=gha,mode=max,scope=${GITHUB_REF_NAME}-fpm"]
  cache-from = ["type=gha,scope=${GITHUB_REF_NAME}-fpm"]
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

target "web-ci" {
  inherits = ["web", "_ci"]
  tags = ["ci.local/wreality/web:latest"]
  cache-to = ["type=gha,mode=max,scope=${GITHUB_REF_NAME}-web"]
  cache-from = ["type=gha,scope=${GITHUB_REF_NAME}-web"]
  output = ["type=docker,dest=/tmp/web.tar"]
}

target "fpm-release" {
  inherits = ["fpm", "_release"]
  output = ["type=image,push=true,annotation.org.opencontainers.image.description=Pilcrow FPM Container Image version: ${ VERSION }@${VERSION_DATE } (${ VERSION_URL })"]
  cache-from = ["type=gha,scope=${GITHUB_REF_NAME}-fpm"]
}

target "web-release" {
  inherits = ["web", "_release"]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=image,push=true,annotation.org.opencontainers.image.description=Pilcrow WEB Container Image version: ${ VERSION }@${VERSION_DATE } (${ VERSION_URL })"]
  cache-from = ["type=gha,scope=${GITHUB_REF_NAME}-web"]
}

target "_release" {
  output = ["type=image,push=true"]
}


target "_defaults" {
  dockerfile = "Dockerfile"
}

target "_ci" {
  cache-to = ["type=gha,mode=max"]
  cache-from = ["type=gha"]
}

group "default" {
  targets = ["fpm", "web"]
}

group "ci" {
  targets = ["fpm-ci", "web-ci"]
}

group "release" {
  targets = ["fpm-release", "web-release"]

}
