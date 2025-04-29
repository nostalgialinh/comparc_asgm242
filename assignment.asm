.data
	#shared: board, rules prompt, continue prompt, invalid messages
	#each player: prompt to get coordinate
	board: .space 225        # 15 x 15 = 225 cells
    	displayBoard: .space 1350 # each cell display 6 bytes, 225 * 6 = 1350
    	str_endl: .asciiz "\n"
    	str_space: .asciiz "   "
    	str_header: .asciiz "    _0_   _1_   _2_   _3_   _4_   _5_   _6_   _7_   _8_   _9_   _10   _11   _12   _13   _14\n"
	rules: .asciiz "abc"
	coordPrompt1: .asciiz "Player 1, please input your coordinates: "
	coordPrompt2: .asciiz "Player 2, please input your coordinates: "
	outRangeMsg: .asciiz "Coordinates out of range! Each coordinate must be between 0-14."
	occupiedCellMsg: .asciiz "Cell is already occupied."
	wrongFormatMsg: .asciiz "Coordinates input should be 'x,y' (Horizontal, Vertical) "
.text
	jal displayRules
	jal makeBoard
gamePlay:
	jal showBoard
	#jal promptCoord
	#jal showBoard
	#jal checkWinner #already printed winner message, return in $v0 1 if game ends, else 0
	#beqz gamePlay

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
	
	#jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
makeBoard:
# ---------------------------------------------------------------------------------------------------- #
#   Task1: Initialize 'board' one dimension array with size 15*15 row major order
#   Initial value of each entry is 0
#   Task2: Initialize 'displayBoard': _x_ then three spaces
# ---------------------------------------------------------------------------------------------------- #
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize board with 0
    la $t0, board       # $t0 = address of board
    li $t1, 0           # counter
    li $t2, 225         # total cells
init_board_loop:
    sb $zero, 0($t0)    # store 0
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    blt $t1, $t2, init_board_loop

    # Initialize displayBoard with "___   "
    la $t0, displayBoard
    li $t1, 0           # counter
init_display_loop:
    li $t2, 95          # ASCII '_'
    sb $t2, 0($t0)      # _
    sb $t2, 1($t0)      # _
    sb $t2, 2($t0)      # _
    li $t2, 32          # ASCII ' '
    sb $t2, 3($t0)      # space
    sb $t2, 4($t0)      # space
    sb $t2, 5($t0)      # space
    addi $t0, $t0, 6    # move to next cell
    addi $t1, $t1, 1
    li $t2, 225
    blt $t1, $t2, init_display_loop

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
 	
showBoard:
addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Print header (column numbers)
    li $v0, 4
    la $a0, str_header
    syscall

    # Print board
    la $t0, displayBoard  # $t0 = pointer to displayBoard
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

    li $t2, 0             # col counter

print_col:
    li $t4, 0             # inner counter for 6 chars
print_cell_char:
    lb $a0, 0($t0)        # load one byte from displayBoard
    li $v0, 11            # syscall to print character
    syscall
    addi $t0, $t0, 1      # move to next byte in displayBoard
    addi $t4, $t4, 1
    li $t5, 6             # 6 characters per cell
    blt $t4, $t5, print_cell_char

    addi $t2, $t2, 1
    li $t3, 15
    blt $t2, $t3, print_col

    # New line after row
    li $v0, 4
    la $a0, str_endl
    syscall

    addi $t1, $t1, 1
    li $t3, 15
    blt $t1, $t3, print_row

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
 	
promptCoord:
# ---------------------------------------------------------------------------------------------------- #
#   	Arguments:
#	$s0 contains flag: 0 - player 1 ; 1 - player 2
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	beqz handlePlayer2
	handlePlayer1:
		#prompt
		jal validateCoord #out: $v0: 0 --> invalid, 1 --> valid; $s2: row; $s3: col . Please print msg there
		beqz handlePlayer1
		j promptCoord_end
	handlePlayer2:
		#prompt
		jal validateCoord
		beqz handlePlayer2
promptCoord_end:
	jal updateBoard #in: $s2: row; $s3: col
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
	
	#TODO
	
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
#	Description: update both 'board' and 'displayBoard' 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra

checkWinner:
# ---------------------------------------------------------------------------------------------------- #
#	Return:
#	$v0: 1 if game ends, else 0
#	$s4: 0 if player 1 wins, 1 if player 2 wins, 2 if tie
#	Description: check if any player win based on 'board', print Result message on terminal if game ends
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	
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
	
	#TODO
	
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
	

	
	