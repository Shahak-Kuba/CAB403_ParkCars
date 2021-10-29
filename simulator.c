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

int car_list_chance = 50;

shm_CP_t CP;

// predefining shared memory functions
int shared_mem_init(shm_CP_t* shm, char* shm_key);
void clear_memory( shm_CP_t* shm ); 

// simulation functions

/* car simulation functions */
void car_sim(shm_CP_t* shm); // car simulation
void LPR_generator(); // function that will generate random LPR
void *navigate_func(void *enter_num); // direct a car and remembe the level it goes to (5 threads)
void *send_car_to_enter(void *enter_num); // sends a car from que to entrance (5 threads)
void *generate_car_queue(void *arg); // function that will fill a linked list of cars waiting for a 

// queue thread
pthread_t car_queue_thread;
pthread_mutex_t car_queue_mutex;
pthread_cond_t car_queue_cond;

// car queue functions
queue *q;
void initialize(queue *q);
int isempty(queue *q);
void enqueue(queue *q, char LP[7]);
char* dequeue(queue *q);
void display(NP_t *head);


/* boom arm simulation functions */
void *toggleGate(void *arg);
void init_gates();

/* fire sensor simulation functions */
int fireState = 0; //0 normal operation, 1 for creep & 2 for spike

int main()
{
    printf("Enter F to trigger Creeping Fire Alarm Event\n");
    printf("Enter G to trigger Spike Fire Alarm Event\n");
    // initialising shared memory
    shared_mem_init(&CP, KEY);

    // initializing boom gate status to closed for each level 
    init_gates();
    
    // initialize queue
    q = malloc(sizeof(queue));
    initialize(q);


    /*********************** INIT THREADS ***********************/
    pthread_create(&car_queue_thread, NULL, generate_car_queue, (void*)0);
    pthread_t entrances[NUM_ENTERS];
    // replace 1 with NUM_LEVELS
    for(int i = 0; i < 1; i++ )
    {
        pthread_create(&entrances[i], NULL, send_car_to_enter, (void *)&i  );
        pthread_create(&entrances[i], NULL, toggleGate, (void *)&i);
        
    }
    
    
    

    // Allocate space for LPR
    /*
    char LPR[7];
    LPR[6] = 0; // termination char
    for(int i = 0; i < 10; i++)
    {
        LPR_generator(LPR);
        printf("%s\n",LPR);
    }
    */
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
    printf("shared mem pointer: %p\n", shm->shm_ptr);
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
            FILE* file_ptr = fopen(LPFILE,"r");
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


void *send_car_to_enter(void *enter_num)
{
    // get level cast from void
    int num = *(int *)enter_num;
    printf("%d enterance got car", num);
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // mutex lock this thread
    printf("locking lpr");
    pthread_mutex_lock(&entrance->LPR_mutex); // ensure this bahaviour is as expected and doesn't fully freeze
    while(1)
    {
        // get LP from queue

        memcpy(entrance->LPR_reading, dequeue(q), 6);

        // send signal to &entrance->LPR_cond
        pthread_cond_signal(&entrance->LPR_cond);
        printf("Signal sent to entrance LPR");

        // send signal to generator function
        pthread_cond_signal(&car_queue_cond);
        printf("Signal sent to carqueue gen");

        // wait for LPR_cond signal
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);
    }
}

void *generate_car_queue(void* arg)
{
    pthread_mutex_lock(&car_queue_mutex);
    while(1)
    {
        while(q->count < QUEUE_LENGTH)
        {
            // add another car to queue
            static char LPlate[7];
            LPR_generator(LPlate);
            
            //enqueue car
            enqueue(q, LPlate);
        }
        
        pthread_cond_wait(&car_queue_cond, &car_queue_mutex);
        printf("%p", arg); /// Only here cause get error dunno how to not parse an arg
    }
}

// Car queue functions
void initialize(queue *q)
{
    q->count = 0;
    q->front = NULL;
    q->rear = NULL;
}

int isempty(queue *q)
{
    return (q->rear == NULL);
}

void enqueue(queue *q, char LP[7])
{
    if (q->count < QUEUE_LENGTH)
    {
        NP_t *tmp;
        tmp = malloc(sizeof(NP_t));
        memcpy(tmp->number_plate,LP, 6);
        tmp->next = NULL;
        if(!isempty(q))
        {
            q->rear->next = tmp;
            q->rear = tmp;
        }
        else
        {
            q->front = q->rear = tmp;
        }
        q->count++;
    }
    else
    {
        printf("Queue is full.... if this prints it's a bad sign :(( \n");
    }

    printf("%s enqueued", LP);
}

char * dequeue(queue *q)
{
    NP_t *tmp;
    char *number_plate = malloc(7);
    memcpy(number_plate, q->front->number_plate, 6);
    number_plate[6] = 0;
    tmp = q->front;
    q->front = q->front->next;
    q->count--;
    free(tmp);
    return(number_plate);
}

void display(NP_t *head)
{
    if(head == NULL)
    {
        printf("NULL\n");
    }
    else
    {
        printf("%s\n", head -> number_plate);
        display(head->next);
    }
}

/* ----------------------------------------------Boom arm simulation functions----------------------------------------------------*/
void *toggleGate(void* entrance_no_ptr) {
    int entrance_num = *(int *)entrance_no_ptr;
    Enter_t *entrance = &CP.shm_ptr->Enter[entrance_num];
    
    pthread_mutex_lock(&entrance->BOOM_mutex);
    
    while(1)
    {
        // if 'R' then 'O'
        if(entrance->BOOM_status == 'R')
        {
            // timing

            // change
            entrance->BOOM_status = 'O';
            // unlock
            pthread_mutex_unlock(&entrance->BOOM_mutex);

        }
        
        // (else) if 'L' then 'C'
        else 
        {
            // timing

            // change
            entrance->BOOM_status = 'C';
            // unlock
            pthread_mutex_unlock(&entrance->BOOM_mutex);
        }

        // Return signal to 
        pthread_cond_signal(&entrance->info_sign_cond);

        pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex);
    }
    pthread_mutex_unlock(&entrance->BOOM_mutex);
}

void init_gates()
{

    CP_t *carpark = CP.shm_ptr;
    printf("%p\n", carpark);
    for(int i = 0; i < NUM_LEVELS; i++)
    {
        carpark->Enter[i].BOOM_status = 'C';
    }

}


/* ----------------------------------------------Level simulation functions----------------------------------------------------*/
void *navigate_func(void *enter_num)
{
    // getting the level number
    int num_enter = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num_enter];

    pthread_mutex_lock(&entrance->info_sign_mutex);
    Level_t *level;
    while(1)
    {  
        // sending signal to generate a new car
        pthread_cond_signal(&car_queue_cond); 
        // check what to do with car
        if(entrance->info_sign_status != 'X')
        {
            // defining the level we are looking at
            int level_num = ((int) entrance->info_sign_status) - 1;
            level = &CP.shm_ptr->Level[level_num];
            // copy the LPR reading
            memcpy(level->LPR_reading,entrance->LPR_reading, 6);

        }


        pthread_cond_wait(&entrance->info_sign_cond,&entrance->info_sign_mutex);
    }
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