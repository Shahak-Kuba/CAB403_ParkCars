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
int LPR_to_htab(htab_t* h);
size_t htab_index(htab_t *h, char *key);
size_t djb_hash(char *s);
void item_print(item_t *i);

/* SHARED MEMORY functions */
int shared_mem_init_open(shm_CP_t* shm, const char* shm_key);

/* ENTRANCE functions */
void enter_carpark();// this will be a function that allows a car to enter the carpark
bool LPR_detect(char LPR[6]); // function that will check if the LPR is on the list
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


// -----------------------------------------------------Hash Table Function--------------------------------------------------------------------------

// printing a item in the hash table
void item_print(item_t *i)
{
    printf("key=%s value=%d", i->key, i->value);
}

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

// Print the hash table.
// pre: true
// post: hash table is printed to screen
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
            for (item_t *j = h->buckets[i]; j != NULL; j = j->next)
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

// reading from file directly into a hash table
int LPR_to_htab(htab_t *h)
{
    // initialising hast table
    // Reading the file
    // initialising buffer of 100000 bytes (in case of a long plates.txt)
    char source[8]; // reading a number plate of 8 bytes long
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
        if (htab_add(h, source, 0) == false)
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
    size_t buckets = 25;
    htab_t h;
    if (!htab_init(&h, buckets))
    {
        printf("failed to initialise hash table\n");
        return EXIT_FAILURE;
    }

    LPR_to_htab(&h);

    
    // loop that runs the simulation
    while(sim)
    {
        htab_print(&h);
        sim = false;
    }
    return EXIT_SUCCESS;
}
