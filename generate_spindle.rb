#! /usr/bin/ruby

# generate verilog to test spindle
# Sirish Nandyala
# hi@siri.sh

require 'shortcut'

$modulename = 'spindle'

gamma_dynamic = TriggeredInput.new [50,4], "32'h42A0_0000", "gamma_dynamic"
gamma_static = TriggeredInput.new [50,5], "32'h42A0_0000", "gamma_static"

bdamp_1 = TriggeredInput.new [50,15], "32'h3E71_4120", "BDAMP_1"
bdamp_2 = TriggeredInput.new [50,14], "32'h3D14_4674", "BDAMP_2"
bdamp_chain = TriggeredInput.new [50,13], "32'h3C58_44D0", "BDAMP_chain"

waveform = Waveform.new

spindle = Spindle.new
waveform.connect_to spindle
gamma_dynamic.connect_to spindle
gamma_static.connect_to spindle
bdamp_1.connect_to spindle
bdamp_2.connect_to spindle
bdamp_chain.connect_to spindle

generate_verilog