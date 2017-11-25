

# PROGRAM: Hello, World!
.data # Data declaration section
user_input: .space 1001		# Allocating space for user_input of entire 1000 character string + NULL
temp_string: .asciiz "" #	Declaring an empty string. This string will take all input up until the comma
hex_8_or_more: .asciiz ""	# Declaring an empty string. This string will store 
input_char: .space 9

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



beq $t5, 44, when_comma	#Store the character, but if the character is a comma, store it and print the string
j when_not_commma
when_comma:
sb $t5, temp_string($t1)
j print_temp_string

when_not_commma:
beq $t5, 10, print_exit_load_char	#If the character is a newline store a newline, print the temp_string and exit
beq $t5, $zero, print_exit_load_char	#If the character is a NULL character store a newline, print the temp_string and exit


sb $t5 , temp_string($t1)

addi $t1, $t1, 1 # $t1++	index for temp_string
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in string
j Load_Char 				# Go back to Load_char to loop the next character




after_print_temp_string:	# After we are done printing temp_string that ends with a comma and making it empty 
addi $t3, $t3, 1			# $t3 = $t3 + 1 to offset address at user_input by 1 to get the next char in input_string (which would be the value after the comma)
li $t1, 0					# we initialize the index for temp_string which is $t1
j Load_Char

print_temp_string:		# We print the temp_string then make the string an empty string so we can re-use it again

li $v0, 4
la $a0, temp_string 	# Print the temp_string
syscall


li $t1, 0  # Re-initialize $t1 temp_string's index to 0
Make_all_zero:
lb $t6, temp_string($t1)
beq $t6, $zero, after_print_temp_string	# Make the string empty by turning every character previously 
									# there into a NULL character until we hit a NULL character in the string


li $t6, 0	
sb $t6, temp_string($t1)			# Store the NULL character into the temp_string[$t1]

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


li $t6, 0	
sb $t6, temp_string($t1)			# Store the NULL character into the temp_string[$t1]

addi $t1, $t1, 1				# $t1 += 1
j Make_all_zero_exit					# Go back to loop header



after_Load_Char:














Exit:
li $v0, 10	#Call code for exiting program
syscall # Exit program

