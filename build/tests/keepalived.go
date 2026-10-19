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

// ReadOnlyTemplate renders a template from an actual read-only mount.
func ReadOnlyTemplate(ctx context.Context, image *dagger.Container) error {
	ctx, cancel := context.WithTimeout(ctx, time.Minute)
	defer cancel()
	fixture := image.WithMountedDirectory("/tmp/readonly-templates",
		image.Directory("/container/services/keepalived-conf/assets/confs"),
		dagger.ContainerWithMountedDirectoryOpts{ReadOnly: true}).
		WithEnvVariable("KEEPALIVED_CONF_TEMPLATE", "/tmp/readonly-templates/keepalived.conf.template").
		WithEnvVariable("KEEPALIVED_CONF", "/tmp/readonly-rendered.conf")
	return run(ctx, fixture, []string{"bash", "-ec", `
 KEEPALIVED_INTERFACE=$(ip -o route show default | awk '{print $5; exit}')
 test -n "${KEEPALIVED_INTERFACE}"
 export KEEPALIVED_INTERFACE
 template_before=$(cat "${KEEPALIVED_CONF_TEMPLATE}")
 if touch /tmp/readonly-templates/write-probe 2>/dev/null; then
   echo 'template mount is writable' >&2
   exit 1
 fi
 container --skip-process
 test -s "${KEEPALIVED_CONF}"
 test "$(cat "${KEEPALIVED_CONF_TEMPLATE}")" = "${template_before}"
 keepalived -f "${KEEPALIVED_CONF}" --config-test
 `}, dagger.ContainerWithExecOpts{})
}

// ProjectedConfig checks reloads after Kubernetes-style atomic symlink updates.
func ProjectedConfig(ctx context.Context, image *dagger.Container) error {
	return Runtime(ctx, image.WithEnvVariable("TEST_PROJECTED_CONFIG", "true"))
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
