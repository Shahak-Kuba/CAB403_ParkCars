#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

#define SHMSZ 2120 // defining size for shared memory
#define KEY "CPark" // defining key for shared memory


// Struct for Entrance
typedef struct Enter
{
    pthread_mutex_t LPR_mutex;
    pthread_cond_t LPR_cond;
    char LPR_reading[6];
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
    char LPR_reading[6];
    pthread_mutex_t BOOM_mutex;
    pthread_cond_t BOOM_cond;
    char BOOM_status;
} Exit_t;

// Struct for Level

typedef struct Level
{
    pthread_mutex_t LPR_mutex;
    pthread_cond_t LPR_cond;
    char LPR_reading[6];
    char temp_sensor[2];
    char fire_alarm;
} Level_t;

// Struct for entire Carpark

typedef struct CarPark
{
    // Creating the entrances
    Enter_t Enter[5];
    // Creating the Exits
    Exit_t Exit[5];
    // Creating levels
    Level_t Level[5];
} CP_t;


// A shared memory control structure.

typedef struct Shm_Carpark {
    /// The name of the shared memory object.
    const char* key;
    /// The file descriptor used to manage the shared memory object.
    int fd;
    /// Pointer to address of the shared data block. 
    CP_t* shm_car;
} shm_CP_t;

// Car data type

typedef struct Car
{
    int thread_no;
    char LPR[6]; // random LPR number
    time_t time_stayed; // time data type to keep track of 
    struct car_data *next;

} Car_t;



