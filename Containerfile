# ft_ality – OCaml development environment (Linux / Podman)
# Compiler version matches the last confirmed local setup: OCaml 5.3.0.
FROM docker.io/library/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    OPAMROOT=/opt/opam \
    OPAMYES=1

# Build dependencies for OCaml, opam/findlib, GNU make, and the stty command.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      opam build-essential m4 pkg-config git ca-certificates \
      curl unzip bubblewrap make coreutils && \
    rm -rf /var/lib/apt/lists/*

# No OCamlSDL: this project now reads its input from the terminal.
# opam's sandbox is disabled *inside the container* (not on the host).
RUN opam init --bare --disable-sandboxing --yes --no-setup && \
    opam switch create ftality ocaml-base-compiler.5.3.0 --yes && \
    opam install --switch ftality --yes ocamlfind && \
    /opt/opam/ftality/bin/ocamlc -version && \
    /opt/opam/ftality/bin/ocamlfind query findlib

ENV PATH="/opt/opam/ftality/bin:${PATH}"

RUN mkdir -p /workspace
WORKDIR /workspace
CMD ["sleep", "infinity"]
