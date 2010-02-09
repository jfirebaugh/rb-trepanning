class Debugger
  class CmdProcessor
    # Command processor hooks.
    attr_reader :autoirb_hook

    class Hook
      attr_accessor :list

      def initialize(list=[])
        @list = list
      end

      def <<(name, hook)
        @list << [name, hook]
      end

      def delete_by_name(delete_name)
        @list.delete_if {|hook_name, hook| hook_name == delete_name}
      end

      def empty?
        @list.empty?
      end

      def insert(index, name, hook)
        @list.insert(index, [name, hook])
      end

      def insert_if_new(index, name, hook)
        @list.insert(index, [name, hook]) unless
          @list.find {|try_name, hook| try_name == name}
      end

      # Run each function in `hooks' with args
      def run(*args)
        @list.each do |name, hook| 
          hook.call(name, *args) 
        end
      end

      # Could add delete_at and delete if necessary.
    end
  end
end
if __FILE__ == $0
  # Demo it.
  hooks = Debugger::CmdProcessor::Hook.new
  hooks.run(5)
  hook1 = Proc.new {|name, a| puts "#{name} called with #{a}"}
  hooks = Debugger::CmdProcessor::Hook.new()
  hooks.insert(-1, 'hook1', hook1)
  p hooks.list
  hooks.insert_if_new(-1, 'hook1', hook1)
  puts '-' * 30
  p hooks.list
  hooks.run(10)
  puts '-' * 30
  hooks.insert(-1, 'hook2', hook1)
  hooks.run(20)
  puts '-' * 30
  hooks.delete_by_name('hook2')
  hooks.run(30)
end
