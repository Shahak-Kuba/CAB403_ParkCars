#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

#define SHMSZ 2120 // defining size for shared memory
#define KEY "PARKING" // defining key for shared memory
#define NUM_LEVELS 5
#define NUM_ENTERS 5
#define NUM_EXITS 5
#define LPRSZ 6
#define LEVEL_CAPACITY 20
#define LPFILE "plates.txt"


// Struct for Entrance
typedef struct Enter
{
    pthread_mutex_t LPR_mutex;
    pthread_cond_t LPR_cond;
    char LPR_reading[LPRSZ];
    pthread_mutex_t BOOM_mutex;
    pthread_cond_t BOOM_cond;
    char BOOM_status;
    pthread_mutex_t info_sign_mutex;
    pthread_cond_t info_sign_cond;
    char info_sign_status;
} Enter_t;

// Struct for Exit 

typedef struct Exit
{
    pthread_mutex_t LPR_mutex;
    pthread_cond_t LPR_cond;
    char LPR_reading[LPRSZ];
    pthread_mutex_t BOOM_mutex;
    pthread_cond_t BOOM_cond;
    char BOOM_status;
} Exit_t;

// Struct for Level

typedef struct Level
{
    pthread_mutex_t LPR_mutex;
    pthread_cond_t LPR_cond;
    char LPR_reading[LPRSZ];
    char temp_sensor[2];
    char fire_alarm;
} Level_t;

// Struct for entire Carpark

typedef struct CarPark
{
    // Creating the entrances
    Enter_t Enter[NUM_ENTERS];
    // Creating the Exits
    Exit_t Exit[NUM_EXITS];
    // Creating levels
    Level_t Level[NUM_LEVELS];
} CP_t;


// A shared memory control structure.

typedef struct Shm_Carpark {
    /// The name of the shared memory object.
    const char* key;
    /// The file descriptor used to manage the shared memory object.
    int fd;
    /// Pointer to address of the shared data block. 
    CP_t* shm_ptr;
} shm_CP_t;

// Car data type

typedef struct Car
{
    int thread_no;
    char LPR[LPRSZ + 1]; // random LPR number with a space for 0 char
    time_t time_in; // entered time
    time_t time_out; // exited time
    struct Car *next;

} Car_t;


// ---------------------------------------------------------Hash table-------------------------------------------------------

// An item inserted into a hash table.
// As hash collisions can occur, multiple items can exist in one bucket.
// Therefore, each bucket is a linked list of items that hashes to that bucket.
typedef struct item item_t;
struct item
{
    char *key;
    int value;
    item_t *next;
};

// A hash table mapping a string to an integer.
typedef struct htab htab_t;
struct htab
{
    item_t **buckets;
    size_t size;
};

