from os.path import join, dirname
import sys
import glob

try:
    from vunit import VUnit
except:
    print("Please, intall vunit_hdl with 'pip install vunit_hdl'")
    print("Also, make sure to have either GHDL or Modelsim installed.")
    exit()

root = dirname(__file__)

vu = VUnit.from_argv()

vu.add_verification_components()
vu.add_com()

expert = vu.add_library("expert")
expert.add_source_files(join(root, "../libraries/stdexpert/src/*.vhd"))

stdblocks = vu.add_library("stdblocks")
stdblocks_filelist = glob.glob("../sync_lib/*.vhd")
for vhd_file in stdblocks_filelist:
    if "_tb" not in vhd_file:
        stdblocks.add_source_file(vhd_file)

# stdblocks_filelist = glob.glob("./*.vhd")
# for vhd_file in stdblocks_filelist:
#     if "tdp" not in vhd_file:
#         stdblocks.add_source_file(vhd_file)
#     else:
#         stdblocks.add_source_file(vhd_file,vhdl_standard="1993")
stdblocks.add_source_files(join(root, "./*.vhd"))

#must use relaxed flag due to shared variable problem in VHDL2008/1993 conflict and how
#the different synthesizers understand it.
if "ghdl" in vu.get_simulator_name():
    vu.set_compile_option("ghdl.a_flags",["-frelaxed"])

test_tb = stdblocks.entity("ram_lib_tb")
test_tb.scan_tests_from_file(join(root, "ram_lib_tb.vhd"))

test_tb.add_config(
    name = "dp_ram",
    generics = dict(
        entity_sel      = "dp_ram",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = False,
        run_time        = 100,
    )
)

test_tb.add_config(
    name = "dp_ram_fall_through",
    generics = dict(
        entity_sel      = "dp_ram",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = True,
        run_time        = 100,
    )
)

test_tb.add_config(
    name = "tdp_ram",
    generics = dict(
        entity_sel      = "tdp_ram",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = False,
        run_time        = 100,
    )
)

test_tb.add_config(
    name = "tdp_ram_fall_through",
    generics = dict(
        entity_sel      = "tdp_ram",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = True,
        run_time        = 100,
    )
)

test_tb.add_config(
    name = "tdp_ram_difport",
    generics = dict(
        entity_sel      = "tdp_ram_difport",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = False,
        run_time        = 100,
    )
)

test_tb.add_config(
    name = "tdp_ram_difport_fall_through",
    generics = dict(
        entity_sel      = "tdp_ram_difport",
        port_size       = 8,
        addr_size       = 8,
        fall_through    = True,
        run_time        = 100,
    )
)

if "ghdl" in vu.get_simulator_name():
    vu.set_sim_option("ghdl.elab_flags",["-frelaxed"])
    vu.set_sim_option("ghdl.sim_flags",["-frelaxed"])

vu.main()
