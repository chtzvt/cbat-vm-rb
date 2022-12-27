require './util'
require './state'
require './instructions'

var_lt = VariableLookupTable.new
var_lt.store("USER", "Charlton")
var_lt.store("name", "BatchVM")

label_lt = LabelLookupTable.new 
label_lt.store("WAZZUP", 7)

file_lt = FileLookupTable.new 

pc = ProgramCounter.new

test = EchoInstruction.new
test.run("\"Hey, %user%! My name is %name%.\"", var_lt, label_lt, file_lt, pc)

test2 = SetPromptInstruction.new
test2.run("NAME,\"Please enter your name:\"", var_lt, label_lt, file_lt, pc)

test3 = AppendFileInstruction.new
test3.run("\"%NAME%\",\"USERS.TXT\"", var_lt, label_lt, file_lt, pc)


p var_lt
p file_lt