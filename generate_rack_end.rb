#!/usr/bin/ruby

# generate an fpga-fpga testbed
# Sirish Nandyala
# hi@siri.sh

require './shortcut'

def generate_network
  
  $modulename = 'rack_end'
  
  rack = FPGARack.new
  neurons = Neuron.new
  
  output = Output.new
  
  
  rack.connect_to neurons
  neurons.connect_to output

  
end

if __FILE__ == $0
  
  generate_network
  generate_verilog

end