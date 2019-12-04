def valid?(num)
  digits = num.digits.reverse
  groups = []

  return false unless digits.sort == digits

  digits.each do |i|
    if groups.empty? || groups.last.first != i
      # no prev match
      groups << [i, 1]
    else
      # prev match
      groups[-1][-1] += 1
    end
  end

  return groups.map{ |a| a[1] }.any?{ |a| a == 2 }
end

lower_bound = 152085
upper_bound = 670283

count = 0
(lower_bound..upper_bound).each do |num|
  count += 1 if valid?(num)
end

puts count
