#! /usr/bin/ruby

# generate verilog to test spindle
# Sirish Nandyala
# hi@siri.sh

require './shortcut'

$modulename = 'spindle'

spindle = Spindle.new
spindle.connect_parameters  # create and connect the default parameter inputs
                            # gamma_dynamic, gamma_static, BDAMP1, BDAMP2, and BDAMP_chain

waveform = Waveform.new
waveform.connect_to spindle

output = Output.new
waveform.connect_to output
spindle.connect_to output

generate_verilog