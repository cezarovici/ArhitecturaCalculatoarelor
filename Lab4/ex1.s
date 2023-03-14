.data

    sir : .asciiz "cezarovici" 

.text

main:   
    la a0,sir

    jal ra, reverse

    li a0,17
    li a1,1


reverse:
    addi sp, sp, -8
    
    sw ra, 0(sp)			
	sw s0, 4(sp)			
	lb a1,0(a0)

    beq a1,zero, print_char

    lb s0,0(a0)
    addi a0,a0,1
    
  
    jal reverse
    
    add a1,s0,zero 

print_char:
    li a0,11 # afisare caracter
    ecall 

    lw ra,0(sp)
    lw s0,4(sp)

    addi sp,sp,8
    jalr zero ra 0 # revenire din functia de afisare