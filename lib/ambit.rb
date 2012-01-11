# This gem allows choose/fail (amb) style non-deterministic programming in
# Ruby
#
# Author::    Jim Wise  (mailto:jwise@draga.com)
# Copyright:: Copyright (c) 2011 Jim Wise
# License::   2-clause BSD-Style (see LICENSE[link:files/LICENSE.html])

module Ambit

  VERSION = '0.10.1'

  # A ChoicesExhausted exception is raised if the outermost choose invocation of
  # a Generator has run out of choices, indicating that no (more) solutions are possible.
  class ChoicesExhausted < StandardError
  end

  class Generator
    @@trace = 0
    # Allocate a new private Generator.  Usually not needed -- use Ambit::choose et al, instead.
    #
    # See "Private Generators" in the README for details
    def initialize
      @paths = []
      @trace = 0
    end

    # Turn on tracing (to standard error) of Ambit operations
    #
    # intended for use by Ambit::trace
    #
    # The optional level argument sets the verbosity -- if not passed, each
    # call to this method increases verbosity
    def self.trace lvl=false
      if lvl
        @@trace = lvl
      else 
        @@trace = @trace + 1
      end
    end

    # Turn off tracing (to standard error) of Ambit operations
    #
    # intended for use by Ambit::untrace
    def self.untrace
      @@trace = 0
    end

    # Clear all outstanding choices registered with this generator.
    #
    # Returns the generator to the state it was in before all choices were
    # made.  Does not rewind execution.
    def clear!
      @paths = []
    end

    # Given an enumerator, begin a generate-and-test process.
    #
    # Returns with the first member of the enumerator.  A later call to #fail!
    # on the same generator will backtrack and try the next value in the
    # enumerator, continuing from the point of this #choose as if that value
    # had been chosen originally.
    #
    # Multiple calls to #choose will nest, so that backtracking forms
    # a tree-like execution path
    #
    # calling #choose with no argument or an empty iterator 
    # is equivalent to calling #fail!
    def choose choices = []
      ch = choices.clone          # clone it in case it's modified by the caller
      ch.each do |choice|
        callcc do |cc|
          STDERR.print "choosing from " + choices.inspect + ": " if @trace > 0
          @paths.unshift cc
          STDERR.puts choice.inspect if @trace > 0
          return choice
        end
      end
      self.fail!                  # if we get here, we've exhausted the choices
    end

    alias amb choose

    # Indicate that the current combination of choices has failed, and roll execution back
    # to the last #choose, continuing with the next choice.
    def fail!
      raise ChoicesExhausted.new if @paths.empty?
      cc = @paths.shift
      # if it quacks (or can be called) like a duck, call it -- it's either a Proc
      # from #mark or a Continuation from #choose
      cc.call
    end

    # Fail unless a condition holds.
    def assert cond
      fail! unless cond
    end

    alias require assert

    # Begin a mark/cut pair to commit to one branch of the current #choose operation.
    #
    # See "Marking and Cutting" in README for details
    def mark 
      @paths.unshift Proc.new {self.fail!}
    end

    # Remove the most recent mark
    #
    # See "Marking and Cutting" in README for details
    def unmark!
      STDERR.puts "unmark!" if @trace > 0
      return if @paths.empty?
      n = @paths.rindex {|x| x.instance_of? Proc}
      n and @paths.delete_at(n)
    end

    # Remove all marks
    #
    # See "Marking and Cutting" in README for details
    def unmark_all!
      STDERR.puts "unmark_all!" if @trace > 0
      return if @paths.empty?
      @paths = @paths.reject {|x| x.instance_of? Proc}
    end

    # Commit to all choices since the last #mark operation.
    #
    # See "Marking and Cutting" in README for details
    def cut!
      STDERR.puts "cut!" if @trace > 0
      return if @paths.empty?
      # rewind paths back to the last mark
      @paths = @paths.drop_while {|x| x.instance_of? Continuation}
      # drop up to one mark
      @paths = @paths.drop(1) unless @paths.empty?
    end
  end

  # Turn on tracing (to standard error) of Ambit operations
  #
  # See ``Watching Ambit Work'' in README.rdoc
  #
  # The optional level argument sets the verbosity -- if not passed, each
  # call to this method increases verbosity
  def self.trace lvl = false
    Generator::trace lvl
  end

  # Turn off tracing (to standard error) of Ambit operations
  #
  # See ``Watching Ambit Work'' in README.rdoc
  #
  def self.untrace
    Generator::untrace
  end

  # forward method invocations on this module to the default Generator.
  def self.method_missing(sym, *args, &block) # :nodoc:
    Ambit::Default_Generator.send(sym, *args, &block)
  end

  # The default generator used by Ambit.choose, Ambit.fail!, et al.
  # should not be used directly.
  Default_Generator = Generator.new

end
