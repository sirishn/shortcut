# READY for some Raking
# easily generate verilog of neuromuscular circuitry using simple ruby commands
# Sirish Nandyala
# hi@siri.sh

$block_types = []
Dir["./blocks/*.rb"].each do |file|
    $block_types += [File.basename(file, File.extname(file))]
    require file
end


def generate_verilog
  
    @clk_divider ||= TriggeredInput.new -1, "clk_divider", [50,7]
    @clk ||= ClkGen.new
    @clk_divider.connect_to @clk
    
    blocks = []
    $modulename ||= "shortcut"
    $block_types.each do |block_type|
        eval("$#{block_type}s ||= []")
        eval("blocks += $#{block_type}s")
    end

    generate_opalkelly_header($modulename)

    puts "/////////////////////// BEGIN WIRE DEFINITIONS ////////////////////////////" 
    blocks.each do |block|
        block.put_wire_definitions
    end
    puts "/////////////////////// END WIRE DEFINITIONS //////////////////////////////"

    puts ""
    
    puts "/////////////////////// BEGIN INSTANCE DEFINITIONS ////////////////////////"
    blocks.each do |block|
        block.put_instance_definition
    end
    puts "/////////////////////// END INSTANCE DEFINITIONS //////////////////////////"
    
    puts "endmodule"
end


def generate_opalkelly_header(modulename)
  
    header = %{
`timescale 1ns / 1ps

// #{modulename}_xem6010.v
// Generated on #{Time.new}

    module #{modulename}_xem6010(
	    input  wire [7:0]  hi_in,
	    output wire [1:0]  hi_out,
	    inout  wire [15:0] hi_inout,
	    inout  wire        hi_aa,

	    output wire        i2c_sda,
	    output wire        i2c_scl,
	    output wire        hi_muxsel,
	    input  wire        clk1,
	    input  wire        clk2,
	
	    output wire [7:0]  led,
	    
	    // Neuron array inputs
          input wire spikein1,  
          input wire spikein2,
          input wire spikein3,
          input wire spikein4,
          input wire spikein5,
          input wire spikein6,
          input wire spikein7,
          input wire spikein8,
          input wire spikein9,
          input wire spikein10,
          input wire spikein11,
          input wire spikein12,
          input wire spikein13,
          input wire spikein14,
      
          // Neuron array outputs
          output wire spikeout1, 
          output wire spikeout2,
          output wire spikeout3,
          output wire spikeout4,
          output wire spikeout5,
          output wire spikeout6,
          output wire spikeout7,
          output wire spikeout8,
          output wire spikeout9,
          output wire spikeout10,
          output wire spikeout11,
          output wire spikeout12,
          output wire spikeout13,
          output wire spikeout14
       );
       
        parameter NN = 8;
		
        // *** Dump all the declarations here:
        wire         ti_clk;
        wire [30:0]  ok1;
        wire [16:0]  ok2;   
        wire reset_global;

        // *** Target interface bus:
        assign i2c_sda = 1'bz;
        assign i2c_scl = 1'bz;
        assign hi_muxsel = 1'b0;
    }
    puts header
    #`
end
