.data
	board: .space 225        # 15 x 15 = 225 cells
	displayBoard: .space 2000
	str_endl: .asciiz "\n"
	str_space: .asciiz "   "
	str_header: .asciiz "     _0_   _1_   _2_   _3_   _4_   _5_   _6_   _7_   _8_   _9_   _10   _11   _12   _13   _14\n"
	rules: .asciiz "abc"
	coordPrompt1: .asciiz "Player 1, please input your coordinates: "
	coordPrompt2: .asciiz "Player 2, please input your coordinates: "
	outRangeMsg: .asciiz "Coordinates out of range! Each coordinate must be between 0-14."
	occupiedCellMsg: .asciiz "Cell is already occupied."
	wrongFormatMsg: .asciiz "Coordinates input should be 'x,y' (Horizontal, Vertical) "
	separator:      .asciiz "------------------------------------------------------------\n"
	top_border:     .asciiz "==================== GOMOKU GAME RULES ====================\n"

	intro:          .asciiz "* GAME OBJECTIVE *\nBe the first player to place five of your marks in a row\n(horizontally, vertically, or diagonally).\n\n"

	players:        .asciiz "* PLAYERS AND SYMBOLS *\nTwo players take turns:\n- Player 1 uses symbol: X\n- Player 2 uses symbol: O\n\n"

	win_condition:  .asciiz "* WINNING CONDITION *\nA player wins if they have 5 consecutive symbols in one of\nthese ways:\n- Horizontally\n- Vertically\n- Diagonally (\\ or / direction)\n\n"

	board_text:          .asciiz "* GAME BOARD *\n- The game is played on a 15x15 grid (225 cells).\n"

	tie:            .asciiz "* TIE CONDITION *\nAll 225 cells are filled with no winner — the game announces:\n\"Tie\"\n"
	
	#data for prompt coordinate
	coord: .space 128
	invalidFormat_prompt: .asciiz "WARNING: Invalid format. Format must be X,Y (horiz,verti). Input again.\n"
	outOfRange_prompt: .asciiz "WARNING: Coordinate out of range. Must be between 0-14. Input again.\n"
	notDigit_prompt: .asciiz "WARNING: Coordinate contains non-digit. Input again.\n"
	leadingZero_prompt: .asciiz "WARNING: Coordinate has leading zero but more than one digit. Input again.\n"
	preOccupied_prompt: .asciiz "WARNING: Coordinates already occupied. Input again.\n"
.text
	jal displayRules
	
	li $v0, 4
	la $a0, str_endl
	syscall
	
	jal makeBoard
	jal showInitBoard
	li $t8, 0
	li $t9, 2
gamePlay:
	rem $s0, $t8, $t9
	jal promptCoord
	jal showUpdatedBoard
	#jal checkWinner #already printed winner message, return in $s5 1 if game ends, else 0
	addi $t8, $t8, 1
	bnez $s5, gamePlay
	#jal writeToFile
	li $v0, 10
	syscall

displayRules:
# ---------------------------------------------------------------------------------------------------- #
#   Print rules in terminal 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#jal stackIn
	
	#TODO
	li $v0, 4
	la $a0, separator
	syscall
	la $a0, top_border
	syscall
	la $a0, separator
	syscall

    	# Print intro
	la $a0, intro
	syscall
	la $a0, separator
	syscall

	# Print players
	la $a0, players
	syscall
	la $a0, separator
	syscall

	# Print win condition
	la $a0, win_condition
	syscall
	la $a0, separator
	syscall

	# Print board info
	la $a0, board_text
	syscall
	la $a0, separator
	syscall

	# Print tie condition
	la $a0, tie
	syscall
	la $a0, separator
	syscall	
	
	#jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
makeBoard:
# ---------------------------------------------------------------------------------------------------- #
#   Task1: Initialize 'board' one dimension array with size 15*15 row major order
#   Initial value of each entry is 0
#   Task2: Initialize 'displayBoard': __ 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#jal stackIn
	
	#TODO
	la $a1, board         # base address of board
	li $t0, 0
	init_board_loop:
		sb $zero, ($a1)       # store 0 at board[t0]
		addi $a1, $a1, 1      # move to next byte
		addi $t0, $t0, 1      # increment index
		li $t1, 225           # total entries
		bne $t0, $t1, init_board_loop
	#jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
showInitBoard:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

    	# --- Initialization section: board = 0 and displayBoard = "___   " ---
	la $t0, board       # $t0 = address of board
	li $t1, 0           # counter
	li $t2, 225         # total cells
init_Displayboard_loop:
	sb $zero, 0($t0)    # store 0 in each board cell
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	blt $t1, $t2, init_Displayboard_loop

    # Initialize displayBoard with "___   "
	la $t0, displayBoard
	li $t1, 0           # counter
init_display_loop:
	li $t2, 95          # ASCII '_'
	sb $t2, 0($t0)
	sb $t2, 1($t0)
	sb $t2, 2($t0)
	li $t2, 32          # ASCII space
	sb $t2, 3($t0)
	sb $t2, 4($t0)
	sb $t2, 5($t0)
	addi $t0, $t0, 6    # move to next display cell
	addi $t1, $t1, 1
	li $t2, 225
	blt $t1, $t2, init_display_loop

    # --- Now display the board as usual ---
	li $v0, 4
	la $a0, str_header
	syscall

	la $t0, displayBoard
	li $t1, 0             # row counter

print_row:
    # Print row number
    li $v0, 1
    move $a0, $t1
    syscall

    # Print spacing after row number
    li $v0, 4
    la $a0, str_space
    syscall
    
    # Add extra space for single-digit row numbers (0-9)
    li $t6, 10
    bge $t1, $t6, skip_extra_space  # If row >= 10, skip extra space
    li $v0, 11
    li $a0, 32                      # ASCII space
    syscall

skip_extra_space:

    li $t2, 0             # col counter
print_col:
	li $t4, 0             # char index within each cell
print_cell_char:
	lb $a0, 0($t0)
	li $v0, 11
	syscall
	addi $t0, $t0, 1
	addi $t4, $t4, 1
	li $t5, 6
	blt $t4, $t5, print_cell_char

	addi $t2, $t2, 1
	li $t3, 15
	blt $t2, $t3, print_col

	li $v0, 4
	la $a0, str_endl
	syscall

	addi $t1, $t1, 1
	li $t3, 15
	blt $t1, $t3, print_row

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

showUpdatedBoard:
# ---------------------------------------------------------------------------------------------------- #
#   Function to display the updated board after a move
#   Uses the 'board' array to update the 'displayBoard' and then displays it
#   board: Contains 0 for empty, 1 for player 1 (X), 2 for player 2 (O)
#   displayBoard: Visual representation with "___" for empty, "_X_" for player 1, "_O_" for player 2
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# First, update displayBoard based on current board values
	la $t0, board         # $t0 = address of board
	la $t1, displayBoard  # $t1 = address of displayBoard
	li $t2, 0             # cell counter

update_display_loop:
	lb $t3, 0($t0)        # Load board value (0, 1, or 2)
	
	# Each displayBoard cell has 6 characters: "___   " or "_X_   " or "_O_   "
	li $t5, 6
	mul $t4, $t2, $t5     # Calculate offset in displayBoard
	add $t4, $t1, $t4     # Address of current displayBoard cell
	
	# First and third character remain '_' for all cells
	li $t5, 95            # ASCII '_'
	sb $t5, 0($t4)        # First '_'
	sb $t5, 2($t4)        # Third '_'
	
	# Middle character depends on board value
	beqz $t3, empty_cell  # If board value is 0, cell is empty
	li $t6, 1
	beq $t3, $t6, player1_cell # If board value is 1, cell is player 1 (X)
	
	# Otherwise, it's player 2 (O)
	li $t5, 79            # ASCII 'O'
	sb $t5, 1($t4)
	j cell_marked
	
player1_cell:
	li $t5, 88            # ASCII 'X'
	sb $t5, 1($t4)
	j cell_marked
	
empty_cell:
	li $t5, 95            # ASCII '_'
	sb $t5, 1($t4)
	
cell_marked:
	# Last 3 characters are spaces
	li $t5, 32            # ASCII space
	sb $t5, 3($t4)
	sb $t5, 4($t4)
	sb $t5, 5($t4)
	
	addi $t0, $t0, 1      # Move to next board cell
	addi $t2, $t2, 1      # Increment counter
	li $t3, 225           # 15x15 board has 225 cells
	blt $t2, $t3, update_display_loop

	# Now display the updated board
	li $v0, 4
	la $a0, str_header
	syscall

	la $t0, displayBoard
	li $t1, 0             # row counter

print_updated_row:
	# Print row number
	li $v0, 1
	move $a0, $t1
	syscall

	# Print spacing after row number
	li $v0, 4
	la $a0, str_space
	syscall
	
	# Add extra space for single-digit row numbers (0-9)
	li $t6, 10
	bge $t1, $t6, skip_updated_extra_space  # If row >= 10, skip extra space
	li $v0, 11
	li $a0, 32                      # ASCII space
	syscall

skip_updated_extra_space:

	li $t2, 0             # col counter
print_updated_col:
	li $t4, 0             # char index within each cell
print_updated_cell_char:
	lb $a0, 0($t0)
	li $v0, 11
	syscall
	addi $t0, $t0, 1
	addi $t4, $t4, 1
	li $t5, 6
	blt $t4, $t5, print_updated_cell_char

	addi $t2, $t2, 1
	li $t3, 15
	blt $t2, $t3, print_updated_col

	li $v0, 4
	la $a0, str_endl
	syscall

	addi $t1, $t1, 1
	li $t3, 15
	blt $t1, $t3, print_updated_row

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

promptCoord:
# ---------------------------------------------------------------------------------------------------- #
#   	Arguments:
#	$s0 contains flag: 0 - player 1 ; 1 - player 2
# 	$v0: 0 --> invalid, 1 --> valid; $s2: row; $s3: col 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	beqz $s0, handlePlayer1
	j handlePlayer2
	
handlePlayer1:
	# Display prompt for Player 1
	li $v0, 4
	la $a0, coordPrompt1
	syscall

	jal validateCoord  # out: $v0: 0 --> invalid, 1 --> valid; $s2: row; $s3: col
	beqz $s5, handlePlayer1  # If invalid, prompt again
	jal updateBoard
	beqz $s5, handlePlayer1
	
	li $v0, 4
	la $a0, str_endl
	syscall
	j promptCoord_end
	
handlePlayer2:
	# Display prompt for Player 2
	li $v0, 4
	la $a0, coordPrompt2
	syscall

	jal validateCoord  # out: $v0: 0 --> invalid, 1 --> valid; $s2: row; $s3: col
	beqz $s5, handlePlayer2  # If invalid, prompt again
	jal updateBoard
	beqz $s5, handlePlayer2 
	
	li $v0, 4
	la $a0, str_endl
	syscall
	
		
promptCoord_end:
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
	
validateCoord:
# ---------------------------------------------------------------------------------------------------- #
#	Return:
#	$v0: 0 if invalid else 1
#	$s2: row
#	$s3: col
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	li $v0, 8
	la $a0, coord
	li $a1, 127 #maximum char to read
	syscall
	
	#correct formats: d,d; dd,dd; d,dd; dd,d --> max_length = 5, at least 3
	#$a0 hold address of current index
	#$t0 hold length
	li $t0, 0
	la $t1, coord
	li $t2, -1 #index of comma
	li $t3, ','
	#make sure correct length + only one comma is accepted
	getBufferLength:
		lb $t4, 0($t1)
		beqz $t4 end_getBufferLength
		beq $t4, $t3, isComma
		j continueGBL
		isComma:
		bne $t2, -1, invalidFormat
		move $t2,$t0
		continueGBL:
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j getBufferLength
	
	end_getBufferLength:
	addi $t0, $t0, -1 # endline
		
	#slti $t1, $t0, 3
	#bnez $t1, invalidFormat
		
	#slti $t1, $t0, 6
	#beqz $t1, invalidFormat
	move $s0, $t0 #s0 hold length
	
	
	#done checking length, now checking position of comma 
	beq $t2, -1, invalidFormat #no comma
	#before comma
	add $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, 0
	jal checkEachCoord
	lw $ra, 0($sp)
	add $sp, $sp, 4
	move $s2, $s4
	beqz $s5, end_validateCoord
	
	#after comma 
	add $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $t2
	addi $t0, $t0, 1
	move $t2, $s0
	
	jal checkEachCoord
	lw $ra, 0($sp)
	add $sp, $sp, 4
	move $s3, $s4
	j end_validateCoord
	
	invalidFormat:
		li $v0, 4
		la $a0, invalidFormat_prompt
		syscall
		li $s5, 0
		
end_validateCoord:
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
checkEachCoord:
# start index $t0, end index  + 1 $t2, return $s5 is 0 if invalid
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	la $t1, coord
	li $t3, 0 #contain count
	
	sub $t2, $t2, $t0 #contain number of char 

	seq $t4, $t2, 0
	sgt $t5, $t2, 2
	or $t5, $t4, $t5
	bnez $t5, outOfRange
	add $t0, $t0, $t1

	beq $t2, 1, oneChar #t2 hold number of char
	twoChar:
		lb $t1, 0($t0)
		addi $t1, $t1, -48
		beqz $t1, leadingZero
		sltiu $t3, $t1, 10 #t3 = 1 if t1 less than 10
		li $t2, 0
		sle $t2, $t2, $t1 #t2 = 1 if 0 <= t1
		and $t2, $t3, $t2
		beqz $t2, notDigit
		bne $t1, 1, outOfRange
		
		addi $t0, $t0, 1
		lbu $t1, 0($t0)
		addi $t1, $t1, -48
		sltiu $t3, $t1, 10 #t3 = 1 if t1 less than 10
		li $t2, 0
		sle $t2, $t2, $t1 #t2 = 1 if 0 <= t1
		and $t2, $t3, $t2
		beqz $t2, notDigit
		slti $t2, $t1, 5 #t2 - 1 if t1 less than 5
		beqz $t2, outOfRange
		move $s4, $t1
		addi $s4, $s4, 10
		li $s5, 1
	j end_checkEachCoord
	oneChar:
		lbu $t0, 0($t0)
		addi $t0, $t0, -48
		sltiu $t1, $t0, 10
		li $t2, 0
		sle $t2, $t2, $t0
		and $t2, $t1, $t2
		beqz $t2, notDigit
		move $s4, $t0
		li $s5, 1
	j end_checkEachCoord
	outOfRange:
		li $v0, 4
		la $a0, outOfRange_prompt
		syscall
		li $s5, 0
		j end_checkEachCoord
	leadingZero:
		li $v0, 4
		la $a0, leadingZero_prompt
		syscall
		li $s5, 0
		j end_checkEachCoord
	notDigit:
		li $v0, 4
		la $a0, notDigit_prompt
		syscall
		li $s5, 0
end_checkEachCoord:	
	jal stackOut
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
updateBoard:
# ---------------------------------------------------------------------------------------------------- #
#	Arguments:
#	$s0: 0 if player 1 else player 2
#	$s2: row
#	$s3: col
#	Return:
#	$s5: 1 if updated successfully else 0
#	Description: update both 'board' and 'displayBoard' 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	# Calculate the index in the board array (row_major: index = row * cols + col)
	li $t0, 15           # Number of columns in the board
	mul $t1, $s2, $t0    # row * cols
	add $t1, $t1, $s3    # row * cols + col = index in board array
	
	# Get the base address of the board array
	la $t2, board
	add $t2, $t2, $t1    # Actual memory address to update
	
	lb $t3, 0($t2)
	beqz $t3, notPreoccupied
	li $v0, 4
	la $a0, preOccupied_prompt
	syscall
	li $s5, 0
	j end_updateBoard
	
notPreoccupied:
	# Determine which value to store based on current player
	beqz $s0, player1_mark
	li $t3, 2            # Player 2 (O) = 2
	j store_mark
	
player1_mark:
	li $t3, 1            # Player 1 (X) = 1
	
store_mark:
	# Store the player's mark at the calculated position
	sb $t3, 0($t2)       # Update the board array with player's mark
	li $s5, 1
	
end_updateBoard:	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

# checkWinner:
# # ---------------------------------------------------------------------------------------------------- #
# #	Return:
# #	$s5: 1 if game ends, else 0
# #	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
# #	Description: check if any player win based on 'board', print Result message on terminal if game ends
# # ---------------------------------------------------------------------------------------------------- #
# 	addi $sp, $sp, -4
# 	sw $ra, 0($sp)
# 	jal stackIn
	
# 	#TODO
	
# 	jal stackOut
#  	lw $ra, 0($sp)
#  	addi $sp, $sp, 4
#  	jr $ra

# writeToFile:
# # ---------------------------------------------------------------------------------------------------- #
# #	Arguments:
# #	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
# #	Description: write last displayBoard and result to file
# # ---------------------------------------------------------------------------------------------------- #
# 	addi $sp, $sp, -4
# 	sw $ra, 0($sp)
# 	jal stackIn
	
# 	#TODO
	
# 	jal stackOut
#  	lw $ra, 0($sp)
#  	addi $sp, $sp, 4
#  	jr $ra
																																						
stackIn:
# ---------------------------------------------------------------------------------------------------- #
# Should use this to avoid wrong value of registers when call functions, NOTE that $ra is not included
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	sw $t3, 20($sp)
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	jr $ra
stackOut:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	lw $t3, 20($sp)
	sw $t4, 24($sp)
	sw $t5, 28($sp)
	addi $sp, $sp, 32
	jr $ra

	
	
	
