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
#define QUEUE_LENGTH 100


// ---------------------------------------shared memory --------------------------------------------------------

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
    int16_t temp_sensor;
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


// --------------------------------------------------Car struct-------------------------------------------

typedef struct Car Car_t;
struct Car
{
    int level;
    clock_t time_in;
    int time_inside; // in ms
    char LPR[6];
    Car_t *next;
};

// ---------------------------------------------------------Hash table-------------------------------------------------------
typedef struct NP NP_t;
struct NP
{
    char number_plate[7];
    NP_t *next;
} ;

typedef struct htab htab_t;
struct htab
{
  NP_t **buckets;
  size_t size;  
};

// ---------------------------------------------------------Queue-------------------------------------------------------
typedef struct queue queue;
struct queue
{
    int count;
    NP_t *front;
    NP_t *rear;
};


// Firealarm 
#define EVAC_MESSAGE "EVACUATE "
#define MEDIAN_WINDOW 5
#define TEMPCHANGE_WINDOW 30

// variables
int16_t tempArray [NUM_LEVELS][TEMPCHANGE_WINDOW + MEDIAN_WINDOW]; // assume that 0 values are init
int tempArrayIndex[NUM_LEVELS];
int shm_fd;
shm_CP_t shm;
int alarm_active = 0;