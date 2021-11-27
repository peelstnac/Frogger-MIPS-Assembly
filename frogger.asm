# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
.text
Draw:
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code

addi $t2, $zero, 28 # $t2 stores x offset
addi $t3, $zero, 60 # $t3 stores y offset
addi $t5, $zero, 4 # $t5 stores width of rectangle
addi $t6, $zero, 4 # $t6 stores height of rectangle
add $t7, $t5, $zero # $t7 is original $t5

addi $t4, $zero, 4 # $t4 stores 4
mult $t2, $t4
mflo $t2 # $t2 is now multiplied by 4

addi $t4, $zero, 128 # $t4 stores 128
mult $t3, $t4
mflo $t3 # $t3 is now multiplied by 128

Loop_y:
beq $t6, $zero, Loop_y_end
Loop_x:
beq $t5, $zero, Loop_x_end
add $t4, $t2, $t3 # $t4 stores total offset to add
add $t4, $t4, $t0 # $t4 is now the position to draw pixel
sw $t1, 0($t4) # paint the first (top-left) unit red.

addi $t2, $t2, 4 # increment $t2 by 4 to move down a column
addi $t5, $t5, -1 # loop counter decrement
j Loop_x
Loop_x_end:
add $t5, $t7, $zero # reset $t5 to width
addi $t4, $zero, -4
mult $t4, $t5 
mflo $t4
add $t2, $t2, $t4 # resrt $t4 to original x offset

addi $t3, $t3, 128 # increment $t3 by 128 to move down a row
addi $t6, $t6, -1 # loop counter decrement
j Loop_y
Loop_y_end:

Exit:
li $v0, 10 # terminate the program gracefully
syscall