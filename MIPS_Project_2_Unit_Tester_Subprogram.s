# PROGRAM: Hello, World!
.data # Data declaration section

hex_8: .byte '7','F','F','f',','
			# '7','F','F','f','\n'
			# '7','F','F','f','0','0','a','1','\n'
			# '0','0','0','f','0','0','a','1',','

.text # Assembly language instructions

main: # Start of code section

sub1_call:

li $a0, 'F'		# Argument for #sub program 1 loaded into $a0
jal subProgram_1	# Call sub program 1
move $s1, $v0	# return value from 
after_sub1_call:


li $v0, 1
move $a0, $s1 	# Print the integer in $s1 which is the decimal of the hexadecimal argument in $a0
syscall


Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program


subProgram_1:

# Converts a single hexadecimal character to decimal
# Is called in SubProgram_2
# takes in argument $a0 a hexadecimal character which is a byte '0' - '9'; 'A' - 'F'; 'a' - 'f'
# returns $v0 a decimal digit of the hexadecimal character
bge $a0, 48, check_LE_57

check_LE_57:
ble $a0, 57, val_48_to_57		# $t8 <= 57. Basically if $t8 >= 48 && $t8 <= 57; '0' to '9'; subtract 48 to get the decimal value
j check_GE_65
val_48_to_57:




check_GE_65:
bge $a0, 65, check_LE_70		# check $t8 >= 65. If true check $t8 <= 70
j state_6
check_LE_70:
ble $a0, 70, val_65_70		# If $t8 <= 70 && $t8 >= 65 then it's in 'A' to 'F'; store it, get next char in temp_string and remain in state_5


bge $a0, 97, check_LE_102		# $t8 >= 97; If true check $t8 <= 102; Above case already handled when false.
j state_6
check_LE_102:
ble $a0, 102, store_get_next_remain		# If $t8 <= 102 && $t8 >= 97 then it's in 'a' to 'f'; store it, get next char in temp_string and remain in state_5

sub_1_return:
jr $ra

