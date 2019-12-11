require 'byebug';
input = File.readlines("input").map(&:chomp).map(&:chars)

asteroids = []

# Find all asteroid positions
input.length.times do |i|
  input[0].length.times do |j|
    asteroids << [j, i] if input[i][j] == "#"
  end
end

# For each asteroid, check each other asteroid (oof n^2) angle (ratio of x diff / y diff)
coords = asteroids.map do |i|
  angles = {}

  asteroids.each do |j|
    next if i == j
    angle = Math.atan2(i[1] - j[1], i[0] - j[0])
    angles[angle] = true
  end

  [angles.count, i]
end

# Pick the best asteroid
max = 0
best_pos = nil
coords.each do |coord|
  if coord[0] > max
    max = coord[0]
    best_pos = coord[1]
  end
end

index = 0
while true
  angles = {}
  # First, populate angles chart
  asteroids.each do |i|
    next if i == best_pos

    angle = ((Math.atan2(best_pos[1] - i[1], best_pos[0] - i[0]) * 180 / Math::PI) - 90) % 360
    distance = (best_pos[1] - i[1]).abs + (best_pos[0] - i[0]).abs

    if angles[angle]
      if angles[angle][1] > distance
        angles[angle] = [i, distance]
      end
    else
      angles[angle] = [i, distance]
    end
  end

  # Then, PEW PEW the asteroids in order
  angles.keys.sort.each do |angle|
    index += 1
    if index == 200
      puts angle
      puts angles[angle][0]
      exit
    end

    puts asteroids.delete(angles[angle][0]).join(",")
  end
end
