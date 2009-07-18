class Debugger
  class CmdProcessor
    def initialize()
      @event    = nil
      @frame    = nil
      @prompt   = '(rdbgr): '
      # Load up debugger commands. Sets @commands
      load_debugger_commands 
    end

    def debug_eval(str)
      begin
        b = @frame.binding if @frame 
        b ||= binding
        eval(str, b)
      rescue StandardError, ScriptError => e
#         if Command.settings[:stack_trace_on_error]
#           at = eval("caller(1)", b)
#           print "%s:%s\n", at.shift, e.to_s.sub(/\(eval\):1:(in `.*?':)?/, '')
#           for i in at
#             print "\tfrom %s\n", i
#           end
#         else
#           print "#{e.class} Exception: #{e.message}\n"
#         end
#         throw :debug_error
        errmsg "#{e.class} Exception: #{e.message}\n"
      end
    end

    def errmsg(message)
      puts "Error: #{message}"
    end

    def msg(message)
      puts message
    end

    def process_command()
      str = read_command()
      args = str.split
      return false if args.size == 0
      cmd_name = args[0]
      @commands[cmd_name].run(args) if @commands[cmd_name]
      return true if !str || 'q' == str.strip
      puts debug_eval(str)
      return false
    end

    def process_commands(frame=nil)
      @frame = frame
      leave_loop = false
        while not leave_loop do
          leave_loop = process_command()
        end
    rescue IOError, Errno::EPIPE
    rescue Exception
      puts "INTERNAL ERROR!!! #{$!}\n" rescue nil
    end

    def read_command()
      require 'readline'
      Readline.readline(@prompt)
    end

    # Loads in debugger commands by requiring each file in the
    # 'command' directory. Then a new instance of each class of the 
    # form Debugger::xxCommand is added to @commands and that array
    # is returned.
    def load_debugger_commands
      cmd_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                           'command'))
      Dir.chdir(cmd_dir) do
        # Note: require_relative doesn't seem to pick up the above
        # chdir.
        Dir.glob('*.rb').each { |rb| require File.join(cmd_dir, rb) }
      end if File.directory?(cmd_dir)
      # Instantiate each Command class found by the above require(s).
      @commands = {}
      @aliases = {}
      Debugger.constants.grep(/.Command$/).each do |command|
        # Note: there is probably a non-eval way to instantiate the command, but I don't
        # now it. And eval works.
        cmd = Debugger.instance_eval("Debugger::#{command}.new")

        # Add to list of commands and aliases.
        cmd_name = cmd.name_aliases[0]
        aliases= cmd.name_aliases[1..-1]
        @commands[cmd_name] = cmd
        aliases.each {|a| @aliases[a] = cmd_name}
      end
    end
  end
end

if __FILE__ == $0
  dbg = Debugger::CmdProcessor.new()
  dbg.msg('cmdproc main')
  dbg.errmsg('Whoa!')
  p dbg.instance_variable_get('@commands')
  p dbg.instance_variable_get('@aliases')

  if ARGV.size > 0
    dbg.msg('Enter "q" to quit')
    dbg.process_commands
  else
    $input = []
    class << dbg
      def read_command
        $input.shift
      end
    end
    $input = ['1+2']
    dbg.process_command
  end
end
