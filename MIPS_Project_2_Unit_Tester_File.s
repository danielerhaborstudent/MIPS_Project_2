

# PROGRAM: Hello, World!
.data # Data declaration section
user_input: .space 1001		# Allocating space for user_input of entire 1000 character string + NULL

indexOf_user_input: 		# Use to store value of $t3 which is basically the memory location of user_user input. This acts like an index whe we do $t3 += 1
							# I am trying to preserve it incase we are forced to use $t3 later either in the state machines or in the sub_programs
				.align 2
				.space 4
curr_state:
			.space 1		# State to store integer values from 0 through 9
					
temp_string: .asciiz "" #	Declaring an empty string. This string will take all input up until the comma
hex_8_or_more: .asciiz ""	# Declaring an empty string. This string will store 


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
sw $t3, indexOf_user_input($zero)		# Save $t3 in indexOf_user_input



beq $t5, 44, when_comma	#Store the character, but if the character is a comma, store it and print the string
j when_not_commma
when_comma:
sb $t5, temp_string($t1)
j print_temp_string

when_not_commma:
beq $t5, 10, print_exit_load_char	#If the character is a newline store a newline, print the temp_string and exit
beq $t5, $zero, print_exit_load_char	#If the character is a NULL character store a newline, print the temp_string and exit


sb $t5 , temp_string($t1)		#Store the character that is not a comma, or \0 or \n in temp_string 

addi $t1, $t1, 1 			# $t1++	   index for temp_string

lw $t3, indexOf_user_input($zero)  # load $t3 in indexOf_user_input
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in string
j Load_Char 				# Go back to Load_char to loop the next character




after_print_temp_string:	# After we are done printing temp_string that ends with a comma and making it empty 
lw $t3, indexOf_user_input($zero)  # load $t3 in indexOf_user_input
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in input_string (which would be the value after the comma)
li $t1, 0					# we initialize the index for temp_string which is $t1
j Load_Char

print_temp_string:		# We print the temp_string then make the string an empty string so we can re-use it again

li $v0, 4
la $a0, temp_string 	# Print the temp_string
syscall

###Where my state_machine will be and hence where subprogram 2 and 3 and 1 are called

State_Machine:

state_0:
# Initial state where we read the first char from temp_string which could be of many forms "\n" | "FffF[space],"|
# "[space]FFf[space]," | "\," | "[sapce]\n" | "012345678\n"

li $t0, 0					# curr_state = 0
sb $t0, curr_state($zero)

li $t1, 0			# initialize temp_strings index to 0 $t1 = 0
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, '\n', state_3 		# If the first character I see is a '\n' go to state_3

beq $t8, '\t', state_4		# If the first character is a space or a tab go to state_4
beq $t8, 'Space', state_4 

beq $t8, ',', state_1		# If the first character I see is a comma go to state_1

j state_5					# If I neither see a '\n' nor a [space] nor a ',' it must be a character. Go to state_5



state_1:
# We are in state_1
li $t0, 1
sb $t0, curr_state($zero)  # curr_state = 1

# Get the next character
addi $t1, $t1, 1				# $t1 += 1			
lb $t8, temp_string($t1)		# temp_string[$t1]

beq $t8, $zero, state_2			# If the next character after the comma is NUL then go to state_2 hence 
								# the value we read from temp_string was ",\0"	because temp_string is zero terminated
								# No other cases possible because temp_string is either comma terminated or '\n' terminated



state_2:
li $t0, 2
sb $t0, curr_state($zero)  # curr_state = 2




state_3:

state_4:

state_5:






li $t1, 0  # Re-initialize $t1 temp_string's index to 0
Make_all_zero:
lb $t6, temp_string($t1)
beq $t6, $zero, after_print_temp_string	# Make the string empty by turning every character previously 
									# there into a NULL character until we hit a NULL character in the string



sb $zero, temp_string($t1)			# Store the NULL character into the temp_string[$t1]

addi $t1, $t1, 1				# $t1 += 1
j Make_all_zero					# Go back to loop header


print_exit_load_char:

li $t5, 10					# Load a newline into the temp_string[$t1]; this will help us when we are validating
sb $t5, temp_string($t1)

li $v0, 4
la $a0, temp_string 	# Print the temp_string
syscall

li $t1, 0  # Re-initialize $t1 temp_string's index to 0

Make_all_zero_exit:
lb $t6, temp_string($t1)
beq $t6, $zero, after_Load_Char	# Make the string empty by turning every character previously 
									# there into a NULL character until we hit a NULL character in the string


	
sb $zero, temp_string($t1)			# Store the NULL character into the temp_string[$t1]

addi $t1, $t1, 1				# $t1 += 1
j Make_all_zero_exit					# Go back to loop header



after_Load_Char:














Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program

