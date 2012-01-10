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

def colorize map
  # map from country to its color
  colorized = {}
  map.each do |country, neighbors|
    local_colorized = colorized.clone # fake a functional view of colorized
    color = Ambit.choose Colors
    puts "considering #{color} for #{country}"
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

def colorize_map map
  colorized = colorize map
  check map, colorized

  colorized.each do |country, color|
    puts "#{country} => #{color}"
  end
end

# colorize_map Example
colorize_map BackTrack
# colorize_map ThreeByThree
# colorize_map WesternEurope
