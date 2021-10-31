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

int car_list_chance = 100;

shm_CP_t CP;
pthread_mutex_t rand_mutex; // mutex for random LPR generation

// predefining shared memory functions
int shared_mem_init(shm_CP_t* shm, char* shm_key);
void clear_memory( shm_CP_t* shm ); 

void Assignment_Sleep(int time_in_milli_sec);

// simulation functions

/* car simulation functions */
void car_sim(shm_CP_t* shm); // car simulation
void LPR_generator(); // function that will generate random LPR
void *navigate_func(void *enter_num); // direct a car and remembe the level it goes to (5 threads)
void *send_car_to_enter(void *enter_num); // sends a car from que to entrance (5 threads)
void *generate_car_queue(void *arg); // function that will fill a linked list of cars waiting for a 
void *level_navigation(void *arg);

// queue thread
queue *q;
pthread_t car_queue_thread;
pthread_mutex_t car_queue_mutex;
pthread_cond_t car_queue_cond;

// send car threads
pthread_t send_car_thread;

// car queue functions
void initialize(queue *q);
int isempty(queue *q);
void enqueue(queue *q, char LP[7]);
char* dequeue(queue *q);
void display(NP_t *head);

// car generation function
int linecount = 0;


/* boom arm simulation functions */
void *toggleGate(void *arg);
void init_gates();

/* fire sensor simulation functions */
int fireState = 0; //0 normal operation, 1 for creep & 2 for spike
int16_t BaseTemp;
void generateTemperature();

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

    /*********************** INIT THREADS ***********************/
    int num = 0;
    pthread_create(&car_queue_thread, NULL, generate_car_queue, (void*)q);
    Assignment_Sleep(10);
    printf("final queue:\n");
    display(q->front);
    pthread_create(&send_car_thread, NULL, send_car_to_enter, (void *)&num);
    pthread_t gate_thread;
    pthread_create(&gate_thread, NULL, toggleGate, (void *)&num);

    //pthread_t level_nav_thread;
    //pthread_create(&level_nav_thread, NULL, level_navigation, (void *)&num);

    pthread_join(send_car_thread, 0);   
    

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

void LPR_generator(char LPR[LPRSZ+1]) {
    pthread_mutex_lock(&rand_mutex);
    if (rand() % 100 <= car_list_chance) {
        
        //Use car from plates.txt
        //Measure Number of plates in file.
        FILE* file_ptr = fopen("plates.txt","r");
        fseek(file_ptr,0,SEEK_END);
        // getting size of file in lines
        int file_plate_count = ftell(file_ptr) / (LPRSZ + 1); //assumes all plates are 6 chars long
        //Take Random Plate from file
        fseek(file_ptr,(rand() % file_plate_count)*(LPRSZ+1),SEEK_SET);
        fgets(LPR,LPRSZ+1,file_ptr);
        fclose(file_ptr);

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

void *send_car_to_enter(void *enter_num)
{
    // get level cast from void
    int num = *(int *)enter_num;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // mutex lock this thread
    printf("locking lpr\n");
    pthread_mutex_lock(&entrance->LPR_mutex); // ensure this bahaviour is as expected and doesn't fully freeze
    while(1)
    {
        // get LP from queue
        char *LPR = dequeue(q);
        //printf("%s\n", LPR);
        memcpy(entrance->LPR_reading, LPR, 6);
        printf("%d enterance got the car %s\n", num+1, LPR);

        // send signal to &entrance->LPR_cond
        pthread_cond_signal(&entrance->LPR_cond);
        printf("Signal sent to entrance LPR\n");

        // send signal to generator function
        pthread_cond_signal(&car_queue_cond);
        printf("Signal sent to carqueue gen\n");

        // wait for LPR_cond signal
        pthread_cond_wait(&entrance->LPR_cond, &entrance->LPR_mutex);
    }
}

void *generate_car_queue(void* arg)
{
    queue *q = (queue *) arg;
    pthread_mutex_lock(&car_queue_mutex);
    while(1)
    {
        while(q->count < QUEUE_LENGTH)
        {
            // add another car to queue
            char LPlate[7];
            LPR_generator(LPlate);
            
            //enqueue car
            enqueue(q, LPlate);
        }
        
        pthread_cond_wait(&car_queue_cond, &car_queue_mutex);
        //printf("%p", arg); /// Only here cause get error dunno how to not parse an arg
    }
}

void *level_navigation(void *arg)
{
    // get enterance number cast from void
    int num = *(int *)arg;
    Enter_t *entrance = &CP.shm_ptr->Enter[num];

    // mutex lock this thread
    pthread_mutex_lock(&entrance->info_sign_mutex); // ensure this bahaviour is as expected and doesn't fully freeze
    while(1)
    {
        // if a car is going in
        if(entrance->info_sign_status != 'X')
        {
            int level_num = entrance->info_sign_status - '0';
            printf("level number is %d\n",level_num);
            //Level_t *level = &CP.shm_ptr->Level[level_num];
        }

        // remove car from entrance
        pthread_mutex_lock(&entrance->LPR_mutex);
        entrance->LPR_reading[0] = 0;
        pthread_mutex_unlock(&entrance->LPR_mutex);

        // return a signal back to the 
        pthread_cond_wait(&entrance->info_sign_cond, &entrance->info_sign_mutex);
        printf("doing something in the info sign\n");
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

char * dequeue(queue *q)
{
    NP_t *tmp;
    char *number_plate = (char *) malloc(7);
    memcpy(number_plate, q->front->number_plate, 7);
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
        printf("%s -> ", head -> number_plate);
        display(head->next);
    }
}

/* ----------------------------------------------Boom arm simulation functions----------------------------------------------------*/
void *toggleGate(void* entrance_no_ptr) {

    int entrance_num = *(int *)entrance_no_ptr;
    Enter_t *entrance = &CP.shm_ptr->Enter[entrance_num];

    pthread_mutex_lock(&entrance->BOOM_mutex);
    printf("BOOM mutex locked\n"); 
    while(1)
    {
         
        Assignment_Sleep(10);
        // if 'R' then 'O'
        if(entrance->BOOM_status == 'R')
        {
            // change
            printf("gate opened.\n");
            pthread_mutex_lock(&entrance->BOOM_mutex);
            printf("BOOM locked\n");
            entrance->BOOM_status = 'O';

        }
        // (else) if 'L' then 'C'
        else if(entrance->BOOM_status == 'L')
        {
            // change
            printf("gate closed.\n");
            pthread_mutex_lock(&entrance->BOOM_mutex);
            printf("BOOM locked\n");
            entrance->BOOM_status = 'C';
        }

        pthread_mutex_unlock(&entrance->BOOM_mutex);
        printf("BOOM unlocked\n");


        // other signal
        //pthread_cond_signal(&entrance->info_sign_cond);

        printf("sending signal with boom gate %c\n", entrance->BOOM_status);
        pthread_cond_signal(&entrance->BOOM_cond);  
        printf("signal sent\n");

        // waiting for next boom signal to be sent
        pthread_mutex_lock(&entrance->BOOM_mutex); // locking so we can unlock with wait
        printf("BOOM mutex unlocked and waiting for signal\n");
        pthread_cond_wait(&entrance->BOOM_cond, &entrance->BOOM_mutex);
        printf("recieved signal\n");
    }
    pthread_mutex_unlock(&entrance->BOOM_mutex);
}

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

/* ----------------------------------------------Fire sensor functions----------------------------------------------------*/
/*
void generateTemperature() {
    for (int i = 0; i < NUM_LEVELS; i++) {
        pthread_mutex_lock(&rand_mutex);
        int16_t tempNoise = ((rand()%2)*2)-1; //sets tempNoise to be -1 or +1;
        int16_t randScalar = rand()%4;
        pthread_mutex_unlock(&rand_mutex);

        switch(fireState) {
        case 1: //Creep Event (Rising Average)
            BaseTemp++;
            CP.shm_ptr->Level[i].temp_sensor = BaseTemp + tempNoise;
            break;

        case 2: //Spike Event (Jump to temps > 58)
            CP.shm_ptr->Level[i].temp_sensor = 60;
            break;

        default: //Normal Operation
            BaseTemp = 30;
            CP.shm_ptr->Level[i].temp_sensor = BaseTemp + (tempNoise*randScalar); // -3 - +3 higher or lower than base temp
            break;
        }
    }
}*/