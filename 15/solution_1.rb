require 'byebug'
require 'io/console'

# Just a map
# It can write to a coord, read a coord
# And print to stdout.
class Map
  attr_reader :ball_x, :paddle_x

  def initialize
    @map = []

    @biggest_x = 0
    @biggest_y = 0
  end

  def write(x, y, val)
    @biggest_x = x if x > @biggest_x
    @biggest_y = y if y > @biggest_y
    @map[x] ||= []
    @map[x][y] = val
  end

  def read(x, y)
    return 0 unless @map[x]
    @map[x][y] || 0
  end

  def print_map
    (@biggest_y+1).times do |i|
      (@biggest_x+1).times do |j|
        print(read(j, i))
      end
      puts
    end
  end
end

class Compiler
  attr_reader :score

  def initialize(program:)
    @map = Map.new
    @opcodes_to_procs = {}
    @instruction_pointer = 0
    @program = program
    @relative_base = 0
    @outputs = []
    @last_move = nil
    @x = 30
    @y = 30

    register(1, ->(a, b, pointer){ write(pointer, a + b)})
    register(2, ->(a, b, pointer){ write(pointer, a * b)})
    register(3, ->(pointer)      do
      move = rand(4) + 1
      @last_move = move
      write(pointer, move)
    end)

    register(4, ->(a)            do
      new_coord = coord_after_moving(@last_move)
      case a
      when 0 # wall
        @map.write(*new_coord, "#")
      when 1 # moved
        @x = new_coord[0]
        @y = new_coord[1]

        @map.write(*new_coord, " ")
      when 2 # moved AND hit oxygen
        @map.write(*new_coord, "@")
        @halted = true
      end
    end)
    register(5, ->(a, pointer)   { set_instruction_pointer(pointer) if a != 0 })
    register(6, ->(a, pointer)   { set_instruction_pointer(pointer) if a == 0 })
    register(7, ->(a, b, pointer){ write(pointer, a < b ? 1 : 0)})
    register(8, ->(a, b, pointer){ write(pointer, a == b ? 1 : 0)})
    register(9, ->(a)            { @relative_base += a })
    register(99, ->()            { @halted = true })
  end

  def run
    while !@halted
      run_instruction
    end
  end

  def register(opcode, proc)
    @opcodes_to_procs[opcode] = proc
  end

  private

  def coord_after_moving(direction)
    x = @x.dup
    y = @y.dup

    case direction
    when 1
      y -= 1
    when 2
      y += 1
    when 3
      x -= 1
    when 4
      x += 1
    end

    [x, y]
  end

  def run_instruction
    opcode, *pmodes = parse_first_value(pop_instruction.to_s)
    proc = @opcodes_to_procs[opcode]
    arity = proc.arity

    args = arity.times.map do |i|
      pmode = pmodes[i] || 0

      instruction = pop_instruction
      case pmode
      when 0
        if i == 2 || opcode == 3
          instruction
        else
          @program[instruction] ||= 0
        end
      when 1
        instruction
      when 2
        if opcode == 3 || i == 2
          instruction + @relative_base
        else
          @program[instruction + @relative_base] ||= 0
        end
      end
    end

    ret = instance_exec *args, &proc
  end

  def pop_instruction
    val = @program[@instruction_pointer] ||= 0
    @instruction_pointer += 1

    val
  end

  def parse_first_value(value)
    opcode = (value[-2..-1] || value[-1]).to_i
    p_mode_1 = value[-3].to_i
    p_mode_2 = value[-4].to_i
    p_mode_3 = value[-5].to_i

    [opcode, p_mode_1, p_mode_2, p_mode_3]
  end

  def write(pointer, value)
    @program[pointer] = value
  end

  def set_instruction_pointer(new_address)
    @instruction_pointer = new_address
  end
end

program = File.read("input").chomp.split(",").map(&:to_i)
compiler = Compiler.new(program: program)

compiler.run
map = compiler.instance_variable_get(:@map)
map.write(30, 30, "S")
map.print_map

# This code doesn't solve the problem
# After printing, I sat down and solved the maze manually, and counted steps along the way.
