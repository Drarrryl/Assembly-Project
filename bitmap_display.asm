##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
	li $v0, 32
	li $a0, 1

    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue
    li $t8, 0x000000

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    sw $t1, 0($t0)          # paint the first unit (i.e., top-left) red
    sw $t2, 4($t0)          # paint the second unit on the first row green
    sw $t3, 128($t0)        # paint the first unit on the second row blue
    add $t4, $t3, $t2
    subi $t2, $t4, 0x004444
    
    add $t0, $t0, 132 # Starting pixel
    addi $t4, $t0, 400 # End 40 units to the right
    
    # Loop
    loop_start:
        beq $t0, $t4, loop_end
        sw $t2, 0($t0) 
        j rem_prev
        back:
            addi $t0, $t0, 4         # paint the curr pixel green
            syscall
            j loop_start 
    
    # Remove prev
    rem_prev:
        sw $t8, -4($t0)
        j back
    
    
    loop_end:
    
    
    
    
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
