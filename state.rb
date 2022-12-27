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
    # Need to add support for builtins 
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

class ProgramCounter
    attr_reader :pc 

    def initialize
        @pc = 0
    end

    def set(val)
        @pc = val
    end

    def incr!
        @pc += 1
    end

    def decr!
        @pc -= 1
    end

    def jump_to(label, label_lt)
        self.set(@label_lt.get(label))
    end
end
