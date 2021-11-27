# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)

.data
displayAddress: .word 0x10008000

.text

j MAIN

################################# FUNCTIONS #################################

# STACK (BOT -> TOP): t1 $t2 $t3 $t5 $t6
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

################################# MAIN #################################

MAIN: 
li $t1, 0xff0000 # red
addi $t2, $t2, 8
addi $t3, $t3, 8
addi $t5, $t5, 4
addi $t6, $t6, 6

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

Exit:
li $v0, 10 # terminate the program gracefully
syscall
