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
	
	    output wire [7:0]  led
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
