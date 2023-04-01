require 'singleton'

class InstructionMap 
    include Singleton 

    def lookup(op)
        case op
        when "l"
            LabelInstruction.new
        when "e"
            EchoInstruction.new
        when "stp"
            SetPromptInstruction.new
        when "af"
            AppendFileInstruction.new
        when "ieq"
            IfEqualInstruction.new
        when "trm"
            TerminateInstruction.new
        when "st"
            StoreInstruction.new
        when "bp"
            BreakpointInstruction.new
        when "nop"
            NopInstruction.new
        when "g"
            GotoInstruction.new
        when "p"
            PauseInstruction.new
        when "ieq"
            IfEqualInstruction.new
        when "inq"
            IfNotEqualInstruction.new
        when "iex"
            IfFileExistsInstruction.new
        when "inx"
            IfNotFileExistsInstruction.new
        when "adi"
            NopInstruction.new
        when "sbi"
            NopInstruction.new
        when "mli"
            NopInstruction.new
        when "dvi"
            NopInstruction.new
        when "cls"
            ClearScreenInstruction.new
        when "clr"
            NopInstruction.new
        when "t"
            TypeFileInstruction.new
        when "c"
            CallInstruction.new
        else 
            NopInstruction.new
        end
    end
end

module Executable
    attr_accessor :args, :raw_args, :var_lt, :label_lt, :file_lt, :ec, :debug_enable

    def init(raw_str, var_lt, label_lt, file_lt, ec, debug_enable)
        @args = raw_str.batch_get_instr_args unless raw_str.nil?
        @raw_args = @args.clone.map(&:clone) unless raw_str.nil?
        @var_lt = var_lt
        @label_lt = label_lt
        @file_lt = file_lt 
        @ec = ec
        @debug_enable = debug_enable
    end

    def exec
        raise "Not implemented!"
    end

    def to_batch
        raise "Not implemented!"
    end

    def to_cbat
        raise "Not implemented!"
    end

    def op
        to_cbat.split(' ')[0]
    end

    def run(args, var_lt, label_lt, file_lt, pc)
        self.init(args, var_lt, label_lt, file_lt, pc)
        self.exec()
    end
end

class EchoInstruction
    include Executable

    def exec
        puts @args[0].batch_interpolate_string(@var_lt)
    end

    def to_batch
        "echo \"#{@raw_args[0]}\""
    end

    def to_cbat
        "e \"#{@raw_args[0]}\""
    end
end

class ClearScreenInstruction
    include Executable

    def exec
        puts "\e[H\e[2J" unless @debug_enable
    end

    def to_batch
        "cls"
    end

    def to_cbat
        "cls"
    end
end

class StoreInstruction
    include Executable

    def exec
        puts "[debug] store #{@args[0]}='#{@args[1]}'" if @debug_enable
        @var_lt.store(@args[0], @args[1])
    end

    def to_batch
        "set #{@raw_args[0]}=\"#{@raw_args[1]}\""
    end

    def to_cbat
        "st #{@raw_args[0]},\"#{@raw_args[1]}\""
    end
end

class SetPromptInstruction
    include Executable

    def prompt(msg)
        print(msg.batch_remove_quotes)
        STDIN.gets
    end

    def exec
        str = args[1]
        str = "Input: " if args[1].empty?
        puts "[debug] prompt store #{@args[0]}" if @debug_enable
        @var_lt.store(args[0].to_sym, prompt(str).chomp)
    end

    def to_batch
        "set /p #{@raw_args[0]}=\"#{@raw_args[1]}\""
    end

    def to_cbat
        "stp #{@raw_args[0]},\"#{@raw_args[1]}\""
    end
end

class PauseInstruction
    include Executable

    def prompt(msg)
        puts msg.batch_remove_quotes unless msg.empty?
        STDIN.gets
    end

    def exec
        if args.nil? or args[0].to_i != 0
            str = "Press any key to continue..."
        else 
            str = ""
        end 

        prompt(str).chomp
    end

    def to_batch
        if args.nil? or args[0].to_i != 0
            "pause"
        else 
            "pause>nul"
        end 
    end

    def to_cbat
        if args.nil? or args[0].to_i != 0
            "p"
        else 
            "p 0"
        end 
    end
end

class AppendFileInstruction
    include Executable

    def exec
        puts "[debug] file append #{@args[1]} '#{@args[0].batch_interpolate_string(@var_lt)}'" if @debug_enable
        @file_lt.append(@args[1], @args[0].batch_interpolate_string(@var_lt))
    end

    def to_batch
        "echo \"#{@raw_args[0]}\" >>\"#{@raw_args[1]}\""
    end

    def to_cbat
        "af \"#{@raw_args[0]}\",\"#{@raw_args[1]}\""
    end
end

class TypeFileInstruction
    include Executable

    def exec
        puts "[debug] file type #{@args[1]} '#{@args[0].batch_interpolate_string(@var_lt)}'" if @debug_enable
        print @file_lt.read(@args[0].batch_interpolate_string(@var_lt))
    end

    def to_batch
        "type \"#{@raw_args[0]}\""
    end

    def to_cbat
        "t \"#{@raw_args[0]}\""
    end
end

class IfEqualInstruction
    include Executable

    def exec
        @ec = :jump
    end

    def target(ci)
        puts "[debug] if equal compare '#{@var_lt.get(@args[0])}' to '#{@args[1].batch_interpolate_string(@var_lt)}'" if @debug_enable
        if @var_lt.get(@args[0]) == @args[1].batch_interpolate_string(@var_lt)
            if @args[1].nil?
                puts "[debug] \tif equal comparison succeeds, advancing" if @debug_enable
                ci + 1
            else 
                puts "[debug] \tif equal comparison succeeds, jumping to #{@args[2]} (#{@label_lt.get(@args[2]).to_i}" if @debug_enable
                @label_lt.get(@args[2]).to_i
            end
        else 
            if @args[1].nil?
                puts "[debug] \tif equal comparison failed without a label, advancing" if @debug_enable
                ci + 2
            else 
                puts "[debug] \tif equal comparison failed with label, advancing" if @debug_enable
                ci + 1
            end
        end
    end 

    def to_batch
        "if \"%#{@raw_args[0]}%\" EQU \"#{@raw_args[1]}\" goto #{@raw_args[2]}"
    end

    def to_cbat
        "ieq \"#{@raw_args[0]}\",\"#{@raw_args[1]}\",#{@raw_args[2]}"
    end
end

class IfNotEqualInstruction
    include Executable

    def exec
        @ec = :jump
    end

    def target(ci)
        puts "[debug] if not equal compare '#{@var_lt.get(@args[0])}' to '#{@args[1].batch_interpolate_string(@var_lt)}'" if @debug_enable
        if @var_lt.get(@args[0]) != @args[1].batch_interpolate_string(@var_lt)
            if @args[1].nil?
                puts "[debug] \tif not equal comparison succeeds, advancing" if @debug_enable
                ci + 1
            else 
                puts "[debug] \tif not equal comparison succeeds, jumping to #{@args[2]} (#{@label_lt.get(@args[2]).to_i}" if @debug_enable
                @label_lt.get(@args[2]).to_i
            end
        else 
            if @args[1].nil?
                puts "[debug] \tif not equal comparison failed without a label, advancing" if @debug_enable
                ci + 2
            else 
                puts "[debug] \tif not equal comparison failed with label, advancing" if @debug_enable
                ci + 1
            end
        end
    end 

    def to_batch
        "if \"%#{@raw_args[0]}%\" NOT EQU \"#{@raw_args[1]}\" goto #{@raw_args[2]}"
    end

    def to_cbat
        "inq \"#{@raw_args[0]}\",\"#{@raw_args[1]}\",#{@raw_args[2]}"
    end
end

class IfFileExistsInstruction
    include Executable

    def exec
        @ec = :jump
    end

    def target(ci)
        puts "[debug] if file exists '#{args[0].batch_interpolate_string(@var_lt)}'" if @debug_enable
        if @file_lt.file_exists?(args[0].batch_interpolate_string(@var_lt))
            if @args[1].nil?
                puts "[debug] \tif file exists succeeds, advancing" if @debug_enable
                ci + 1
            else 
                puts "[debug] \tif file exists succeeds, jumping to #{@args[1]} (#{@label_lt.get(@args[1]).to_i}" if @debug_enable
                @label_lt.get(@args[1]).to_i
            end
        else 
            if @args[1].nil?
                puts "[debug] \tif file exists failed without a label, advancing" if @debug_enable
                ci + 2
            else 
                puts "[debug] \tif file exists failed with label, advancing" if @debug_enable
                ci + 1
            end
        end
    end 

    def to_batch
        "if EXIST \"%#{@raw_args[0]}%\" goto #{@raw_args[1]}"
    end

    def to_cbat
        "iex \"#{@raw_args[0]}\",#{@raw_args[1]}"
    end
end

class IfNotFileExistsInstruction
    include Executable

    def exec
        @ec = :jump
    end

    def target(ci)
        puts "[debug] if file not exists '#{args[0].batch_interpolate_string(@var_lt)}'" if @debug_enable
        unless @file_lt.file_exists?(args[0].batch_interpolate_string(@var_lt))
            if @args[1].nil?
                puts "[debug] \tif file not exists succeeds, advancing" if @debug_enable
                ci + 1
            else 
                puts "[debug] \tif file not exists succeeds, jumping to #{@args[1]} (#{@label_lt.get(@args[1]).to_i}" if @debug_enable
                @label_lt.get(@args[1]).to_i
            end
        else 
            if @args[1].nil?
                puts "[debug] \tif file not exists failed without a label, advancing" if @debug_enable
                ci + 2
            else 
                puts "[debug] \tif file not exists failed with label, advancing" if @debug_enable
                ci + 1
            end
        end
    end 

    def to_batch
        "if NOT EXIST \"%#{@raw_args[0]}%\" goto #{@raw_args[1]}"
    end

    def to_cbat
        "inx \"#{@raw_args[0]}\",#{@raw_args[1]}"
    end
end

class GotoInstruction
    include Executable

    def exec
        @ec = :jump
        target
    end

    def target(cur)
        case @args[0].batch_interpolate_string(@var_lt).downcase.to_sym
        when :cbat_next
            cur + 1
        when :cbat_prev
            cur - 1
        else
            puts "[debug] goto target #{@args[0]}@#{@label_lt.get(@args[0]).to_i}" if @debug_enable
            @label_lt.get(@args[0]).to_i
        end
    end 

    def to_batch
        "goto #{@raw_args[0]}"
    end

    def to_cbat
        "g #{@raw_args[0]}"
    end
end

class CallInstruction
    include Executable

    def exec
        @ec = :subroutine
        target
    end

    def target
        puts "[debug] call target #{@args[0]}@#{@label_lt.get(@args[0]).to_i}" if @debug_enable
        @args[0].batch_interpolate_string(@subr_lt)
    end 

    def to_batch
        "call #{@raw_args[0]}"
    end

    def to_cbat
        "c #{@raw_args[0]}"
    end
end

class TerminateInstruction
    include Executable

    def exec
        puts "[debug] terminate" if @debug_enable
        @ec = :terminated
    end

    def to_batch
        "exit"
    end

    def to_cbat
        "trm"
    end
end

class BreakpointInstruction
    include Executable

    def exec
        @ec = :breakpoint
    end

    def to_cbat
        "bp"
    end

    def to_batch
        "::cbat:breakpoint"
    end
end

class LabelInstruction
    include Executable

    def exec
        puts "[debug] label def: #{@args[0]}" if @debug_enable
        ""
    end

    def to_cbat
        "l #{@raw_args[0]}"
    end

    def to_batch
        ":#{@raw_args[0]}"
    end
end   

class NopInstruction
    include Executable

    def exec
        puts "[debug] no-op" if @debug_enable
        ""
    end

    def to_cbat
        "l "
    end

    def to_batch
        "::cbat:nop"
    end
end  

class IllegalInstruction
    include Executable

    def exec
        puts "[debug] illegal instr" if @debug_enable
        ""
    end

    def to_cbat
        "nop"
    end

    def to_batch
        "::cbat:nop"
    end
end   