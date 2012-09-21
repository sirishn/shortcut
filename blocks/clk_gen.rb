# generate verilog for clk generator
# Sirish Nandyala
# hi@siri.sh

class ClkGen

    attr_reader :id
    attr_accessor :input_id

    def initialize
        $clk_gens ||= []
        @@clk_gen_block_count ||= -1
        @@clk_gen_block_count += 1
        @id = ["clk_gen", @@clk_gen_block_count]
        @input_id = ["dummy_triggered_input", 999]
        $clk_gens += [self]   
    end

    def connect_from(source)
        (block_type, index) = source.id
        if ["triggered_input", "static_input"].include? block_type
            @input_id = source.id
        else
            raise "cannot connect #{source} to #{self}"
        end
              
    end

    def put_wire_definitions
        wires = %{
        // Clock Generator #{@id.join} Wire Definitions
        wire neuron_clk;  // neuron clock (128 cycles per 1ms simulation time) 
        wire sim_clk;     // simulation clock (1 cycle per 1ms simulation time)
        wire spindle_clk; // spindle clock (3 cycles per 1ms simulation time)
        }
        puts wires    
    end

    def put_instance_definition
        instance = %{
        // Clock Generator #{@id.join} Instance Definition
        gen_clk clocks(
            .rawclk(clk1),
            .half_cnt(#{@input_id.join}),
            .clk_out1(neuron_clk),
            .clk_out2(sim_clk),
            .clk_out3(spindle_clk),
            .int_neuron_cnt_out()
        );
        }
        puts instance    
    end
end
