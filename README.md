# stdblocks

Basic blocks for building more powerful IP Cores. Also, used to keep a very good distance from FPGA manufacturer blocks.

## CONTENTS:

* Sync Library: Collection of blocks for transforming asynchronous signals into synchronous signals.
* RAM Library: Ram blocks, targeted to avoid using manufacturer RAM wizards.
* Fifo Library: FIFOS, basic types.
* Scheduler Library: a collection of different control and schedule mechanisms (round robin, queueing...)
* Timer Library: a collection of time base generator: ADPLL, NCO, PWM, Long Counter (for imprecise times up to several seconds) and Precise Long Counter (with +-1 clock cycle precision). 

## Note for Beginners

* Sync, RAM and FIFO libraries are Beginners Friendly. The same cannot be said about other complex libraries. If you find in need of more comments and coding advisoring to understand what is going on, please, ask for it on a ticket.
