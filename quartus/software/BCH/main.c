/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "BCHAPI.h"
#include "system.h"
#include "sys/alt_irq.h"


void BCH_ISR(void*);


int main()
{

  alt_ic_isr_register(BCH_0_IRQ_INTERRUPT_CONTROLLER_ID, BCH_0_IRQ, BCH_ISR, NULL, NULL);
  printf("Hello from Nios II!\n");

  volatile unsigned int status = BCH_read_status(BCH_0_BASE);
  printf("Status: 0x%x\n", status);

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

  BCH_enable_irq(BCH_0_BASE);
  BCH_start(BCH_0_BASE);

  while(1){
  }
  return 0;
}

void BCH_ISR(void* context){
	bch_msg data;
	BCH_pop_msg(BCH_0_BASE, &data);
	unsigned int status = BCH_read_status(BCH_0_BASE);
	unsigned int ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
	BCH_pop_msg(BCH_0_BASE, &data);
	status = BCH_read_status(BCH_0_BASE);
	ctrl = BCH_read_ctrl(BCH_0_BASE);
	printf("Error: 0x%X, Data: 0x%X; Status: 0x%X; Ctrl: 0x%X\n", data.error, data.msg, status, ctrl);
}

