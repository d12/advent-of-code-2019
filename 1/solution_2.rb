inputs = File.read("input").lines.map(&:to_f)
sum = 0

inputs.each do |i|
  value = i
  while value > 0
    fuel = (value/3).to_i - 2

    break if fuel <= 0

    sum += (value = fuel)
  end
end

puts sum
