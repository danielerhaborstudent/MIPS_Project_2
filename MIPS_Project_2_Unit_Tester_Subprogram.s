# PROGRAM: Hello, World!
.data # Data declaration section

hex_8: .byte  '0','0','0','f','0','0','a','1',',' #'7','F','F','f',','
			# '7','F','F','f','\n'
			# '7','F','F','f','0','0','a','1','\n'
			# '0','0','0','f','0','0','a','1',','

.text # Assembly language instructions

main: # Start of code section

prep_iter_hex_8:
li $t0, 0		# index to iterate through hex_8
iter_hex_8:
lb $s1, hex_8($t0)	# $a0 = hex_8[$t0]
beq $s1, ',', Exit # Leave the program when we hit a comma or newline
beq $s1, '\n', Exit
sub1_call:
move $a0, $s1 	# assign the argument $s1 to the parameter $a0 of sub_ program 1
jal subProgram_1	# Call sub program 1
move $s0, $v0	# return value from $v0 and store in $s0
after_sub1_call:

li $v0, 1
move $a0, $s0 	# Print the integer in $s0 which is the decimal of the hexadecimal character in $s1; 
syscall

addi $t0, $t0, 1	# $t0++
j iter_hex_8





Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program


subProgram_1:

# Converts a single hexadecimal character to decimal
# Is called in SubProgram_2
# takes in argument $a0 a hexadecimal character which is a byte '0' - '9'; 'A' - 'F'; 'a' - 'f'
# returns $v0 a decimal digit of the hexadecimal character
bge $a0, 48, check_LE_57
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_57:
ble $a0, 57, val_48_to_57		# $a0 <= 57. Basically if $a0 >= 48 && $a0 <= 57; '0' to '9'; subtract 48 to get the decimal value
j check_GE_65			# Else check $a0 >= 65
val_48_to_57:
addi $v0, $a0, -48 		# $v0 = $a0 - 48
j sub_1_return			# return back to caller



check_GE_65:
bge $a0, 65, check_LE_70		# check $a0 >= 65. If true check $a0 <= 70
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_70:
ble $a0, 70, val_65_70		# If $a0 >= 65 && $a0 <= 70  ; 'A' to 'F'; subtract 55 to get the decimal value
j check_GE_97 				# else check if $a0 >= 97
val_65_70:
addi $v0, $a0, -55 # $v0 = $a0 - 55
j sub_1_return	# retun back to caller


check_GE_97:
bge $a0, 97, check_LE_102		# $a0 >= 97; If true check $t8 <= 102; Above case already handled when false.
# No else block will ever be reached. Because $a0 will always be a valid hex character.
check_LE_102:
ble $a0, 102, val_97_to_102		# If  $a0 >= 97 && $a0 <= 102;'a' to 'f'; subtract 87 to get the decimal value
# No else block will ever be reached. Because $a0 will always be a valid hex character.
val_97_to_102:
addi $v0, $a0, -87 # $v0 = $a0 - 87
j sub_1_return	# retun back to caller


sub_1_return:
jr $ra


subProgram_2:



