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
#include "BCH_regs.h"
#include "system.h"

void BCH_ISR(void*);

typedef struct {
    char error;
    unsigned int msg;
} bch_msg;

void BCH_push_msg(unsigned int msg);
void BCH_pop_msg(bch_msg* msg);


unsigned int BCH_read_status();
bool BCH_is_full();
bool BCH_is_empty();
bool BCH_is_irq();

unsigned int BCH_read_ctrl();
bool BCH_is_irq_enabled();
bool BCH_is_decoding();
void BCH_ack_irq();

void BCH_write_ctrl(unsigned int data);
void BCH_enable_irq();
void BCH_disable_irq();
void BCH_start();

// -----------------------------------------------------------------

void BCH_push_msg(unsigned int msg) {
	IOWR_BCH_DATA(BCH_0_BASE, msg);
}

void BCH_pop_msg(bch_msg* msg){
	volatile unsigned data = IORD_BCH_DATA(BCH_0_BASE);
	msg->error = data >> 24;
	msg->msg = data & 0x8FFFFF;
}


unsigned int BCH_read_status() {
	return IORD_BCH_STATUS(BCH_0_BASE);
}

bool BCH_is_full(){
	return BCH_read_status() & BCH_MASK_STATUS_FULL;
}

bool BCH_is_empty(){
	return BCH_read_status() & BCH_MASK_STATUS_EMPTY;
}

bool BCH_is_irq() {
	return BCH_read_status() & BCH_MASK_STATUS_IRQ;
}

void BCH_ack_irq() {
	BCH_is_irq();
}


unsigned int BCH_read_ctrl(){
	return IORD_BCH_CTRL(BCH_0_BASE);
}
bool BCH_is_irq_enabled(){
	return BCH_read_ctrl() & BCH_MASK_CTRL_IRQ_ENABLED;
}
bool BCH_is_decoding(){
	return BCH_read_ctrl() & BCH_MASK_CTRL_DECODE;
}


void BCH_write_ctrl(unsigned int data){
	IOWR_BCH_CTRL(BCH_0_BASE, data);
}
void BCH_enable_irq(){
	volatile unsigned int current = BCH_read_ctrl();
	BCH_write_ctrl(current | BCH_MASK_CTRL_IRQ_ENABLED);
}
void BCH_disable_irq(){
	volatile unsigned int current = BCH_read_ctrl();
	BCH_write_ctrl(current & ~BCH_MASK_CTRL_IRQ_ENABLED);
}
void BCH_start(){
	volatile unsigned int current = BCH_read_ctrl();
	BCH_write_ctrl(current | BCH_MASK_CTRL_DECODE);
}


int main()
{

  alt_ic_isr_register(BCH_0_IRQ_INTERRUPT_CONTROLLER_ID, BCH_0_IRQ, BCH_ISR, NULL, NULL);
  printf("Hello from Nios II!\n");

  volatile unsigned int status = BCH_read_status();
  printf("Status: 0x%x\n", status);

  BCH_push_msg(0x638E0E56);
  status = BCH_read_status();
  printf("Status: 0x%x\n", status);

  BCH_push_msg(0x638E0E57);
  status = BCH_read_status();
  printf("Status: 0x%x\n", status);

  BCH_enable_irq();
  BCH_start();

  while(1){
  }
  return 0;
}

void BCH_ISR(void* context){
	bch_msg data;
	BCH_pop_msg(&data);
	unsigned int status = BCH_read_status();
	unsigned int ctrl = BCH_read_ctrl();
	printf("Data: 0x%x; Status: 0x%x; Ctrl: 0x%x\n", data.msg, status, ctrl);
	BCH_pop_msg(&data);
	status = BCH_read_status();
	ctrl = BCH_read_ctrl();
	printf("Data: 0x%x; Status: 0x%x; Ctrl: 0x%x\n", data.msg, status, ctrl);
}

