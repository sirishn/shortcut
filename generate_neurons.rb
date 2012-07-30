#! /usr/bin/ruby

# easily generate verilog to connect neurons and synapses
# Sirish Nandyala
# hi@siri.sh

require 'shortcut'

def generate_network

    $modulename = 'synapse'

    i_in = TriggeredInput.new [50,6], "32'd10240", "I_in"
    
    motoneurons = Neuron.new
    i_in.connect_to motoneurons

    ia_afferent = Neuron.new
    ia_afferent.connect_from motoneurons
    
    
end



if __FILE__ == $0

generate_network
generate_verilog

end
