require './util'
require './state'
require './instructions'
require './cbat'
require './debugger'

class Program
    include CBATLoader
    include Debugger
    attr_accessor :current_instr

    def initialize
        @var_lt = VariableLookupTable.new
        @label_lt = LabelLookupTable.new 
        @file_lt = FileLookupTable.new 
        @instructions = []
        @exec_ctx = :idle
    end 

    def run()
        @exec_ctx = :running 
        @current_instr = @entry_point

        while @exec_ctx == :running 
            @instructions[@current_instr].exec()

            case @instructions[@current_instr]
            when TerminateInstruction
                @exec_ctx = :terminated
            when GotoInstruction
                @current_instr = @instructions[@current_instr].target
                @exec_ctx = :running
            when BreakpointInstruction
                @exec_ctx = :breakpoint
                debugger
                @exec_ctx = :running
                puts ">>> Debugger exits. Bye!"
            end

            if @current_instr >= @instructions.length - 1
                @exec_ctx = :eof 
            end

            @current_instr += 1
        end 
    end
end
