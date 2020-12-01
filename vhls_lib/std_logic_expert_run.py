from os.path import join, dirname
import sys

try:
    from vunit import VUnit
except:
    print("Please, intall vunit_hdl with 'pip install vunit_hdl'")
    print("Also, make sure to have either GHDL or Modelsim installed.")
    exit()

root = dirname(__file__)

vu = VUnit.from_argv()

lib = vu.add_library("stdblocks")
lib.add_source_files(join(root, "./vhls_lib.vhd"))
lib.add_source_files(join(root, "./vhls_lib_tb.vhd"))
test_tb = lib.entity("vhls_lib_tb")
test_tb.scan_tests_from_file(join(root, "vhls_lib_tb.vhd"))

vu.main()
