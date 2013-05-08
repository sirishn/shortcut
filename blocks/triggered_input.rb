# generate verilog for a PC-to-opalkelly triggered input
# Sirish Nandyala
# hi@siri.sh

class TriggeredInput
    
    attr_reader :id
    attr_accessor :trigger_address, :reset_value, :name    

    def initialize(reset_value=-1, name=-1, trigger_address=-1)
      $triggered_inputs ||= []
      @@triggered_input_block_count ||= -1
      @@triggered_input_block_count += 1
      @id = ["triggered_input", @@triggered_input_block_count]
      @target_id = ["dummy_target", 999]
      @trigger_address = trigger_address unless trigger_address == -1
      @trigger_address = [50, @@triggered_input_block_count] if trigger_address == -1
      @reset_value = reset_value unless reset_value == -1
      @reset_value = @id.join if reset_value == -1
      @name = name unless name == -1
      @name = @id.join if name == -1
	    $triggered_inputs += [self]   
    end

    def connect_to(destination)
      destination.connect_from self
      @target_id = destination.id
    end
    
    def format_data_type(value)
        (block_type, index) = @target_id
        if ["neuron", "synapse"].include? block_type
          return format_fixed(value) 
        elsif ["spindle", "muscle"].include? block_type
          return format_float(value) unless ["Ia_gain", "II_gain"].include? @name
          return format_int32(value) if ["Ia_gain", "II_gain"].include? @name 
        elsif ["clk_gen"].include? block_type
          return format_int32(value)
        end
        
    end
    
    def format_float(value)
        formatted_string = [value.to_f].pack('f').unpack('i')[0].to_s(16)
        while formatted_string.length < 8
            formatted_string = "0" + formatted_string
        end
        return "32'h#{formatted_string}"
    end
    
    def format_int32(value)
        return "32'd#{value.to_i}"
    end
    
    def format_fixed(value)
        return "32'd#{(value*1024).to_i}"
    end

    def put_wire_definitions
        wires = %{
        // Triggered Input #{@id.join} Wire Definitions
        reg [31:0] #{@id.join};    // Triggered input sent from USB (#{@name})       
        }
        puts wires    
    end

    def put_instance_definition
        reset_string = @reset_value 
        reset_string = format_data_type(@reset_value) unless @reset_value == @id.join
        
        instance = %{
        // Triggered Input #{@id.join} Instance Definition (#{@name})
        always @ (posedge ep#{@trigger_address[0]}trig[#{@trigger_address[1]}] or posedge reset_global)
        if (reset_global)
            #{@id.join} <= #{reset_string};         //reset to #{@reset_value}      
        else
            #{@id.join} <= {ep02wire, ep01wire};        
        }
	    puts instance
    end

end
