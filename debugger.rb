module Debugger
    def debugger 
        puts ">>> Debugger enters. Hello!"
        while (input = gets.chomp) != 'q'
            cmd = input.split(' ', 2)
            case cmd[0]
            when "pos"
                puts "Current instruction: #{@current_instr}"
            when "d"
                puts "Internal instruction dump: \n"
                ix = 0
                @instructions.map do |i|
                    puts " #{ix} #{ix == @current_instr ? "@" : "|"} #{i.inspect}" 
                    ix += 1
                end
            when "dc"
                puts "CBAT instruction dump: \n"
                ix = 0
                @instructions.map do |i|
                    puts " #{ix} #{ix == @current_instr ? "@" : "|"} #{i.to_cbat}" 
                    ix += 1
                end
            when "i"
                puts "Instruction: "
                inp = gets.chomp

                puts "Target address: "
                addr = gets.chomp

                ins = inp.split(' ', 2)
                instr_map = InstructionMap.instance
                i = instr_map.lookup(ins[0])

                if i.class == IllegalInstruction
                    puts "cbat: illegal instruction `#{ins[0]}`"
                    next
                end 
        
                i.init(ins[1], @var_lt, @label_lt, @file_lt, @exec_ctx)
                insert_instr(i, addr.to_i)
            when "j"
                puts "Destination address: "
                @current_instr = gets.chomp.to_i
            when "foutc"
                puts self.to_cbat_file
            when "foutb"
                puts self.dump_batch
            else 
                puts "
                    PROGRAM COUNTER
                    pos  | current PC value
                    j    | Jump to address

                    EXECUTION
                    d    | dump instructions (internal repr)
                    dc   | dump instructions (cbat repr)
                    i    | Insert instruction at address
                    deli | delete instruction at address
                    
                    VARIABLES
                    sv   | set variable

                    LABELS
                    lc   | create label
                    ld   | delete label
                    
                    FILES
                    fcp  | file copy
                    fd   | file delete
                    fr   | read file content
                    fw   | write file content

                    MISC
                    foutc | Dump program as cbat
                    foutb | Dump program as batch
                "
            end

        @exec_ctx = :running 
        end
    end

    def insert_instr(instruction, address)
        @instructions.insert(address, instruction)
    end
end