#include <stdio.h>
#include <stdlib.h>
#include<string.h>
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
    shm_CP_t PARKING;

    key = KEY;
    shared_mem_init_open(&PARKING, key);
    
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



bool LPR_detect(char *LPR)
{
    int line_num = 1;
	char temp[512]; // file buffer
    FILE *fptr = fopen("plates.txt", "r"); 
    printf("%s\n",LPR);
    if(fptr == NULL)
    {
        printf("Could not open plates.txt file. Please make sure it's in the same directory");
    }

    while(fgets(temp, 512, fptr) != NULL) {
		if((strstr(temp, LPR)) != NULL) {
			return true; // licence found, return true
		}
		line_num++;
	}

    return false;
}
