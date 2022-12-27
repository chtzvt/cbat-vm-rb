require './instructions'

class CBATLoader
    attr_accessor :file_name, :entry_point, :version
    attr_accessor :labels 
    attr_accessor :instructions

    attr_accessor :var_lt, :label_lt, :file_lt, :exec_ctx

    def initialize
        @var_lt = VariableLookupTable.new
        @label_lt = LabelLookupTable.new 
        @file_lt = FileLookupTable.new 
        @instructions = []
    end

    def open(path)
        current_section = :unknown

        File.open(path).each_line do |line|
            line = line.chomp.strip

            case line
            when ".header"
                current_section = :header
                next
            when ".labels"
                current_section = :labels 
                next
            when ".instrs"
                current_section = :instructions
                next
            end

            case current_section 
            when :header 
                read_header_field(line)
            when :labels 
                read_labels_field(line)
            when :instructions
                read_instructions_field(line)
            else 
                puts "cbat: ignoring garbage `#{line}`"
                next
            end
        end
    end

    def read_header_field(field)
        kv = field.split(' ')
        case kv[0]
        when "filename"
            @file_name = kv[1]
        when "entry"
            @entry_point = kv[1] 
        when "ver"
            @version = kv[1]
        end
    end 

    def read_labels_field(field)
        kv = field.split(':')
        @label_lt.store(kv[0], kv[1])
    end

    def read_instructions_field(field)
        kv = field.split(' ', 2)
        case kv[0]
        when "e"
            i = EchoInstruction.new
        when "stp"
            i = SetPromptInstruction.new
        when "af"
            i = AppendFileInstruction.new
        when "ieq"
            i = IfEqualInstruction.new
        when "trm"
            i = TerminateInstruction.new
        end

        i.init(kv[1], @var_lt, @label_lt, @file_lt, @exec_ctx)
        @instructions.append(i)
    end

    def to_cbat 
        @instructions.map do |instr|
            puts instr.to_cbat
        end
    end

    def to_batch 
        @instructions.map do |instr|
            puts instr.to_batch
        end
    end
end


class Program
 #   include CBATLoader
    # global state
    attr_accessor :var_lt, :file_lt
    # local state
    attr_accessor :label_lt, :current_instr

    def run()

    end

    def insert_instr(instruction, address)
        @instructions.insert(address, instruction)
    end
end
