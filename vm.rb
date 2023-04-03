require './util'
require './state'
require './instructions'
require './cbat'
require './debugger'

class Program
    include Debugger
    
    attr_accessor :file_name, :entry_point, :version
    attr_accessor :instructions

    attr_accessor :var_lt, :subr_lt, :file_lt, :label_lt
    attr_accessor :exec_ctx, :debug_log_enable

    attr_accessor :current_instr, :prev_instr

    def initialize(var_lt, subr_lt, file_lt)
        @label_lt = LabelLookupTable.new 
        @var_lt = var_lt.nil? ? VariableLookupTable.new : var_lt
        @subr_lt = subr_lt.nil? ? SubroutineLookupTable.new : subr_lt
        @file_lt = file_lt.nil? ? FileLookupTable.new : file_lt
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
            when CallInstruction
                subroutine = @subr_lt.get(@instructions[@current_instr].target)

                if subroutine.nil?
                    puts "cbat: subroutine `#{@instructions[@current_instr].target}` not found" if @debug_log_enable
                    p @subr_lt.keys
                    @current_instr += 1
                    next 
                end

                @exec_ctx = :subroutine
                
                subroutine.run
                
                @exec_ctx = :running                
            end

            @instructions[@current_instr].exec() unless @instructions[@current_instr].nil?

            @current_instr += 1
        end
    end

    def dump_cbat
        @instructions.map do |instr|
            puts instr.to_cbat
        end
        puts "(eof)"
    end

    def dump_batch 
        puts "#{@file_name}"
        @instructions.map do |instr|
            puts instr.to_batch
        end
        puts "(eof)"
    end

    def to_cbat_file
        puts ".header"
        puts "\tfilename #{@file_name}"
        puts "\tentry #{@entry_point}"
        puts "\tver #{@version}"
        puts ".labels"
        @label_lt.map do |k,v|
            puts "\t#{k}:#{v}"
        end   
        puts ".instrs"  
        @instructions.map do |instr|
            puts "\t#{instr.to_cbat}"
        end
        puts "\t"
    end
end
