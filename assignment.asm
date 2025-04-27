.data
	#shared: board, rules prompt, continue prompt, invalid messages
	#each player: prompt to get coordinate
	board: .space #TODO
	displayBoard: .space #TODO
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
	jal promptCoord
	jal showBoard
	jal checkWinner #already printed winner message, return in $v0 1 if game ends, else 0
	beqz gamePlay

	jal writeToFile
	li $v0, 10
	syscall
	
displayRules:
# ---------------------------------------------------------------------------------------------------- #
#   Print rules in terminal 
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
makeBoard:
# ---------------------------------------------------------------------------------------------------- #
#   	Task1: Initialize 'board' one dimension array with size 15*15 row major order
#	Initial value of each entry is 0: 
#	Task2: Initialize 'displayBoard': _x_ then three space
# 	Row/Col   	 _0_   _1_   _2_   _3_   _4_   _5_   _7_   _8_   _9_   _10   _11   _12   _13   _14
#	    0 		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    1		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    2		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    3		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    4		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    5		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    6		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    7		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    8		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	    9		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	   10		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	   11		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	   12		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	   13		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
#	   14		 ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___   ___
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	
	jal stackOut
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4
 	jr $ra
 	
showBoard:
# ---------------------------------------------------------------------------------------------------- #
#   show displayBoard
# ---------------------------------------------------------------------------------------------------- #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal stackIn
	
	#TODO
	
	jal stackOut
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
	

	
	
