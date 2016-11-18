#ifndef __BCH_REGS_H__
#define __BCH_REGS_H__

#include <io.h>

#define BCH_STATUS      0
#define BCH_CTRL        1
#define BCH_DATA        2

#define IORD_BCH_STATUS(base) IORD(base, BCH_STATUS)
#define IOWR_BCH_CTRL(base, data) IOWR(base, BCH_CTRL, data)
#define IORD_BCH_CTRL(base) IORD(base, BCH_CTRL)
#define IORD_BCH_DATA(base) IORD(base, BCH_DATA)
#define IOWR_BCH_DATA(base, data) IOWR(base, BCH_DATA, data)

#define BCH_MASK_STATUS_IRQ 1 << 0
#define BCH_MASK_STATUS_EMPTY 1 << 1
#define BCH_MASK_STATUS_FULL 1 <<2

#define BCH_MASK_CTRL_DECODE 1 << 0
#define BCH_MASK_CTRL_IRQ_ENABLE 1 << 1

#endif /* __BCH_REGS_H__ */
