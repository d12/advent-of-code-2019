require 'byebug'

raw_input = File.read("sample_input").chomp.chars.map(&:to_i)

@hash = {}

# n - nth element in the pattern, 0 indexed
# output_index - the output index we're on, which determines how the pattern repeats
def nth_pattern_element(n, output_index)
  # This is lazy, but it works

  hash_key = "#{output_index}"

  output_index += 1
  base_pattern = if @hash[hash_key]
    @hash[hash_key]
  else
    pattern = []
    output_index.times { pattern << 0 }
    output_index.times { pattern << 1 }
    output_index.times { pattern << 0 }
    output_index.times { pattern << -1 }
    @hash[hash_key] = pattern
  end



  base_pattern[n % base_pattern.length]
end

def fft(input)
  length = input.length
  output = []

  input.each_with_index do |num, index|
    numbers = input.each_with_index.map do |inner_num, i|
      pattern_num = nth_pattern_element(i + 1, index)
      inner_num * pattern_num
    end

    output << ((numbers.sum.abs) % 10)
  end

  output
end

def do_phases(num, input)
  last_input = input
  num.times do |i|
    puts i
    last_input = fft(last_input)
  end

  last_input
end

puts do_phases(100, raw_input).join
