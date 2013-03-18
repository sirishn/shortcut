#!/usr/bin/ruby

# generate an fpga-fpga testbed (32'bit number transmission)
# sirish
# hi@siri.sh

require './shortcut'

$modulename = 'uart'

i_in = TriggeredInput.new

rack = FPGARack.new
rx = UART.new
rx2 = UART.new

neuron = Neuron.new
tx = UART.new
tx2 = UART.new

spindle = Spindle.new
spindle2 = Spindle.new

rx.connect_to spindle
rx2.connect_to spindle2


i_in.connect_to neuron
neuron.connect_to tx

rx_neuron = Neuron.new
rack.connect_to rx_neuron
rx_neuron.connect_to tx2

generate_verilog