onerror {quit -code 1}
source "/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Sanity_check_for_system._331bff47b95538ad76ac508cf6f39ad90fe696f2/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
