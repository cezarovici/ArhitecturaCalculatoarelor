.data

.text

main:
	
	addi a0, zero, 123	# pune valoare parametru in $a0
	jal ra, afis				# apel procedura

	li a0, 17				# apel serviciu sistem de operare
	li a1, 1
	
	ecall					# pentru terminare program

afis:
	addi sp, sp, -12		# alocare spatiu pe stiva pentru salvare valori registre folosite de procedura		
	sw ra, 0(sp)			# salvare valoare registru pe stiva
	sw s0, 4(sp)			# salvare valoare registru pe stiva
	sw s1, 8(sp)			# salvare valoare registru pe stiva
	
	slti t0, a0, 10 # 1 IN  T0 daca a0 e cifra 0 daca nu
	bne t0, zero, print_char # daca a0 e cifra o printeaza
	
	addi t0, zero, 10  # adauga 10 la t0 sa impartim mai mult

	div s1, a0, t0 # pune in s1  a0 / t0
	rem s0, a0, t0 # pune in s0  a0 % t0
	
	add a0, s1, zero # punem catul in a0 sa l bagam din nou in fct de afisare
	jal afis # in functie va intra 
	
	# pune in a0 restul
	add a0, s0, zero
	
print_char:

	# in $a0 este deja cifra care trebuie afisata
	
	addi a1, a0, 48		# conversie la caracter 

	li a0, 11				# apel serviciu sistem de operare pentru afisare caracter 
	ecall
	
	lw ra, 0(sp)			# restaurare valoare registru din stiva
	lw s0, 4(sp)			# restaurare valoare registru din stiva
	lw s1, 8(sp)			# restaurare valoare registru din stiva
	addi sp, sp, 12			# refacere stiva
	jalr zero ra 0 			# revenire din procedura

