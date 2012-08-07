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

    def connect_to(destination)
        destination.connect_from self
    end

    def connect_from(source)
        if source.id[0] == "triggered_input"
            @gamma_dynamic_id = source.id if source.name == "gamma_dynamic"
            @gamma_static_id = source.id if source.name == "gamma_static"
            @BDAMP_1_id = source.id if source.name == "BDAMP_1"
            @BDAMP_2_id = source.id if source.name == "BDAMP_2"
            @BDAMP_chain_id = source.id if source.name == "BDAMP_chain"
        elsif source.id[0] == "waveform"
            @lce_id = source.id 
        else
            raise "cannot connect #{source} to #{self}"
        end
    end

    def connect_parameters
      @@gamma_dynamic ||= TriggeredInput.new [50,4], "32'h42A0_0000", "gamma_dynamic"
      @@gamma_static ||= TriggeredInput.new [50,5], "32'h42A0_0000", "gamma_static"

      @@bdamp_1 ||= TriggeredInput.new [50,15], "32'h3E71_4120", "BDAMP_1"
      @@bdamp_2 ||= TriggeredInput.new [50,14], "32'h3D14_4674", "BDAMP_2"
      @@bdamp_chain ||= TriggeredInput.new [50,13], "32'h3C58_44D0", "BDAMP_chain"
      
      @@gamma_dynamic.connect_to self
      @@gamma_static.connect_to self
      @@bdamp_1.connect_to self
      @@bdamp_2.connect_to self
      @@bdamp_chain.connect_to self
    end
    
    def put_wire_definitions
        wires = %{
        // Spindle #{@id} Wire Definitions
        wire [31:0] Ia_#{@id};    // Ia afferent (pps)
        wire [31:0] II_#{@id};    // II afferent (pps)
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
            .out2(II_#{@id}),                   // II afferent (pps)
            .out3(Ia_#{@id}),                   // Ia afferent (pps)
            .BDAMP_1(#{@BDAMP_1_id}),           // Damping coefficient for bag1 fiber
            .BDAMP_2(#{@BDAMP_2_id}),           // Damping coefficient for bag2 fiber
            .BDAMP_chain(#{@BDAMP_chain_id})    // Damping coefficient for chain fiber
        );
        }
        puts instance
    end
end

