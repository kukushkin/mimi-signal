require 'mimi/core'

# Asynchronous processing of trapped signals
#
# Example:
#   logger = Logger.new(STDOUT)
#
#   trap('INT') do
#     logger.warn 'Interrupted' # => (ThreadError) can't be called from trap context
#     # shutdown gracefully ...
#   end
#
# Solution:
#   logger = Logger.new(STDOUT)
#
#   Mimi::Signal.trap('INT') do
#     logger.warn 'Interrupted' # works!
#     # shutdown gracefully ...
#   end
#
#
module Mimi
  class Signal
    attr_reader :signal

    private

    def initialize(signal, &block)
      self.class.handlers[signal.to_sym] ||= { old_trap: nil, blocks: [] }
      self.class.handlers[signal.to_sym][:blocks].push(block)
      self.class.handlers[signal.to_sym][:old_trap] ||=
        Kernel.trap(signal) do
          puts "#{self} got signal #{signal}"
          self.class.queue << signal.to_sym
        end
      self.class.start
    end

    # Traps a signal (or multiple signals) and installs the signal handler
    #
    # @param [Array<String,Symbol>] signals
    #
    def self.trap(*signals, &block)
      signals.each { |s| new(s, &block) }
    end

    # Starts the background thread which monitors queued signals.
    # Invoked implicitly when any signal handler is installed
    #
    def self.start
      return if @thread
      @thread = Thread.new do
        loop do
          signal = queue.pop # it's blocking
          handlers[signal][:blocks].each(&:call) if handlers[signal]
        end
      end
    end

    # Stops the Mimi::Signal, untraps all trapped signals
    #
    def self.stop
      return unless @thread
      handlers.keys.each do |signal|
        Kernel.trap(signal, handlers[signal][:old_trap])
      end
      @thread.kill
      @thread = nil
      @handlers = nil
    end

    private # -ish class methods

    def self.handlers
      @handlers ||= {}
    end

    def self.queue
      @queue ||= Queue.new
    end
  end # class Signal
end # module Mimi

require_relative 'signal/version'
