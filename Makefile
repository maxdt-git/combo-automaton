NAME = ft_ality
SRC  = src/keymap.ml src/automaton.ml src/grammar.ml src/main.ml

all: $(NAME)

$(NAME): $(SRC)
	ocamlfind ocamlopt -I src -o $(NAME) $(SRC)

clean:
	rm -f src/*.cm* src/*.o

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
