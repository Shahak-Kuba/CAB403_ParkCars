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
#include "datas.h"

// Global variables
shm_CP_t CP;
htab_t h;

// level counter to count how many cars in a level
int level_car_counter[] = {0,0,0,0,0}; // zero cars in each level initally
pthread_mutex_t level_car_counter_mutex;

// initialising the simulation
bool sim = true;

// car data type to for manager to know car info

/*
typedef struct Car Car_t;
typedef struct Car
{
    int level; // allocated level
    char LPR[6]; // random LPR number with a space for 0 char
    clock_t time_in; // entered time
    clock_t time_out; // exited time
    struct Car_t *next; // pointer to next car in linked list
}*/

// Predefining functions

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

/* EXIT functions */


//----------------------------------------------------------------------MAIN---------------------------------------------------------------------//
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
    htab_print(&h); // debug print


    // creating linked list to the cars at each level



    
    printf("SENDING IT.....\n");
    char LPR[7] = "927KOB";
    printf("%s \n", LPR);

    memcpy(CP.shm_ptr->Enter[0].LPR_reading, LPR, 6);

    int enter_num = 0;

    pthread_t enter; 
    pthread_create(&enter,NULL, enterFunc , (void *)&enter_num);
    sleep(1);
    pthread_mutex_lock(&CP.shm_ptr->Enter[0].LPR_mutex);
    pthread_cond_signal(&CP.shm_ptr->Enter[0].LPR_cond);
    pthread_mutex_unlock(&CP.shm_ptr->Enter[0].LPR_mutex);

    int* ptr;
    pthread_join(enter, (void**)&ptr);

    return EXIT_SUCCESS;
}




// Functions

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

// -----------------------------------------------------Entrance Function--------------------------------------------------------------------------

// Enternce routine

void* enterFunc(void *enter_num)
{
    // get the entrance we are looking at
    int num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];
    // initially locking all mutex's for enterance 
    printf("locking lpr");
    pthread_mutex_lock(&entrance->LPR_mutex);
    while(1)
    {
        printf("waiting for signal....\n");
        // checking if there is a number plate in LPR reading
        if(entrance->LPR_reading[0] != 0){
			// temp variable to store the LPR reading
            char temp_LPR[7];
            // copy the number plate from car arrived at gate
            memcpy(temp_LPR, entrance->LPR_reading, 6);
            temp_LPR[6] = 0; // last byte set to end character
            int level_num = -1; // initialising level to be -1 (not allocated yet)
            // check if car is allowed in
            if(htab_find(&h, temp_LPR) != NULL){
                // find level number and incrementing
                pthread_mutex_lock(&level_car_counter_mutex);
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
                // checking cars are going to the right level
                printf("%s inserted into carpark at level %d\n", temp_LPR, level_num);
                printf("number of cars in a each level: \n" );
                for(int i = 0; i < NUM_LEVELS; i++)
                {
                    printf("Level %d: %d \n",i+1, level_car_counter[i]);
                }
                
                // changing the sign
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = '1' + level_num; // min level is level 1
                pthread_mutex_unlock(&entrance->info_sign_mutex);
                pthread_cond_signal(&entrance->info_sign_cond);

                // sending signal to open boom gate 
                pthread_mutex_lock(&entrance->BOOM_mutex);
                entrance->BOOM_status = 'R';
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // sending signal to simulator boom
                pthread_cond_signal(&entrance->BOOM_cond);
                // waiting for the gate to open
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex);
                
                usleep(20000); // 20ms wait before boomgate closes

                // sending signal to lower boom gate
                pthread_mutex_lock(&entrance->BOOM_mutex);
                entrance->BOOM_status = 'L';
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // sending signal to simulator boom
                pthread_cond_signal(&entrance->BOOM_cond);
                // waiting for the gate to open
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex);
            }
            
            if(level_num == -1)
            {
                // changing the sign to be 'X'
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = 'X';
                pthread_cond_signal(&entrance->info_sign_cond);
            }
        }
        //removing the car from entrance
        entrance->LPR_reading[0] = 0;
        // signal to let simulator know the entrance is empty
        pthread_cond_signal(&entrance->LPR_cond);
        // small sleep so we dont clash 
        usleep(10);
        // check if car arrives at entrance gate
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);
    }
    //unlocking all mutex
    pthread_mutex_unlock(&entrance->LPR_mutex);
    return 0;

}

// -----------------------------------------------------Level Function--------------------------------------------------------------------------

