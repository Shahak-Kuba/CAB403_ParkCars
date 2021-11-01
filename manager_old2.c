#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>
#include "datas.h"

// Global variables
shm_CP_t CP;
htab_t h;

// level counter to count how many cars in a level
int level_car_counter[] = {0,0,0,0,0}; // zero cars in each level initally
pthread_mutex_t level_car_counter_mutex;

// define linked lists
Car_t *cars_inside_head = NULL;

// mutex lock for adding cars inside
pthread_mutex_t add_car_in_mutex;


// Predefining functions

// adding to array of linked lists func
int addCar(Car_t *head, char *LPR, int level_num);
int deleteCar(Car_t *head, char *LPR);

void Assignment_Sleep(int time_in_milli_sec);

/* Hash Table functions */
bool htab_init(htab_t *h, size_t n);
size_t djb_hash(char *s);
size_t htab_index(htab_t *h, char *key);
bool htab_add(htab_t *h, char key[7]);
NP_t *htab_bucket(htab_t *h, char *key);
NP_t *htab_find(htab_t *h, char *key);
void htab_destroy(htab_t *h);
int LPR_to_htab(htab_t *h);
void item_print(NP_t *i);
void htab_print(htab_t *h);

/* SHARED MEMORY functions */
int shared_mem_init_open(shm_CP_t *shm, const char *shm_key);

/* ENTRANCE functions */
void *enterFunc(void *enter_num);
void *exitFunc(void *exit_num);

int main()
{
    // opening shared memory
    const char* key;
    key = KEY;
    shared_mem_init_open(&CP, key);

    // initialising has table
    size_t buckets = 10;
    if (!htab_init(&h, buckets))
    {
        printf("failed to initialise hash table\n");
        return EXIT_FAILURE;
    }
    // allocate plates to hash table
    LPR_to_htab(&h);
    //htab_print(&h); // debug print

    int num = 0;

    pthread_t enter; 
    pthread_create(&enter,NULL,enterFunc,(void *)&num);
    
    /*
    pthread_t exit;
    pthread_create(&exit, NULL, exitFunc, (void *)&num);*/


    pthread_join(enter, NULL);

}


// Functions


void Assignment_Sleep(int time_in_milli_sec)
{
    int time = time_in_milli_sec * 1000;
    usleep(time);
}

// -----------------------------------------------------Shared Memory Function--------------------------------------------------------------------------

int shared_mem_init_open(shm_CP_t* shm, const char *shm_key)
{   
    // opening the shared data, otherwise producing an error
    if ((shm->fd = shm_open(shm_key, O_RDWR, 0)) < 0)
        {
            perror("unable to open shared memory");
            return(EXIT_FAILURE);
        }
    // mapping memory
    if((shm->shm_ptr = mmap(0, SHMSZ, PROT_WRITE, MAP_SHARED, shm->fd,0)) == (CP_t *) - 1)
    {
        perror("mmap");
        return(EXIT_FAILURE);
    }
    printf("shared memory opened!\n");
    return(EXIT_SUCCESS);
}

// -----------------------------------------------------Hash Table Function--------------------------------------------------------------------------

// initialising has table
bool htab_init(htab_t *h, size_t n)
{
    h->size = n;
    h->buckets = (NP_t **)calloc(n, sizeof(NP_t *));
    return h->buckets != 0;
}

// The Bernstein hash function.
// A very fast hash function that works well in practice.
size_t djb_hash(char *s)
{
    size_t hash = 5381;
    int c = 0;
    while ((c = *s++) != '\0')
    {
        // hash = hash * 33 + c
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

// Calculate the offset for the bucket for key in hash table.
size_t htab_index(htab_t *h, char *key)
{
    return djb_hash(key) % h->size;
}

// adding function for hash table
bool htab_add(htab_t *h, char key[7])
{
    // allocating space for a new number plate
    NP_t *newhead = (NP_t *)malloc(sizeof(NP_t));
    // check if new head was created
    if(newhead == NULL)
    {
        return false;
    }
    // copy number plate from key into number_plate
    memcpy(newhead->number_plate, key, 6);
    newhead->number_plate[6] = 0;
    // finding index of next hash 
    size_t bucket = htab_index(h,newhead->number_plate);
    newhead->next = h->buckets[bucket];
    h->buckets[bucket] = newhead;
    return true;
    
}

// Find pointer to head of list for key in hash table.
NP_t *htab_bucket(htab_t *h, char *key)
{
    return h->buckets[htab_index(h, key)];
}

// item find
NP_t *htab_find(htab_t *h, char *key)
{
    char buff[7];
    memcpy(buff,key, 6);
    buff[6] = 0;
    for (NP_t *i = htab_bucket(h, key); i != NULL; i = i->next)
    {
        if (strcmp(i->number_plate, key) == 0)
        { // found the key
            return i;
        }
    }
    return NULL;
}

void htab_destroy(htab_t *h)
{
    // free linked lists
    for (size_t i = 0; i < h->size; ++i)
    {
        NP_t *bucket = h->buckets[i];
        while (bucket != NULL)
        {
            NP_t *next = bucket->next;
            free(bucket);
            bucket = next;
        }
    }

    // free buckets array
    free(h->buckets);
    h->buckets = NULL;
    h->size = 0;
}

// reading from file directly into a hash table
int LPR_to_htab(htab_t *h)
{
    // initialising hast table
    // Reading the file
    char source[7]; // reading a number plate of 7 bytes long
    FILE *file = fopen(LPFILE, "r"); // opening in file mode
    // checking file exists
    if (file == NULL)
    {
        printf("Error reading %s please make sure file exists", LPFILE);
    }
    // scanning for number plate
    while((fscanf(file, "%s", source)) != EOF)
    {
        //printf("%s\n", source);
        if ((htab_add(h, source)) == false)
        {
            printf("error adding number plate to hash table");
        }
    }
    printf("successfuly allocated number plates to hash table\n");
    return 0;
}

void item_print(NP_t *i)
{
    printf("key=%s", i->number_plate);
}

void htab_print(htab_t *h)
{
    printf("hash table with %ld buckets\n", h->size);
    for (size_t i = 0; i < h->size; ++i)
    {
        printf("bucket %ld: ", i);
        if (h->buckets[i] == NULL)
        {
            printf("empty\n");
        }
        else
        {
            for (NP_t *j = h->buckets[i]; j != NULL; j = j->next)
            {
                item_print(j);
                if (j->next != NULL)
                {
                    printf(" -> ");
                }
            }
            printf("\n");
        }
    }
}

// Add function
int addCar(Car_t *head, char *LPR, int level_num)
{
    Car_t *newcar = (Car_t *)malloc(sizeof(Car_t));
    if(newcar == NULL)
    {
        printf("could not malloc Car_t\n");
        return 1;
    }
    newcar->level = level_num;
    memcpy(newcar->LPR, LPR, 6);
    newcar->time_in = clock();
    newcar->next = NULL;

    if(head == NULL)
    {
        head = newcar;
    }
    else
    {
        // finding last null pointer
        while(head->next != NULL)
        {
            head = head->next;
        }
        head->next = newcar;
    }
    /*
    printf("LPR: %s, time in: %ld, time inside: %d, level: %d\n", newcar->LPR, newcar->time_in, newcar->time_inside, newcar->level);
    sleep(3);*/
    return 0;

}

int deleteCar(Car_t *head, char *LPR)
{
    Car_t *previous = NULL;
    Car_t *current = head;
    while (current != NULL)
    {
        if (strcmp(LPR, current->LPR) == 0)
        {
            Car_t *newhead = head;
            if (previous == NULL) // first item in list
                newhead = current->next;
            else
                previous->next = current->next;
            free(current);
            printf("this is dumb %s\n", newhead->LPR);
            return 0; // car removed
        }
        previous = current;
        current = current->next;
    }
    // LPR not found
    return 1; 
}

// Enternce routine

void *enterFunc(void *enter_num)
{
    // get the entrance we are looking at
    int num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // initially locking all mutex's for enterance 
    pthread_mutex_lock(&entrance->LPR_mutex);

    // temporary LPR variable to store any cars that come to entrance
    char temp_LPR[7];
    // last byte set to end character
    temp_LPR[6] = 0; 

    // initialising level to be -1 (not allocated yet)
    int level_num = -1;
    // inifinite while loop
    while(1)
    {
        // checking if there is a number plate in LPR reading
        if(entrance->LPR_reading[0] != 0){
            //printf("car at the entrance\n");
            // copying new LP to the temp variable
            memcpy(temp_LPR, entrance->LPR_reading, 6);

            // check if car is allowed in
            if(htab_find(&h, temp_LPR) != NULL){

                // find level number and incrementing
                pthread_mutex_lock(&level_car_counter_mutex);
                level_num = -1; // resetting level to be -1
                for (int i = 0; i < NUM_LEVELS; i++)
                {
                    if(level_car_counter[i] < LEVEL_CAPACITY)
                    {
                        level_num = i;
                        level_car_counter[i]++;
                        printf("inserting a car to level %d\n", i); //debug
                        break;
                    }
                }
                // check if carpark is full (should not happen but incase it does)
                if(level_num == -1)
                {
                    printf("Carpark is full idiot!");
                    break;
                }
                // release level counter mutex 
                pthread_mutex_unlock(&level_car_counter_mutex);
                //printf("added car\n");


                // checking cars are going to the right level
                printf("%s inserted into carpark at level %d\n", temp_LPR, level_num);
                //printf("number of cars in a each level: \n" );
                for(int i = 0; i < NUM_LEVELS; i++)
                {
                    printf("Level %d: %d \n",i+1, level_car_counter[i]);
                }

                // set the value for the info sign
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = '1' + level_num;
                pthread_mutex_unlock(&entrance->info_sign_mutex);
                //printf("sign set to %c\n", entrance->info_sign_status);

                /*-----------------RAISING BOOM GATE ----------------*/ 

                 // sending signal to open boom gate 
                pthread_mutex_lock(&entrance->BOOM_mutex);
                entrance->BOOM_status = 'R';
                //printf("Boom status is set to %c\n",entrance->BOOM_status);
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // sending signal to simulator boom
                //printf("sending signal to BOOM GATE Simulator with raising\n");
                pthread_cond_signal(&entrance->BOOM_cond);
                //printf("signal sent\n");
                // waiting then locking
                //printf("waiting for open gate signal\n");
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex); // unlocks and mutex and wait
                //printf("Boom status is set to %c\n",entrance->BOOM_status);
                pthread_mutex_unlock(&entrance->BOOM_mutex);

                /* -----------------------Storing Cars--------------------*/
                pthread_mutex_lock(&add_car_in_mutex);
                
                // adding that new car to the tail of the linked list
                if((addCar(cars_inside_head, entrance->LPR_reading, level_num)) != 0)
                {
                    printf("you broke me first\n"); 
                }

                pthread_mutex_unlock(&add_car_in_mutex);
                /*-----------------Navigating car ----------------*/ 
            
                // sending signal to info sign cond
                pthread_cond_signal(&entrance->info_sign_cond);
                // waiting for a signal saying the car has gone in
                pthread_cond_wait(&entrance->info_sign_cond,&entrance->info_sign_mutex);
                // unlocking mutex for other cars
                pthread_mutex_unlock(&entrance->info_sign_mutex);


                /*-----------------LOWERING BOOM GATE ----------------*/ 
                pthread_mutex_lock(&entrance->BOOM_mutex);
                entrance->BOOM_status = 'L';
                //printf("Boom status is set to %c\n",entrance->BOOM_status);
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // send a signal to simulator to lower the boom arm
                //printf("sending signal to BOOM GATE Simulator with raising\n");
                pthread_cond_signal(&entrance->BOOM_cond);
                //printf("signal sent\n");
                // waiting then locking
                //printf("waiting for open gate signal\n");
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex); // unlocks and mutex and wait
                //printf("Boom status is set to %c\n",entrance->BOOM_status);
                pthread_mutex_unlock(&entrance->BOOM_mutex);

            }
            else
            {
                // set the value for the info sign
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = 'X';
                pthread_mutex_unlock(&entrance->info_sign_mutex);
                printf("sign set to %c\n", entrance->info_sign_status);

                
                // sending signal to level LPR
                pthread_cond_signal(&entrance->info_sign_cond);
            }
            // send a signal saying im empty
            pthread_cond_signal(&entrance->LPR_cond);
        }  

        //printf("waiting for a new car to be at the entrance\n");
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);

    }  
    //unlocking all mutex
    pthread_mutex_unlock(&entrance->LPR_mutex);
    return 0;  
}

// Exit routine
void *exitFunc(void *exit_num)
{
    // get enterance number cast from void
    int num = *(int *)exit_num;
    Exit_t *exit = &CP.shm_ptr->Exit[num];
    double cost;

    pthread_mutex_lock(&exit->LPR_mutex);
     // infinite loop
    while(1)
    {
        // check if we can pull a car out
        if(cars_inside_head != NULL)
        {
            // copy LPR to exit LPR
            pthread_mutex_lock(&add_car_in_mutex);
            memcpy(&exit->LPR_reading, &cars_inside_head->LPR, 6);
            

            // get time time it was in / billing
            cost = ((double)(clock() - cars_inside_head->time_in)/ CLOCKS_PER_SEC )* 0.05;
            printf("the cost is %f\n", cost);


            // send a boomgate signal to open
            /*-----------------RAISING BOOM GATE ----------------*/ 

            // sending signal to open boom gate 
            pthread_mutex_lock(&exit->BOOM_mutex);
            exit->BOOM_status = 'R';
            printf("Boom status is set to %c\n",exit->BOOM_status);
            pthread_mutex_unlock(&exit->BOOM_mutex);
            // sending signal to simulator boom
            printf("sending signal to BOOM GATE Simulator with raising\n");
            pthread_cond_signal(&exit->BOOM_cond);
            printf("signal sent\n"); 
            // waiting then locking
            printf("waiting for open gate signal\n");
            pthread_cond_wait(&exit->BOOM_cond, &exit->BOOM_mutex); // unlocks and mutex and wait
            printf("Boom status is set to %c\n",exit->BOOM_status);
            pthread_mutex_unlock(&exit->BOOM_mutex);

            // remove from linked list
            if((deleteCar(cars_inside_head, exit->LPR_reading)) != 0)
            {
                printf("could not find LPR");
            }

            pthread_mutex_unlock(&add_car_in_mutex);

            // send a boomgate signal to close
            /*-----------------LOWERING BOOM GATE ----------------*/ 
            pthread_mutex_lock(&exit->BOOM_mutex);
            exit->BOOM_status = 'L';
            printf("Boom status is set to %c\n",exit->BOOM_status);
            pthread_mutex_unlock(&exit->BOOM_mutex);
            // send a signal to simulator to lower the boom arm
            printf("sending signal to BOOM GATE Simulator with raising\n");
            pthread_cond_signal(&exit->BOOM_cond);
            printf("signal sent\n");
            // waiting then locking
            printf("waiting for open gate signal\n");
            pthread_cond_wait(&exit->BOOM_cond, &exit->BOOM_mutex); // unlocks and mutex and wait
            printf("Boom status is set to %c\n",exit->BOOM_status);
            pthread_mutex_unlock(&exit->BOOM_mutex);

        }

        // non busy waiting
        printf("waiting for exit LPR signal\n");
        pthread_cond_wait(&exit->LPR_cond, &exit->LPR_mutex);
    }
}


















