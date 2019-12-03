require 'byebug'
input = File.read("input").lines.map(&:chomp)

wire_a = input[0].split(",")
wire_b = input[1].split(",")

# store path of wire_a in hash, then for each place wire_b touches, check if it exists in the hash
hash = {}
collisions = []

wire_a_x = 0
wire_a_y = 0
wire_a.each do |instruction|
  x_diff = 0
  y_diff = 0

  case instruction.chars.first
  when "U"
    y_diff = 1
  when "D"
    y_diff = -1
  when "R"
    x_diff = 1
  when "L"
    x_diff = -1
  end

  num = instruction[1..-1].to_i
  num.times do |i|
    wire_a_x += x_diff
    wire_a_y += y_diff

    hash[[wire_a_x, wire_a_y]] = true
  end
end

wire_b_x = 0
wire_b_y = 0
wire_b.each do |instruction|
  x_diff = 0
  y_diff = 0

  case instruction.chars.first
  when "U"
    y_diff = 1
  when "D"
    y_diff = -1
  when "R"
    x_diff = 1
  when "L"
    x_diff = -1
  end

  num = instruction[1..-1].to_i
  num.times do |i|
    wire_b_x += x_diff
    wire_b_y += y_diff

    if hash[[wire_b_x, wire_b_y]] == true
      # This is a collision
      # Manhattan distance is just x.abs + y.abs
      collisions << (wire_b_x.abs + wire_b_y.abs)
    end
  end
end

puts collisions
puts collisions.min
