REGISTRY ?= ghcr.io/klepac-ceraj-lab
VERSION ?= latest
CONTAINER_HOME ?= $(HOME)/containers
DATABASE_HOME ?= $(HOME)/containers
IMAGES := bzip2 kneaddata/012 metaphlan/3 metaphlan/4 humann/3 humann/4

.PHONY: all build push apptainer install postinstall clean \
        $(IMAGES) \
        $(IMAGES:%=push-%) \
        $(IMAGES:%=apptainer-%)

all: build

build: $(IMAGES)

$(IMAGES):
	docker build -t $(REGISTRY)/$(subst /,-,$@):$(VERSION) -f $@/Dockerfile $@

push: $(IMAGES:%=push-%)

push-%:
	docker push $(REGISTRY)/$(subst /,-,$*):$(VERSION)

apptainer: $(IMAGES:%=apptainer-%)

apptainer-%:
	apptainer build $(subst /,-,$*).sif docker://$(REGISTRY)/$(subst /,-,$*):$(VERSION)

install: apptainer postinstall

postinstall:
	@SHELL_NAME=$$(basename "$$SHELL"); \
	case "$$SHELL_NAME" in \
		bash) PROFILE_FILE="$$HOME/.bashrc";; \
		zsh)  PROFILE_FILE="$$HOME/.zshrc";; \
		fish) PROFILE_FILE="$$HOME/.config/fish/config.fish";; \
		*)    echo "Unknown shell: $$SHELL_NAME. Please update your PATH manually."; exit 1;; \
	esac; \
	echo "Adding $(PWD)/bin to PATH in $$PROFILE_FILE"; \
	ECHO_LINE='export PATH="$(PWD)/bin:$$PATH"'; \
	if ! grep -Fq "$$ECHO_LINE" "$$PROFILE_FILE"; then \
		echo "$$ECHO_LINE" >> "$$PROFILE_FILE"; \
		echo "PATH updated. Restart your shell or run: source $$PROFILE_FILE"; \
	else \
		echo "PATH already set in $$PROFILE_FILE"; \
	fi

clean:
	rm -f *.sif