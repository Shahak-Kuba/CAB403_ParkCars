all:
	@make clean
	@make manager
	@make simulation
	@echo
	@echo manager and simulation built successfully


manager: manager.c 
	@gcc -o manager manager.c -Wall -Wextra -Werror -lpthread -lrt -g

simulation: simulator.c
	@gcc -o simulator simulator.c -Wall -Wextra -Werror -lpthread -lrt -g


clean:
	@rm manager -f
	@rm simulator -f