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

int car_list_chance = 50;

// predefining shared memory functions
int shared_mem_init(shm_CP_t* shm, char* shm_key);
void clear_memory( shm_CP_t* shm ); 

// simulation functions

/* car simulation functions */
void car_sim(shm_CP_t* shm); // car simulation
void LPR_generator(); // function that will generate random LPR

/* boom arm simulation functions */
void toggleGate();

/* fire sensor simulation functions */
int fireState = 0; //0 normal operation, 1 for creep & 2 for spike

int main()
{
    printf("Enter F to trigger Creeping Fire Alarm Event\n");
    printf("Enter G to trigger Spike Fire Alarm Event\n");
    // initialising shared memory
    shm_CP_t shm;
    shared_mem_init(&shm, KEY);

    // intialising threads


    // Allocate space for LPR
    char LPR[7];
    LPR[6] = 0; // termination char
    for(int i = 0; i < 500; i++)
    {
        LPR_generator(LPR);
        printf("%s\n",LPR);
    }
    //main loop
    for (;;) {
        if (fgetc(stdin) == 'f') {
            printf("Increasing Temperature Over Time");
            fireState = 1;
        } else if (fgetc(stdin) == 'g') {
            printf("Increasing Temperature Instantly");
            fireState = 2;
        }
    }

    return(EXIT_SUCCESS);
}

/* ----------------------------------------------shared memory functions----------------------------------------------------*/

int shared_mem_init(shm_CP_t* shm, char* shm_key)
{
    shm_unlink(shm_key);// making sure key is not linked to shm
    shm->key = shm_key;

    //Opening or Creating and opening data
    if((shm->fd = shm_open(shm->key, O_CREAT | O_RDWR, 0666)) < 0)
    {
        perror("shm_open");
        return(EXIT_FAILURE);
    }

    // truncating memory to allocated size
    if(ftruncate(shm->fd,SHMSZ) < 0)
    {
        perror("ftruncate");
        return(EXIT_FAILURE);
    }

    // mapping memory
    if((shm->shm_ptr = mmap(0, SHMSZ, PROT_WRITE, MAP_SHARED, shm->fd,0)) == (CP_t *) - 1)
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
    munmap(shm->shm_ptr, sizeof(CP_t));
    shm_unlink(KEY);
    shm->fd = -1;
    shm->shm_ptr = NULL;
}

/* ----------------------------------------------car simulation functions----------------------------------------------------*/

void LPR_generator(char LPR[7])
{
    while (true) {
        if (rand() % 100 <= car_list_chance) {
            //printf("Use Car Plate: ");
            //Use car from plates.txt
            //Measure Number of plates in file.
            FILE* file_ptr = fopen("plates.txt","r");
            fseek(file_ptr,0,SEEK_END);
            int file_plate_count = ftell(file_ptr) / 7; //assumes all plates are 6 chars long
            //Take Random Plate from file
            fseek(file_ptr,(rand() % file_plate_count)*7,SEEK_SET);
            fgets(LPR,7,file_ptr);
            //printf("%s.\n",LPR);
            fclose(file_ptr);

        } else {
            //Generate random car plate
            //printf("Generate New Plate: ");
            for(int i = 0; i < 6; i++) {
                if(i < 3) { // first 3 are numbers
                    LPR[i] = '0' + (random() % 10);
                } else { // last 3 are letters
                    LPR[i] = 'A' + random() % 26;
                }
            }
            //printf("%s.\n",LPR);
        }

        break;

        //Break and finish if plate doesnt exist
        /*
        if (! plate exists) {
            break;
        }
        */
    }    
}


/* ----------------------------------------------Boom arm simulation functions----------------------------------------------------*/
void toggleGate() {

}

/* ----------------------------------------------Fire sensor functions----------------------------------------------------*/
void generateTemperature(void) {
    switch(fireState) {
        case 1: //Creep Event (Rising Average)
            //code
            break;
        case 2: //Spike Event (Jump to temps > 58)
            //code
            break;
        default: //Normal Operation
            //code
            break;
    }
}