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

void Assignment_Sleep(int time_in_milli_sec);

// simulation variable
int car_list_chance = 100;

// shared mem variables
shm_CP_t CP;
pthread_mutex_t rand_mutex; // mutex for random LPR generation

// predefining shared memory functions
int shared_mem_init(shm_CP_t* shm, char* shm_key);
void clear_memory( shm_CP_t* shm ); 

/* car simulation functions */
void LPR_generator(); // function that will generate random LPR
void *generate_car_queue(void *arg); // function that will fill a linked list of cars waiting for a
void *send_car_to_enter(void *enter_num); // sends a car from que to entrance (5 threads)

void *level_navigation(void *arg);

// queue thread
queue *q;
pthread_mutex_t car_queue_mutex;
pthread_cond_t car_queue_cond;

// send car threads
pthread_t send_car_thread;
pthread_mutex_t send_car_from_queue_mutex;
pthread_cond_t send_car_from_queue_cond;

// car queue functions
void initialize(queue *q);
int isempty(queue *q);
void enqueue(queue *q, char LP[7]);
// dequeue car function and pthreads
pthread_mutex_t car_dequeue_mutex;
pthread_cond_t car_dequeue_cond;
bool dequeue(queue *q, char LP[7]);
// display queue function
void display(NP_t *head);

// car generation variable
int linecount = 0;

/* boom arm simulation functions */
void *toggleGate(void *enter_num);
void init_gates();

/* fire sensor simulation functions */
pthread_t temperature_thread;
int fireState = 0; //0 normal operation, 1 for creep & 2 for spike
int16_t BaseTemp;
void generateTemperature();
void fire_alarms_active();

/* input thread */
pthread_t input_thread;
void get_input();

pthread_t create_car_thread;
pthread_t gate_thread;
pthread_t level_nav_thread;
pthread_t create_car_thread;

int main()
{
    pthread_mutex_init(&rand_mutex, NULL);
    printf("Enter F to trigger Creeping Fire Alarm Event\n");
    printf("Enter G to trigger Spike Fire Alarm Event\n");
    // initialising shared memory
    shared_mem_init(&CP, KEY);

    // initializing boom gate status to closed for each level 
    init_gates();
    
    // initialize queue
    q = (queue *) malloc(sizeof(queue));
    initialize(q);
    display(q->front);

    // generating car queue thread
    pthread_create(&create_car_thread, NULL, generate_car_queue, (void*)q);
    Assignment_Sleep(100); // sleep to make sure cars are initially generated

    int num = 0; // doing for 1 entrance/level/exit, will replace with a for loop
    pthread_create(&send_car_thread, NULL, send_car_to_enter, (void *)&num);
    
    pthread_create(&gate_thread, NULL, toggleGate, (void *)&num);

    pthread_create(&level_nav_thread, NULL, level_navigation, (void *)&num);

    pthread_create(&input_thread, NULL, (void *)get_input, NULL);

    pthread_join(create_car_thread, NULL);
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

    // initialising every mutex and cond variables
    pthread_mutexattr_t attr_mutex;
    pthread_mutexattr_init(&attr_mutex);
    pthread_mutexattr_setpshared(&attr_mutex, PTHREAD_PROCESS_SHARED);

    pthread_condattr_t attr_cond;
    pthread_condattr_init(&attr_cond);
    pthread_condattr_setpshared(&attr_cond, PTHREAD_PROCESS_SHARED);

    // Entrances
    for(int i = 0; i < NUM_ENTERS; i++)
    {
        Enter_t *entrance = &CP.shm_ptr->Enter[i];
        // conditional variables
        pthread_cond_init(&entrance->BOOM_cond, &attr_cond);
        pthread_cond_init(&entrance->LPR_cond, &attr_cond);
        pthread_cond_init(&entrance->info_sign_cond, &attr_cond);

        // mutex's
        pthread_mutex_init(&entrance->BOOM_mutex, &attr_mutex);
        pthread_mutex_init(&entrance->LPR_mutex, &attr_mutex);
        pthread_mutex_init(&entrance->info_sign_mutex, &attr_mutex);
    }

    // Levels
    for(int i = 0; i < NUM_ENTERS; i++)
    {
        Level_t *level = &CP.shm_ptr->Level[i];
        // conditional variables
        pthread_cond_init(&level->LPR_cond, &attr_cond);
        // mutex's
        pthread_mutex_init(&level->LPR_mutex, &attr_mutex);
    }

    // Exits
    for(int i = 0; i < NUM_ENTERS; i++)
    {
        Exit_t *exit = &CP.shm_ptr->Exit[i];
        // conditional variables
        pthread_cond_init(&exit->LPR_cond, &attr_cond);
        pthread_cond_init(&exit->BOOM_cond, &attr_cond);


        // mutex's
        pthread_mutex_init(&exit->BOOM_mutex, &attr_mutex);
        pthread_mutex_init(&exit->LPR_mutex, &attr_mutex);
    }

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

void Assignment_Sleep(int time_in_milli_sec)
{
    int time = time_in_milli_sec * 1000;
    printf("waiting %d ms\n", time_in_milli_sec);
    usleep(time);
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
        memcpy(tmp->number_plate,LP, 7);
        tmp->next = NULL;
        if(!isempty(q))
        {
            //printf("que is not empty\n");
            q->rear->next = tmp;
            q->rear = tmp;
        }
        else
        {
            //printf("queue is empty\n");
            q->front = q->rear = tmp;
        }
        q->count++;
    }
    else
    {
        printf("Queue is full.... if this prints it's a bad sign :(( \n");
    }

    //printf("%s\n", LP);
}

bool dequeue(queue *q, char LP[7])
{
    if(q->front == NULL)
    {
        return false;
    }
    NP_t *tmp;
    //char *number_plate = (char *) malloc(7);
    memcpy(LP, q->front->number_plate, 7);
    tmp = q->front;
    q->front = q->front->next;
    q->count--;
    free(tmp);
    return true;
}

void display(NP_t *head)
{
    if(head == NULL)
    {
        printf("NULL\n");
    }
    else
    {
        printf("%s -> ", head -> number_plate);
        display(head->next);
    }
}

/*-----------------------------------CAR GENERATION AND SEND TO GATE ----------------------------------------*/

void LPR_generator(char LPR[LPRSZ+1]) 
{
    pthread_mutex_lock(&rand_mutex);
    if (rand() % 100 <= car_list_chance) {
        
        //Use car from plates.txt
        //Measure Number of plates in file.
        FILE* file_ptr = fopen(LPFILE,"r");
        fseek(file_ptr,0,SEEK_END);
        // getting size of file in lines
        int file_plate_count = ftell(file_ptr) / (LPRSZ + 1); //assumes all plates are 6 chars long
        //Take Random Plate from file
        fseek(file_ptr,linecount*(LPRSZ+1),SEEK_SET);
        fgets(LPR,LPRSZ+1,file_ptr);
        fclose(file_ptr);
        linecount++;

            if(linecount == file_plate_count)
            {
                linecount = 0;
            }
        
        } else {
        //Generate random car plate
        for(int i = 0; i < LPRSZ; i++) {
            if(i < 3) { // first 3 are numbers
                LPR[i] = '0' + (random() % 10);
            } else { // last 3 are letters
                LPR[i] = 'A' + random() % 26;
            }
        }
    }    
    LPR[6] = 0;
    pthread_mutex_unlock(&rand_mutex);
}

void *generate_car_queue(void* arg)
{
    queue *q = (queue *) arg;
    pthread_mutex_lock(&car_queue_mutex);
    while(1)
    {
        fire_alarms_active(); // check that no firealarms are active before generating car
        int random_time = (int) floor(rand()%100);
        Assignment_Sleep(random_time);
        while(q->count < QUEUE_LENGTH)
        {
            // add another car to queue
            char LPlate[7];
            LPR_generator(LPlate);
            
            //enqueue car
            enqueue(q, LPlate);
        }
        display(q->front);
        pthread_cond_wait(&car_queue_cond, &car_queue_mutex);
        //printf("%p", arg); /// Only here cause get error dunno how to not parse an arg
    }
}

void *send_car_to_enter(void *enter_num)
{
    // get level cast from void
    int num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // mutex lock this thread
    pthread_mutex_lock(&entrance->LPR_mutex); // ensure this bahaviour is as expected and doesn't fully freeze
    char LPR[7];
    while(1)
    {
        fire_alarms_active(); // check no fire alarms are active before 
        // check if the entrance is empty
        if(entrance->LPR_reading[0] == 0)
        {
            // lock the queue so no other entrances can dequeue a car
            pthread_mutex_lock(&car_dequeue_mutex);
            // check if we can dequeue a car
            if(dequeue(q, LPR))
            {
                //copy LPR
                memcpy(entrance->LPR_reading, LPR, 6);
                printf("%d enterance got the car %s\n", num+1, LPR);

                // send signal to &entrance->LPR_cond saying recieved a car
                pthread_cond_signal(&entrance->LPR_cond);
                printf("Signal sent to entrance LPR\n");

                // send signal to generator function make a new car
                pthread_cond_signal(&car_queue_cond);
                printf("Signal sent to carqueue gen\n");
            }
            // lock the queue so other entrances can dequeue a car
            pthread_mutex_unlock(&car_dequeue_mutex);
        }

        display(q->front);
        // waiting for car to leave the entrance
        printf("waiting for entrance to be empty\n");
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);
    }
}

/*-----------------------------------------BOOM GATE FUNCTIONS------------------------------------------------*/
void init_gates()
{

    CP_t *carpark = CP.shm_ptr;
    printf("%p\n", carpark);
    for(int i = 0; i < NUM_LEVELS; i++)
    {
        carpark->Enter[i].info_sign_status = 'X';
        carpark->Enter[i].BOOM_status = 'C';
    }

}

void *toggleGate(void* enter_num) 
{
    // getting entrance number
    int entrance_num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[entrance_num];

    // initial lock of boom gate mutex
    pthread_mutex_lock(&entrance->BOOM_mutex);
    
    // infinit loop
    while(1)
    {
        Assignment_Sleep(10); // 10ms wait as per requirement
        // if 'R' then 'O'
        if(entrance->BOOM_status == 'R')
        {
            // change
            entrance->BOOM_status = 'O';
            printf("Boom status is set to %c\n",entrance->BOOM_status);

        }
        // (else) if 'L' then 'C'
        else if(entrance->BOOM_status == 'L')
        {
            // change
            entrance->BOOM_status = 'C';
            printf("Boom status is set to %c\n",entrance->BOOM_status);
        }

        pthread_mutex_unlock(&entrance->BOOM_mutex);
        // return a signal saying boom gate status has changed
        pthread_cond_signal(&entrance->BOOM_cond);
        
        pthread_mutex_lock(&entrance->BOOM_mutex);
        printf("BOOM mutex unlocked and waiting for signal\n");
        pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex);
    }

}

/*-----------------------------------------Level navigation FUNCTIONS------------------------------------------------*/

void *level_navigation(void *enter_num)
{
    // get enterance number cast from void
    int num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // predeclare level variable
    Level_t *level;
    int level_num;
    pthread_mutex_lock(&entrance->info_sign_mutex);
    while(1)
    {
        // check if firealarms are active before doing anything
        fire_alarms_active(); 

        // check if the car is allowed in
        printf("checking sign status\n");
        if(entrance->info_sign_status != 'X')
        {
            Assignment_Sleep(10);
            // getting the level number
            level_num = (int) entrance->info_sign_status - '1';
            // getting the level struct
            level = &CP.shm_ptr->Level[level_num];
            // copying LPR to level data
            pthread_mutex_lock(&level->LPR_mutex);
            memcpy(level->LPR_reading, entrance->LPR_reading, 6);
            pthread_mutex_unlock(&level->LPR_mutex);
            printf("Level %d recieved LPR: %s\n", level_num, level->LPR_reading);

        }
        // removing the car from entrace
        entrance->LPR_reading[0] = 0;
        pthread_mutex_unlock(&entrance->info_sign_mutex);
        pthread_cond_signal(&entrance->info_sign_cond);
        pthread_mutex_lock(&entrance->info_sign_mutex);
        pthread_cond_wait(&entrance->info_sign_cond, &entrance->info_sign_mutex);
    }


}
/*------------------------------------------FIRE ALARM----------------------------------------*/

void generateTemperature() {
    while(1)
    {
        for (int i = 0; i < NUM_LEVELS; i++) {
            pthread_mutex_lock(&rand_mutex);
            int16_t tempNoise = ((rand()%2)*2)-1; //sets tempNoise to be -1 or +1;
            int16_t randScalar = rand()%4;
            pthread_mutex_unlock(&rand_mutex);
            
            // getting the given level
            Level_t *level = &CP.shm_ptr->Level[i];
            
            switch(fireState) {
            case 1: //Creep Event (Rising Average)
                BaseTemp++;
                level->temp_sensor = BaseTemp + tempNoise;
                break;

            case 2: //Spike Event (Jump to temps > 58)
                level->temp_sensor = 60;
                break;

            default: //Normal Operation
                BaseTemp = 30;
                level->temp_sensor = BaseTemp + (tempNoise*randScalar); // -3 - +3 higher or lower than base temp
                break;
            }
        }
    }
}


// Used to block a thread from doing more if there's a fire detected
void fire_alarms_active()
{
    
    for(int i = 0; i < NUM_LEVELS; i++)
    {
        if(CP.shm_ptr->Level[i].fire_alarm == '1')
        {
            printf("Firealarm triggered, blocking program\n");
            for(;;)
            {
                
            }
        }
    }

}

/*------------------------------------------USER INPUT-----------------------------------------*/

void get_input()
{
    printf("Input function thread started\n");
    //main loop
    for (;;) {
        
        int charinput = 0;
        charinput = fgetc(stdin);
        if (charinput == 'f') {
            printf("\nIncreasing Temperature Over Time\n\n");
            fireState = 1;
        } else if (charinput == 'g') {
            printf("\nIncreasing Temperature Instantly\n\n");
            fireState = 2;
        }
        else if(charinput == 'c')
        {
            pthread_cancel(send_car_thread);
            pthread_cancel(create_car_thread);
            pthread_cancel(level_nav_thread);
            pthread_cancel(input_thread);
            pthread_cancel(gate_thread);
            clear_memory(&CP);
        }
    }
}