library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;

package axis_lib is

  --axi parameters
  type fifo_data_rec is record
    tdest  : std_logic_vector;
    tdata  : std_logic_vector;
    tuser  : std_logic_vector;
    tlast  : std_logic;
  end record;

  type fifo_config_rec is record
    ram_type     :  fifo_t;
    fifo_size    : integer;
    tdata_size   : integer;
    tdest_size   : integer;
    tuser_size   : integer;
    packet_mode  : boolean;
    tuser_enable : boolean;
    tdest_enable : boolean;
    tlast_enable : boolean;
    cut_through  : boolean;
    sync_mode    : boolean;
  end record;

  function header_size_f ( param : fifo_config_rec ) return integer;


end package;

package body axis_lib is

  function fifo_type_dec ( ram_type : fifo_t ) return mem_t is
      --variable tmp : string;
  begin
      case ram_type is
          when blockram =>
              return blockram;
          when ultra =>
              return ultra;
          when registers =>
              return registers;
          when distributed =>
              return distributed;
          when others =>
              return registers;
              report "Unknown fifo type. Using Flip-flops." severity warning;
      end case;
      --return tmp;
  end function fifo_type_dec;

  function header_size_f (
    param   : fifo_config_rec
  )
  return integer is
      variable tmp : integer;
  begin
    tmp := 0;
    if not param.packet_mode then
      if param.tlast_enable then
        tmp := 1;
      end if;
      if param.tuser_enable then
        tmp := param.tuser_size + tmp;
      end if;
      if param.tdest_enable then
        tmp := tmp + param.tdest_size;
      end if;
    end if;
    return tmp;
  end header_size_f;

  function fifo_size_f (
    param   : fifo_config_rec
  )
  return integer is
      variable tmp : integer;
  begin
    tmp := param.tdata_size + header_size_f(param);
    return tmp;
  end fifo_size_f;

  function head_bus_in (
    param : fifo_config_rec;
    data  : fifo_data_rec
  ) return std_logic_vector is
    variable head_data_v : std_logic_vector(header_size_f(param) downto 0);
  begin
  --
    if param.packet_mode or param.tlast_enable then
      head_data_v(0) <= data.tlast;
    end if;

    if param.tuser_enable then
      head_data_v := head_data_v sll param.tuser_size;
      head_data_v(data.tuser'range) := data.tuser;
    end if;

    if param.tdest_enable then
      head_data_v := head_data_v sll param.tdest_size;
      head_data_v(data.tdest'range) := data.tdest;
    end if;

    return head_data_v;
  end head_bus_in;

  function data_bus_in (
    param : in fifo_config_rec;
    data  : in fifo_data_rec
  ) return std_logic_vector is
    variable head_data_v : std_logic_vector(header_size_f(param) downto 0);
    variable fifo_data_v : std_logic_vector(  fifo_size_f(param) downto 0);
  begin
    head_data_v := head_bus_in(data,param);
    fifo_data_v(fifo_size_f(param) downto fifo_size_f(param)-head_data_v'length) := head_data_v;
    fifo_data_v(data.tdata'range) := data.tdata;
    return fifo_data_v;
  end data_bus_in;

  function head_bus_out (
    param      : in  fifo_config_rec;
    input_data : in  std_logic_vector
  ) return fifo_data_rec is
    variable head_data_v : std_logic_vector(header_size_f(param)-1 downto 0);
    variable data_v      : fifo_data_rec;
  begin
    head_data_v  := input_data;
    data_v.tdata := (others=>'0');
    
    if param.tdest_enable then
      data_v.tdest <= head_data_v(data_v.tdest'range);
      head_data_v  := head_data_v srl param.tdest_size;
    end if;

    if param.tuser_enable then
      data_v.tuser <= head_data_v(data_v.tuser'range);
      head_data_v  := head_data_v srl param.tuser_size;
    end if;

    if param.packet_mode or param.tlast_enable then
      data_v.tlast <= head_data_v(0);
    end if;

    return data_v;
  end head_bus_out;

  function data_bus_out (
    param     : in  fifo_config_rec;
    fifo_data : in  std_logic_vector
  ) return fifo_data_rec is
    variable head_data_v : std_logic_vector(header_size_f(param)-1 downto 0);
    variable data_v      : fifo_data_rec;
  begin
    head_data_v  := fifo_data(fifo_data'high downto param.tdata_size);
    data_v       := head_bus_out(param,head_data_v);
    data_v.tdata := fifo_data(data_v.tdata'range);
    return data_v;
  end data_bus_out;


end package body;
