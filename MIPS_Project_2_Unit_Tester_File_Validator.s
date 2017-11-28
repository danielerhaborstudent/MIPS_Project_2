

# PROGRAM: Hello, World!
.data # Data declaration section
user_input: .space 1001		# Allocating space for user_input of entire 1000 character string + NULL
temp_string: .space 1001 #	Declaring an empty string. This string will take all input up until the comma
hex_8_or_more: .space 1001	# Declaring an empty string. This string will store 



valid: .asciiz "VALID"
invalid: .asciiz "INVALID"
space: .asciiz "SPACE"
comma: .asciiz "COMMA"



.text # Assembly language instructions

main: # Start of code section

li $v0, 8				
la $a0, user_input
li $a1, 1001				#Read as many as 1000 characters + NULL into user_input
syscall

prep_init_temp_string:
li $t1, 0		# temp_string index
init_temp_string:
beq $t1, 1001, after_init_temp_string
sb $zero, temp_string($t1)
addi $t1, $t1, 1
j init_temp_string
after_init_temp_string:	


prep_init_hex_8_or_more:
li $t3, 0		# hex_8_or_more index
init_hex_8_or_more:
beq $t3, 1001, after_init_hex_8_or_more
sb $zero, hex_8_or_more($t3)
addi $t3, $t3, 1
j init_hex_8_or_more
after_init_hex_8_or_more:	

li $t0, 0		# user_input index
li $t1, 0		# temp_string index
li $t3, 0 		# hex_8_or_more index



Loop_store:

lb $t2, user_input($t0)
beq $t2, '\n', after_Loop_store
sb $t2, temp_string($t1)

addi $t0, $t0, 1
addi $t1, $t1, 1

j Loop_store

after_Loop_store:
sb $t2, temp_string($t1)
li $v0, 4
la $a0, temp_string
syscall

# ##Print Newline
# li $v0, 11
# la $a0, '\n'
# syscall	


prep_validator:
li $t1, 0 # index of temp_string
li $t3, 0 # hex_8_or_more
validator:
lb $t8, temp_string($t1)

bge $t8, 48, check_less_equal_57		# If $t8 >= 48. If true check if $t8 <= 57

# else !($t8 >= 48) then $t8 < 48 but check if it's a '\t', '\n', 32(Space) or ',' first before assuming invalid
# because we read the next character too so it may not always be valid or invalid. We could read a series of 
# valid characters then a space or comma or newline whille iterating through temp_string

beq $t8, '\t', print_space_next					# If it's a '\t' print("Space") and get the next character temp_string
beq $t8, '\n', print_hex_exit					# If it's a '\n' store in hex_8_or_more and exit temp_string
beq $t8, 32, print_space_next				# If it's a space print("space") get the next character temp_string
beq $t8, ',', print_COMMA_next					# If it's a comma print("Comma") and get the next character in temp_string

j print_invalid_next								# if none of the above then invalid; get the next character

check_less_equal_57:
ble $t8, 57, print_store_get_next_remain		# $t8 <= 57. Basically if $t8 >= 48 && $t8 <= 57; '0' to '9'; store it, get next char in temp_string and remain in state_5


bge $t8, 65, check_less_equal_70		# check $t8 >= 65. If true check $t8 <= 70
check_less_equal_70:
ble $t8, 70, print_store_get_next_remain		# If $t8 <= 70 && $t8 >= 65 then it's in 'A' to 'F'; store it, get next char in temp_string and remain in state_5


bge $t8, 97, check_less_equal_102		# $t8 >= 97; If true check $t8 <= 102; Above case already handled when false.
check_less_equal_102:
ble $t8, 102, print_store_get_next_remain		# If $t8 <= 102 && $t8 >= 97 then it's in 'a' to 'f'; store it, get next char in temp_string and remain in state_5

j print_invalid_next								# get the next character





print_store_get_next_remain:

li $v0, 4			# print("VALID")
la $a0, valid
syscall

sb $t8, hex_8_or_more($t3)								# Store the validated character at the right address in hex_8_or_more
addi $t3, $t3, 1 			# $t0++ index of hex_8_or_more
# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

j validator

print_invalid_next:
li $v0, 4			# print("INVALID")
la $a0, invalid
syscall
# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]
j validator

print_hex_exit:
##Print Newline
li $v0, 11
la $a0, '\n'
syscall

li $v0, 4
la $a0, hex_8_or_more
syscall
j prep_zero_temp_string

print_space_next:

li $v0, 4			# print("SPACE")
la $a0, space
syscall
# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]
j validator


print_COMMA_next:
li $v0, 4
la $a0, comma
syscall
# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]
j validator








prep_zero_temp_string:
li $t1, 0		# temp_string index
zero_temp_string:
lb $t2, temp_string($t1)
beq $t2, $zero, after_zero_temp_string
sb $zero, temp_string($t1)
addi $t1, $t1, 1
j zero_temp_string
after_zero_temp_string:		

li $v0, 4 			# print temp_string
la $a0, temp_string
syscall

prep_zero_hex_8_or_more:
li $t3, 0		# temp_string index
zero_hex_8_or_more:
lb $t2, hex_8_or_more($t3)
beq $t2, $zero, after_zero_hex_8_or_more
sb $zero, hex_8_or_more($t3)
addi $t3, $t3, 1
j zero_hex_8_or_more
after_zero_hex_8_or_more:	

li $v0, 4 			# print temp_string
la $a0, hex_8_or_more
syscall



Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program

