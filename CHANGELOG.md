# Changelog

Project-specific changes only. See upstream [Keepalived release notes](https://www.keepalived.org/release-notes/).

## 2.3.4

⚠️ Breaking change: this version is a complete rewrite with a new base image and is not backward compatible. Please refer to the [README](README.md) for the new usage.

### Changed
  - Upgrade Keepalived version to 2.3.4
  - Upgrade baseimage to osixia/baseimage:alpine-2.0.0-alpha2
  - Use GitHub action for CI/CD and osixia/container-baseimage/build tool

For previous releases, see the GitHub [releases page](https://github.com/osixia/container-keepalived/releases).
