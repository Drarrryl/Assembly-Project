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
    
    li $s0, 0xff0000        # $s0 = red
    li $s1, 0x00ff00        # $s1 = green
    li $s2, 0x0000ff        # $s2 = blue
    li $s3, 0xff7f00        # $s3 = orange
    li $s4, 0x00ffff        # $s4 = cyan
    li $s5, 0xffff00        # $s5 = yellow
    
    li $t9, 0x000000        # $t9 = black
    li $t2, 0x555555        # $t2 = gray (for border)
    li $t1, 0x000000        # $t1 = placeholder value
    
    addi $t7, $t0, 32

    draw_row_right:
        beq $t0, $t7, change_end_pixel1
        sw $t2 0($t0)
        addi $t0, $t0, 4
        j draw_row_right
        
    change_end_pixel1:
        addi $t7, $t7, 1920
        j draw_col_down
        
    draw_col_down:
        beq $t0, $t7, change_end_pixel2
        sw $t2 0($t0)
        addi $t0, $t0, 128
        j draw_col_down
        
    change_end_pixel2:
        subi $t7, $t7, 32
        j draw_row_left
        
    draw_row_left:
        beq $t0, $t7, change_end_pixel3
        sw $t2 0($t0)
        subi $t0, $t0, 4
        j draw_row_left
        
    change_end_pixel3:
        subi $t7, $t7, 1920
        j draw_col_up
        
    draw_col_up:
        beq $t0, $t7, end_draw_border
        sw $t2 0($t0)
        subi $t0, $t0, 128
        j draw_col_up
    
    end_draw_border:
    
    addi $t8, $t0, 144 # Start pixel in the middle
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
    move $t0, $t8 # Start at top of column
    move $t6, $t0 
    
    j game_loop
    
    keyboard_input:                     # A key is pressed
        lw $a0, 4($t1)                  # Load second word from keyboard
        beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
        beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
        beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
        beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
        beq $a0, 0x71, respond_to_Q     # Check if the key d was pressed
    
        li $v0, 1                       # ask system to print $a0
        syscall
    
        b game_loop
    
    respond_to_W:
    	j shift
    respond_to_A:
        li $t2, 0x555555
        lw $t3, -4($t0)
        beq $t2, $t3, end_key
        addi $t7, $t0, 384
    	j move_left
    respond_to_S:
        li $t2, 0x555555
        lw $t3, 384($t0)
        beq $t2, $t3, end_key
    	j move_down
    respond_to_D:
        li $t2, 0x555555
        lw $t3, 4($t0)
        beq $t2, $t3, end_key
        addi $t7, $t0, 384
    	j move_right
    respond_to_Q:
    	li $v0, 10                      # Quit gracefully
    	syscall

move_left:
    beq $t0, $t7, left_reset_start_pos
    lw $t3, 0($t0)  # Get color of block in column
    sw $t3, -4($t0) # Color the block to the left of the column the corresponding color
    sw $t9, 0($t0) # Color original block black
    addi $t0, $t0, 128 
    j move_left
    
left_reset_start_pos:
    sub $t6, $t0, 388
    sub $t0, $t0, 388
    j end_key

move_right:
    beq $t0, $t7, right_reset_start_pos
    lw $t3, 0($t0)  # Get color of block in column
    sw $t3, 4($t0) # Color the block to the left of the column the corresponding color
    sw $t9, 0($t0) # Color original block black
    addi $t0, $t0, 128 
    j move_right
    
right_reset_start_pos:
    subi $t6, $t0, 380
    subi $t0, $t0, 380
    j end_key

move_down:
    lw $t2, 0($t0) # Prev color
    sw $t9, 0($t0) # Displace
    move $t3, $t2 # Next color
    addi $t0, $t0, 128 # Start 1 column down next iteration
    li $t4, 0 # Index
    li $t5, 3 # End Index
    next_down:
        beq $t4, $t5, down_reset_start_pos
        lw $t2, 0($t0) # Prev color
        sw $t3, 0($t0) # Replace w/ new color
        move $t3, $t2 # Next color
        addi $t0, $t0, 128
        addi $t4, $t4, 1
        j next_down
    j end_key
    
    
down_reset_start_pos:
    addi $t6, $t6, 128
    move $t0, $t6
    j end_key

shift:
    lw $t2, 0($t0) # Prev color
    lw $t3, 256($t0) # Next color
    sw $t3, 0($t0) # Shift color
    move $t3, $t2 # Next color -> prev color
    addi $t0, $t0, 128
    li $t4, 0 # Index
    li $t5, 2 # End Index
    next:
        beq $t4, $t5, reset_start_pos
        lw $t2, 0($t0)
        sw $t3, 0($t0)
        move $t3, $t2
        addi $t0, $t0, 128
        addi $t4, $t4, 1
        j next
    j end_key

reset_start_pos:
    move $t0, $t6
    j end_key

repaint:
    lw $t0, ADDR_DSPL
    lw $t2, 0($t0)
    sw $t2, 0($t0)
    li $t3, 0  # Start Index Row
    li $t4, 14 # Stop Index Row
    next_paint_r:
        beq $t3, $t4, repaint_reset_start_pos
        li $t5, 0 # Start Index Col
        li $t7, 9 # Stop Index Col
        next_paint_c:
            beq $t5, $t7, end_col
            lw $t2, 0($t0)
            sw $t2, 0($t0)
            addi $t5, $t5, 1
            j next_paint_c
        end_col:
        addi $t3, $t3, 1
        j next_paint_r
    
repaint_reset_start_pos:
    move $t0, $t6
    j end_repaint

game_loop:
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    end_key:
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	j repaint
	end_repaint:
	li $v0, 32                      # Set to sleep value
	li $a0, 17                      # Sleeps for 17 millisecond which is about 1/60 of a second
	syscall

    # 5. Go back to Step 1
    j game_loop
