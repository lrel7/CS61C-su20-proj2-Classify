.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Prologue 
    # we're going to use t0 & t1 in this function
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)

    li t0, 0 # counter

    # check if the length is less than 1
    li t1, 1
    blt a0, t1, error # if length<1, error
    j loop_start  # jump to loop_start
    
error:
    li a1, 8 # error code
    j exit2  

loop_start:
    lw t1, 0(a0) # load an element into t1
    bge t1, x0, loop_continue # if positive, then skip (x0=0)
    sw x0, 0(a0) # if negative, set it to 0

loop_continue:
    addi a0, a0, 4 # increment a0  
    addi t0, t0, 1 # increment counter
    blt t0, a1, loop_start # if counter<length, continue loop

loop_end:
    # Epilogue 
    # load back t0 & t1
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8

	ret