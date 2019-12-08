file = File.read("input").chomp.chars.map(&:to_i)

layers = []

file.each_slice(150).each do |slice|
  layers << slice
end

result = Array.new(150)

layers.each do |layer|
  layer.each_with_index do |char, i|
    case result[i]
    when nil,  2
      result[i] = char
    end
  end
end

index = 0
6.times do |a|
  25.times do |b|
    print result[index]
    index += 1
  end
  puts
end

# index = 0
# lowest = 10000000
#
# layers.each_with_index do |layer, i|
#   count = layer.count{|a| a == 0}
#   if count < lowest
#     lowest = count
#     index = i
#   end
# end
#
# layer = layers[index]
#
# ones = layer.count{|a| a == 1}
# twos = layer.count{|a| a == 2}
#
# puts ones * twos
