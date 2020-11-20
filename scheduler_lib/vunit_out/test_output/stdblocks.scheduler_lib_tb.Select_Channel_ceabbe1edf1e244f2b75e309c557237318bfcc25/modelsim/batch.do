onerror {quit -code 1}
source "/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
