package tests

import (
	"context"
	_ "embed"
	"fmt"
	"time"

	"dagger.io/dagger"
)

// Image checks the image content: keepalived libraries and packages that must not be shipped.
func Image(ctx context.Context, image *dagger.Container) error {

	ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	fixture := image.WithNewFile("/tmp/keepalived-image-check.sh", imageCheck, dagger.ContainerWithNewFileOpts{Permissions: 0755})
	if err := run(ctx, fixture, []string{"sh", "/tmp/keepalived-image-check.sh"}, dagger.ContainerWithExecOpts{}); err != nil {
		return fmt.Errorf("image checks: %w", err)
	}

	return nil
}

// Runtime runs the image supervisor with the default services in a derived container, with
// the capabilities keepalived needs to manage virtual IPs in its own network namespace.
func Runtime(ctx context.Context, image *dagger.Container) error {

	ctx, cancel := context.WithTimeout(ctx, 3*time.Minute)
	defer cancel()

	fixture := image.WithNewFile("/tmp/keepalived-runtime-check.sh", runtimeCheck, dagger.ContainerWithNewFileOpts{Permissions: 0755})
	if err := run(ctx, fixture, []string{"sh", "/tmp/keepalived-runtime-check.sh"}, dagger.ContainerWithExecOpts{InsecureRootCapabilities: true, NoInit: true}); err != nil {
		return fmt.Errorf("runtime checks: %w", err)
	}

	return nil
}

// run executes a check script and returns its output on failure, which Dagger does not show.
func run(ctx context.Context, container *dagger.Container, args []string, opts dagger.ContainerWithExecOpts) error {

	opts.Expect = dagger.ReturnTypeAny
	exec := container.WithExec(args, opts)

	code, err := exec.ExitCode(ctx)
	if err != nil {
		return err
	}
	if code == 0 {
		return nil
	}

	stdout, _ := exec.Stdout(ctx)
	stderr, _ := exec.Stderr(ctx)
	return fmt.Errorf("exit code %d:\n%s%s", code, stdout, stderr)
}

//go:embed testdata/image.sh
var imageCheck string

//go:embed testdata/runtime.sh
var runtimeCheck string
