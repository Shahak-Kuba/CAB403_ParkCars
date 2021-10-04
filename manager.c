#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>
#include "datas.h"


// initialising the simulation
bool sim = true;

// Predefining functions

/* SHARED MEMORY functions */
int shared_mem_init_open(shm_CP_t* shm, const char* shm_key);

/* ENTRANCE functions */
void enter_carpark();// this will be a function that allows a car to enter the carpark
bool LPR_detect(char LPR[6]); // function that will check if the LPR is on the list
void detect(char LPR[6]);// this function will verify that the car can enter the car park
void navigate();// this function will navigate the car to the appropriate floor based on how full the carpark is
void boom_control();// function to control boomgate status

/* EXIT functions */



int main()
{
    const char* key;
    shm_CP_t* shm;

    key = KEY;

    shared_mem_init_open(shm, key);

    // loop that runs the simulation
    while(sim)
    {
        sim = false;
    }
}

// Functions


int shared_mem_init_open(shm_CP_t* shm, const char* shm_key)
{   
    // opening the shared data, otherwise producing an error
    if ((shm->fd = shm_open(shm_key, O_RDWR, 0)) < 0)
        {
            perror("shm_open");
            return(EXIT_FAILURE);
        }
    return(EXIT_SUCCESS);
}