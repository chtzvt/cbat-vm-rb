require './vm'

program = Program.new
program.open(ARGV[0])
program.run