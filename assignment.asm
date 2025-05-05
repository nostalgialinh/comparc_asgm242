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

	tie:            .asciiz "* TIE CONDITION *\nAll 225 cells are filled with no winner - the game announces:\n\"Tie\"\n"

	player1win : .asciiz "Player 1 wins\n" #14 (does not count '0')
	player2win : .asciiz "Player 2 wins\n" #14
	playertie : .asciiz "Tie\n" #4
	
	#data for prompt coordinate
	coord: .space 128
	invalidFormat_prompt: .asciiz "WARNING: Invalid format. Format must be X,Y (horiz,verti). Input again.\n"
	outOfRange_prompt: .asciiz "WARNING: Coordinate out of range. Must be between 0-14. Input again.\n"
	notDigit_prompt: .asciiz "WARNING: Coordinate contains non-digit. Input again.\n"
	leadingZero_prompt: .asciiz "WARNING: Coordinate has leading zero but more than one digit. Input again.\n"
	preOccupied_prompt: .asciiz "WARNING: Coordinates already occupied. Input again.\n"
	
	#output file
	outputFile: .asciiz "result.txt"
.text
	jal displayRules
	
	li $v0, 4
	la $a0, str_endl
	syscall
	
	jal makeBoard
	li $t8, 0
	li $t9, 2
gamePlay:
	rem $s0, $t8, $t9
	jal showUpdatedBoard
	jal promptCoord
	jal checkWinner  #already printed winner message, return in $s5 1 if game ends, else 0
	addi $t8, $t8, 1
	beq $s5, 0, gamePlay
	jal showUpdatedBoard
	jal winnerMessage #$s5: 1 if game ends, else 0	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
	jal writeToFile
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
#   	Task1: Initialize 'board' one dimension array with size 15*15 row major order
#   	Initial value of each entry is 0
#   	Task2: Initialize 'displayBoard': __ 
#	Shape of displayBoard: #header: 5 spaces + column, each cell '_D_  ' -> 5 + 6*14 + 1 ('\n') = 90 (0-89)
#     _0_   _1_   _2_   _3_   _4_   _5_   _6_   _7_   _8_   _9_   _10   _11   _12   _13   _14   
#0    ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___      
#					.......................................  
#14   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	la $a1, board         # base address of board
	li $t0, 0
	li $t1, 225           # total entries
	init_board_loop:
		sb $zero, ($a1)       # store 0 at board[t0]
		addi $a1, $a1, 1      # move to next byte
		addi $t0, $t0, 1      # increment index
		bne $t0, $t1, init_board_loop
 
 	#header: 5 spaces + column, each cell '_D_  ' -> 5 + 6*14 + 1 ('\n') = 90 (0-89)
 	la $t0, displayBoard
	li $t1, 5
	li $t2, 32
	
	write_5_spaces:
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, -1
	bgtz $t1, write_5_spaces

	li $t1, 0
	li $t2, 10
	li $t3, 32
	li $t4, 95
	header_oneDigit:
	sb $t4, 0($t0)
	sb $t4, 2($t0)
	sb $t3, 3($t0)
	sb $t3, 4($t0)
	sb $t3, 5($t0)
	addi $t5, $t1, 48 # corresponding ascii for digit
	sb $t5, 1($t0)
	addi $t0, $t0, 6
	addi $t1, $t1, 1
	addi $t2, $t2, -1
	bnez $t2, header_oneDigit
	
	#t0 already at new place
	li $t1, 0
	li $t2, 5
	li $t3, 32
	li $t4, 95
	li $t6, 49
 	header_twoDigit:#10 to 14
	sb $t4, 0($t0)
	sb $t6, 1($t0)
	sb $t3, 3($t0)
	sb $t3, 4($t0)
	sb $t3, 5($t0)
	addi $t5, $t1, 48 # corresponding ascii for digit
	sb $t5, 2($t0)
	addi $t0, $t0, 6
	addi $t1, $t1, 1
	addi $t2, $t2, -1
	bnez $t2, header_twoDigit 	
 	
 	li $t1, 10
 	sb $t1, 0($t0)
 	addi $t0, $t0, 1
 	
 	#each row
 	li $s0, 0 #index
 	li $s1, 15
 	li $t5, 10
 	displayBoard_rowInit:
 	div $s0, $t5
 	li $t2, 32
 	mflo $t1
 	beqz $t1, rowInit_oneDigit
 	#rowInit_twoDigit
 	li $t1, 49
 	sb $t1, 0($t0)
 	addi $t0, $t0, 1
 	mfhi $t1
 	addi $t1, $t1, 48
 	sb $t1, 0($t0)
 	addi $t0, $t0,1
 	li $t1, 3
 	j write_n_spaces
 	rowInit_oneDigit:
 	addi $t1, $s0, 48
 	sb $t1, 0($t0)
 	addi $t0, $t0, 1
 	li $t1, 4
 	
 	
 	write_n_spaces:
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, -1
	bgtz $t1, write_n_spaces
	
	li $t1, 0
	li $t2, 15
	li $t3, 95
	li $t4, 32
	loopEachRow:
	sb $t3, 0($t0)
	sb $t3, 1($t0)
	sb $t3, 2($t0)
	sb $t4, 3($t0)
	sb $t4, 4($t0)
	sb $t4, 5($t0)
	addi $t0, $t0, 6
	addi $t1, $t1, 1
	bne $t1, $t2, loopEachRow
	
	li $t1,  10
	sb $t1, 0($t0)
	addi $t0, $t0,1
	addi $s0, $s0, 1
	bne $s0, $s1, displayBoard_rowInit
 	
 	sb $0, 0($t0)
 	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

showUpdatedBoard:
# ---------------------------------------------------------------------------------------------------- #
#	Print display board
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	la $a0, displayBoard
	li $v0, 4
	syscall

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
	li $s5, 0 #Failed to update
	j end_updateBoard
	
notPreoccupied:
	# Determine which value to store based on current player
	beqz $s0, player1_mark
	li $t3, 2	# Player 2 (O) = 2
	li $t4, 79	# O
	j store_mark
	
player1_mark:
	li $t3, 1	# Player 1 (X) = 1
	li $t4, 88	# X
	
store_mark:
	# Store the player's mark at the calculated position
	sb $t3, 0($t2)       # Update the board array with player's mark
	
	#Update displayBoard. displayBoard index: (row+1)*96 + 5 + col*6 + 1.
	#(explain: row+1 because we have header; col*6+2 because '_M_   ' is each cell having 6 characters, and M is at index 1 of each cell)
	#5 is number indexing characters for row coordianate
	li $t1, 96
	addi $s0, $s2, 1
	mul $s0, $s0, $t1	#(row+1)*96
	addi $s0, $s0,5		#(row+1)*96 +5
	li $t1, 6
	mul $t1, $s3, $t1	#col*6
	add $s0, $s0, $t1	#(row+1)*96 +5 + col*6
	addi $s0, $s0 ,1		#(row+1)*96 +5+ col*6 + 1
	la $t1, displayBoard
	add $s0, $s0, $t1 # Actual memory address of displayBoard to update
	sb $t4, 0($s0)
	
	li $s5, 1	#Update successfully
end_updateBoard:	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

checkWinner:
# ---------------------------------------------------------------------------------------------------- #
#	Return:
#	$s5: 1 if game ends, else 0
#	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
#	Description: check if any player win based on 'board', print Result message on terminal if game ends
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	addi $sp, $sp, -4
	sw $t8, 0($sp)
	addi $sp, $sp, -4
	sw $t9, 0($sp)

	
	# Initialize return values
	li $s5, 0           # Game not ended by default
	li $s4, 2           # Default to tie (will be updated if someone wins)
	
	# Check for horizontal wins
	li $t0, 0           # row counter
horizontal_loop_row:
	li $t1, 0           # column counter
horizontal_loop_col:
	# Check if we have enough space for 5 in a row horizontally
	li $t3, 10          # Maximum column index to start a 5-in-a-row (15-5)
	bgt $t1, $t3, horizontal_next_row   # Skip if not enough space
	
	# Calculate start position in board array
	li $t3, 15          # Board width
	mul $t4, $t0, $t3   # row * width
	add $t4, $t4, $t1   # index = row * width + col
	la $t5, board       # board base address
	add $t5, $t5, $t4   # address of current cell
	
	# Load the value at current position
	lb $t6, 0($t5)      # t6 = current cell value
	beqz $t6, horizontal_next_col  # Skip empty cells
	
	# Check next 4 positions horizontally
	li $t7, 1           # counter for consecutive pieces
	move $t8, $t5       # copy current address
	move $t9, $t6       # remember player mark
horizontal_check:
	addi $t8, $t8, 1    # next cell horizontally
	lb $t6, 0($t8)      # load next cell
	bne $t6, $t9, horizontal_next_col  # break if different player or empty
	
	addi $t7, $t7, 1    # increment counter
	li $t3, 5           # need 5 to win
	beq $t7, $t3, winner_found  # 5 consecutive pieces found
	
	j horizontal_check  # continue checking
	
horizontal_next_col:
	addi $t1, $t1, 1    # next column
	li $t3, 15
	blt $t1, $t3, horizontal_loop_col
	
horizontal_next_row:
	addi $t0, $t0, 1    # next row
	li $t3, 15
	blt $t0, $t3, horizontal_loop_row
	
	# Check for vertical wins
	li $t0, 0           # row counter
vertical_loop_row:
	li $t1, 0           # column counter
vertical_loop_col:
	# Check if we have enough space for 5 in a row vertically
	li $t3, 10          # Maximum row index to start a 5-in-a-row (15-5)
	bgt $t0, $t3, vertical_next_col   # Skip if not enough space
	
	# Calculate start position in board array
	li $t3, 15          # Board width
	mul $t4, $t0, $t3   # row * width
	add $t4, $t4, $t1   # index = row * width + col
	la $t5, board       # board base address
	add $t5, $t5, $t4   # address of current cell
	
	# Load the value at current position
	lb $t6, 0($t5)      # t6 = current cell value
	beqz $t6, vertical_next_col  # Skip empty cells
	
	# Check next 4 positions vertically
	li $t7, 1           # counter for consecutive pieces
	move $t8, $t5       # copy current address
	move $t9, $t6       # remember player mark
vertical_check:
	addi $t8, $t8, 15   # next cell vertically (add one row)
	lb $t6, 0($t8)      # load next cell
	bne $t6, $t9, vertical_next_col  # break if different player or empty
	
	addi $t7, $t7, 1    # increment counter
	li $t3, 5           # need 5 to win
	beq $t7, $t3, winner_found  # 5 consecutive pieces found
	
	j vertical_check    # continue checking
	
vertical_next_col:
	addi $t1, $t1, 1    # next column
	li $t3, 15
	blt $t1, $t3, vertical_loop_col
	
vertical_next_row:
	addi $t0, $t0, 1    # next row
	li $t3, 15
	blt $t0, $t3, vertical_loop_row
	
	# Check for diagonal wins (down-right direction: \)
	li $t0, 0           # row counter
diag_dr_loop_row:
	li $t1, 0           # column counter
diag_dr_loop_col:
	# Check if we have enough space for 5 in a row diagonally (down-right)
	li $t3, 10          # Maximum row/col index to start a 5-in-a-row (15-5)
	bgt $t0, $t3, diag_dr_next_col   # Skip if not enough space vertically
	bgt $t1, $t3, diag_dr_next_row   # Skip if not enough space horizontally
	
	# Calculate start position in board array
	li $t3, 15          # Board width
	mul $t4, $t0, $t3   # row * width
	add $t4, $t4, $t1   # index = row * width + col
	la $t5, board       # board base address
	add $t5, $t5, $t4   # address of current cell
	
	# Load the value at current position
	lb $t6, 0($t5)      # t6 = current cell value
	beqz $t6, diag_dr_next_col  # Skip empty cells
	
	# Check next 4 positions diagonally (down-right)
	li $t7, 1           # counter for consecutive pieces
	move $t8, $t5       # copy current address
	move $t9, $t6       # remember player mark
diag_dr_check:
	addi $t8, $t8, 16   # next cell diagonally (add one row + one column)
	lb $t6, 0($t8)      # load next cell
	bne $t6, $t9, diag_dr_next_col  # break if different player or empty
	
	addi $t7, $t7, 1    # increment counter
	li $t3, 5           # need 5 to win
	beq $t7, $t3, winner_found  # 5 consecutive pieces found
	
	j diag_dr_check     # continue checking
	
diag_dr_next_col:
	addi $t1, $t1, 1    # next column
	li $t3, 15
	blt $t1, $t3, diag_dr_loop_col
	
diag_dr_next_row:
	addi $t0, $t0, 1    # next row
	li $t3, 15
	blt $t0, $t3, diag_dr_loop_row
	
	# Check for diagonal wins (down-left direction: /)
	li $t0, 0           # row counter
diag_dl_loop_row:
	li $t1, 0           # column counter
diag_dl_loop_col:
	# Check if we have enough space for 5 in a row diagonally (down-left)
	li $t3, 10          # Maximum row index to start a 5-in-a-row (15-5)
	bgt $t0, $t3, diag_dl_next_col   # Skip if not enough space vertically
	li $t3, 4           # Minimum col index to start a 5-in-a-row
	blt $t1, $t3, diag_dl_next_col   # Skip if not enough space horizontally
	
	# Calculate start position in board array
	li $t3, 15          # Board width
	mul $t4, $t0, $t3   # row * width
	add $t4, $t4, $t1   # index = row * width + col
	la $t5, board       # board base address
	add $t5, $t5, $t4   # address of current cell
	
	# Load the value at current position
	lb $t6, 0($t5)      # t6 = current cell value
	beqz $t6, diag_dl_next_col  # Skip empty cells
	
	# Check next 4 positions diagonally (down-left)
	li $t7, 1           # counter for consecutive pieces
	move $t8, $t5       # copy current address
	move $t9, $t6       # remember player mark
diag_dl_check:
	addi $t8, $t8, 14   # next cell diagonally (add one row - one column)
	lb $t6, 0($t8)      # load next cell
	bne $t6, $t9, diag_dl_next_col  # break if different player or empty
	
	addi $t7, $t7, 1    # increment counter
	li $t3, 5           # need 5 to win
	beq $t7, $t3, winner_found  # 5 consecutive pieces found
	
	j diag_dl_check     # continue checking
	
diag_dl_next_col:
	addi $t1, $t1, 1    # next column
	li $t3, 15
	blt $t1, $t3, diag_dl_loop_col
	
diag_dl_next_row:
	addi $t0, $t0, 1    # next row
	li $t3, 15
	blt $t0, $t3, diag_dl_loop_row
	
	# Check for tie: If no winner and board is full
	la $t0, board        # board base address
	li $t1, 0            # counter for board cells
	li $t2, 225          # total board cells
check_tie_loop:
	lb $t3, 0($t0)      # load cell value
	beqz $t3, not_tie   # if any cell is empty, not a tie
	addi $t0, $t0, 1    # move to next cell
	addi $t1, $t1, 1    # increment counter
	blt $t1, $t2, check_tie_loop
	
	# All cells filled without winner = tie
	li $s4, 2           # tie (2)
	li $s5, 1           # game ended
	j end_checkWinner
	
not_tie:
	# Game continues
	li $s5, 0           # game not ended
	j end_checkWinner
	
winner_found:
	# t9 contains the winner's mark (1 for player 1, 2 for player 2)
	li $t3, 1
	beq $t9, $t3, player1_wins
	
	# Player 2 wins
	li $s4, 1           # player 2 (1)
	j announce_winner
	
player1_wins:
	li $s4, 0           # player 1 (0)
	
announce_winner:
	li $s5, 1           # game ended
	
end_checkWinner:

	lw $t9, 0($sp)
	addi $sp, $sp, 4
	lw $t8, 0($sp)
	addi $sp, $sp, 4

	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

winnerMessage:
# ---------------------------------------------------------------------------------------------------- #
#	$s5: 1 if game ends
#	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn

	beq $s4, 0, printPlayer1win
	beq $s4, 1, printPlayer2win
	beq $s4, 2, printTie


printPlayer1win:

	li $v0, 4
	la $a0, player1win
	syscall

	j returnMsg

printPlayer2win:
	li $v0, 4
	la $a0, player2win
	syscall

	j returnMsg
	

printTie:
	li $v0, 4
	la $a0, playertie
	syscall

	j returnMsg
	
returnMsg:

	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

writeToFile:
# ---------------------------------------------------------------------------------------------------- #
#	Arguments:
#	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
#	Description: write last displayBoard and result to file
# ---------------------------------------------------------------------------------------------------- #
 	addi $sp, $sp, -4
 	sw $ra, 0($sp)
 	jal stackIn
	
	#prepare input buffer
	# 1536(displayBoard) is '\0'
	la $s0, displayBoard
	addi $s0, $s0, 1536
	
	li $t1, 2
	li $t0, 0 #current index
	beq $s4, $t1, writeTie
	beqz $s4, writePlayer1
	#writePlayer2
	li $t1, 13 #string length
	la $t2, player2win #address of string
	j loopPrepare
	writePlayer1:
	li $t1, 13 #string length
	la $t2, player1win #address of string
	j loopPrepare
	writeTie:
	li $t1, 3 #string length
	la $t2, playertie #address of string	
		
	loopPrepare:
	lb $t3, 0($t2)
	sb $t3, 0($s0)
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	addi $s0, $s0, 1
	bne $t0, $t1, loopPrepare
	
	sb $0, 0($s0)
	
 	#open file
 	li $v0, 13
 	la $a0, outputFile
 	li $a1, 1
 	syscall
 	move $a0, $v0 #save file discriptor
 	
 	li $v0, 15
 	la $a1, displayBoard
 	addi $a2, $t1, 1537 #1536  + length string + 1
 	syscall
 	
 	li $v0, 16
 	syscall
 	
 	jal stackOut
  	lw $ra, 0($sp)
  	addi $sp, $sp, 4
  	jr $ra
																																						
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
