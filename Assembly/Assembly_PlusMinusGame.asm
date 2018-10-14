## PLUS MINUS WIN ##

# program takes two first argument name of file and
# second is plus minus pattern
# if above requirement not fulfilled it run for defualt pattern
.globl main
.data
	pattern: .asciiz "--+--+--"
    	minus: .byte '-'
    	plus: .byte '+'
    	win: .asciiz "\nResult: Winnable\n"
    	lose: .asciiz "\nResult: Not Winnable\n"
    	input: .asciiz "\nProvided pattern: "

.text
main:
	# if (argc == 2) {
	#    string = argv[1];
	#  } else {
	#    string = strdup(default_str);
	#  }
	
	# deciding on basis of user argument
    	beq $a0, 2, loadarg     
    	bne $a0, 2, default
print:	
	# printf("String: %s\n", string);
	j printpattern
code:

    	# storing on stack   
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	# setting argument for isWinnable
    	move $a0, $s0  
    	jal isWinnable
    	
    	# loading back from stack
    	lw $ra, 0($sp)  
    	addi $sp,$sp, 4
    	
    	# isWinnable output
    	move $t0, $v0
    	
    	# if (isWinnable(string)) {
	# printf ("Result: Winnable\n");
	#   } else {
	# printf ("Result: Not Winnable\n");
	# }
    	beq $t0, 1, success
    	beq $t0, 0, failure   
    	
exit:
	# system call 10 is exit()
	li $v0, 10
    	li $a0, 0      	
    	# return 0;
    	syscall

# setting default pattern
default:
    	la $s0, pattern
    	j print

# setting pattern as 2nd argument of provided input    
loadarg:
    	lw $s0, 4($a1)
    	j print

# printing pattern for which solution need to be found
printpattern:
	la $a0, input
	li $v0, 4
	syscall
    	move $a0, $s0
    	li $v0, 4
    	syscall
    	j code

# calculate length of the string
strlength:
    	move $t8, $a0  # Given address in $t0, load its value into $a0
    	li $t9, 0	
sloop:    
	lb $t6, 0($t8)
    	beq $t6, $zero, ends
    	addi $t8, $t8, 1
    	addi $t9, $t9, 1
    	j sloop
ends:   
	 move $t1, $t9
   	 j check

# if game is not winnable
failure:
    	la $a0, lose
    	li $v0, 4
    	syscall
    	j exit

# if game is winnable    
success:
    	la $a0,win
    	li $v0, 4
    	syscall
	j exit
	
# recursively look for the combination to win if possible and return accordingly
# expects one argument($a0) containing pattern
# for each recursion storing three values in stack
# ra, t0(string pointer), t1(loop status)
# ouput stored in $v0
isWinnable:
	# loading pattern  
    	move $t0, $a0
    	# calculating length of pattern
	# int len = strlen(str);
    	j strlength
check:    	
    	# loading minus sign
    	la $t2, minus
    	lb $t2, ($t2)
    	# loading plus sign
    	la $t3, plus
    	lb $t3, ($t3)
    	
    	# setting output as one
	# int result = 1;
    	li $v0, 1
    	
    	# looping for string len -1
	# for (int i = 0; i < len - 1; i++) {
loop:     
	# if (str[i] == '-' && str[i+1] == '-') {
    	lb $t4, 0($t0)
    	lb $t5, 1($t0)
    	bne $t4,$t2, end
    	bne $t5,$t2, end
	
	# flipping both character to +
	# str[i] = str[i+1] = '+';
    	sb $t3, 0($t0)
    	sb $t3, 1($t0)
  
  	# storing in stack before calling
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	addi $sp, $sp, -4
   	sw $t0, 0($sp)
    	addi $sp, $sp, -4
    	sw $t1, 0($sp)
    	
	# result = !isWinnable(str);
    	jal isWinnable
    	
    	# flipping received output
    	beq $v0, 1, zero
    	beq $v0, 0, one
    	
cont:    
	# loading values from stack
	lw $t1, 0($sp)
    	addi $sp,$sp, 4
    	lw $t0, 0($sp)
    	addi $sp,$sp, 4
    	lw $ra, 0($sp)
    	addi $sp,$sp, 4
    	
  	# changing back to '-'
	# str[i] = str[i+1] = '-';
    	sb $t2, 0($t0)
    	sb $t2, 1($t0)
    	
    	# if output 1 it means its winnable return
	# if (result) {
	#  return 1;
    	beq $v0, 1, break
end:    
	# decrementing value of loop
    	addi $t1, $t1, -1
    	# incrementing string pointer
    	add $t0, $t0, 1
    	# continue looping if not reached 1
    	bge $t1, 2, loop
    	
    	# return result already stored in v0
	# return result;        
    	jr $ra

# if winnable for this recursion return
break:    
    	jr $ra   	 

# flip output to 1 		 
one:
    	li $v0, 1
    	j cont

# flip output to 0
zero:
    	li $v0, 0
    	j cont