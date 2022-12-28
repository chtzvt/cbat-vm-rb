require './util'
require './state'
require './instructions'
require './cbat'
require './debugger'

class Program
    include CBATLoader
    include Debugger
    attr_accessor :current_instr, :prev_instr

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
            @prev_instr = @current_instr.dup

            if @debug_log_enable and @current_instr == @entry_point
                @debug_step = true
                debug
            end

            if @debug_step
                puts "[step] #{@current_instr} | #{@instructions[@current_instr].to_cbat}" 
            end

            case @instructions[@current_instr]
            when TerminateInstruction
                @exec_ctx = :terminated
            when LabelInstruction
                @label_lt.store(@instructions[@current_instr].args[0], @current_instr)
            when GotoInstruction
                @current_instr = @instructions[@current_instr].target(@current_instr)
                @exec_ctx = :running
            when BreakpointInstruction
                debug
            when IfEqualInstruction, IfNotEqualInstruction, IfFileExistsInstruction, IfNotFileExistsInstruction
                branch_target = @instructions[@current_instr].target(@current_instr)
                unless branch_target.nil? 
                    @prev_instr = @current_instr
                    @current_instr = branch_target
                    puts "[debug] set new branch target #{branch_target} (prev #{@prev_instr})" if @debug_log_enable
                    next
                end 
            end

            @instructions[@current_instr].exec() unless @instructions[@current_instr].nil?

            @current_instr += 1
        end
        puts @exec_ctx 
    end
end
