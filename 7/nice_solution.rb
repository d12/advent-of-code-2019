require 'byebug';

class Compiler
  attr_writer :output_compiler
  attr_reader :input_queue
  attr_reader :ret

  def initialize(phase:, program:, output: nil)
    @opcodes_to_procs = {}
    @instruction_pointer = 0
    @program = program
    @ret = []
    @input_queue = [phase]
    @output_compiler = output
    @halted = false

    register(1, ->(a, b, pointer){ write(pointer, a + b)})
    register(2, ->(a, b, pointer){ write(pointer, a * b)})
    register(3, ->(pointer)      { @input_queue.empty? ? :no_input : write(pointer, @input_queue.shift) })
    register(4, ->(a)            { @ret = a ; @output_compiler.push_input(a) })
    register(5, ->(a, pointer)   { set_instruction_pointer(pointer) if a != 0 })
    register(6, ->(a, pointer)   { set_instruction_pointer(pointer) if a == 0 })
    register(7, ->(a, b, pointer){ write(pointer, a < b ? 1 : 0)})
    register(8, ->(a, b, pointer){ write(pointer, a == b ? 1 : 0)})
    register(99, ->()            { @halted = true ; })
  end

  def run
    while !@halted
      val = run_instruction
      if val == :no_input
        @instruction_pointer -= 2
        return val
      end
    end

    @ret
  end

  def register(opcode, proc)
    @opcodes_to_procs[opcode] = proc
  end

  def push_input(input)
    @input_queue.push(input)
  end

  def halted?
    @halted
  end

  private

  def run_instruction
    opcode, *pmodes = parse_first_value(pop_instruction.to_s)

    proc = @opcodes_to_procs[opcode]
    arity = proc.arity

    args = arity.times.map do |i|
      pmode = pmodes[i] || 0

      # Third pmode is always 1, and for some reason, opcode 3 pmode is always 1.
      pmode = 1 if (i == 2 || opcode == 3)

      instruction = pop_instruction
      pmode == 0 ? @program[instruction] : instruction
    end
    puts "running instruction #{opcode}"

    ret = instance_exec *args, &proc
  end

  def pop_instruction
    val = @program[@instruction_pointer]
    @instruction_pointer += 1

    val
  end

  def parse_first_value(value)
    opcode = (value[-2..-1] || value[-1]).to_i
    p_mode_1 = value[-3].to_i
    p_mode_2 = value[-4].to_i

    [opcode, p_mode_1, p_mode_2]
  end

  def write(pointer, value)
    @program[pointer] = value
  end

  def set_instruction_pointer(new_address)
    @instruction_pointer = new_address
  end
end

program = File.read("input").chomp.split(",").map(&:to_i)
# 43210

max = 0

def run_instance(a, b, c, d, e, program)
  five = Compiler.new(phase: e, program: program.dup)
  four = Compiler.new(phase: d, program: program.dup, output: five)
  three = Compiler.new(phase: c, program: program.dup, output: four)
  two = Compiler.new(phase: b, program: program.dup, output: three)
  one = Compiler.new(phase: a, program: program.dup, output: two)

  five.output_compiler = one
  one.push_input(0)

  while !five.halted?
    one.run
    two.run
    three.run
    four.run
    five.run
  end

  five.ret
  #TODO: CHECK WHEN PROGRAM IS HALTED
end

[5, 6, 7, 8, 9].permutation(5).each do |a, b, c, d, e|
  output = run_instance(a, b, c, d, e, program)

  if output > max
    max = output
  end
end

puts max
