require 'byebug';

inputs = File.read("input").chomp.split(",").map(&:to_i)

inputs[1] = 12
inputs[2] = 2

pos = 0
while true
  case inputs[pos]
  when 1
    arg_1 = inputs[pos+1]
    arg_2 = inputs[pos+2]
    destination = inputs[pos+3]

    sum = inputs[arg_1] + inputs[arg_2]
    inputs[destination] = sum

    pos += 4
   when 2
    arg_1 = inputs[pos+1]
    arg_2 = inputs[pos+2]
    destination = inputs[pos+3]

    product = inputs[arg_1] * inputs[arg_2]
    inputs[destination] = product
    pos += 4
  when 99
    puts "Finished!"
    puts inputs[0]
    break
  end
end
