# generate verilog for synapse modules
# Sirish Nandyala
# hi@siri.sh

class Synapse

    attr_reader :id
    attr_accessor :presynaptic_id, :postsynaptic_id

    def initialize( presynaptic_id, postsynaptic_id)
        $synapses ||= [] 
        @@synapse_block_count ||= -1        
        @@synapse_block_count += 1
        @id = ["synapse", @@synapse_block_count]
        @presynaptic_id = presynaptic_id
        @postsynaptic_id = postsynaptic_id     
        $synapses += [self]              
    end

    def put_wire_definitions
        wires = %{
        // Synapse #{@id} Wire Definitions        
        wire [31:0] I_#{@id};   // sample of the synaptic current (updates once per 1ms simulation time)
        wire [31:0] each_I_#{@id};  // raw synaptic currents
        }
        puts wires 
    end
    
    def put_instance_definition
        instance = %{
        // Synapse #{@id} Instance Definition
        synapse #{@id}(
            .clk(neuron_clk),   // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),   // reset synaptic weights
            .spike_in(each_spike_#{@presynaptic_id}),   // spike from presynaptic neuron
            .postsynaptic_spike_in(each_spike_#{@postsynaptic_id}), //spike from postsynaptic neuron
            .I_out(I_#{@id}),    // sample of synaptic current out
            .each_I(each_I_#{@id}) // raw synaptic currents
        );
        }
        puts instance
    end

end
