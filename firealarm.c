#include "datas.h"

// Function prototypes
int shared_mem_init_open(shm_CP_t *shm, const char *shm_key);
void sort(int16_t *array , int n);
int16_t get_median(int16_t array[] , int n) ;
void init_alarms(void);
int shared_mem_init_open(shm_CP_t *shm, const char *shm_key);
void tempmonitor(int level);

//memory initialisation
int shared_mem_init_open( shm_CP_t *shm, const char *shm_key )
{   
    int memory_opened;
    memory_opened = 0;
    // opening the shared data, otherwise producing an error
    shm->fd = shm_open(shm_key, O_RDWR, 0);
    if (shm->fd  < 0) 
    {
        memory_opened = 1;
    }

    shm->shm_ptr = mmap(0, SHMSZ, PROT_WRITE, MAP_SHARED, shm->fd,0);
    // mapping memory
    if(shm->shm_ptr == MAP_FAILED) 
    {
        memory_opened = 1;
    }

    //memory sucessfully shared if it has been unchanged by above ifs
    return memory_opened;
}

// function to sort the array in ascending order
void sort( int16_t * array , int n )
{ 
    // declare some local variables
    int i;
    int j;
    int16_t temp;

    for(i=0 ; i<n ; i++) {
        for(j=0 ; j < (n-1) ; j++) {
            if(array[j]>array[j+1]) {
                temp = array[j];
                array[j] = array[j+1];
                array[j+1] = temp;
            }
        }
    }
}

// function to calculate the median of the array
int16_t get_median( int16_t array[] , int n ) {
    int16_t median;
    
    if(( n % 2) == 0) {
        //even number of elements in inputted array
        median = (array[(n-1)/2] + array[n/2])/2.0;
    } else {
        //odd number of elements in inputted array
        median = array[n/2];
    }
    return median;
}

void init_alarms( void )
{
    // Activate alarms on all levels
    for (int i = 0; i < NUM_LEVELS; i++) {
        pthread_mutex_lock(&shm.shm_ptr->Level[i].LPR_mutex); //lock level
        shm.shm_ptr->Level[i].fire_alarm = '0'; //set alarm flag
        pthread_cond_broadcast(&shm.shm_ptr->Level[i].LPR_cond); //send condition
        pthread_mutex_unlock(&shm.shm_ptr->Level[i].LPR_mutex); //unlock level
    }
}
//temperature monitoring and evaluating for a specific level
void tempmonitor( int level ) {
    int mediantemp = 0; //Resultant temp from smoothing process
    int hightemps = 0; //Count number of high temps from last 30 readings
    int16_t temp = 0; //temperature taken from sensor
    int16_t buffer[MEDIAN_WINDOW]; //local array to be destructively changed to find median
    int end_index;
    temp = shm.shm_ptr->Level[level].temp_sensor; //take value currently stored in temp

    //shift existing readings across to make space for new reading
    for(int i = MEDIAN_WINDOW; i > 0; i--) {
        tempArray[level][i] = tempArray[level][i-1];      
    }
    //write new temp reading into array
    tempArray[level][0] = temp;

    //copy temps into array to sort and find median temp.
    for (int i = 0; i < MEDIAN_WINDOW; i++) {
        buffer[i] = tempArray[level][i];
    }
    sort(buffer, MEDIAN_WINDOW);
    mediantemp = get_median(buffer,MEDIAN_WINDOW);

    end_index = (int)TEMPCHANGE_WINDOW + (int)MEDIAN_WINDOW -1;
    //shift smoothed temperature readings across to make room for new reading
    for(int i = end_index; i >= MEDIAN_WINDOW; i--) {
        tempArray[level][i] = tempArray[level][i-1];     
    }
    //add new median reading to array
    tempArray[level][MEDIAN_WINDOW] = mediantemp;
    
    //step through temp readings to identify number hot readings
    for (int i = MEDIAN_WINDOW; i < (TEMPCHANGE_WINDOW + MEDIAN_WINDOW); i++) {
        if (tempArray[level][i] >= 58) {
            hightemps++;
        }
    }
    // If 90% of the last 30 temperatures are >= 58 degrees,
    // this is considered a high temperature. Raise the alarm
    if (hightemps >= (TEMPCHANGE_WINDOW * 0.9) && tempArray[level][(TEMPCHANGE_WINDOW + MEDIAN_WINDOW) -1] != 0) {
        alarm_active = 1;
    }

    // If the newest temp is >= 8 degrees higher than the oldest
    // temp (out of the last 30), this is a high rate-of-rise.
    // Additionally, Make sure oldest temperature stored is not 0 to prevent initial readings causing trigger 
    if ( (tempArray[level][MEDIAN_WINDOW] - tempArray[level][(TEMPCHANGE_WINDOW + MEDIAN_WINDOW) -1] >= 8) && (tempArray[level][TEMPCHANGE_WINDOW + (MEDIAN_WINDOW -1)] != 0) ) {
        alarm_active = 1;
    }

}

int main( void ) {
    const char* key;
    key = KEY;
    int shm_opened;
    shm_opened = shared_mem_init_open(&shm, key);

    // Only run program if memory opens successfully
    if(shm_opened == 0)
    {
        init_alarms();

        while(alarm_active == 0) {
            for (int lvl = 0; lvl < NUM_LEVELS; lvl++) {
                tempmonitor(lvl); 
            }
            usleep(2000); //wait 2ms between next reading
        }
        //alarm flag true, raise alarm.
        //fprintf(stderr,"\nALARM TRIGGERED\n")

        // Activate alarms on all levels
        for (int i = 0; i < NUM_LEVELS; i++) {
            pthread_mutex_lock(&shm.shm_ptr->Level[i].LPR_mutex); //lock level
            shm.shm_ptr->Level[i].fire_alarm = '1'; //set alarm flag
            pthread_cond_broadcast(&shm.shm_ptr->Level[i].LPR_cond); //send condition
            pthread_mutex_unlock(&shm.shm_ptr->Level[i].LPR_mutex); //unlock level
        }
        
        // Open up all boom gates
        //open exits
        for (int i = 0; i < NUM_EXITS; i++) {
            char gateState = shm.shm_ptr->Exit[i].BOOM_status;
            pthread_mutex_lock(&shm.shm_ptr->Exit[i].BOOM_mutex); //lock exit
            if (gateState == 'C') { //if gate already open dont need to change.
                shm.shm_ptr->Exit[i].BOOM_status = 'R'; //set gate to raise
                pthread_cond_broadcast(&shm.shm_ptr->Exit[i].BOOM_cond); //send condition
            }
            pthread_mutex_unlock(&shm.shm_ptr->Exit[i].BOOM_mutex); //unlock exit
        }
        //open entrances
        for (int i = 0; i < NUM_ENTERS; i++) {
            char gateState = shm.shm_ptr->Enter[i].BOOM_status;
            pthread_mutex_lock(&shm.shm_ptr->Enter[i].BOOM_mutex); //lock entrance
            if (gateState == 'C') { //if gate already open dont need to change it's state.
                shm.shm_ptr->Enter[i].BOOM_status = 'R'; //otherwise, set gate to raise
                pthread_cond_broadcast(&shm.shm_ptr->Enter[i].BOOM_cond); //send condition
            }
            pthread_mutex_unlock(&shm.shm_ptr->Enter[i].BOOM_mutex); //unlock entrance
        }	

        // Show evacuation message on an endless loop
        for (;;) {
            for (const char *p = EVAC_MESSAGE; *p != '\0'; p++) {
                char letter = (char)p[0];

                //Display Evacuate on Entrace Signs
                for (int i = 0; i < NUM_ENTERS; i++) {
                    pthread_mutex_lock(&shm.shm_ptr->Enter[i].info_sign_mutex); //lock entrance
                    shm.shm_ptr->Enter[i].info_sign_status = letter; //set sign character
                    pthread_cond_broadcast(&shm.shm_ptr->Enter[i].info_sign_cond); //send condition
                    pthread_mutex_unlock(&shm.shm_ptr->Enter[i].info_sign_mutex); //unlock level mutex
                }
                usleep(20000); //sleep for 20ms between letters
            }
        }
    }
    return 0;
}
