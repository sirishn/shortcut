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
        wires = %{
        // Waveform Generator #{@id.join} Wire Definitions
        wire [31:0] #{@id.join};   // Wave out signal
        }
        puts wires
    end
    
    def put_instance_definition
        instance = %{
        // Waveform Generator #{@id.join} Instance Definition
        waveform_from_pipe_bram_2s gen_#{@id.join}(
            .reset(reset_global),               // reset the waveform
            .pipe_clk(ti_clk),                  // target interface clock from opalkelly interface
            .pipe_in_write(pipe_in_write),      // write enable signal from opalkelly pipe in
            .pipe_in_data(pipe_in_data),        // waveform data from opalkelly pipe in
            .pop_clk(sim_clk),                  // trigger next waveform sample every 1ms
            .wave(#{@id.join})                   // wave out signal
        );
        }
        puts instance
    end   
    
end
