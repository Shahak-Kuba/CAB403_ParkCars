#include "datas.h"

int shm_fd;
shm_CP_t *shm;
int alarm_active = 0;




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

void tempmonitor(int level)
{

	int count, temp, mediantemp, hightemps;

    Level_t *levels = shm->shm_ptr->Level;
    temp = &levels[level].temp_sensor;
    count = tempArrayIndex[level];

    if(count != 5){
        tempArray[level][count] = temp;
        count++;
    }
    else 
    {
        count = 0;
        hightemps = 0;

        sort(tempArray[level], MEDIAN_WINDOW);
        mediantemp = get_median(tempArray[level], MEDIAN_WINDOW);
        
        // Iterate through array (backwards) and push each value along one (dropping the last), 
        // while counting the number of hightemps
        for(int i = TEMPCHANGE_WINDOW + MEDIAN_WINDOW; i > MEDIAN_WINDOW; i--)
        {
            // Temperatures of 58 degrees and higher are a concern
            if(tempArray[level][i] >= 58)
            {
                hightemps++;
            }
        }
        // replace duplicate value (which has already been moved to MEDIAN_WINDOW+1)
        tempArray[level][MEDIAN_WINDOW] = mediantemp;

        // If 90% of the last 30 temperatures are >= 58 degrees,
        // this is considered a high temperature. Raise the alarm
        if (hightemps >= TEMPCHANGE_WINDOW * 0.9)
        {
            alarm_active = 1;
        }
        // If the newest temp is >= 8 degrees higher than the oldest
        // temp (out of the last 30), this is a high rate-of-rise.
        // Raise the alarm
        if (tempArray[level][MEDIAN_WINDOW] - tempArray[level][TEMPCHANGE_WINDOW] >= 8)
        {
            alarm_active = 1;
        }        

    }
    usleep(2000);	
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
	shm_fd = shm_open("PARKING", O_RDWR, 0);
	shm = (volatile void *) mmap(0, 2920, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);

    while(alarm_active == 0)
    {
        for (int lvl = 0; lvl <= LEVELS; lvl++) 
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
			for (int i = 0; i < ENTRANCES; i++) {
				int addr = 288 * i + 192;
				volatile struct parkingsign *sign = shm + addr;
				pthread_mutex_lock(&sign->m);
				sign->display = *p;
				pthread_cond_broadcast(&sign->c);
				pthread_mutex_unlock(&sign->m);
			}
			usleep(20000);
		}
	}

    return EXIT_SUCCESS;
}
