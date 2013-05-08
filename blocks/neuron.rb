 # generate verilog for neuron modules
# Sirish Nandyala
# hi@siri.sh

class Neuron
    
    attr_reader :id
    attr_accessor :input_id, :spike_counter, :name

    def initialize(name=-1, type=-1)
        $neurons ||= []
        @@neuron_block_count ||= -1        
        @@neuron_block_count += 1
        @id = ["neuron", @@neuron_block_count]
        #@input_id = ["dummy", 0]
        @input_id = []
        @spike_counter = SpikeCounter.new
        @spike_counter.connect_from(self) 
        @name = @id.join if name == -1
        @name = name unless name == -1
        @type = "regular spiking" if type == -1
        @type = type unless type == -1
        
        @afferent_type = "Ia"
        
        $neurons += [self]       
    end

    def connect_to(destination, strength=-1)
        #destination.input_id = Synapse.new( @id, destination.id).id if destination.id[0] == "neuron"
        (block_type,index) = destination.id
        destination.connect_from self unless ["neuron", "fpga_rack"].include? block_type
        destination.connect_from self, strength if ["neuron", "fpga_rack"].include? block_type
    end

    def connect_from(source, synaptic_strength=-1)
        (block_type,index) = source.id
        #if block_type == "neuron"
        if ["neuron", "fpga_rack"].include? block_type
            @input_id += [Synapse.new(source.id, @id, synaptic_strength).id] 
        elsif ["triggered_input", "static_input"].include? block_type 
            @input_id += [source.id]
        elsif block_type == "spindle"
            @input_id += [source.id]
            @afferent_type = synaptic_strength unless synaptic_strength == -1
        else
            raise "cannot connect #{source} to #{self}"
        end
    end

    def put_wire_definitions
        
        wires = %{
        // Neuron #{@id.join} Wire Definitions (#{@name})
        wire [31:0] v_#{@id.join};   // membrane potential
        wire spike_#{@id.join};      // spike sample for visualization only
        wire each_spike_#{@id.join}; // raw spike signals
        wire [127:0] population_#{@id.join}; // spike raster for entire population  
        
        wire [31:0] a_#{@id.join};  // membrane recovery decay rate
        wire [31:0] b_#{@id.join};  // membrane recovery sensitivity
        wire [31:0] c_#{@id.join};  // membrane potential reset value
        wire [31:0] d_#{@id.join};  // membrane recovery reset value    
        }
        puts wires
    
    end

    def put_instance_definition
        i_in = "  "
        @input_id.each do |id|
            (block_type,index) = id
            i_in += id.join if ["triggered_input", "static_input"].include? block_type
            i_in += "each_I_#{id.join}" if block_type == "synapse"
            i_in += "fixed_#{@afferent_type}_#{id.join}" if block_type == "spindle"
            i_in += " + "
        end
        i_in = i_in[0..-3] # remove extra + 
        

        (a,b,c,d) = ["32'd82", "32'd205", "-32'd65560", "32'd2048"] if @type == "regular spiking"
        (a,b,c,d) = ["32'd12", "32'd205", "-32'd65560", "32'd2048"] if @type == "fast spiking"        
        
        instance = %{

        // Neuron #{@id.join} Instance Definition (#{@name} - #{@type})
        assign a_#{@id.join} = #{a};
        assign b_#{@id.join} = #{b};
        assign c_#{@id.join} = #{c};
        assign d_#{@id.join} = #{d};
        
        izneuron_abcd #{@id.join}(
            .clk(neuron_clk),               // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),           // reset to initial conditions
            
            .a(a_#{@id.join}),
            .b(b_#{@id.join}),
            .c(c_#{@id.join}),
            .d(d_#{@id.join}),
            
            .I_in(#{i_in}),          // input current from synapse
            .v_out(v_#{@id.join}),               // membrane potential
            .spike(spike_#{@id.join}),           // spike sample
            .each_spike(each_spike_#{@id.join}), // raw spikes
            .population(population_#{@id.join})  // spikes of population per 1ms simulation time
        );
        }
        puts instance
    end

end
