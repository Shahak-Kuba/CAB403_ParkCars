	.file	"manager.c"
	.text
.Ltext0:
	.comm	CP,24,16
	.comm	h,16,16
	.globl	level_car_counter
	.bss
	.align 16
	.type	level_car_counter, @object
	.size	level_car_counter, 20
level_car_counter:
	.zero	20
	.comm	level_car_counter_mutex,40,32
	.globl	sim
	.data
	.type	sim, @object
	.size	sim, 1
sim:
	.byte	1
	.section	.rodata
.LC0:
	.string	"unable to open shared memory"
.LC1:
	.string	"mmap"
.LC2:
	.string	"shared memory opened!"
	.text
	.globl	shared_mem_init_open
	.type	shared_mem_init_open, @function
shared_mem_init_open:
.LFB6:
	.file 1 "manager.c"
	.loc 1 44 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	.loc 1 46 20
	movq	-16(%rbp), %rax
	movl	$0, %edx
	movl	$2, %esi
	movq	%rax, %rdi
	call	shm_open@PLT
	movl	%eax, %edx
	.loc 1 46 18
	movq	-8(%rbp), %rax
	movl	%edx, 8(%rax)
	.loc 1 46 13
	movq	-8(%rbp), %rax
	movl	8(%rax), %eax
	.loc 1 46 8
	testl	%eax, %eax
	jns	.L2
	.loc 1 48 13
	leaq	.LC0(%rip), %rdi
	call	perror@PLT
	.loc 1 49 19
	movl	$1, %eax
	jmp	.L3
.L2:
	.loc 1 52 24
	movq	-8(%rbp), %rax
	movl	8(%rax), %eax
	movl	$0, %r9d
	movl	%eax, %r8d
	movl	$1, %ecx
	movl	$2, %edx
	movl	$2120, %esi
	movl	$0, %edi
	call	mmap@PLT
	movq	%rax, %rdx
	.loc 1 52 22
	movq	-8(%rbp), %rax
	movq	%rdx, 16(%rax)
	.loc 1 52 12
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	.loc 1 52 7
	cmpq	$-1, %rax
	jne	.L4
	.loc 1 54 9
	leaq	.LC1(%rip), %rdi
	call	perror@PLT
	.loc 1 55 15
	movl	$1, %eax
	jmp	.L3
.L4:
	.loc 1 57 5
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	.loc 1 58 11
	movl	$0, %eax
.L3:
	.loc 1 59 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	shared_mem_init_open, .-shared_mem_init_open
	.globl	htab_init
	.type	htab_init, @function
htab_init:
.LFB7:
	.loc 1 65 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	.loc 1 66 13
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 8(%rax)
	.loc 1 67 27
	movq	-16(%rbp), %rax
	movl	$8, %esi
	movq	%rax, %rdi
	call	calloc@PLT
	movq	%rax, %rdx
	.loc 1 67 16
	movq	-8(%rbp), %rax
	movq	%rdx, (%rax)
	.loc 1 68 13
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 68 23
	testq	%rax, %rax
	setne	%al
	.loc 1 69 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	htab_init, .-htab_init
	.globl	djb_hash
	.type	djb_hash, @function
djb_hash:
.LFB8:
	.loc 1 74 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	.loc 1 75 12
	movq	$5381, -8(%rbp)
	.loc 1 76 9
	movl	$0, -12(%rbp)
	.loc 1 77 11
	jmp	.L8
.L9:
	.loc 1 80 23
	movq	-8(%rbp), %rax
	salq	$5, %rax
	movq	%rax, %rdx
	.loc 1 80 29
	movq	-8(%rbp), %rax
	addq	%rax, %rdx
	.loc 1 80 37
	movl	-12(%rbp), %eax
	cltq
	.loc 1 80 14
	addq	%rdx, %rax
	movq	%rax, -8(%rbp)
.L8:
	.loc 1 77 19
	movq	-24(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -24(%rbp)
	.loc 1 77 17
	movzbl	(%rax), %eax
	.loc 1 77 15
	movsbl	%al, %eax
	movl	%eax, -12(%rbp)
	.loc 1 77 11
	cmpl	$0, -12(%rbp)
	jne	.L9
	.loc 1 82 12
	movq	-8(%rbp), %rax
	.loc 1 83 1
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	djb_hash, .-djb_hash
	.globl	htab_index
	.type	htab_index, @function
htab_index:
.LFB9:
	.loc 1 87 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	.loc 1 88 12
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	djb_hash
	movq	%rax, %rdx
	.loc 1 88 29
	movq	-8(%rbp), %rax
	movq	8(%rax), %rcx
	.loc 1 88 26
	movq	%rdx, %rax
	movl	$0, %edx
	divq	%rcx
	movq	%rdx, %rax
	.loc 1 89 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	htab_index, .-htab_index
	.globl	htab_add
	.type	htab_add, @function
htab_add:
.LFB10:
	.loc 1 93 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	.loc 1 95 29
	movl	$16, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	.loc 1 97 7
	cmpq	$0, -8(%rbp)
	jne	.L14
	.loc 1 99 16
	movl	$0, %eax
	jmp	.L15
.L14:
	.loc 1 102 19
	movq	-8(%rbp), %rax
	.loc 1 102 5
	movq	-32(%rbp), %rcx
	movl	$6, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	.loc 1 103 30
	movq	-8(%rbp), %rax
	movb	$0, 6(%rax)
	.loc 1 105 41
	movq	-8(%rbp), %rdx
	.loc 1 105 21
	movq	-24(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	htab_index
	movq	%rax, -16(%rbp)
	.loc 1 106 22
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 106 31
	movq	-16(%rbp), %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rdx
	.loc 1 106 19
	movq	-8(%rbp), %rax
	movq	%rdx, 8(%rax)
	.loc 1 107 6
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 107 15
	movq	-16(%rbp), %rdx
	salq	$3, %rdx
	addq	%rax, %rdx
	.loc 1 107 24
	movq	-8(%rbp), %rax
	movq	%rax, (%rdx)
	.loc 1 108 12
	movl	$1, %eax
.L15:
	.loc 1 110 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	htab_add, .-htab_add
	.globl	htab_bucket
	.type	htab_bucket, @function
htab_bucket:
.LFB11:
	.loc 1 114 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$16, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -16(%rbp)
	movq	%rsi, -24(%rbp)
	.loc 1 115 13
	movq	-16(%rbp), %rax
	movq	(%rax), %rbx
	.loc 1 115 23
	movq	-24(%rbp), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	htab_index
	.loc 1 115 22
	salq	$3, %rax
	addq	%rbx, %rax
	movq	(%rax), %rax
	.loc 1 116 1
	addq	$16, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	htab_bucket, .-htab_bucket
	.globl	htab_find
	.type	htab_find, @function
htab_find:
.LFB12:
	.loc 1 120 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	.loc 1 122 5
	movq	-32(%rbp), %rcx
	leaq	-15(%rbp), %rax
	movl	$6, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	.loc 1 123 13
	movb	$0, -9(%rbp)
.LBB2:
	.loc 1 124 20
	movq	-32(%rbp), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	htab_bucket
	movq	%rax, -8(%rbp)
	.loc 1 124 5
	jmp	.L19
.L22:
	.loc 1 126 21
	movq	-8(%rbp), %rax
	.loc 1 126 13
	movq	-32(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	strcmp@PLT
	.loc 1 126 12
	testl	%eax, %eax
	jne	.L20
	.loc 1 128 20
	movq	-8(%rbp), %rax
	jmp	.L23
.L20:
	.loc 1 124 54 discriminator 2
	movq	-8(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -8(%rbp)
.L19:
	.loc 1 124 5 discriminator 1
	cmpq	$0, -8(%rbp)
	jne	.L22
.LBE2:
	.loc 1 131 12
	movl	$0, %eax
.L23:
	.loc 1 132 1 discriminator 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	htab_find, .-htab_find
	.globl	htab_destroy
	.type	htab_destroy, @function
htab_destroy:
.LFB13:
	.loc 1 135 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
.LBB3:
	.loc 1 137 17
	movq	$0, -8(%rbp)
	.loc 1 137 5
	jmp	.L25
.L28:
.LBB4:
	.loc 1 139 25
	movq	-40(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 139 34
	movq	-8(%rbp), %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	.loc 1 139 15
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	.loc 1 140 15
	jmp	.L26
.L27:
.LBB5:
	.loc 1 142 19
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	.loc 1 143 13
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	.loc 1 144 20
	movq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
.L26:
.LBE5:
	.loc 1 140 15
	cmpq	$0, -16(%rbp)
	jne	.L27
.LBE4:
	.loc 1 137 37 discriminator 2
	addq	$1, -8(%rbp)
.L25:
	.loc 1 137 29 discriminator 1
	movq	-40(%rbp), %rax
	movq	8(%rax), %rax
	.loc 1 137 5 discriminator 1
	cmpq	%rax, -8(%rbp)
	jb	.L28
.LBE3:
	.loc 1 149 11
	movq	-40(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 149 5
	movq	%rax, %rdi
	call	free@PLT
	.loc 1 150 16
	movq	-40(%rbp), %rax
	movq	$0, (%rax)
	.loc 1 151 13
	movq	-40(%rbp), %rax
	movq	$0, 8(%rax)
	.loc 1 152 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	htab_destroy, .-htab_destroy
	.section	.rodata
.LC3:
	.string	"r"
.LC4:
	.string	"plates.txt"
	.align 8
.LC5:
	.string	"Error reading %s please make sure file exists"
	.align 8
.LC6:
	.string	"error adding number plate to hash table"
.LC7:
	.string	"%s"
	.align 8
.LC8:
	.string	"successfuly allocated number plates to hash table"
	.text
	.globl	LPR_to_htab
	.type	LPR_to_htab, @function
LPR_to_htab:
.LFB14:
	.loc 1 156 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 160 18
	leaq	.LC3(%rip), %rsi
	leaq	.LC4(%rip), %rdi
	call	fopen@PLT
	movq	%rax, -8(%rbp)
	.loc 1 162 8
	cmpq	$0, -8(%rbp)
	jne	.L31
	.loc 1 164 9
	leaq	.LC4(%rip), %rsi
	leaq	.LC5(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 167 10
	jmp	.L31
.L32:
	.loc 1 170 14
	leaq	-15(%rbp), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	htab_add
	.loc 1 170 35
	xorl	$1, %eax
	.loc 1 170 12
	testb	%al, %al
	je	.L31
	.loc 1 172 13
	leaq	.LC6(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L31:
	.loc 1 167 12
	leaq	-15(%rbp), %rdx
	movq	-8(%rbp), %rax
	leaq	.LC7(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	__isoc99_fscanf@PLT
	.loc 1 167 10
	cmpl	$-1, %eax
	jne	.L32
	.loc 1 175 5
	leaq	.LC8(%rip), %rdi
	call	puts@PLT
	.loc 1 176 12
	movl	$0, %eax
	.loc 1 177 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	LPR_to_htab, .-LPR_to_htab
	.section	.rodata
.LC9:
	.string	"key=%s"
	.text
	.globl	item_print
	.type	item_print, @function
item_print:
.LFB15:
	.loc 1 180 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 181 23
	movq	-8(%rbp), %rax
	.loc 1 181 5
	movq	%rax, %rsi
	leaq	.LC9(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 182 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	item_print, .-item_print
	.section	.rodata
.LC10:
	.string	"hash table with %ld buckets\n"
.LC11:
	.string	"bucket %ld: "
.LC12:
	.string	"empty"
.LC13:
	.string	" -> "
	.text
	.globl	htab_print
	.type	htab_print, @function
htab_print:
.LFB16:
	.loc 1 185 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 186 5
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, %rsi
	leaq	.LC10(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.LBB6:
	.loc 1 187 17
	movq	$0, -8(%rbp)
	.loc 1 187 5
	jmp	.L36
.L42:
	.loc 1 189 9
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC11(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 190 14
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 190 23
	movq	-8(%rbp), %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	.loc 1 190 12
	testq	%rax, %rax
	jne	.L37
	.loc 1 192 13
	leaq	.LC12(%rip), %rdi
	call	puts@PLT
	jmp	.L38
.L37:
.LBB7:
	.loc 1 196 29
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	.loc 1 196 38
	movq	-8(%rbp), %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	.loc 1 196 24
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	.loc 1 196 13
	jmp	.L39
.L41:
	.loc 1 198 17
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	item_print
	.loc 1 199 22
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	.loc 1 199 20
	testq	%rax, %rax
	je	.L40
	.loc 1 201 21
	leaq	.LC13(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L40:
	.loc 1 196 56 discriminator 2
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -16(%rbp)
.L39:
	.loc 1 196 13 discriminator 1
	cmpq	$0, -16(%rbp)
	jne	.L41
.LBE7:
	.loc 1 204 13
	movl	$10, %edi
	call	putchar@PLT
.L38:
	.loc 1 187 37 discriminator 2
	addq	$1, -8(%rbp)
.L36:
	.loc 1 187 29 discriminator 1
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	.loc 1 187 5 discriminator 1
	cmpq	%rax, -8(%rbp)
	jb	.L42
.LBE6:
	.loc 1 207 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	htab_print, .-htab_print
	.section	.rodata
.LC14:
	.string	"waiting for signal...."
.LC15:
	.string	"Carpark is full idiot!"
	.align 8
.LC16:
	.string	"%s inserted into carpark at level %d\n"
	.text
	.globl	enterFunc
	.type	enterFunc, @function
enterFunc:
.LFB17:
	.loc 1 214 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -56(%rbp)
	.loc 1 216 9
	movq	-56(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -12(%rbp)
	.loc 1 217 28
	movq	16+CP(%rip), %rcx
	.loc 1 217 14
	movl	-12(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	addq	%rdx, %rax
	salq	$5, %rax
	addq	%rcx, %rax
	movq	%rax, -24(%rbp)
	.loc 1 219 5
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
.L53:
	.loc 1 223 9
	leaq	.LC14(%rip), %rdi
	call	puts@PLT
	.loc 1 225 33
	movq	-24(%rbp), %rax
	movzbl	88(%rax), %eax
	.loc 1 225 11
	testb	%al, %al
	je	.L44
.LBB8:
	.loc 1 228 38
	movq	-24(%rbp), %rax
	leaq	88(%rax), %rcx
	.loc 1 228 13
	leaq	-39(%rbp), %rax
	movl	$6, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	.loc 1 229 25
	movb	$0, -33(%rbp)
	.loc 1 231 16
	leaq	-39(%rbp), %rax
	movq	%rax, %rsi
	leaq	h(%rip), %rdi
	call	htab_find
	.loc 1 231 15
	testq	%rax, %rax
	je	.L44
.LBB9:
	.loc 1 233 17
	leaq	level_car_counter_mutex(%rip), %rdi
	call	pthread_mutex_lock@PLT
	.loc 1 234 21
	movl	$-1, -4(%rbp)
.LBB10:
	.loc 1 235 26
	movl	$0, -8(%rbp)
	.loc 1 235 17
	jmp	.L46
.L49:
	.loc 1 237 41
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	level_car_counter(%rip), %rax
	movl	(%rdx,%rax), %eax
	.loc 1 237 23
	cmpl	$19, %eax
	jg	.L47
	.loc 1 239 35
	movl	-8(%rbp), %eax
	movl	%eax, -4(%rbp)
	.loc 1 240 42
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	level_car_counter(%rip), %rax
	movl	(%rdx,%rax), %eax
	.loc 1 240 45
	leal	1(%rax), %ecx
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	level_car_counter(%rip), %rax
	movl	%ecx, (%rdx,%rax)
	.loc 1 241 25
	jmp	.L48
.L47:
	.loc 1 235 50 discriminator 2
	addl	$1, -8(%rbp)
.L46:
	.loc 1 235 17 discriminator 1
	cmpl	$4, -8(%rbp)
	jle	.L49
.L48:
.LBE10:
	.loc 1 245 19
	cmpl	$-1, -4(%rbp)
	jne	.L50
	.loc 1 247 21
	leaq	.LC15(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 248 21
	nop
.LBE9:
.LBE8:
	.loc 1 293 5
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	.loc 1 294 12
	movl	$0, %eax
	jmp	.L54
.L50:
.LBB12:
.LBB11:
	.loc 1 253 17
	leaq	level_car_counter_mutex(%rip), %rdi
	call	pthread_mutex_unlock@PLT
	.loc 1 254 17
	movl	-4(%rbp), %edx
	leaq	-39(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC16(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 257 17
	movq	-24(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	.loc 1 258 39
	movq	-24(%rbp), %rax
	movb	$82, 184(%rax)
	.loc 1 259 17
	movq	-24(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	.loc 1 261 17
	movq	-24(%rbp), %rax
	addq	$136, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
	.loc 1 263 17
	movq	-24(%rbp), %rax
	leaq	96(%rax), %rdx
	movq	-24(%rbp), %rax
	addq	$136, %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_cond_wait@PLT
	.loc 1 268 37
	movq	16+CP(%rip), %rcx
	.loc 1 268 26
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	$2400, %rax
	addq	%rcx, %rax
	movq	%rax, -32(%rbp)
	.loc 1 269 17
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	.loc 1 270 29
	movq	-32(%rbp), %rax
	leaq	88(%rax), %rcx
	.loc 1 270 17
	leaq	-39(%rbp), %rax
	movl	$6, %edx
	movq	%rax, %rsi
	movq	%rcx, %rdi
	call	memcpy@PLT
	.loc 1 271 17
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	.loc 1 273 17
	movq	-32(%rbp), %rax
	addq	$40, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
	.loc 1 276 17
	movq	-24(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	.loc 1 277 39
	movq	-24(%rbp), %rax
	movb	$76, 184(%rax)
	.loc 1 278 17
	movq	-24(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	.loc 1 280 17
	movq	-24(%rbp), %rax
	addq	$136, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
	.loc 1 282 17
	movq	-24(%rbp), %rax
	leaq	96(%rax), %rdx
	movq	-24(%rbp), %rax
	addq	$136, %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_cond_wait@PLT
.L44:
.LBE11:
.LBE12:
	.loc 1 289 34
	movq	-24(%rbp), %rax
	movb	$0, 88(%rax)
	.loc 1 290 9
	movq	-24(%rbp), %rax
	movq	-24(%rbp), %rdx
	addq	$40, %rdx
	movq	%rax, %rsi
	movq	%rdx, %rdi
	call	pthread_cond_wait@PLT
	.loc 1 223 9
	jmp	.L53
.L54:
	.loc 1 296 1 discriminator 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	enterFunc, .-enterFunc
	.globl	levelFunc
	.type	levelFunc, @function
levelFunc:
.LFB18:
	.loc 1 303 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	.loc 1 305 8
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -4(%rbp)
	.loc 1 306 24
	movq	16+CP(%rip), %rcx
	.loc 1 306 13
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	$2400, %rax
	addq	%rcx, %rax
	movq	%rax, -16(%rbp)
.L56:
	.loc 1 308 9 discriminator 1
	jmp	.L56
	.cfi_endproc
.LFE18:
	.size	levelFunc, .-levelFunc
	.section	.rodata
.LC17:
	.string	"PARKING"
	.align 8
.LC18:
	.string	"failed to initialise hash table"
	.text
	.globl	main
	.type	main, @function
main:
.LFB19:
	.loc 1 318 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 321 9
	leaq	.LC17(%rip), %rax
	movq	%rax, -8(%rbp)
	.loc 1 322 5
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	leaq	CP(%rip), %rdi
	call	shared_mem_init_open
	.loc 1 325 12
	movq	$10, -16(%rbp)
	.loc 1 326 10
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	leaq	h(%rip), %rdi
	call	htab_init
	.loc 1 326 9
	xorl	$1, %eax
	.loc 1 326 8
	testb	%al, %al
	je	.L58
	.loc 1 328 9
	leaq	.LC18(%rip), %rdi
	call	puts@PLT
	.loc 1 329 16
	movl	$1, %eax
	jmp	.L59
.L58:
	.loc 1 333 5
	leaq	h(%rip), %rdi
	call	LPR_to_htab
	.loc 1 334 5
	leaq	h(%rip), %rdi
	call	htab_print
	.loc 1 359 12
	movl	$0, %eax
.L59:
	.loc 1 360 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/lib/gcc/x86_64-linux-gnu/8/include/stddef.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 4 "/usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/types/FILE.h"
	.file 6 "/usr/include/stdio.h"
	.file 7 "/usr/include/x86_64-linux-gnu/bits/sys_errlist.h"
	.file 8 "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h"
	.file 9 "/usr/include/x86_64-linux-gnu/bits/thread-shared-types.h"
	.file 10 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.file 11 "/usr/include/time.h"
	.file 12 "/usr/include/unistd.h"
	.file 13 "/usr/include/x86_64-linux-gnu/bits/getopt_core.h"
	.file 14 "datas.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0xddb
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF154
	.byte	0xc
	.long	.LASF155
	.long	.LASF156
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.long	.LASF5
	.byte	0x2
	.byte	0xd8
	.byte	0x17
	.long	0x39
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.long	.LASF1
	.uleb128 0x4
	.byte	0x8
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.long	.LASF2
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.long	.LASF3
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x2
	.long	.LASF6
	.byte	0x3
	.byte	0x26
	.byte	0x1a
	.long	0x6a
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.long	.LASF7
	.uleb128 0x5
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF8
	.uleb128 0x2
	.long	.LASF9
	.byte	0x3
	.byte	0x96
	.byte	0x19
	.long	0x78
	.uleb128 0x2
	.long	.LASF10
	.byte	0x3
	.byte	0x97
	.byte	0x1b
	.long	0x78
	.uleb128 0x6
	.byte	0x8
	.long	0x9d
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF11
	.uleb128 0x7
	.long	0x9d
	.uleb128 0x8
	.long	.LASF52
	.byte	0xd8
	.byte	0x4
	.byte	0x31
	.byte	0x8
	.long	0x230
	.uleb128 0x9
	.long	.LASF12
	.byte	0x4
	.byte	0x33
	.byte	0x7
	.long	0x71
	.byte	0
	.uleb128 0x9
	.long	.LASF13
	.byte	0x4
	.byte	0x36
	.byte	0x9
	.long	0x97
	.byte	0x8
	.uleb128 0x9
	.long	.LASF14
	.byte	0x4
	.byte	0x37
	.byte	0x9
	.long	0x97
	.byte	0x10
	.uleb128 0x9
	.long	.LASF15
	.byte	0x4
	.byte	0x38
	.byte	0x9
	.long	0x97
	.byte	0x18
	.uleb128 0x9
	.long	.LASF16
	.byte	0x4
	.byte	0x39
	.byte	0x9
	.long	0x97
	.byte	0x20
	.uleb128 0x9
	.long	.LASF17
	.byte	0x4
	.byte	0x3a
	.byte	0x9
	.long	0x97
	.byte	0x28
	.uleb128 0x9
	.long	.LASF18
	.byte	0x4
	.byte	0x3b
	.byte	0x9
	.long	0x97
	.byte	0x30
	.uleb128 0x9
	.long	.LASF19
	.byte	0x4
	.byte	0x3c
	.byte	0x9
	.long	0x97
	.byte	0x38
	.uleb128 0x9
	.long	.LASF20
	.byte	0x4
	.byte	0x3d
	.byte	0x9
	.long	0x97
	.byte	0x40
	.uleb128 0x9
	.long	.LASF21
	.byte	0x4
	.byte	0x40
	.byte	0x9
	.long	0x97
	.byte	0x48
	.uleb128 0x9
	.long	.LASF22
	.byte	0x4
	.byte	0x41
	.byte	0x9
	.long	0x97
	.byte	0x50
	.uleb128 0x9
	.long	.LASF23
	.byte	0x4
	.byte	0x42
	.byte	0x9
	.long	0x97
	.byte	0x58
	.uleb128 0x9
	.long	.LASF24
	.byte	0x4
	.byte	0x44
	.byte	0x16
	.long	0x249
	.byte	0x60
	.uleb128 0x9
	.long	.LASF25
	.byte	0x4
	.byte	0x46
	.byte	0x14
	.long	0x24f
	.byte	0x68
	.uleb128 0x9
	.long	.LASF26
	.byte	0x4
	.byte	0x48
	.byte	0x7
	.long	0x71
	.byte	0x70
	.uleb128 0x9
	.long	.LASF27
	.byte	0x4
	.byte	0x49
	.byte	0x7
	.long	0x71
	.byte	0x74
	.uleb128 0x9
	.long	.LASF28
	.byte	0x4
	.byte	0x4a
	.byte	0xb
	.long	0x7f
	.byte	0x78
	.uleb128 0x9
	.long	.LASF29
	.byte	0x4
	.byte	0x4d
	.byte	0x12
	.long	0x50
	.byte	0x80
	.uleb128 0x9
	.long	.LASF30
	.byte	0x4
	.byte	0x4e
	.byte	0xf
	.long	0x57
	.byte	0x82
	.uleb128 0x9
	.long	.LASF31
	.byte	0x4
	.byte	0x4f
	.byte	0x8
	.long	0x255
	.byte	0x83
	.uleb128 0x9
	.long	.LASF32
	.byte	0x4
	.byte	0x51
	.byte	0xf
	.long	0x265
	.byte	0x88
	.uleb128 0x9
	.long	.LASF33
	.byte	0x4
	.byte	0x59
	.byte	0xd
	.long	0x8b
	.byte	0x90
	.uleb128 0x9
	.long	.LASF34
	.byte	0x4
	.byte	0x5b
	.byte	0x17
	.long	0x270
	.byte	0x98
	.uleb128 0x9
	.long	.LASF35
	.byte	0x4
	.byte	0x5c
	.byte	0x19
	.long	0x27b
	.byte	0xa0
	.uleb128 0x9
	.long	.LASF36
	.byte	0x4
	.byte	0x5d
	.byte	0x14
	.long	0x24f
	.byte	0xa8
	.uleb128 0x9
	.long	.LASF37
	.byte	0x4
	.byte	0x5e
	.byte	0x9
	.long	0x47
	.byte	0xb0
	.uleb128 0x9
	.long	.LASF38
	.byte	0x4
	.byte	0x5f
	.byte	0xa
	.long	0x2d
	.byte	0xb8
	.uleb128 0x9
	.long	.LASF39
	.byte	0x4
	.byte	0x60
	.byte	0x7
	.long	0x71
	.byte	0xc0
	.uleb128 0x9
	.long	.LASF40
	.byte	0x4
	.byte	0x62
	.byte	0x8
	.long	0x281
	.byte	0xc4
	.byte	0
	.uleb128 0x2
	.long	.LASF41
	.byte	0x5
	.byte	0x7
	.byte	0x19
	.long	0xa9
	.uleb128 0xa
	.long	.LASF157
	.byte	0x4
	.byte	0x2b
	.byte	0xe
	.uleb128 0xb
	.long	.LASF42
	.uleb128 0x6
	.byte	0x8
	.long	0x244
	.uleb128 0x6
	.byte	0x8
	.long	0xa9
	.uleb128 0xc
	.long	0x9d
	.long	0x265
	.uleb128 0xd
	.long	0x39
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x23c
	.uleb128 0xb
	.long	.LASF43
	.uleb128 0x6
	.byte	0x8
	.long	0x26b
	.uleb128 0xb
	.long	.LASF44
	.uleb128 0x6
	.byte	0x8
	.long	0x276
	.uleb128 0xc
	.long	0x9d
	.long	0x291
	.uleb128 0xd
	.long	0x39
	.byte	0x13
	.byte	0
	.uleb128 0xe
	.long	.LASF45
	.byte	0x6
	.byte	0x89
	.byte	0xe
	.long	0x29d
	.uleb128 0x6
	.byte	0x8
	.long	0x230
	.uleb128 0xe
	.long	.LASF46
	.byte	0x6
	.byte	0x8a
	.byte	0xe
	.long	0x29d
	.uleb128 0xe
	.long	.LASF47
	.byte	0x6
	.byte	0x8b
	.byte	0xe
	.long	0x29d
	.uleb128 0xe
	.long	.LASF48
	.byte	0x7
	.byte	0x1a
	.byte	0xc
	.long	0x71
	.uleb128 0xc
	.long	0x2dd
	.long	0x2d2
	.uleb128 0xf
	.byte	0
	.uleb128 0x7
	.long	0x2c7
	.uleb128 0x6
	.byte	0x8
	.long	0xa4
	.uleb128 0x7
	.long	0x2d7
	.uleb128 0xe
	.long	.LASF49
	.byte	0x7
	.byte	0x1b
	.byte	0x1a
	.long	0x2d2
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF50
	.uleb128 0x2
	.long	.LASF51
	.byte	0x8
	.byte	0x19
	.byte	0x13
	.long	0x5e
	.uleb128 0x8
	.long	.LASF53
	.byte	0x10
	.byte	0x9
	.byte	0x52
	.byte	0x10
	.long	0x329
	.uleb128 0x9
	.long	.LASF54
	.byte	0x9
	.byte	0x54
	.byte	0x23
	.long	0x329
	.byte	0
	.uleb128 0x9
	.long	.LASF55
	.byte	0x9
	.byte	0x55
	.byte	0x23
	.long	0x329
	.byte	0x8
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x301
	.uleb128 0x2
	.long	.LASF56
	.byte	0x9
	.byte	0x56
	.byte	0x3
	.long	0x301
	.uleb128 0x8
	.long	.LASF57
	.byte	0x28
	.byte	0x9
	.byte	0x76
	.byte	0x8
	.long	0x3b1
	.uleb128 0x9
	.long	.LASF58
	.byte	0x9
	.byte	0x78
	.byte	0x7
	.long	0x71
	.byte	0
	.uleb128 0x9
	.long	.LASF59
	.byte	0x9
	.byte	0x79
	.byte	0x10
	.long	0x40
	.byte	0x4
	.uleb128 0x9
	.long	.LASF60
	.byte	0x9
	.byte	0x7a
	.byte	0x7
	.long	0x71
	.byte	0x8
	.uleb128 0x9
	.long	.LASF61
	.byte	0x9
	.byte	0x7c
	.byte	0x10
	.long	0x40
	.byte	0xc
	.uleb128 0x9
	.long	.LASF62
	.byte	0x9
	.byte	0x94
	.byte	0x7
	.long	0x71
	.byte	0x10
	.uleb128 0x9
	.long	.LASF63
	.byte	0x9
	.byte	0x9a
	.byte	0x3
	.long	0x6a
	.byte	0x14
	.uleb128 0x9
	.long	.LASF64
	.byte	0x9
	.byte	0x9a
	.byte	0x3
	.long	0x6a
	.byte	0x16
	.uleb128 0x9
	.long	.LASF65
	.byte	0x9
	.byte	0x9b
	.byte	0x14
	.long	0x32f
	.byte	0x18
	.byte	0
	.uleb128 0x10
	.byte	0x8
	.byte	0x9
	.byte	0xb0
	.byte	0x5
	.long	0x3d5
	.uleb128 0x9
	.long	.LASF66
	.byte	0x9
	.byte	0xb2
	.byte	0x14
	.long	0x40
	.byte	0
	.uleb128 0x9
	.long	.LASF67
	.byte	0x9
	.byte	0xb3
	.byte	0x14
	.long	0x40
	.byte	0x4
	.byte	0
	.uleb128 0x11
	.byte	0x8
	.byte	0x9
	.byte	0xad
	.byte	0x11
	.long	0x3f7
	.uleb128 0x12
	.long	.LASF68
	.byte	0x9
	.byte	0xaf
	.byte	0x2a
	.long	0x3f7
	.uleb128 0x12
	.long	.LASF69
	.byte	0x9
	.byte	0xb4
	.byte	0x7
	.long	0x3b1
	.byte	0
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF70
	.uleb128 0x10
	.byte	0x8
	.byte	0x9
	.byte	0xb9
	.byte	0x5
	.long	0x422
	.uleb128 0x9
	.long	.LASF66
	.byte	0x9
	.byte	0xbb
	.byte	0x14
	.long	0x40
	.byte	0
	.uleb128 0x9
	.long	.LASF67
	.byte	0x9
	.byte	0xbc
	.byte	0x14
	.long	0x40
	.byte	0x4
	.byte	0
	.uleb128 0x11
	.byte	0x8
	.byte	0x9
	.byte	0xb6
	.byte	0x11
	.long	0x444
	.uleb128 0x12
	.long	.LASF71
	.byte	0x9
	.byte	0xb8
	.byte	0x2a
	.long	0x3f7
	.uleb128 0x12
	.long	.LASF72
	.byte	0x9
	.byte	0xbd
	.byte	0x7
	.long	0x3fe
	.byte	0
	.uleb128 0x8
	.long	.LASF73
	.byte	0x30
	.byte	0x9
	.byte	0xab
	.byte	0x8
	.long	0x49f
	.uleb128 0x13
	.long	0x3d5
	.byte	0
	.uleb128 0x13
	.long	0x422
	.byte	0x8
	.uleb128 0x9
	.long	.LASF74
	.byte	0x9
	.byte	0xbf
	.byte	0x10
	.long	0x49f
	.byte	0x10
	.uleb128 0x9
	.long	.LASF75
	.byte	0x9
	.byte	0xc0
	.byte	0x10
	.long	0x49f
	.byte	0x18
	.uleb128 0x9
	.long	.LASF76
	.byte	0x9
	.byte	0xc1
	.byte	0x10
	.long	0x40
	.byte	0x20
	.uleb128 0x9
	.long	.LASF77
	.byte	0x9
	.byte	0xc2
	.byte	0x10
	.long	0x40
	.byte	0x24
	.uleb128 0x9
	.long	.LASF78
	.byte	0x9
	.byte	0xc3
	.byte	0x10
	.long	0x49f
	.byte	0x28
	.byte	0
	.uleb128 0xc
	.long	0x40
	.long	0x4af
	.uleb128 0xd
	.long	0x39
	.byte	0x1
	.byte	0
	.uleb128 0x11
	.byte	0x28
	.byte	0xa
	.byte	0x43
	.byte	0x9
	.long	0x4dd
	.uleb128 0x12
	.long	.LASF79
	.byte	0xa
	.byte	0x45
	.byte	0x1c
	.long	0x33b
	.uleb128 0x12
	.long	.LASF80
	.byte	0xa
	.byte	0x46
	.byte	0x8
	.long	0x4dd
	.uleb128 0x12
	.long	.LASF81
	.byte	0xa
	.byte	0x47
	.byte	0xc
	.long	0x78
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x4ed
	.uleb128 0xd
	.long	0x39
	.byte	0x27
	.byte	0
	.uleb128 0x2
	.long	.LASF82
	.byte	0xa
	.byte	0x48
	.byte	0x3
	.long	0x4af
	.uleb128 0x11
	.byte	0x30
	.byte	0xa
	.byte	0x4b
	.byte	0x9
	.long	0x527
	.uleb128 0x12
	.long	.LASF79
	.byte	0xa
	.byte	0x4d
	.byte	0x1b
	.long	0x444
	.uleb128 0x12
	.long	.LASF80
	.byte	0xa
	.byte	0x4e
	.byte	0x8
	.long	0x527
	.uleb128 0x12
	.long	.LASF81
	.byte	0xa
	.byte	0x4f
	.byte	0x1f
	.long	0x2ee
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x537
	.uleb128 0xd
	.long	0x39
	.byte	0x2f
	.byte	0
	.uleb128 0x2
	.long	.LASF83
	.byte	0xa
	.byte	0x50
	.byte	0x3
	.long	0x4f9
	.uleb128 0xc
	.long	0x97
	.long	0x553
	.uleb128 0xd
	.long	0x39
	.byte	0x1
	.byte	0
	.uleb128 0xe
	.long	.LASF84
	.byte	0xb
	.byte	0x9f
	.byte	0xe
	.long	0x543
	.uleb128 0xe
	.long	.LASF85
	.byte	0xb
	.byte	0xa0
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF86
	.byte	0xb
	.byte	0xa1
	.byte	0x11
	.long	0x78
	.uleb128 0xe
	.long	.LASF87
	.byte	0xb
	.byte	0xa6
	.byte	0xe
	.long	0x543
	.uleb128 0xe
	.long	.LASF88
	.byte	0xb
	.byte	0xae
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF89
	.byte	0xb
	.byte	0xaf
	.byte	0x11
	.long	0x78
	.uleb128 0x14
	.long	.LASF90
	.byte	0xc
	.value	0x21f
	.byte	0xf
	.long	0x5a8
	.uleb128 0x6
	.byte	0x8
	.long	0x97
	.uleb128 0xe
	.long	.LASF91
	.byte	0xd
	.byte	0x24
	.byte	0xe
	.long	0x97
	.uleb128 0xe
	.long	.LASF92
	.byte	0xd
	.byte	0x32
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF93
	.byte	0xd
	.byte	0x37
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF94
	.byte	0xd
	.byte	0x3b
	.byte	0xc
	.long	0x71
	.uleb128 0x15
	.long	.LASF95
	.value	0x120
	.byte	0xe
	.byte	0x15
	.byte	0x10
	.long	0x663
	.uleb128 0x9
	.long	.LASF96
	.byte	0xe
	.byte	0x17
	.byte	0x15
	.long	0x4ed
	.byte	0
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x18
	.byte	0x14
	.long	0x537
	.byte	0x28
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x19
	.byte	0xa
	.long	0x663
	.byte	0x58
	.uleb128 0x9
	.long	.LASF99
	.byte	0xe
	.byte	0x1a
	.byte	0x15
	.long	0x4ed
	.byte	0x60
	.uleb128 0x9
	.long	.LASF100
	.byte	0xe
	.byte	0x1b
	.byte	0x14
	.long	0x537
	.byte	0x88
	.uleb128 0x9
	.long	.LASF101
	.byte	0xe
	.byte	0x1c
	.byte	0xa
	.long	0x9d
	.byte	0xb8
	.uleb128 0x9
	.long	.LASF102
	.byte	0xe
	.byte	0x1d
	.byte	0x15
	.long	0x4ed
	.byte	0xc0
	.uleb128 0x9
	.long	.LASF103
	.byte	0xe
	.byte	0x1e
	.byte	0x14
	.long	0x537
	.byte	0xe8
	.uleb128 0x16
	.long	.LASF104
	.byte	0xe
	.byte	0x1f
	.byte	0xa
	.long	0x9d
	.value	0x118
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x673
	.uleb128 0xd
	.long	0x39
	.byte	0x5
	.byte	0
	.uleb128 0x2
	.long	.LASF105
	.byte	0xe
	.byte	0x20
	.byte	0x3
	.long	0x5de
	.uleb128 0x8
	.long	.LASF106
	.byte	0xc0
	.byte	0xe
	.byte	0x24
	.byte	0x10
	.long	0x6db
	.uleb128 0x9
	.long	.LASF96
	.byte	0xe
	.byte	0x26
	.byte	0x15
	.long	0x4ed
	.byte	0
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x27
	.byte	0x14
	.long	0x537
	.byte	0x28
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x28
	.byte	0xa
	.long	0x663
	.byte	0x58
	.uleb128 0x9
	.long	.LASF99
	.byte	0xe
	.byte	0x29
	.byte	0x15
	.long	0x4ed
	.byte	0x60
	.uleb128 0x9
	.long	.LASF100
	.byte	0xe
	.byte	0x2a
	.byte	0x14
	.long	0x537
	.byte	0x88
	.uleb128 0x9
	.long	.LASF101
	.byte	0xe
	.byte	0x2b
	.byte	0xa
	.long	0x9d
	.byte	0xb8
	.byte	0
	.uleb128 0x2
	.long	.LASF107
	.byte	0xe
	.byte	0x2c
	.byte	0x3
	.long	0x67f
	.uleb128 0x8
	.long	.LASF108
	.byte	0x68
	.byte	0xe
	.byte	0x30
	.byte	0x10
	.long	0x736
	.uleb128 0x9
	.long	.LASF96
	.byte	0xe
	.byte	0x32
	.byte	0x15
	.long	0x4ed
	.byte	0
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x33
	.byte	0x14
	.long	0x537
	.byte	0x28
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x34
	.byte	0xa
	.long	0x663
	.byte	0x58
	.uleb128 0x9
	.long	.LASF109
	.byte	0xe
	.byte	0x35
	.byte	0xd
	.long	0x2f5
	.byte	0x5e
	.uleb128 0x9
	.long	.LASF110
	.byte	0xe
	.byte	0x36
	.byte	0xa
	.long	0x9d
	.byte	0x60
	.byte	0
	.uleb128 0x2
	.long	.LASF111
	.byte	0xe
	.byte	0x37
	.byte	0x3
	.long	0x6e7
	.uleb128 0x15
	.long	.LASF112
	.value	0xb68
	.byte	0xe
	.byte	0x3b
	.byte	0x10
	.long	0x77a
	.uleb128 0x9
	.long	.LASF95
	.byte	0xe
	.byte	0x3e
	.byte	0xd
	.long	0x77a
	.byte	0
	.uleb128 0x16
	.long	.LASF106
	.byte	0xe
	.byte	0x40
	.byte	0xc
	.long	0x78a
	.value	0x5a0
	.uleb128 0x16
	.long	.LASF108
	.byte	0xe
	.byte	0x42
	.byte	0xd
	.long	0x79a
	.value	0x960
	.byte	0
	.uleb128 0xc
	.long	0x673
	.long	0x78a
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0xc
	.long	0x6db
	.long	0x79a
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0xc
	.long	0x736
	.long	0x7aa
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0x2
	.long	.LASF113
	.byte	0xe
	.byte	0x43
	.byte	0x3
	.long	0x742
	.uleb128 0x8
	.long	.LASF114
	.byte	0x18
	.byte	0xe
	.byte	0x48
	.byte	0x10
	.long	0x7ea
	.uleb128 0x17
	.string	"key"
	.byte	0xe
	.byte	0x4a
	.byte	0x11
	.long	0x2d7
	.byte	0
	.uleb128 0x17
	.string	"fd"
	.byte	0xe
	.byte	0x4c
	.byte	0x9
	.long	0x71
	.byte	0x8
	.uleb128 0x9
	.long	.LASF115
	.byte	0xe
	.byte	0x4e
	.byte	0xb
	.long	0x7ea
	.byte	0x10
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x7aa
	.uleb128 0x2
	.long	.LASF116
	.byte	0xe
	.byte	0x4f
	.byte	0x3
	.long	0x7b6
	.uleb128 0x2
	.long	.LASF117
	.byte	0xe
	.byte	0x5e
	.byte	0x13
	.long	0x808
	.uleb128 0x18
	.string	"NP"
	.byte	0x10
	.byte	0xe
	.byte	0x5f
	.byte	0x8
	.long	0x82f
	.uleb128 0x9
	.long	.LASF118
	.byte	0xe
	.byte	0x61
	.byte	0xa
	.long	0x82f
	.byte	0
	.uleb128 0x9
	.long	.LASF119
	.byte	0xe
	.byte	0x62
	.byte	0xb
	.long	0x83f
	.byte	0x8
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x83f
	.uleb128 0xd
	.long	0x39
	.byte	0x6
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x7fc
	.uleb128 0x2
	.long	.LASF120
	.byte	0xe
	.byte	0x65
	.byte	0x15
	.long	0x851
	.uleb128 0x8
	.long	.LASF121
	.byte	0x10
	.byte	0xe
	.byte	0x66
	.byte	0x8
	.long	0x879
	.uleb128 0x9
	.long	.LASF122
	.byte	0xe
	.byte	0x68
	.byte	0xa
	.long	0x879
	.byte	0
	.uleb128 0x9
	.long	.LASF123
	.byte	0xe
	.byte	0x69
	.byte	0xa
	.long	0x2d
	.byte	0x8
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x83f
	.uleb128 0x19
	.string	"CP"
	.byte	0x1
	.byte	0xe
	.byte	0xa
	.long	0x7f0
	.uleb128 0x9
	.byte	0x3
	.quad	CP
	.uleb128 0x19
	.string	"h"
	.byte	0x1
	.byte	0xf
	.byte	0x8
	.long	0x845
	.uleb128 0x9
	.byte	0x3
	.quad	h
	.uleb128 0xc
	.long	0x71
	.long	0x8b8
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0x1a
	.long	.LASF124
	.byte	0x1
	.byte	0x12
	.byte	0x5
	.long	0x8a8
	.uleb128 0x9
	.byte	0x3
	.quad	level_car_counter
	.uleb128 0x1a
	.long	.LASF125
	.byte	0x1
	.byte	0x13
	.byte	0x11
	.long	0x4ed
	.uleb128 0x9
	.byte	0x3
	.quad	level_car_counter_mutex
	.uleb128 0x19
	.string	"sim"
	.byte	0x1
	.byte	0x16
	.byte	0x6
	.long	0x8fa
	.uleb128 0x9
	.byte	0x3
	.quad	sim
	.uleb128 0x3
	.byte	0x1
	.byte	0x2
	.long	.LASF126
	.uleb128 0x1b
	.long	.LASF135
	.byte	0x1
	.value	0x13d
	.byte	0x5
	.long	0x71
	.quad	.LFB19
	.quad	.LFE19-.LFB19
	.uleb128 0x1
	.byte	0x9c
	.long	0x945
	.uleb128 0x1c
	.string	"key"
	.byte	0x1
	.value	0x140
	.byte	0x11
	.long	0x2d7
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x1d
	.long	.LASF122
	.byte	0x1
	.value	0x145
	.byte	0xc
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x1e
	.long	.LASF129
	.byte	0x1
	.value	0x12e
	.byte	0x7
	.long	0x47
	.quad	.LFB18
	.quad	.LFE18-.LFB18
	.uleb128 0x1
	.byte	0x9c
	.long	0x999
	.uleb128 0x1f
	.long	.LASF131
	.byte	0x1
	.value	0x12e
	.byte	0x17
	.long	0x47
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x1d
	.long	.LASF127
	.byte	0x1
	.value	0x131
	.byte	0x8
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1d
	.long	.LASF128
	.byte	0x1
	.value	0x132
	.byte	0xd
	.long	0x999
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x736
	.uleb128 0x20
	.long	.LASF130
	.byte	0x1
	.byte	0xd5
	.byte	0x7
	.long	0x47
	.quad	.LFB17
	.quad	.LFE17-.LFB17
	.uleb128 0x1
	.byte	0x9c
	.long	0xa49
	.uleb128 0x21
	.long	.LASF132
	.byte	0x1
	.byte	0xd5
	.byte	0x17
	.long	0x47
	.uleb128 0x3
	.byte	0x91
	.sleb128 -72
	.uleb128 0x22
	.string	"num"
	.byte	0x1
	.byte	0xd8
	.byte	0x9
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x23
	.long	.LASF133
	.byte	0x1
	.byte	0xd9
	.byte	0xe
	.long	0xa49
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x24
	.long	.Ldebug_ranges0+0
	.uleb128 0x23
	.long	.LASF134
	.byte	0x1
	.byte	0xe2
	.byte	0x12
	.long	0x82f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -55
	.uleb128 0x24
	.long	.Ldebug_ranges0+0x30
	.uleb128 0x23
	.long	.LASF131
	.byte	0x1
	.byte	0xea
	.byte	0x15
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1d
	.long	.LASF128
	.byte	0x1
	.value	0x10c
	.byte	0x1a
	.long	0x999
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x25
	.quad	.LBB10
	.quad	.LBE10-.LBB10
	.uleb128 0x22
	.string	"i"
	.byte	0x1
	.byte	0xeb
	.byte	0x1a
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x673
	.uleb128 0x26
	.long	.LASF136
	.byte	0x1
	.byte	0xb8
	.byte	0x6
	.quad	.LFB16
	.quad	.LFE16-.LFB16
	.uleb128 0x1
	.byte	0x9c
	.long	0xab9
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0xb8
	.byte	0x19
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x25
	.quad	.LBB6
	.quad	.LBE6-.LBB6
	.uleb128 0x22
	.string	"i"
	.byte	0x1
	.byte	0xbb
	.byte	0x11
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x25
	.quad	.LBB7
	.quad	.LBE7-.LBB7
	.uleb128 0x22
	.string	"j"
	.byte	0x1
	.byte	0xc4
	.byte	0x18
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x845
	.uleb128 0x26
	.long	.LASF137
	.byte	0x1
	.byte	0xb3
	.byte	0x6
	.quad	.LFB15
	.quad	.LFE15-.LFB15
	.uleb128 0x1
	.byte	0x9c
	.long	0xaeb
	.uleb128 0x27
	.string	"i"
	.byte	0x1
	.byte	0xb3
	.byte	0x17
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x20
	.long	.LASF138
	.byte	0x1
	.byte	0x9b
	.byte	0x5
	.long	0x71
	.quad	.LFB14
	.quad	.LFE14-.LFB14
	.uleb128 0x1
	.byte	0x9c
	.long	0xb39
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x9b
	.byte	0x19
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x23
	.long	.LASF139
	.byte	0x1
	.byte	0x9f
	.byte	0xa
	.long	0x82f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -31
	.uleb128 0x23
	.long	.LASF140
	.byte	0x1
	.byte	0xa0
	.byte	0xb
	.long	0x29d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x26
	.long	.LASF141
	.byte	0x1
	.byte	0x86
	.byte	0x6
	.quad	.LFB13
	.quad	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.long	0xbc6
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x86
	.byte	0x1b
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x25
	.quad	.LBB3
	.quad	.LBE3-.LBB3
	.uleb128 0x22
	.string	"i"
	.byte	0x1
	.byte	0x89
	.byte	0x11
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x25
	.quad	.LBB4
	.quad	.LBE4-.LBB4
	.uleb128 0x23
	.long	.LASF142
	.byte	0x1
	.byte	0x8b
	.byte	0xf
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x25
	.quad	.LBB5
	.quad	.LBE5-.LBB5
	.uleb128 0x23
	.long	.LASF119
	.byte	0x1
	.byte	0x8e
	.byte	0x13
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x20
	.long	.LASF143
	.byte	0x1
	.byte	0x77
	.byte	0x7
	.long	0x83f
	.quad	.LFB12
	.quad	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.long	0xc33
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x77
	.byte	0x19
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x27
	.string	"key"
	.byte	0x1
	.byte	0x77
	.byte	0x22
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x23
	.long	.LASF144
	.byte	0x1
	.byte	0x79
	.byte	0xa
	.long	0x82f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -31
	.uleb128 0x25
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.uleb128 0x22
	.string	"i"
	.byte	0x1
	.byte	0x7c
	.byte	0x10
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.uleb128 0x20
	.long	.LASF145
	.byte	0x1
	.byte	0x71
	.byte	0x7
	.long	0x83f
	.quad	.LFB11
	.quad	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.long	0xc72
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x71
	.byte	0x1b
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x27
	.string	"key"
	.byte	0x1
	.byte	0x71
	.byte	0x24
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.byte	0
	.uleb128 0x20
	.long	.LASF146
	.byte	0x1
	.byte	0x5c
	.byte	0x6
	.long	0x8fa
	.quad	.LFB10
	.quad	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.long	0xccf
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x5c
	.byte	0x17
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x27
	.string	"key"
	.byte	0x1
	.byte	0x5c
	.byte	0x1f
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x23
	.long	.LASF147
	.byte	0x1
	.byte	0x5f
	.byte	0xb
	.long	0x83f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x23
	.long	.LASF142
	.byte	0x1
	.byte	0x69
	.byte	0xc
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x20
	.long	.LASF148
	.byte	0x1
	.byte	0x56
	.byte	0x8
	.long	0x2d
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.long	0xd0e
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x56
	.byte	0x1b
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x27
	.string	"key"
	.byte	0x1
	.byte	0x56
	.byte	0x24
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x28
	.long	.LASF149
	.byte	0x1
	.byte	0x49
	.byte	0x8
	.long	0x2d
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0xd5a
	.uleb128 0x27
	.string	"s"
	.byte	0x1
	.byte	0x49
	.byte	0x17
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x23
	.long	.LASF150
	.byte	0x1
	.byte	0x4b
	.byte	0xc
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x22
	.string	"c"
	.byte	0x1
	.byte	0x4c
	.byte	0x9
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.byte	0
	.uleb128 0x20
	.long	.LASF151
	.byte	0x1
	.byte	0x40
	.byte	0x6
	.long	0x8fa
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.long	0xd97
	.uleb128 0x27
	.string	"h"
	.byte	0x1
	.byte	0x40
	.byte	0x18
	.long	0xab9
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x27
	.string	"n"
	.byte	0x1
	.byte	0x40
	.byte	0x22
	.long	0x2d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x20
	.long	.LASF152
	.byte	0x1
	.byte	0x2b
	.byte	0x5
	.long	0x71
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0xdd8
	.uleb128 0x27
	.string	"shm"
	.byte	0x1
	.byte	0x2b
	.byte	0x24
	.long	0xdd8
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x21
	.long	.LASF153
	.byte	0x1
	.byte	0x2b
	.byte	0x35
	.long	0x2d7
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x7f0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x13
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x21
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x17
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0xd
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0x5
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1d
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1f
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x23
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x24
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x55
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x25
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x26
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x27
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x28
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.LBB8-.Ltext0
	.quad	.LBE8-.Ltext0
	.quad	.LBB12-.Ltext0
	.quad	.LBE12-.Ltext0
	.quad	0
	.quad	0
	.quad	.LBB9-.Ltext0
	.quad	.LBE9-.Ltext0
	.quad	.LBB11-.Ltext0
	.quad	.LBE11-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF112:
	.string	"CarPark"
.LASF31:
	.string	"_shortbuf"
.LASF157:
	.string	"_IO_lock_t"
.LASF128:
	.string	"level"
.LASF47:
	.string	"stderr"
.LASF121:
	.string	"htab"
.LASF20:
	.string	"_IO_buf_end"
.LASF94:
	.string	"optopt"
.LASF129:
	.string	"levelFunc"
.LASF156:
	.string	"/media/sf_CAB403_ParkCars"
.LASF18:
	.string	"_IO_write_end"
.LASF1:
	.string	"unsigned int"
.LASF119:
	.string	"next"
.LASF36:
	.string	"_freeres_list"
.LASF137:
	.string	"item_print"
.LASF12:
	.string	"_flags"
.LASF77:
	.string	"__wrefs"
.LASF130:
	.string	"enterFunc"
.LASF68:
	.string	"__wseq"
.LASF24:
	.string	"_markers"
.LASF143:
	.string	"htab_find"
.LASF95:
	.string	"Enter"
.LASF133:
	.string	"entrance"
.LASF125:
	.string	"level_car_counter_mutex"
.LASF120:
	.string	"htab_t"
.LASF86:
	.string	"__timezone"
.LASF131:
	.string	"level_num"
.LASF83:
	.string	"pthread_cond_t"
.LASF53:
	.string	"__pthread_internal_list"
.LASF149:
	.string	"djb_hash"
.LASF46:
	.string	"stdout"
.LASF71:
	.string	"__g1_start"
.LASF23:
	.string	"_IO_save_end"
.LASF59:
	.string	"__count"
.LASF93:
	.string	"opterr"
.LASF132:
	.string	"enter_num"
.LASF43:
	.string	"_IO_codecvt"
.LASF51:
	.string	"int16_t"
.LASF70:
	.string	"long long unsigned int"
.LASF140:
	.string	"file"
.LASF98:
	.string	"LPR_reading"
.LASF136:
	.string	"htab_print"
.LASF49:
	.string	"sys_errlist"
.LASF22:
	.string	"_IO_backup_base"
.LASF108:
	.string	"Level"
.LASF33:
	.string	"_offset"
.LASF75:
	.string	"__g_size"
.LASF64:
	.string	"__elision"
.LASF48:
	.string	"sys_nerr"
.LASF26:
	.string	"_fileno"
.LASF113:
	.string	"CP_t"
.LASF144:
	.string	"buff"
.LASF116:
	.string	"shm_CP_t"
.LASF142:
	.string	"bucket"
.LASF5:
	.string	"size_t"
.LASF155:
	.string	"manager.c"
.LASF15:
	.string	"_IO_read_base"
.LASF107:
	.string	"Exit_t"
.LASF104:
	.string	"info_sign_status"
.LASF45:
	.string	"stdin"
.LASF110:
	.string	"fire_alarm"
.LASF146:
	.string	"htab_add"
.LASF111:
	.string	"Level_t"
.LASF67:
	.string	"__high"
.LASF103:
	.string	"info_sign_cond"
.LASF55:
	.string	"__next"
.LASF134:
	.string	"temp_LPR"
.LASF96:
	.string	"LPR_mutex"
.LASF11:
	.string	"char"
.LASF39:
	.string	"_mode"
.LASF85:
	.string	"__daylight"
.LASF87:
	.string	"tzname"
.LASF42:
	.string	"_IO_marker"
.LASF13:
	.string	"_IO_read_ptr"
.LASF63:
	.string	"__spins"
.LASF54:
	.string	"__prev"
.LASF109:
	.string	"temp_sensor"
.LASF16:
	.string	"_IO_write_base"
.LASF65:
	.string	"__list"
.LASF50:
	.string	"long long int"
.LASF21:
	.string	"_IO_save_base"
.LASF115:
	.string	"shm_ptr"
.LASF153:
	.string	"shm_key"
.LASF151:
	.string	"htab_init"
.LASF92:
	.string	"optind"
.LASF145:
	.string	"htab_bucket"
.LASF6:
	.string	"__int16_t"
.LASF127:
	.string	"num_level"
.LASF141:
	.string	"htab_destroy"
.LASF123:
	.string	"size"
.LASF37:
	.string	"_freeres_buf"
.LASF62:
	.string	"__kind"
.LASF38:
	.string	"__pad5"
.LASF126:
	.string	"_Bool"
.LASF30:
	.string	"_vtable_offset"
.LASF102:
	.string	"info_sign_mutex"
.LASF91:
	.string	"optarg"
.LASF56:
	.string	"__pthread_list_t"
.LASF118:
	.string	"number_plate"
.LASF89:
	.string	"timezone"
.LASF117:
	.string	"NP_t"
.LASF14:
	.string	"_IO_read_end"
.LASF124:
	.string	"level_car_counter"
.LASF7:
	.string	"short int"
.LASF8:
	.string	"long int"
.LASF60:
	.string	"__owner"
.LASF150:
	.string	"hash"
.LASF152:
	.string	"shared_mem_init_open"
.LASF97:
	.string	"LPR_cond"
.LASF138:
	.string	"LPR_to_htab"
.LASF44:
	.string	"_IO_wide_data"
.LASF90:
	.string	"__environ"
.LASF101:
	.string	"BOOM_status"
.LASF139:
	.string	"source"
.LASF79:
	.string	"__data"
.LASF61:
	.string	"__nusers"
.LASF35:
	.string	"_wide_data"
.LASF32:
	.string	"_lock"
.LASF0:
	.string	"long unsigned int"
.LASF28:
	.string	"_old_offset"
.LASF52:
	.string	"_IO_FILE"
.LASF72:
	.string	"__g1_start32"
.LASF82:
	.string	"pthread_mutex_t"
.LASF58:
	.string	"__lock"
.LASF74:
	.string	"__g_refs"
.LASF148:
	.string	"htab_index"
.LASF2:
	.string	"unsigned char"
.LASF100:
	.string	"BOOM_cond"
.LASF84:
	.string	"__tzname"
.LASF17:
	.string	"_IO_write_ptr"
.LASF69:
	.string	"__wseq32"
.LASF73:
	.string	"__pthread_cond_s"
.LASF154:
	.string	"GNU C17 8.3.0 -mtune=generic -march=x86-64 -g"
.LASF78:
	.string	"__g_signals"
.LASF34:
	.string	"_codecvt"
.LASF88:
	.string	"daylight"
.LASF66:
	.string	"__low"
.LASF9:
	.string	"__off_t"
.LASF4:
	.string	"signed char"
.LASF114:
	.string	"Shm_Carpark"
.LASF3:
	.string	"short unsigned int"
.LASF135:
	.string	"main"
.LASF105:
	.string	"Enter_t"
.LASF76:
	.string	"__g1_orig_size"
.LASF122:
	.string	"buckets"
.LASF81:
	.string	"__align"
.LASF25:
	.string	"_chain"
.LASF106:
	.string	"Exit"
.LASF147:
	.string	"newhead"
.LASF41:
	.string	"FILE"
.LASF99:
	.string	"BOOM_mutex"
.LASF27:
	.string	"_flags2"
.LASF80:
	.string	"__size"
.LASF29:
	.string	"_cur_column"
.LASF10:
	.string	"__off64_t"
.LASF40:
	.string	"_unused2"
.LASF19:
	.string	"_IO_buf_base"
.LASF57:
	.string	"__pthread_mutex_s"
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
