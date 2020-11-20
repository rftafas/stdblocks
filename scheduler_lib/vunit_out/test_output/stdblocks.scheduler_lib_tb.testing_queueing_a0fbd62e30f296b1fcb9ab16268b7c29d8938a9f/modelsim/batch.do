onerror {quit -code 1}
source "/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.testing_queueing_a0fbd62e30f296b1fcb9ab16268b7c29d8938a9f/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
