# CI/CD tool

## Get Help
```
go run main.go --help
```

## Run Tests
```
go mod vendor
go run main.go job test ../Dockerfile
```

The Go test job checks the image version and verifies that `curl --version`
succeeds in every built runtime image.
