shortcut
========

generate verilog code for neuromuscular circuitry using simple ruby commands

Sirish Nandyala  
<hi@siri.sh>


What is it?
-----------

The FPGA project is becoming a nightmare in its size and complexity, and 
writing the verilog modules to get data in and out of it has become a 
major timesink and an endless source of frustration.

Shortcut is an easy way to get working verilog code to program the FPGA 
instead of having to write it the long way.


How do I use it?
----------------

First, we need a way to talk to the computer. Open up a terminal and from 
inside the shortcut directory, type:

	irb
	
Let's make the simplest neural network. Tell the computer, "I don't want to 
write verilog the long way, I want to use a shortcut!"

	require 'shortcut'

Because the computer is so polite, it responds "=>true", which is its way of 
saying OK. Next, we want some neurons, so we'll use the equals sign to tell 
the computer, "Build me these neurons and those neurons!"

	these_neurons = Neuron.new
	those_neurons = Neuron.new
	
The computer must think we're pretty special; each time, it responded, "Here 
are the neurons you asked for." How sweet, maybe next time we shouldn't order 
it around like that. We'll gently say, "Computer, these neurons connect to 
those neurons. Can you help me with this?"

	these_neurons.connect_to those_neurons
	
The computer doesn't simply reply OK this time, but replies ["synapse", 0]. 
This is its way of saying, "Yes, I've also created some synapses for you, 
because I know that synapses are how neurons connect to each other." Great!
Such a helpful computer! Now that our simple network is built, all we need to 
do is put something into these neurons, so that we can see what comes out of 
those neurons. We'll ask the computer, "Give me something to put into these 
neurons."

	something = TriggeredInput.new
	something.connect_to these_neurons

"And connect those neurons to what comes out," we continue.

	what_comes_out = Output.new
	those_neurons.connect_to what_comes_out
	
Phew! Our network is done! We have something (a synaptic current) which goes 
into these neurons, these neurons go through synapses to those neurons, and 
from those neurons we can see what comes out (the synaptic current into an 
individual neuron in the population, the membrane potential of that 
individual neuron, and the spike count of the overall population). For the 
grand finale, we'll shout to the computer "Generate Verilog!"

	generate_verilog
	
Behold! An entire verilog module, from `timescale to endmodule! We didn't have 
to look through each module declaration, note each port name, check the width 
of each port, verify whether each wire of each port was declared prior to its 
use, keep track of the name, number, and address of each OpalKelly endpoint, 
pipe, and trigger, note which ports of which modules are allowed to connect to 
each other, and I could go on but it tires me just thinking about it! From 9 
easy to understand, easy to write, easy to digest lines we have hundreds of 
lines of verilog, waiting to be copied and pasted into the eager arms of your 
Xilinx ISE. Congratulations!

### Pro Tips ###

Now that you know how shortcut works, you can type your code into your 
favorite text editor (mine is TextMate) and save the file. Then to generate 
the verilog, simply type:

	ruby *filename*

To generate the verilog and save it into a file (shortcut_xem6010.v, for 
example), type:

	ruby *filename* > shortcut_xem6010.v
	
How easy was that?

What blocks can I make?
-----------------------

As of right now, the included blocks are:

* Triggered Input - a connection from the PC to the FPGA across the USB 
interface. Each value you would like to send to the FPGA requires its own 
Triggered Input. 

		TriggeredInput.new
		
* Waveform - an onboard arbitrary function generator, the waveform itself is 
piped once from the PC to the FPGA where it is locally replayed

		Waveform.new
		
* Neurons - a population of 128 neurons
			
		Neuron.new
			
* Spindles - length and velocity sensing muscle fibers 
		
		Spindle.new
		
* Output - the connection from the FPGA to the PC across the USB interface. 
Only one output block should be created at any time. Each block you want to 
receive data from connects to the same Output.

		Output.new

### Automatic Blocks ###

These blocks will be automatically generated and connected as needed. You 
should never need to create or connect one of these by hand.
 		
* Synapses - connects two or more neuron populations (created on neuron to 
neuron connection)
		
		Synapse.new
		
* Spike Counters - returns the number of spikes across a neuron population 	
(created with each new Neuron) 

		SpikeCounter.new
		
* Clock Generator - creates the ability to adjust the on the fly clock speed adjustments and any required subclocks 

		ClkGen.new


How does it work?
-----------------

Shortcut wraps the modules used for this project into individual Ruby 
classes. When we write a shortcut script, we are writing a Ruby script filled 
with these classes. Each class keeps track of its own ports, wires, and all 
that jazz. It knows what it can and cannot connect to and how to make those 
connections. In this manner, shortcut creates and stores a list of all blocks 
that have been instantiated and a netlist of sorts for how these blocks 
interconnect. All this work is done behind the scenes so that the only thing 
we, the end user, have to worry about is which blocks we want to make and 
which blocks we want to connect them to. All the bit level trivia is handled 
automatically for us.


