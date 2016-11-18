#include "BCHAPI.h"


void BCH_push_msg(unsigned long base, unsigned int msg) {
	IOWR_BCH_DATA(base, msg);
}

void BCH_pop_msg(unsigned long base, bch_msg* msg){
	volatile unsigned data = IORD_BCH_DATA(base);
	msg->error = data >> 24;
	msg->msg = data & 0xFFFFFF;
}


unsigned int BCH_read_status(unsigned long base) {
	return IORD_BCH_STATUS(base);
}

bool BCH_is_full(unsigned long base){
	return BCH_read_status(base) & BCH_MASK_STATUS_FULL;
}

bool BCH_is_empty(unsigned long base){
	return BCH_read_status(base) & BCH_MASK_STATUS_EMPTY;
}

bool BCH_is_irq(unsigned long base) {
	return BCH_read_status(base) & BCH_MASK_STATUS_IRQ;
}

void BCH_ack_irq(unsigned long base) {
	BCH_is_irq(base);
}


unsigned int BCH_read_ctrl(unsigned long base){
	return IORD_BCH_CTRL(base);
}
bool BCH_is_irq_enabled(unsigned long base){
	return BCH_read_ctrl(base) & BCH_MASK_CTRL_IRQ_ENABLED;
}
bool BCH_is_decoding(unsigned long base){
	return BCH_read_ctrl(base) & BCH_MASK_CTRL_DECODE;
}


void BCH_write_ctrl(unsigned long base, unsigned int data){
	IOWR_BCH_CTRL(base, data);
}
void BCH_enable_irq(unsigned long base){
	volatile unsigned int current = BCH_read_ctrl(base);
	BCH_write_ctrl(base, current | BCH_MASK_CTRL_IRQ_ENABLED);
}
void BCH_disable_irq(unsigned long base){
	volatile unsigned int current = BCH_read_ctrl(base);
	BCH_write_ctrl(base, current & ~BCH_MASK_CTRL_IRQ_ENABLED);
}
void BCH_start(unsigned long base){
	volatile unsigned int current = BCH_read_ctrl(base);
	BCH_write_ctrl(base, current | BCH_MASK_CTRL_DECODE);
}

