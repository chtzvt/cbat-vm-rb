module Executable
    attr_accessor :args, :raw_args, :var_lt, :label_lt, :file_lt, :ec

    def init(raw_str, var_lt, label_lt, file_lt, ec)
        @args = raw_str.batch_get_instr_args unless raw_str.nil?
        @raw_args = @args.clone.map(&:clone) unless raw_str.nil?
        @var_lt = var_lt
        @label_lt = label_lt
        @file_lt = file_lt 
        @ec = ec
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

class StoreInstruction
    include Executable

    def exec
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
        gets
    end

    def exec
        str = args[1]
        str = "Input:" if args[1].empty?
        @var_lt.store(args[0].to_sym, prompt(str).chomp)
    end

    def to_batch
        "set /p #{@raw_args[0]}=\"#{@raw_args[1]}\""
    end

    def to_cbat
        "stp #{@raw_args[0]},\"#{@raw_args[1]}\""
    end
end

class AppendFileInstruction
    include Executable

    def exec
        @file_lt.append_file(@args[1], @args[0].batch_interpolate_string(@var_lt))
    end

    def to_batch
        "echo \"#{@raw_args[0]}\" >>\"#{@raw_args[1]}\""
    end

    def to_cbat
        "af \"#{@raw_args[0]}\",\"#{@raw_args[1]}\""
    end
end

class IfEqualInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
    end

    def to_batch
        "if \"%#{@raw_args[0]}%\" EQU \"#{@raw_args[1]}\" #{@raw_args[2]}"
    end

    def to_cbat
        "ieq \"#{@raw_args[0]}\",\"#{@raw_args[1]}\",#{@raw_args[2]}"
    end
end

class GotoInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
    end

    def to_batch
        "goto #{@raw_args[0]}"
    end

    def to_cbat
        "g #{@raw_args[0]}"
    end
end

class TerminateInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
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
        @raw_str.batch_interpolate_string(@var_lt)
    end

    def to_batch
        "::cbat:breakpoint"
    end
end
