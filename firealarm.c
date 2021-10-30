#include "datas.h"

int shm_fd;
shm_CP_t shm;
int alarm_active = 0;
int shared_mem_init_open(shm_CP_t *shm, const char *shm_key);

#define LEVELS 5
#define ENTRANCES 5
#define EXITS 5

#define MEDIAN_WINDOW 5
#define TEMPCHANGE_WINDOW 30

int16_t tempArray [LEVELS][TEMPCHANGE_WINDOW + MEDIAN_WINDOW]; // assume that 0 values are init
int tempArrayIndex[LEVELS];

typedef struct {
	pthread_mutex_t m;
	pthread_cond_t c;
	char s;
} boomgate;

struct parkingsign {
	pthread_mutex_t m;
	pthread_cond_t c;
	char display;
};


int compare(const void *first, const void *second)
{
	return *((const int *)first) - *((const int *)second);
}


// function to sort the array in ascending order
int16_t * sort(int16_t *array , int n)
{ 
    // declare some local variables
    int i=0 , j=0 , temp=0;

    for(i=0 ; i<n ; i++)
    {
        for(j=0 ; j<n-1 ; j++)
        {
            if(array[j]>array[j+1])
            {
                temp        = array[j];
                array[j]    = array[j+1];
                array[j+1]  = temp;
            }
        }
    }
    return array;
}

// function to calculate the median of the array
int16_t get_median(int16_t array[] , int n)
{
    int16_t median=0;
    
    // if number of elements are even
    if(n%2 == 0)
        median = (array[(n-1)/2] + array[n/2])/2.0;
    // if number of elements are odd
    else
        median = array[n/2];
    
    return median;
}

void tempmonitor(int level) {
    int mediantemp = 0; //Resultant temp from smoothing process
    int hightemps = 0; //Count number of high temps from last 30 readings
    int16_t temp = 0;
    int16_t buffer[MEDIAN_WINDOW];
    
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

    //shift smoothed temperature readings across to make room for new reading
    for(int i = TEMPCHANGE_WINDOW + MEDIAN_WINDOW-1; i >= MEDIAN_WINDOW; i--) {
        tempArray[level][i] = tempArray[level][i-1];     
    }
    //add new median reading to array
    tempArray[level][MEDIAN_WINDOW] = mediantemp;
    
    //step through temp readings to identify number hot readings
    for (int i = MEDIAN_WINDOW; i < TEMPCHANGE_WINDOW+MEDIAN_WINDOW; i++) {
        if (tempArray[level][i] >= 58) {
            hightemps++;
        }
    }
    // If 90% of the last 30 temperatures are >= 58 degrees,
    // this is considered a high temperature. Raise the alarm
    //printf("High Temp: %d\n", hightemps);
    if (hightemps >= TEMPCHANGE_WINDOW * 0.9) {
        alarm_active = 1;
    }

    // If the newest temp is >= 8 degrees higher than the oldest
    // temp (out of the last 30), this is a high rate-of-rise.
    // Additionally, Make sure oldest temperature stored is not 0 to prevent initial readings causing trigger 
    if (tempArray[level][MEDIAN_WINDOW] - tempArray[level][TEMPCHANGE_WINDOW+MEDIAN_WINDOW-1] >= 8 && tempArray[level][TEMPCHANGE_WINDOW+MEDIAN_WINDOW-1] != 0) {
        alarm_active = 1;
    }
    
    //sleep
    usleep(2000);
}

/* Dummy Function For Spitting Out Temperatures To Console....
void dumpTempMemory() {
    //testing printout
    printf("Temp Memory Block:\n");
    for (int x = 0; x < LEVELS; x++) {
        for (int y = 0; y < TEMPCHANGE_WINDOW + MEDIAN_WINDOW; y++) {
            printf("%d ", tempArray[x][y]);
            if (y == 4) {
                printf(" | ");
            }
        }
        printf("\n");
    }
    printf("\n");
}
*/

int shared_mem_init_open(shm_CP_t* shm, const char *shm_key)
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
    printf("shared memory opened!\n");
    return(EXIT_SUCCESS);
}

void *openboomgate(boomgate *bg)
{
	pthread_mutex_lock(&bg->m);
	for (;;) {
		if (bg->s == 'C') {
			bg->s = 'R';
			pthread_cond_broadcast(&bg->c);
		}
		if (bg->s == 'O') {
		}
		pthread_cond_wait(&bg->c, &bg->m);
	}
	pthread_mutex_unlock(&bg->m);
	
}

int main(void)
{
    const char* key;
    key = KEY;
    shared_mem_init_open(&shm, key);

    while(alarm_active == 0)
    {
        for (int lvl = 0; lvl < LEVELS; lvl++) 
        {
            tempmonitor(lvl); 
        }
        usleep(1000);
    }
	
	
	fprintf(stderr, "*** ALARM ACTIVE ***\n");
	
	// Handle the alarm system and open boom gates
	// Activate alarms on all levels

	
	// Open up all boom gates
	
	
	// Show evacuation message on an endless loop
	for (;;) {
        
		char *evacmessage = "EVACUATE ";
		for (char *p = evacmessage; *p != '\0'; p++) {
            char letter = (char)p[0];
            //printf("%c\n",letter);
            for (int i = 0; i < ENTRANCES; i++) {
                shm.shm_ptr->Enter[i].info_sign_status = letter;
            }
			//for (int i = 0; i < ENTRANCES; i++) {
			//	int addr = 288 * i + 192;
			//	volatile struct parkingsign *sign = &shm + addr;
			//	pthread_mutex_lock(&sign->m);
			//	sign->display = *p;
			//	pthread_cond_broadcast(&sign->c);
			//	pthread_mutex_unlock(&sign->m);
			//}
			usleep(20000);
		}
        
	}

    return EXIT_SUCCESS;
}
