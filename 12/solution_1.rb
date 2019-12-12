require 'byebug'

moons_input = File.readlines("input").map(&:chomp)

prev_states = {}

class Moon
  attr_accessor :x, :y, :z, :vel_x, :vel_y, :vel_z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z

    @vel_x = 0
    @vel_y = 0
    @vel_z = 0
  end

  def apply_velocity
    @x += @vel_x
    @y += @vel_y
    @z += @vel_z
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def hash
    [@x, @y, @z, @vel_x, @vel_y, @vel_z].join(",")
  end

  private

  def potential_energy
    @x.abs + @y.abs + @z.abs
  end

  def kinetic_energy
    @vel_x.abs + @vel_y.abs + @vel_z.abs
  end
end

moons = []

moons_input.each do |i|
  x, y, z = /x=(-?\d+).*y=(-?\d+).*z=(-?\d+)/.match(i).captures.map(&:to_i)
  moons << Moon.new(x, y, z)
end

t = -1

while true do
  moons.each do |moon|
    # Look at each other moon and figure out velocity change required
    moons.each do |other_moon|
      next if moon == other_moon

      if other_moon.x > moon.x
        moon.vel_x += 1
      elsif other_moon.x < moon.x
        moon.vel_x -= 1
      end

      if other_moon.y > moon.y
        moon.vel_y += 1
      elsif other_moon.y < moon.y
        moon.vel_y -= 1
      end

      if other_moon.z > moon.z
        moon.vel_z += 1
      elsif other_moon.z < moon.z
        moon.vel_z -= 1
      end
    end
  end

  moons.each(&:apply_velocity)
  t += 1

  # Run the program again checking vel_x and vel_y, then GCM of the three numbers is the solution
  if moons.map(&:vel_z) == [0, 0, 0, 0]
    puts t + 1
    exit 0
  end
end

# x -> 42016
# y -> 115807
# z -> 96526
