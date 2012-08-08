# generate verilog for opalkelly outputs
# Sirish Nandyala
# hi@siri.sh

class Output

    attr_reader :id
    attr_accessor :input_id, :wire_count
    
    def initialize
        $outputs ||= []
        @@output_block_count ||= -1
        @@output_block_count += 1
        @id = ["output", @@output_block_count]
        @input_id = []
        @wire_out_address = 31
        @wire_out_index = -1
        @wire_count = 0
        $outputs += [self]
    end

    def connect_from(source)
        (block_type,index) = source.id
        if block_type == "neuron"
            @input_id += [source.input_id] if source.input_id[0] == "synapse" unless @input_id.include? source.input_id
            @input_id += [source.id] unless @input_id.include? source.id
            @input_id += [source.spike_counter.id] unless @input_id.include? source.spike_counter.id        
        elsif block_type == "spindle"
            @input_id += [source.id] unless @input_id.include? source.id
        elsif block_type == "waveform"
            @input_id += [source.id] unless @input_id.include? source.id
        elsif block_type == "triggered_input"
            @input_id += [source.id] unless @input_id.include? source.id
        else
            raise "cannot connect #{source} to #{self}"
        end
    end
    
    def count_wires
        @wire_count = 0
        @input_id.each do |block_type, index|
           @wire_count += 4 if block_type == "neuron"
           @wire_count += 2 if block_type == "synapse"
           @wire_count += 2 if block_type == "spike_counter"
           @wire_count += 2 if block_type == "waveform"
           @wire_count += 2 if block_type == "triggered_input"
           @wire_count += 4 if block_type == "spindle"    
        end
    end
    
    def put_wire_definitions
        count_wires
        wires = %{
        // Output and OpalKelly Interface Wire Definitions
        
        wire [#{@wire_count}*17-1:0] ok2x;
        wire [15:0] ep00wire, ep01wire, ep02wire;
        wire [15:0] ep50trig;
        
        wire pipe_in_write;
        wire [15:0] pipe_in_data;
        }
        puts wires
    end
    
    def put_instance_definition
        count_wires
        instance = %{
        // Output and OpalKelly Interface Instance Definitions
        assign led = 0;
        assign reset_global = ep00wire[0];
        okWireOR # (.N(#{@wire_count})) wireOR (ok2, ok2x);
        okHost okHI(
            .hi_in(hi_in),  .hi_out(hi_out),    .hi_inout(hi_inout),    .hi_aa(hi_aa),
            .ti_clk(ti_clk),    .ok1(ok1),  .ok2(ok2)   );
        
        okTriggerIn ep50    (.ok1(ok1), .ep_addr(8'h50),    .ep_clk(clk1),  .ep_trigger(ep50trig)   );
        
        okWireIn    wi00    (.ok1(ok1), .ep_addr(8'h00),    .ep_dataout(ep00wire)   );
        okWireIn    wi01    (.ok1(ok1), .ep_addr(8'h01),    .ep_dataout(ep01wire)   );
        okWireIn    wi02    (.ok1(ok1), .ep_addr(8'h02),    .ep_dataout(ep02wire)   );
        }
        @input_id.each do |input_id|
            (block_type,index) = input_id

            if block_type == "neuron"
                instance += add_wire_outs "v", input_id
                instance += add_wire_outs "population", input_id
            elsif block_type == "synapse"
                instance += add_wire_outs "I", input_id
            elsif block_type == "spike_counter"
                instance += add_wire_outs "spike_count", input_id
            elsif block_type == "waveform"
                instance += add_wire_outs "", input_id
            elsif block_type == "spindle"
                instance += add_wire_outs "Ia", input_id
                instance += add_wire_outs "II", input_id
            elsif block_type == "triggered_input"
                instance += add_wire_outs "", input_id
            end
        end
        puts instance
    end
    
    def add_wire_outs(datain_prefix, input_id)
        datain = "#{datain_prefix}_#{input_id.join}"
        datain = "#{datain_prefix}_neuron#{input_id[1]}" if datain_prefix == "spike_count"
        datain = "#{input_id.join}" if datain_prefix == ""
        return %{
        okWireOut wo#{(@wire_out_address+=1).to_s(16)} (    .ep_datain(#{datain}[15:0]),  .ok1(ok1),  .ok2(ok2x[#{@wire_out_index+=1}*17 +: 17]), .ep_addr(8'h#{@wire_out_address.to_s(16)})    );
        okWireOut wo#{(@wire_out_address+=1).to_s(16)} (    .ep_datain(#{datain}[31:16]),  .ok1(ok1),  .ok2(ok2x[#{@wire_out_index+=1}*17 +: 17]), .ep_addr(8'h#{@wire_out_address.to_s(16)})   );    
        }
    end
    
end