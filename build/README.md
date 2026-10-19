# CI/CD tool

This project uses [osixia/dagger-build](https://github.com/osixia/dagger-build) to build, test, and deploy images.

## Get Help
```
go run main.go --help
```

## Run Tests
```
go mod vendor
go run main.go job test ../Dockerfile
```

Limit a local run with `--arches amd64`.

The shared `job.DefaultTest` builds the images and checks their entrypoint's
version. `main.go` installs `job.Test` to run the additional checks in `tests/`,
on the engine platform only:

- image content: keepalived libraries, `iptables` command, BFD and HTTP_GET regex
  support, and no build or unused packages,
- read-only mounted templates: rendering, source preservation and configuration validation,
- projected configuration: hot reload after two atomic `..data` symlink replacements,
- runtime: configuration generated from environment variables, script security,
  notify script logs, virtual IP set when master, hot reload and virtual IPs
  removed on stop.
