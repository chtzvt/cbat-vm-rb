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

            @exec_ctx = :eof if @instructions[@current_instr].nil?

            case @instructions[@current_instr]
            when TerminateInstruction
                @exec_ctx = :terminated
            when LabelInstruction
                @label_lt.store(@instructions[@current_instr].args[0], @current_instr)
            when GotoInstruction
                @current_instr = @instructions[@current_instr].target
                @exec_ctx = :running
            when BreakpointInstruction
                @exec_ctx = :breakpoint
                debugger
                @exec_ctx = :running
                puts ">>> Debugger exits. Bye!"
            when IfEqualInstruction, IfNotEqualInstruction, IfFileExistsInstruction, IfNotFileExistsInstruction
                @current_instr = @instructions[@current_instr].target.nil? ? @current_instr : @instructions[@current_instr].target
                @exec_ctx = :running
            end


            @instructions[@current_instr].exec() unless @instructions[@current_instr].nil?
            # Likely cause of bugs
            # Not every instruction advances the program counter
            # It's probably better to handle this in an else clause of the above case, 
            # and individually for special case instrs that do increment the pc.
            @current_instr += 1
        end 
    end
end
