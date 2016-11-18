#include "BCH_regs.h"

#define BCH_MASK_STATUS_IRQ 1 << 0
#define BCH_MASK_STATUS_EMPTY 1 << 1
#define BCH_MASK_STATUS_FULL 1 <<2

#define BCH_MASK_CTRL_DECODE 1 << 0
#define BCH_MASK_CTRL_IRQ_ENABLED 1 << 1


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

