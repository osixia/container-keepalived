package tests

import (
	"context"

	"github.com/osixia/dagger-build/job"
)

// Run checks keepalived-specific behavior after the reusable job's version check. CI builds
// each arch on a native runner: run locally with --arches matching the host to avoid emulation.
func Run(ctx context.Context, builds []*job.BuildResult) error {

	for _, build := range builds {
		for _, image := range build.Containers {

			if err := Image(ctx, image); err != nil {
				return err
			}
			if err := ReadOnlyTemplate(ctx, image); err != nil {
				return err
			}
			if err := Runtime(ctx, image); err != nil {
				return err
			}
			if err := ProjectedConfig(ctx, image); err != nil {
				return err
			}
		}
	}

	return nil
}
