module LookupTable 
    attr_reader :lt

    def initialize
        @lt = {}
    end

    def store(name, value)
        @lt.store(name.downcase.to_sym, value)
    end

    def get(name)
        @lt.fetch(name.downcase.to_sym, "undefined")
    end

    def to_s 
        @lt.to_s 
    end
end

class VariableLookupTable
    include LookupTable

    def get(name)
        case name.downcase.to_sym
        when :date
            Time.new.strftime("%Y-%m-%d")
        when :time
            Time.new.strftime("%H:%M:%S")
        when :random
            rand(0..32767).to_s
        when :username
            `whoami`.chomp
        else
            @lt.fetch(name.downcase.to_sym, "undefined")
        end
    end
end 

class LabelLookupTable
    include LookupTable
end 

class FileLookupTable
    include LookupTable

    def append_file(name, content)        
        orig_content = ""
        orig_content = self.get(name) if self.file_exists?(name) 
        self.store(name, orig_content + content + '\n')
    end

    def file_exists?(name)
        
    end

    def delete_file(name)

    end

    def copy_file(source, dest)
        
    end

    def create_file(name)

    end

    def overwrite_file(name, content)

    end

    def write_file(name, content)
        overwrite_file(name, content)
    end
end 

class SubroutineLookupTable
    include LookupTable
end 

class ExecutionContext
    attr_accessor :call_stack, :current_file, :current_instr

    def initialize()
        @call_stack = []
    end

    def call(sub)

    end 

    def push_stack_frame(filename, instr_addr)
        @call_stack << [filename, instr_addr]
    end

    def pop_stack_frame
        @call_stack.pop
    end

    def restore_caller
        prev_state = self.pop_stack_frame
        @current_file = prev_state[0]
        @current_instr = prev_state[1]
    end
end