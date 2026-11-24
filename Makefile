# ft_ality — all compilation and execution happen inside Podman.
# The host needs only GNU Make and Podman, not OCaml.

PODMAN           = podman
PODMAN_IMAGE     = ft-ality-ocaml:5.3.0
PODMAN_CONTAINER = ft-ality-dev
GRAMMAR         ?=

.DEFAULT_GOAL := all

all: podman-compile

podman-build:
	$(PODMAN) build -f Containerfile -t $(PODMAN_IMAGE) .

# Sources are mounted read-only, so build artifacts stay inside the container.
# Do not use --userns=keep-id here: /workspace belongs to the container user.
podman-up:
	$(PODMAN) run -d --name $(PODMAN_CONTAINER) \
		-v "$(CURDIR):/source:ro,Z" -w /workspace \
		$(PODMAN_IMAGE)

# Refresh sources before every build; generated .cmi/.cmx/.o stay in /workspace/src.
# Existing compiled interfaces copied from the host are removed before compiling.
podman-compile:
	$(PODMAN) exec -w /workspace $(PODMAN_CONTAINER) sh -ec '\
		rm -rf src grammars grammar; \
		cp -R /source/src ./src; \
		if [ -d /source/grammars ]; then cp -R /source/grammars ./grammars; fi; \
		if [ -d /source/grammar ]; then cp -R /source/grammar ./grammar; fi; \
		rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o src/*.cmt src/*.cmti; \
		ocamlfind ocamlopt -I src -o ft_ality \
			src/keymap.ml \
			src/automaton.ml \
			src/grammar.ml \
			src/recognition.ml \
			src/input.ml \
			src/main.ml'

# Keep stdin attached: input_char stdin + stty require an interactive terminal.
podman-run: podman-compile
	$(PODMAN) exec -it -w /workspace $(PODMAN_CONTAINER) ./ft_ality $(GRAMMAR)

podman-shell:
	$(PODMAN) exec -it -w /workspace $(PODMAN_CONTAINER) /bin/bash

clean:
	$(PODMAN) exec -w /workspace $(PODMAN_CONTAINER) sh -c \
		'rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o src/*.cmt src/*.cmti'

fclean: clean
	$(PODMAN) exec -w /workspace $(PODMAN_CONTAINER) rm -f /workspace/ft_ality

re: fclean all

podman-down:
	$(PODMAN) rm -f $(PODMAN_CONTAINER)

.PHONY: all podman-build podman-up podman-compile podman-run \
        podman-shell podman-down clean fclean re
