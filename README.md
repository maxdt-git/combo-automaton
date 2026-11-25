*This activity has been created as part of the 42 curriculum by mde-nas and mmonnier.*

# ft_ality

## Description

ft_ality recreates the **training mode of a fighting game** (think Mortal Kombat) in
pure functional OCaml. A grammar file describes the available keys and the combos to
learn; at startup the program **trains a finite-state automaton** from it, then reads the
keyboard in real time and prints every move whose key sequence has just been completed.

The project is an introduction to formal languages: combos are words of a **regular
language** whose alphabet is the set of game actions, and they are recognized by a
deterministic finite-state automaton `A = ⟨Q, Σ, Q0, F, δ⟩`.

## Instructions

Everything is built and run inside a Podman container — the host only needs GNU Make
and Podman (no local OCaml install).

```sh
make podman-build                               # build the OCaml 5.3.0 image (once)
make podman-up                                  # start the dev container
make                                            # compile ./ft_ality inside the container
make podman-run GRAMMAR=grammars/config.txt     # run with a grammar file
```

Other targets: `podman-shell`, `clean`, `fclean`, `re`, `podman-down`.

Press `Ctrl+D` to quit.

### Grammar format

```text
[keys]
# key:action
q:Punch
down:Down

[moves]
# action,action,...:move name
Down,Forward,Punch:Hadoudon
Punch,Punch,Kick:One-Two-Wasabi
```

Key mappings are computed from the grammar (never hardcoded) and printed at startup.
Arrow keys are referred to as `up`, `down`, `left`, `right`. Lines starting with `#`
are comments. Invalid lines and duplicate keys are reported with an explicit error.

### Example

```text
$ ./ft_ality grammars/config.txt
Key mappings:
up -> Up
down -> Down
left -> Back
right -> Forward
q -> Punch
...
----------------------
Down
Forward
Punch
Hadoudon !!
```

## Implementation

- **Parsing** (`grammar.ml`): trims lines, drops comments, splits the `[keys]` and
  `[moves]` sections, then parses each line into a `Result`; the first error stops
  the parse.
- **Training** (`automaton.ml`): each combo is inserted from the initial state, one
  symbol at a time, reusing existing transitions so that combos sharing a prefix share
  states (a trie). The last state of each combo becomes a recognition state; several
  moves can share the same sequence.
- **Recognition** (`recognition.ml`, `input.ml`): the terminal is switched to raw mode,
  each key is translated to an action through the key mapping, and the automaton steps
  to its next state. When no transition exists, it restarts from the initial state on
  the same symbol, so combos can chain continuously.
- Only the allowed modules (`Pervasives`/`Stdlib`, `List`, `String`, `Sys`) are used,
  with no `open` and no `;;`.

## Resources

- [Finite-state machine (Wikipedia)](https://en.wikipedia.org/wiki/Finite-state_machine)
- [Chomsky hierarchy (Wikipedia)](https://en.wikipedia.org/wiki/Chomsky_hierarchy)
- [OCaml documentation](https://ocaml.org/docs)
- **AI usage:** AI assistance (Claude) was used to write this README from the existing
  source code. All OCaml code was written and understood by the authors.
