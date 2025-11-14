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
    li $s6, 0x555555        # $s6 = gray (for border)
    
    li $s7, 1               # $s6 = pause/unpause game (0 -> paused, 1 -> unpaused)
    
    li $t9, 0               # $t9 = 0 (Placeholder for gravity timer)
    
    # Draw Gray Border
    
    li $a0, 0
    li $a1, 0
    li $a2, 9
    move $a3, $s6
    jal line_horiz
    
    li $a2, 16
    jal line_vert
    
    li $a1, 15
    li $a2, 9
    move $a3, $s6
    jal line_horiz
    
    li $a0, 8
    li $a1, 0
    li $a2, 16
    move $a3, $s6
    jal line_vert
    
    # End Draw Gray Border
    
    # Make initial and recurring (3x1) column
    
    jal make_column
    
    move $t6, $t8 # Initialize $t6 as the start position of the column (top block)
    move $t0, $t8 # Initialize $t0 as the start position of the column (top block)
    
    jal make_score_txt
    
    move $t6, $t0
    
    j game_loop
    
    make_column:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 144  # Start pixel in the middle
    move $t8, $t0       # Store top block position in $t8 for later
    addi $t7, $t0, 384  
    draw_columns:
        beq $t0, $t7, end_draw_col
        j gen_rand
        draw_pixel:
            sw $t1, 0($t0)
            add $t0, $t0, 128
            j draw_columns
    
    gen_rand: # Randomize color between 6 colors from $s0 - $s5
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
    
    end_draw_col:
    jr $ra
    
    # End drawing of column
    
    make_score_txt:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
    
        li $a0, 0
        li $a1, 16
        jal draw_S
        
        li $a0, 5
        li $a1, 16
        jal draw_C
        
        li $a0, 10
        li $a1, 16
        jal draw_O
        
        li $a0, 15
        li $a1, 16
        jal draw_R
        
        li $a0, 20
        li $a1, 16
        jal draw_E
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_S:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S2
        jal S3
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_C:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S3
        jal S4
        jal S5
        addi $a0, $t3, -1
        addi $a1, $t4, 3
        li $a2, 1
        jal line_vert
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_O:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
        jal S4
        jal S5
        addi $a0, $t3, -1
        addi $a1, $t4, 3
        li $a2, 1
        jal line_vert
        addi $a0, $t3, 2
        addi $a1, $t4, 3
        li $a2, 1
        jal line_vert
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_R:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S5
        jal S6
        addi $a0, $t3, -1
        addi $a1, $t4, 4
        li $a2, 3
        jal line_vert       # Segment 4
        addi $a0, $t3, -1
        addi $a1, $t4, 3
        li $a2, 4
        jal line_diag_br      # Segment 6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_E:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S3
        jal S4
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_8:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $t3, $a0, 1
        move $t4, $a1
        li $a2, 2
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
        jal S4
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    S0:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        move $a1, $t4
        jal line_horiz      # Segment 0
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S1: 
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $a0, $t3, 2
        addi $a1, $t4, 1
        jal line_vert       # Segment 1
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S2: 
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $a0, $t3, 2
        addi $a1, $t4, 4
        jal line_vert       # Segment 2
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S3:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        addi $a1, $t4, 6
        jal line_horiz      # Segment 3
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S4:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $a0, $t3, -1
        addi $a1, $t4, 4
        jal line_vert       # Segment 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S5:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $a0, $t3, -1
        addi $a1, $t4, 1
        jal line_vert       # Segment 5
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S6:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        addi $a1, $t4, 3
        jal line_horiz      # Segment 6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    line_vert: 
        # $a0 -> x coord
        # $a1 -> y coord
        # $a2 -> length of line
        # $a3 -> color of the line
        # direction is always down
        # Temps used: $t1, $t2, $t5, $t7
        lw $t1, ADDR_DSPL
        
        sll $t2, $a0, 2     # multiply horiz offset by 4
        add $t1, $t1, $t2   # Horizontal offset
        sll $t2, $a1, 7     # multiply vert offset by 128
        add $t1, $t1, $t2   # Vertical offset
        sll $t5, $a2, 7   # Scaled Length
        add $t7, $t1, $t5
        draw_line_vert:
            # $t4 -> iterate by t4 pixels
            # $t7 -> stop location
            beq $t1, $t7, end_line_vert
            sw $a3, 0($t1)
            addi $t1, $t1, 128
            j draw_line_vert
    end_line_vert:
    jr $ra
    
    line_horiz: 
        # $a0 -> x coord
        # $a1 -> y coord
        # $a2 -> length of line
        # $a3 -> color of the line
        # direction is always right
        # Temps used: $t1, $t2, $t5, $t7
        lw $t1, ADDR_DSPL
        
        sll $t2, $a0, 2     # multiply horiz offset by 4
        add $t1, $t1, $t2   # Horizontal offset
        sll $t2, $a1, 7     # multiply vert offset by 128
        add $t1, $t1, $t2   # Vertical offset
        sll $t5, $a2, 2     # Scaled Length (by 4)
        add $t7, $t1, $t5
        j draw_line_horiz
        draw_line_horiz:
            # $t4 -> iterate by t4 pixels
            # $t7 -> stop location
            beq $t1, $t7, end_line_horiz
            sw $a3, 0($t1)
            addi $t1, $t1, 4
            j draw_line_horiz
    end_line_horiz:
    jr $ra
    
    line_diag_br:
        # $a0 -> x coord
        # $a1 -> y coord 
        # $a2 -> length of line
        # $a3 -> color
        # direction is always bottom right
        # Temps used: $t1, $t2, $t4, $t5, $t7
        lw $t1, ADDR_DSPL
        
        li $a3, 0xffffff
        
        sll $t2, $a0, 2     # multiply horiz offset by 4
        add $t1, $t1, $t2   # Horizontal offset
        sll $t2, $a1, 7     # multiply vert offset by 128
        add $t1, $t1, $t2   # Vertical offset
        li $t4, 132
        mul $t5, $a2, $t4   # Scaled Length
        add $t7, $t1, $t5
        draw_line_diag:
            # $t4 -> iterate by t4 pixels
            # $t7 -> stop location
            beq $t1, $t7, end_line_diag
            sw $a3, 0($t1)
            addi $t1, $t1, 132
            j draw_line_diag
    end_line_diag:
    jr $ra
    
    clear_rect:
        # $a0 -> x coord
        # $a1 -> y coord 
        # $a2 -> width 
        # $a3 -> height
        # draws a black rectangle at the desired location
        
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        
        move $t3, $a3 # Store height in $t3 since line_horiz uses $a3 as color
        
        draw_clear_rect:
            beq $t3, $zero, end_draw_clear_rect
            li $a3, 0x000000
            jal line_horiz
            addi $a1, $a1, 1
            addi $t3, $t3, -1
            j draw_clear_rect
        end_draw_clear_rect:
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
        
    keyboard_input:                     # A key is pressed
        lw $a0, 4($t1)                  # Load second word from keyboard
        beq $a0, 0x70, respond_to_P     # Check if the key p was pressed
        
        beq $s7, $zero, game_loop       # If game is pause remove access to other inputs
        
        beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
        beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
        beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
        beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
        beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    
        li $v0, 1                       # ask system to print $a0
        syscall
    
        b game_loop
    
    respond_to_W:       # Shifts the columnn colors by one
    	j shift
    respond_to_A:       # Moves the column left by 1 unit
        li $t2, 0x555555
        lw $t3, -4($t0)
        beq $t2, $t3, end_key
        addi $t7, $t0, 384
    	j move_left
    respond_to_S:       # Moves the column down by 1 unit
        li $t2, 0x555555
        lw $t3, 384($t0)
        beq $t2, $t3, end_key
    	j move_down
    respond_to_D:       # Moves the column right by 1 unit
        li $t2, 0x555555
        lw $t3, 4($t0)
        beq $t2, $t3, end_key
        addi $t7, $t0, 384
    	j move_right
    respond_to_Q:       # Quits the program
    	li $v0, 10
    	syscall
    respond_to_P:       # Pauses the game
    	li $t1, 1
    	beq $s7, $t1, pause
    	beq $s7, $zero, unpause
    	pause:
    	   li $s7, 0
    	   jal draw_pause
    	   j end_key
    	unpause:
    	   li $s7, 1
    	   jal clear_pause
    	   j end_key

move_left:
    beq $t0, $t7, left_reset_start_pos
    lw $t3, 0($t0)  # Get color of block in column
    sw $t3, -4($t0) # Color the block to the left of the column the corresponding color
    li $t4, 0x000000
    sw $t4, 0($t0) # Color original block black
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
    li $t4, 0x000000
    sw $t4, 0($t0) # Color original block black
    addi $t0, $t0, 128 
    j move_right
    
right_reset_start_pos:
    addi $t6, $t0, -380
    addi $t0, $t0, -380
    j end_key

move_down:
    lw $t2, 0($t0) # Prev color
    li $t4, 0x000000
    sw $t4, 0($t0) # Displace
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
    
check_bottom:
    lw $t1, 0($t0)
    beq $t1, $s0, stop
    beq $t1, $s1, stop
    beq $t1, $s2, stop
    beq $t1, $s3, stop
    beq $t1, $s4, stop
    beq $t1, $s5, stop
    beq $t1, $s6, stop
    j end_check
    stop:
        # addi $t0, $t0, -128
        # jal check_win
        jal make_column
        move $t0, $t8
        move $t6, $t8
        j end_key

down_reset_start_pos:
    j check_bottom
    end_check:
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
        beq $t4, $t5, shift_reset_start_pos
        lw $t2, 0($t0)
        sw $t3, 0($t0)
        move $t3, $t2
        addi $t0, $t0, 128
        addi $t4, $t4, 1
        j next
    j end_key

shift_reset_start_pos:
    move $t0, $t6
    j end_key

draw_pause:
    addi $sp, $sp, -4   # Move the stack to an empty location
    sw $ra, 0($sp)      # Push the return address register onto the stack
    li $a0, 60
    li $a1, 0
    li $a2, 3
    li $a3, 0xffffff
    jal line_vert
    
    li $a0, 62
    li $a1, 0
    li $a2, 3
    li $a3, 0xffffff
    jal line_vert
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4    # Move the stack to its original location
    jr $ra
    
clear_pause:
    addi $sp, $sp, -4   # Move the stack to an empty location
    sw $ra, 0($sp)      # Push the return address register onto the stack
    
    li $a0, 60
    li $a1, 0
    li $a2, 3
    li $a3, 3
    jal clear_rect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4    # Move the stack to its original location
    jr $ra
    

repaint:
    move $t6, $t0
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

gravity:
    li $t9, 0
    j respond_to_S

game_loop:
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    end_key:
    beq $s7, $zero, game_loop
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	j repaint
	end_repaint:
	li $v0, 32                      # Set to sleep value
	li $a0, 17                      # Sleeps for 17 millisecond which is about 1/60 of a second
	syscall
	addi $t9, $t9, 17               # Increment gravity timer
	li $t1, 510                    # 510 milliseconds = 0.51 seconds
	beq $t9, $t1, gravity           # If its been 1.02 seconds uninterrupted by any falling inputs move column down 

    # 5. Go back to Step 1
    j game_loop
