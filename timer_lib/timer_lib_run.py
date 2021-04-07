from os.path import join, dirname
import sys

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
    "long_counter",
    "precise_long_counter"
)

period_list = {
    "pwm"   : 50,
    "nco"   : 50,
    "adpll" : 50,
    "long_counter" : 40960,
    "precise_long_counter" : 50000
}

root = dirname(__file__)

vu = VUnit.from_argv()

expert = vu.add_library("expert")
expert.add_source_files(join(root, "../libraries/stdexpert/src/*.vhd"))

lib = vu.add_library("stdblocks")
lib.add_source_files(join(root, "../sync_lib/*.vhd"))
lib.add_source_files(join(root, "../ram_lib/*.vhd"))
lib.add_source_files(join(root, "../fifo_lib/*.vhd"))
lib.add_source_files(join(root, "./*.vhd"))
test_tb = lib.entity("timer_lib_tb")
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
