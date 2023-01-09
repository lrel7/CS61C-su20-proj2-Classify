.globl classify

# buffer to store the number of rows & cols
.data
buffer1: .word 0 0
buffer2: .word 0 0
buffer3: .word 0 0

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    # =====================================
    # =====================================

    # check the number of command line args
    li t0, 5 # totally 5 arguments
    bne a0, t0, wrong_argc 

    # prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    # save args
    mv s0, a1 # pointer to argv
    mv s1, a2 # print_classification

	# =====================================
    # LOAD MATRICES
    # =====================================

    # load the args
    lw a0, 4(s0) # the pointer to m0 path
    la a1, buffer1 # the address of buffer1, also the pointer to the # of rows
    addi a2, a1, 4 # the pointer to the # of cols

    # Load pretrained m0
    jal read_matrix

    # a0 holds the pointer to m0
    # get a copy of it
    mv s2, a0

    # ======================================
    
    # load the args
    lw a0, 8(s0) # the pointer to m1 path
    la a1, buffer2 # the address of buffer2, also the pointer to the # of rows
    addi a2, a1, 4 # the pointer to the # of cols

    # Load pretrained m1
    jal read_matrix

    # a0 holds the pointer to m1
    # get a copy of it
    mv s3, a0

    # =======================================

    # load the args
    lw a0, 12(s0) # the pointer to input path
    la a1, buffer3 # the address of buffer3, also the pointer to the # of rows
    addi a2, a1, 4 # the pointer to the # of cols

    # Load input matrix
    jal read_matrix

    # a0 holds the pointer to input network matrix
    # get a copy of it
    mv s4, a0

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input

    # load the rows and cols
    la t0, buffer1 # get the address of buffer1
    lw t1, 0(t0) # the # of rows of m0
    lw t2, 4(t0) # the # of cols of m0
    la t0, buffer3 # get the address of buffer3
    lw t3, 0(t0) # the # of rows of input
    lw t4, 4(t0) # the # of cols of input

    # malloc for the result matrix
    mul a0, t1, t4 # the # of elements
    mv s5, a0 # get a copy of the # of elements
    slli a0, a0, 2 # the # of bytes
    jal malloc
    mv a6, a0 # the pointer to the result matrix

    # load the rest args
    mv a0, s2 # the pointer to m0
    mv a1, t1 # the # of rows of m0
    mv a2, t2 # the # of cols of m0
    mv a3, s4 # the pointer to input
    mv a4, t3 # the # of rows of input
    mv a5, t4 # the # of cols of input

    # run matmul
    jal matmul

    # now a6 holds the pointer to the m0*input
    # get a copy of it
    mv s6, a6

    # =====================================
    # 2. NONLINEAR LAYER: ReLU(m0 * input)

    # load args for relu
    mv a0, s6 # the pointer to the matrix
    mv a1, s5 # the # of elements of the matrix

    # s5 is now free

    # run relu
    jal relu

    # the pointer to relu(m0*input) is still in s6

    # =====================================
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # load the rows and cols
    la t0, buffer2 # get the address of buffer2
    lw s7, 0(t0) # the # of rows of m1, use s register because we still need it afterwards
    lw t1, 4(t0) # the # of cols of m1
    la t0, buffer1 # get the address of buffer1
    lw t2, 0(t0) # the # of rows of m0, also of m0*input
    la t0, buffer3 # get the address of buffer3
    lw s8, 4(t0) # the # of cols of input, also of m0*input

    # malloc for the result matrix
    mul a0, s7, s8 # the # of elements
    mv s5, a0 # get a copy of the # of elements
    slli a0, a0, 2 # the # of bytes
    jal malloc
    mv a6, a0 # the pointer to the result matrix

    # load the rest args
    mv a0, s3 # the pointer to m1
    mv a1, s7 # the # of rows of m1
    mv a2, t1 # the # of cols of m1
    mv a3, s6 # the pointer to m0*input
    mv a4, t2 # the # of rows of m0*input
    mv a5, s8 # the # of cols of m0*input

    # run matmal
    jal matmul

    # now a6 holds the pointer to the scores matrix

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    # load args for write_matrix
    lw a0, 16(s0) # the pointer to output path
    mv a1, a6 # the pointer to the scores matrix
    mv a2, s7 # the number of rows
    mv a3, s8 # the number of cols

    # run write_matrix
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    # load args
    mv a0, a6 # the pointer to the scores matrix
    mv a1, s5 # the number of elements

    # run argmax
    jal argmax

    # now a0 holds the label, get a copy of it
    # it's coming to an end, so many s registers are already free
    mv s2, a0 

    # Print classification
    bnez s1, skip_print # if print_classification!=0, do not print
    mv a1, s2 # a1 should be the int to print
    jal print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char

    # =====================================

skip_print:

    # free space malloced
    mv a0, s6 # s6 holds the pointer to m0*input
    jal free 
    mv a0, a6 # a6 holds the pointer to scores
    jal free

    # load the return value
    mv a0, s2

    # epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40

    # return
    ret

wrong_argc:
    li a1, 49
    jal exit2