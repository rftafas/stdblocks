import sys
import os

def indent(value):
    txt = ""
    for j in range(value):
        txt = txt + "  "
    return txt;

def create_axis_port( port_name, type, number, indsize):
    code = ""
    if ("master" in type):
        for j in range(number):
            code = code + indent(indsize) + ("--AXIS Master Port %d\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tready_i   : in  std_logic;\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tvalid_o   : out std_logic;\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tlast_o    : out std_logic;\r\n" % j)
    else :
        for j in range(number):
            code = code + indent(indsize) + ("--AXIS Slave Port %d\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tready_o : out std_logic;\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tvalid_i : in  std_logic;\r\n" % j)
            code = code + indent(indsize) + port_name + ("%d_tlast_i  : in  std_logic;\r\n" % j)
    return code

def create_port_connection( port_name, type, number_elements, indsize):
    code = ""
    if ("slave" in type):
        code = code + indent(indsize) + ("--Slave Connections\r\n")
        for j in range(number_elements):
            code = code + indent(indsize) + ("--Slave %d\r\n" % j)
            code = code + indent(indsize) + ("s_tvalid_s(%d) <= %s%d_tvalid_i;\r\n"   % (j, port_name, j))
            code = code + indent(indsize) + ("s_tlast_s(%d)  <= %s%d_tlast_i;\r\n"    % (j, port_name, j))
            code = code + indent(indsize) + ("%s%d_tready_o  <= s_tready_s(%d);\r\n" % (port_name, j, j))
            code = code + indent(indsize) + ("s_tdata_s(%d)  <= %s%d_tdata_i;\r\n"    % (j, port_name, j))
            code = code + indent(indsize) + ("s_tuser_s(%d)  <= %s%d_tuser_i;\r\n"    % (j, port_name, j))
            code = code + indent(indsize) + ("s_tdest_s(%d)  <= %s%d_tdest_i;\r\n"    % (j, port_name, j))
            code = code + indent(indsize) + ("\r\n")
    else:
        code = code + indent(indsize)+("--Master Connections\r\n")
        for j in range(number_elements):
            code = code + indent(indsize) + ("--Master %d\r\n" % j)
            code = code + indent(indsize) + ("%s%d_tvalid_o <= m_tvalid_s(%d);\r\n" % (port_name, j, j))
            code = code + indent(indsize) + ("%s%d_tlast_o  <= m_tlast_s(%d);\r\n"  % (port_name, j, j))
            code = code + indent(indsize) + ("m_tready_s(%d) <= %s%d_tready_i;\r\n"   % (j, port_name, j))
            code = code + indent(indsize) + ("%s%d_tdata_o  <= m_tdata_s(%d);\r\n"  % (port_name, j, j))
            code = code + indent(indsize) + ("%s%d_tuser_o  <= m_tuser_s(%d);\r\n"  % (port_name, j, j))
            code = code + indent(indsize) + ("%s%d_tdest_o  <= m_tdest_s(%d);\r\n"  % (port_name, j, j))
            code = code + indent(indsize) + ("\r\n")
    return code

def axi_custom( entity_name, number_slaves, number_masters):
    #check for axis_concat existance
    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_custom.vhd","r")
    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axi_custom is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axi_custom;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("s","slave",number_slaves,3))
            output_file.write(create_axis_port("m","master",number_masters,3))
        elif ("--python constant code" in line):
            output_file.write(indent(1)+"constant number_slaves  : integer := %d;\r\n" % number_slaves)
            output_file.write(indent(1)+"constant number_masters : integer := %d;\r\n" % number_masters)
        elif ("--python signal connections" in line):
            output_file.write(create_port_connection("m","master",number_masters,1))
            output_file.write(create_port_connection("s","slaves",number_slaves,1))
        else:
            output_file.write(line)
    return True;

def axi_concat( entity_name, number_elements):
    #check for axis_concat existance
    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_concat.vhd","r")
    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_concat is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_concat;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("s","slave",number_elements,3))
            output_file.write(indent(3)+"--AXIS Master Port\r\n")
            output_file.write(indent(3)+"m_tdata_o    : out std_logic_vector(%d*tdata_size-1 downto 0);\r\n" % number_elements)
            output_file.write(indent(3)+"m_tuser_o    : out std_logic_vector(%d*tuser_size-1 downto 0);\r\n" % number_elements)
            output_file.write(indent(3)+"m_tdest_o    : out std_logic_vector(%d*tdest_size-1 downto 0);\r\n" % number_elements)
        elif ("--python constant code" in line):
            output_file.write(indent(1)+"constant number_ports : integer := %d;\r\n" % number_elements)
        elif ("--python signal connections" in line):
            for j in range(number_elements):
                output_file.write(indent(2)+"s_tvalid_s(%d) <= s%d_tvalid_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(2)+"s_tlast_s(%d)  <= s%d_tlast_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(2)+"s%d_tready_o   <= m_tready_i;\r\n" % j)

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(2)+"axi_tdata_s(%d) <= s%d_tdata_i;\r\n" % (j,j))
                output_file.write(indent(2)+"axi_tuser_s(%d) <= s%d_tuser_i;\r\n" % (j,j))
                output_file.write(indent(2)+"axi_tdest_s(%d) <= s%d_tdest_i;\r\n" % (j,j))
        else:
            output_file.write(line)
    return True;

def axis_switch ( entity_name, number_elements):
    #check for axis_concat existance
    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_switch.vhd","r")
    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_switch is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_switch;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("s","slave",number_elements,3))
        elif ("--python constant code" in line):
            output_file.write("  constant number_ports : integer := %d;\r\n" % number_elements)
        elif ("--array connections" in line):
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tvalid_s(%d) <= s%d_tvalid_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tlast_s(%d)  <= s%d_tlast_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"axi_tdata_s(%d) <= s%d_tdata_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tuser_s(%d) <= s%d_tuser_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tdest_s(%d) <= s%d_tdest_i;\r\n" % (j,j))

        elif ("--ready connections" in line):
            for j in range(number_elements):
                output_file.write(indent(1)+"s%d_tready_o   <= s_tready_s(%d) and m_tready_i;\r\n" % (j,j))

        else:
            output_file.write(line)
    return True;

def axis_broadcast ( entity_name, number_elements):
    #check for axis_concat existance
    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_broadcast.vhd","r")
    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_broadcast is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_broadcast;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("m","master",number_elements,3))
        elif ("--python constant code" in line):
            output_file.write("  constant number_ports : integer := %d;\r\n" % number_elements)
        elif ("--array connections" in line):
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tvalid_s(%d) <= s%d_tvalid_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tlast_s(%d)  <= s%d_tlast_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"axi_tdata_s(%d) <= s%d_tdata_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tuser_s(%d) <= s%d_tuser_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tdest_s(%d) <= s%d_tdest_i;\r\n" % (j,j))

        elif ("--ready connections" in line):
            for j in range(number_elements):
                output_file.write(indent(1)+"s%d_tready_o   <= s_tready_s(%d) and m_tready_i;\r\n" % (j,j))

        else:
            output_file.write(line)
    return True;

def axis_aligner ( entity_name, number_elements):
    #check for axis_concat existance
    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_aligner.vhd","r")
    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_aligner is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_aligner;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(indent(1)+create_axis_port("m","master",number_elements,3))
            output_file.write(indent(1)+create_axis_port("s","slave",number_elements,3))
        elif ("--python constant code" in line):
            output_file.write("  constant number_ports : integer := %d;\r\n" % number_elements)
        elif ("--array connections" in line):
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tvalid_s(%d) <= s%d_tvalid_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"s_tlast_s(%d)  <= s%d_tlast_i;\r\n" % (j, j))

            output_file.write("\r\n")
            for j in range(number_elements):
                output_file.write(indent(3)+"axi_tdata_s(%d) <= s%d_tdata_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tuser_s(%d) <= s%d_tuser_i;\r\n" % (j,j))
                output_file.write(indent(3)+"axi_tdest_s(%d) <= s%d_tdest_i;\r\n" % (j,j))

        elif ("--python signal connections" in line):
            output_file.write(create_port_connection("m","master",number_elements,1))
            output_file.write(create_port_connection("s","slaves",number_elements,1))

        else:
            output_file.write(line)
    return True;

def axis_intercon ( entity_name, number_slaves, number_masters):
    #first we create inernal needed block.
    internal_name = entity_name+"_switch"
    if (not axis_switch(internal_name,number_slaves)):
        print("Error, cannot create internal switch.\r\n")
        sys.exit()

    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_intercon.vhd","r")


    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_intercon is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_intercon;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("m","master",number_masters,3))
            output_file.write(create_axis_port("s","slave",number_slaves,3))
        elif ("--component slaves port code" in line):
            output_file.write(indent(4)+create_axis_port("s","slave",number_slaves,4))
        elif ("--python constant code" in line):
            output_file.write("  constant number_masters : integer := %d;\r\n" % number_masters)
            output_file.write("  constant number_slaves : integer := %d;\r\n" % number_slaves)
        elif ("--array connections" in line):
            output_file.write(create_port_connection("m","master",number_masters,1))
            output_file.write(create_port_connection("s","slave",number_slaves,1))
        elif ("--switch instance slaves" in line):
            for j in range(number_slaves):
                output_file.write(indent(5)+"s%d_tdata_i  => s_tdata_s(%d),\r\n" % (j,j))
                output_file.write(indent(5)+"s%d_tdest_i  => s_tdest_s(%d),\r\n" % (j,j))
                output_file.write(indent(5)+"s%d_tuser_i  => s_tuser_s(%d),\r\n" % (j,j))
                output_file.write(indent(5)+"s%d_tlast_i  => s_tlast_s(%d),\r\n" % (j,j))
                output_file.write(indent(5)+"s%d_tvalid_i => valid_array_s(j)(%d),\r\n" % (j,j))
                output_file.write(indent(5)+"s%d_tready_o => valid_ready_s(j)(%d),\r\n" % (j,j))
        else:
            output_file.write(line)
    return True;

def axis_broadcast ( entity_name, number_masters):

    output_file_name = "output/"+entity_name+".vhd"
    output_file = open(output_file_name,"w+")

    concat_source = open("axis_broadcast.vhd","r")


    code_lines = concat_source.readlines()

    for line in code_lines:
        if ("entity axis_broadcast is" in line):
            output_file.write("entity %s is\r\n" % entity_name)
        elif ("end axis_broadcast;" in line):
            output_file.write("end %s;\r\n" % entity_name)
        elif ("architecture" in line):
            output_file.write("architecture behavioral of %s is\r\n" % entity_name)
        elif ("--python port code" in line):
            output_file.write(create_axis_port("m","master",number_masters,3))
        elif ("--component slaves port code" in line):
            output_file.write(indent(4)+create_axis_port("m","master",number_masters,4))
        elif ("--python constant code" in line):
            output_file.write("  constant number_masters : integer := %d;\r\n" % number_masters)
        elif ("--array connections" in line):
            output_file.write(create_port_connection("m","master",number_masters,1))
        else:
            output_file.write(line)
    return True;

def error_help():
    print("plase, select a valid option. Current available:\r\n")
    print("'custom'      : create axi empty block with master and slave ports.\r\n")
    print("'concat'      : create axi concatenation block. Makes two sync streams into one.\r\n")
    print("'switch'      : create an automatic AXI switch endine. Selects from various sources.\r\n")
    print("'aligner'     : forces early channels wait for late channels.\r\n")
    print("'intercon'    : AXI-S interconnect. TDEST based.\r\n")
    print("'broadcast'   : Copy slave stream data to several masters.\r\n")
    print("Usage: python axi-build.py <option> <entity name> <command paramenter>\r\n")
    print("Example: python axi-build.py concat my_concat_block 3\r\n")
    sys.exit()

####################################################################################################
# Application Menu
####################################################################################################
if not os.path.exists("output"):
    os.mkdir("output")

try:
    command = sys.argv[1]
except:
    error_help()

if (command == "custom"):
    entity_name = sys.argv[2]
    number_slaves = int(sys.argv[3])
    number_masters = int(sys.argv[4])
    success = axi_custom( entity_name, number_slaves, number_masters)
elif (command == "concat"):
    entity_name = sys.argv[2]
    number_slaves = int(sys.argv[3])
    success = axi_concat(entity_name,number_slaves)
elif (command == "switch"):
    entity_name = sys.argv[2]
    number_slaves = int(sys.argv[3])
    success = axis_switch(entity_name,number_slaves)
elif (command == "aligner"):
    entity_name = sys.argv[2]
    number_slaves = int(sys.argv[3])
    success = axis_aligner(entity_name,number_slaves)
elif (command == "intercon"):
    entity_name = sys.argv[2]
    number_slaves = int(sys.argv[3])
    number_masters = int(sys.argv[4])
    success = axis_intercon(entity_name,number_slaves,number_masters)
elif (command == "broadcast"):
    entity_name = sys.argv[2]
    number_masters = int(sys.argv[3])
    success = axis_broadcast(entity_name,number_masters)
else:
    print("Command not supported or yet to be implemented.")
    error_help()


if success:
    print("output is "+entity_name+".vhd")
    print("---------------------------------------------------------------------------------------------------------")
    print("-- This code and its autogenerated outputs are provided under LGPL by Ricardo Tafas.                   --")
    print("-- What does that mean? That you get it for free as long as you give back all good stuff you add to it.--")
    print("-- You can download more VHDL stuff at https://github.com/rftafas                                      --")
    print("---------------------------------------------------------------------------------------------------------")
sys.exit()
