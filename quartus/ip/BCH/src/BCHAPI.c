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

