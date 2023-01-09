.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
    # we use s0~s2
    # and should also save ra
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
	
    # save a1, a2
    mv s1, a1
    mv s2, a2

    # open the file, and check if failed
    mv a1, a0 # a1 should be the string pointer
    li a2, 0 # a2 is the permission bit, 0-read only
    jal fopen
    li t0, -1
    beq a0, t0, error_fopen # a0==-1 means that fopen fails

    # now a0 holds the file descriptor, save a copy of it
    mv s0, a0

    # malloc 8 bytes for the buffer first 
    li a0, 8 
    jal malloc

    # now a0 holds the buffer pointer, save a copy of it
    mv s3, a0

    # start to read rows and cols from the file
    mv a1, s0 # a1 should be the file descriptor
    mv a2, s3 # a2 should be the buffer
    li a3, 8 # number of bytes to read from the file
    jal fread
    bne a0, a3, error_fread # a0 != the # of bytes we want to read, means that fread fails

    # read from the buffer(s3 holds its pointer) 
    lw t0, 0(s3) # the rows
    lw t1, 4(s3) # the cols

    # store the rows and cols back to the pointers
    sw t0, 0(s1)
    sw t1, 0(s2)

    # now s1 & s2 are free, we can use them
    
    # malloc for the matrix
    mul a0, t0, t1 # rows * cols elements
    slli a0, a0, 2 # a0*4 bytes
    mv s2, a0 # save a copy of a0
    jal malloc

    # now a0 holds the pointer to the matrix, save a copy of it
    mv s1, a0

    # start to read elements from the file
    mv a1, s0 # a1 should be the file descriptor
    mv a2, s1 # a2 should be the buffer
    mv a3, s2 # when fread, a3 should be the number of bytes to read
    jal fread
    bne a0, a3, error_fread # a0 != the # of bytes we want to read, means that fread fails

    # close the file
    mv a1, s0 # a1 should be the file descriptor
    jal fclose
    bne a0, x0, error_fclose # a0 != 0 means that fclose fails 

    # store the pointer of the matrix back to a0
    mv a0, s1

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20

    ret

error_fopen:
    li a1, 50 
    j exit2

error_fread:
    li a1, 51
    j exit2

error_fclose:
    li a1, 52 
    j exit2