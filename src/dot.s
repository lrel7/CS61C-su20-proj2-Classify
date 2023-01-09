.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
    # check length and stride first
    ble a2, x0, error_5
    ble a3, x0, error_6
    ble a4, x0, error_6

    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)

    li t0, 0 # counter
    li s0, 0 # result

    # handle stride
    li t3, 4
    mul t1, a3, t3 # increment of a0 for each loop
    mul t2, a4, t3 # increment of a1 for each loop

loop_start:

    # load an element from the two vector
    lw t3, 0(a0)
    lw t4, 0(a1)

    mul t3, t3, t4 # multiple t3 & t4
    add s0, s0, t3 # s0 += t3

    addi t0, t0, 1
    add a0, a0, t1 # increment a0
    add a1, a1, t2 # increment a1
    
    beq t0, a2, loop_end # counter == length
    j loop_start

loop_end:
    mv a0, s0 # copy the result int a0 (return a0)

    # Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
    
    ret

error_5:
    li a1, 5
    j exit2

error_6:
    li a1, 6
    j exit2