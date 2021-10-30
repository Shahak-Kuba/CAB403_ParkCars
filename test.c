#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

pthread_cond_t cond_1;
pthread_mutex_t mutex_1;
void *func1(void *arg);
void *func2(void *arg);

// compile this with "gcc -o test test.c -lrt -lpthread"

int main()
{
   int num1 = 1;
   int num2 = 2;
   // create thread type variables
   pthread_t thread1, thread2;
   // create threads
   pthread_create(&thread1, NULL, func1, (void *)&num1);
   pthread_create(&thread2, NULL, func2, (void *)&num2);

   // waits for thread to terminate, doesnt happen however the program will exit if u dont wait for this 
   pthread_join(thread2, NULL);

}

// instead of typecast (void *)(*)(void *) you can just make a func like this and just call it
void *func1(void *arg)
{
    // reading the arg into a local int variable
    int num = *(int *)arg;
    // initial lock of mutex
    pthread_mutex_lock(&mutex_1);
    while(1)
    {
        // sleep for pause otherwise too fast
        sleep(1);
        // printing which signal we are at 
        printf("func%d running\n", num);
        sleep(1);
        // sending signal to func2
        printf("sending signal to func2\n");
        pthread_cond_signal(&cond_1);
        sleep(1);
        // waiting for signal to come back
        printf("waiting for func2 to send a signal\n");
        pthread_cond_wait(&cond_1, &mutex_1);

    }
}

// same as func1
void *func2(void *arg)
{
    int num = *(int *)arg;
    pthread_mutex_lock(&mutex_1);
    while(1)
    {
        sleep(1);
        printf("func%d running\n", num);
        sleep(1);
        printf("sending signal to func2\n");
        pthread_cond_signal(&cond_1);
        sleep(1);
        printf("waiting for func1 to send a signal\n");
        pthread_cond_wait(&cond_1, &mutex_1);
    }    
}