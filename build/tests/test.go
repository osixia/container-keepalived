package tests

import (
	"context"
	"fmt"

	"github.com/osixia/container-baseimage/build/job"
)

// Run checks that curl is available in each built runtime image.
func Run(ctx context.Context, builds []*job.BuildResult) error {
	for _, build := range builds {
		for _, image := range build.Containers {
			if _, err := image.WithExec([]string{"curl", "--version"}).Sync(ctx); err != nil {
				return fmt.Errorf("curl runtime check for %s: %w", build.Image.Name, err)
			}
		}
	}
	return nil
}
