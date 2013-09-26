# generate verilog to simulate interhemispheric competition
# reference: http://www.jneurosci.org/content/27/41/11083.full.pdf

require './shortcut'

def generate_network

  $modulename = 'ih_competition'
  
  
  # Inputs to Motor Cortex
  left_m1_in = TriggeredInput.new 10, "left_m1_in", [50,6]
  right_m1_in = TriggeredInput.new 10, "right_m1_in", [50,7]
  
  #M1 Neurons
  left_m1 = Neuron.new "left_m1", "regular"
  right_m1 = Neuron.new "right_m1", "regular"
  
  
  left_m1_in.connect_to left_m1
  right_m1_in.connect_to right_m1
  
  
  # MotoNeurons
  left_motoneuron = Neuron.new "left_motoneuron", "regular"
  right_motoneuron = Neuron.new "right_motoneuron", "regular"
  
  left_m1.connect_to right_motoneuron #Contralateral
  right_m1.connect_to left_motoneuron #contralateral
  
  left_m1.connect_to left_motoneuron #ipsilateral
  right_m1.connect_to right_motoneuron #ipsilateral
  
  
  # Data collection 
  output = Output.new
  
  left_m1.connect_to output
  right_m1.connect_to output
  left_motoneuron.connect_to output
  right_motoneuron.connect_to output

end

if __FILE__ == $0

  generate_network
  generate_verilog

end
