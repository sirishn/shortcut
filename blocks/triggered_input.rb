# generate verilog for a PC-to-opalkelly triggered input
# Sirish Nandyala
# hi@siri.sh

class TriggeredInput
    
    attr_reader :id
    attr_accessor :trigger_address, :reset_value, :name    

    def initialize(trigger_address=-1, reset_value=-1, name=-1)
        $triggered_inputs ||= []
        @@triggered_input_block_count ||= -1
        @@triggered_input_block_count += 1
        @id = ["triggered_input", @@triggered_input_block_count]
        @trigger_address = trigger_address unless trigger_address == -1
        @trigger_address = [50, @@triggered_input_block_count] if trigger_address == -1
        @reset_value = reset_value unless reset_value == -1
        @reset_value = @id.join if reset_value == -1
        @name = name unless name == -1
        @name = @id.to_s if name == -1
	    $triggered_inputs += [self]   
    end

    def connect_to(destination)
        destination.connect_from self
    end

    def put_wire_definitions
        wires = %{
        // Triggered Input #{@id.join} Wire Definitions
        reg [31:0] #{@id.join};    // Triggered input sent from USB (#{@name})       
        }
        puts wires    
    end

    def put_instance_definition
        instance = %{
        // Triggered Input #{@id.join} Instance Definition (#{@name})
        always @ (posedge ep#{@trigger_address[0]}trig[#{@trigger_address[1]}] or posedge reset_global)
        if (reset_global)
            #{@id.join} <= #{@reset_value};        
        else
            #{@id.join} <= {ep02wire, ep01wire};        
        }
	    puts instance
    end

end
