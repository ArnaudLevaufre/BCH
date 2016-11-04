#include "BCH_regs.h"


typedef struct {
    char error;
    unsigned int msg;
} bch_msg;

void BCH_push_msg(unsigned long base, unsigned int msg);
void BCH_pop_msg(unsigned long base, bch_msg* msg);


unsigned int BCH_read_status(unsigned long base);
bool BCH_is_full(unsigned long base);
bool BCH_is_empty(unsigned long base);
bool BCH_is_irq(unsigned long base);

unsigned int BCH_read_ctrl(unsigned long base);
bool BCH_is_irq_enabled(unsigned long base);
bool BCH_is_decoding(unsigned long base);
void BCH_ack_irq(unsigned long base);

void BCH_write_ctrl(unsigned long base, unsigned int data);
void BCH_enable_irq(unsigned long base);
void BCH_disable_irq(unsigned long base);
void BCH_start(unsigned long base);

