class Node
  attr_reader :children, :name

  def initialize(name)
    @children = {}
    @name = name
  end
end

lines = File.read("input").lines.map(&:chomp)
hash = {}

# Build the tree, maintaining `hash` for node lookup
lines.each do |i|
  # b orbits a
  a, b = i.split(")")

  node = hash[a] ||= Node.new(a)
  node.children[b] = hash[b] || Node.new(b)
  hash[b] ||= node.children[b]
end

# Count orbits and suborbits
def count_orbits(node, acc)
  node.children.values.map do |child|
    count_orbits(child, acc+1)
  end.sum + acc
end

start = hash["COM"]

puts count_orbits(start, 0)
