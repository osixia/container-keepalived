package main

import (
	"context"
	"os"

	"dagger.io/dagger"

	"github.com/osixia/container-baseimage/build/cmd"
	"github.com/osixia/container-baseimage/build/config"
	"github.com/osixia/container-baseimage/build/job"
	"github.com/osixia/container-keepalived/build/tests"
)

func main() {

	// image

	var KeepalivedImage = &config.Image{
		BaseImage:    "osixia/baseimage:alpine-2.0.0-rc",
		Distribution: config.Alpine,

		Name:        "osixia/keepalived",
		Description: "Keepalived container image 🐳🛟🌴",

		Url:           "https://opensource.osixia.net/projects/container-images/keepalived/",
		Documentation: "https://opensource.osixia.net/projects/container-images/keepalived/",
		Source:        "https://github.com/osixia/container-keepalived",

		Authors: "The osixia/container-keepalived maintainers",
		Vendor:  "Osixia",

		Licences: "MIT",
	}

	config.Images = []*config.Image{
		KeepalivedImage,
	}

	config.DefaultImage = KeepalivedImage

	// github

	config.ProjectGithubRepo = &config.GithubRepo{
		Organization: "osixia",
		Project:      "container-keepalived",
	}

	// tests

	job.Test = func(ctx context.Context, client *dagger.Client, options any) ([]*job.BuildResult, error) {
		builds, err := job.DefaultTest(ctx, client, options)
		if err != nil {
			return nil, err
		}
		if err := tests.Run(ctx, builds); err != nil {
			return nil, err
		}
		return builds, nil
	}

	// execute cmd

	mainCtx := context.Background()
	if err := cmd.Run(mainCtx); err != nil {
		os.Exit(1)
	}

}
