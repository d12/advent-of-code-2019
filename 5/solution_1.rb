# With parameter mode, parameter, instruction list, gets value
def get_value(instructions, parameter, parameter_mode)
  parameter_mode == 0 ? instructions[parameter] : parameter
end

inputs = File.read("input").chomp.split(",").map(&:to_i)

pos = 0
while true
  num = inputs[pos].to_s

  opcode = num[-2..-1].to_i
  if opcode == 0
    opcode = num[-1].to_i
  end

  param_mode_1 = num[-3].to_i || 0
  param_mode_2 = num[-4].to_i || 0

  case opcode
  when 1
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)
    destination = inputs[pos+3]

    sum = arg_1 + arg_2
    inputs[destination] = sum

    pos += 4
   when 2
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)
    destination = inputs[pos+3]

    product = arg_1 * arg_2
    inputs[destination] = product
    pos += 4
  when 3
    arg_1 = inputs[pos+1]
    inputs[arg_1] = 5
    pos += 2
  when 4
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    puts arg_1
    pos += 2
  when 5
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)

    if arg_1 != 0
      pos = arg_2
    else
      pos += 3
    end
  when 6
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)

    if arg_1 == 0
      pos = arg_2
    else
      pos += 3
    end
  when 7
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)
    destination = inputs[pos+3]

    if arg_1 < arg_2
      inputs[destination] = 1
    else
      inputs[destination] = 0
    end

    pos += 4
  when 8
    arg_1 = get_value(inputs, inputs[pos+1], param_mode_1)
    arg_2 = get_value(inputs, inputs[pos+2], param_mode_2)
    destination = inputs[pos+3]

    if arg_1 == arg_2
      inputs[destination] = 1
    else
      inputs[destination] = 0
    end

    pos += 4
  when 99
    puts "Done"
    puts inputs.join(", ")
    break
  else
    puts "wtf"
  end
end
