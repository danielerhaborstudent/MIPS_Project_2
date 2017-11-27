

# PROGRAM: Hello, World!
.data # Data declaration section
user_input: .space 1001		# Allocating space for user_input of entire 1000 character string + NULL

indexOf_user_input: 		# Use to store value of $t3 which is basically the memory location of user_input. This acts like an index whe we do $t3 += 1
							# I am trying to preserve it incase we are forced to use $t3 later either in the state machines or in the sub_programs
							# has to be able to hold a word because memory locations are of the form 0x7fffffff basically 1 word; 4 bytes
				.align 2
				.space 4
curr_state:
			.space 1		# State to store integer values from 0 through 9
					
temp_string: .asciiz "" #	Declaring an empty string. This string will take all input up until the comma
hex_8_or_more: .asciiz ""	# Declaring an empty string. This string will store a hex string with 8 or more valid hex_characters either ending with a comma or newline

indexOf_hex_8_or_more: 			 # Will use this to store $t0 which will hold the memory address of hex_8_or_more while in state_ 5 
								 # so I can iterate while I am storing the next character
						.align 2 # Has to be a word because memory locations are of the form 0x7fffffff basically 1 word; 4 bytes	
						.space 4

print_NaNComma: .asciiz "NaN,"		# String for "NaN,"

print_NaN: .asciiz "NaN"		# String for "NaN"

print_too_largeC: .asciiz "too large,"

print_too_large: .asciiz "too large"



.text # Assembly language instructions

main: # Start of code section

li $v0, 8				
la $a0, user_input
li $a1, 1001				#Read as many as 1000 characters + NULL into user_input
syscall

##Print Newline
li $v0, 11
la $a0, '\n'
syscall	

	
li $t1, 0		# $t1 = 0	index for temp_string
la $t3, user_input		#Load address of user_input into $t3	


Load_Char:


lb $t5, 0($t3)				# $t5 = $t3[0] 
sw $t3, indexOf_user_input($zero)		# Save $t3(which is holding a memory address) in indexOf_user_input



beq $t5, 44, when_comma	#Store the character, but if the character is a comma, store it and go to State_Machine
j when_not_commma
when_comma:
sb $t5, temp_string($t1)
j State_Machine

when_not_commma:
beq $t5, 10, store_endl_enter_machine	#If the character is a newline store a newline in temp_string and enter the state machine
beq $t5, $zero, store_endl_enter_machine	#If the character is a NULL character store a newline in temp_string and enter the state machine


sb $t5 , temp_string($t1)		#Store the character that is not a comma, or \0 or \n in temp_string 

addi $t1, $t1, 1 			# $t1++	   index for temp_string

lw $t3, indexOf_user_input($zero)  # load $t3 in indexOf_user_input
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in string
j Load_Char 				# Go back to Load_char to loop the next character




next_temp_string:	# After we are done making temp_string that ended in a comma empty 
					# we get the next temp_string via iterating through user_input
lw $t3, indexOf_user_input($zero)  # load $t3 in indexOf_user_input
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in input_string (which would be the value after the comma)
li $t1, 0					# we initialize the index for temp_string which is $t1
j Load_Char



###Where my state_machine will be and hence where subprogram 2 and 3 and 1 are called

State_Machine:

la $t0, hex_8_or_more                   # When I enter the state machine store the address of hex_8_or_more in indexOf_hex_8_or_more($zero) to be used later
sw $t0, indexOf_hex_8_or_more($zero)

state_0:
# Initial state where we read the first char from temp_string which could be of many forms "\n" | "FffF[space],"|
# "[space]FFf[space]," | "\," | "[sapce]\n" | "012345678\n"

li $t0, 0					# curr_state = 0
sb $t0, curr_state($zero)

li $t1, 0			# initialize temp_strings index to 0 $t1 = 0
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, '\n', state_3 		# If the first character I see is a '\n' go to state_3

beq $t8, '\t', state_4		# If the first character is a space or a tab go to state_4
beq $t8, 32, state_4 

beq $t8, ',', state_1		# If the first character I see is a comma go to state_1

j state_5					# If I neither see a '\n' nor a [space] nor a ',' it must be a character. Go to state_5



state_1:
# We are in state_1
# We read our first comma either after temp_string was declared invalid
# Or after we read some spaces initially with nothing else
# After we read only our first comma

li $t0, 1
sb $t0, curr_state($zero)  # curr_state = 1

# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, $zero, state_2			# If the next character after the comma is NUL then go to state_2 hence 
								# the value we read from temp_string was ",\0" or "invalid,\0" or "[space],\0"	because temp_string is zero terminated
								# No other cases possible because temp_string is either comma terminated or '\n' terminated


state_2:
# We are in state_2
# See state_1 description

li $t0, 2
sb $t0, curr_state($zero)  # curr_state = 2

li $v0, 4
la $a0, print_NaNComma		# print("Nan,")
syscall

j after_State_Machine			# We then leave the state_machine and get the next temp_string




state_3:

# We are in state_3
# This means that $t8 = '\n' we have read a newline. Maybe after a space, 
# or after some invalid character was reached or just initially
# We just print("NaN") and exit the program
li $t0, 3
sb $t0, curr_state($zero)		# curr_state = 3


li $v0, 4
la $a0, print_NaN  # print("NaN")
syscall

j after_Load_Char # We stop our iteration of user_input because we've reached the end. and just exit the program




state_4:

# We are in state_4; we have read the first space or tab. Or we are still reading 
# spaces or tabs before a valid char, invalid char, comma or a newline

li $t0, 4
sb $t0, curr_state($zero)		# curr_state = 4

# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, '\t', state_4			# If the next character read is a space or tab stay in state_4
beq $t8, 32, state_4

beq $t8, ',', state_1			# If the next character read is a comma go to state_1
beq $t8, '\n', state_3			# If it is a newline go to state_3

j state_5						# If I neither see a [space] nor a ',' nor a '\n' it must be a character. Go to state_5



state_5:

# We are in state_5; we have read the first valid or invalid character
# or the first valid(s) or invalid character after initial [space]
# These occur before '\n' or comma never after

li $t0, 5
sb $t0, curr_state($zero)		# curr_state = 5


bge $t8, 48, check_less_equal_57		# If $t8 >= 48. If true check if $t8 <= 57

# else !($t8 >= 48) then $t8 < 48 but check if it's a '\t', '\n', 32(Space) or ',' first before assuming invalid
# because we read the next character too so it may not always be valid or invalid. We could read a series of 
# valid characters then a space or comma or newline whille iterating through temp_string

beq $t8, '\t', state_7					# If it's a '\t' go to state_7 
beq $t8, '\n', state_9					# If it's a '\n' go to state_9
beq $t8, 32, state_7					# If it's a space go to state_7
beq $t8, ',', state_8					# If it's a comma we deal with that in state_8

j state_6								# if none of the above then invalid; because it is invalid so we deal with that in state_6

check_less_equal_57:
ble $t8, 57, store_get_next_remain		# $t8 <= 57. Basically if $t8 >= 48 && $t8 <= 57; '0' to '9'; store it, get next char in temp_string and remain in state_5

bge $t8, 58, check_less_equal_64		# If $t8 >= 58 we check if $t8 <= 64 so we can be sure that is is invalid. $t8 <= 57 already 
										# handles the case when it is false
check_less_equal_64:
ble $t8, 64, state_6					# We handled $t8 >= 58; now we handle when $t8 <= 64; If both are true we know it is invalid so we go to state_6


bge $t8, 65, check_less_equal_70		# If above was false check $t8 >= 65. If true check $t8 <= 70
check_less_equal_70:
ble $t8, 70, store_get_next_remain		# If $t8 <= 70 && $t8 >= 65 then it's in 'A' to 'F'; store it, get next char in temp_string and remain in state_5

bge $t8, 71, check_less_equal_96		#  $t8 >= 71; If true check $t8 <= 96; Will never be false because the above case handled that already.
check_less_equal_96:					#
ble $t8, 96, state_6					#	$t8 <= 86; If true it is definitely an invalid character so we go to state_6 to handle those.

bge $t8, 97, check_less_equal_102		# $t8 >= 97; If true check $t8 <= 102; Above case already handled when false.
check_less_equal_102:
ble $t8, 102, store_get_next_remain		# If $t8 <= 102 && $t8 >= 97 then it's in 'a' to 'f'; store it, get next char in temp_string and remain in state_5

j state_6								# If !(t8 <= 102) then it is definitely invalid so we go to state_6












store_get_next_remain:

lw $t0, indexOf_hex_8_or_more($zero)		# Get the address of hex_8_or_more from indexOf_hex_8_or_more($zero)

sb $t8, 0($t0)								# Store the validated character at the right address in hex_8_or_more

addi $t0, $t0, 1 			# increment $t0 basically incrementing the value in indexOf_hex_8_or_more($zero) by 1 basically incrementing the memory address
							# of hex_8_or_more by 1, so we get the next position in the hex_8_or_more string

sw $t0, indexOf_hex_8_or_more($zero) # save the new address to be reused later in other states.
# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

j state_5				# Remain in state_5 





state_6:
# We are now in state_6
# Here we read. We know that the temp_string is invalid because it could be like "FFf@," | "FF[space]F\n" 
# Since we know it is invalid we just keep reading the rest of the characters until we see a '\n' or a comma

li $t0, 6
sb $t0, curr_state($zero)		# curr_state = 6

addi $t1, $t1, 1
lb $t8, temp_string($t1)		# Get the next character


beq $t8, ',', state_1		# We just keep reading characters until we either hit a ',' or a '\n' to tell us what state to go to to either print("NaN,") or print("NaN")
beq $t8, '\n', state_3		# Hence we will stay in state_6 until we find a ',' or '\n'


j state_6			# basically in essence just remaining in state_6 and reading characters





state_7:

# We are in state_7. We have read a valid char or a series of valid char from temp_string but we hit either a space or a tab.
# We will either read more successive spaces or tabs and remain in this state or we read any character that is not a '\n', ',' or '\t'
# Then it is a character so we go to the invalid state_6

li $t0, 7
sb $t0, curr_state($zero)		# curr_state = 7

addi $t1, $t1, 1
lb $t8, temp_string($t1)		# Get the next character

beq $t8, 32, state_7 		# If we keep reading spaces or tabs we remain in state_7
beq $t8, '\t', state_7
beq $t8, ',', state_8		# If we read a comma we go to state_8
beq $t8, '\n', state_9		# If we read a newline we go to state_9

j state_6		# If non of the above are true then we definitely read a character but since we just read "valid_char[space]some_char" 
				# We know the entire string is invalid so we go to state_6 to handle that




state_8:

# We are in state_8 we read a "valid_char(s)[space]," or "valid_char(s)," 
# We will just store the comma as part of hex_8_string_or_more so we can know what to print when we intend on calling sub_2 and sub_3

li $t0, 8
sb $t0, curr_state($zero)		# curr_state = 8


lw $t0, indexOf_hex_8_or_more($zero)		# Get the address of hex_8_or_more from indexOf_hex_8_or_more($zero)
sb $t8, 0($t0)								# Store the comma at the right address in hex_8_or_more


li $t9, 0				# Our index to iterate through hex_8_or_more
check_too_large_comma:

# If the index at which the comma is at in hex_8_or_more is > 8 then hex_8_or_more is too large so we print("too large,")
# hex_8_or_more[0] to hex_8_or_more[8] is fine with hex_8_or_more[7] being the 8th valid char and hex_8_or_more[8] being the comma.
# Anything greater then print("too large,")

lb $t8, hex_8_or_more($t9) # $t8 = hex_8_or_more[$t9]
beq $t8, ',', check_index	# When we hit a comma we check if the index > 8
addi $t9, $t9, 1
j check_too_large_comma

check_index:

bgt $t9, 8, tooLargeC_zero_Next_temp_string		# If the index is greater than 8, we print("too large,"), 
												# zero out hex_8_or_more and get the next_temp (we have to leave the state machine)

li $v0, 4			# Else we print hex_8_or_more with the comma and get the next temp_string
la $a0, hex_8_or_more # For now just print the value later on we will call sub_2 and then sub_3 here 
syscall

li $t9, 0			# initalize index $t9 to iterate hex_8_or_more as 0
j zero_Hex_8_or_more_leave_machine


tooLargeC_zero_Next_temp_string:

li $v0, 4
la $a0, print_too_largeC		# Print("too large,")
syscall

li $t9, 0  # initalize index $t9 to iterate hex_8_or_more as 0
zero_Hex_8_or_more_leave_machine:
lb $t8, hex_8_or_more($t9)				# If hex_8_or_more[$t9] == 0 then leave the state machine. We hit the end of hex_8_or_more. 
beq $t8, $zero, after_State_Machine 	# Else hex_8_or_more[$t9] = 0 
sb $zero, hex_8_or_more($t9)			# Keep iterating through that
addi $t9, $t9, 1
j zero_Hex_8_or_more_leave_machine




state_9:
# We are in state_9 so we read "valid_char(s)\n" or "valid_char(s)[space]\n"
# We will just store the '\n' as part of hex_8_string_or_more so we can know what to print when we intend on calling sub_2 and sub_3

li $t0, 9
sb $t0, curr_state($zero)		# curr_state = 9

lw $t0, indexOf_hex_8_or_more($zero)		# Get the address of hex_8_or_more from indexOf_hex_8_or_more($zero)
sb $t8, 0($t0)								# Store the '\n' at the right address in hex_8_or_more


li $t9, 0				# Our index to iterate through hex_8_or_more
check_too_large_newline:

# If the index at which the newline is at in hex_8_or_more is > 8 then hex_8_or_more is too large so we print("Too large")
# hex_8_or_more[0] to hex_8_or_more[8] is fine with hex_8_or_more[7] being the 8th valid char and hex_8_or_more[8] being the comma.
# Anything greater then print("Too large,")

lb $t8, hex_8_or_more($t9) # $t8 = hex_8_or_more[$t9]
beq $t8, '\n', check_index_N	# When we hit a newline we check if the index > 8
addi $t9, $t9, 1
j check_too_large_newline

check_index_N:
bgt $t9, 8, tooLarge_exit_program		# If the index $t9 > 8 then print("too large") and exit the program

# Else print hex_8_or_more
li $t9, 0							# printing temporarily for now. Here sub_2 will be called then sub_3 to print the value		
print_char_hex_8_or_more_without_endl:
lb $t8, hex_8_or_more($t9)				# iterate through hex_8_or_more
beq $t8, '\n', after_Load_Char			# and print the characters until we see a newline. When we see a newline we exit the entire program because we are done
										# with user_input 
li $v0, 11			# Print character in $t8 
move $a0, $t8
syscall

tooLarge_exit_program:		

li $v0, 4
la $a0, print_too_large 	#print("too large")
syscall

j after_Load_Char			# and exit the program







after_State_Machine:
li $t1, 0  # Re-initialize $t1 temp_string's index to 0
Make_all_zero:
lb $t6, temp_string($t1)
beq $t6, $zero, next_temp_string	# Make the string empty by turning every character previously 
									# there into a NULL character until we hit a NULL character in the string
									# When we zero out temp_string we get the next temp_string from user_input

sb $zero, temp_string($t1)			# Store the NULL character into the temp_string[$t1]
addi $t1, $t1, 1				# $t1 += 1
j Make_all_zero					# Go back to loop header



store_endl_enter_machine:
li $t5, 10					# Load a newline into the temp_string[$t1]; this will help us when we are validating
sb $t5, temp_string($t1)
j State_Machine




after_Load_Char:




Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program

