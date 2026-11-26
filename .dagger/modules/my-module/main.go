package my_module

import (
	"dagger.io/dagger/core"

	"dagger/my-module/internal/dagger"
)

type MyModule struct {
	// Image the build runs on.
	BaseImageAddress string

	// +private
	Source *dagger.Directory
}

func New(
	ws *dagger.Workspace,
	// +default="alpine:3.21"
	baseImageAddress string,
) *MyModule {
	return &MyModule{
		BaseImageAddress: baseImageAddress,
		Source: ws.Directory("/", dagger.WorkspaceDirectoryOpts{
			Exclude: []string{"**/.git", "**/.dagger", "**/vendor"},
		}),
	}
}

// A container with the source mounted, ready to build on.
func (m *MyModule) Container() *dagger.Container {
	return core.NewContainer().
		From(m.BaseImageAddress).
		WithDirectory("/src", m.Source).
		WithWorkdir("/src")
}
