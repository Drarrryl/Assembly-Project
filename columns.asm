################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    lw $t0, ADDR_DSPL
    
    li $s0, 0xff0000        # $t1 = red
    li $s1, 0x00ff00        # $t3 = green
    li $s2, 0x0000ff        # $t3 = blue
    li $s3, 0xff7f00        # $t1 = orange
    li $s4, 0x00ffff        # $t3 = cyan
    li $s5, 0xffff00        # $t3 = blue
    
    li $t9, 0x000000        # $t9 = black
    li $t1, 0x555555        # $t4 = gray (for border)
    
    addi $t6, $t0, 32
    
    draw_row_right:
        beq $t0, $t6, change_end_pixel1
        sw $t1 0($t0)
        addi $t0, $t0, 4
        j draw_row_right
        
    change_end_pixel1:
        addi $t6, $t6, 1920
        j draw_col_down
        
    draw_col_down:
        beq $t0, $t6, change_end_pixel2
        sw $t1 0($t0)
        addi $t0, $t0, 128
        j draw_col_down
        
    change_end_pixel2:
        subi $t6, $t6, 32
        j draw_row_left
        
    draw_row_left:
        beq $t0, $t6, change_end_pixel3
        sw $t1 0($t0)
        subi $t0, $t0, 4
        j draw_row_left
        
    change_end_pixel3:
        subi $t6, $t6, 1920
        j draw_col_up
        
    draw_col_up:
        beq $t0, $t6, end_draw_border
        sw $t1 0($t0)
        subi $t0, $t0, 128
        j draw_col_up
    
    end_draw_border:
    
    addi $t0, $t0, 144 # Start pixel in the middle
    addi $t7, $t0, 384 
    draw_columns:
        beq $t0, $t7, end_draw
        j gen_rand
        draw_pixel:
            sw $t1, 0($t0)
            add $t0, $t0, 128
            j draw_columns
    
    gen_rand:
        li $t1, 0
        li $t2, 1
        li $t3, 2
        li $t4, 3
        li $t5, 4
        li $t6, 5
        
        li $v0, 42
        li $a0, 0
        li $a1, 6
        syscall
        
        beq $a0, $t1 pick_red
        beq $a0, $t2 pick_green
        beq $a0, $t3 pick_blue
        beq $a0, $t4 pick_orange
        beq $a0, $t5 pick_cyan
        beq $a0, $t6 pick_yellow
        
    pick_red:
        move $t1, $s0
        j draw_pixel
    pick_green:
        move $t1, $s1
        j draw_pixel
    pick_blue:
        move $t1, $s2
        j draw_pixel
    pick_orange:
        move $t1, $s3
        j draw_pixel
    pick_cyan:
        move $t1, $s4
        j draw_pixel
    pick_yellow:
        move $t1, $s5
        j draw_pixel
    
    end_draw:
    
    addi $t0, $t0, 40
    sw $s0, 0($t0)
    addi $t0, $t0, 4
    sw $s1, 0($t0)
    addi $t0, $t0, 4
    sw $s2, 0($t0)
    addi $t0, $t0, 4
    sw $s3, 0($t0)
    addi $t0, $t0, 4
    sw $s4, 0($t0)
    addi $t0, $t0, 4
    sw $s5, 0($t0)
    addi $t0, $t0, 4
    
    
    
    
    

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
