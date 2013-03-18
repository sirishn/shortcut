# generate universal asynchronous receiver/transmitter
# sirish
# hi@siri.sh

class UART

   attr_reader :id
   attr_accessor :input_id, :target_id

   def initialize
       $uarts ||= []
       @@uart_block_count ||= -1
       @@uart_block_count += 1
       @id = ["uart", @@uart_block_count]
       @input_id = []
       @target_id = []
       @datain_rx = ""
       
       $uarts += [self]
   end

   def connect_from(source)
       (block_type,index) = source.id
       if block_type == "neuron"
           @input_id += [source.spike_counter.id] unless @input_id.include? source.spike_counter.id
       elsif ["waveform", "triggered_input", "emg", "muscle"].include? block_type
           @input_id += [source.id] unless @input.id.include? source.id
       elsif block_type == "fpga_rack"
           @datain_rx = "spikein#{$fpga_racks[0].next_open_input}" # if block_type == "fpga_rack"
       else
           raise "cannot connect #{source} to #{self}"
       end
       
       $fpga_racks[0].connect_from self if @target_id.empty?
   end
   
   def connect_to(destination)
     destination.connect_from self
     @target_id = destination.id
     $fpga_racks[0].connect_to self
     
   end
   
   def put_wire_definitions
     
     wires_tx = %{
     // UART Tx #{@id.join} Wire Definitions
     wire TxD_#{@id.join};
     }
     
     wires_rx = %{
     // UART Rx #{@id.join} Wire Definitions
     wire [31:0] RxData_#{@id.join};
     }
     
     puts wires_tx if @target_id.empty?
     puts wires_rx if @input_id.empty?
     
   end
   
   def put_instance_definition
     
     (block_type, index) = @input_id
     datain_tx = ""
     datain_tx = "spike_count_#{@input_id.join}}" if block_type == "neuron"
     datain_tx = "#{@input_id.join}" if ["triggered_input", "emg", "waveform"].include? block_type
     datain_tx = "total_force_out_#{@input_id.join}" if block_type == "muscle"
     
     instance_tx = %{
     // UART Tx #{@id.join} Instance Definition
     uart_tx_32 tx_#{@id.join}(
          .clock(neuron_clk),
          .reset(reset_global),
          .TxData(#{datain_tx}),
          .transmit(sim_clk),
          .TxD(TxD_#{@id.join}),
          .state(),
          .nextState()
     ); 
     }
     

     instance_rx = %{
     // UART Rx #{@id.join} Instance Definition
     uart_rx_32 rx_#{@id.join}(
          .clock(neuron_clk),
          .reset(global_reset),
          .RxD(#{@datain_rx}),
          .RxData(RxData_#{@id.join})
     );
     }
     
     puts instance_tx if @target_id.empty?
     puts instance_rx if @input_id.empty?
   end
   

end