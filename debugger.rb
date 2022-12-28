module Debugger
    def debugger 
        puts ">>> Debugger enters. Hello!"
        while (input = gets.chomp) != 'q'
            cmd = input.split(' ', 2)
            case cmd[0]
            when "pc"
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
            when "insi"
                puts "Instruction: "
                inp = gets.chomp

                puts "Target address: "
                addr = gets.chomp.to_i

                ins = inp.split(' ', 2)
                instr_map = InstructionMap.instance
                i = instr_map.lookup(ins[0])

                if i.class == IllegalInstruction
                    puts "cbat: illegal instruction `#{ins[0]}`"
                    next
                end 
        
                i.init(ins[1], @var_lt, @label_lt, @file_lt, @exec_ctx)
                insert_instr(i, addr)
                @current_instr += 1 if addr <= @current_instr
            when "j"
                puts "Destination address: "
                @current_instr = gets.chomp.to_i
            when "deli"
                puts "Delete target address: "
                target = gets.chomp.to_i 
                @current_instr -= 1 if target <= @current_instr
                @instructions.delete_at(target)
            when "vset"
                puts "Variable name: "
                vname = gets.chomp

                puts "Value: "
                vval = gets.chomp
                @var_lt.store(vname, vval)
            when "vdel"
                puts "Variable name: "
                vname = gets.chomp
                @var_lt.delete(vname)
            when "vdmp"
                puts "Variable dump: \n"
                ix = 0
                @var_lt.map do |k,v|
                    puts " #{k} | #{v}" 
                end
            when "fdmp"
                puts "File dump: \n"
                ix = 0
                @file_lt.map do |k,v|
                    puts " #{k} | #{v}" 
                end
            when "lbc"
                puts "Label name: "
                lbname = gets.chomp

                puts "Destination: "
                lbdest = gets.chomp
                @label_lt.store(lbname, lbdest.to_i)
            when "lbd"
                puts "Label name: "
                lbname = gets.chomp
                @label_lt.delete(lbname)
            when "lbdmp"
                puts "Label dump: \n"
                ix = 0
                @label_lt.map do |k,v|
                    puts " #{k} | #{v}" 
                end
            when "foutc"
                puts self.to_cbat_file
            when "foutb"
                puts self.dump_batch
            else 
                puts "
                    PROGRAM COUNTER
                    pc   | current PC value
                    j    | Jump to address

                    EXECUTION
                    d    | dump instructions (internal repr)
                    dc   | dump instructions (cbat repr)
                    insi | Insert instruction at address
                    deli | delete instruction at address
                    
                    VARIABLES
                    vset | set variable
                    vdel | delete variable
                    vdmp | dump variables 

                    LABELS
                    lbc  | create label
                    lbd  | delete label
                    lbdmp| dump labels
                    
                    FILES
                    fcp  | file copy
                    fdel | file delete
                    fr   | read file content
                    fw   | write file content
                    fdmp | dump files

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