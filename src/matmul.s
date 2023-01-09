.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    ble a1, x0, error_2
    ble a2, x0, error_2
    ble a4, x0, error_3
    ble a5, x0, error_3
    bne a2, a4, error_4 # don't match

    # Prologue
    # we use s0~s7, and ra for "jal dot"
    addi sp, sp, -36
    sw ra, 0(sp)
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)

    li t0, 0 # row index for m0
    li t1, 0 # col index for m1
    # li t2, 0 # index for d

    # save arguments (we will pass a0~a4 to dot)
    mv s0, a0 # the start of m0's row vector
    mv s1, a1 # m0's rows
    mv s2, a2 # m0's cols
    mv s3, a3 # the start of m1's col vector
    mv s4, a4 # m1's rows
    mv s5, a5 # m1's cols
    mv s6, a6 # d's pos

    # need another register to save s3
    # because m1 has to go back to its
    # first col after an inner loop
    mv s7, s3

    # calculate m0's move between rows
    slli t2, s2, 2 # 4*cols

# increment m0's row
outer_loop_start:
    beq t0, s1, outer_loop_end # gone through all rows of m0

# increment m1's col
inner_loop_start:
    # load args for dot
    mv a0, s0 # start of m0's row vector
    mv a1, s3 # start of m1's col vector
    mv a2, s2 # length==m0's cols==m1's rows
    li a3, 1 # the stride of m0's row vector=1
    mv a4, a5 # the stride of m1's col vector=it's cols

    # prologue 
    # we use t0~t4 in dot, so save them
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)

    # call dot
    jal dot

    # epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp) 
    addi sp, sp, 20

    # store the result into the new matrix
    sw a0, 0(s6)

    # m1 moves to the next col
    addi t1, t1, 1 # increment index of col
    addi s3, s3, 4 # increment col pointer

    # d moves to the next position
    addi s6, s6, 4

    # judge whether m1's cols are all gone through
    beq t1, s5, inner_loop_end

    j inner_loop_start

inner_loop_end:
    # m0 moves to the next row
    addi t0, t0, 1 # increment index of row
    add s0, s0, t2 # increment row pointer

    # m1 moves back to the first col
    li t1, 0 # set index of back col to 0
    mv s3, s7 # moves back to the first col

    j outer_loop_start

outer_loop_end:
    # no return value

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    
    ret

error_2:
    li a1, 2
    j exit2
error_3:
    li a1, 3
    j exit2
error_4:
    li a1, 4
    j exit2