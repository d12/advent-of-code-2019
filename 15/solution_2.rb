require 'byebug'

# Input here is the raw map file printed from solution_1
@map = File.readlines("input_2").map(&:chomp).map(&:chars)

@max_depth = 0

start_x, start_y = [42, 10]

def flood_fill(x, y, depth)
  if depth > @max_depth
    @max_depth = depth
  end

  if @map[x][y+1] == " "
    @map[x][y+1] = "F"
    flood_fill(x, y+1, depth+1)
  end

  if @map[x][y-1] == " "
    @map[x][y-1] = "F"
    flood_fill(x, y-1, depth+1)
  end

  if @map[x+1][y] == " "
    @map[x+1][y] = "F"
    flood_fill(x+1, y, depth+1)
  end

  if @map[x-1][y] == " "
    @map[x-1][y] = "F"
    flood_fill(x-1, y, depth+1)
  end
end

flood_fill(start_x, start_y, 0)
puts @max_depth
