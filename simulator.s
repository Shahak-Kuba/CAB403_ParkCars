	.file	"simulator.c"
	.text
.Ltext0:
	.globl	car_list_chance
	.data
	.align 4
	.type	car_list_chance, @object
	.size	car_list_chance, 4
car_list_chance:
	.long	50
	.comm	CP,24,16
	.globl	fireState
	.bss
	.align 4
	.type	fireState, @object
	.size	fireState, 4
fireState:
	.zero	4
	.section	.rodata
	.align 8
.LC0:
	.string	"Enter F to trigger Creeping Fire Alarm Event"
	.align 8
.LC1:
	.string	"Enter G to trigger Spike Fire Alarm Event"
.LC2:
	.string	"PARKING"
	.align 8
.LC3:
	.string	"Increasing Temperature Over Time"
	.align 8
.LC4:
	.string	"Increasing Temperature Instantly"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.file 1 "simulator.c"
	.loc 1 37 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	.loc 1 38 5
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	.loc 1 39 5
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	.loc 1 41 5
	leaq	.LC2(%rip), %rsi
	leaq	CP(%rip), %rdi
	call	shared_mem_init
	.loc 1 44 5
	movl	$0, %eax
	call	init_gates
.LBB2:
	.loc 1 49 13
	movl	$0, -60(%rbp)
	.loc 1 49 5
	jmp	.L2
.L3:
	.loc 1 51 34 discriminator 3
	movl	-60(%rbp), %edx
	.loc 1 51 9 discriminator 3
	leaq	-48(%rbp), %rax
	movslq	%edx, %rdx
	salq	$3, %rdx
	leaq	(%rax,%rdx), %rdi
	leaq	-60(%rbp), %rax
	movq	%rax, %rcx
	leaq	toggleGate(%rip), %rdx
	movl	$0, %esi
	call	pthread_create@PLT
	.loc 1 49 28 discriminator 3
	movl	-60(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -60(%rbp)
.L2:
	.loc 1 49 22 discriminator 1
	movl	-60(%rbp), %eax
	.loc 1 49 5 discriminator 1
	testl	%eax, %eax
	jle	.L3
.LBE2:
	.loc 1 57 12
	movb	$0, -49(%rbp)
.LBB3:
	.loc 1 58 13
	movl	$0, -4(%rbp)
	.loc 1 58 5
	jmp	.L4
.L5:
	.loc 1 60 9 discriminator 3
	leaq	-55(%rbp), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	LPR_generator
	.loc 1 61 9 discriminator 3
	leaq	-55(%rbp), %rax
	movq	%rax, %rdi
	call	puts@PLT
	.loc 1 58 30 discriminator 3
	addl	$1, -4(%rbp)
.L4:
	.loc 1 58 5 discriminator 1
	cmpl	$499, -4(%rbp)
	jle	.L5
.L8:
.LBE3:
	.loc 1 65 13
	movq	stdin(%rip), %rax
	movq	%rax, %rdi
	call	fgetc@PLT
	.loc 1 65 12
	cmpl	$102, %eax
	jne	.L6
	.loc 1 66 13
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 67 23
	movl	$1, fireState(%rip)
	jmp	.L8
.L6:
	.loc 1 68 20
	movq	stdin(%rip), %rax
	movq	%rax, %rdi
	call	fgetc@PLT
	.loc 1 68 19
	cmpl	$103, %eax
	jne	.L8
	.loc 1 69 13
	leaq	.LC4(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 70 23
	movl	$2, fireState(%rip)
	.loc 1 65 12
	jmp	.L8
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.section	.rodata
.LC5:
	.string	"shm_open"
.LC6:
	.string	"ftruncate"
.LC7:
	.string	"mmap"
.LC8:
	.string	"shared mem pointer: %p\n"
	.text
	.globl	shared_mem_init
	.type	shared_mem_init, @function
shared_mem_init:
.LFB7:
	.loc 1 80 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	.loc 1 81 5
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	shm_unlink@PLT
	.loc 1 82 14
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, (%rax)
	.loc 1 85 19
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movl	$438, %edx
	movl	$66, %esi
	movq	%rax, %rdi
	call	shm_open@PLT
	movl	%eax, %edx
	.loc 1 85 17
	movq	-8(%rbp), %rax
	movl	%edx, 8(%rax)
	.loc 1 85 12
	movq	-8(%rbp), %rax
	movl	8(%rax), %eax
	.loc 1 85 7
	testl	%eax, %eax
	jns	.L10
	.loc 1 87 9
	leaq	.LC5(%rip), %rdi
	call	perror@PLT
	.loc 1 88 15
	movl	$1, %eax
	jmp	.L11
.L10:
	.loc 1 92 8
	movq	-8(%rbp), %rax
	movl	8(%rax), %eax
	movl	$2120, %esi
	movl	%eax, %edi
	call	ftruncate@PLT
	.loc 1 92 7
	testl	%eax, %eax
	jns	.L12
	.loc 1 94 9
	leaq	.LC6(%rip), %rdi
	call	perror@PLT
	.loc 1 95 15
	movl	$1, %eax
	jmp	.L11
.L12:
	.loc 1 99 24
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
	.loc 1 99 22
	movq	-8(%rbp), %rax
	movq	%rdx, 16(%rax)
	.loc 1 99 12
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	.loc 1 99 7
	cmpq	$-1, %rax
	jne	.L13
	.loc 1 101 9
	leaq	.LC7(%rip), %rdi
	call	perror@PLT
	.loc 1 102 15
	movl	$1, %eax
	jmp	.L11
.L13:
	.loc 1 106 5
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, %rsi
	leaq	.LC8(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	.loc 1 107 11
	movl	$0, %eax
.L11:
	.loc 1 108 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	shared_mem_init, .-shared_mem_init
	.globl	clear_memory
	.type	clear_memory, @function
clear_memory:
.LFB8:
	.loc 1 111 36
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 113 15
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	.loc 1 113 5
	movl	$2920, %esi
	movq	%rax, %rdi
	call	munmap@PLT
	.loc 1 114 5
	leaq	.LC2(%rip), %rdi
	call	shm_unlink@PLT
	.loc 1 115 13
	movq	-8(%rbp), %rax
	movl	$-1, 8(%rax)
	.loc 1 116 18
	movq	-8(%rbp), %rax
	movq	$0, 16(%rax)
	.loc 1 117 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	clear_memory, .-clear_memory
	.section	.rodata
.LC9:
	.string	"r"
.LC10:
	.string	"plates.txt"
	.text
	.globl	LPR_generator
	.type	LPR_generator, @function
LPR_generator:
.LFB9:
	.loc 1 122 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	.loc 1 124 13
	call	rand@PLT
	movl	%eax, %ecx
	.loc 1 124 20
	movl	$1374389535, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$5, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	.loc 1 124 26
	movl	car_list_chance(%rip), %edx
	.loc 1 124 12
	cmpl	%edx, %eax
	jg	.L16
.LBB4:
	.loc 1 128 30
	leaq	.LC9(%rip), %rsi
	leaq	.LC10(%rip), %rdi
	call	fopen@PLT
	movq	%rax, -16(%rbp)
	.loc 1 129 13
	movq	-16(%rbp), %rax
	movl	$2, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	fseek@PLT
	.loc 1 130 36
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	ftell@PLT
	movq	%rax, %rcx
	.loc 1 130 52
	movabsq	$5270498306774157605, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	sarq	%rdx
	movq	%rcx, %rax
	sarq	$63, %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	.loc 1 130 17
	movl	%eax, -20(%rbp)
	.loc 1 132 29
	call	rand@PLT
	.loc 1 132 36
	cltd
	idivl	-20(%rbp)
	.loc 1 132 55
	movl	%edx, %eax
	sall	$3, %eax
	subl	%edx, %eax
	.loc 1 132 13
	movslq	%eax, %rcx
	movq	-16(%rbp), %rax
	movl	$0, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	fseek@PLT
	.loc 1 133 13
	movq	-16(%rbp), %rdx
	movq	-40(%rbp), %rax
	movl	$7, %esi
	movq	%rax, %rdi
	call	fgets@PLT
	.loc 1 135 13
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	fclose@PLT
.LBE4:
	.loc 1 150 9
	jmp	.L23
.L16:
.LBB5:
	.loc 1 140 21
	movl	$0, -4(%rbp)
	.loc 1 140 13
	jmp	.L18
.L21:
	.loc 1 141 19
	cmpl	$2, -4(%rbp)
	jg	.L19
	.loc 1 142 37
	call	random@PLT
	movq	%rax, %rcx
	.loc 1 142 46
	movabsq	$7378697629483820647, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	sarq	$2, %rdx
	movq	%rcx, %rax
	sarq	$63, %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movq	%rcx, %rdx
	.loc 1 142 34
	movl	%edx, %eax
	leal	48(%rax), %ecx
	.loc 1 142 24
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	.loc 1 142 34
	movl	%ecx, %edx
	.loc 1 142 28
	movb	%dl, (%rax)
	jmp	.L20
.L19:
	.loc 1 144 36
	call	random@PLT
	movq	%rax, %rcx
	.loc 1 144 45
	movabsq	$5675921253449092805, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	sarq	$3, %rdx
	movq	%rcx, %rax
	sarq	$63, %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movq	%rcx, %rdx
	.loc 1 144 34
	movl	%edx, %eax
	leal	65(%rax), %ecx
	.loc 1 144 24
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	.loc 1 144 34
	movl	%ecx, %edx
	.loc 1 144 28
	movb	%dl, (%rax)
.L20:
	.loc 1 140 36 discriminator 2
	addl	$1, -4(%rbp)
.L18:
	.loc 1 140 13 discriminator 1
	cmpl	$5, -4(%rbp)
	jle	.L21
.L23:
.LBE5:
	.loc 1 150 9
	nop
	.loc 1 159 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	LPR_generator, .-LPR_generator
	.globl	toggleGate
	.type	toggleGate, @function
toggleGate:
.LFB10:
	.loc 1 163 41
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 164 9
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -4(%rbp)
	.loc 1 165 28
	movq	16+CP(%rip), %rcx
	.loc 1 165 14
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	addq	%rdx, %rax
	salq	$5, %rax
	addq	%rcx, %rax
	movq	%rax, -16(%rbp)
	.loc 1 167 5
	movq	-16(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
.L27:
	.loc 1 175 20
	movq	-16(%rbp), %rax
	movzbl	184(%rax), %eax
	.loc 1 175 11
	cmpb	$82, %al
	jne	.L25
	.loc 1 180 35
	movq	-16(%rbp), %rax
	movb	$79, 184(%rax)
	.loc 1 182 13
	movq	-16(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	jmp	.L26
.L25:
	.loc 1 192 35
	movq	-16(%rbp), %rax
	movb	$67, 184(%rax)
	.loc 1 194 13
	movq	-16(%rbp), %rax
	addq	$96, %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
.L26:
	.loc 1 199 9
	movq	-16(%rbp), %rax
	addq	$232, %rax
	movq	%rax, %rdi
	call	pthread_cond_signal@PLT
	.loc 1 201 9
	movq	-16(%rbp), %rax
	leaq	96(%rax), %rdx
	movq	-16(%rbp), %rax
	addq	$136, %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_cond_wait@PLT
	.loc 1 175 11
	jmp	.L27
	.cfi_endproc
.LFE10:
	.size	toggleGate, .-toggleGate
	.section	.rodata
.LC11:
	.string	"%p\n"
	.text
	.globl	init_gates
	.type	init_gates, @function
init_gates:
.LFB11:
	.loc 1 207 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 209 11
	movq	16+CP(%rip), %rax
	movq	%rax, -16(%rbp)
	.loc 1 210 5
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC11(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.LBB6:
	.loc 1 211 13
	movl	$0, -4(%rbp)
	.loc 1 211 5
	jmp	.L29
.L30:
	.loc 1 213 39 discriminator 3
	movq	-16(%rbp), %rcx
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	addq	%rdx, %rax
	salq	$5, %rax
	addq	%rcx, %rax
	addq	$184, %rax
	movb	$67, (%rax)
	.loc 1 211 37 discriminator 3
	addl	$1, -4(%rbp)
.L29:
	.loc 1 211 5 discriminator 1
	cmpl	$4, -4(%rbp)
	jle	.L30
.LBE6:
	.loc 1 216 1
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	init_gates, .-init_gates
	.globl	generateTemperature
	.type	generateTemperature, @function
generateTemperature:
.LFB12:
	.loc 1 221 32
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 222 5
	movl	fireState(%rip), %eax
	cmpl	$1, %eax
	je	.L36
	cmpl	$2, %eax
	je	.L37
	.loc 1 231 13
	jmp	.L35
.L36:
	.loc 1 225 13
	nop
	jmp	.L35
.L37:
	.loc 1 228 13
	nop
.L35:
	.loc 1 233 1
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	generateTemperature, .-generateTemperature
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
	.long	0xa9a
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF133
	.byte	0xc
	.long	.LASF134
	.long	.LASF135
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
	.long	.LASF136
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
	.uleb128 0x2
	.long	.LASF79
	.byte	0xa
	.byte	0x1b
	.byte	0x1b
	.long	0x39
	.uleb128 0x11
	.byte	0x28
	.byte	0xa
	.byte	0x43
	.byte	0x9
	.long	0x4e9
	.uleb128 0x12
	.long	.LASF80
	.byte	0xa
	.byte	0x45
	.byte	0x1c
	.long	0x33b
	.uleb128 0x12
	.long	.LASF81
	.byte	0xa
	.byte	0x46
	.byte	0x8
	.long	0x4e9
	.uleb128 0x12
	.long	.LASF82
	.byte	0xa
	.byte	0x47
	.byte	0xc
	.long	0x78
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x4f9
	.uleb128 0xd
	.long	0x39
	.byte	0x27
	.byte	0
	.uleb128 0x2
	.long	.LASF83
	.byte	0xa
	.byte	0x48
	.byte	0x3
	.long	0x4bb
	.uleb128 0x11
	.byte	0x30
	.byte	0xa
	.byte	0x4b
	.byte	0x9
	.long	0x533
	.uleb128 0x12
	.long	.LASF80
	.byte	0xa
	.byte	0x4d
	.byte	0x1b
	.long	0x444
	.uleb128 0x12
	.long	.LASF81
	.byte	0xa
	.byte	0x4e
	.byte	0x8
	.long	0x533
	.uleb128 0x12
	.long	.LASF82
	.byte	0xa
	.byte	0x4f
	.byte	0x1f
	.long	0x2ee
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x543
	.uleb128 0xd
	.long	0x39
	.byte	0x2f
	.byte	0
	.uleb128 0x2
	.long	.LASF84
	.byte	0xa
	.byte	0x50
	.byte	0x3
	.long	0x505
	.uleb128 0xc
	.long	0x97
	.long	0x55f
	.uleb128 0xd
	.long	0x39
	.byte	0x1
	.byte	0
	.uleb128 0xe
	.long	.LASF85
	.byte	0xb
	.byte	0x9f
	.byte	0xe
	.long	0x54f
	.uleb128 0xe
	.long	.LASF86
	.byte	0xb
	.byte	0xa0
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF87
	.byte	0xb
	.byte	0xa1
	.byte	0x11
	.long	0x78
	.uleb128 0xe
	.long	.LASF88
	.byte	0xb
	.byte	0xa6
	.byte	0xe
	.long	0x54f
	.uleb128 0xe
	.long	.LASF89
	.byte	0xb
	.byte	0xae
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF90
	.byte	0xb
	.byte	0xaf
	.byte	0x11
	.long	0x78
	.uleb128 0x14
	.long	.LASF91
	.byte	0xc
	.value	0x21f
	.byte	0xf
	.long	0x5b4
	.uleb128 0x6
	.byte	0x8
	.long	0x97
	.uleb128 0xe
	.long	.LASF92
	.byte	0xd
	.byte	0x24
	.byte	0xe
	.long	0x97
	.uleb128 0xe
	.long	.LASF93
	.byte	0xd
	.byte	0x32
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF94
	.byte	0xd
	.byte	0x37
	.byte	0xc
	.long	0x71
	.uleb128 0xe
	.long	.LASF95
	.byte	0xd
	.byte	0x3b
	.byte	0xc
	.long	0x71
	.uleb128 0x15
	.long	.LASF96
	.value	0x120
	.byte	0xe
	.byte	0x15
	.byte	0x10
	.long	0x66f
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x17
	.byte	0x15
	.long	0x4f9
	.byte	0
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x18
	.byte	0x14
	.long	0x543
	.byte	0x28
	.uleb128 0x9
	.long	.LASF99
	.byte	0xe
	.byte	0x19
	.byte	0xa
	.long	0x66f
	.byte	0x58
	.uleb128 0x9
	.long	.LASF100
	.byte	0xe
	.byte	0x1a
	.byte	0x15
	.long	0x4f9
	.byte	0x60
	.uleb128 0x9
	.long	.LASF101
	.byte	0xe
	.byte	0x1b
	.byte	0x14
	.long	0x543
	.byte	0x88
	.uleb128 0x9
	.long	.LASF102
	.byte	0xe
	.byte	0x1c
	.byte	0xa
	.long	0x9d
	.byte	0xb8
	.uleb128 0x9
	.long	.LASF103
	.byte	0xe
	.byte	0x1d
	.byte	0x15
	.long	0x4f9
	.byte	0xc0
	.uleb128 0x9
	.long	.LASF104
	.byte	0xe
	.byte	0x1e
	.byte	0x14
	.long	0x543
	.byte	0xe8
	.uleb128 0x16
	.long	.LASF105
	.byte	0xe
	.byte	0x1f
	.byte	0xa
	.long	0x9d
	.value	0x118
	.byte	0
	.uleb128 0xc
	.long	0x9d
	.long	0x67f
	.uleb128 0xd
	.long	0x39
	.byte	0x5
	.byte	0
	.uleb128 0x2
	.long	.LASF106
	.byte	0xe
	.byte	0x20
	.byte	0x3
	.long	0x5ea
	.uleb128 0x8
	.long	.LASF107
	.byte	0xc0
	.byte	0xe
	.byte	0x24
	.byte	0x10
	.long	0x6e7
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x26
	.byte	0x15
	.long	0x4f9
	.byte	0
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x27
	.byte	0x14
	.long	0x543
	.byte	0x28
	.uleb128 0x9
	.long	.LASF99
	.byte	0xe
	.byte	0x28
	.byte	0xa
	.long	0x66f
	.byte	0x58
	.uleb128 0x9
	.long	.LASF100
	.byte	0xe
	.byte	0x29
	.byte	0x15
	.long	0x4f9
	.byte	0x60
	.uleb128 0x9
	.long	.LASF101
	.byte	0xe
	.byte	0x2a
	.byte	0x14
	.long	0x543
	.byte	0x88
	.uleb128 0x9
	.long	.LASF102
	.byte	0xe
	.byte	0x2b
	.byte	0xa
	.long	0x9d
	.byte	0xb8
	.byte	0
	.uleb128 0x2
	.long	.LASF108
	.byte	0xe
	.byte	0x2c
	.byte	0x3
	.long	0x68b
	.uleb128 0x8
	.long	.LASF109
	.byte	0x68
	.byte	0xe
	.byte	0x30
	.byte	0x10
	.long	0x742
	.uleb128 0x9
	.long	.LASF97
	.byte	0xe
	.byte	0x32
	.byte	0x15
	.long	0x4f9
	.byte	0
	.uleb128 0x9
	.long	.LASF98
	.byte	0xe
	.byte	0x33
	.byte	0x14
	.long	0x543
	.byte	0x28
	.uleb128 0x9
	.long	.LASF99
	.byte	0xe
	.byte	0x34
	.byte	0xa
	.long	0x66f
	.byte	0x58
	.uleb128 0x9
	.long	.LASF110
	.byte	0xe
	.byte	0x35
	.byte	0xd
	.long	0x2f5
	.byte	0x5e
	.uleb128 0x9
	.long	.LASF111
	.byte	0xe
	.byte	0x36
	.byte	0xa
	.long	0x9d
	.byte	0x60
	.byte	0
	.uleb128 0x2
	.long	.LASF112
	.byte	0xe
	.byte	0x37
	.byte	0x3
	.long	0x6f3
	.uleb128 0x15
	.long	.LASF113
	.value	0xb68
	.byte	0xe
	.byte	0x3b
	.byte	0x10
	.long	0x786
	.uleb128 0x9
	.long	.LASF96
	.byte	0xe
	.byte	0x3e
	.byte	0xd
	.long	0x786
	.byte	0
	.uleb128 0x16
	.long	.LASF107
	.byte	0xe
	.byte	0x40
	.byte	0xc
	.long	0x796
	.value	0x5a0
	.uleb128 0x16
	.long	.LASF109
	.byte	0xe
	.byte	0x42
	.byte	0xd
	.long	0x7a6
	.value	0x960
	.byte	0
	.uleb128 0xc
	.long	0x67f
	.long	0x796
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0xc
	.long	0x6e7
	.long	0x7a6
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0xc
	.long	0x742
	.long	0x7b6
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
	.uleb128 0x2
	.long	.LASF114
	.byte	0xe
	.byte	0x43
	.byte	0x3
	.long	0x74e
	.uleb128 0x8
	.long	.LASF115
	.byte	0x18
	.byte	0xe
	.byte	0x48
	.byte	0x10
	.long	0x7f6
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
	.long	.LASF116
	.byte	0xe
	.byte	0x4e
	.byte	0xb
	.long	0x7f6
	.byte	0x10
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x7b6
	.uleb128 0x2
	.long	.LASF117
	.byte	0xe
	.byte	0x4f
	.byte	0x3
	.long	0x7c2
	.uleb128 0xc
	.long	0x9d
	.long	0x818
	.uleb128 0xd
	.long	0x39
	.byte	0x6
	.byte	0
	.uleb128 0x18
	.long	.LASF118
	.byte	0x1
	.byte	0xc
	.byte	0x5
	.long	0x71
	.uleb128 0x9
	.byte	0x3
	.quad	car_list_chance
	.uleb128 0x19
	.string	"CP"
	.byte	0x1
	.byte	0x10
	.byte	0xa
	.long	0x7fc
	.uleb128 0x9
	.byte	0x3
	.quad	CP
	.uleb128 0x18
	.long	.LASF119
	.byte	0x1
	.byte	0x22
	.byte	0x5
	.long	0x71
	.uleb128 0x9
	.byte	0x3
	.quad	fireState
	.uleb128 0x1a
	.long	.LASF137
	.byte	0x1
	.byte	0xdd
	.byte	0x6
	.quad	.LFB12
	.quad	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1b
	.long	.LASF138
	.byte	0x1
	.byte	0xce
	.byte	0x6
	.quad	.LFB11
	.quad	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.long	0x8c0
	.uleb128 0x1c
	.long	.LASF120
	.byte	0x1
	.byte	0xd1
	.byte	0xb
	.long	0x7f6
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x1d
	.quad	.LBB6
	.quad	.LBE6-.LBB6
	.uleb128 0x1e
	.string	"i"
	.byte	0x1
	.byte	0xd3
	.byte	0xd
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.byte	0
	.uleb128 0x1f
	.long	.LASF128
	.byte	0x1
	.byte	0xa3
	.byte	0x7
	.long	0x47
	.quad	.LFB10
	.quad	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.long	0x910
	.uleb128 0x20
	.long	.LASF123
	.byte	0x1
	.byte	0xa3
	.byte	0x18
	.long	0x47
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x1c
	.long	.LASF121
	.byte	0x1
	.byte	0xa4
	.byte	0x9
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1c
	.long	.LASF122
	.byte	0x1
	.byte	0xa5
	.byte	0xe
	.long	0x910
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x67f
	.uleb128 0x21
	.long	.LASF126
	.byte	0x1
	.byte	0x79
	.byte	0x6
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.long	0x997
	.uleb128 0x22
	.string	"LPR"
	.byte	0x1
	.byte	0x79
	.byte	0x19
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x23
	.quad	.LBB4
	.quad	.LBE4-.LBB4
	.long	0x977
	.uleb128 0x1c
	.long	.LASF124
	.byte	0x1
	.byte	0x80
	.byte	0x13
	.long	0x29d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x1c
	.long	.LASF125
	.byte	0x1
	.byte	0x82
	.byte	0x11
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.byte	0
	.uleb128 0x1d
	.quad	.LBB5
	.quad	.LBE5-.LBB5
	.uleb128 0x1e
	.string	"i"
	.byte	0x1
	.byte	0x8c
	.byte	0x15
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.byte	0
	.uleb128 0x21
	.long	.LASF127
	.byte	0x1
	.byte	0x6f
	.byte	0x6
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x9c5
	.uleb128 0x22
	.string	"shm"
	.byte	0x1
	.byte	0x6f
	.byte	0x1e
	.long	0x9c5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x7fc
	.uleb128 0x1f
	.long	.LASF129
	.byte	0x1
	.byte	0x4f
	.byte	0x5
	.long	0x71
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.long	0xa0c
	.uleb128 0x22
	.string	"shm"
	.byte	0x1
	.byte	0x4f
	.byte	0x1f
	.long	0x9c5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x20
	.long	.LASF130
	.byte	0x1
	.byte	0x4f
	.byte	0x2a
	.long	0x97
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x24
	.long	.LASF131
	.byte	0x1
	.byte	0x24
	.byte	0x5
	.long	0x71
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0xa91
	.uleb128 0x1c
	.long	.LASF132
	.byte	0x1
	.byte	0x2f
	.byte	0xf
	.long	0xa91
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x1e
	.string	"LPR"
	.byte	0x1
	.byte	0x38
	.byte	0xa
	.long	0x808
	.uleb128 0x3
	.byte	0x91
	.sleb128 -71
	.uleb128 0x23
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.long	0xa71
	.uleb128 0x1e
	.string	"i"
	.byte	0x1
	.byte	0x31
	.byte	0xd
	.long	0x71
	.uleb128 0x3
	.byte	0x91
	.sleb128 -76
	.byte	0
	.uleb128 0x1d
	.quad	.LBB3
	.quad	.LBE3-.LBB3
	.uleb128 0x1e
	.string	"i"
	.byte	0x1
	.byte	0x3a
	.byte	0xd
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.byte	0
	.uleb128 0x25
	.long	0x4af
	.uleb128 0xd
	.long	0x39
	.byte	0x4
	.byte	0
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
	.uleb128 0x2e
	.byte	0
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
	.uleb128 0x2117
	.uleb128 0x19
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
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
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
	.uleb128 0x1d
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x1e
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
	.uleb128 0x1f
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
	.uleb128 0x20
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
	.uleb128 0x21
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
	.uleb128 0x22
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
	.uleb128 0x23
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x24
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
	.uleb128 0x25
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
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
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF113:
	.string	"CarPark"
.LASF79:
	.string	"pthread_t"
.LASF31:
	.string	"_shortbuf"
.LASF138:
	.string	"init_gates"
.LASF136:
	.string	"_IO_lock_t"
.LASF47:
	.string	"stderr"
.LASF20:
	.string	"_IO_buf_end"
.LASF95:
	.string	"optopt"
.LASF135:
	.string	"/media/sf_CAB403_ParkCars"
.LASF18:
	.string	"_IO_write_end"
.LASF1:
	.string	"unsigned int"
.LASF36:
	.string	"_freeres_list"
.LASF12:
	.string	"_flags"
.LASF77:
	.string	"__wrefs"
.LASF68:
	.string	"__wseq"
.LASF24:
	.string	"_markers"
.LASF96:
	.string	"Enter"
.LASF122:
	.string	"entrance"
.LASF87:
	.string	"__timezone"
.LASF84:
	.string	"pthread_cond_t"
.LASF118:
	.string	"car_list_chance"
.LASF53:
	.string	"__pthread_internal_list"
.LASF128:
	.string	"toggleGate"
.LASF124:
	.string	"file_ptr"
.LASF46:
	.string	"stdout"
.LASF71:
	.string	"__g1_start"
.LASF23:
	.string	"_IO_save_end"
.LASF59:
	.string	"__count"
.LASF94:
	.string	"opterr"
.LASF43:
	.string	"_IO_codecvt"
.LASF51:
	.string	"int16_t"
.LASF137:
	.string	"generateTemperature"
.LASF70:
	.string	"long long unsigned int"
.LASF99:
	.string	"LPR_reading"
.LASF49:
	.string	"sys_errlist"
.LASF22:
	.string	"_IO_backup_base"
.LASF109:
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
.LASF114:
	.string	"CP_t"
.LASF119:
	.string	"fireState"
.LASF120:
	.string	"carpark"
.LASF121:
	.string	"entrance_num"
.LASF117:
	.string	"shm_CP_t"
.LASF5:
	.string	"size_t"
.LASF15:
	.string	"_IO_read_base"
.LASF108:
	.string	"Exit_t"
.LASF105:
	.string	"info_sign_status"
.LASF45:
	.string	"stdin"
.LASF127:
	.string	"clear_memory"
.LASF111:
	.string	"fire_alarm"
.LASF112:
	.string	"Level_t"
.LASF67:
	.string	"__high"
.LASF104:
	.string	"info_sign_cond"
.LASF55:
	.string	"__next"
.LASF97:
	.string	"LPR_mutex"
.LASF11:
	.string	"char"
.LASF39:
	.string	"_mode"
.LASF86:
	.string	"__daylight"
.LASF134:
	.string	"simulator.c"
.LASF88:
	.string	"tzname"
.LASF42:
	.string	"_IO_marker"
.LASF13:
	.string	"_IO_read_ptr"
.LASF63:
	.string	"__spins"
.LASF54:
	.string	"__prev"
.LASF110:
	.string	"temp_sensor"
.LASF16:
	.string	"_IO_write_base"
.LASF65:
	.string	"__list"
.LASF50:
	.string	"long long int"
.LASF21:
	.string	"_IO_save_base"
.LASF116:
	.string	"shm_ptr"
.LASF93:
	.string	"optind"
.LASF6:
	.string	"__int16_t"
.LASF130:
	.string	"shm_key"
.LASF123:
	.string	"entrance_no_ptr"
.LASF37:
	.string	"_freeres_buf"
.LASF62:
	.string	"__kind"
.LASF38:
	.string	"__pad5"
.LASF30:
	.string	"_vtable_offset"
.LASF103:
	.string	"info_sign_mutex"
.LASF92:
	.string	"optarg"
.LASF56:
	.string	"__pthread_list_t"
.LASF90:
	.string	"timezone"
.LASF14:
	.string	"_IO_read_end"
.LASF7:
	.string	"short int"
.LASF125:
	.string	"file_plate_count"
.LASF8:
	.string	"long int"
.LASF126:
	.string	"LPR_generator"
.LASF60:
	.string	"__owner"
.LASF98:
	.string	"LPR_cond"
.LASF132:
	.string	"entrances"
.LASF44:
	.string	"_IO_wide_data"
.LASF91:
	.string	"__environ"
.LASF102:
	.string	"BOOM_status"
.LASF80:
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
.LASF83:
	.string	"pthread_mutex_t"
.LASF129:
	.string	"shared_mem_init"
.LASF58:
	.string	"__lock"
.LASF74:
	.string	"__g_refs"
.LASF2:
	.string	"unsigned char"
.LASF101:
	.string	"BOOM_cond"
.LASF85:
	.string	"__tzname"
.LASF17:
	.string	"_IO_write_ptr"
.LASF69:
	.string	"__wseq32"
.LASF73:
	.string	"__pthread_cond_s"
.LASF133:
	.string	"GNU C17 8.3.0 -mtune=generic -march=x86-64 -g"
.LASF78:
	.string	"__g_signals"
.LASF34:
	.string	"_codecvt"
.LASF89:
	.string	"daylight"
.LASF66:
	.string	"__low"
.LASF9:
	.string	"__off_t"
.LASF4:
	.string	"signed char"
.LASF115:
	.string	"Shm_Carpark"
.LASF3:
	.string	"short unsigned int"
.LASF131:
	.string	"main"
.LASF106:
	.string	"Enter_t"
.LASF76:
	.string	"__g1_orig_size"
.LASF82:
	.string	"__align"
.LASF25:
	.string	"_chain"
.LASF107:
	.string	"Exit"
.LASF41:
	.string	"FILE"
.LASF100:
	.string	"BOOM_mutex"
.LASF27:
	.string	"_flags2"
.LASF81:
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
