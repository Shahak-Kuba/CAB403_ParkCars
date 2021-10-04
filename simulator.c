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

// predefining shared memory functions
int shared_mem_init(shm_CP_t* shm, const char* shm_key);
void clear_memory( shm_CP_t* shm ); 

// simulation functions

/* car simulation functions */
void car_sim(shm_CP_t* shm); // car simulation
void LPR_generator(); // function that will generate random LPR

/* boom arm simulation functions */


/* fire sensor simulation functions */


int main()
{
    return(EXIT_SUCCESS);
}

/* ----------------------------------------------shared memory functions----------------------------------------------------*/

int shared_mem_init(shm_CP_t* shm, const char* shm_key)
{
    shm_unlink(shm_key);// making sure key is not linked to shm
    shm->key = shm_key;

    //Opening or Creating and opening data
    if((shm->fd = shm_open(shm->key, O_CREAT | O_RDWR, 0666) < 0))
    {
        perror("shm_open");
        return(EXIT_FAILURE);
    }
    // truncating memory to allocated size
    if(ftruncate(shm->fd,SHMSZ)<0)
    {
        perror("ftruncate");
        return(EXIT_FAILURE);
    }
    // mapping memory
    if((shm->shm_car = mmap(0, SHMSZ, PROT_WRITE, MAP_SHARED, shm->fd,0)) == (CP_t *) - 1)
    {
        perror("mmap");
        return(EXIT_FAILURE);
    }

    // if exited with true then shared memory has been created
    return(EXIT_SUCCESS);
}

// clearing memory
void clear_memory( shm_CP_t* shm ) {
    // Remove the shared memory object.
    munmap( shm->shm_car, sizeof(CP_t));
    shm_unlink(shm->shm_car);
    shm->fd = -1;
    shm->shm_car = NULL;
}

/* ----------------------------------------------car simulation functions----------------------------------------------------*/

/* ----------------------------------------------Boom arm simulation functions----------------------------------------------------*/

/* ----------------------------------------------Fire sensor functions----------------------------------------------------*/