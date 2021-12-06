#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Freeman Cheng, 1006877140
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining (EASY)
# 2. Have objects in different rows move at different speeds (EASY)
# 3. Add a third row in each of the water and road sections (EASY)
# 4. Add sound effects for movement, collisions, game end and reaching the goal area (HARD)
# 5. Add powerups to scene (slowing down time, score booster, extra lives, etc) (HARD)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
displayAddress: .word 0x10008000
displayWidth: .word 32
displayHeight: .word 64

# Map information
mapWidth: .word 32
mapHeight: .word 40

map1StartY: .word 60
map1StartHeight: .word 4

map1CarsY: .word 48
map1CarsHeight: .word 12

map1MiddleY: .word 44
map1MiddleHeight: 4

map1LogsY: .word 32
map1LogsHeight: .word 12

map1EndY: .word 28
map1EndHeight: .word 4

mapEndReached: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

# Map obstacles
carRow1: .word 0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000
carRow2: .word 0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080
carRow3: .word 0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000
carRow1Rate: .word 1
carRow2Rate: .word 2
carRow3Rate: .word 1
logRow1: .word 0x964b00,0x964b00,0xffd700,0xffd700,0xffd700,0xffd700,0x964b00,0x964b00,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff
logRow2: .word 0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00
logRow3: .word 0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x964b00,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff,0x0000ff
logRow1Rate: .word 1
logRow2Rate: .word 2
logRow3Rate: .word 1

# Player information
playerWidth: .word 4
playerHeight: .word 4
playerX: .word 0
playerY: .word 60
playerLives: .word 3
playerScore: .word 0

# Timing
time: .word 0
sleep: .word 50

livesString: .asciiz "Lives remaining: "
newline: .asciiz "\n"

.text

j MAIN

################################# FUNCTIONS #################################

# STACK (BOT -> TOP): $t1
# $t1 is array pointer
# RETURN STACK (BOT -> TOP):
SHIFT_ROW_ARRAY_L:
# shift array of mapWidth integers by 1 to the left with wrap around
# pop arguments off stack
lw $t1, 0($sp)
addi $sp, $sp, 4

lw $t2, 0($t1) # (*$t1)[0]
addi $t8, $zero, 0 # index
addi $t9, $zero, 124 # for loop index limit

SHIFT_ROW_ARRAY_L_LOOP:
beq $t8, $t9, SHIFT_ROW_ARRAY_L_LOOP_END
# idea: arr[i] = arr[i + 1]
add $t3, $t1, $t8 # $t3 index i
addi $t4, $t3, 4 # $t4 index i + 1
lw $t4, 0($t4)
sw $t4, 0($t3)
addi $t8, $t8, 4 # $t8 += 4
j SHIFT_ROW_ARRAY_L_LOOP

SHIFT_ROW_ARRAY_L_LOOP_END:
# idea: arr[31] = arr[0]
add $t3, $t1, $t8
sw $t2, 0($t3)
jr $ra

# STACK (BOT -> TOP): $t1
# $t1 is array pointer
# RETURN STACK (BOT -> TOP):
SHIFT_ROW_ARRAY_R:
# shift array of mapWidth integers by 1 to the right with wrap around
# pop arguments off stack
lw $t1, 0($sp)
addi $sp, $sp, 4

lw $t2, 124($t1) # (*$t1)[31]
addi $t8, $zero, 124 # index
addi $t9, $zero, -4 # for loop index limit

SHIFT_ROW_ARRAY_R_LOOP:
beq $t8, $t9, SHIFT_ROW_ARRAY_R_LOOP_END
# idea: arr[i] = arr[i - 1]
add $t3, $t1, $t8 # $t3 index i
addi $t4, $t3, -4 # $t4 index i - 1
lw $t4, 0($t4)
sw $t4, 0($t3)
addi $t8, $t8, -4 # $t8 += 4
j SHIFT_ROW_ARRAY_R_LOOP

SHIFT_ROW_ARRAY_R_LOOP_END:
# idea: arr[0] = arr[31]
sw $t2, 0($t1)
jr $ra

# STACK (BOT -> TOP): $t1 $t2 $t3 $t5 $t6
# $t1 is colour
# $t2 is x offset; $t3 is y offset (not multiplied)
# $t5 is width; $t6 is height (not multiplied) 
# RETURN STACK (BOT - > TOP):
DRAW_RECTANGLE:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t6, 0($sp)
addi $sp, $sp, 4
lw $t5, 0($sp)
addi $sp, $sp, 4
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_RECTANGLE_LOOP_Y:
beq $t6, $zero, DRAW_RECTANGLE_LOOP_Y_END

DRAW_RECTANGLE_LOOP_X:
beq $t5, $zero, DRAW_RECTANGLE_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel
sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_RECTANGLE_LOOP_X

DRAW_RECTANGLE_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_RECTANGLE_LOOP_Y

DRAW_RECTANGLE_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_LOG_ROW_1:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_LOG_ROW_1_LOOP_Y:
beq $t6, $zero, DRAW_LOG_ROW_1_LOOP_Y_END

DRAW_LOG_ROW_1_LOOP_X:
beq $t5, $zero, DRAW_LOG_ROW_1_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, logRow1
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_LOG_ROW_1_LOOP_X

DRAW_LOG_ROW_1_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_LOG_ROW_1_LOOP_Y

DRAW_LOG_ROW_1_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_LOG_ROW_2:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_LOG_ROW_2_LOOP_Y:
beq $t6, $zero, DRAW_LOG_ROW_2_LOOP_Y_END

DRAW_LOG_ROW_2_LOOP_X:
beq $t5, $zero, DRAW_LOG_ROW_2_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, logRow2
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_LOG_ROW_2_LOOP_X

DRAW_LOG_ROW_2_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_LOG_ROW_2_LOOP_Y

DRAW_LOG_ROW_2_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_LOG_ROW_3:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_LOG_ROW_3_LOOP_Y:
beq $t6, $zero, DRAW_LOG_ROW_3_LOOP_Y_END

DRAW_LOG_ROW_3_LOOP_X:
beq $t5, $zero, DRAW_LOG_ROW_3_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, logRow3
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_LOG_ROW_3_LOOP_X

DRAW_LOG_ROW_3_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_LOG_ROW_3_LOOP_Y

DRAW_LOG_ROW_3_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_CAR_ROW_1:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_CAR_ROW_1_LOOP_Y:
beq $t6, $zero, DRAW_CAR_ROW_1_LOOP_Y_END

DRAW_CAR_ROW_1_LOOP_X:
beq $t5, $zero, DRAW_CAR_ROW_1_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, carRow1
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_CAR_ROW_1_LOOP_X

DRAW_CAR_ROW_1_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_CAR_ROW_1_LOOP_Y

DRAW_CAR_ROW_1_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_CAR_ROW_2:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_CAR_ROW_2_LOOP_Y:
beq $t6, $zero, DRAW_CAR_ROW_2_LOOP_Y_END

DRAW_CAR_ROW_2_LOOP_X:
beq $t5, $zero, DRAW_CAR_ROW_2_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, carRow2
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_CAR_ROW_2_LOOP_X

DRAW_CAR_ROW_2_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_CAR_ROW_2_LOOP_Y

DRAW_CAR_ROW_2_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): $t2 $t3
# $t2 is x offset; $t3 is y offset (not multiplied)
# RETURN STACK (BOT - > TOP):
DRAW_CAR_ROW_3:
lw $t0, displayAddress # $t0 is base address for display

# pop arguments off stack
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4

lw $t5, mapWidth # width
addi $t6, $zero, 4 # height

# body
add $t7, $t5, $zero # $t7 is copy of $t5

addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

DRAW_CAR_ROW_3_LOOP_Y:
beq $t6, $zero, DRAW_CAR_ROW_3_LOOP_Y_END

DRAW_CAR_ROW_3_LOOP_X:
beq $t5, $zero, DRAW_CAR_ROW_3_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

la $t8, carRow3
add $t8, $t8, $t2
lw $t1, 0($t8) # load $t1 as color in array

sw $t1, 0($t4) # paint pixel
addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j DRAW_CAR_ROW_3_LOOP_X

DRAW_CAR_ROW_3_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j DRAW_CAR_ROW_3_LOOP_Y

DRAW_CAR_ROW_3_LOOP_Y_END:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
DRAW_MAP1_BACKGROUND:
addi $sp, $sp, -4
sw $ra, 0($sp)

# START

# DRAW_RECTANGLE arguments
li $t1, 0x00ff00 # green
addi $t2, $zero, 0
lw $t3, map1StartY
lw $t5, mapWidth
lw $t6, map1StartHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

# Cars

# DRAW_RECTANGLE arguments
li $t1, 0x808080 # grey
addi $t2, $zero, 0
lw $t3, map1CarsY
lw $t5, mapWidth
lw $t6, map1CarsHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

# Middle

# DRAW_RECTANGLE arguments
li $t1, 0x00ff00 # green
addi $t2, $zero, 0
lw $t3, map1MiddleY
lw $t5, mapWidth
lw $t6, map1MiddleHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

# Logs

# DRAW_RECTANGLE arguments
li $t1, 0x964b00 # brown
addi $t2, $zero, 0
lw $t3, map1LogsY
lw $t5, mapWidth
lw $t6, map1LogsHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

# End

# DRAW_RECTANGLE arguments
li $t1, 0x00ff00 # green
addi $t2, $zero, 0
lw $t3, map1EndY
lw $t5, mapWidth
lw $t6, map1EndHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

DRAW_PLAYER:
addi $sp, $sp, -4
sw $ra, 0($sp)

# DRAW_RECTANGLE arguments
li $t1, 0xffa500 # orange
lw $t2, playerX
lw $t3, playerY
lw $t5, playerWidth
lw $t6, playerHeight

# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)

jal DRAW_RECTANGLE

lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
DRAW_CARS:
addi $sp, $sp, -4
sw $ra, 0($sp)

# Row 1
# args for DRAW_CAR_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 56
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_CAR_ROW_1

# Row 2
# args for DRAW_CAR_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 52
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_CAR_ROW_2

# Row 1
# args for DRAW_CAR_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 48
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_CAR_ROW_3

lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
DRAW_LOGS:
addi $sp, $sp, -4
sw $ra, 0($sp)

# Row 1
# args for DRAW_LOG_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 40
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_LOG_ROW_1

# Row 2
# args for DRAW_LOG_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 36
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_LOG_ROW_2

# Row 1
# args for DRAW_LOG_ROW_...
addi $t2, $zero, 0
addi $t3, $zero, 32
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
jal DRAW_LOG_ROW_3

lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

MOVE_CARS:
addi $sp, $sp, -4
sw $ra, 0($sp)

# only move if time is multiple of 10
lw $t0, time
addi $t4, $zero, 10
div $t0, $t4
mfhi $t4 # check if 0
beq $t4, $zero, MOVE_CARS_EVEN_TIME
# check multiple of 12
addi $t4, $zero, 12
div $t0, $t4
mfhi $t4 # check if 0
beq $t4, $zero, MOVE_CARS_ODD_TIME
j MOVE_CARS_END

MOVE_CARS_EVEN_TIME:

# row 1
la $t1, carRow1
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R
la $t1, carRow1
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R

# row 3
la $t1, carRow3
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R

j MOVE_CARS_END

MOVE_CARS_ODD_TIME: 
# row 2
la $t1, carRow2
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_L

MOVE_CARS_END:
lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

MOVE_LOGS:
# we will move the frog along with the log if the frog is sitting on the log
addi $sp, $sp, -4
sw $ra, 0($sp)

# only move if time is multiple of 10
lw $t0, time
addi $t4, $zero, 10
div $t0, $t4
mfhi $t4 # check if 10
beq $t4, $zero, MOVE_LOGS_EVEN_TIME
addi $t4, $zero, 12
div $t0, $t4
mfhi $t4 # check if 12
beq $t4, $zero, MOVE_LOGS_ODD_TIME
j MOVE_LOGS_END

MOVE_LOGS_EVEN_TIME:

# row 1
la $t1, logRow1
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_L
# row 1
la $t1, logRow1
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_L
# check frog y coincides with log y
lw $t3, playerY
addi $t4, $zero, 40
beq $t3, $t4, FROG_ON_CAR_ROW_1
j FROG_NOT_ON_CAR_ROW_1

FROG_ON_CAR_ROW_1:
# move left
jal KEY_A
jal KEY_A

FROG_NOT_ON_CAR_ROW_1:

# row 3
la $t1, logRow3
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_L
# check frog y coincides with log y
lw $t3, playerY
addi $t4, $zero, 32
beq $t3, $t4, FROG_ON_CAR_ROW_3
j FROG_NOT_ON_CAR_ROW_3

FROG_ON_CAR_ROW_3:
# move left
jal KEY_A

FROG_NOT_ON_CAR_ROW_3:
j MOVE_LOGS_END

MOVE_LOGS_ODD_TIME: 
# row 2
la $t1, logRow2
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R
# check frog y coincides with log y
lw $t3, playerY
addi $t4, $zero, 36
beq $t3, $t4, FROG_ON_CAR_ROW_2
j FROG_NOT_ON_CAR_ROW_2

FROG_ON_CAR_ROW_2:
# move right
jal KEY_D

FROG_NOT_ON_CAR_ROW_2:

MOVE_LOGS_END:
lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
LISTEN_TO_KEYBOARD:
addi $sp, $sp, -4
sw $ra, 0($sp)

# check if key has been pressed
lw $t8, 0xffff0000
beq $t8, 1, KEY_IN
j NO_KEY_IN

KEY_IN:
# if keystroke
lw $t2, 0xffff0004
# w
beq $t2, 119, HANDLE_KEY_W
# a
beq $t2, 97, HANDLE_KEY_A
# s
beq $t2, 115, HANDLE_KEY_S
# d
beq $t2, 100, HANDLE_KEY_D
j NO_KEY_IN

HANDLE_KEY_W:
jal KEY_W
j PLAY_MOVEMENT_SOUND

HANDLE_KEY_A:
jal KEY_A
j PLAY_MOVEMENT_SOUND

HANDLE_KEY_S:
jal KEY_S
j PLAY_MOVEMENT_SOUND

HANDLE_KEY_D:
jal KEY_D
j PLAY_MOVEMENT_SOUND

PLAY_MOVEMENT_SOUND:
# syscall args
addi $v0, $zero, 31
addi $a0, $zero, 61
addi $a1, $zero, 100
addi $a2, $zero, 88
addi $a3, $zero, 64
syscall

NO_KEY_IN:
lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

# movement functions

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
KEY_W:
lw $t3, playerY
lw $t4, map1EndY
beq $t3, $t4, NO_KEY_W # collision detection
addi $t3, $t3, -1 # update position
sw $t3, playerY
NO_KEY_W:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
KEY_A:
lw $t3, playerX
beq $t3, $zero, NO_KEY_A # collision detection
addi $t3, $t3, -1 # update position
sw $t3, playerX
NO_KEY_A:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
KEY_S:
lw $t3, playerY
lw $t4, displayHeight
lw $t5, playerHeight
sub $t4, $t4, $t5
beq $t3, $t4, NO_KEY_S # collision detection
addi $t3, $t3, 1 # update position
sw $t3, playerY
NO_KEY_S:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
KEY_D:
lw $t3, playerX
lw $t4, mapWidth
lw $t5, playerWidth
sub $t4, $t4, $t5
beq $t3, $t4, NO_KEY_D # collision detection
addi $t3, $t3, 1 # update position
sw $t3, playerX
NO_KEY_D:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
CHECK_OBSTACLE_COLLISIONS:
addi $sp, $sp, -4
sw $ra, 0($sp)
# idea: loop through pixels where player will be drawn before player is drawn
# check if contain obstacle colors
lw $t2, playerX
lw $t3, playerY
# loop limits
lw $t5, playerWidth
lw $t6, playerHeight
add $t7, $t5, $zero # $t7 is copy of $t5
# perform $t2 *= 4 and $t3 *= 128
addi $t4, $zero, 4
mult $t2, $t4
mflo $t2 # $t2 = $t2 * 4

addi $t4, $zero, 128
mult $t3, $t4
mflo $t3 # $t3 = $t3 * 128

CHECK_OBSTACLE_LOOP_Y:
beq $t6, $zero, CHECK_OBSTACLE_LOOP_Y_END

CHECK_OBSTACLE_LOOP_X:
beq $t5, $zero, CHECK_OBSTACLE_LOOP_X_END
add $t4, $t2, $t3 # $t4 is total offset to add
add $t4, $t4, $t0 # $t4 is position to draw pixel

# START COLLISION CHECK 
lw $t1, 0($t4) # colour of pixel
# check if red
li $t9, 0xff0000 # red
beq $t1, $t9, OBSTACLE_COLLISION
# check if blue
li $t9, 0x0000ff # blue
beq $t1, $t9, OBSTACLE_COLLISION
# END COLLISION CHECK 

# START POWERUP COLLISION CHECK 
li $t9, 0xffd700 # gold
beq $t1, $t9, POWERUP_COLLISION
j NO_POWERUP_COLLISION

POWERUP_COLLISION:
li $t9, 200
sw $t9, sleep
j NO_OBSTACLE_COLLISION

NO_POWERUP_COLLISION:
li $t9, 50
sw $t9, sleep
j NO_OBSTACLE_COLLISION

OBSTACLE_COLLISION:
# play collision sound
addi $v0, $zero, 31
addi $a0, $zero, 40
addi $a1, $zero, 100
addi $a2, $zero, 88
addi $a3, $zero, 64
syscall

# player loses 1 life
lw $t8, playerLives
addi $t8, $t8, -1
sw $t8, playerLives

# for now, reset player positions
addi $t2, $zero, 0
addi $t3, $zero, 60
sw $t2, playerX
sw $t3, playerY

# print lives
jal PRINT_LIVES
j CHECK_OBSTACLE_LOOP_Y_END

NO_OBSTACLE_COLLISION:

addi $t2, $t2, 4 # move down a column
addi $t5, $t5, -1 # loop counter decrement
j CHECK_OBSTACLE_LOOP_X

CHECK_OBSTACLE_LOOP_X_END:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # reset $t4 to original x offset

addi $t3, $t3, 128 # move down a row
addi $t6, $t6, -1 # loop counter decrement
j CHECK_OBSTACLE_LOOP_Y

CHECK_OBSTACLE_LOOP_Y_END:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
CHECK_VICTORY:
# check if frog y is end y
lw $t3, playerY
addi $t4, $zero, 28
beq $t3, $t4, IF_VICTORY
j NO_VICTORY

IF_VICTORY:
# update score
lw $a0, playerScore
addi $a0, $a0, 1
sw $a0, playerScore
# play victory sound
addi $v0, $zero, 31
addi $a0, $zero, 72
addi $a1, $zero, 100
addi $a2, $zero, 0
addi $a3, $zero, 64
syscall
# mapEndReached[playerX] = 1
lw $t2, playerX
addi $t4, $zero, 4
mult $t2, $t4 # need to scale playerX by 4
mflo $t2 # $t2 = 4 * $t2
la $t8, mapEndReached
add $t8, $t8, $t2
addi $t4, $zero, 1
sw $t4, 0($t8)

# for now, reset player X and Y
addi $t2, $zero, 0
addi $t3, $zero, 60
sw $t2, playerX
sw $t3, playerY

NO_VICTORY:
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
CHECK_NO_LIVES:
lw $t8, playerLives
beq $t8, $zero, Exit
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
DRAW_END_REACHED_SQUARES:
addi $sp, $sp, -4
sw $ra, 0($sp)

# read from mapEndReached and draw squares in places frog has made it to end
# loop through mapEndReached
la $t7, mapEndReached
# loop init
addi $t8, $zero, 0
addi $t9, $zero, 128
addi $t4, $zero, 1
DRAW_END_REACHED_SQUARES_LOOP:
beq $t8, $t9, DRAW_END_REACHED_SQUARES_LOOP_END
# check if mapEndReached[$t8] = 1
add $t6, $t7, $t8
lw $t5, 0($t6)
beq $t5, $t4, DERSL_IF
j DERSL_ELSE 

DERSL_IF:
# draw 4x4 white square at ($t8, 0)
# preserve registers
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t4, 0($sp)
addi $sp, $sp, -4
sw $t5, 0($sp)
addi $sp, $sp, -4
sw $t6, 0($sp)
addi $sp, $sp, -4
sw $t7, 0($sp)
addi $sp, $sp, -4
sw $t8, 0($sp)
addi $sp, $sp, -4
sw $t9, 0($sp)
# function args
li $t1, 0xffffff # white
addi $t2, $zero, 4
addi $t3, $zero, 28
# $t0 = $t8 / 4
addi $t0, $zero, 4
div $t8, $t0
mflo $t0
# push args
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)

jal DRAW_RECTANGLE

# restore registers
lw $t9, 0($sp)
addi $sp, $sp, 4
lw $t8, 0($sp)
addi $sp, $sp, 4
lw $t7, 0($sp)
addi $sp, $sp, 4
lw $t6, 0($sp)
addi $sp, $sp, 4
lw $t5, 0($sp)
addi $sp, $sp, 4
lw $t4, 0($sp)
addi $sp, $sp, 4
lw $t3, 0($sp)
addi $sp, $sp, 4
lw $t2, 0($sp)
addi $sp, $sp, 4
lw $t1, 0($sp)
addi $sp, $sp, 4
lw $t0, 0($sp)
addi $sp, $sp, 4

DERSL_ELSE:
addi $t8, $t8, 4
j DRAW_END_REACHED_SQUARES_LOOP

DRAW_END_REACHED_SQUARES_LOOP_END:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
PRINT_LIVES:
addi $v0, $zero, 4
la $a0, livesString
syscall
addi $v0, $zero, 1
lw $a0, playerLives
syscall
addi $v0, $zero, 4
la $a0, newline
syscall
jr $ra

################################# MAIN #################################

MAIN: 
jal PRINT_LIVES

# game loop
GAME_LOOP:

# drawing
jal DRAW_MAP1_BACKGROUND
jal DRAW_CARS
jal DRAW_LOGS
jal DRAW_END_REACHED_SQUARES

# obstacle collisions
# idea: loop through pixels where player will be drawn before player is drawn
# check if contain obstacle colors
jal CHECK_OBSTACLE_COLLISIONS 

# player
jal DRAW_PLAYER
jal LISTEN_TO_KEYBOARD

# obstacles
jal MOVE_CARS
jal MOVE_LOGS

# game
jal CHECK_VICTORY
jal CHECK_NO_LIVES

# update time
lw $t0, time
addi $t0, $t0 1 # increment
addi $t1, $zero, 60 # mod 60
div $t0, $t1
mfhi $t0
sw $t0, time # update

# sleep
li $v0, 32
lw $a0, sleep
syscall
j GAME_LOOP

Exit:
# sleep
li $v0, 32
li $a0, 1000
syscall
# play exit sound
# megalovania
addi $v0, $zero, 33
addi $a0, $zero, 62
addi $a1, $zero, 300
addi $a2, $zero, 0
addi $a3, $zero, 64
syscall
syscall
addi $a0, $zero, 74
syscall
addi $a0, $zero, 69
syscall
addi $a0, $zero, 68
syscall
addi $a0, $zero, 67
syscall
addi $a0, $zero, 65
syscall
addi $a0, $zero, 62
syscall
addi $a0, $zero, 65
syscall
addi $a0, $zero, 67
syscall
li $v0, 10 # terminate the program gracefully
syscall
