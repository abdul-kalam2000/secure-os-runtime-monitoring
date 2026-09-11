/*
 * race_condition.c
 * Author: Abdul Kalam Mansoor | EMPL ID: 24712243
 * Secure OS Project - Race Condition Exploit Simulation
 *
 * Two threads concurrently withdraw from a shared account balance
 * with no synchronization (no mutex/lock). This demonstrates how an
 * unprotected critical section can be exploited to cause privilege
 * escalation or an inconsistent system state.
 */

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

int balance = 100;

void *withdraw(void *arg) {
    for (int i = 0; i < 5; i++) {
        if (balance >= 10) {
            int temp = balance;
            usleep(100000);   // simulate a delay between read and write
            balance = temp - 10;
            printf("Withdraw successful. Remaining balance: %d\n", balance);
        } else {
            printf("Insufficient balance.\n");
        }
    }
    return NULL;
}

int main() {
    pthread_t t1, t2;
    pthread_create(&t1, NULL, withdraw, NULL);
    pthread_create(&t2, NULL, withdraw, NULL);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    return 0;
}
