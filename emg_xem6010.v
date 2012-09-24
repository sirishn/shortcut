
`timescale 1ns / 1ps

// emg_xem6010.v
// Generated on Fri Sep 21 14:39:09 -0700 2012

    module emg_xem6010(
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
    
/////////////////////// BEGIN WIRE DEFINITIONS ////////////////////////////

        // Clock Generator clk_gen0 Wire Definitions
        wire neuron_clk;  // neuron clock (128 cycles per 1ms simulation time) 
        wire sim_clk;     // simulation clock (1 cycle per 1ms simulation time)
        wire spindle_clk; // spindle clock (3 cycles per 1ms simulation time)
        

        // Triggered Input triggered_input0 Wire Definitions
        reg [31:0] triggered_input0;    // Triggered input sent from USB (I_in)       
        

        // Triggered Input triggered_input1 Wire Definitions
        reg [31:0] triggered_input1;    // Triggered input sent from USB (ltp)       
        

        // Triggered Input triggered_input2 Wire Definitions
        reg [31:0] triggered_input2;    // Triggered input sent from USB (ltd)       
        

        // Triggered Input triggered_input3 Wire Definitions
        reg [31:0] triggered_input3;    // Triggered input sent from USB (p_delta)       
        

        // Triggered Input triggered_input4 Wire Definitions
        reg [31:0] triggered_input4;    // Triggered input sent from USB (clk_divider)       
        

        // Output and OpalKelly Interface Wire Definitions
        
        wire [18*17-1:0] ok2x;
        wire [15:0] ep00wire, ep01wire, ep02wire;
        wire [15:0] ep50trig;
        
        wire pipe_in_write;
        wire [15:0] pipe_in_data;
        

        // Spike Counter spike_counter0 Wire Definitions
        wire [31:0] spike_count_neuron0;
        

        // Spike Counter spike_counter1 Wire Definitions
        wire [31:0] spike_count_neuron1;
        

        // Synapse synapse0 Wire Definitions        
        wire [31:0] I_synapse0;   // sample of the synaptic current (updates once per 1ms simulation time)
        wire [31:0] each_I_synapse0;  // raw synaptic currents
        

        // Synapse synapse1 Wire Definitions        
        wire [31:0] I_synapse1;   // sample of the synaptic current (updates once per 1ms simulation time)
        wire [31:0] each_I_synapse1;  // raw synaptic currents
        

        // Neuron neuron0 Wire Definitions
        wire [31:0] v_neuron0;   // membrane potential
        wire spike_neuron0;      // spike sample for visualization only
        wire each_spike_neuron0; // raw spike signals
        wire [127:0] population_neuron0; // spike raster for entire population        
        

        // Neuron neuron1 Wire Definitions
        wire [31:0] v_neuron1;   // membrane potential
        wire spike_neuron1;      // spike sample for visualization only
        wire each_spike_neuron1; // raw spike signals
        wire [127:0] population_neuron1; // spike raster for entire population        
        

        // EMG emg0 Wire Definitions
        wire [31:0] emg0;        // EMG out
        
/////////////////////// END WIRE DEFINITIONS //////////////////////////////

/////////////////////// BEGIN INSTANCE DEFINITIONS ////////////////////////

        // Clock Generator clk_gen0 Instance Definition
        gen_clk clocks(
            .rawclk(clk1),
            .half_cnt(triggered_input4),
            .clk_out1(neuron_clk),
            .clk_out2(sim_clk),
            .clk_out3(spindle_clk),
            .int_neuron_cnt_out()
        );
        

        // Triggered Input triggered_input0 Instance Definition (I_in)
        always @ (posedge ep50trig[6] or posedge reset_global)
        if (reset_global)
            triggered_input0 <= 32'd10240;         //reset to 10      
        else
            triggered_input0 <= {ep02wire, ep01wire};        
        

        // Triggered Input triggered_input1 Instance Definition (ltp)
        always @ (posedge ep50trig[12] or posedge reset_global)
        if (reset_global)
            triggered_input1 <= 32'd0;         //reset to 0      
        else
            triggered_input1 <= {ep02wire, ep01wire};        
        

        // Triggered Input triggered_input2 Instance Definition (ltd)
        always @ (posedge ep50trig[11] or posedge reset_global)
        if (reset_global)
            triggered_input2 <= 32'd0;         //reset to 0      
        else
            triggered_input2 <= {ep02wire, ep01wire};        
        

        // Triggered Input triggered_input3 Instance Definition (p_delta)
        always @ (posedge ep50trig[10] or posedge reset_global)
        if (reset_global)
            triggered_input3 <= 32'd0;         //reset to 0      
        else
            triggered_input3 <= {ep02wire, ep01wire};        
        

        // Triggered Input triggered_input4 Instance Definition (clk_divider)
        always @ (posedge ep50trig[7] or posedge reset_global)
        if (reset_global)
            triggered_input4 <= triggered_input4;         //reset to triggered_input4      
        else
            triggered_input4 <= {ep02wire, ep01wire};        
        

        // Output and OpalKelly Interface Instance Definitions
        assign led = 0;
        assign reset_global = ep00wire[0];
        okWireOR # (.N(18)) wireOR (ok2, ok2x);
        okHost okHI(
            .hi_in(hi_in),  .hi_out(hi_out),    .hi_inout(hi_inout),    .hi_aa(hi_aa),
            .ti_clk(ti_clk),    .ok1(ok1),  .ok2(ok2)   );
        
        okTriggerIn ep50    (.ok1(ok1), .ep_addr(8'h50),    .ep_clk(clk1),  .ep_trigger(ep50trig)   );
        
        okWireIn    wi00    (.ok1(ok1), .ep_addr(8'h00),    .ep_dataout(ep00wire)   );
        okWireIn    wi01    (.ok1(ok1), .ep_addr(8'h01),    .ep_dataout(ep01wire)   );
        okWireIn    wi02    (.ok1(ok1), .ep_addr(8'h02),    .ep_dataout(ep02wire)   );
        
        okWireOut wo20 (    .ep_datain(v_neuron0[15:0]),  .ok1(ok1),  .ok2(ok2x[0*17 +: 17]), .ep_addr(8'h20)    );
        okWireOut wo21 (    .ep_datain(v_neuron0[31:16]),  .ok1(ok1),  .ok2(ok2x[1*17 +: 17]), .ep_addr(8'h21)   );    
        
        okWireOut wo22 (    .ep_datain(population_neuron0[15:0]),  .ok1(ok1),  .ok2(ok2x[2*17 +: 17]), .ep_addr(8'h22)    );
        okWireOut wo23 (    .ep_datain(population_neuron0[31:16]),  .ok1(ok1),  .ok2(ok2x[3*17 +: 17]), .ep_addr(8'h23)   );    
        
        okWireOut wo24 (    .ep_datain(spike_count_neuron0[15:0]),  .ok1(ok1),  .ok2(ok2x[4*17 +: 17]), .ep_addr(8'h24)    );
        okWireOut wo25 (    .ep_datain(spike_count_neuron0[31:16]),  .ok1(ok1),  .ok2(ok2x[5*17 +: 17]), .ep_addr(8'h25)   );    
        
        okWireOut wo26 (    .ep_datain(I_synapse1[15:0]),  .ok1(ok1),  .ok2(ok2x[6*17 +: 17]), .ep_addr(8'h26)    );
        okWireOut wo27 (    .ep_datain(I_synapse1[31:16]),  .ok1(ok1),  .ok2(ok2x[7*17 +: 17]), .ep_addr(8'h27)   );    
        
        okWireOut wo28 (    .ep_datain(v_neuron1[15:0]),  .ok1(ok1),  .ok2(ok2x[8*17 +: 17]), .ep_addr(8'h28)    );
        okWireOut wo29 (    .ep_datain(v_neuron1[31:16]),  .ok1(ok1),  .ok2(ok2x[9*17 +: 17]), .ep_addr(8'h29)   );    
        
        okWireOut wo2a (    .ep_datain(population_neuron1[15:0]),  .ok1(ok1),  .ok2(ok2x[10*17 +: 17]), .ep_addr(8'h2a)    );
        okWireOut wo2b (    .ep_datain(population_neuron1[31:16]),  .ok1(ok1),  .ok2(ok2x[11*17 +: 17]), .ep_addr(8'h2b)   );    
        
        okWireOut wo2c (    .ep_datain(spike_count_neuron1[15:0]),  .ok1(ok1),  .ok2(ok2x[12*17 +: 17]), .ep_addr(8'h2c)    );
        okWireOut wo2d (    .ep_datain(spike_count_neuron1[31:16]),  .ok1(ok1),  .ok2(ok2x[13*17 +: 17]), .ep_addr(8'h2d)   );    
        
        okWireOut wo2e (    .ep_datain(I_synapse0[15:0]),  .ok1(ok1),  .ok2(ok2x[14*17 +: 17]), .ep_addr(8'h2e)    );
        okWireOut wo2f (    .ep_datain(I_synapse0[31:16]),  .ok1(ok1),  .ok2(ok2x[15*17 +: 17]), .ep_addr(8'h2f)   );    
        
        okWireOut wo30 (    .ep_datain(emg0[15:0]),  .ok1(ok1),  .ok2(ok2x[16*17 +: 17]), .ep_addr(8'h30)    );
        okWireOut wo31 (    .ep_datain(emg0[31:16]),  .ok1(ok1),  .ok2(ok2x[17*17 +: 17]), .ep_addr(8'h31)   );    
        

        // Spike Counter spike_counter0 Instance Definition
        spike_counter spike_counter0(
            .clk(neuron_clk),
            .reset(reset_global),
            .spike_in(each_spike_neuron0), 
            .spike_count( spike_count_neuron0)
        );
        

        // Spike Counter spike_counter1 Instance Definition
        spike_counter spike_counter1(
            .clk(neuron_clk),
            .reset(reset_global),
            .spike_in(each_spike_neuron1), 
            .spike_count( spike_count_neuron1)
        );
        

        // Synapse synapse0 Instance Definition
        synapse synapse0(
            .clk(neuron_clk),                           // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),                       // reset synaptic weights
            .spike_in(each_spike_neuron0),             // spike from presynaptic neuron
            .postsynaptic_spike_in(each_spike_neuron1),   //spike from postsynaptic neuron
            .I_out(I_synapse0),                           // sample of synaptic current out
            .each_I(each_I_synapse0),                      // raw synaptic currents
        
            .ltp(triggered_input1),                        // long term potentiation weight
            .ltd(triggered_input2),                        // long term depression weight
            .p_delta(triggered_input3)                 // chance for decay 
        );
        

        // Synapse synapse1 Instance Definition
        synapse synapse1(
            .clk(neuron_clk),                           // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),                       // reset synaptic weights
            .spike_in(each_spike_neuron1),             // spike from presynaptic neuron
            .postsynaptic_spike_in(each_spike_neuron0),   //spike from postsynaptic neuron
            .I_out(I_synapse1),                           // sample of synaptic current out
            .each_I(each_I_synapse1),                      // raw synaptic currents
        
            .ltp(triggered_input1),                        // long term potentiation weight
            .ltd(triggered_input2),                        // long term depression weight
            .p_delta(triggered_input3)                 // chance for decay 
        );
        


        // Neuron neuron0 Instance Definition
        izneuron neuron0(
            .clk(neuron_clk),               // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),           // reset to initial conditions
            .I_in(  triggered_input0 + each_I_synapse1 ),          // input current from synapse
            .v_out(v_neuron0),               // membrane potential
            .spike(spike_neuron0),           // spike sample
            .each_spike(each_spike_neuron0), // raw spikes
            .population(population_neuron0)  // spikes of population per 1ms simulation time
        );
        


        // Neuron neuron1 Instance Definition
        izneuron neuron1(
            .clk(neuron_clk),               // neuron clock (128 cycles per 1ms simulation time)
            .reset(reset_global),           // reset to initial conditions
            .I_in(  each_I_synapse0 ),          // input current from synapse
            .v_out(v_neuron1),               // membrane potential
            .spike(spike_neuron1),           // spike sample
            .each_spike(each_spike_neuron1), // raw spikes
            .population(population_neuron1)  // spikes of population per 1ms simulation time
        );
        

        // EMG emg0 Instance Definition
        emg emg0_instance(
            .clk(sim_clk),                                // update every 1ms
            .reset(reset_global),                         // reset the emg
            .spike_count(spike_count_neuron0),  // input spike count to muscle
            .emg_out(emg0)                     // emg out
        );
        
/////////////////////// END INSTANCE DEFINITIONS //////////////////////////
endmodule
