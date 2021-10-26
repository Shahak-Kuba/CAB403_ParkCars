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

// hash table allocation
bool htab_init(htab_t *h, size_t n); // function to initialise hash table
size_t htab_index(htab_t *h, char *key); // function to duns index of hash table
size_t djb_hash(char *s);
void item_print(item_t *i);
bool htab_add(htab_t *h, char *key, int value);
item_t *htab_bucket(htab_t *h, char *key);
int LPR_to_htab(htab_t* h);
item_t *htab_find(htab_t *h, char *key);
void htab_destroy(htab_t *h); // function to destroy hash table at the end


/* SHARED MEMORY functions */
int shared_mem_init_open(shm_CP_t* shm, const char* shm_key);

/* ENTRANCE functions */
void enter_carpark();// this will be a function that allows a car to enter the carpark
bool LPR_detect(htab_t *h, char LPR[6]); // function that will check if the LPR is on the list
void detect(char LPR[6]);// this function will verify that the car can enter the car park
void navigate();// this function will navigate the car to the appropriate floor based on how full the carpark is
void boom_control();// function to control boomgate status

/* EXIT functions */



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

// functuon to detect if the random license plate is on the allocated .txt file
bool LPR_detect(htab_t *h, char *LPR)
{
    if(htab_find(h, LPR) == NULL)
    {
        return false;
    }
    return true;
}

//

// -----------------------------------------------------Hash Table Function--------------------------------------------------------------------------

// initialising has table
bool htab_init(htab_t *h, size_t n)
{
    h->size = n;
    h->buckets = (item_t **)calloc(n, sizeof(item_t *));
    return h->buckets != 0;
}

// The Bernstein hash function.
// A very fast hash function that works well in practice.
size_t djb_hash(char *s)
{
    size_t hash = 5381;
    int c;
    while ((c = *s++) != '\0')
    {
        // hash = hash * 33 + c
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

// Add a key with value to the hash table.
// pre: htab_find(h, key) == NULL
// post: (return == false AND allocation of new item failed)
//       OR (htab_find(h, key) != NULL)
bool htab_add(htab_t *h, char *key, int value)
{
    // allocate new item
    item_t *newhead = (item_t *)malloc(sizeof(item_t));
    if (newhead == NULL)
    {
        return false;
    }
    newhead->key = key;
    newhead->value = value;

    // hash key and place item in appropriate bucket
    size_t bucket = htab_index(h, key);
    newhead->next = h->buckets[bucket];
    h->buckets[bucket] = newhead;
    //printf("bucket %ld has key is: %s with a value of %d\n", bucket, h->buckets[bucket]->key, h->buckets[bucket]->value);
    return true;
}

// Calculate the offset for the bucket for key in hash table.
size_t htab_index(htab_t *h, char *key)
{
    return djb_hash(key) % h->size;
}

// Find pointer to head of list for key in hash table.
item_t *htab_bucket(htab_t *h, char *key)
{
    return h->buckets[htab_index(h, key)];
}

// item find
item_t *htab_find(htab_t *h, char *key)
{
    for (item_t *i = htab_bucket(h, key); i != NULL; i = i->next)
    {
        if (strcmp(i->key, key) == 0)
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
        item_t *bucket = h->buckets[i];
        while (bucket != NULL)
        {
            item_t *next = bucket->next;
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
    // initialising buffer of 100000 bytes (in case of a long plates.txt)
    char source[6]; // reading a number plate of 8 bytes long
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
        if ((htab_add(h, source, 0)) == false)
        {
            printf("error adding number plate to hash table");
        }
        //size_t index = htab_index(h,source);
    }
    printf("successfuly allocated number plates to hash table\n");
    return 0;
}


// -----------------------------------------------------------------------------------------------------------------MAIN--------------------------------------------------------------------------------------------------------------------------------------------------

int main()
{
    // opening shared memory
    const char* key;
    shm_CP_t PARKING;
    key = KEY;
    shared_mem_init_open(&PARKING, key);

    // initialising has table
    size_t buckets = 10;
    htab_t h;
    if (!htab_init(&h, buckets))
    {
        printf("failed to initialise hash table\n");
        return EXIT_FAILURE;
    }

    LPR_to_htab(&h); // allocating the allowed number plated to hash table

    // setting up threads
    pthread_t enter1;
    Car_t data1;

    pthread_create(&enter1, NULL, (void *(*)(void *))LPR_detect, (void *)&data1);


    
    // loop that runs the simulation
    while(sim)
    {   
        // pull in car 
        sim = false;
    }
    return EXIT_SUCCESS;
}
