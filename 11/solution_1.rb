require 'byebug'

# Le brain, the intcode computer.
class Brain
  attr_reader :robot

  def initialize(program:, robot:)
    @opcodes_to_procs = {}
    @instruction_pointer = 0
    @program = program
    @relative_base = 0
    @robot = robot
    @halted = false

    # In this problem, every _other_ output paints. So the brain keeps track of
    # whether the next output should paint or move.
    @painting = true

    register(1, ->(a, b, pointer){ write(pointer, a + b)})
    register(2, ->(a, b, pointer){ write(pointer, a * b)})
    register(3, ->(pointer)      { write(pointer, get_robot_current_color)})
    register(4, ->(a)            { paint_or_move(a) })
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

  def get_robot_current_color
    @robot.current_color
  end

  def paint_or_move(value)
    if @painting
      @robot.paint(value)
    else
      @robot.move(value == 0 ? :left : :right)
    end

    @painting = !@painting
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

# Just a map
# It can write to a coord, read a coord
# And print to stdout.
class Map
  def initialize(x, y)
    @map = []
    @map[x] = []
    @map[x][y] = 0

    @biggest_x = 0
    @biggest_y = 0

    @positions_drawn = {}
  end

  def write(x, y, val)
    @biggest_x = x if x > @biggest_x
    @biggest_y = y if y > @biggest_y

    @map[x] ||= []
    @map[x][y] = val
    @positions_drawn[[x,y]] = true
  end

  def read(x, y)
    return 0 unless @map[x]
    @map[x][y] || 0
  end

  def number_of_positions_drawn
    @positions_drawn.count
  end

  def print_map
    (@biggest_y+1).times do |i|
      (@biggest_x+1).times do |j|
        print(read(j, i) == 0 ? " " : "@")
      end
      puts
    end
  end
end

# The emergency hull painting robot. The robot and the brain work together.
class Robot
  DIRECTIONS = [:up, :right, :down, :left]

  attr_reader :map
  def initialize(program:)
    @brain = Brain.new(program: program, robot: self)
    @x = 0
    @y = 0
    @direction = :up

    @map = Map.new(@x, @y)

    # Per part 2, write the initial position white
    @map.write(@x, @y, 1)
  end

  def start
    @brain.run
  end

  def current_color
    @map.read(@x, @y)
  end

  def paint(value)
    @map.write(@x, @y, value)
  end

  def move(direction)
    index = DIRECTIONS.index(@direction)

    direction == :right ? index += 1 : index -= 1
    new_direction = DIRECTIONS[index % 4]
    @direction = new_direction

    case @direction
    when :up
      @y -= 1
    when :down
      @y += 1
    when :right
      @x += 1
    when :left
      @x -= 1
    end
  end
end

program = File.read("input").chomp.split(",").map(&:to_i)
robot = Robot.new(program: program)

robot.start
robot.map.print_map
