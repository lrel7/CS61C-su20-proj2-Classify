.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:

    # Prologue
    # we need t0, t1, t2, t3
    addi sp, sp, -16
    sw, t0, 0(sp)
    sw, t1, 4(sp)
    sw, t2, 8(sp)
    sw, t3, 12(sp)

    # check the length
    li t0, 1 # used for comparison, can also used for counter
    blt a1, t0, error

    lw t1, 0(a0) # record the largest element 
    li t2, 1 # record its index
    j loop_start

error:
    li a1, 7
    j exit2

loop_start:
    addi t0, t0, 1 # increment the counter
    addi a0, a0, 4 # increment a0
    lw t3, 0(a0) # load an element

    # if the current element is not larger than t1, continue
    ble t3, t1, loop_continue

    # if the current element is larger, replace t1 and t2
    mv t1, t3 # replace t1 with the current element
    mv t2, t0 # replace t2 with the current index 

loop_continue:
    beq t0, a1, loop_end # if counter=length, end
    j loop_start

loop_end:
    addi a0, t2, -1 # load the result into a0 (return a0)

    # Epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16

    ret