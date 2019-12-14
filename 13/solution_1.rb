require 'byebug'
require 'io/console'

# Just a map
# It can write to a coord, read a coord
# And print to stdout.
class Map
  attr_reader :ball_x, :paddle_x

  def initialize
    @map = []

    @ball_x = 0
    @paddle_x = 0

    @biggest_x = 0
    @biggest_y = 0
  end

  def num_blocks
    @map.flatten.count do |a|
      a == 2
    end
  end

  def write(x, y, val)
    @biggest_x = x if x > @biggest_x
    @biggest_y = y if y > @biggest_y

    if val == 4
      @ball_x = x
    elsif val == 3
      @paddle_x = x
    end

    @map[x] ||= []
    @map[x][y] = val
  end

  def read(x, y)
    return 0 unless @map[x]
    @map[x][y] || 0
  end

  def char_for_code(code)
    case code
    when 0
      " "
    when 1
      "@"
    when 2
      "*"
    when 3
      "_"
    when 4
      "o"
    end
  end

  def print_map
    (@biggest_y+1).times do |i|
      (@biggest_x+1).times do |j|
        print(char_for_code(read(j, i)))
      end
      puts
    end
  end
end

class Compiler
  attr_reader :score

  def initialize(input:, program:)
    @map = Map.new
    @opcodes_to_procs = {}
    @input = input
    @instruction_pointer = 0
    @program = program
    @program[0] = 2
    @relative_base = 0
    @outputs = []
    @first = true
    @score = 0

    register(1, ->(a, b, pointer){ write(pointer, a + b)})
    register(2, ->(a, b, pointer){ write(pointer, a * b)})
    register(3, ->(pointer)      { write(pointer, joystick) })
    register(4, ->(a)            do
       @outputs << a
       if @outputs.length == 3
         write_to_map
         @outputs = []
       end
    end)
    register(5, ->(a, pointer)   { set_instruction_pointer(pointer) if a != 0 })
    register(6, ->(a, pointer)   { set_instruction_pointer(pointer) if a == 0 })
    register(7, ->(a, b, pointer){ write(pointer, a < b ? 1 : 0)})
    register(8, ->(a, b, pointer){ write(pointer, a == b ? 1 : 0)})
    register(9, ->(a)            { @relative_base += a })
    register(99, ->()            { @halted = true })
  end

  def joystick
    sleep 0.1
    if @first
      0
      @first = nil
    end
    @map.print_map

    @map.ball_x <=> @map.paddle_x
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

  def write_to_map
    x, y, tile_id = @outputs

    if x == -1 && y == 0
      @score = tile_id
    else
      @map.write(x, y, tile_id)
    end
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
compiler = Compiler.new(input: 2, program: program)

compiler.run
puts compiler.score
