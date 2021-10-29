all:
	@make clean
	@make manager
	@make simulation
	@make firealarm
	@echo
	@echo manager, simulation and firealarm built successfully


manager: manager.c 
	@gcc -o manager manager.c -Wall -Wextra -Werror -lpthread -lrt -g

simulation: simulator.c
	@gcc -o simulator simulator.c -Wall -Wextra -Werror -lpthread -lrt -g

firealarm: firealarm.c
	@gcc -o firealarm firealarm.c -Wall -Wextra -Werror -lrt -g

clean:
	@rm -f manager 
	@rm -f simulator
	@rm -f firealarm