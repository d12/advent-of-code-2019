require 'byebug'

class Compiler
  def initialize(input:, program:)
    @opcodes_to_procs = {}
    @input = input
    @instruction_pointer = 0
    @program = program
    @relative_base = 0
  end

  def run
    while true
      run_instruction
    end
  end

  def register(opcode, proc)
    @opcodes_to_procs[opcode] = proc
  end

  private

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

compiler.register(1, ->(a, b, pointer){ write(pointer, a + b)})
compiler.register(2, ->(a, b, pointer){ write(pointer, a * b)})
compiler.register(3, ->(pointer)      { write(pointer, @input)})
compiler.register(4, ->(a)            { puts a })
compiler.register(5, ->(a, pointer)   { set_instruction_pointer(pointer) if a != 0 })
compiler.register(6, ->(a, pointer)   { set_instruction_pointer(pointer) if a == 0 })
compiler.register(7, ->(a, b, pointer){ write(pointer, a < b ? 1 : 0)})
compiler.register(8, ->(a, b, pointer){ write(pointer, a == b ? 1 : 0)})
compiler.register(9, ->(a) { @relative_base += a })
compiler.register(99, ->()            { puts "Goodbye!" ; exit 0 })

compiler.run
