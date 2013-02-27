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
    @next_open_output ||= 1
    @input_id = []

    $fpga_racks += [self]
  end
  
  def connect_to(destination)
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
    // Neuron array inputs
    wire spikein1;  
    wire spikein2;
    wire spikein3;
    wire spikein4;
    wire spikein5;
    wire spikein6;
    wire spikein7;
    wire spikein8;
    wire spikein9;
    wire spikein10;
    wire spikein11;
    wire spikein12;
    wire spikein13;
    wire spikein14;
    
    // Neuron array outputs
    wire spikeout1; 
    wire spikeout2;
    wire spikeout3;
    wire spikeout4;
    wire spikeout5;
    wire spikeout6;
    wire spikeout7;
    wire spikeout8;
    wire spikeout9;
    wire spikeout10;
    wire spikeout11;
    wire spikeout12;
    wire spikeout13;
    wire spikeout14;  
    }
  
    puts wires
  end
  
  def put_instance_definition
    puts "    //FPGA-FPGA Outputs"
    @input_id.each do |id|
      (block_type, index) = id
      if block_type == "neuron"
        puts "    assign spikeout#{@next_open_output} = each_spike_#{id.join};"
      end
    end
    
  end
  
end
