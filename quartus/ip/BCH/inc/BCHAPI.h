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

