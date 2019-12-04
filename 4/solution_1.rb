def valid?(num)
  digits = num.digits.reverse
  doubled = false

  previous_digit = digits.first
  digits[1..-1].each do |i|
    return false if i < previous_digit
    doubled = true if i == previous_digit
    previous_digit = i
  end

  return doubled
end

lower_bound = 152085
upper_bound = 670283

count = 0
(lower_bound..upper_bound).each do |num|
  count += 1 if valid?(num)
end

puts count
