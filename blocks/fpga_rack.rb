# manage the fpga-fpga communication pins
# Sirish Nandyala
# hi@siri.sh

class FPGARack
  
  attr_reader :id, :next_open_input, :next_open_output
  attr_accessor :input_id
  
  def initialize
    $fpga_racks ||= []
    @@fpga_rack_block_count ||= -1
    @@fpga_rack_block_count += 1
    @id = ["fpga_rack", @@fpga_rack_block_count]
    @next_open_input ||= 1
    @next_open_output ||= 0
    @input_id = []

    $fpga_racks += [self]
  end
  
  def connect_to(destination)
    @next_open_output = 1 if @next_open_output == 0
    destination.connect_from self
    @next_open_output += 1
  end
  
  def connect_from(source)
    (block_type, index) = source.id
    if block_type == "neuron"
      @input_id += [source.id]
    else
      raise "cannot connect #{source} to #{self}"
    end
  end
  
  def put_wire_definitions
  
    wires = %{
    // FPGA Input/Output Rack Wire Definitions
    // these are in the top module input/output list
    }
  
    puts wires
  end
  
  def put_instance_definition
    puts "    //FPGA-FPGA Outputs"
    @input_id.each do |id|
      (block_type, index) = id
      if block_type == "neuron"
        puts "    assign spikeout#{@next_open_output} = each_spike_#{id.join};"
        @next_open_output += 1
      end
    end
    
    while @next_open_output <= 14 do
      puts "    assign spikeout#{@next_open_output} = 1'b0;"
      @next_open_output += 1
    end
    
    
  end
  
end
