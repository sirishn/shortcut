# generate verilog for neuron modules
# Sirish Nandyala
# hi@siri.sh

class Neuron
    
    attr_reader :id
    attr_accessor :input_id, :spike_counter

    def initialize
        $neurons ||= []
        @@neuron_block_count ||= -1        
        @@neuron_block_count += 1
        @id = ["neuron", @@neuron_block_count]
        @input_id = ["dummy", 0]
        @spike_counter = SpikeCounter.new
        @spike_counter.connect_from(self)     
        $neurons += [self]       
    end

    def connect_to(destination)
        #destination.input_id = Synapse.new( @id, destination.id).id if destination.id[0] == "neuron"
        destination.connect_from self  
    end

    def connect_from(source)
        @input_id = Synapse.new(source.id, @id).id if source.id[0] == "neuron"
        @input_id = source.id if source.id[0] == "triggered_input"    
    end

    def put_wire_definitions
        
        wires = %{
        // Neuron #{@id} Wire Definitions
        wire [31:0] v_#{@id};   // membrane potential
        wire spike_#{@id};      // spike sample for visualization only
        wire each_spike_#{@id}; // raw spike signals
        wire [127:0] population_#{@id}; // spike raster for entire population        
        }
        puts wires
    
    end

    def put_instance_definition
    
        i_in = "each_I_#{@input_id}" if @input_id[0] == "synapse"
        i_in = @input_id.to_s if @input_id[0] == "triggered_input"

        instance = %{

        // Neuron #{@id} Instance Definition
        izneuron #{@id}(
            .clk(neuron_clk),               // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),           // reset to initial conditions
            .I_in(#{i_in}),          // input current from synapse
            .v_out(v_#{@id}),               // membrane potential
            .spike(spike_#{@id}),           // spike sample
            .each_spike(each_spike_#{@id}), // raw spikes
            .population(population_#{@id})  // spikes of population per 1ms simulation time
        );
        }
        puts instance
    end

end
