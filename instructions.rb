module Executable
    attr_accessor :args, :var_lt, :label_lt, :file_lt, :pc

    def init(raw_str, var_lt, label_lt, file_lt, pc)
        @args = raw_str.batch_get_instr_args
        @var_lt = var_lt
        @label_lt = label_lt
        @file_lt = file_lt 
        @pc = pc
    end

    def exec
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
end

class AppendFileInstruction
    include Executable

    def exec
        @file_lt.append_file(@args[1], @args[0].batch_interpolate_string(@var_lt))
    end
end

class IfEqualInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
    end
end

class GotoInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
    end
end

class TerminateInstruction
    include Executable

    def exec
        @raw_str.batch_interpolate_string(@var_lt)
    end
end