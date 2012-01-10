#!/usr/bin/ruby

require 'nondeterminism'

# This solution to the N queens problem is inspired by that given
#
# Sterling, Leon and Ehud Shapiro, The Art of Prolog, MIT Press, 1994
#   http://www.amazon.com/Art-Prolog-Second-Programming-Techniques/dp/0262193388
#
# but is less elegant, as this is not prolog (and I am not Sterling or Shapiro)
#
# we want to place N queens on an NxN chess board.  Since we know no two queens
# can be in the same row, an array of N integers between 0 and N-1 will do to
# represent the placement.  Since we know no two queens can be in the same column,
# each number from 1 .. N will appear once in this array;  this means the solution
# is a permutation of 1 .. N

# Here is the actual board generator.  Next is the test if a position is safe.  All else
# in this file is for display or testing.
$nd = Nondeterminism::Generator.new
def queens n, board = []
  if board.size == n
    board
  else
    c = $nd.choose(1..n)
    $nd.fail! unless safe board, c
    queens n, board + [c]
  end
end

# board is the first M columns of an NxN board, and is valid so far.
# piece is a proposed piece for the M+1th row of the board.
# returns true if piece is a valid placement, false otherwise
def safe board, piece
  board.each_with_index do |c, r|
    return false if c == piece  # same column
    # they're on the same diagonal if the distance in columns == the distance in rows
    rdist = board.size - r;
    cdist = (piece - c).abs
    return false if rdist == cdist
  end
  true
end

# Alternator is an infinite enumerables which flipflops between two values
# We use these to define an odd row and an even row as
# [" ", ".", " ", ...] and [".", " ", ".", ...], respectively.
# With these at our disposal, we can break off as many squares as we need to draw
# an even or odd board row of any size
class Alternator
  include Enumerable
  def initialize first, second
    @first, @second = first, second
  end

  def each
    loop do
      yield @first
      yield @second
    end
  end
end

E = Alternator.new " ", "."
O = Alternator.new ".", " "

# return a blank board of a given size, as an array of N strings of length N
def empty_board n
  (1..n).collect do |i|
    ((i+1).odd? ? O : E).take(n).to_s
  end
end
# board is a board in the above format (array where a[i] is the column
# number of the queen in row i+1, rows and columns being numbered from 1

# n, if provided, is the size of the full board.  This allows this routine
# to show a partly-filled board by passing n > board.size, though we don't
# currently use this.
def board_to_s board, n = board.size
  b = empty_board n
  board.each_with_index do |x, i|
    b[i][x-1] = 'Q'
  end
  b.join "\n"
end

def show_board board
  puts board_to_s board
end

# tests:
# show_board (1..8).to_a
# puts ""
# show_board [1, 3, 5, 7, 2, 4, 6, 8]
raise "board_to_s failed" unless board_to_s([1,2]) == "Q.\n.Q";

# tests:
raise "safe failed" if safe([1, 3, 5], 3);
raise "safe failed" unless safe([1, 3, 5], 2);
raise "safe failed" if safe([1, 3, 5], 4);

# to run one board
#show_board queens 8

# to show all valid 8x8 boards:
args = ARGV.empty? ? ["8"] : ARGV
args.each do |a|
  begin
    n = a.to_i

    # state is not reset when we fail!, so count can be used to track how many times
    # we returned from `show_board queens n' below
    count = 0
    show_board queens n
    count += 1
    puts ""

    # force next solution; will throw ChoicesExhausted if none found
    $nd.fail!

  rescue Nondeterminism::ChoicesExhausted
    # thrown when we finally run out of possible boards, whether we found any valid
    # boards or not (since we unconditionally fail! above)
    puts "#{count} #{n}x#{n} boards found, not accounting for symmetry"
  end
end
