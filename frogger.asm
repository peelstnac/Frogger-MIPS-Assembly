.data
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
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

# Map obstacles
carRow1: .word 0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000
carRow2: .word 0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080
carRow3: .word 0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0x808080,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000,0xff0000
carRow1Rate: .word 1
carRow2Rate: .word 2
carRow3Rate: .word 1

# Player information
playerWidth: .word 4
playerHeight: .word 4
playerX: .word 0
playerY: .word 60

# Timing
time: .word 0

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

MOVE_CARS:
addi $sp, $sp, -4
sw $ra, 0($sp)

# row 1
la $t1, carRow1
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R

# row 2
la $t1, carRow2
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_L

# row 3
la $t1, carRow3
addi $sp, $sp, -4
sw $t1, 0($sp)
jal SHIFT_ROW_ARRAY_R

lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra

# STACK (BOT -> TOP): 
# RETURN STACK (BOT - > TOP):
LISTEN_TO_KEYBOARD:
# check if key has been pressed
lw $t8, 0xffff0000
beq $t8, 1, KEY_IN
j NO_KEY_IN

KEY_IN:
# if keystroke
lw $t2, 0xffff0004
# w
beq $t2, 119, KEY_W
# a
beq $t2, 97, KEY_A
# s
beq $t2, 115, KEY_S
# d
beq $t2, 100, KEY_D
j NO_KEY_IN

KEY_W:
lw $t3, playerY
lw $t4, map1EndY
beq $t3, $t4, NO_KEY_IN # collision detection
addi $t3, $t3, -1 # update position
sw $t3, playerY
j NO_KEY_IN

KEY_A:
lw $t3, playerX
beq $t3, $zero, NO_KEY_IN # collision detection
addi $t3, $t3, -1 # update position
sw $t3, playerX
j NO_KEY_IN

KEY_S:
lw $t3, playerY
lw $t4, displayHeight
lw $t5, playerHeight
sub $t4, $t4, $t5
beq $t3, $t4, NO_KEY_IN # collision detection
addi $t3, $t3, 1 # update position
sw $t3, playerY
j NO_KEY_IN

KEY_D:
lw $t3, playerX
lw $t4, mapWidth
lw $t5, playerWidth
sub $t4, $t4, $t5
beq $t3, $t4, NO_KEY_IN # collision detection
addi $t3, $t3, 1 # update position
sw $t3, playerX
j NO_KEY_IN


NO_KEY_IN:
jr $ra

################################# MAIN #################################

MAIN: 
# game loop
GAME_LOOP:

# drawing
jal DRAW_MAP1_BACKGROUND
jal DRAW_CARS
jal DRAW_PLAYER

# player
jal LISTEN_TO_KEYBOARD

# obstacles
jal MOVE_CARS

# update time
lw $t0, time
addi $t0, $t0 1 # increment
addi $t1, $zero, 20 # mod 20
div $t0, $t1
mfhi $t0
sw $t0, time # update

# sleep
li $v0, 32
li $a0, 50
syscall
j GAME_LOOP

Exit:
li $v0, 10 # terminate the program gracefully
syscall