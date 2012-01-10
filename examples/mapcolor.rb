#!/usr/bin/ruby

require 'rubygems'
require 'ambit'

# yes, I know, no monaco, luxembourg, or andorra
WesternEurope = {
  :portugal => [:spain],
  :spain => [:france, :portugal, :andorra],
  :france => [:spain, :belgium, :germany, :switzerland, :italy, :luxembourg, :andorra],
  :belgium => [:france, :netherlands, :germany, :luxembourg],
  :netherlands => [:belgium, :germany],
  :germany => [:france, :belgium, :netherlands, :switzerland, :denmark, :austria, :luxembourg],
  :denmark => [:germany],
  :switzerland => [:france, :germany, :austria, :italy],
  :italy => [:france, :switzerland, :austria],
  :austria => [:germany, :switzerland, :italy],
  :luxembourg => [:france, :belgium, :germany],
  :andorra => [:spain, :france],
}

ThreeByThree = {
  :a => [:b, :d],
  :b => [:a, :c, :e],
  :c => [:b, :f],
  :d => [:a, :e, :g],
  :e => [:b, :d, :f, :h],
  :f => [:c, :e, :i],
  :g => [:d, :h],
  :h => [:e, :g, :i],
  :i => [:f, :h],
}

# from http://spicerack.sr.unh.edu/~student/tutorial/fourColor/FourColor.html
Example = {
  :inner => [:ne, :se, :sw, :nw],
  :ne => [:inner, :se, :nw, :outer],
  :se => [:inner, :ne, :sw, :outer],
  :sw => [:inner, :se, :nw, :outer],
  :nw => [:inner, :ne, :sw, :outer],
  :outer => [:ne, :se, :sw, :nw],
}

# Example which forces more than one level of backtrack:
# |         |
# +-------+ |
# |a|b|c|d| |
# +-------+ |
# |  e    | |
# +-------+ |
# | f |  g  |

BackTrack = {
  :a => [:b, :e, :g],
  :b => [:a, :c, :e, :g],
  :c => [:b, :d, :e, :g],
  :d => [:c, :e, :g],
  :e => [:a, :b, :c, :d, :f, :g],
  :f => [:e, :g],
  :g => [:a, :b, :c, :d, :e, :f],
}
Colors = [:red, :yellow, :blue, :green]

# when called as colorize2(map), we start from the beginning colorizing that
# map.  when recursively called as colorize2(map, countries, colorized),
# countries are the countries left to colorize, and colorized are the
# assignments made so far.

def colorize map, countries=map.keys, colorized={}
  country=countries.first
  return colorized if country.nil?

  color = Ambit.choose Colors
  #puts "considering #{color} for #{country}"
  map[country].each {|n| Ambit.assert colorized[n] != color}

  colorized_new = colorized.clone # fake a functional view of hash
  colorized_new[country] = color
  colorize map, countries.drop(1), colorized_new
end

# an alternative version, using iteration instead of recursion
def colorize_iterating  map
  # map from country to its color
  colorized = {}
  map.each do |country, neighbors|
    local_colorized = colorized.clone # fake a functional view of colorized
    color = Ambit.choose Colors
    #puts "considering #{color} for #{country}"
    neighbors.each {|n| Ambit.assert colorized[n] != color}
    local_colorized[country] = color
    colorized = local_colorized
  end
  colorized
end


# a deterministic check, for comparison purposes
def check map, colorized
  map.each do |country, neighbors|
    color = colorized[country]
    neighbors.each do |neighbor|
      if colorized[neighbor] == color
        raise "country #{country} and neighbor #{neighbor} have the same color!"
      end
    end
  end
end

def test_map map
  colorized = colorize map
  check map, colorized

  colorized.each do |country, color|
    puts "#{country} => #{color}"
  end
end

puts "Simple example:"
test_map Example
puts ""
puts "Complex example:"
test_map BackTrack
puts ""
puts "Three-by-three grid:"
test_map ThreeByThree
puts ""
puts "Western Europe:"
test_map WesternEurope
