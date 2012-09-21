# easily generate verilog for a static input 
# Sirish Nandyala
# hi@siri.sh

class StaticInput

    attr_reader :id
    attr_accessor :name, :target_id

    def initialize(value=0, name=-1)
        $static_inputs ||= []
        @@static_input_block_count ||= -1
        @@static_input_block_count += 1
        @id = ["static_input", @@static_input_block_count]
        @target_id = ["dummy_target", 999]
        @value = value
        @name = name unless name == -1
        @name = @id.join if name == -1
        
        $static_inputs += [self]
    end

    def connect_to(destination)
        destination.connect_from self
        @target_id = destination.id
    end
    
    def format_data_type(value)
        (block_type, index) = @target_id
        if block_type == "neuron"
            return format_fixed(value)
        elsif block_type == "spindle"
            return format_float(value)
        elsif block_type == "muscle"
            return format_float(value)
        elsif block_type == "clk_gen"
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
        // Static Input #{@id.join} Wire Definitions
        wire [31:0] #{@id.join};    // Static input (#{@name}) 
        }
        puts wires
    end
    
    def put_instance_definition
        
        instance = %{
        // Static Input #{@id.join} Instance Definition
        assign #{@id.join} = #{format_data_type(@value)};
        }
        puts instance
    end

end