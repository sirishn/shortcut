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

    def connect_to(destination)
        destination.connect_from self
    end

    def connect_from(source)
        if source.id[0] == "neuron"
            @input_id = source.id
        else
            raise "cannt connect #{source} to #{self}"
        end
    end

    def put_wire_definitions
        wires = %{
        // Spike Counter #{@id.join} Wire Definitions
        wire [31:0] spike_count_#{@input_id.join};
        }
        puts wires    
    end

    def put_instance_definition
        instance = %{
        // Spike Counter #{@id.join} Instance Definition
        spike_counter #{@id.join}(
            .clk(neuron_clk),
            .reset(reset_global),
            .spike_in(each_spike_#{@input_id.join}), 
            .spike_count( spike_count_#{@input_id.join})
        );
        }
        puts instance    
    end
end
