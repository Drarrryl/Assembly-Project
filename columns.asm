################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Yujin Kim, 1009852633
# Student 2: Darryl Lubin, 1009115191
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
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

RED:
    .word 0xff0000

GREEN:
    .word 0x00ff00

BLUE:
    .word 0x0000ff

ORANGE:
    .word 0xff7f00

CYAN:
    .word 0x00ffff

YELLOW:
    .word 0xffff00

GRAY:
    .word 0x555555
    
GRAVITY_TICK:
    .word 17
##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game
    
main:
    lw $t0, ADDR_DSPL
    
    li $s5, 0           # $s5 = 0 (Placeholder for gravity timer)
    li $s6, 510             # $s6 = 510 milliseconds = 0.51 seconds
    
    li $s0, 0               # $s0 = score at right digit (_X)
    li $s1, 0               # $s1 = score at left digit (X_)
    
    addi $sp, $sp, -4   # Move the stack to an empty location
    li $t1, 1
    sw $t1, 0($sp)      # 0($sp) = pause/unpause game (0 -> paused, 1 -> unpaused)
    
    
    # Draw Gray Border
    
    li $a0, 0
    li $a1, 0
    li $a2, 9
    lw $a3, GRAY
    jal line_horiz
    
    li $a2, 16
    jal line_vert
    
    li $a1, 15
    li $a2, 9
    lw $a3, GRAY
    jal line_horiz
    
    li $a0, 8
    li $a1, 0
    li $a2, 16
    lw $a3, GRAY
    jal line_vert
    
    li $a0, 9
    li $a1, 0
    li $a2, 2
    lw $a3, GRAY
    jal line_horiz
    
    li $a0, 9
    li $a1, 4
    li $a2, 12
    lw $a3, GRAY
    jal line_vert
    
    li $a0, 10
    li $a1, 1
    li $a2, 15
    lw $a3, GRAY
    jal line_vert
    
    
    # End Draw Gray Border
    
    # Make initial and recurring (3x1) column
    
    jal make_column
    jal move_column
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 144
    
    move $t6, $t0 # Initialize $t6 as the start position of the column (top block)
    
    jal make_score_txt
    
    move $t6, $t0
    
    # Start the game
    
    j game_loop
    
    # Draw column on the side panel
    
    make_column:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 164  # Start pixel on the side panel
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
        lw $t1, RED
        j draw_pixel
    pick_green:
        lw $t1, GREEN
        j draw_pixel
    pick_blue:
        lw $t1, BLUE
        j draw_pixel
    pick_orange:
        lw $t1, ORANGE
        j draw_pixel
    pick_cyan:
        lw $t1, CYAN
        j draw_pixel
    pick_yellow:
        lw $t1, YELLOW
        j draw_pixel
    
    end_draw_col:
    jr $ra
    
    # Move column to the middle of the paying field then create a new column on the side panel
    
    move_column:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 164  # Set to the first cell of the column on the side panel
        lw $t1, 0($t0)      # Store color of the first cell in $t1
        lw $t2, 128($t0)    # Store color of the second cell in $t2
        lw $t3, 256($t0)    # Store color of the third cell in $t3
        
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 144      # Set to the middle of the playing field
        sw $t1, 0($t0)          # Set color of the first cell of the column
        sw $t2, 128($t0)        # Set color of the second cell of the column
        sw $t3, 256($t0)        # Set color of the third cell of the column
        
        jal make_column
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    
    make_score_txt:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
    
        li $a0, 0
        li $a1, 16
        jal draw_S
        
        li $a0, 4
        li $a1, 16
        jal draw_C
        
        li $a0, 8
        li $a1, 16
        jal draw_O
        
        li $a0, 12
        li $a1, 16
        jal draw_R
        
        li $a0, 16
        li $a1, 16
        jal draw_E
        
        li $a0, 20
        li $a1, 16
        jal draw_colon
        
        li $a0, 24
        li $a1, 16
        jal draw_0
        
        li $a0, 28
        li $a1, 16
        jal draw_0
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_S:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
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
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S3
        jal S4
        jal S5
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_O:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
        jal S4
        jal S5
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_R:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S4
        jal S5
        jal S6
        addi $a1, $t4, 2
        li $a2, 3
        jal line_diag_br      # Segment 6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_E:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S3
        jal S4
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_colon:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t4, $a1
        li $a2, 1
        li $a3, 0xffffff
        
        addi $a1, $t4, 1
        li $a2, 1
        jal line_vert       # Segment 4
        
        addi $a1, $t4, 3
        li $a2, 1
        jal line_vert       # Segment 4
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_0:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
        jal S4
        jal S5
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_1:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S1
        jal S2
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_2:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S3
        jal S4
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_3:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_4:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S1
        jal S2
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_5:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S2
        jal S3
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_6:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S2
        jal S3
        jal S4
        jal S5
        jal S6
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_7:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S5
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    
    draw_8:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
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
    
    draw_9:
        # $a0 -> x coord
        # $a1 -> y coord
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $t3, $a0
        move $t4, $a1
        li $a2, 3
        li $a3, 0xffffff
        jal S0
        jal S1
        jal S2
        jal S3
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
        addi $a0, $a0, 2
        move $a1, $t4
        jal line_vert       # Segment 1
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S2: 
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        addi $a0, $t3, 2
        addi $a1, $t4, 2
        jal line_vert       # Segment 2
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S3:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        addi $a1, $t4, 4
        jal line_horiz      # Segment 3
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S4:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        addi $a1, $t4, 2
        jal line_vert       # Segment 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S5:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        move $a1, $t4
        jal line_vert       # Segment 5
        lw $ra, 0($sp)
        addi $sp, $sp, 4    # Move the stack to its original location
        jr $ra
    S6:
        addi $sp, $sp, -4   # Move the stack to an empty location
        sw $ra, 0($sp)      # Push the return address register onto the stack
        move $a0, $t3
        addi $a1, $t4, 2
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
        
        lw $t1, 0($sp)
        beq $t1, $zero, game_loop       # If game is pause remove access to other inputs
        
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
        beq $t2, $t3, end_key   # Reached the border
        lw $t4, 252($t0)    # Left to the last cell of the column
        bne $zero, $t4, end_key     # Collision detected
        addi $t7, $t0, 384
    	j move_left
    respond_to_S:       # Moves the column down by 1 unit
        move $t0, $t6
    
        li $t2, 0x555555
        lw $t3, 384($t0)
        beq $t2, $t3, end_key
    	j move_down
    respond_to_D:       # Moves the column right by 1 unit
        li $t2, 0x555555
        lw $t3, 4($t0)
        beq $t2, $t3, end_key   # Reached the border
        lw $t4, 260($t0)    # Right to the last cell of the column
        bne $zero, $t4, end_key     # Collision detected
        addi $t7, $t0, 384
    	j move_right
    respond_to_Q:       # Quits the program
    	li $v0, 10
    	syscall
    respond_to_P:       # Pauses the game
    	li $t1, 1
    	lw $t2, 0($sp)
    	beq $t2, $t1, pause
    	beq $t2, $zero, unpause
    	pause:
    	   sw $zero, 0($sp)
    	   jal draw_pause
    	   j end_key
    	unpause:
    	   li $t1, 1
    	   sw $t1, 0($sp)
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
    jal check_bottom
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
    lw $t1, 384($t0)
    lw $t2, RED
    beq $t1, $t2, stop
    lw $t2, GREEN
    beq $t1, $t2, stop
    lw $t2, BLUE
    beq $t1, $t2, stop
    lw $t2, ORANGE
    beq $t1, $t2, stop
    lw $t2, CYAN
    beq $t1, $t2, stop
    lw $t2, YELLOW
    beq $t1, $t2, stop
    lw $t2, GRAY
    beq $t1, $t2, stop
    jr $ra
    stop:
        # Check if there is a match
        jal check_matches
        
        # Check game over condition
        jal check_game_over
        
        li $v0, 32
        li $a0, 510     # Sleep for 30 frames
        syscall
        
        # Move column on the side panel into the playing field then generate a new column
        jal move_column
        
        lw  $t0, ADDR_DSPL
        addi $t0, $t0, 144  # Set $t0 to be the first cell of the column in the playing field
        move $t6, $t0
        
        j end_key

down_reset_start_pos:
    addi $t6, $t6, 128
    move $t0, $t6
    jal check_bottom
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
    li $s5, 0
    j respond_to_S

update_score:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Digit 0 (_X)
    li $a0, 28
    li $a1, 16
    li $a2, 3
    li $a3, 5
    jal clear_rect
    
    li $a0, 28
    li $a1, 16
    li $a2, 1
    li $a3, 0xffffff
    beq $s0, $zero, digit0_0
    li $t1, 1
    beq $s0, $t1, digit0_1
    li $t1, 2
    beq $s0, $t1, digit0_2
    li $t1, 3
    beq $s0, $t1, digit0_3
    li $t1, 4
    beq $s0, $t1, digit0_4
    li $t1, 5
    beq $s0, $t1, digit0_5
    li $t1, 6
    beq $s0, $t1, digit0_6
    li $t1, 7
    beq $s0, $t1, digit0_7
    li $t1, 8
    beq $s0, $t1, digit0_8
    li $t1, 9
    beq $s0, $t1, digit0_9
    
    digit0_0:
        jal draw_0
        j update_digit1
    
    digit0_1:
        jal draw_1
        j end_update_score
    
    digit0_2:
        jal draw_2
        j end_update_score
    
    digit0_3:
        jal draw_3
        j end_update_score
    
    digit0_4:
        jal draw_4
        j end_update_score
    
    digit0_5:
        jal draw_5
        j end_update_score
    
    digit0_6:
        jal draw_6
        j end_update_score
    
    digit0_7:
        jal draw_7
        j end_update_score
    
    digit0_8:
        jal draw_8
        j end_update_score
    
    digit0_9:
        jal draw_9
        j end_update_score
    
    update_digit1:
    # Digit 1 (X_)
    li $a0, 24
    li $a1, 16
    li $a2, 3
    li $a3, 5
    jal clear_rect
    
    li $a0, 24
    li $a1, 16
    li $a2, 1
    li $a3, 0xffffff
    beq $s1, $zero, digit1_0
    li $t1, 1
    beq $s1, $t1, digit1_1
    li $t1, 2
    beq $s1, $t1, digit1_2
    li $t1, 3
    beq $s1, $t1, digit1_3
    li $t1, 4
    beq $s1, $t1, digit1_4
    li $t1, 5
    beq $s1, $t1, digit1_5
    li $t1, 6
    beq $s1, $t1, digit1_6
    li $t1, 7
    beq $s1, $t1, digit1_7
    li $t1, 8
    beq $s1, $t1, digit1_8
    li $t1, 9
    beq $s1, $t1, digit1_9
    
    digit1_0:
        jal draw_0
        j end_update_score
    
    digit1_1:
        jal draw_1
        j end_update_score
    
    digit1_2:
        jal draw_2
        j end_update_score
    
    digit1_3:
        jal draw_3
        j end_update_score
    
    digit1_4:
        jal draw_4
        j end_update_score
    
    digit1_5:
        jal draw_5
        j end_update_score
    
    digit1_6:
        jal draw_6
        j end_update_score
    
    digit1_7:
        jal draw_7
        j end_update_score
    
    digit1_8:
        jal draw_8
        j end_update_score
    
    digit1_9:
        jal draw_9
        j end_update_score
     
    end_update_score:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

score_overflow:
    addi $s1, $s1, 1
    li $s0, 0
    j end_overflow

check_matches:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    loop_clear_matches:     # Find matches until no matches found
        jal clear_matches   # Delete matches
        beq $v0, $zero, end_check_matches   # No matches found
        
        li $v0, 32
        li $a0, 510     # Sleep for 30 frames
        syscall
        
        jal drop_gems   # Drop gems
        lw $t1, GRAVITY_TICK
        li $s5, 0
        beq $s6, $t1, loop_clear_matches
        addi $s0, $s0, 1    # Increment score by 1
        li $t1, 10
        beq $s0, $t1, score_overflow
        end_overflow:
        jal update_score
        lw $t1, GRAVITY_TICK
        sub $s6, $s6, $t1
        j loop_clear_matches
    
    end_check_matches:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

clear_matches:
    li $v0, 0   # $v0 = 0 -> no matches found $v0 = 1 -> at least one match found
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 132  # Start at the first cell inside the border
    
    # Check horizontal match (x < 5, y < 15)
    
    li $t1, 0   # y index
    li $t2, 14   # y upper bound
    horiz_y_loop:
        beq $t1, $t2, end_horiz_y_loop
        li $t3, 0   # x index
        li $t4, 5   # x upper bound
        horiz_x_loop:
            beq $t3, $t4, end_horiz_x_loop
            lw $t5, 0($t0)
            
            # Empty cell
            beq $t5, $zero, horiz_skip_cell
            
            lw $t6, 4($t0)
            lw $t7, 8($t0)
            bne $t5, $t6, horiz_skip_cell
            bne $t6, $t7, horiz_skip_cell
            
            # Horizontal match
            sw $zero, 0($t0)
            sw $zero, 4($t0)
            sw $zero, 8($t0)
            
            li $v0, 1   # A match was found
            
            horiz_skip_cell:
            addi $t0, $t0, 4
            addi $t3, $t3, 1
            j horiz_x_loop
        end_horiz_x_loop:
        addi $t0, $t0, -20
        addi $t0, $t0, 128
        addi $t1, $t1, 1
        j horiz_y_loop
    end_horiz_y_loop:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 132
    
    # Check vertical match (x < 7, y < 12)
    
    li $t1, 0   # y index
    li $t2, 12   # y upper bound
    vert_y_loop:
        beq $t1, $t2, end_vert_y_loop
        li $t3, 0   # x index
        li $t4, 7   # x upper bound
        vert_x_loop:
            beq $t3, $t4, end_vert_x_loop
            lw $t5, 0($t0)
            
            # Empty cell
            beq $t5, $zero, vert_skip_cell
            
            lw $t6, 128($t0)
            lw $t7, 256($t0)
            bne $t5, $t6, vert_skip_cell
            bne $t6, $t7, vert_skip_cell
            
            # Vertical match
            sw $zero, 0($t0)
            sw $zero, 128($t0)
            sw $zero, 256($t0)
            
            li $v0, 1   # A match was found
            
            vert_skip_cell:
            addi $t0, $t0, 4
            addi $t3, $t3, 1
            j vert_x_loop
        end_vert_x_loop:
        addi $t0, $t0, -28
        addi $t0, $t0, 128
        addi $t1, $t1, 1
        j vert_y_loop
    end_vert_y_loop:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 132
    
    # Check diagonal down match (x < 5, y < 12)
    
    li $t1, 0   # y index
    li $t2, 12   # y upper bound
    diag_down_y_loop:
        beq $t1, $t2, end_diag_down_y_loop
        li $t3, 0   # x index
        li $t4, 5   # x upper bound
        diag_down_x_loop:
            beq $t3, $t4, end_diag_down_x_loop
            lw $t5, 0($t0)
            
            # Empty cell
            beq $t5, $zero, diag_down_skip_cell
            
            lw $t6, 132($t0)
            lw $t7, 264($t0)
            bne $t5, $t6, diag_down_skip_cell
            bne $t6, $t7, diag_down_skip_cell
            
            # Diagonal down match
            sw $zero, 0($t0)
            sw $zero, 132($t0)
            sw $zero, 264($t0)
            
            li $v0, 1   # A match was found
            
            diag_down_skip_cell:
            addi $t0, $t0, 4
            addi $t3, $t3, 1
            j diag_down_x_loop
        end_diag_down_x_loop:
        addi $t0, $t0, -20
        addi $t0, $t0, 128
        addi $t1, $t1, 1
        j diag_down_y_loop
    end_diag_down_y_loop:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 388  # Start at the first cell of the third row inside the border
    
    # Check diagonal up match (x < 5, y < 12)
    
    li $t1, 0   # y index
    li $t2, 12   # y upper bound
    diag_up_y_loop:
        beq $t1, $t2, end_diag_up_y_loop
        li $t3, 0   # x index
        li $t4, 5   # x upper bound
        diag_up_x_loop:
            beq $t3, $t4, end_diag_up_x_loop
            lw $t5, 0($t0)
            
            # Empty cell
            beq $t5, $zero, diag_up_skip_cell
            
            lw $t6, -124($t0)
            lw $t7, -248($t0)
            bne $t5, $t6, diag_up_skip_cell
            bne $t6, $t7, diag_up_skip_cell
            
            # Diagonal up match
            sw $zero, 0($t0)
            sw $zero, -124($t0)
            sw $zero, -248($t0)
            
            li $v0, 1   # A match was found
            
            diag_up_skip_cell:
            addi $t0, $t0, 4
            addi $t3, $t3, 1
            j diag_up_x_loop
        end_diag_up_x_loop:
        addi $t0, $t0, -20
        addi $t0, $t0, 128
        addi $t1, $t1, 1
        j diag_up_y_loop
    end_diag_up_y_loop:
    
    jr $ra

drop_gems:                
    li $t1, 0
    li $t2, 14  # Drop gems 13 times then stop when $t1 reaches 14
    drop_gems_loop:
        beq $t1, $t2, end_drop_gems
        
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 1668     # Start at the first cell of the second last row
        
        li $t3, 0
        li $t4, 7
        drop_gems_x_loop:
            beq $t3, $t4, end_drop_gems_x_loop
            li $t5, 13
            drop_gems_y_loop:
                beq $zero, $t5, end_drop_gems_y_loop
                
                lw $t6, 0($t0)      # Current color
                lw $t7, 128($t0)    # Below color
                
                beq $t6, $zero, skip_drop   # No gems to drop
                bne $t7, $zero, skip_drop   # No gems to drop
                
                # Drop gem
                sw $zero, 0($t0)    # Set current cell black
                sw $t6, 128($t0)    # Set below cell the color of the previous current cell
                
                skip_drop:
                    addi $t5, $t5, -1
                    addi $t0, $t0, -128
                    j drop_gems_y_loop
                    
            end_drop_gems_y_loop:
                addi $t3, $t3, 1
                addi $t0, $t0, 1664     # Return to the second last row
                addi $t0, $t0, 4        # Move 1 column right
                j drop_gems_x_loop
        
        end_drop_gems_x_loop:
            addi $t1, $t1, 1
            j drop_gems_loop
            
end_drop_gems:
    jr $ra

check_game_over:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 132
    
    li $t1, 0       # x index
    li $t2, 7        # x upper bound
    check_game_over_loop:
        beq $t1, $t2, check_middle_space
        lw $t3, 0($t0)
        bne $t3, $zero, game_over   # gem found on the top of the playing field -> game over
        
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        j check_game_over_loop
    
    check_middle_space:
        lw $t0, ADDR_DSPL
        addi $t0, $t0, 144  # Set to middle of the first row
        lw $t3, 128($t0)
        bne $t3, $zero, game_over   # Column generating space is occupied -> game over
        lw $t3, 256($t0)
        bne $t3, $zero, game_over   # Column generating space is occupied -> game over
    
end_check_game_over:
    jr $ra

game_over:
    li $v0, 10
    syscall

game_loop:
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    end_key:
    lw $t1, 0($sp)
    beq $t1, $zero, game_loop
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	j repaint
	end_repaint:
	li $v0, 32                      # Set to sleep value
	li $a0, 17                      # Sleeps for 17 millisecond which is about 1/60 of a second
	syscall
	lw $t1, GRAVITY_TICK
	add $s5, $s5, $t1               # Increment gravity timer
	beq $s5, $s6, gravity           # If its been 1.02 seconds uninterrupted by any falling inputs move column down 

    # 5. Go back to Step 1
    j game_loop
