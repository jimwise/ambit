# This gem allows choose/fail (amb) style non-deterministic programming in
# Ruby
#
# Author::    Jim Wise  (mailto:jwise@draga.com)
# Copyright:: Copyright (c) 2011 Jim Wise
# License::   2-clause BSD-Style (see LICENSE[link:files/LICENSE.html])

module Nondeterminism

  VERSION = '0.9.0'

  # A ChoicesExhausted exception is raised if the outermost choose invocation of
  # a Generator has run out of choices, indicating that no (more) solutions are possible
  class ChoicesExhausted < StandardError
  end

  class Generator
    def initialize
      @paths = []
    end

    def clear!
      @paths = []
    end

    # choose -- given an enumerator, begin a generate-and-test process.
    #   this method returns with the first member of the enumerator
    #   a later call to fail! on the same generator will backtrack and
    #   try the next value in the enumerator.
    #   Multiple calls to choose will nest, so that backtracking forms
    #   a tree-like execution path
    def choose choices = []
      ch = choices.clone          # clone it in case it's modified by the caller
      ch.each do |choice|
        callcc do |cc|
          @paths.unshift cc
          return choice
        end
      end
      self.fail!                  # if we get here, we've exhausted the choices
    end

    alias amb choose

    def fail!
      raise ChoicesExhausted.new if @paths.empty?
      cc = @paths.shift
      # if it quacks (or can be called) like a duck, call it -- it's either a Proc from #mark or a Continuation from #choose
      cc.call
    end

    def require cond
      fail! unless cond
    end

    alias assert require

    def mark 
      @paths.unshift Proc.new {self.fail!}
    end

    def cut!
      return if @paths.empty?
      # rewind paths back to the last mark
      @paths = @paths.drop_while {|x| x.instance_of? Continuation}
      # drop up to one mark
      @paths = @paths.drop(1) unless @paths.empty?
    end
  end

  Default_Generator = Generator.new # :nodoc:

  def Nondeterminism::method_missing(sym, *args, &block) # :nodoc:
    Nondeterminism::Default_Generator.send(sym, *args, &block);
  end

end

# For convenience, ND is an alias for the NonDeterminism module
ND = Nondeterminism # :nodoc:
