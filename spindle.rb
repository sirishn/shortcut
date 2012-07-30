# generate verilog for spindle
# Sirish Nandyala
# hi@siri.sh

class Spindle

    attr_reader :id
    attr_accessor :gamma_dynamic_id, :gamma_static_id, :lce_id, :BDAMP_1_id, :BDAMP_2_id, :BDAMP_chain_id

    def initialize
        $spindles ||= []
        @@spindle_block_count ||= -1
        @@spindle_block_count += 1
        @id = ["spindle", @@spindle_block_count]
        @gamma_dynamic_id = ["dummy_triggered_input", 999]
        @gamma_static_id = ["dummy_triggered_input", 999]
        @lce_id = ["dummy_waveform", 999]
        @BDAMP_1_id = ["dummy_triggered_input", 999]
        @BDAMP_2_id = ["dummy_triggered_input", 999]
        @BDAMP_chain_id = ["dummy_triggered_input", 999]
        $spindles += [self]    
    end

    def connect_from(source)
        if source.id[0] == "triggered_input"
            @gamma_dynamic_id = source.id if source.name == "gamma_dynamic"
            @gamma_static_id = source.id if source.name == "gamma_static"
            @BDAMP_1_id = source.id if source.name == "BDAMP_1"
            @BDAMP_2_id = source.id if source.name == "BDAMP_2"
            @BDAMP_chain_id = source.id if source.name == "BDAMP_chain"
        end
        @lce_id = source.id if source.id[0] == "waveform"
    end

    def put_wire_definitions
        wires = %{
        // Spindle #{@id} Wire Definitions
        wire [31:0] #{@id}_Ia;    // Ia afferent (pps)
        wire [31:0] #{@id}_II;    // II afferent (pps)
        }       
        puts wires
    end

    def put_instance_definition
        instance = %{
        // Spindle #{@id} Instance Definition
        spindle #{@id} (
            .gamma_dyn(#{@gamma_dynamic_id}),   // spindle dynamic gamma input (pps)
            .gamma_sta(#{@gamma_static_id}),    // spindle static gamma input (pps)
            .lce(#{@lce_id}),                   // length of contractile element (muscle length)
            .clk(spindle_clk),                  // spindle clock (3 cycles per 1ms simulation time) 
            .reset(reset_global),               // reset the spindle
            .out0(),
            .out1(),
            .out2(#{@id}_II),                   // II afferent (pps)
            .out3(#{@id}_Ia),                   // Ia afferent (pps)
            .BDAMP_1(#{@BDAMP_1_id}),           // Damping coefficient for bag1 fiber
            .BDAMP_2(#{@BDAMP_2_id}),           // Damping coefficient for bag2 fiber
            .BDAMP_chain(#{@BDAMP_chain_id})    // Damping coefficient for chain fiber
        );
        }
        puts instance
    end
end

