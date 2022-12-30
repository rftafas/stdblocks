from os.path import join, dirname
import sys
import glob

try:
    from vunit import VUnit
except:
    print("Please, intall vunit_hdl with 'pip install vunit_hdl'")
    print("Also, make sure to have either GHDL or Modelsim installed.")
    exit()

entities_list = (
    "pwm",
    "nco",
    "adpll",
    "frac_adpll",
    "long_counter",
    "precise_long_counter"
)

period_list = {
    "pwm"          : 50,
    "nco"          : 50,
    "adpll"        : 50,
    "frac_adpll"   : 50,
    "long_counter" : 40960,
    "precise_long_counter" : 50000
}

root = dirname(__file__)

vu = VUnit.from_argv()

expert = vu.add_library("expert")
expert.add_source_files(join(root, "../libraries/stdexpert/src/*.vhd"))

stdblocks = vu.add_library("stdblocks")
stdblocks_filelist = glob.glob("../sync_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../ram_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../fifo_lib/*.vhd")
for vhd_file in stdblocks_filelist:
    if "_tb" not in vhd_file:
        stdblocks.add_source_files(vhd_file)

stdblocks.add_source_files(join(root, "./*.vhd"))
test_tb = stdblocks.entity("timer_lib_tb")
test_tb.scan_tests_from_file(join(root, "timer_lib_tb.vhd"))

for entity in entities_list:
    test_tb.add_config(
        name = entity,
        generics = dict(
            entity_sel = entity,
            run_time   = 600,
            period     = period_list[entity]
        )
    )

vu.main()
