class Debugger
  class CmdProcessor

    DEFAULT_SETTINGS = {
      :autoeval      => true,      # Ruby eval non-debugger commands
      :autoirb       => false,     # Go into IRB in debugger command loop
      :autolist      => false,     # Run 'list' 

      :basename      => false,     # Show basename of filenames only
      :btlimit       => 16,        # backtrace limit
      :different     => 'nostack', # stop *only* when  different position? 

      :debugexcept   => true,      # Internal debugging of command exceptions
      :debugskip     => false,     # Internal debugging of step/next skipping
      :debugstack    => false,     # How hidden outer debugger stack frames

      :listsize      => 10,        # Number of lines in list 
      :maxstring     => 150,       # Strings which are larger than this
                                   # will be truncated to this length when
                                   # printed
      :prompt        => '(rbdbgr): ',
      :trace         => false, # event tracing
      :width         => (ENV['COLUMNS'] || '80').to_i,
    } unless defined?(DEFAULT_SETTINGS)
  end
end

if __FILE__ == $0
  # Show it:
  require 'pp'
  PP.pp(Debugger::CmdProcessor::DEFAULT_SETTINGS)
end
