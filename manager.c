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
#include <sys/ioctl.h>
#include <math.h>
#include "datas.h"

#define DEBUG false




// Global variables
shm_CP_t CP;
htab_t h;

// billing
float total_revenue = 0;

// level counter to count how many cars in a level
int level_car_counter[] = {0,0,0,0,0}; // zero cars in each level initally
pthread_mutex_t level_car_counter_mutex;

// initialising linked list of cars inside
Car_t *cars_inside = NULL;
// mutex lock for adding cars inside
pthread_mutex_t add_car_in_mutex;

// Predefining functions

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

// Display functions
void *display_func();
pthread_t display_thread;

/* SHARED MEMORY functions */
int shared_mem_init_open(shm_CP_t *shm, const char *shm_key);

/* ENTRANCE functions */
void *enterFunc(void *enter_num);

int main()
/*****************************************************************************
 * @brief   Main program for manager.c
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  void
 * @arg     void
 * @note    
 *****************************************************************************/
{
    // opening shared memory
    const char* key;
    key = KEY;
    shared_mem_init_open(&CP, key);

    // initialising has table
    size_t buckets = 10;
    if (!htab_init(&h, buckets))
    {
        if(DEBUG) {printf("failed to initialise hash table\n");}
        return EXIT_FAILURE;
    }
    // allocate plates to hash table
    LPR_to_htab(&h);
    if(DEBUG){htab_print(&h);} // debug print


    int num = 0;

    pthread_t enter; 
    pthread_create(&enter,NULL,enterFunc,(void *)&num);

    pthread_create(&display_thread, NULL, (void *)display_func, NULL );

    pthread_join(enter, NULL);

}


void Assignment_Sleep(int time_in_milli_sec)
/*****************************************************************************
 * @brief   Sleeps for a given amount of milliseconds
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  void
 * @arg     void
 *****************************************************************************/
{
    int time = time_in_milli_sec * 1000;
    usleep(time);
}

// -----------------------------------------------------Shared Memory Function--------------------------------------------------------------------------

int shared_mem_init_open(shm_CP_t* shm, const char *shm_key)
/*****************************************************************************
 * @brief   Opens a shared memory location created by the simulator
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  int (EXIT_SUCCESS)
 * @arg     shm_CP_t* shm: pointer struct containing all car park data
 *          char* shm_key: key to map memory to
 *****************************************************************************/
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
    if(DEBUG) {printf("shared memory opened!\n");}
    return(EXIT_SUCCESS);
}

// -----------------------------------------------------Hash Table Function--------------------------------------------------------------------------

// initialising has table
bool htab_init(htab_t *h, size_t n)
/*****************************************************************************
 * @brief   Initializes a hash table struct of size n
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  bool:
 *              - true if memory allocation completed successfully
 *              - false if memory allocation failed
 * @arg     htab_t *h: hash table to initialize
 *          size_t n: size to initialize hash table
 *****************************************************************************/
{
    h->size = n;
    h->buckets = (NP_t **)calloc(n, sizeof(NP_t *));
    return h->buckets != 0;
}

size_t djb_hash(char *s)
/*****************************************************************************
 * @brief   The Bernstein hash function. A very fast hash function that works well in practice.
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  size_t: hash location
 * @arg     char *s: hash character
 *****************************************************************************/
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
/*****************************************************************************
 * @brief   Gets index of a key in a given hash table
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  size_t: location of key
 * @arg     htab_t *h: hash table to initialize
 *          char *key: key to look for
 *****************************************************************************/
{
    return djb_hash(key) % h->size;
}

// adding function for hash table
bool htab_add(htab_t *h, char key[7])
/*****************************************************************************
 * @brief   Adds a number plate to given hash table
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
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
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
{
    return h->buckets[htab_index(h, key)];
}

// item find
NP_t *htab_find(htab_t *h, char *key)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
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
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
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
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
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
        //if(DEBUG) {printf("%s\n", source);}
        if ((htab_add(h, source)) == false)
        {
            printf("error adding number plate to hash table");
        }
    }
    if(DEBUG) {printf("successfuly allocated number plates to hash table\n");}
    return 0;
}

void item_print(NP_t *i)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
{
    printf("key=%s", i->number_plate);
}

void htab_print(htab_t *h)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
{
    if(DEBUG) {printf("hash table with %ld buckets\n", h->size);}
    for (size_t i = 0; i < h->size; ++i)
    {
        if(DEBUG) {printf("bucket %ld: ", i);}
        if (h->buckets[i] == NULL)
        {
            if(DEBUG) {printf("empty\n");}
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

// -----------------------------------------------------Car and entrances/exits--------------------------------------------------------------------------


// linked list function
int addCar(int level, char *LPR)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
{
    Car_t *newcar = (Car_t*)malloc(sizeof(Car_t));
    if(newcar == NULL)
    {
        printf("could not malloc Car_t\n");
        return 1;
    }
    newcar->level = level;
    memcpy(newcar->LPR, LPR, 6);
    newcar->time_in = clock();
    newcar->next = NULL;

    if(cars_inside == NULL)
    {
        cars_inside = newcar;
    }
    else
    {
        // finding last null pointer
        while(cars_inside->next != NULL)
        {
            cars_inside = cars_inside->next;
        }
        cars_inside->next = newcar;
    }

    return 0;
}

// Enterance routine

void *enterFunc(void *enter_num)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
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
            if(DEBUG) {printf("car at the entrance\n");}
            // copying new LP to the temp variable
            memcpy(temp_LPR, entrance->LPR_reading, 6);
            level_num = -1;
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
                        if(DEBUG) {printf("inserting a car to level %d\n", i);}
                        break;
                    }
                }
                // check if carpark is full (should not happen but incase it does)
                if(level_num == -1)
                {
                    if(DEBUG) {printf("Carpark is full!\n");}
                    break;
                }
                // release level counter mutex 
                pthread_mutex_unlock(&level_car_counter_mutex);


                // checking cars are going to the right level
                if(DEBUG) 
                {
                    printf("%s inserted into carpark at level %d\n", temp_LPR, level_num);
                    printf("number of cars in a each level: \n" );
                    for(int i = 0; i < NUM_LEVELS; i++)
                    {
                        printf("Level %d: %d \n",i+1, level_car_counter[i]);
                    }
                }

                // set the value for the info sign
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = '1' + level_num;
                pthread_mutex_unlock(&entrance->info_sign_mutex);
                if(DEBUG) {printf("sign set to %c\n", entrance->info_sign_status);}

                /*-----------------RAISING BOOM GATE ----------------*/ 

                 // sending signal to open boom gate 
                pthread_mutex_lock(&entrance->BOOM_mutex);
                entrance->BOOM_status = 'R';
                if(DEBUG) {printf("Boom status is set to %c\n",entrance->BOOM_status);}
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // sending signal to simulator boom
                if(DEBUG) {printf("sending signal to BOOM GATE Simulator with raising\n");}
                pthread_cond_signal(&entrance->BOOM_cond);
                if(DEBUG) {printf("signal sent\n");}
                // waiting then locking
                if(DEBUG) {printf("waiting for open gate signal\n");}
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex); // unlocks and mutex and wait
                if(DEBUG) {printf("Boom status is set to %c\n",entrance->BOOM_status);}
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                
                /*-----------------storing car ----------------*/
                pthread_mutex_lock(&add_car_in_mutex);
                if((addCar(level_num, entrance->LPR_reading)) != 0)
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
                if(DEBUG) {printf("Boom status is set to %c\n",entrance->BOOM_status);}
                pthread_mutex_unlock(&entrance->BOOM_mutex);
                // send a signal to simulator to lower the boom arm
                if(DEBUG) {printf("sending signal to BOOM GATE Simulator with raising\n");}
                pthread_cond_signal(&entrance->BOOM_cond);
                if(DEBUG) {printf("signal sent\n");}
                // waiting then locking
                if(DEBUG) {printf("waiting for open gate signal\n");}
                pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex); // unlocks and mutex and wait
                if(DEBUG) {printf("Boom status is set to %c\n",entrance->BOOM_status);}
                pthread_mutex_unlock(&entrance->BOOM_mutex);

            }
            else
            {
                // set the value for the info sign
                pthread_mutex_lock(&entrance->info_sign_mutex);
                entrance->info_sign_status = 'X';
                pthread_mutex_unlock(&entrance->info_sign_mutex);
                if(DEBUG) {printf("sign set to %c\n", entrance->info_sign_status);}

                
                // sending signal to level LPR
                pthread_cond_signal(&entrance->info_sign_cond);
                // waiting for a signal saying the car has gone in
                pthread_cond_wait(&entrance->info_sign_cond,&entrance->info_sign_mutex);
                // unlocking mutex for other cars
                pthread_mutex_unlock(&entrance->info_sign_mutex);
            }
            // send a signal saying im empty
            pthread_cond_signal(&entrance->LPR_cond);
        }  

        if(DEBUG) {printf("waiting for a new car to be at the entrance\n");}
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);

    }  
    //unlocking all mutex
    pthread_mutex_unlock(&entrance->LPR_mutex);
    return 0;
}

void *exitFunc(void *exit_num)
/*****************************************************************************
 * @brief   TODO
 * @author  Shaq Kuba
 * @date    01/11/2021
 * @return  TODO
 * @arg     TODO
 *****************************************************************************/
{
    // getting exit number
    int num = *(int *)exit_num;
    Exit_t *exit = &CP.shm_ptr->Exit[num];


    pthread_mutex_lock(&exit->LPR_mutex);
    while(1)
    {
        



        pthread_cond_wait(&exit->LPR_cond, &exit->LPR_mutex);
    }
}

// -----------------------------------------------------Displaying info--------------------------------------------------------------------------


void *display_func()
/*****************************************************************************
 * @brief   Displays a GUI of all values
 * @author  Maxime Stuehrenberg
 * @date    01/11/2021
 * @return  void
 * @arg     void
 *****************************************************************************/
{
    if(DEBUG == false)
    {

        for(;;)
        {
            system("clear");
            struct winsize w;
            ioctl(0, TIOCGWINSZ, &w);
            int width =  w.ws_col;
            char *bar; 
            bar = (char*)malloc ( width * sizeof (char));
            for(int i = 0; i < width; i++)
            {
                bar[i] = '=';
            }

            

            // Display 

            printf("%s\n", bar);

            int calc = (int)floor((width - 29)/2);
            char space_buffer[calc];


            for(int i = 0; i < calc; i++)
            {
                space_buffer[i] = ' ';
            }

            // firealarm check

            for(int l = 0; l < NUM_LEVELS; l++)
            {
                if(CP.shm_ptr->Level[l].fire_alarm == '1')
                {
                    printf("%s", space_buffer);
                    printf("!!! FIRE ALARM ACTIVE ON LEVEL %d !!!", l);
                    printf("%s\n", space_buffer);
                }
                
            }

            printf("\nEntrance license plates:\n");
            
            for(int e = 0; e < NUM_ENTERS; e++)
            {
                char * text = CP.shm_ptr->Enter[e].LPR_reading;
                if(text[0] == 0)
                {
                    text = " None ";
                }
                printf(" ENT %d LPR: |%s|", e, text);
            }
            printf("\n\n");
            printf("Exit license plates:\n");
            
            for(int e = 0; e < NUM_EXITS; e++)
            {
                char * text = CP.shm_ptr->Exit[e].LPR_reading;
                if(text[0] == 0)
                {
                    text = " None ";
                }
                printf(" EXT %d LPR: |%s|", e, text);
            }
            printf("\n\n");
            printf("Temperature sensors:\n");
            
            for(int l = 0; l < NUM_LEVELS; l++)
            {
                printf(" LVL %d TMP: |  %d  |", l, CP.shm_ptr->Level[l].temp_sensor);
            }

            printf("\n\n");
            printf("Level capacities:\n");
            for(int l = 0; l < NUM_LEVELS; l++)
            {
                printf(" LVL %d CAP: |%d of %d|", l, level_car_counter[l], LEVEL_CAPACITY);
            }
            printf("\n\n");
            printf("Total billing revenue: $%.2f\n",total_revenue );


            printf("\n");
            printf("\n");
            printf("\n");
            printf("%s\n", bar);
            usleep(50000);
        }
    }
    
    
    return 0;
}














