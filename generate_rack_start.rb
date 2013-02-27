#!/usr/bin/ruby

# generate an fpga-fpga testbed
# Sirish Nandyala
# hi@siri.sh

require './shortcut'

def generate_network
  
  $modulename = 'rack_start'
  
  i_in = TriggeredInput.new 10, "I_in", [50,6]
  
  neurons = Neuron.new
  i_in.connect_to neurons
  
  output = Output.new
  rack = FPGARack.new
  
  neurons.connect_to output
  neurons.connect_to rack
  
end

if __FILE__ == $0
  
  generate_network
  generate_verilog

end