#! /usr/bin/ruby

# easily generate verilog to connect neurons and synapses
# Sirish Nandyala
# hi@siri.sh

require './shortcut'

def generate_network

    $modulename = 'synapse'

    i_in = TriggeredInput.new 10, "I_in", [50,6]
    
    motoneurons = Neuron.new
    i_in.connect_to motoneurons

    ia_afferent = Neuron.new
    ia_afferent.connect_from motoneurons
    
    ia_afferent.connect_to motoneurons
    
    output = Output.new
    motoneurons.connect_to output
    ia_afferent.connect_to output
    
end



if __FILE__ == $0

generate_network
generate_verilog

end
