
proc vunit_help {} {
    puts {List of VUnit commands:}
    puts {vunit_help}
    puts {  - Prints this help}
    puts {vunit_load [vsim_extra_args]}
    puts {  - Load design with correct generics for the test}
    puts {  - Optional first argument are passed as extra flags to vsim}
    puts {vunit_user_init}
    puts {  - Re-runs the user defined init file}
    puts {vunit_run}
    puts {  - Run test, must do vunit_load first}
    puts {vunit_compile}
    puts {  - Recompiles the source files}
    puts {vunit_restart}
    puts {  - Recompiles the source files}
    puts {  - and re-runs the simulation if the compile was successful}
}

proc vunit_run {} {
    if {[catch {_vunit_run} failed_or_err]} {
        echo $failed_or_err
        return true;
    }

    if {![is_test_suite_done]} {
        echo
        echo "Test Run Failed!"
        echo
        _vunit_run_failure;
        return true;
    }

    return false;
}

proc _vunit_source_init_files_after_load {} {
    return 0
}
proc _vunit_source_init_files_before_run {} {
    return 0
}

proc vunit_load {{vsim_extra_args ""}} {
    set vsim_failed [catch {
        eval vsim ${vsim_extra_args} {-modelsimini /home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/modelsim/modelsim.ini -wlf {/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/modelsim/vsim.wlf} -quiet -t ps -onfinish stop  -g/scheduler_lib_tb/runner_cfg={"active python runner : true,enabled_test_cases : Select Channel,output path : /home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/,tb path : /home/rftafas/Projects/stdblocks/scheduler_lib/,use_color : true"} stdblocks.scheduler_lib_tb(simulation)   -L vunit_lib -L expert -L stdblocks}
    }]

    if {${vsim_failed}} {
       echo Command 'vsim ${vsim_extra_args} -modelsimini /home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/modelsim/modelsim.ini -wlf {/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/modelsim/vsim.wlf} -quiet -t ps -onfinish stop  -g/scheduler_lib_tb/runner_cfg={"active python runner : true,enabled_test_cases : Select Channel,output path : /home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/,tb path : /home/rftafas/Projects/stdblocks/scheduler_lib/,use_color : true"} stdblocks.scheduler_lib_tb(simulation)   -L vunit_lib -L expert -L stdblocks' failed
       echo Bad flag from vsim_extra_args?
       return true
    }

    if {[_vunit_source_init_files_after_load]} {
        return true
    }

    global BreakOnAssertion
    set BreakOnAssertion 2

    global NumericStdNoWarnings
    set NumericStdNoWarnings 0

    global StdArithNoWarnings
    set StdArithNoWarnings 0

    
    return false
}

proc is_test_suite_done {} {
    set fd [open "/home/rftafas/Projects/stdblocks/scheduler_lib/vunit_out/test_output/stdblocks.scheduler_lib_tb.Select_Channel_ceabbe1edf1e244f2b75e309c557237318bfcc25/vunit_results" "r"]
    set contents [read $fd]
    close $fd
    set lines [split $contents "
"]
    foreach line $lines {
        if {$line=="test_suite_done"} {
           return true;
        }
    }

    return false;
}


proc _vunit_run_failure {} {
    catch {
        # tb command can fail when error comes from pli
        echo "Stack trace result from 'tb' command"
        echo [tb]
        echo
        echo "Surrounding code from 'see' command"
        echo [see]
    }
}

proc _vunit_run {} {
    if {[_vunit_source_init_files_before_run]} {
        return true
    }

    proc on_break {} {
        resume
    }
    onbreak {on_break}

    run -all
}

proc _vunit_sim_restart {} {
    restart -f
}

proc vunit_compile {} {
    set cmd_show {/opt/quicklogic/conda/bin/python3 -u scheduller_lib_run.py --compile}
    puts "Re-compiling using command ${cmd_show}"

    set chan [open |[list {/opt/quicklogic/conda/bin/python3} {-u} {-c} {import sys;import subprocess;exit(subprocess.call(['/opt/quicklogic/conda/bin/python3', '-u', 'scheduller_lib_run.py', '--compile'], cwd='/home/rftafas/Projects/stdblocks/scheduler_lib', bufsize=0, universal_newlines=True, stdout=sys.stdout, stderr=sys.stdout))}] r]

    while {[gets $chan line] >= 0} {
        puts $line
    }

    if {[catch {close $chan} error_msg]} {
        puts "Re-compile failed"
        puts ${error_msg}
        return true
    } else {
        puts "Re-compile finished"
        return false
    }
}

proc vunit_restart {} {
    if {![vunit_compile]} {
        _vunit_sim_restart
        vunit_run
    }
}
