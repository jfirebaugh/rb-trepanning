class Debugger
  class CmdProcessor

    attr_reader   :aliases         # Hash[String] of command names
                                   # indexed by alias name
    attr_reader   :commands        # Hash[String] of command objects
                                   # indexed by name
    
    # Load up debugger commands from builtin and user directories
    # Sets @commands, @aliases
    def load_cmds_initialize
      @commands = {}
      @aliases = {}

      cmd_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                           'command'))
      load_debugger_commands(cmd_dir)
    end

    # Loads in debugger commands by require'ing each ruby file in the
    # 'command' directory. Then a new instance of each class of the 
    # form Debugger::xxCommand is added to @commands and that array
    # is returned.

    def load_debugger_commands(cmd_dir)
      Dir.glob(File.join(cmd_dir, '*.rb')).each do |rb| 
        require rb
      end if File.directory?(cmd_dir)
      # Instantiate each Command class found by the above require(s).
      Debugger::Command.constants.grep(/.Command$/).each do |command|
        # Note: there is probably a non-eval way to instantiate the
        # command, but I don't know it. And eval works.
        new_cmd = "Debugger::Command::#{command}.new(self)"
        cmd = self.instance_eval(new_cmd)

        # Add to list of commands and aliases.
        cc = cmd.class
        cmd_name = cc.const_get(:NAME)
        if cc.constants.member?(:ALIASES)
          aliases= cc.const_get(:ALIASES)  
          aliases.each {|a| @aliases[a] = cmd_name}
        end
        @commands[cmd_name] = cmd
      end
    end

  end
end
if __FILE__ == $0
  cmdproc = Debugger::CmdProcessor.new
  cmddir = File.join(File.dirname(__FILE__), 'command')
  cmdproc.load_cmds_initialize
  puts cmdproc.commands.keys.sort.join("\n")
  puts '=' * 20
  puts cmdproc.aliases.keys.sort.join("\n")
end
