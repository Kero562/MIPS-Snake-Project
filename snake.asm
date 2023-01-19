#=========================================================================================#
#     *            *            *            *            *            *            *     #
#=========================================================================================#
#                                                                                         #
# Final Project: Snake                                                                    #
# Group Name: Team Avengers                                                               #
# Group Members:                                                                          #
#	Alexander Eckert                                                                  #
#	Jessica Ortega                                                                    #
#	Kerolos Khalil                                                                    #
#	Benen Kim                                                                         # 
#                                                                                         #
# Objective: Create a playable snake game using MIPS and Assembly Programming             #
#                                                                                         #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                                                                                         #
# Our project will be utilizing the MIPS Bitmap Display and Keyboard MMIO Simulator.      #
# When executing the project please use the Bitmap Display with the following settings:   #
#                                                                                         # 
#	Unit Width in Pixels:        16                                                   #       
#	Unit Height in Pixels:       16                                                   #        
# 	Display Width in Pixels:     512                                                  #
#	Display Height in Pixels:    512                                                  #            
#	Base address for display:    $gp (global pointer)                                 #    
#                                                                                         #
# For best performance, reset keyboard simulator between games.                           # 
#                                                                                         #                          
#=========================================================================================#
#     *            *            *            *            *            *            *     #
#=========================================================================================#





.data

screenWidth: 	.word 32            #Set screen width
screenHeight: 	.word 32            #Set screen height

snakeSpeed:	.word 60            #Lower number means faster snake (less wait between frame updates)

score: 		.word 0             #Set score counter, increases by 10 for each apple eaten

#Snake initialization
snakeHeadX: 	.word 7             #Snake head x coordinate
snakeHeadY:	.word 25            #Snake head y coordinate
snakeTailX:	.word 5             #Snake tail x coordinate
snakeTailY:	.word 25            #Snake tail y coordinate

#Colors
snakeColor: 	.word 0xC29979      #Set snake color
bgColor:        .word 0xCDEAC0      #Set background color
gridColor:      .word 0xB6E697      #set grid color
borderColor:    .word 0x50723C      #Set wall color
appleColor: 	.word 0xE7471D      #Set apple color
saveColor:      .word 0xCDEAC0      #mutable color

direction:	.word 100           #Snake default direction
tailDirection:	.word 100           #Tail default direction
#=========================================================================================#
#                                                                                         #
# The game will be receiving character inputs from the keyboard.                          #                                     
# Specifically w, a, s, and d.                                                            #  
# 	Move up:                 119 (ascii w)                                            #  
# 	Move left:               97 (ascii a)                                             #   
# 	Move down:               115 (ascii s)                                            #    
# 	Move right:              100 (ascii d)                                            #   
#       Increase snake speed:    43 (ascii +)                                             #
#       Decrease snake speed:    45 (ascii -)                                             #
#       Reset snake speed:       61 (ascii =)                                             #
#                                                                                         #
#=========================================================================================#

directionChangeAddressArray:	.word 0:10000  #used to store the position of a direction change
newDirectionChangeArray:	.word 0:10000  #used to store the new direction
arrayLength:			.word 0        #numer of direction changes * 4
nextDirection:		        .word 0        #Next direction to update tail
#=========================================================================================#  
#                                                                                         #
# The tail must follow the same path the head takes. Every time the snake changes         #
# direction, we save the location of the change and the new direction in respective       #
# arrays. Whenever a tail segment reaches a position in the array, its direction will be  #
# updated.                                                                                #
#                                                                                         #
#=========================================================================================#

#Apple declaration
applePositionX: .word 100
applePositionY: .word 100

cheatCodes:     .word 0

gameOver:	.asciiz "   GAME OVER\n\nHigh Score: 1470\nYour Score: "





.text

StartGame:
    	
	#reinitialize all variables to default settings
	li $t0, 7
	sw $t0, snakeHeadX
	li $t0, 5
	sw $t0, snakeTailX
	li $t0, 25
	sw $t0, snakeHeadY
	sw $t0, snakeTailY
	li $t0, 100
	sw $t0, direction
	sw $t0, tailDirection
	li $t0, 60
	sw $t0, snakeSpeed
	sw $zero, score 
	lw $t0, nextDirection
	sw $t0, arrayLength
	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	
	#Draw background to Bitmap Display
	lw $a0, screenWidth       #get screen width
	lw $a1, bgColor           #get background color
	mul $a2, $a0, $a0         #square screen width to get the total number of pixels
	mul $a2, $a2, 4           #each pixel is represented by a word, each word consisting of 4 bytes
	add $a2, $a2, $gp         #add base of gp
	add $a0, $gp, $zero       #loop counter
	FillLoop:                 #draw Bitmap display
	sw $a1, 0($a0)            #color pixel
	addiu $a0, $a0, 4         #increment counter
	blt $a0, $a2, FillLoop    #continue until all pixels colored
#=========================================================================================#
#                                                                                         #
# The Bitmap display is a grid of pixels. This grid has a height and width. To fill in    #
# the dispay, we must iterate through every pixel and set its color. Each pixel is saved  #
# in memory as one word or four bytes. Thirty two subsequent words in memory represents   #
# one row of the Bitmap display. The next thirty two words represent the second row of    #
# pixels in the display. Therefore, there is a 32x32 block of words in the memory         #
# dedicated to drawing the Bitmap display. We are using $gp (global pointer) as the base  #
# address for referencing these words.                                                    #
#                                                                                         #
#=========================================================================================#		

	#Draw grid to Bitmap Display, we're making a checker board
	lw $a0, screenWidth        #get screen width
	lw $a1, gridColor          #get grid color
	mul $a2, $a0, $a0          #square screen width to get the total number of pixels
	mul $a2, $a2, 4            #each pixel is represented by a word, each word consisting of 4 bytes
	add $a2, $a2, $gp          #add base of gp
	add $a0, $gp, $zero        #loop counter
	li $a3, 0                  #stagger counter
	FillLoop2:                 #draw Bitmap display
	sw $a1, 0($a0)             #color pixel
	addiu $a0, $a0, 8          #increment counter so every other thing is colored
	addiu $a3, $a3, 1          #increment stagger counter
	beq $a3, 16, Stagger       #finished drawing a row, time to stagger
	beq $a3, 32, Stagger2      #finished drawing a row, time to stagger
	blt $a0, $a2, FillLoop2    #continue until all pixels colored
	Stagger:
	addiu $a0, $a0, 4          #stagger the grid color by one pixel each row
	blt $a0, $a2, FillLoop2    #go back to coloring grid
	Stagger2:
	subiu $a0, $a0, 4          #stagger the grid color by one pixel each row
	li $a3, 0                  #reset stagger counter
	blt $a0, $a2, FillLoop2    #go back to coloring grid

	#draw walls
	li $t1, 0		   #Y-coordinate, we will increase $t1 to draw left wall
	LeftWall:
	move $a1, $t1	  	   #move Y-coordinate into $a1
	li $a0, 0		   #load x coordinate to 0, doesnt change
	jal CoordinateToAddress    #get screen coordinates
	move $a0, $v0	           #move screen coordinates into $a0
	lw $a1, borderColor	   #get wall color
	jal DrawPixel	           #draw the pixel
	add $t1, $t1, 1        	   #increment y coordinate
	bne $t1, 32, LeftWall	   #loop through to draw entire left border
	
	li $t1, 0	           #load Y coordinate for right border
	RightWall:                 #repeat for right wall
	move $a1, $t1	           #move y coordinate into $a1
	li $a0, 31	           #set x coordinate to 31 (right edge of bitmap)
	jal CoordinateToAddress	   #convert to screen coordinates
	move $a0, $v0	           # move coordinates into $a0
	lw $a1, borderColor	   #move color data into $a1
	jal DrawPixel	           #draw color at screen coordinates
	add $t1, $t1, 1	           #increment y coordinate
	bne $t1, 32, RightWall	   #loop through to draw entire right border
	
	li $t1, 0	           #load X coordinate for top border
	TopWall:
	move $a0, $t1	           # move x coordinate into $a0
	li $a1, 0	           # set y coordinate to zero for top of screen
	jal CoordinateToAddress	   #get screen coordinate
	move $a0, $v0	           #  move screen coordinates to $a0
	lw $a1, borderColor	   # store color data to $a1
	jal DrawPixel	           #draw color at screen coordinates
	add $t1, $t1, 1            #increment X position
	bne $t1, 32, TopWall       #loop through to draw entire top border
	
	li $t1, 0	           #load X coordinate for bottom border
	BottomWall:
	move $a0, $t1	           # move x coordinate to $a0
	li $a1, 31	           # load Y coordinate for bottom of screen
	jal CoordinateToAddress	   #get screen coordinates
	move $a0, $v0	           #move screen coordinates to $a0
	lw $a1, borderColor	   #put color data into $a1
	jal DrawPixel	           #draw color at screen position
	add $t1, $t1, 1	           #increment X coordinate
	bne $t1, 32, BottomWall	   # loop through to draw entire bottom border

DrawBabySnake:
	#draw snake head
	lw $a0, snakeHeadX         #load x coordinate
	lw $a1, snakeHeadY         #load y coordinate
	jal CoordinateToAddress    #get screen coordinates
	move $a0, $v0              #copy coordinates to $a0
	lw $a1, snakeColor         #store color into $a1
	jal DrawPixel	           #draw color at pixel
	
	#draw middle portion
	lw $a0, snakeHeadX         #load x coordinate
	lw $a1, snakeHeadY         #load y coordinate
	sub $a0, $a0, 1
	jal CoordinateToAddress    #get screen coordinates
	move $a0, $v0              #copy coordinates to $a0
	lw $a1, snakeColor         #store color into $a1
	jal DrawPixel	           #draw color at pixel
	
	#draw snake tail
	lw $a0, snakeTailX         #load x coordinate
	lw $a1, snakeTailY         #load y coordinate
	jal CoordinateToAddress    #get screen coordinates
	move $a0, $v0              #copy coordinates to $a0
	lw $a1, snakeColor         #store color into $a1
	jal DrawPixel	           #draw color at pixel


DrawApple:
	li $v0, 42                 #syscall for random int with a upper bound
	li $a1, 30                 #upper bound 30 (0 <= $a0 < $a1)
	syscall
	addiu $a0, $a0, 1          #increment the X position so it doesnt draw on a border
	sw $a0, applePositionX     #store X position
	syscall
	addiu $a0, $a0, 1          #increment the Y position so it doesnt draw on a border
	sw $a0, applePositionY     #store Y position

#=========================================================================================#
#                                                                                         #
# The snake speed setting is not the speed of the snake, but the rest time between frame  #
# updates. If the snake speed is 60, the system checks every 60 miliseconds for new user  #
# inout from the keyboard simulator.                                                      #
#                                                                                         #
#=========================================================================================#
InputCheck:
	lw $a0, snakeSpeed             #get sleep time
	jal Pause                      #sleep for that amount

	lw $a0, snakeHeadX             #get snake's current x position
	lw $a1, snakeHeadY             #get snake's current y position
	jal CoordinateToAddress        #get coordinates for snake head in case of user input
	add $a2, $v0, $zero            #save coordinates to $a2

	li $t0, 0xffff0000             #MIPS processor I/O space is reserved from 0xffff0000 to 0xffffffff
	lw $t1, ($t0)                  #move it to $t1
	andi $t1, $t1, 0x0001          #if there was input, this will return something other than 0
	beqz $t1, SelectDrawDirection  #if no new input, snake continues in same direction
	lw $a1, 4($t0)                 #get the decimal ascii value of the input
	
DirectionCheck:	
	lw $a0, direction              #load current direction into $a0
	
	beq $a1, 43, Fast              #snake go zoom
	beq $a1, 45, Slow              #slow snake 
	beq $a1, 61, Norm              #reset speed

	beq $a1, 119, Continue
	beq $a1, 97, Continue
	beq $a1, 100, Continue
	beq $a1, 115, Continue
	lw $a1, direction              #continue in same direction
	j SelectDrawDirection          #if input in invalid, don't change current direction
	Continue:

	jal CheckDirection	       #make sure the snake isn't doing a 180, $a0 current direction, $a1 new direction
	beqz $v0, InputCheck	       #if input is not valid, get new input, otherwise
	sw $a1, direction	       #store the new direction
	
	lw $t7, direction	       #load the direction into $t7
			
SelectDrawDirection:
	beq $t7, 119, DrawUpLoop       #if character entered was 'w', draw up
	beq $t7, 97, DrawLeftLoop      #if character entered was 'a', draw left
	beq $t7, 115, DrawDownLoop     #if character entered was 's', draw down
	beq $t7, 100, DrawRightLoop    #if character entered was 'd', draw right
	
	j InputCheck                   #if unsupported character was entered           
	
Fast:
	lw $t2, snakeSpeed
	subi $t2, $t2, 10
	sw $t2, snakeSpeed             #make snake go fast
	lw $a1, direction              #continue in same direction
	j SelectDrawDirection
Slow:
	lw $t2, snakeSpeed
	addi $t2, $t2, 10
	sw $t2, snakeSpeed             #make snake go slow
	lw $a1, direction              #continue in same direction
	j SelectDrawDirection
Norm:
	li $t2, 60
	sw $t2, snakeSpeed             #make snake go normal
	lw $a1, direction              #continue in same direction
	j SelectDrawDirection

DrawUpLoop:
	lw $a0, snakeHeadX 
	lw $a1, snakeHeadY
	lw $a2, direction
	jal CheckGameEndingCollision   #check for collision
	lw $t0, snakeHeadX
	lw $t1, snakeHeadY
	addiu $t1, $t1, -1             #move head up
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	lw $a1, snakeColor
	jal DrawPixel                  #draw head in new position
	sw  $t1, snakeHeadY
	j UpdateTailPosition           #update tail
	
DrawLeftLoop:
	lw $a0, snakeHeadX
	lw $a1, snakeHeadY
	lw $a2, direction	
	jal CheckGameEndingCollision   #check for collision 
	lw $t0, snakeHeadX             
	lw $t1, snakeHeadY
	addiu $t0, $t0, -1             #move head left
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	lw $a1, snakeColor
	jal DrawPixel                  #draw head in new position
	sw  $t0, snakeHeadX	
	j UpdateTailPosition           #update tail

DrawDownLoop:
	lw $a0, snakeHeadX
	lw $a1, snakeHeadY
	lw $a2, direction	
	jal CheckGameEndingCollision
	lw $t0, snakeHeadX	       
	lw $t1, snakeHeadY
	addiu $t1, $t1, 1              #move head down
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	lw $a1, snakeColor
	jal DrawPixel                  #draw head in new position
	sw  $t1, snakeHeadY	
	j UpdateTailPosition           #update tail

DrawRightLoop:
	lw $a0, snakeHeadX
	lw $a1, snakeHeadY
	lw $a2, direction	
	jal CheckGameEndingCollision   #check for collision
	lw $t0, snakeHeadX
	lw $t1, snakeHeadY
	addiu $t0, $t0, 1              #move head right
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	lw $a1, snakeColor
	jal DrawPixel                  #draw head in new position
	sw  $t0, snakeHeadX
	j UpdateTailPosition           #update tail
			
UpdateTailPosition:	
	lw $t2, tailDirection          #branch based on which direction tail is moving
	beq $t2, 119, MoveTailUp
	beq $t2, 115, MoveTailDown
	beq $t2, 97, MoveTailLeft
	beq $t2, 100, MoveTailRight

MoveTailUp:
	#get the screen coordinates of the next direction change
	lw $t8, nextDirection
	la $t0, directionChangeAddressArray #get direction change coordinate
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, snakeTailX  #get snake tail position
	lw $a1, snakeTailY
	#if the index is out of bounds, set back to zero
	beq $s1, 1, IncreaseLengthUp #branch if length should be increased
	addiu $a1, $a1, -1 #change tail position if no length change
	sw $a1, snakeTailY
	
IncreaseLengthUp:
	li $s1, 0 #set flag back to false
	jal CoordinateToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailUp #change direction if needed
	la $t3, newDirectionChangeArray  #update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailDirection
	addiu $t8,$t8,4
	sw $t8, nextDirection 
DrawTailUp:
	lw $a1, snakeColor
	jal DrawPixel
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	jal CheckerBoard
	lw $a1, saveColor
	jal DrawPixel	
	j NewApple  #finished updating snake, update apple

MoveTailDown:
	#get the screen coordinates of the next direction change
	lw $t8, nextDirection
	la $t0, directionChangeAddressArray #get direction change coordinate
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, snakeTailX  #get snake tail position
	lw $a1, snakeTailY
	beq $s1, 1, IncreaseLengthDown #branch if length should be increased
	addiu $a1, $a1, 1 #change tail position if no length change
	sw $a1, snakeTailY
	
IncreaseLengthDown:
	li $s1, 0 #set flag back to false
	jal CoordinateToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailDown #change direction if needed
	la $t3, newDirectionChangeArray  #update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailDirection
	addiu $t8,$t8,4
	sw $t8, nextDirection  
DrawTailDown:	
	lw $a1, snakeColor
	jal DrawPixel	
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	jal CheckerBoard
	lw $a1, saveColor
	jal DrawPixel	
	j NewApple #finished updating snake, update apple

MoveTailLeft:
	#update the tail position when moving left
	lw $t8, nextDirection
	la $t0, directionChangeAddressArray #get direction change coordinate
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, snakeTailX #get snake tail position
	lw $a1, snakeTailY
	beq $s1, 1, IncreaseLengthLeft #branch if length should be increased
	addiu $a0, $a0, -1 #change tail position if no length change
	sw $a0, snakeTailX
	
IncreaseLengthLeft:
	li $s1, 0 #set flag back to false
	jal CoordinateToAddress
	add $a0, $v0, $zero
	bne $t9, $a0, DrawTailLeft #change direction if needed
	la $t3, newDirectionChangeArray #update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailDirection
	addiu $t8,$t8,4
	sw $t8, nextDirection  
DrawTailLeft:	
	lw $a1, snakeColor
	jal DrawPixel	
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t0, $t0, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	jal CheckerBoard
	lw $a1, saveColor
	jal DrawPixel	
	j NewApple  #finished updating snake, update apple

MoveTailRight:
	#get the screen coordinates of the next direction change
	lw $t8, nextDirection
	#get the base address of the coordinate array
	la $t0, directionChangeAddressArray
	#go to the correct index of array
	add $t0, $t0, $t8
	#get the data from the array
	lw $t9, 0($t0)
	#get current tail position
	lw $a0, snakeTailX
	lw $a1, snakeTailY
	#if the length needs to be increased
	#do not change coordinates
	beq $s1, 1, IncreaseLengthRight
	#change tail position
	addiu $a0, $a0, 1
	#store new tail position
	sw $a0, snakeTailX
	
IncreaseLengthRight:
	li $s1, 0 #set flag back to false
	#get screen coordinates
	jal CoordinateToAddress
	#store coordinates in $a0
	add $a0, $v0, $zero
	#if the coordinates is a position change 
	#continue drawing tail in same direction
	bne $t9, $a0, DrawTailRight
	#get the base address of the direction change array
	la $t3, newDirectionChangeArray
	#move to correct index in array
	add $t3, $t3, $t8
	#get data from array
	lw $t9, 0($t3)
	#store new direction
	sw $t9, tailDirection
	#increment position in array
	addiu $t8,$t8,4
	sw $t8, nextDirection  
DrawTailRight:	
	lw $a1, snakeColor
	jal DrawPixel	
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t0, $t0, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordinateToAddress
	add $a0, $v0, $zero
	jal CheckerBoard
	lw $a1, saveColor
	jal DrawPixel
	j NewApple               #finished updating snake, update apple
		
NewApple:
	lw $a0, snakeHeadX
	lw $a1, snakeHeadY
	jal CheckAppleCollision
	beq $v0, 1, AddLength    #if apple was eaten, add length

	lw $a0, applePositionX
	lw $a1, applePositionY
	jal CoordinateToAddress
	add $a0, $v0, $zero
	lw $a1, appleColor
	jal DrawPixel            #draw the apple
	j InputCheck
	
AddLength:
	li $s1, 1                #flag to increase snake length
	j DrawApple

#=========================================================================================#
#                                                                                         #
# When we jump to this function, the value of $a0 will be our x coordinate, and the value #
# of $a1 is the y coordinate. When we leave the function, the coordinate address will be  #
# saved in $v0. The function gets the address of the coordinates in the bitmap display by #
# multiplying the bitmap width by the y coordinate to iterate through the first y blocks  #
# of the bitmap memory, then adds the x coordinate to move forward x addresses in memory. #
# Then, multiply by four to get the byte as every address is a word. And add to $gp       #
# The address after this corresponds to the location of the pixel in the bitmap display.  # 
#                                                                                         #
#=========================================================================================#
CoordinateToAddress:
	lw $v0, screenWidth 	   #Store screen width into $v0
	mul $v0, $v0, $a1	   #multiply by y position
	add $v0, $v0, $a0	   #add the x position
	mul $v0, $v0, 4		   #multiply by 4
	add $v0, $v0, $gp   	   #add global pointer from bitmap display
	jr $ra       	           # return $v0
 
DrawPixel:
	sw $a1, ($a0) 	           #$a0 is the address of the pixel to color, $a1 is the color to draw the pixel
	jr $ra		           #return
	
CheckerBoard:                      #Figure out which color of the checker pattern to draw
	add $a2, $gp, $zero        #loop counter
	li $a3, 0                  #stagger counter
	li $a1, 0                  #rowCounter
	CheckLoop:                 
	addiu $a2, $a2, 4          #start searching for pending pixel
	addiu $a1, $a1, 1          #measuring rows
	beq $a1, 32, RowChange1    #at the end of every other row, the row, switch stagger
	beq $a1, 64, RowChange2    #board is even size
	beqz $a3, Bgcol            #if the pixel is even, it will be drawn to the background color
	lw $t2, gridColor          #otherwise it will be drawn to the grid color
	sw $t2, saveColor
	subiu $a3, $a3, 1          #the next pixel is drawn the other color
	blt $a2, $a0, CheckLoop    #continue until we find the pixel to be colored
	jr $ra                     #return with color
	Bgcol:
	lw $t2, bgColor
	sw $t2, saveColor
	addiu $a3, $a3, 1
	blt $a2, $a0, CheckLoop    #continue until we find the pending pixel
	RowChange1:
	addiu $a2, $a2, 4
	blt $a2, $a0, Bgcol
	RowChange2:
	li $a1, 0
	subiu $a2, $a2, 4
	blt $a2, $a0, Bgcol       
	jr $ra                     #exit the loop

#=========================================================================================#
#                                                                                         #	
# input                                                                                   #
# $a0 - current direction                                                                 #
# $a1 - input                                                                             #
# $a2 - coordinates of direction change if acceptable                                     #
# return                                                                                  #
# $v0 = 0 - direction unacceptable                                                        #
# $v0 = 1 - direction is acceptable                                                       #
#                                                                                         #
#=========================================================================================#
CheckDirection:
	beq $a0, $a1, Same                #if the input is the same as current direction, continue moving in the direction
	beq $a0, 119, checkIsDownPressed  #if moving up, check to see if down is pressed
	beq $a0, 115, checkIsUpPressed	  #if moving down, check to see if up is pressed
	beq $a0, 97, checkIsRightPressed  #if moving left, check to see if right is pressed
	beq $a0, 100, checkIsLeftPressed  #if moving right, check to see if left is pressed
	j DirectionCheckFinished          #if input is incorrect, get new input
	
checkIsDownPressed:
	beq $a1, 115, unacceptable        #if down is pressed while moving up prevent snake from moving into itself
	j acceptable

checkIsUpPressed:
	beq $a1, 119, unacceptable        #if up is pressed while moving down prevent snake from moving into itself
	j acceptable

checkIsRightPressed:
	beq $a1, 100, unacceptable        #if right is pressed while moving left prevent snake from moving into itself
	j acceptable
	
checkIsLeftPressed:
	beq $a1, 97, unacceptable         #if left is pressed while moving right prevent snake from moving into itself
	j acceptable
	
acceptable:
	li $v0, 1
	
	#turning snake
    	#li $v0, 31
    	#li $a0, 45
    	#li $a1, 400 #DURATION
    	#li $a2, 13 #type of noise
    	#li $a3, 127
    	#syscall
    		
	beq $a1, 119, storeUpDirection    #store the location of up direction change
	beq $a1, 115, storeDownDirection  #store the location of down direction change	
	beq $a1, 97, storeLeftDirection   #store the location of left direction change
	beq $a1, 100, storeRightDirection #store the location of right direction change
	j DirectionCheckFinished
	
	
#=========================================================================================#
#                                                                                         #	
# This is where we store the all the turns the user inputs so that the snake's tail can   #
# properly follow the head. We take advantage of MIPS arrays for this.                    #
#                                                                                         #
#=========================================================================================#	
storeUpDirection:
	lw $t4, arrayLength                  #get the array index
	la $t2, directionChangeAddressArray  #get the address for the coordinate for direction change
	la $t3, newDirectionChangeArray      #get address for new direction
	add $t2, $t2, $t4                    #add the index to the base
	add $t3, $t3, $t4
		
	sw $a2, 0($t2)                       #store the coordinates in that index
	li $t5, 119
	sw $t5, 0($t3)                       #store the direction in that index
	
	addiu $t4, $t4, 4                    #increment the array index

UpStop:
	sw $t4, arrayLength	
	j DirectionCheckFinished
	
storeDownDirection:
	lw $t4, arrayLength                  #get the array index
	la $t2, directionChangeAddressArray  #get the address for the coordinate for direction change
	la $t3, newDirectionChangeArray      #get address for new direction
	add $t2, $t2, $t4                    #add the index to the base
	add $t3, $t3, $t4
	
	sw $a2, 0($t2)                       #store the coordinates in that index
	li $t5, 115
	sw $t5, 0($t3)                       #store the direction in that index

	addiu $t4, $t4, 4                    #increment the array index

DownStop:	
	sw $t4, arrayLength
	j DirectionCheckFinished

storeLeftDirection:
	lw $t4, arrayLength                  #get the array index
	la $t2, directionChangeAddressArray  #get the address for the coordinate for direction change
	la $t3, newDirectionChangeArray      #get address for new direction
	add $t2, $t2, $t4                    #add the index to the base
	add $t3, $t3, $t4

	sw $a2, 0($t2)                       #store the coordinates in that index
	li $t5, 97
	sw $t5, 0($t3)                       #store the direction in that index

	addiu $t4, $t4, 4                    #increment the array index


LeftStop:
	sw $t4, arrayLength
	j DirectionCheckFinished

storeRightDirection:
	lw $t4, arrayLength                  #get the array index
	la $t2, directionChangeAddressArray  #get the address for the coordinate for direction change
	la $t3, newDirectionChangeArray      #get address for new direction
	add $t2, $t2, $t4                    #add the index to the base
	add $t3, $t3, $t4
	
	sw $a2, 0($t2)                       #store the coordinates in that index
	li $t5, 100
	sw $t5, 0($t3)                       #store the direction in that index

	addiu $t4, $t4, 4                    #increment the array index

RightStop:
	sw $t4, arrayLength	             #store array position	
	j DirectionCheckFinished
	
unacceptable:
	li $v0, 0                            #direction is not acceptable
	j DirectionCheckFinished
	
Same:
	li $v0, 1
	
DirectionCheckFinished:
	jr $ra
	
Pause:
	li $v0, 32                           #syscall value for sleep
	syscall                              #will sleep for whatever $a0 is set to
	jr $ra
	
CheckAppleCollision:
	lw $t0, applePositionX               #get apple coordinates
	lw $t1, applePositionY               #snake's head coordinates are stored in $a0 and $a1
	add $v0, $zero, $zero	             #set $v0 to 0, to default to no collision, 1 means collision
	beq $a0, $t0, XEqualApple            #check first to see if x is equal
	j ExitCollisionCheck                 #if not equal we exit
	
XEqualApple:
	beq $a1, $t1, YEqualApple            #check to see if the y is equal
	j ExitCollisionCheck                 #if not eqaul end function
	
YEqualApple:                                 #This means that the snake has eaten an apple
	lw $t5, score                        #update the score as apple has been eaten
	li $t6, 10
	add $t5, $t5, $t6
	sw $t5, score
	
	#eating fruit
    	li $v0, 31
    	li $a0, 45
    	li $a1, 500 #DURATION
    	li $a2, 10 #type of noise
    	li $a3, 127
    	syscall
	
	li $v0, 1                            #set return value to 1 for collision
	
ExitCollisionCheck:                          #exit collision check
	jr $ra
	
#=========================================================================================#
#                                                                                         #
# Collision Check                                                                         #
#                                                                                         #
# $a0 - snakeHeadPositionX                                                                #
# $a1 - snakeHeadPositionY                                                                #
# $a2 - snakeHeadDirection                                                                #
#                                                                                         #
# if $v0 = 0, no collision, if $v0 = 1, player dead                                       #
#                                                                                         #
#=========================================================================================#
	
CheckGameEndingCollision:
	add $s3, $a0, $zero      #save snake head x position into $s3
	add $s4, $a1, $zero      #save snake head y position into $s4
	sw $ra, 0($sp)           #move return address so we can check for collisions

	beq $a2, 119, CheckUp    #if the player moved up a tile
	beq $a2, 115, CheckDown  #if the player moved down a tile
	beq $a2, 97,  CheckLeft  #if the player moved left a tile
	beq $a2, 100, CheckRight #if the player moved right a tile
	j BodyCollisionDone
	
CheckUp:
	addiu $a1, $a1, -1       #look above the current position
	jal CoordinateToAddress
	lw $t1, 0($v0)           #get color at screen address
	lw $t2, snakeColor
	lw $t3, borderColor
	beq $t1, $t2, Exit       #If colors are equal, game over
	beq $t1, $t3, Exit       #If you hit the border, game over
	j BodyCollisionDone      #otherwise, still good

CheckDown:
	addiu $a1, $a1, 1        #look below the current position
	jal CoordinateToAddress
	lw $t1, 0($v0)           #get color at screen address
	lw $t2, snakeColor
	lw $t3, borderColor
	beq $t1, $t2, Exit       #If colors are equal, game over
	beq $t1, $t3, Exit       #If you hit the border, game over
	j BodyCollisionDone      #otherwise, still good

CheckLeft:
	addiu $a0, $a0, -1       #look to the left of the current position
	jal CoordinateToAddress
	lw $t1, 0($v0)           #get color at screen address
	lw $t2, snakeColor
	lw $t3, borderColor
	beq $t1, $t2, Exit       #If colors are equal, game over
	beq $t1, $t3, Exit       #If you hit the border, game over
	j BodyCollisionDone      #otherwise, still good

CheckRight:
	addiu $a0, $a0, 1        #look to the right of the current position
	jal CoordinateToAddress
	lw $t1, 0($v0)           #get color at screen address
	lw $t2, snakeColor
	lw $t3, borderColor
	beq $t1, $t2, Exit       #If colors are equal, game over
	beq $t1, $t3, Exit       #If you hit the border, game over
	j BodyCollisionDone      #otherwise, still good

BodyCollisionDone:
	lw $ra, 0($sp)           #restore return address
	jr $ra		

Exit:                            #Game over
	#death noise
	li $v0, 31
    	li $a0, 30 #pitch
    	li $a1, 600 #duration
    	li $a2, 16 #type of noise
    	li $a3, 127 
    	syscall
    		
	li $v0, 32
    	li $a0, 600
    	syscall
    		
    	li $v0, 31
    	li $a0, 29
    	li $a1, 600
    	li $a2, 16
    	li $a3, 127 
    	syscall
    		
    	li $v0, 32
    	li $a0, 600
    	syscall
    		
    	li $v0, 31
    	li $a0, 28
    	li $a1, 600
    	li $a2, 16
    	li $a3, 127 
    	syscall
    		
    	li $v0, 32
    	li $a0, 600
    	syscall
    		
    	li $v0, 31
    	li $a0, 25
    	li $a1, 1500
    	li $a2, 16
    	li $a3, 127 
    	syscall
	
	li $v0, 56               #syscall value for java prompt
	la $a0, gameOver         #get message
	lw $a1, score	         #get score
	syscall

	#game restart sound
    	li $v0, 31
    	li $a0, 45               #type of noise
    	li $a1, 400              #DURATION
    	li $a2, 13                #instrument number
    	li $a3, 127              #volume
    	syscall
    	
	j StartGame              #Start game over