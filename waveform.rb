# generate verilog for waveform function generator
# Sirish Nandyala
# hi@siri.sh

class Waveform

    attr_reader :id

    def initialize
        $waveforms ||= []
        @@waveform_block_count ||= -1
        @@waveform_block_count += 1
        @id = ["waveform", @@waveform_block_count]
        $waveforms += [self]    
    end
    
    def connect_to(destination)
      destination.connect_from self
    end
    
    def put_wire_definitions
      wires %{
      // Waveform Generator #{@id} Wire Definitions
      wire [31:0] #{@id};
      }
      puts wires;
    end
    
    def put_instance_definition
    instance = %{
    // Waveform Generator #{@id} Instance Definition
    waveform_from_pipe_bram_2s gen_#{@id}(
        .reset(reset_global),
        .pipe_clk(ti_clk),
        .pipe_in_write(pipe_in_write),
        .pipe_in_data(pipe_in_data),
        .pop_clk(sim_clk),
        .wave(#{@id})
    );
    }
    puts instance
    end
    
    
end
