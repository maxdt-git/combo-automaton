NAME = ft_ality
SRC_DIR = src
BUILD_DIR = build

SRC = $(SRC_DIR)/keymap.ml \
      $(SRC_DIR)/automaton.ml \
      $(SRC_DIR)/grammar.ml \
      $(SRC_DIR)/recognition.ml \
      $(SRC_DIR)/input.ml \
      $(SRC_DIR)/main.ml

OBJ = $(patsubst $(SRC_DIR)/%.ml,$(BUILD_DIR)/%.cmx,$(SRC))

OCAMLOPT = ocamlfind ocamlopt
OCAMLFLAGS = -I $(BUILD_DIR)

all: $(NAME)

$(NAME): $(OBJ)
	$(OCAMLOPT) $(OCAMLFLAGS) -o $@ $(OBJ)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml Makefile | $(BUILD_DIR)
	$(OCAMLOPT) $(OCAMLFLAGS) -c -o $@ $<

# Compilation dependencies (needed for correct incremental and parallel builds)
$(BUILD_DIR)/grammar.cmx: $(BUILD_DIR)/automaton.cmx $(BUILD_DIR)/keymap.cmx
$(BUILD_DIR)/recognition.cmx: $(BUILD_DIR)/automaton.cmx $(BUILD_DIR)/keymap.cmx
$(BUILD_DIR)/input.cmx: $(BUILD_DIR)/recognition.cmx
$(BUILD_DIR)/main.cmx: $(BUILD_DIR)/keymap.cmx $(BUILD_DIR)/automaton.cmx \
                        $(BUILD_DIR)/grammar.cmx $(BUILD_DIR)/recognition.cmx \
                        $(BUILD_DIR)/input.cmx

clean:
	rm -rf $(BUILD_DIR)
	# Remove artifacts left by the previous Makefile inside src/
	rm -f $(SRC_DIR)/*.cmi $(SRC_DIR)/*.cmo $(SRC_DIR)/*.cmx \
	      $(SRC_DIR)/*.o $(SRC_DIR)/*.cmt $(SRC_DIR)/*.cmti

fclean: clean
	rm -f $(NAME)

re:
	$(MAKE) fclean
	$(MAKE) all

.PHONY: all clean fclean re
