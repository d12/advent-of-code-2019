require 'byebug';

recipe_input = File.readlines("sample_input").map(&:chomp)

ask = "FUEL"

class Recipe
  # Data is
  # {
  #   quantity: 1,
  #   metal: "FUEL",
  #   inputs: [
  #     {
  #       quantity: 3,
  #       metal: "A"
  #     },
  #     {
  #       quantity: 1,
  #       metal: "B"
  #     }
  #   ]
  # }
  def initialize(data)
    @data = data
  end

  def inputs
    @data[:inputs]
  end

  def metal
    @data[:metal]
  end

  def quantity
    @data[:quantity]
  end
end

@recipes = []
@recipe_hash = {}
recipe_input.each do |input|
  input_text, output_text = input.split("=>")
  split_input_text = input_text.split(",").map(&:strip)

  output_quantity, output_metal = output_text.split(" ")
  output_quantity = output_quantity.to_i

  inputs = split_input_text.map do |text|
    split = text.split(" ")

    {
      quantity: split[0].to_i,
      metal: split[1]
    }
  end

  data = {
    quantity: output_quantity,
    metal: output_metal,
    inputs: inputs
  }

  recipe = Recipe.new(data)
  @recipes << recipe
  @recipe_hash[data[:metal]] ||= []
  @recipe_hash[data[:metal]] << recipe
end

@fuel = 0
@og_total = 1000000000000
@total_ore = 1000000000000
@inventory = {}
things_i_need = Hash.new(0)

def fulfil_recipe(recipe)
  inputs = recipe.inputs
  inputs.each do |input|
    metal = input[:metal]
    quantity = input[:quantity]

    unless @inventory[metal] && @inventory[metal] >= quantity
      while (!@inventory[metal] || (@inventory[metal] < quantity))
        get(metal)
      end
    end

    @inventory[metal] -= quantity
  end
  @inventory[recipe.metal] ||= 0
  @inventory[recipe.metal] += recipe.quantity
end

def get(metal)
  if metal == "ORE"
    @total_ore -= 1
    if @total_ore < 0
      puts @fuel
      byebug
      exit 0
    end
    @inventory["ORE"] ||= 0
    @inventory["ORE"] += 1
    return true
  end

  recipe = @recipe_hash[metal].first
  fulfil_recipe(recipe)
end

@fuel = 0
@inventory = {}

while true do
  get("FUEL")
  @fuel += 1
end
