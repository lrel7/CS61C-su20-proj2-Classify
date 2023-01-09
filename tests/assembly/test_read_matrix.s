.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # load the address of the filename
    la s0, file_path

    # allocate memory for the number of rows
    li a0, 4
    jal malloc
    mv s1, a0 # get a copy of the pointer of rows

    # allocate memory for the number of columns
    li a0, 4
    jal malloc
    mv s2, a0 # get a copy of the pointer of cols

    # call read_matrix
    mv a0, s0 # a0 : pointer of filename
    mv a1, s1 # a1 : pointer of rows
    mv a2, s2 # a2 : pointer of cols
    jal read_matrix

    # Print out elements of matrix
    lw a1, 0(s1)
    lw a2, 0(s2)
    jal print_int_array

    # Terminate the program
    jal exit