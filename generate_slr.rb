#! /usr/bin/ruby

# generate verilog of short latency reflex
# Sirish Nandyala
# hi @ siri.sh

require './shortcut'

$modulename = 'slr'

motor_command = TriggeredInput.new 10, "I_in", [50,6]

#muscle = Muscle.new
spindle = Spindle.new
waveform = Waveform.new

motoneurons = Neuron.new
ia_afferent = Neuron.new "Ia"

#waveform.connect_to muscle
waveform.connect_to spindle

motor_command.connect_to motoneurons
#motoneuron.connect_to muscle

spindle.connect_to ia_afferent
ia_afferent.connect_to motoneurons

emg = EMG.new
motoneurons.connect_to emg
    
output = Output.new
motoneurons.connect_to output
ia_afferent.connect_to output
emg.connect_to output
spindle.connect_to output
waveform.connect_to output


generate_verilog
