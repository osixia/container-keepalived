package tests

import (
	"context"
	"fmt"

	"dagger.io/dagger"

	"github.com/osixia/dagger-build/job"
)

// Run checks keepalived-specific behavior after the reusable job's version check, only on
// the engine platform: emulated images are too slow and unreliable for VRRP timing checks.
func Run(ctx context.Context, client *dagger.Client, builds []*job.BuildResult) error {

	enginePlatform, err := client.DefaultPlatform(ctx)
	if err != nil {
		return fmt.Errorf("engine platform: %w", err)
	}

	tested := 0
	for _, build := range builds {
		for _, image := range build.Containers {

			platform, err := image.Platform(ctx)
			if err != nil {
				return fmt.Errorf("image platform: %w", err)
			}
			if platform != enginePlatform {
				continue
			}
			tested++

			if err := Image(ctx, image); err != nil {
				return err
			}
			if err := Runtime(ctx, image); err != nil {
				return err
			}
		}
	}

	if tested == 0 && len(builds) > 0 {
		return fmt.Errorf("no image built for the engine platform %v", enginePlatform)
	}

	return nil
}
