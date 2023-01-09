.globl write_matrix

# buffer used to store rows and cols
# this can void malloc
.data
rows_cols_buffer: .word 0 0

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    # we use s0~s3, and should also save ra
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    # save the args
    mv s0, a0 # pointer to the filename
    mv s1, a1 # pointer to the matrix

    # calculate the # of elements in the matrix
    mul s3, a2, a3

    # store # of rows & cols into the buffer
    la t0, rows_cols_buffer
    sw a2, 0(t0)
    sw a3, 4(t0)

    # open the file
    mv a1, s0 # pointer to the filename
    li a2, 1 # permission : write-only(1)
    jal fopen
    li t0, -1
    beq a0, t0, error_fopen # if a0==-1, fopen fails

    # now a0 hold the file descriptor, get a copy of it
    mv s2, a0

    # now start to write into the file
    # first write the # of rows and cols
    mv a1, s2 # file descriptor
    la a2, rows_cols_buffer # pointer to the buffer
    li a3, 2 # number of elements
    li a4, 4 # size of each element in bytes
    jal fwrite
    bne a0, a3, error_fwrite # if a0!=a3, fwrite fails

    # now write the elements
    # a1 is still the file descriptor, so no need to set it
    mv a2, s1 # pointer to the matrix
    mv a3, s3 # number of elements
    jal fwrite
    bne a0, a3, error_fwrite # if a0!=a3, fwrite fails

    # close the file
    # a1 is still the file descriptor, so no need to set it
    jal fclose
    bnez a0, error_fclose # if a0!=0 (Branch if Not Equal to Zero)

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20

    ret

error_fopen:
    li a1, 53
    jal exit2

error_fwrite:
    li a1, 54
    jal exit2

error_fclose:
    li a1, 55
    jal exit2