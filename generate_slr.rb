#! /usr/bin/ruby

# generate verilog of short latency reflex
# Sirish Nandyala
# hi @ siri.sh

require './shortcut'

$modulename = 'slr'

motor_command = TriggeredInput.new

muscle = Muscle.new
spindle = Spindle.new
waveform = Waveform.new

motoneuron = Neuron.new
ia_afferent = Neuron.new "Ia"

#waveform.connect_to muscle
waveform.connect_to spindle

motor_command.connect_to motoneuron
#motoneuron.connect_to muscle

spindle.connect_to ia_afferent
ia_afferent.connect_to motoneuron

generate_verilog



