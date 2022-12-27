require './util'
require './cbat'

program = Program.new
program.open("input.cbat")
puts program.to_cbat_file
puts program.to_batch

program.run