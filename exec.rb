require './util'
require './cbat'
require './state'
require './instructions'

cbatLoader = CBATLoader.new
cbatLoader.open("input.cbat")
puts cbatLoader.to_cbat

var_lt = VariableLookupTable.new

label_lt = LabelLookupTable.new 
label_lt.store("WAZZUP", 7)

file_lt = FileLookupTable.new 

pc = 0

v1 = StoreInstruction.new
v1.run("FIRST,\"CBAT\"", var_lt, label_lt, file_lt, pc)
v2 = StoreInstruction.new
v2.run("LAST,\"BatchVM\"", var_lt, label_lt, file_lt, pc)

test = EchoInstruction.new
test.run("\"Hey, %USERNAME%! It is %DATE%. My name is %FIRST% %LAST%.\"", var_lt, label_lt, file_lt, pc)

test2 = SetPromptInstruction.new
test2.run("NAME,\"Please enter your name: \"", var_lt, label_lt, file_lt, pc)

test3 = AppendFileInstruction.new
test3.run("\"%NAME%\",\"USERS.TXT\"", var_lt, label_lt, file_lt, pc)

test4 = EchoInstruction.new
test4.run("\"Great to meet you, %NAME%.\"", var_lt, label_lt, file_lt, pc)

test5 = EchoInstruction.new
test5.run("\"It is %TIME% at %DATE%. Here's a random number: %RANDOM%.\"", var_lt, label_lt, file_lt, pc)

puts ""

puts "-- Reassembled CBAT --"
puts v1.to_cbat
puts v2.to_cbat
puts test.to_cbat
puts test2.to_cbat
puts test3.to_cbat
puts test4.to_cbat
puts test5.to_cbat
puts "-- ---------- --"

puts "" 

puts "-- Reassembled Batch --"
puts v1.to_batch
puts v2.to_batch
puts test.to_batch 
puts test2.to_batch 
puts test3.to_batch 
puts test4.to_batch 
puts test5.to_batch 
puts "-- ---------- --"

puts ""

p var_lt
p file_lt
p label_lt