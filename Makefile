.PHONY: new

new:
	@test $(POST) || ( echo [Usage] make new POST=my-first-post; exit 1 )
	pwd
	hugo new content posts/$(POST).md