.import ../../src/write_matrix.s
.import ../../src/utils.s

.data
m0: .word 1, 2, 3, 4, 5, 6, 7, 8, 9 # MAKE CHANGES HERE TO TEST DIFFERENT MATRICES
file_path: .asciiz "outputs/test_write_matrix/student_write_outputs.bin"

.text
main:
    # load addresses
    la a0, file_path # pointer to the filename
    la a1, m0 # pointer to the matrix

    # set rows & cols
    li a2, 3
    li a3, 3

    # Write the matrix to a file
    jal write_matrix 

    # Exit the program
    jal exit
