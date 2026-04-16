package main

import (
	"context"
	"os"

	"github.com/osixia/container-baseimage/build/cmd"
	"github.com/osixia/container-baseimage/build/config"
)

func main() {

	// image

	var KeepalivedImage = &config.Image{
		BaseImage:    "osixia/baseimage:alpine-2.0.0-beta3",
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

	// execute cmd

	mainCtx := context.Background()
	if err := cmd.Run(mainCtx); err != nil {
		os.Exit(1)
	}

}
