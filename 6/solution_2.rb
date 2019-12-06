class Node
  attr_reader :children, :name
  attr_accessor :path

  def initialize(name)
    @children = {}
    @name = name

    # Used for calculating shortest path between two nodes.
    @path = []
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

def populate_paths(node, path)
  node.path = path
  path << node.name

  node.children.values.each do |child|
    populate_paths(child, path.dup)
  end
end

start = hash["COM"]
populate_paths(start, [])

you_path = hash["YOU"].path
san_path = hash["SAN"].path

# Figure out common ancestor
common_ancestor = nil
you_path.count.times do |i|
  next if you_path[i] == san_path[i]
  common_ancestor = i
  break
end

puts you_path.length + san_path.length - (2 * common_ancestor) - 2
