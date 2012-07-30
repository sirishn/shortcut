# generate verilog for spike counters
# Sirish Nandyala
# hi@siri.sh

class SpikeCounter

    attr_reader :id
    attr_accessor :input_id

    def initialize
        $spike_counters ||= []
        @@spike_counter_block_count ||= -1
        @@spike_counter_block_count += 1
        @id = ["spike_counter", @@spike_counter_block_count]
        @input_id = ["dummy_neuron", 999]
        $spike_counters += [self]   
    end

    def connect_from(source)
        @input_id = source.id    
    end

    def put_wire_definitions
        wires = %{
        // Spike Counter #{@id} Wire Definitions
        wire [31:0] spike_count_#{@input_id};
        }
        puts wires    
    end

    def put_instance_definition
        instance = %{
        // Spike Counter #{@id} Instance Definition
        spike_counter #{@id}(
            .clk(neuron_clk),
            .reset(reset_global),
            .spike_in(each_spike_#{@input_id}), 
            .spike_count( spike_count_#{@input_id})
        );
        }
        puts instance    
    end
end
