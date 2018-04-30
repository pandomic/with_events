# frozen_string_literal: true

module WithEvents
  class Event
    attr_reader :name, :condition, :callback, :options

    def initialize(name, klass, options = {})
      @name = name
      @klass = klass
      @options = options
      @condition = options[:condition]
      @callback = options[:callback]
      @stream = options[:stream]

      define_condition
      define_callback
    end

    private

    attr_reader :klass, :stream

    def define_condition
      klass.instance_exec(name, condition) do |name, condition|
        define_method("may_#{name}?") do
          WithEvents::Invoker.new(condition).invoke(self)
        end
      end
    end

    def define_callback
      klass.instance_exec(name, stream, callback) do |name, stream, callback|
        define_method("#{name}!") do
          stream&.notify(name, self)
          WithEvents::Invoker.new(callback).invoke(self)
        end
      end
    end
  end
end
