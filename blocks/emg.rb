# generate verilog for emg module
# Sirish Nandyala
# hi@siri.sh

class EMG
  
  attr_reader :id
  attr_accessor :input_id
  
  def initialize
    $emgs ||= []
    @@emg_block_count ||= -1
    @@emg_block_count += 1
    
    @id = ["emg", @@emg_block_count]
    @input_id = ["dummy_input", 999]
    
    $emgs += [self]
  end
  
  def connect_to(destination)
    destination.connect_from self
  end
  
  def connect_from(source)
    (block_type, index) = source.id
    if ["neuron"].include? block_type
      @input_id = source.id
    else
      raise "cannot connect #{source} to #{self}"
    end 
  end
  
  def put_wire_definitions
        wires = %{
        // EMG #{@id.join} Wire Definitions
        wire [31:0] #{@id.join};        // EMG out
        }
        puts wires
  end
  
  def put_instance_definition
        instance = %{
        // EMG #{@id.join} Instance Definition
        emg #{@id.join}_instance(
            .clk(sim_clk),                                // update every 1ms
            .reset(reset_global),                         // reset the emg
            .spike_count(spike_count_#{@input_id.join}),  // input spike count to muscle
            .emg_out(#{@id.join})                     // emg out
        );
        }
        puts instance
  end
  
end