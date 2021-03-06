# generate verilog for synapse modules
# Sirish Nandyala
# hi@siri.sh

class Synapse

    attr_reader :id
    attr_accessor :presynaptic_id, :postsynaptic_id, :ltp_id, :ltd_id, :p_delta_id

    def initialize( presynaptic_id, postsynaptic_id, strength=-1 )
        $synapses ||= [] 
        @@synapse_block_count ||= -1        
        @@synapse_block_count += 1
        @id = ["synapse", @@synapse_block_count]
        @presynaptic_id = presynaptic_id
        @postsynaptic_id = postsynaptic_id
        @ltp_id = ["dummy_input", 999]
        @ltd_id = ["dummy_input", 999]
        @p_delta_id = ["dummy_input", 999]
        @synaptic_strength = 1024
        @synaptic_strength = strength unless strength==-1     
        
        connect_plasticity
        
        (block_type, id) = @presynaptic_id
        @spike_in = "each_spike_#{@presynaptic_id.join}" if block_type == "neuron"
        @spike_in = "spikein#{$fpga_racks[0].next_open_input}" if block_type == "fpga_rack"
        
        
        $synapses += [self]              
    end

    def connect_from(source)
      (block_type, index) = source.id
      if ["triggered_input", "static_input"].include? block_type
        @ltp_id = source.id if source.name == "ltp"
        @ltd_id = source.id if source.name == "ltd"
        @p_delta_id = source.id if source.name == "p_delta"
      else
        raise "cannot connect #{source} to #{self}"
      end
      
    end
    
    def connect_plasticity
      @@ltp ||= TriggeredInput.new 0, "ltp", [50,12]
      @@ltd ||= TriggeredInput.new 0, "ltd", [50,11]
      @@p_delta ||= TriggeredInput.new 0, "p_delta", [50, 10]
      
      @@ltp.connect_to self
      @@ltd.connect_to self
      @@p_delta.connect_to self
    
    end

    def put_wire_definitions
        wires = %{
        // Synapse #{@id.join} Wire Definitions        
        wire [31:0] I_#{@id.join};   // sample of the synaptic current (updates once per 1ms simulation time)
        wire [31:0] each_I_#{@id.join};  // raw synaptic currents
        wire [31:0] synaptic_strength_#{@id.join}; // baseline synaptic strength
        }
        puts wires 
    end
    
    def put_instance_definition

        
        instance = %{
        // Synapse #{@id.join} Instance Definition
        
        assign synaptic_strength_#{@id.join} = 32'd#{@synaptic_strength}; // baseline synaptic strength
        
        synapse #{@id.join}(
            .clk(neuron_clk),                           // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),                       // reset synaptic weights
            .spike_in(#{@spike_in}),             // spike from presynaptic neuron
            .postsynaptic_spike_in(each_spike_#{@postsynaptic_id.join}),   //spike from postsynaptic neuron
            .I_out(I_#{@id.join}),                           // sample of synaptic current out
            .each_I(each_I_#{@id.join}),                      // raw synaptic currents
            
            .base_strength(synaptic_strength_#{@id.join}),  // baseline synaptic strength              
        
            .ltp(#{@ltp_id.join}),                        // long term potentiation weight
            .ltd(#{@ltd_id.join}),                        // long term depression weight
            .p_delta(#{@p_delta_id.join})                 // chance for decay 
        );
        }
        puts instance
    end

end
