module Debugger
    def debugger 
        puts ">>> Debugger enters. Hello!"
        while (input = gets.chomp) != 'q'
            cmd = input.split(' ', 2)
            case cmd[0]
            when "pos"
                puts "Current instruction: #{@current_instr}"
            when "d"
                puts "Instruction dump: \n"
                ix = 0
                @instructions.map do |i|
                    puts " #{ix} | #{p i}" 
                    ix += 1
                    puts "\n"
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
                @current_instr = gets.chomp.to_i - 1
            else 
                puts "
                    pos | current PC value
                      d | dump instructions
                      i | Insert instruction at address
                      j | Jump to address
                "
            end

        @exec_ctx = :running 
        end
    end

    def insert_instr(instruction, address)
        @instructions.insert(address, instruction)
    end
end