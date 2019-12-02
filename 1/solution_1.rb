inputs = File.read("input").lines.map(&:to_f)
sum = 0

inputs.each do |i|
  sum += (i/3).to_i - 2
end

puts sum
