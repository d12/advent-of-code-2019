(1..100).each do |a|
  (1..100).each do |b|
    inputs = File.read("input").chomp.split(",").map(&:to_i)

    inputs[1] = a
    inputs[2] = b

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
        puts "Done one"
        puts "#{a}, #{b}, #{inputs[0]}"
        exit if inputs[0] == 19690720
        break
      end
    end
  end
end
