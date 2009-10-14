# -*- coding: utf-8 -*-
require_relative %w(.. base_subsubcmd)
require_relative %w(.. base_subsubmgr)

class Debugger::SubSubcommand::ShowAuto < Debugger::SubSubcommandMgr
  unless defined?(HELP)
    HELP   = 'Show settings which some sort of "automatic" default behavior'
    NAME   = File.basename(__FILE__, '.rb')
    PREFIX = 'showauto'
  end
end

if __FILE__ == $0
  require_relative %w(.. .. mock)
  dbgr = MockDebugger::MockDebugger.new
  cmds = dbgr.core.processor.commands
  show_cmd = cmds['show']
  command = Debugger::SubSubcommand::ShowAuto.new(dbgr.core.processor, 
                                                  show_cmd)
  name = File.basename(__FILE__, '.rb')
  cmd_args = ['show', name]
  show_cmd.instance_variable_set('@last_args', cmd_args)
  # require_relative %w(.. .. .. rbdbgr)
  # dbgr = Debugger.new(:set_restart => true)
  # dbgr.debugger
  command.run(cmd_args)
end
