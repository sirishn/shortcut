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
        
        @Ia_gain_id = ["dummy_triggered_input", 999]
        @II_gain_id = ["dummy_triggered_input", 999]
        
        connect_parameters
        
        $spindles += [self]    
    end

    def connect_to(destination, type=-1)
        (block_type,index) = destination.id
        destination.connect_from self unless block_type == "neuron"
        destination.connect_from(self,type) if block_type == "neuron"
    end

    def connect_from(source)
        (block_type,index) = source.id
        if ["triggered_input", "static_input"].include? block_type
            @gamma_dynamic_id = source.id if source.name == "gamma_dynamic"
            @gamma_static_id = source.id if source.name == "gamma_static"
            @BDAMP_1_id = source.id if source.name == "BDAMP_1"
            @BDAMP_2_id = source.id if source.name == "BDAMP_2"
            @BDAMP_chain_id = source.id if source.name == "BDAMP_chain"
            @lce_id = source.id if source.name == "lce"
            @Ia_gain_id = source.id if source.name == "Ia_gain"
            @II_gain_id = source.id if source.name == "II_gain"
        #elsif block_type == "waveform"
        elsif ["waveform", "uart"].include? block_type
            @lce_id = source.id 
        else
            raise "cannot connect #{source} to #{self}"
        end
    end

    def connect_parameters
      @@gamma_dynamic ||= TriggeredInput.new 80, "gamma_dynamic", [50,4]
      @@gamma_static ||= TriggeredInput.new 80, "gamma_static", [50,5]

      @@bdamp_1 ||= TriggeredInput.new 0.2356, "BDAMP_1", [50,15]           #"32'h3E71_4120"
      @@bdamp_2 ||= TriggeredInput.new 0.0362, "BDAMP_2", [50,14]           #"32'h3D14_4674"
      @@bdamp_chain ||= TriggeredInput.new 0.0132, "BDAMP_chain", [50,13]   #"32'h3C58_44D0"
      
      @@Ia_gain ||= TriggeredInput.new -1, "Ia_gain", [50,9]
      @@II_gain ||= TriggeredInput.new -1, "II_gain", [50,8]
      
      @@gamma_dynamic.connect_to self
      @@gamma_static.connect_to self
      @@bdamp_1.connect_to self
      @@bdamp_2.connect_to self
      @@bdamp_chain.connect_to self
      @@Ia_gain.connect_to self
      @@II_gain.connect_to self
    end
    
    def put_wire_definitions
        wires = %{
        // Spindle #{@id.join} Wire Definitions
        wire [31:0] Ia_#{@id.join};    // Ia afferent (pps)
        wire [31:0] II_#{@id.join};    // II afferent (pps)
        
        wire [31:0] int_Ia_#{@id.join}; // Ia afferent integer format
        wire [31:0] fixed_Ia_#{@id.join}; // Ia afferent fixed point format
        
        wire [31:0] int_II_#{@id.join}; // II afferent integer format
        wire [31:0] fixed_II_#{@id.join}; // II afferent fixed point format
        }       
        puts wires
    end

    def put_instance_definition
        
        (block_type, index) = @lce_id
        lce = @lce_id.join
        lce = "RxData_#{@lce_id.join}" if block_type == "uart"
        
        instance = %{
        // Spindle #{@id.join} Instance Definition
        spindle #{@id.join} (
            .gamma_dyn(#{@gamma_dynamic_id.join}),   // spindle dynamic gamma input (pps)
            .gamma_sta(#{@gamma_static_id.join}),    // spindle static gamma input (pps)
            .lce(#{lce}),                   // length of contractile element (muscle length)
            .clk(spindle_clk),                  // spindle clock (3 cycles per 1ms simulation time) 
            .reset(reset_global),               // reset the spindle
            .out0(),
            .out1(),
            .out2(II_#{@id.join}),                   // II afferent (pps)
            .out3(Ia_#{@id.join}),                   // Ia afferent (pps)
            .BDAMP_1(#{@BDAMP_1_id.join}),           // Damping coefficient for bag1 fiber
            .BDAMP_2(#{@BDAMP_2_id.join}),           // Damping coefficient for bag2 fiber
            .BDAMP_chain(#{@BDAMP_chain_id.join})    // Damping coefficient for chain fiber
        );
        
        // Ia Afferent datatype conversion (floating point -> integer -> scaled fixed point)
        floor   ia_#{@id.join}_float_to_int(
            .in(Ia_#{@id.join}),
            .out(int_Ia_#{@id.join})
        );
        
        assign fixed_Ia_#{@id.join} = int_Ia_#{@id.join} * #{@Ia_gain_id.join};
        
        // II Afferent datatype conversion (floating point -> integer -> scaled fixed point)
        floor   ii_#{@id.join}_float_to_int(
            .in(II_#{@id.join}),
            .out(int_II_#{@id.join})
        );
        
        assign fixed_II_#{@id.join} = int_II_#{@id.join} * #{@II_gain_id.join};
        
        }
        puts instance
    end
end

