#this is the starting file for cs2340 project1 tic-tac-toe game. 
# In this game the computer will place an X or O on a 3x3 board, and then the user will play
# by placing their token on one of the spaces left.
# the game ends when a line of the same 3 tokens is formed in any direction.
.data
debug: .asciiz "hi" 
welcome: .asciiz "Welcome to the game of tic-tac-toe!\n"
explanation: .asciiz "The board is numbered. Play your move by selecting the board cell number you wish.\n"
youAre: .asciiz  "You, the player, are O, the computer will be X.\n\n"
cell: .asciiz "Choose the cell to play in (1-9): "
cMove: .asciiz "Computer's move.\n"
pMove: .asciiz "Your move!\n"
cwin: .asciiz "Computer has won the game!\n"
pwin: .asciiz "Congratulations, you won!\n"
aTie: .asciiz "We tied! \n"
playAgain: .asciiz "Would you like to play again? (1 = yes, 2 = no) "

x: .asciiz "  X "
o: .asciiz "  O "
emptyFiller: .asciiz "    "
separator: .asciiz " | "
EOL: .asciiz "\n"

tableUpdate: .asciiz "This is table update with the computer's move:\n"

row1:		.asciiz "  1  |  2  |  3  "
row2:		.asciiz "  4  |  5  |  6  "
row3:		.asciiz "  7  |  8  |  9  \n"
border:		.asciiz "\n-----+------+-----\n"

board: .word 0,0,0,0,0,0,0,0,0    #the board's initial state
####breaking away from main code to just make a program counter

#array of winning combinations
win:   .word 1,2,3,4,5,6,7,8,9,1,4,7,2,5,8,3,6,9,1,5,9,3,5,7  

.text
.globl main

main:
	jal printInstructions 
	jal initializeBoard
	
	li $s0, 0 			#counter for turns
	li $s1, 4			#number of turns in pairs }(1,2),(3,4),(5,6),(7,8)}
	li $s5, 2                       #turn pairs until checkBoardWin starts
	
	#turn is missing 1 turn) 
	loop:  
		beq $s1, $s0, lastTurn	#if first 8 turns already done -> lastTurn
		
		addi $sp, $sp, -12	 
		sw $ra, 8($sp)		#push to ra stack
		sw $s0, 4($sp)		#push counter
		sw $s1, 0($sp)		#push number of turns
	
			
		jal playerMove
		jal computerTurn
		li $v0, 4
		la $a0,tableUpdate
		syscall	
		
		lw $ra, 8($sp)		#restore stack value
		lw $s0, 4($sp)		#restore counter for turns 
		lw $s1, 0($sp)		#restore number of turns
	
		addi $sp, $sp, 12	#add to stack	
		addi $s0, $s0, 1	#increment counter for turns 
		
		slt $s6, $s5, $s0 
		beq $s6, 1, checkBoardWinCondition
		ReturnBack:
		
		jal printTable	
		j loop

checkBoardWinCondition:
	jal checkBoardWin
	j ReturnBack

lastTurn: 
	jal playerMove
	jal printTable
	jal checkBoardWin
	
	li $v0, 4
	la $a0, aTie
	syscall				#display tie message
	
	li $v0, 4			#Ask the user if want to play again?
	la $a0, playAgain
	syscall 
	
	#Get the answer of the user
	li $v0, 5		
	syscall			
	move $a1, $v0  			#store the answer of the user
	
	li $t1, 1      			# If the user enter 1 is yes
	beq $a1,$t1,restartGame		#Check if is 1,restart the game
	li $t1, 2			#if the user enter 2 is no
	beq $a1,$t1, exitGame		#Check if it is 2, exit game
	
	j exitGame

#Name: 			printInstructions
#Purpose: 		This function prints the instructions of the game
#Variables Changed:	N/A
printInstructions: 
	addi $sp, $sp, -4	 
	sw $ra, 0($sp)		#push to stack
	
	#addi $v0, $zero, -1 	#return -1 t
	li $v0, 4
	la $a0, welcome
	syscall				#display welcome message
		
	li $v0, 4
	la $a0, explanation
	syscall				#display grid explanations
	
	li $v0, 4
	la $a0, youAre
	syscall
	
	#next five blocks display board
	li $v0, 4
	la $a0, row1
	syscall
	
	li $v0, 4
	la $a0, border
	syscall
	
	li $v0, 4
	la $a0, row2
	syscall
	
	li $v0, 4
	la $a0, border
	syscall
	
	li $v0, 4
	la $a0, row3
	syscall
	
	lw $ra, 0($sp)		#restore stack parameter
	addi $sp, $sp, 4	#add to stack
	
	jr $ra

#Name:			initializeBoard
#Function: 		sets up pointer to memory location of "board" 
#Variables Changed:	N/A
initializeBoard: 
	la $v0, board 
	jr $ra 

#Name: 			playerMove 
#Function:		Here, the function prompts the user
#			for the desired index on the board.
#			Then that index is passed to boardUpdate.
#Variables:		$a0 = flag for boardUpdate to distinguish between
#			user and pc. Takes in $v0 (index value) and puts it in 
#			$a0

	
playerMove: 
	la $t0, board		#loading array address
	addi $sp, $sp, -4 
	sw $ra, 0($sp) 
	
	#print user pronpt 
	li $v0, 4 
	la $a0, cell
	syscall 
	
	#Get desired board index
	li $v0, 5		
	syscall			
	move $a1, $v0  		#store number int in $a0 to pass to f(x)
	
	#Check the user to enter range from 1-9
	li $t1,1
	blt $a1,$t1,playerMove	#Check if below 1
	li $t1,9
	bgt $a1,$t1,playerMove	#Check if over 9   
	
	#Now check if position is empty or not
	sub $a1,$a1,1		#Subtract the selection to match with position of array
	
	move $a3, $zero		# set a3 back to 0
 	move $t3, $zero   	# set t3 back to 0
 	addu $a3,$a3,$a1	#Store the user input to a3, then we can use $a0 to flag
	sll  $t3,$a3, 2 	#Move to the position has choose
 	addu $t3,$t3,$t0	#Add to get the current memory location of arra
  	lw $t2,0($t3)		#Load the current value of the random position
	bne $t2,0,playerMove	#Check the value of current position is empty =0
	
	
	
	li $a0, 1 	#change flag for distinguishing between user/pc to user
	
	jal boardUpdate		#calling boardUpdate
	
	lw $ra, 0($sp) 
	addi $sp, $sp, 4 
	
	jr $ra


computerTurn: 
	la $t0, board		#loading array address
	li $v0,42		#Create random number call
  	li $a1,9		#Create the random number from range 0-8
  	syscall
  	move $a3, $zero		# set a3 back to 0
 	move $t3, $zero   	# set t3 back to 0
 	addu $a3,$a3,$a0	#Store the random number to a3, then we can use $a0 to flag
	sll $t3, $a3, 2 	#Move to the position has choose
 	addu $t3,$t3,$t0	#Add to get the current memory location of arra
  	lw $t2,0($t3)		#Load the current value of the random position
  	addi $s4, $s4, 1
  	beq $s4, 20, NoSpace
	bne $t2,0,computerTurn	#Check the value of current position is empty =0
	move $a1,$a3		#store number int in $a3 to pass to f(x)
	li $a0, 2 		#change flag for distinguishing between user/pc to user
	addi $sp, $sp, -4 
	sw $ra, 0($sp) 
	jal boardUpdate		
	lw $ra, 0($sp) 
	addi $sp, $sp, 4 
	
	NoSpace:
	li $s4, 0
	jr $ra
	
	
#Name: 			boardUpdate
#Function:		Here, the function takes in two arguments: 
#			$a0 and $a1 where they are respectively 
#			a flag for distinguishing between pc and user
#			and the index value the program will change
#Variables:		$a0, $a1, $t0 (used to hold the address of the board array)
boardUpdate: 
	addi $sp, $sp, -4	#move pointer to store return address
	sw $ra, 0($sp)		#push return address to stack
	
	la $t0, board		#loading array address
	
	sll $a1, $a1, 2		#multiple user input by 4 
	add $t0, $t0, $a1	#adding array address and offset 
	
	beq $a0,1, userChange	#if $a0 = 1 (if inputted by user) 
	beq $a0,2 computerChange	
		
	
	
	
		
	userChange: 			#if is user's turn
		li $t1, 1 	
		sw $t1, 0($t0)		#save 1 into array 
		j return
		
	computerChange:			#if is computer turn
		li $t1, 2 
		sw $t1, 0($t0)		#save "2" into array 
		j return 
	
	return: 
		lw $ra, 0($sp)		#restore stack value
		addi $sp, $sp, 4	# pop ra from stack
		jr $ra 
			
#Name: 			Print table
#Function:		This will load the address of table 
#			If the 0 it will be empty, and print " "
#			If the 1 it will be user, and print "O"
#			If the 2 it will be computer, and print "X"
printTable:
	addi $sp, $sp, -4	#move pointer to store retu
	sw $ra, 0($sp)		#push return address to stack
	la $t0, board           # Load the address of the board array into $t0
	li $t1, 9      # Load the size of the board array into $t1
	li $t2, 0               # Initialize the counter to 0 
	loop_printTable:
		beq $t2, $t1, exit_printTable      # If the counter equals the size of the board, exit the loop
		sll $t3, $t2, 2         # Multiply the counter by 4 to get the offset
 		add $t3, $t3, $t0       # Add the offset to the base address of the board array
 		lw $t4, 0($t3)          # Load the value at the current element into $t4

 		beq $t4,0, Empty		#Check if it empty we go to empty and print space
 		beq $t4,1, userCharacter	#If it user we print O
 		beq $t4,2, computerCharacter	#If it is computer we print X
 		comback: 			#This will help the branch comeback to loop
 			addi $t2, $t2, 1        # Increment the counter
 			beq $t2,3,printBorder	#This check if 3 we will enter the line
 			beq $t2,6,printBorder	#This check if 6 we will enter the line
 			beq $t2,9,printLine	#This check if 9 we will enter the line ( Actually not needed)
 			li $v0, 4
 			la $a0, separator
 			syscall
 			j loop_printTable
 			
 exit_printTable:
  	lw $ra, 0($sp) 
	addi $sp, $sp, 4 
	jr $ra
 
 printLine:
 	li $v0, 4
	la $a0,EOL		#print the new line
	syscall
 	
 	j loop_printTable	#back to the loop
 	
 printBorder:
 	li $v0, 4		
 	la $a0, border		#print the board
 	syscall
 	
 	j loop_printTable	#back to the loop
 	
 Empty:				#If the variable from table equal 0
 	li $v0, 4		# system call for printing string
	la $a0, emptyFiller	# load address of string to be printed
	syscall
	j comback			
 
 userCharacter:		#If the variable from table equal 1
	li $v0, 4		# system call for printing string
	la $a0, o		# load address of string to be printed
	syscall
	j comback
 
 computerCharacter:		#If the variable from table equal 2
  	li $v0, 4		# system call for printing string
	la $a0, x		# load address of string to be printed
	syscall
	j comback

checkBoardWin:
	#Check Row
	
	#t7 Total
	#t6 Loaded Value to be Added
	#t5 Local Row/Column/Diagonal Index
	#t8 Global Index
	#P1 Wins if total = 3
	#P2 Wins if total = 6
	
	la $s2, board#board address
	li $t5, 0 #local position in row index
	li $t8, 0 #global row index
	li $t7, 0
	li $s7, 0 #zero flag
	
	checkRow:
	lw $t6, 0($s2)#load value at index
	add $t7, $t7, $t6 #add value to total
	addi $t5, $t5, 1 #index counter
	addi $s2, $s2, 4 #next value address
	beq $s7, 0, zeroFlagRow
	ReturnBackFlagRow:
	bne $t5, 3, checkRow
	beq $s7, 1, zeroFlagSkipRow
	beq $t7, 3, userWin
	beq $t7, 6, computerWin
	
	#Check next row
	zeroFlagSkipRow:
	li $t5, 0
	li $t7, 0
	li $s7, 0 #zero flag
	addi $t8, $t8, 1
	bne $t8, 3, checkRow

#-----------------------------

	#Check Column
	#t7 Total
	#t6 Loaded Value to be Added
	#t5 Local Column Index
	#t8 Global Index
	#t9 Next Column Starting Count
	
	la $s2, board#board address
	li $t5, 0 #local position in column index
	li $t8, 0 #global column index
	li $s7 0 #zero flag
	
	checkColumn:
	lw $t6, 0($s2)#load value at index
	add $t7, $t7, $t6 #add value to total
	addi $t5, $t5, 1 #index counter
	addi $s2, $s2, 12 #next value address
	beq $s7, 0, zeroFlagColumn
	ReturnBackFlagColumn:
	bne $t5, 3, checkColumn
	beq $s7, 1, zeroFlagSkipColumn
	beq $t7, 3, userWin
	beq $t7, 6, computerWin
	
	#Check next column
	zeroFlagSkipColumn:
	li $t5, 0
	li $t7, 0
	li $t9, 0
	li $s7, 0 #zero flag
	addi $t8, $t8, 1
	la $s2, board #reset board address
		setNextColumn:
		addi $s2, $s2, 4 #next column value
		addi $t9, $t9, 1
		bne $t8, $t9, setNextColumn
	bne $t8, 3, checkColumn
	
#-----------------------------

	#Check Diagonal
	#t7 Total
	#t6 Loaded Value to be Added
	#t5 Local Diagonal Index
	#t8 Global Diagonal Index
	
	la $s2, board#board address
	li $t5, 0 
	li $t6, 0
	li $t7, 0
	li $t8, 0 
	li $t9, 0
	
	checkDiagonal:
	#First Diagonal
	lw $t5, 0($s2)#load value at index
	lw $t6, 16($s2)#load value at index
	lw $t7, 32($s2)#load value at index
	
	beqz $t5, zeroFlagSkipDiagonal1
	beqz $t6, zeroFlagSkipDiagonal1
	beqz $t7, zeroFlagSkipDiagonal1
	
	add $t8, $t5, $t6 #add value to total
	add $t8, $t8, $t7 #add value to total
	
	beq $t8, 3, userWin
	beq $t8, 6, computerWin
	
	#Second Diagonal
	zeroFlagSkipDiagonal1:
	lw $t5, 8($s2)#load value at index
	lw $t6, 16($s2)#load value at index
	lw $t7, 24($s2)#load value at index
	
	beqz $t5, zeroFlagSkipDiagonal2
	beqz $t6, zeroFlagSkipDiagonal2
	beqz $t7, zeroFlagSkipDiagonal2
	
	add $t8, $t5, $t6 #add value to total
	add $t8, $t8, $t7 #add value to total
	
	beq $t8, 3, userWin
	beq $t8, 6, computerWin

	zeroFlagSkipDiagonal2:
#-----------------------------
	jr $ra

zeroFlagRow:
	beqz $t6, zeroCheckRow
	j ReturnBackFlagRow

zeroFlagColumn:
	beqz $t6, zeroCheckColumn
	j ReturnBackFlagColumn
	
zeroCheckRow:
	li $s7, 1
	j ReturnBackFlagRow
	
zeroCheckColumn:
	li $s7, 1
	j ReturnBackFlagColumn
	
userWin:
	li $t1, 0
	sw $t1, 0($t0)
	jal printTable
	li $v0, 4
	la $a0, pwin
	syscall				#display Player Win message
	
	li $v0, 4			#Ask the user if want to play again?
	la $a0, playAgain
	syscall 
	
	#Get the answer of the user
	li $v0, 5		
	syscall			
	move $a1, $v0  			#store the answer of the user
	
	li $t1, 1      			# If the user enter 1 is yes
	beq $a1,$t1,restartGame		#Check if is 1,restart the game
	li $t1, 2			#if the user enter 2 is no
	beq $a1,$t1, exitGame		#Check if it is 2, exit game
	
	

computerWin:
	jal printTable
	li $v0, 4
	la $a0, cwin
	syscall				#display Computer Win message
	
	li $v0, 4			#Ask the user if want to play again?
	la $a0, playAgain
	syscall
	
	#Get the answer of the user
	li $v0, 5		
	syscall			
	move $a1, $v0  			#store the answer of the user
	
	li $t1, 1      			# If the user enter 1 is yes
	beq $a1,$t1,restartGame		#Check if is 1,restart the game
	li $t1, 2			#if the user enter 2 is no
	beq $a1,$t1, exitGame		#Check if it is 2, exit game
	


restartGame:
	la $s0, board
	li $t0, 0			# Initialize a counter to zero
	loop_restartGame:
    		beq $t0, 9, done  	# Check if $t1 < 9
  		sll $t1, $t0, 2   	# Calculate the address of the current board elemen
    		add $t1, $t1, $s0 	# Add the base address of the board arra
    		sw $zero,0($t1)   	# Set the current board element to zero
   		addi $t0, $t0, 1  	# Increment the counter
    		j loop_restartGame      # Jump back to the beginning of the loop
	done:
    	# Game board has been reset to 0
    	j main
    	
exitGame:
	li $v0, 10
	syscall 
	
