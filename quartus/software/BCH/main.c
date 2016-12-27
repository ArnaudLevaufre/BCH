#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "BCHAPI.h"
#include "system.h"
#include "sys/alt_irq.h"
#include <time.h>



void BCH_ISR(void*);

#define EmptyMask 0x02

int main()
{

  alt_ic_isr_register(BCH_0_IRQ_INTERRUPT_CONTROLLER_ID, BCH_0_IRQ, BCH_ISR, NULL, NULL);
  printf("Hello from Nios II!\n");

  volatile unsigned int status = BCH_read_status(BCH_0_BASE);
  printf("Status: 0x%x\n", status);

  volatile unsigned int ctrl = BCH_read_ctrl(BCH_0_BASE);
  printf("Control: 0x%x\n", ctrl);

  // 0 Error
  BCH_push_msg(BCH_0_BASE, 0x435A0BD5);
  status = BCH_read_status(BCH_0_BASE);
  printf("Status: 0x%x\n", status);

  // 1 Error
  BCH_push_msg(BCH_0_BASE, 0x435A0BD4);
  status = BCH_read_status(BCH_0_BASE);
  printf("Status: 0x%x\n", status);

  // 2 Error
  BCH_push_msg(BCH_0_BASE, 0x435A0AD4);
  status = BCH_read_status(BCH_0_BASE);
  printf("Status: 0x%x\n", status);

  // 3 Error
  BCH_push_msg(BCH_0_BASE, 0x435A1AD4);
  status = BCH_read_status(BCH_0_BASE);
  printf("Status 1: 0x%x\n", status);

  BCH_enable_irq(BCH_0_BASE);

  ctrl = BCH_read_ctrl(BCH_0_BASE);
  printf("Control 1: 0x%x\n", ctrl);

  BCH_start(BCH_0_BASE);

  //status = BCH_read_status(BCH_0_BASE);
  //printf("Status 2: 0x%x\n", status);

  while(!BCH_is_empty(BCH_0_BASE)){
	  printf("waiting for empty BCH \n");
  }
  status = BCH_read_status(BCH_0_BASE);
  printf("Status 3: 0x%x\n", status);
  //usleep(4000000);
  printf("First pass with irqs enabled done!\n");

  // 0 Error
    BCH_push_msg(BCH_0_BASE, 0x435A0BD5);
    status = BCH_read_status(BCH_0_BASE);
    printf("Status: 0x%x\n", status);

    // 1 Error
    BCH_push_msg(BCH_0_BASE, 0x435A0BD4);
    status = BCH_read_status(BCH_0_BASE);
    printf("Status: 0x%x\n", status);

    // 2 Error
    BCH_push_msg(BCH_0_BASE, 0x435A0AD4);
    status = BCH_read_status(BCH_0_BASE);
    printf("Status: 0x%x\n", status);

    // 3 Error
    BCH_push_msg(BCH_0_BASE, 0x435A1AD4);
    status = BCH_read_status(BCH_0_BASE);
    printf("Status: 0x%x\n", status);

    BCH_disable_irq(BCH_0_BASE);

    ctrl = BCH_read_ctrl(BCH_0_BASE);
    printf("Control: 0x%x\n", ctrl);

    BCH_start(BCH_0_BASE);

    while(BCH_is_irq(BCH_0_BASE)){
    }
    printf("Second pass with irqs disabled done! irq_n=0 but no ISR called \n");
    ctrl = BCH_read_ctrl(BCH_0_BASE);
    printf("Control: 0x%x\n", ctrl);
    status = BCH_read_status(BCH_0_BASE);
    printf("Status: 0x%x\n", status);

	bch_msg data;
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error 0: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	
    BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error 1: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	
    BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error 2: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	
    BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error 3: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
    return 0;
}

void BCH_ISR(void* context){
	bch_msg data;
	BCH_pop_msg(BCH_0_BASE, &data);
	unsigned int status = BCH_read_status(BCH_0_BASE);
	unsigned int ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error ISR 0: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error ISR 1: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error ISR 2: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error ISR 3: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	//flush serial for display purposes
    fflush(stdout);

}

