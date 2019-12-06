class Compiler
  def initialize(input:, program:)
    @opcodes_to_procs = {}
    @input = input
    @instruction_pointer = 0
    @program = program
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

      # Third pmode is always 1, and for some reason, opcode 3 pmode is always 1.
      pmode = 1 if (i == 2 || opcode == 3)

      instruction = pop_instruction
      pmode == 0 ? @program[instruction] : instruction
    end

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
compiler = Compiler.new(input: 5, program: program)

compiler.register(1, ->(a, b, pointer){ write(pointer, a + b)})
compiler.register(2, ->(a, b, pointer){ write(pointer, a * b)})
compiler.register(3, ->(destination)  { write(pointer, @input)})
compiler.register(4, ->(a)            { puts a })
compiler.register(5, ->(a, pointer)   { set_instruction_pointer(pointer) if a != 0 })
compiler.register(6, ->(a, pointer)   { set_instruction_pointer(pointer) if a == 0 })
compiler.register(7, ->(a, b, pointer){ write(pointer, a < b ? 1 : 0)})
compiler.register(8, ->(a, b, pointer){ write(pointer, a == b ? 1 : 0)})
compiler.register(99, ->()            { puts "Goodbye!" ; exit 0 })

compiler.run
