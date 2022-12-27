require './util'
require './state'
require './instructions'

module CBATLoader
    attr_accessor :file_name, :entry_point, :version
    attr_accessor :instructions

    attr_accessor :var_lt, :label_lt, :file_lt
    attr_accessor :exec_ctx

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
            @entry_point = kv[1].to_i
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
        when "st"
            i = StoreInstruction.new
        else 
            puts "cbat: unknown instruction `#{kv[0]}`"
            exit 
        end

        i.init(kv[1], @var_lt, @label_lt, @file_lt, @exec_ctx)
        @instructions.append(i)
    end

    def to_cbat_instrs
        puts "CBAT::#{@file_name}"
        @instructions.map do |instr|
            puts instr.to_cbat
        end
        puts "(end)"
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
        puts "\ttrm"
    end

    def to_batch 
        puts "BAT::#{@file_name}"
        @instructions.map do |instr|
            puts instr.to_batch
        end
        puts "(end)"
    end
end


class Program
    include CBATLoader

    def initialize
        @var_lt = VariableLookupTable.new
        @label_lt = LabelLookupTable.new 
        @file_lt = FileLookupTable.new 
        @instructions = []
        @exec_ctx = :idle
    end 

    def run()
        @exec_ctx = :running 
        current_instr = @entry_point

        while @exec_ctx == :running 
            @instructions[current_instr].exec()
            current_instr += 1

            if current_instr >= @instructions.length 
                @exec_ctx = :eof 
            end
        end 
    end

    def insert_instr(instruction, address)
        @instructions.insert(address, instruction)
    end
end
