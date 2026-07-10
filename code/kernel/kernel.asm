
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	84813103          	ld	sp,-1976(sp) # 80007848 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd867>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d6078793          	addi	a5,a5,-672 # 80000de0 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	0ea020ef          	jal	ra,800021f4 <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71c000ef          	jal	ra,80000834 <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7159                	addi	sp,sp,-112
    8000014e:	f486                	sd	ra,104(sp)
    80000150:	f0a2                	sd	s0,96(sp)
    80000152:	eca6                	sd	s1,88(sp)
    80000154:	e8ca                	sd	s2,80(sp)
    80000156:	e4ce                	sd	s3,72(sp)
    80000158:	e0d2                	sd	s4,64(sp)
    8000015a:	fc56                	sd	s5,56(sp)
    8000015c:	f85a                	sd	s6,48(sp)
    8000015e:	f45e                	sd	s7,40(sp)
    80000160:	f062                	sd	s8,32(sp)
    80000162:	ec66                	sd	s9,24(sp)
    80000164:	e86a                	sd	s10,16(sp)
    80000166:	1880                	addi	s0,sp,112
    80000168:	8aaa                	mv	s5,a0
    8000016a:	8a2e                	mv	s4,a1
    8000016c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000016e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000172:	0000f517          	auipc	a0,0xf
    80000176:	71e50513          	addi	a0,a0,1822 # 8000f890 <cons>
    8000017a:	1f1000ef          	jal	ra,80000b6a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	71248493          	addi	s1,s1,1810 # 8000f890 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	7a290913          	addi	s2,s2,1954 # 8000f928 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000018e:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000190:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000192:	4ca9                	li	s9,10
  while(n > 0){
    80000194:	07305363          	blez	s3,800001fa <consoleread+0xae>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	02f71163          	bne	a4,a5,800001c2 <consoleread+0x76>
      if(killed(myproc())){
    800001a4:	65e010ef          	jal	ra,80001802 <myproc>
    800001a8:	6df010ef          	jal	ra,80002086 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	49d010ef          	jal	ra,80001e4e <sleep>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	fef703e3          	beq	a4,a5,800001a4 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c2:	0017871b          	addiw	a4,a5,1
    800001c6:	08e4ac23          	sw	a4,152(s1)
    800001ca:	07f7f713          	andi	a4,a5,127
    800001ce:	9726                	add	a4,a4,s1
    800001d0:	01874703          	lbu	a4,24(a4)
    800001d4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001d8:	057d0f63          	beq	s10,s7,80000236 <consoleread+0xea>
    cbuf = c;
    800001dc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e0:	4685                	li	a3,1
    800001e2:	f9f40613          	addi	a2,s0,-97
    800001e6:	85d2                	mv	a1,s4
    800001e8:	8556                	mv	a0,s5
    800001ea:	7c1010ef          	jal	ra,800021aa <either_copyout>
    800001ee:	01850663          	beq	a0,s8,800001fa <consoleread+0xae>
    dst++;
    800001f2:	0a05                	addi	s4,s4,1
    --n;
    800001f4:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001f6:	f99d1fe3          	bne	s10,s9,80000194 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fa:	0000f517          	auipc	a0,0xf
    800001fe:	69650513          	addi	a0,a0,1686 # 8000f890 <cons>
    80000202:	201000ef          	jal	ra,80000c02 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	68450513          	addi	a0,a0,1668 # 8000f890 <cons>
    80000214:	1ef000ef          	jal	ra,80000c02 <release>
        return -1;
    80000218:	557d                	li	a0,-1
}
    8000021a:	70a6                	ld	ra,104(sp)
    8000021c:	7406                	ld	s0,96(sp)
    8000021e:	64e6                	ld	s1,88(sp)
    80000220:	6946                	ld	s2,80(sp)
    80000222:	69a6                	ld	s3,72(sp)
    80000224:	6a06                	ld	s4,64(sp)
    80000226:	7ae2                	ld	s5,56(sp)
    80000228:	7b42                	ld	s6,48(sp)
    8000022a:	7ba2                	ld	s7,40(sp)
    8000022c:	7c02                	ld	s8,32(sp)
    8000022e:	6ce2                	ld	s9,24(sp)
    80000230:	6d42                	ld	s10,16(sp)
    80000232:	6165                	addi	sp,sp,112
    80000234:	8082                	ret
      if(n < target){
    80000236:	0009871b          	sext.w	a4,s3
    8000023a:	fd6770e3          	bgeu	a4,s6,800001fa <consoleread+0xae>
        cons.r--;
    8000023e:	0000f717          	auipc	a4,0xf
    80000242:	6ef72523          	sw	a5,1770(a4) # 8000f928 <cons+0x98>
    80000246:	bf55                	j	800001fa <consoleread+0xae>

0000000080000248 <consputc>:
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000250:	10000793          	li	a5,256
    80000254:	00f50863          	beq	a0,a5,80000264 <consputc+0x1c>
    uartputc_sync(c);
    80000258:	67c000ef          	jal	ra,800008d4 <uartputc_sync>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000264:	4521                	li	a0,8
    80000266:	66e000ef          	jal	ra,800008d4 <uartputc_sync>
    8000026a:	02000513          	li	a0,32
    8000026e:	666000ef          	jal	ra,800008d4 <uartputc_sync>
    80000272:	4521                	li	a0,8
    80000274:	660000ef          	jal	ra,800008d4 <uartputc_sync>
    80000278:	b7d5                	j	8000025c <consputc+0x14>

000000008000027a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000027a:	1101                	addi	sp,sp,-32
    8000027c:	ec06                	sd	ra,24(sp)
    8000027e:	e822                	sd	s0,16(sp)
    80000280:	e426                	sd	s1,8(sp)
    80000282:	e04a                	sd	s2,0(sp)
    80000284:	1000                	addi	s0,sp,32
    80000286:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000288:	0000f517          	auipc	a0,0xf
    8000028c:	60850513          	addi	a0,a0,1544 # 8000f890 <cons>
    80000290:	0db000ef          	jal	ra,80000b6a <acquire>

  switch(c){
    80000294:	47d5                	li	a5,21
    80000296:	0af48063          	beq	s1,a5,80000336 <consoleintr+0xbc>
    8000029a:	0297c663          	blt	a5,s1,800002c6 <consoleintr+0x4c>
    8000029e:	47a1                	li	a5,8
    800002a0:	0cf48f63          	beq	s1,a5,8000037e <consoleintr+0x104>
    800002a4:	47c1                	li	a5,16
    800002a6:	10f49063          	bne	s1,a5,800003a6 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002aa:	795010ef          	jal	ra,8000223e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	5e250513          	addi	a0,a0,1506 # 8000f890 <cons>
    800002b6:	14d000ef          	jal	ra,80000c02 <release>
}
    800002ba:	60e2                	ld	ra,24(sp)
    800002bc:	6442                	ld	s0,16(sp)
    800002be:	64a2                	ld	s1,8(sp)
    800002c0:	6902                	ld	s2,0(sp)
    800002c2:	6105                	addi	sp,sp,32
    800002c4:	8082                	ret
  switch(c){
    800002c6:	07f00793          	li	a5,127
    800002ca:	0af48a63          	beq	s1,a5,8000037e <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ce:	0000f717          	auipc	a4,0xf
    800002d2:	5c270713          	addi	a4,a4,1474 # 8000f890 <cons>
    800002d6:	0a072783          	lw	a5,160(a4)
    800002da:	09872703          	lw	a4,152(a4)
    800002de:	9f99                	subw	a5,a5,a4
    800002e0:	07f00713          	li	a4,127
    800002e4:	fcf765e3          	bltu	a4,a5,800002ae <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002e8:	47b5                	li	a5,13
    800002ea:	0cf48163          	beq	s1,a5,800003ac <consoleintr+0x132>
      consputc(c);
    800002ee:	8526                	mv	a0,s1
    800002f0:	f59ff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f4:	0000f797          	auipc	a5,0xf
    800002f8:	59c78793          	addi	a5,a5,1436 # 8000f890 <cons>
    800002fc:	0a07a683          	lw	a3,160(a5)
    80000300:	0016871b          	addiw	a4,a3,1
    80000304:	0007061b          	sext.w	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0af48f63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    8000031c:	4791                	li	a5,4
    8000031e:	0af48c63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	6067a783          	lw	a5,1542(a5) # 8000f928 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	55a70713          	addi	a4,a4,1370 # 8000f890 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	54a48493          	addi	s1,s1,1354 # 8000f890 <cons>
    while(cons.e != cons.w &&
    8000034e:	4929                	li	s2,10
    80000350:	f4f70fe3          	beq	a4,a5,800002ae <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	07f7f713          	andi	a4,a5,127
    8000035a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000035c:	01874703          	lbu	a4,24(a4)
    80000360:	f52707e3          	beq	a4,s2,800002ae <consoleintr+0x34>
      cons.e--;
    80000364:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000368:	10000513          	li	a0,256
    8000036c:	eddff0ef          	jal	ra,80000248 <consputc>
    while(cons.e != cons.w &&
    80000370:	0a04a783          	lw	a5,160(s1)
    80000374:	09c4a703          	lw	a4,156(s1)
    80000378:	fcf71ee3          	bne	a4,a5,80000354 <consoleintr+0xda>
    8000037c:	bf0d                	j	800002ae <consoleintr+0x34>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	51270713          	addi	a4,a4,1298 # 8000f890 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	58f72e23          	sw	a5,1436(a4) # 8000f930 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea9ff0ef          	jal	ra,80000248 <consputc>
    800003a4:	b729                	j	800002ae <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	f00484e3          	beqz	s1,800002ae <consoleintr+0x34>
    800003aa:	b715                	j	800002ce <consoleintr+0x54>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e9bff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	4de78793          	addi	a5,a5,1246 # 8000f890 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	54c7ab23          	sw	a2,1366(a5) # 8000f92c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	54a50513          	addi	a0,a0,1354 # 8000f928 <cons+0x98>
    800003e6:	2b5010ef          	jal	ra,80001e9a <wakeup>
    800003ea:	b5d1                	j	800002ae <consoleintr+0x34>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80007010 <etext+0x10>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	49450513          	addi	a0,a0,1172 # 8000f890 <cons>
    80000404:	6e6000ef          	jal	ra,80000aea <initlock>

  uartinit();
    80000408:	3e0000ef          	jal	ra,800007e8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	9f478793          	addi	a5,a5,-1548 # 8001fe00 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d3870713          	addi	a4,a4,-712 # 8000014c <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	f426                	sd	s1,40(sp)
    80000438:	f04a                	sd	s2,32(sp)
    8000043a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000043c:	c219                	beqz	a2,80000442 <printint+0x12>
    8000043e:	06054e63          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000442:	4881                	li	a7,0
    80000444:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000448:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000044a:	00007617          	auipc	a2,0x7
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80007038 <digits>
    80000452:	883e                	mv	a6,a5
    80000454:	2785                	addiw	a5,a5,1
    80000456:	02b57733          	remu	a4,a0,a1
    8000045a:	9732                	add	a4,a4,a2
    8000045c:	00074703          	lbu	a4,0(a4)
    80000460:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000464:	872a                	mv	a4,a0
    80000466:	02b55533          	divu	a0,a0,a1
    8000046a:	0685                	addi	a3,a3,1
    8000046c:	feb773e3          	bgeu	a4,a1,80000452 <printint+0x22>

  if(sign)
    80000470:	00088a63          	beqz	a7,80000484 <printint+0x54>
    buf[i++] = '-';
    80000474:	1781                	addi	a5,a5,-32
    80000476:	97a2                	add	a5,a5,s0
    80000478:	02d00713          	li	a4,45
    8000047c:	fee78423          	sb	a4,-24(a5)
    80000480:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000484:	02f05563          	blez	a5,800004ae <printint+0x7e>
    80000488:	fc840713          	addi	a4,s0,-56
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	da5ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
}
    800004ae:	70e2                	ld	ra,56(sp)
    800004b0:	7442                	ld	s0,48(sp)
    800004b2:	74a2                	ld	s1,40(sp)
    800004b4:	7902                	ld	s2,32(sp)
    800004b6:	6121                	addi	sp,sp,64
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b751                	j	80000444 <printint+0x14>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7131                	addi	sp,sp,-192
    800004c4:	fc86                	sd	ra,120(sp)
    800004c6:	f8a2                	sd	s0,112(sp)
    800004c8:	f4a6                	sd	s1,104(sp)
    800004ca:	f0ca                	sd	s2,96(sp)
    800004cc:	ecce                	sd	s3,88(sp)
    800004ce:	e8d2                	sd	s4,80(sp)
    800004d0:	e4d6                	sd	s5,72(sp)
    800004d2:	e0da                	sd	s6,64(sp)
    800004d4:	fc5e                	sd	s7,56(sp)
    800004d6:	f862                	sd	s8,48(sp)
    800004d8:	f466                	sd	s9,40(sp)
    800004da:	f06a                	sd	s10,32(sp)
    800004dc:	ec6e                	sd	s11,24(sp)
    800004de:	0100                	addi	s0,sp,128
    800004e0:	8a2a                	mv	s4,a0
    800004e2:	e40c                	sd	a1,8(s0)
    800004e4:	e810                	sd	a2,16(s0)
    800004e6:	ec14                	sd	a3,24(s0)
    800004e8:	f018                	sd	a4,32(s0)
    800004ea:	f41c                	sd	a5,40(s0)
    800004ec:	03043823          	sd	a6,48(s0)
    800004f0:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f4:	00007797          	auipc	a5,0x7
    800004f8:	3707a783          	lw	a5,880(a5) # 80007864 <panicking>
    800004fc:	cb9d                	beqz	a5,80000532 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fe:	00840793          	addi	a5,s0,8
    80000502:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000506:	000a4503          	lbu	a0,0(s4)
    8000050a:	24050363          	beqz	a0,80000750 <printf+0x28e>
    8000050e:	4981                	li	s3,0
    if(cx != '%'){
    80000510:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000514:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000518:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000520:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000524:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000528:	00007b97          	auipc	s7,0x7
    8000052c:	b10b8b93          	addi	s7,s7,-1264 # 80007038 <digits>
    80000530:	a01d                	j	80000556 <printf+0x94>
    acquire(&pr.lock);
    80000532:	0000f517          	auipc	a0,0xf
    80000536:	40650513          	addi	a0,a0,1030 # 8000f938 <pr>
    8000053a:	630000ef          	jal	ra,80000b6a <acquire>
    8000053e:	b7c1                	j	800004fe <printf+0x3c>
      consputc(cx);
    80000540:	d09ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000544:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000546:	0014899b          	addiw	s3,s1,1
    8000054a:	013a07b3          	add	a5,s4,s3
    8000054e:	0007c503          	lbu	a0,0(a5)
    80000552:	1e050f63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    80000556:	ff5515e3          	bne	a0,s5,80000540 <printf+0x7e>
    i++;
    8000055a:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000055e:	009a07b3          	add	a5,s4,s1
    80000562:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000566:	1e090563          	beqz	s2,80000750 <printf+0x28e>
    8000056a:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000056e:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000570:	c789                	beqz	a5,8000057a <printf+0xb8>
    80000572:	009a0733          	add	a4,s4,s1
    80000576:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057a:	03690863          	beq	s2,s6,800005aa <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    8000057e:	05890263          	beq	s2,s8,800005c2 <printf+0x100>
    } else if(c0 == 'u'){
    80000582:	0d990163          	beq	s2,s9,80000644 <printf+0x182>
    } else if(c0 == 'x'){
    80000586:	11a90863          	beq	s2,s10,80000696 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058a:	15b90163          	beq	s2,s11,800006cc <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    8000058e:	06300793          	li	a5,99
    80000592:	16f90963          	beq	s2,a5,80000704 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90f63          	beq	s2,a5,80000718 <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	03591c63          	bne	s2,s5,800005d6 <printf+0x114>
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	ca5ff0ef          	jal	ra,80000248 <consputc>
    800005a8:	bf79                	j	80000546 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005aa:	f8843783          	ld	a5,-120(s0)
    800005ae:	00878713          	addi	a4,a5,8
    800005b2:	f8e43423          	sd	a4,-120(s0)
    800005b6:	4605                	li	a2,1
    800005b8:	45a9                	li	a1,10
    800005ba:	4388                	lw	a0,0(a5)
    800005bc:	e75ff0ef          	jal	ra,80000430 <printint>
    800005c0:	b759                	j	80000546 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c2:	03678163          	beq	a5,s6,800005e4 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c6:	03878d63          	beq	a5,s8,80000600 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005ca:	09978a63          	beq	a5,s9,8000065e <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005ce:	03878b63          	beq	a5,s8,80000604 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d2:	0da78f63          	beq	a5,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d6:	8556                	mv	a0,s5
    800005d8:	c71ff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005dc:	854a                	mv	a0,s2
    800005de:	c6bff0ef          	jal	ra,80000248 <consputc>
    800005e2:	b795                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e4:	f8843783          	ld	a5,-120(s0)
    800005e8:	00878713          	addi	a4,a5,8
    800005ec:	f8e43423          	sd	a4,-120(s0)
    800005f0:	4605                	li	a2,1
    800005f2:	45a9                	li	a1,10
    800005f4:	6388                	ld	a0,0(a5)
    800005f6:	e3bff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fa:	0029849b          	addiw	s1,s3,2
    800005fe:	b7a1                	j	80000546 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000600:	03668463          	beq	a3,s6,80000628 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000604:	07968b63          	beq	a3,s9,8000067a <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000608:	fda697e3          	bne	a3,s10,800005d6 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	45c1                	li	a1,16
    8000061c:	6388                	ld	a0,0(a5)
    8000061e:	e13ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000622:	0039849b          	addiw	s1,s3,3
    80000626:	b705                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4605                	li	a2,1
    80000636:	45a9                	li	a1,10
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b711                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45a9                	li	a1,10
    80000654:	0007e503          	lwu	a0,0(a5)
    80000658:	dd9ff0ef          	jal	ra,80000430 <printint>
    8000065c:	b5ed                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45a9                	li	a1,10
    8000066e:	6388                	ld	a0,0(a5)
    80000670:	dc1ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000674:	0029849b          	addiw	s1,s3,2
    80000678:	b5f9                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4601                	li	a2,0
    80000688:	45a9                	li	a1,10
    8000068a:	6388                	ld	a0,0(a5)
    8000068c:	da5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000690:	0039849b          	addiw	s1,s3,3
    80000694:	bd4d                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45c1                	li	a1,16
    800006a6:	0007e503          	lwu	a0,0(a5)
    800006aa:	d87ff0ef          	jal	ra,80000430 <printint>
    800006ae:	bd61                	j	80000546 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	6388                	ld	a0,0(a5)
    800006c2:	d6fff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c6:	0029849b          	addiw	s1,s3,2
    800006ca:	bdb5                	j	80000546 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006dc:	03000513          	li	a0,48
    800006e0:	b69ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e4:	856a                	mv	a0,s10
    800006e6:	b63ff0ef          	jal	ra,80000248 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	03c9d793          	srli	a5,s3,0x3c
    800006f0:	97de                	add	a5,a5,s7
    800006f2:	0007c503          	lbu	a0,0(a5)
    800006f6:	b53ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fa:	0992                	slli	s3,s3,0x4
    800006fc:	397d                	addiw	s2,s2,-1
    800006fe:	fe0917e3          	bnez	s2,800006ec <printf+0x22a>
    80000702:	b591                	j	80000546 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b37ff0ef          	jal	ra,80000248 <consputc>
    80000716:	bd05                	j	80000546 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x280>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e0050be3          	beqz	a0,80000546 <printf+0x84>
        consputc(*s);
    80000734:	b15ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x272>
    80000740:	b519                	j	80000546 <printf+0x84>
        s = "(null)";
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8d690913          	addi	s2,s2,-1834 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000750:	00007797          	auipc	a5,0x7
    80000754:	1147a783          	lw	a5,276(a5) # 80007864 <panicking>
    80000758:	c38d                	beqz	a5,8000077a <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075a:	4501                	li	a0,0
    8000075c:	70e6                	ld	ra,120(sp)
    8000075e:	7446                	ld	s0,112(sp)
    80000760:	74a6                	ld	s1,104(sp)
    80000762:	7906                	ld	s2,96(sp)
    80000764:	69e6                	ld	s3,88(sp)
    80000766:	6a46                	ld	s4,80(sp)
    80000768:	6aa6                	ld	s5,72(sp)
    8000076a:	6b06                	ld	s6,64(sp)
    8000076c:	7be2                	ld	s7,56(sp)
    8000076e:	7c42                	ld	s8,48(sp)
    80000770:	7ca2                	ld	s9,40(sp)
    80000772:	7d02                	ld	s10,32(sp)
    80000774:	6de2                	ld	s11,24(sp)
    80000776:	6129                	addi	sp,sp,192
    80000778:	8082                	ret
    release(&pr.lock);
    8000077a:	0000f517          	auipc	a0,0xf
    8000077e:	1be50513          	addi	a0,a0,446 # 8000f938 <pr>
    80000782:	480000ef          	jal	ra,80000c02 <release>
  return 0;
    80000786:	bfd1                	j	8000075a <printf+0x298>

0000000080000788 <panic>:

void
panic(char *s)
{
    80000788:	1101                	addi	sp,sp,-32
    8000078a:	ec06                	sd	ra,24(sp)
    8000078c:	e822                	sd	s0,16(sp)
    8000078e:	e426                	sd	s1,8(sp)
    80000790:	e04a                	sd	s2,0(sp)
    80000792:	1000                	addi	s0,sp,32
    80000794:	84aa                	mv	s1,a0
  panicking = 1;
    80000796:	4905                	li	s2,1
    80000798:	00007797          	auipc	a5,0x7
    8000079c:	0d27a623          	sw	s2,204(a5) # 80007864 <panicking>
  printf("panic: ");
    800007a0:	00007517          	auipc	a0,0x7
    800007a4:	88050513          	addi	a0,a0,-1920 # 80007020 <etext+0x20>
    800007a8:	d1bff0ef          	jal	ra,800004c2 <printf>
  printf("%s\n", s);
    800007ac:	85a6                	mv	a1,s1
    800007ae:	00007517          	auipc	a0,0x7
    800007b2:	87a50513          	addi	a0,a0,-1926 # 80007028 <etext+0x28>
    800007b6:	d0dff0ef          	jal	ra,800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007ba:	00007797          	auipc	a5,0x7
    800007be:	0b27a323          	sw	s2,166(a5) # 80007860 <panicked>
  for(;;)
    800007c2:	a001                	j	800007c2 <panic+0x3a>

00000000800007c4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c4:	1141                	addi	sp,sp,-16
    800007c6:	e406                	sd	ra,8(sp)
    800007c8:	e022                	sd	s0,0(sp)
    800007ca:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007cc:	00007597          	auipc	a1,0x7
    800007d0:	86458593          	addi	a1,a1,-1948 # 80007030 <etext+0x30>
    800007d4:	0000f517          	auipc	a0,0xf
    800007d8:	16450513          	addi	a0,a0,356 # 8000f938 <pr>
    800007dc:	30e000ef          	jal	ra,80000aea <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007e8:	1141                	addi	sp,sp,-16
    800007ea:	e406                	sd	ra,8(sp)
    800007ec:	e022                	sd	s0,0(sp)
    800007ee:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f0:	100007b7          	lui	a5,0x10000
    800007f4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f8:	f8000713          	li	a4,-128
    800007fc:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	470d                	li	a4,3
    80000802:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000806:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000080e:	469d                	li	a3,7
    80000810:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000814:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    80000818:	00007597          	auipc	a1,0x7
    8000081c:	83858593          	addi	a1,a1,-1992 # 80007050 <digits+0x18>
    80000820:	0000f517          	auipc	a0,0xf
    80000824:	13050513          	addi	a0,a0,304 # 8000f950 <tx_lock>
    80000828:	2c2000ef          	jal	ra,80000aea <initlock>
}
    8000082c:	60a2                	ld	ra,8(sp)
    8000082e:	6402                	ld	s0,0(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret

0000000080000834 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000834:	715d                	addi	sp,sp,-80
    80000836:	e486                	sd	ra,72(sp)
    80000838:	e0a2                	sd	s0,64(sp)
    8000083a:	fc26                	sd	s1,56(sp)
    8000083c:	f84a                	sd	s2,48(sp)
    8000083e:	f44e                	sd	s3,40(sp)
    80000840:	f052                	sd	s4,32(sp)
    80000842:	ec56                	sd	s5,24(sp)
    80000844:	e85a                	sd	s6,16(sp)
    80000846:	e45e                	sd	s7,8(sp)
    80000848:	0880                	addi	s0,sp,80
    8000084a:	84aa                	mv	s1,a0
    8000084c:	892e                	mv	s2,a1
  acquire(&tx_lock);
    8000084e:	0000f517          	auipc	a0,0xf
    80000852:	10250513          	addi	a0,a0,258 # 8000f950 <tx_lock>
    80000856:	314000ef          	jal	ra,80000b6a <acquire>

  int i = 0;
  while(i < n){ 
    8000085a:	05205c63          	blez	s2,800008b2 <uartwrite+0x7e>
    8000085e:	8a26                	mv	s4,s1
    80000860:	0485                	addi	s1,s1,1
    80000862:	fff9079b          	addiw	a5,s2,-1
    80000866:	1782                	slli	a5,a5,0x20
    80000868:	9381                	srli	a5,a5,0x20
    8000086a:	00f48ab3          	add	s5,s1,a5
    while(tx_busy != 0){
    8000086e:	00007497          	auipc	s1,0x7
    80000872:	ffe48493          	addi	s1,s1,-2 # 8000786c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0da98993          	addi	s3,s3,218 # 8000f950 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	fea90913          	addi	s2,s2,-22 # 80007868 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x78>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	5bc010ef          	jal	ra,80001e4e <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x5a>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7e>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x5a>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x66>
  }

  release(&tx_lock);
    800008b2:	0000f517          	auipc	a0,0xf
    800008b6:	09e50513          	addi	a0,a0,158 # 8000f950 <tx_lock>
    800008ba:	348000ef          	jal	ra,80000c02 <release>
}
    800008be:	60a6                	ld	ra,72(sp)
    800008c0:	6406                	ld	s0,64(sp)
    800008c2:	74e2                	ld	s1,56(sp)
    800008c4:	7942                	ld	s2,48(sp)
    800008c6:	79a2                	ld	s3,40(sp)
    800008c8:	7a02                	ld	s4,32(sp)
    800008ca:	6ae2                	ld	s5,24(sp)
    800008cc:	6b42                	ld	s6,16(sp)
    800008ce:	6ba2                	ld	s7,8(sp)
    800008d0:	6161                	addi	sp,sp,80
    800008d2:	8082                	ret

00000000800008d4 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008d4:	1101                	addi	sp,sp,-32
    800008d6:	ec06                	sd	ra,24(sp)
    800008d8:	e822                	sd	s0,16(sp)
    800008da:	e426                	sd	s1,8(sp)
    800008dc:	1000                	addi	s0,sp,32
    800008de:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e0:	00007797          	auipc	a5,0x7
    800008e4:	f847a783          	lw	a5,-124(a5) # 80007864 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f767a783          	lw	a5,-138(a5) # 80007860 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800008f6:	c789                	beqz	a5,80000900 <uartputc_sync+0x2c>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc_sync+0x24>
    push_off();
    800008fa:	230000ef          	jal	ra,80000b2a <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	zext.b	a0,s1
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	f4e7a783          	lw	a5,-178(a5) # 80007864 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	284000ef          	jal	ra,80000bae <pop_off>
}
    8000092e:	bfcd                	j	80000920 <uartputc_sync+0x4c>

0000000080000930 <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e422                	sd	s0,8(sp)
    80000934:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000936:	100007b7          	lui	a5,0x10000
    8000093a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000093e:	8b85                	andi	a5,a5,1
    80000940:	cb81                	beqz	a5,80000950 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000094a:	6422                	ld	s0,8(sp)
    8000094c:	0141                	addi	sp,sp,16
    8000094e:	8082                	ret
    return -1;
    80000950:	557d                	li	a0,-1
    80000952:	bfe5                	j	8000094a <uartgetc+0x1a>

0000000080000954 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000954:	1101                	addi	sp,sp,-32
    80000956:	ec06                	sd	ra,24(sp)
    80000958:	e822                	sd	s0,16(sp)
    8000095a:	e426                	sd	s1,8(sp)
    8000095c:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    8000095e:	100004b7          	lui	s1,0x10000
    80000962:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000966:	0000f517          	auipc	a0,0xf
    8000096a:	fea50513          	addi	a0,a0,-22 # 8000f950 <tx_lock>
    8000096e:	1fc000ef          	jal	ra,80000b6a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000972:	0054c783          	lbu	a5,5(s1)
    80000976:	0207f793          	andi	a5,a5,32
    8000097a:	eb89                	bnez	a5,8000098c <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    8000097c:	0000f517          	auipc	a0,0xf
    80000980:	fd450513          	addi	a0,a0,-44 # 8000f950 <tx_lock>
    80000984:	27e000ef          	jal	ra,80000c02 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000988:	54fd                	li	s1,-1
    8000098a:	a831                	j	800009a6 <uartintr+0x52>
    tx_busy = 0;
    8000098c:	00007797          	auipc	a5,0x7
    80000990:	ee07a023          	sw	zero,-288(a5) # 8000786c <tx_busy>
    wakeup(&tx_chan);
    80000994:	00007517          	auipc	a0,0x7
    80000998:	ed450513          	addi	a0,a0,-300 # 80007868 <tx_chan>
    8000099c:	4fe010ef          	jal	ra,80001e9a <wakeup>
    800009a0:	bff1                	j	8000097c <uartintr+0x28>
      break;
    consoleintr(c);
    800009a2:	8d9ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009a6:	f8bff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009aa:	fe951ce3          	bne	a0,s1,800009a2 <uartintr+0x4e>
  }
}
    800009ae:	60e2                	ld	ra,24(sp)
    800009b0:	6442                	ld	s0,16(sp)
    800009b2:	64a2                	ld	s1,8(sp)
    800009b4:	6105                	addi	sp,sp,32
    800009b6:	8082                	ret

00000000800009b8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009b8:	1101                	addi	sp,sp,-32
    800009ba:	ec06                	sd	ra,24(sp)
    800009bc:	e822                	sd	s0,16(sp)
    800009be:	e426                	sd	s1,8(sp)
    800009c0:	e04a                	sd	s2,0(sp)
    800009c2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009c4:	03451793          	slli	a5,a0,0x34
    800009c8:	e7a9                	bnez	a5,80000a12 <kfree+0x5a>
    800009ca:	84aa                	mv	s1,a0
    800009cc:	00020797          	auipc	a5,0x20
    800009d0:	5cc78793          	addi	a5,a5,1484 # 80020f98 <end>
    800009d4:	02f56f63          	bltu	a0,a5,80000a12 <kfree+0x5a>
    800009d8:	47c5                	li	a5,17
    800009da:	07ee                	slli	a5,a5,0x1b
    800009dc:	02f57b63          	bgeu	a0,a5,80000a12 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009e0:	6605                	lui	a2,0x1
    800009e2:	4585                	li	a1,1
    800009e4:	25a000ef          	jal	ra,80000c3e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009e8:	0000f917          	auipc	s2,0xf
    800009ec:	f8090913          	addi	s2,s2,-128 # 8000f968 <kmem>
    800009f0:	854a                	mv	a0,s2
    800009f2:	178000ef          	jal	ra,80000b6a <acquire>
  r->next = kmem.freelist;
    800009f6:	01893783          	ld	a5,24(s2)
    800009fa:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800009fc:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a00:	854a                	mv	a0,s2
    80000a02:	200000ef          	jal	ra,80000c02 <release>
}
    80000a06:	60e2                	ld	ra,24(sp)
    80000a08:	6442                	ld	s0,16(sp)
    80000a0a:	64a2                	ld	s1,8(sp)
    80000a0c:	6902                	ld	s2,0(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret
    panic("kfree");
    80000a12:	00006517          	auipc	a0,0x6
    80000a16:	64650513          	addi	a0,a0,1606 # 80007058 <digits+0x20>
    80000a1a:	d6fff0ef          	jal	ra,80000788 <panic>

0000000080000a1e <freerange>:
{
    80000a1e:	7179                	addi	sp,sp,-48
    80000a20:	f406                	sd	ra,40(sp)
    80000a22:	f022                	sd	s0,32(sp)
    80000a24:	ec26                	sd	s1,24(sp)
    80000a26:	e84a                	sd	s2,16(sp)
    80000a28:	e44e                	sd	s3,8(sp)
    80000a2a:	e052                	sd	s4,0(sp)
    80000a2c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a2e:	6785                	lui	a5,0x1
    80000a30:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a34:	00e504b3          	add	s1,a0,a4
    80000a38:	777d                	lui	a4,0xfffff
    80000a3a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a3c:	94be                	add	s1,s1,a5
    80000a3e:	0095ec63          	bltu	a1,s1,80000a56 <freerange+0x38>
    80000a42:	892e                	mv	s2,a1
    kfree(p);
    80000a44:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a46:	6985                	lui	s3,0x1
    kfree(p);
    80000a48:	01448533          	add	a0,s1,s4
    80000a4c:	f6dff0ef          	jal	ra,800009b8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a50:	94ce                	add	s1,s1,s3
    80000a52:	fe997be3          	bgeu	s2,s1,80000a48 <freerange+0x2a>
}
    80000a56:	70a2                	ld	ra,40(sp)
    80000a58:	7402                	ld	s0,32(sp)
    80000a5a:	64e2                	ld	s1,24(sp)
    80000a5c:	6942                	ld	s2,16(sp)
    80000a5e:	69a2                	ld	s3,8(sp)
    80000a60:	6a02                	ld	s4,0(sp)
    80000a62:	6145                	addi	sp,sp,48
    80000a64:	8082                	ret

0000000080000a66 <kinit>:
{
    80000a66:	1141                	addi	sp,sp,-16
    80000a68:	e406                	sd	ra,8(sp)
    80000a6a:	e022                	sd	s0,0(sp)
    80000a6c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a6e:	00006597          	auipc	a1,0x6
    80000a72:	5f258593          	addi	a1,a1,1522 # 80007060 <digits+0x28>
    80000a76:	0000f517          	auipc	a0,0xf
    80000a7a:	ef250513          	addi	a0,a0,-270 # 8000f968 <kmem>
    80000a7e:	06c000ef          	jal	ra,80000aea <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a82:	45c5                	li	a1,17
    80000a84:	05ee                	slli	a1,a1,0x1b
    80000a86:	00020517          	auipc	a0,0x20
    80000a8a:	51250513          	addi	a0,a0,1298 # 80020f98 <end>
    80000a8e:	f91ff0ef          	jal	ra,80000a1e <freerange>
}
    80000a92:	60a2                	ld	ra,8(sp)
    80000a94:	6402                	ld	s0,0(sp)
    80000a96:	0141                	addi	sp,sp,16
    80000a98:	8082                	ret

0000000080000a9a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a9a:	1101                	addi	sp,sp,-32
    80000a9c:	ec06                	sd	ra,24(sp)
    80000a9e:	e822                	sd	s0,16(sp)
    80000aa0:	e426                	sd	s1,8(sp)
    80000aa2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aa4:	0000f497          	auipc	s1,0xf
    80000aa8:	ec448493          	addi	s1,s1,-316 # 8000f968 <kmem>
    80000aac:	8526                	mv	a0,s1
    80000aae:	0bc000ef          	jal	ra,80000b6a <acquire>
  r = kmem.freelist;
    80000ab2:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab4:	c485                	beqz	s1,80000adc <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab6:	609c                	ld	a5,0(s1)
    80000ab8:	0000f517          	auipc	a0,0xf
    80000abc:	eb050513          	addi	a0,a0,-336 # 8000f968 <kmem>
    80000ac0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ac2:	140000ef          	jal	ra,80000c02 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ac6:	6605                	lui	a2,0x1
    80000ac8:	4595                	li	a1,5
    80000aca:	8526                	mv	a0,s1
    80000acc:	172000ef          	jal	ra,80000c3e <memset>
  return (void*)r;
}
    80000ad0:	8526                	mv	a0,s1
    80000ad2:	60e2                	ld	ra,24(sp)
    80000ad4:	6442                	ld	s0,16(sp)
    80000ad6:	64a2                	ld	s1,8(sp)
    80000ad8:	6105                	addi	sp,sp,32
    80000ada:	8082                	ret
  release(&kmem.lock);
    80000adc:	0000f517          	auipc	a0,0xf
    80000ae0:	e8c50513          	addi	a0,a0,-372 # 8000f968 <kmem>
    80000ae4:	11e000ef          	jal	ra,80000c02 <release>
  if(r)
    80000ae8:	b7e5                	j	80000ad0 <kalloc+0x36>

0000000080000aea <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000aea:	1141                	addi	sp,sp,-16
    80000aec:	e422                	sd	s0,8(sp)
    80000aee:	0800                	addi	s0,sp,16
  lk->name = name;
    80000af0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000af2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000af6:	00053823          	sd	zero,16(a0)
}
    80000afa:	6422                	ld	s0,8(sp)
    80000afc:	0141                	addi	sp,sp,16
    80000afe:	8082                	ret

0000000080000b00 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b00:	411c                	lw	a5,0(a0)
    80000b02:	e399                	bnez	a5,80000b08 <holding+0x8>
    80000b04:	4501                	li	a0,0
  return r;
}
    80000b06:	8082                	ret
{
    80000b08:	1101                	addi	sp,sp,-32
    80000b0a:	ec06                	sd	ra,24(sp)
    80000b0c:	e822                	sd	s0,16(sp)
    80000b0e:	e426                	sd	s1,8(sp)
    80000b10:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b12:	6904                	ld	s1,16(a0)
    80000b14:	4d3000ef          	jal	ra,800017e6 <mycpu>
    80000b18:	40a48533          	sub	a0,s1,a0
    80000b1c:	00153513          	seqz	a0,a0
}
    80000b20:	60e2                	ld	ra,24(sp)
    80000b22:	6442                	ld	s0,16(sp)
    80000b24:	64a2                	ld	s1,8(sp)
    80000b26:	6105                	addi	sp,sp,32
    80000b28:	8082                	ret

0000000080000b2a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b34:	100024f3          	csrr	s1,sstatus
    80000b38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b3c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b3e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b42:	4a5000ef          	jal	ra,800017e6 <mycpu>
    80000b46:	5d3c                	lw	a5,120(a0)
    80000b48:	cb99                	beqz	a5,80000b5e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4a:	49d000ef          	jal	ra,800017e6 <mycpu>
    80000b4e:	5d3c                	lw	a5,120(a0)
    80000b50:	2785                	addiw	a5,a5,1
    80000b52:	dd3c                	sw	a5,120(a0)
}
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	64a2                	ld	s1,8(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
    mycpu()->intena = old;
    80000b5e:	489000ef          	jal	ra,800017e6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b62:	8085                	srli	s1,s1,0x1
    80000b64:	8885                	andi	s1,s1,1
    80000b66:	dd64                	sw	s1,124(a0)
    80000b68:	b7cd                	j	80000b4a <push_off+0x20>

0000000080000b6a <acquire>:
{
    80000b6a:	1101                	addi	sp,sp,-32
    80000b6c:	ec06                	sd	ra,24(sp)
    80000b6e:	e822                	sd	s0,16(sp)
    80000b70:	e426                	sd	s1,8(sp)
    80000b72:	1000                	addi	s0,sp,32
    80000b74:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b76:	fb5ff0ef          	jal	ra,80000b2a <push_off>
  if(holding(lk))
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	f85ff0ef          	jal	ra,80000b00 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b80:	4705                	li	a4,1
  if(holding(lk))
    80000b82:	e105                	bnez	a0,80000ba2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b84:	87ba                	mv	a5,a4
    80000b86:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b8a:	2781                	sext.w	a5,a5
    80000b8c:	ffe5                	bnez	a5,80000b84 <acquire+0x1a>
  __sync_synchronize();
    80000b8e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b92:	455000ef          	jal	ra,800017e6 <mycpu>
    80000b96:	e888                	sd	a0,16(s1)
}
    80000b98:	60e2                	ld	ra,24(sp)
    80000b9a:	6442                	ld	s0,16(sp)
    80000b9c:	64a2                	ld	s1,8(sp)
    80000b9e:	6105                	addi	sp,sp,32
    80000ba0:	8082                	ret
    panic("acquire");
    80000ba2:	00006517          	auipc	a0,0x6
    80000ba6:	4c650513          	addi	a0,a0,1222 # 80007068 <digits+0x30>
    80000baa:	bdfff0ef          	jal	ra,80000788 <panic>

0000000080000bae <pop_off>:

void
pop_off(void)
{
    80000bae:	1141                	addi	sp,sp,-16
    80000bb0:	e406                	sd	ra,8(sp)
    80000bb2:	e022                	sd	s0,0(sp)
    80000bb4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bb6:	431000ef          	jal	ra,800017e6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bbe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bc0:	e78d                	bnez	a5,80000bea <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	02f05963          	blez	a5,80000bf6 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bc8:	37fd                	addiw	a5,a5,-1
    80000bca:	0007871b          	sext.w	a4,a5
    80000bce:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bd0:	eb09                	bnez	a4,80000be2 <pop_off+0x34>
    80000bd2:	5d7c                	lw	a5,124(a0)
    80000bd4:	c799                	beqz	a5,80000be2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bde:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000be2:	60a2                	ld	ra,8(sp)
    80000be4:	6402                	ld	s0,0(sp)
    80000be6:	0141                	addi	sp,sp,16
    80000be8:	8082                	ret
    panic("pop_off - interruptible");
    80000bea:	00006517          	auipc	a0,0x6
    80000bee:	48650513          	addi	a0,a0,1158 # 80007070 <digits+0x38>
    80000bf2:	b97ff0ef          	jal	ra,80000788 <panic>
    panic("pop_off");
    80000bf6:	00006517          	auipc	a0,0x6
    80000bfa:	49250513          	addi	a0,a0,1170 # 80007088 <digits+0x50>
    80000bfe:	b8bff0ef          	jal	ra,80000788 <panic>

0000000080000c02 <release>:
{
    80000c02:	1101                	addi	sp,sp,-32
    80000c04:	ec06                	sd	ra,24(sp)
    80000c06:	e822                	sd	s0,16(sp)
    80000c08:	e426                	sd	s1,8(sp)
    80000c0a:	1000                	addi	s0,sp,32
    80000c0c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c0e:	ef3ff0ef          	jal	ra,80000b00 <holding>
    80000c12:	c105                	beqz	a0,80000c32 <release+0x30>
  lk->cpu = 0;
    80000c14:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c1c:	0f50000f          	fence	iorw,ow
    80000c20:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c24:	f8bff0ef          	jal	ra,80000bae <pop_off>
}
    80000c28:	60e2                	ld	ra,24(sp)
    80000c2a:	6442                	ld	s0,16(sp)
    80000c2c:	64a2                	ld	s1,8(sp)
    80000c2e:	6105                	addi	sp,sp,32
    80000c30:	8082                	ret
    panic("release");
    80000c32:	00006517          	auipc	a0,0x6
    80000c36:	45e50513          	addi	a0,a0,1118 # 80007090 <digits+0x58>
    80000c3a:	b4fff0ef          	jal	ra,80000788 <panic>

0000000080000c3e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e422                	sd	s0,8(sp)
    80000c42:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c44:	ca19                	beqz	a2,80000c5a <memset+0x1c>
    80000c46:	87aa                	mv	a5,a0
    80000c48:	1602                	slli	a2,a2,0x20
    80000c4a:	9201                	srli	a2,a2,0x20
    80000c4c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c50:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c54:	0785                	addi	a5,a5,1
    80000c56:	fee79de3          	bne	a5,a4,80000c50 <memset+0x12>
  }
  return dst;
}
    80000c5a:	6422                	ld	s0,8(sp)
    80000c5c:	0141                	addi	sp,sp,16
    80000c5e:	8082                	ret

0000000080000c60 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c60:	1141                	addi	sp,sp,-16
    80000c62:	e422                	sd	s0,8(sp)
    80000c64:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c66:	ca05                	beqz	a2,80000c96 <memcmp+0x36>
    80000c68:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c6c:	1682                	slli	a3,a3,0x20
    80000c6e:	9281                	srli	a3,a3,0x20
    80000c70:	0685                	addi	a3,a3,1
    80000c72:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c74:	00054783          	lbu	a5,0(a0)
    80000c78:	0005c703          	lbu	a4,0(a1)
    80000c7c:	00e79863          	bne	a5,a4,80000c8c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c80:	0505                	addi	a0,a0,1
    80000c82:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c84:	fed518e3          	bne	a0,a3,80000c74 <memcmp+0x14>
  }

  return 0;
    80000c88:	4501                	li	a0,0
    80000c8a:	a019                	j	80000c90 <memcmp+0x30>
      return *s1 - *s2;
    80000c8c:	40e7853b          	subw	a0,a5,a4
}
    80000c90:	6422                	ld	s0,8(sp)
    80000c92:	0141                	addi	sp,sp,16
    80000c94:	8082                	ret
  return 0;
    80000c96:	4501                	li	a0,0
    80000c98:	bfe5                	j	80000c90 <memcmp+0x30>

0000000080000c9a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c9a:	1141                	addi	sp,sp,-16
    80000c9c:	e422                	sd	s0,8(sp)
    80000c9e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ca0:	c205                	beqz	a2,80000cc0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ca2:	02a5e263          	bltu	a1,a0,80000cc6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ca6:	1602                	slli	a2,a2,0x20
    80000ca8:	9201                	srli	a2,a2,0x20
    80000caa:	00c587b3          	add	a5,a1,a2
{
    80000cae:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cb0:	0585                	addi	a1,a1,1
    80000cb2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde069>
    80000cb4:	fff5c683          	lbu	a3,-1(a1)
    80000cb8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cbc:	fef59ae3          	bne	a1,a5,80000cb0 <memmove+0x16>

  return dst;
}
    80000cc0:	6422                	ld	s0,8(sp)
    80000cc2:	0141                	addi	sp,sp,16
    80000cc4:	8082                	ret
  if(s < d && s + n > d){
    80000cc6:	02061693          	slli	a3,a2,0x20
    80000cca:	9281                	srli	a3,a3,0x20
    80000ccc:	00d58733          	add	a4,a1,a3
    80000cd0:	fce57be3          	bgeu	a0,a4,80000ca6 <memmove+0xc>
    d += n;
    80000cd4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cd6:	fff6079b          	addiw	a5,a2,-1
    80000cda:	1782                	slli	a5,a5,0x20
    80000cdc:	9381                	srli	a5,a5,0x20
    80000cde:	fff7c793          	not	a5,a5
    80000ce2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ce4:	177d                	addi	a4,a4,-1
    80000ce6:	16fd                	addi	a3,a3,-1
    80000ce8:	00074603          	lbu	a2,0(a4)
    80000cec:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000cf0:	fee79ae3          	bne	a5,a4,80000ce4 <memmove+0x4a>
    80000cf4:	b7f1                	j	80000cc0 <memmove+0x26>

0000000080000cf6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000cf6:	1141                	addi	sp,sp,-16
    80000cf8:	e406                	sd	ra,8(sp)
    80000cfa:	e022                	sd	s0,0(sp)
    80000cfc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000cfe:	f9dff0ef          	jal	ra,80000c9a <memmove>
}
    80000d02:	60a2                	ld	ra,8(sp)
    80000d04:	6402                	ld	s0,0(sp)
    80000d06:	0141                	addi	sp,sp,16
    80000d08:	8082                	ret

0000000080000d0a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d0a:	1141                	addi	sp,sp,-16
    80000d0c:	e422                	sd	s0,8(sp)
    80000d0e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d10:	ce11                	beqz	a2,80000d2c <strncmp+0x22>
    80000d12:	00054783          	lbu	a5,0(a0)
    80000d16:	cf89                	beqz	a5,80000d30 <strncmp+0x26>
    80000d18:	0005c703          	lbu	a4,0(a1)
    80000d1c:	00f71a63          	bne	a4,a5,80000d30 <strncmp+0x26>
    n--, p++, q++;
    80000d20:	367d                	addiw	a2,a2,-1
    80000d22:	0505                	addi	a0,a0,1
    80000d24:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d26:	f675                	bnez	a2,80000d12 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d28:	4501                	li	a0,0
    80000d2a:	a809                	j	80000d3c <strncmp+0x32>
    80000d2c:	4501                	li	a0,0
    80000d2e:	a039                	j	80000d3c <strncmp+0x32>
  if(n == 0)
    80000d30:	ca09                	beqz	a2,80000d42 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d32:	00054503          	lbu	a0,0(a0)
    80000d36:	0005c783          	lbu	a5,0(a1)
    80000d3a:	9d1d                	subw	a0,a0,a5
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
    return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <strncmp+0x32>

0000000080000d46 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d4c:	872a                	mv	a4,a0
    80000d4e:	8832                	mv	a6,a2
    80000d50:	367d                	addiw	a2,a2,-1
    80000d52:	01005963          	blez	a6,80000d64 <strncpy+0x1e>
    80000d56:	0705                	addi	a4,a4,1
    80000d58:	0005c783          	lbu	a5,0(a1)
    80000d5c:	fef70fa3          	sb	a5,-1(a4)
    80000d60:	0585                	addi	a1,a1,1
    80000d62:	f7f5                	bnez	a5,80000d4e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d64:	86ba                	mv	a3,a4
    80000d66:	00c05c63          	blez	a2,80000d7e <strncpy+0x38>
    *s++ = 0;
    80000d6a:	0685                	addi	a3,a3,1
    80000d6c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d70:	40d707bb          	subw	a5,a4,a3
    80000d74:	37fd                	addiw	a5,a5,-1
    80000d76:	010787bb          	addw	a5,a5,a6
    80000d7a:	fef048e3          	bgtz	a5,80000d6a <strncpy+0x24>
  return os;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret

0000000080000d84 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e422                	sd	s0,8(sp)
    80000d88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d8a:	02c05363          	blez	a2,80000db0 <safestrcpy+0x2c>
    80000d8e:	fff6069b          	addiw	a3,a2,-1
    80000d92:	1682                	slli	a3,a3,0x20
    80000d94:	9281                	srli	a3,a3,0x20
    80000d96:	96ae                	add	a3,a3,a1
    80000d98:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d9a:	00d58963          	beq	a1,a3,80000dac <safestrcpy+0x28>
    80000d9e:	0585                	addi	a1,a1,1
    80000da0:	0785                	addi	a5,a5,1
    80000da2:	fff5c703          	lbu	a4,-1(a1)
    80000da6:	fee78fa3          	sb	a4,-1(a5)
    80000daa:	fb65                	bnez	a4,80000d9a <safestrcpy+0x16>
    ;
  *s = 0;
    80000dac:	00078023          	sb	zero,0(a5)
  return os;
}
    80000db0:	6422                	ld	s0,8(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strlen>:

int
strlen(const char *s)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dbc:	00054783          	lbu	a5,0(a0)
    80000dc0:	cf91                	beqz	a5,80000ddc <strlen+0x26>
    80000dc2:	0505                	addi	a0,a0,1
    80000dc4:	87aa                	mv	a5,a0
    80000dc6:	4685                	li	a3,1
    80000dc8:	9e89                	subw	a3,a3,a0
    80000dca:	00f6853b          	addw	a0,a3,a5
    80000dce:	0785                	addi	a5,a5,1
    80000dd0:	fff7c703          	lbu	a4,-1(a5)
    80000dd4:	fb7d                	bnez	a4,80000dca <strlen+0x14>
    ;
  return n;
}
    80000dd6:	6422                	ld	s0,8(sp)
    80000dd8:	0141                	addi	sp,sp,16
    80000dda:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ddc:	4501                	li	a0,0
    80000dde:	bfe5                	j	80000dd6 <strlen+0x20>

0000000080000de0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000de8:	1ef000ef          	jal	ra,800017d6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dec:	00007717          	auipc	a4,0x7
    80000df0:	a8470713          	addi	a4,a4,-1404 # 80007870 <started>
  if(cpuid() == 0){
    80000df4:	c51d                	beqz	a0,80000e22 <main+0x42>
    while(started == 0)
    80000df6:	431c                	lw	a5,0(a4)
    80000df8:	2781                	sext.w	a5,a5
    80000dfa:	dff5                	beqz	a5,80000df6 <main+0x16>
      ;
    __sync_synchronize();
    80000dfc:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e00:	1d7000ef          	jal	ra,800017d6 <cpuid>
    80000e04:	85aa                	mv	a1,a0
    80000e06:	00006517          	auipc	a0,0x6
    80000e0a:	2aa50513          	addi	a0,a0,682 # 800070b0 <digits+0x78>
    80000e0e:	eb4ff0ef          	jal	ra,800004c2 <printf>
    kvminithart();    // turn on paging
    80000e12:	080000ef          	jal	ra,80000e92 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e16:	74c010ef          	jal	ra,80002562 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1a:	68a040ef          	jal	ra,800054a4 <plicinithart>
  }

  scheduler();        
    80000e1e:	65f000ef          	jal	ra,80001c7c <scheduler>
    consoleinit();
    80000e22:	dcaff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e26:	99fff0ef          	jal	ra,800007c4 <printfinit>
    printf("\n");
    80000e2a:	00006517          	auipc	a0,0x6
    80000e2e:	29650513          	addi	a0,a0,662 # 800070c0 <digits+0x88>
    80000e32:	e90ff0ef          	jal	ra,800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000e36:	00006517          	auipc	a0,0x6
    80000e3a:	26250513          	addi	a0,a0,610 # 80007098 <digits+0x60>
    80000e3e:	e84ff0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    80000e42:	00006517          	auipc	a0,0x6
    80000e46:	27e50513          	addi	a0,a0,638 # 800070c0 <digits+0x88>
    80000e4a:	e78ff0ef          	jal	ra,800004c2 <printf>
    kinit();         // physical page allocator
    80000e4e:	c19ff0ef          	jal	ra,80000a66 <kinit>
    kvminit();       // create kernel page table
    80000e52:	2ca000ef          	jal	ra,8000111c <kvminit>
    kvminithart();   // turn on paging
    80000e56:	03c000ef          	jal	ra,80000e92 <kvminithart>
    procinit();      // process table
    80000e5a:	0d5000ef          	jal	ra,8000172e <procinit>
    trapinit();      // trap vectors
    80000e5e:	6e0010ef          	jal	ra,8000253e <trapinit>
    trapinithart();  // install kernel trap vector
    80000e62:	700010ef          	jal	ra,80002562 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e66:	628040ef          	jal	ra,8000548e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6a:	63a040ef          	jal	ra,800054a4 <plicinithart>
    binit();         // buffer cache
    80000e6e:	5d5010ef          	jal	ra,80002c42 <binit>
    iinit();         // inode table
    80000e72:	344020ef          	jal	ra,800031b6 <iinit>
    fileinit();      // file table
    80000e76:	22c030ef          	jal	ra,800040a2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7a:	71a040ef          	jal	ra,80005594 <virtio_disk_init>
    userinit();      // first user process
    80000e7e:	455000ef          	jal	ra,80001ad2 <userinit>
    __sync_synchronize();
    80000e82:	0ff0000f          	fence
    started = 1;
    80000e86:	4785                	li	a5,1
    80000e88:	00007717          	auipc	a4,0x7
    80000e8c:	9ef72423          	sw	a5,-1560(a4) # 80007870 <started>
    80000e90:	b779                	j	80000e1e <main+0x3e>

0000000080000e92 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e98:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000e9c:	00007797          	auipc	a5,0x7
    80000ea0:	9dc7b783          	ld	a5,-1572(a5) # 80007878 <kernel_pagetable>
    80000ea4:	83b1                	srli	a5,a5,0xc
    80000ea6:	577d                	li	a4,-1
    80000ea8:	177e                	slli	a4,a4,0x3f
    80000eaa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000eac:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000eb0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eba:	7139                	addi	sp,sp,-64
    80000ebc:	fc06                	sd	ra,56(sp)
    80000ebe:	f822                	sd	s0,48(sp)
    80000ec0:	f426                	sd	s1,40(sp)
    80000ec2:	f04a                	sd	s2,32(sp)
    80000ec4:	ec4e                	sd	s3,24(sp)
    80000ec6:	e852                	sd	s4,16(sp)
    80000ec8:	e456                	sd	s5,8(sp)
    80000eca:	e05a                	sd	s6,0(sp)
    80000ecc:	0080                	addi	s0,sp,64
    80000ece:	84aa                	mv	s1,a0
    80000ed0:	89ae                	mv	s3,a1
    80000ed2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ed4:	57fd                	li	a5,-1
    80000ed6:	83e9                	srli	a5,a5,0x1a
    80000ed8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000eda:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000edc:	02b7fc63          	bgeu	a5,a1,80000f14 <walk+0x5a>
    panic("walk");
    80000ee0:	00006517          	auipc	a0,0x6
    80000ee4:	1e850513          	addi	a0,a0,488 # 800070c8 <digits+0x90>
    80000ee8:	8a1ff0ef          	jal	ra,80000788 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eec:	060a8263          	beqz	s5,80000f50 <walk+0x96>
    80000ef0:	babff0ef          	jal	ra,80000a9a <kalloc>
    80000ef4:	84aa                	mv	s1,a0
    80000ef6:	c139                	beqz	a0,80000f3c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ef8:	6605                	lui	a2,0x1
    80000efa:	4581                	li	a1,0
    80000efc:	d43ff0ef          	jal	ra,80000c3e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f00:	00c4d793          	srli	a5,s1,0xc
    80000f04:	07aa                	slli	a5,a5,0xa
    80000f06:	0017e793          	ori	a5,a5,1
    80000f0a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f0e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde05f>
    80000f10:	036a0063          	beq	s4,s6,80000f30 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f14:	0149d933          	srl	s2,s3,s4
    80000f18:	1ff97913          	andi	s2,s2,511
    80000f1c:	090e                	slli	s2,s2,0x3
    80000f1e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f20:	00093483          	ld	s1,0(s2)
    80000f24:	0014f793          	andi	a5,s1,1
    80000f28:	d3f1                	beqz	a5,80000eec <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f2a:	80a9                	srli	s1,s1,0xa
    80000f2c:	04b2                	slli	s1,s1,0xc
    80000f2e:	b7c5                	j	80000f0e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f30:	00c9d513          	srli	a0,s3,0xc
    80000f34:	1ff57513          	andi	a0,a0,511
    80000f38:	050e                	slli	a0,a0,0x3
    80000f3a:	9526                	add	a0,a0,s1
}
    80000f3c:	70e2                	ld	ra,56(sp)
    80000f3e:	7442                	ld	s0,48(sp)
    80000f40:	74a2                	ld	s1,40(sp)
    80000f42:	7902                	ld	s2,32(sp)
    80000f44:	69e2                	ld	s3,24(sp)
    80000f46:	6a42                	ld	s4,16(sp)
    80000f48:	6aa2                	ld	s5,8(sp)
    80000f4a:	6b02                	ld	s6,0(sp)
    80000f4c:	6121                	addi	sp,sp,64
    80000f4e:	8082                	ret
        return 0;
    80000f50:	4501                	li	a0,0
    80000f52:	b7ed                	j	80000f3c <walk+0x82>

0000000080000f54 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f54:	57fd                	li	a5,-1
    80000f56:	83e9                	srli	a5,a5,0x1a
    80000f58:	00b7f463          	bgeu	a5,a1,80000f60 <walkaddr+0xc>
    return 0;
    80000f5c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f5e:	8082                	ret
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f68:	4601                	li	a2,0
    80000f6a:	f51ff0ef          	jal	ra,80000eba <walk>
  if(pte == 0)
    80000f6e:	c105                	beqz	a0,80000f8e <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f70:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f72:	0117f693          	andi	a3,a5,17
    80000f76:	4745                	li	a4,17
    return 0;
    80000f78:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7a:	00e68663          	beq	a3,a4,80000f86 <walkaddr+0x32>
}
    80000f7e:	60a2                	ld	ra,8(sp)
    80000f80:	6402                	ld	s0,0(sp)
    80000f82:	0141                	addi	sp,sp,16
    80000f84:	8082                	ret
  pa = PTE2PA(*pte);
    80000f86:	83a9                	srli	a5,a5,0xa
    80000f88:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000f8c:	bfcd                	j	80000f7e <walkaddr+0x2a>
    return 0;
    80000f8e:	4501                	li	a0,0
    80000f90:	b7fd                	j	80000f7e <walkaddr+0x2a>

0000000080000f92 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000f92:	715d                	addi	sp,sp,-80
    80000f94:	e486                	sd	ra,72(sp)
    80000f96:	e0a2                	sd	s0,64(sp)
    80000f98:	fc26                	sd	s1,56(sp)
    80000f9a:	f84a                	sd	s2,48(sp)
    80000f9c:	f44e                	sd	s3,40(sp)
    80000f9e:	f052                	sd	s4,32(sp)
    80000fa0:	ec56                	sd	s5,24(sp)
    80000fa2:	e85a                	sd	s6,16(sp)
    80000fa4:	e45e                	sd	s7,8(sp)
    80000fa6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fa8:	03459793          	slli	a5,a1,0x34
    80000fac:	e7a9                	bnez	a5,80000ff6 <mappages+0x64>
    80000fae:	8aaa                	mv	s5,a0
    80000fb0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fb2:	03461793          	slli	a5,a2,0x34
    80000fb6:	e7b1                	bnez	a5,80001002 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fb8:	ca39                	beqz	a2,8000100e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fba:	77fd                	lui	a5,0xfffff
    80000fbc:	963e                	add	a2,a2,a5
    80000fbe:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fc2:	892e                	mv	s2,a1
    80000fc4:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fc8:	6b85                	lui	s7,0x1
    80000fca:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000fce:	4605                	li	a2,1
    80000fd0:	85ca                	mv	a1,s2
    80000fd2:	8556                	mv	a0,s5
    80000fd4:	ee7ff0ef          	jal	ra,80000eba <walk>
    80000fd8:	c539                	beqz	a0,80001026 <mappages+0x94>
    if(*pte & PTE_V)
    80000fda:	611c                	ld	a5,0(a0)
    80000fdc:	8b85                	andi	a5,a5,1
    80000fde:	ef95                	bnez	a5,8000101a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000fe0:	80b1                	srli	s1,s1,0xc
    80000fe2:	04aa                	slli	s1,s1,0xa
    80000fe4:	0164e4b3          	or	s1,s1,s6
    80000fe8:	0014e493          	ori	s1,s1,1
    80000fec:	e104                	sd	s1,0(a0)
    if(a == last)
    80000fee:	05390863          	beq	s2,s3,8000103e <mappages+0xac>
    a += PGSIZE;
    80000ff2:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff4:	bfd9                	j	80000fca <mappages+0x38>
    panic("mappages: va not aligned");
    80000ff6:	00006517          	auipc	a0,0x6
    80000ffa:	0da50513          	addi	a0,a0,218 # 800070d0 <digits+0x98>
    80000ffe:	f8aff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size not aligned");
    80001002:	00006517          	auipc	a0,0x6
    80001006:	0ee50513          	addi	a0,a0,238 # 800070f0 <digits+0xb8>
    8000100a:	f7eff0ef          	jal	ra,80000788 <panic>
    panic("mappages: size");
    8000100e:	00006517          	auipc	a0,0x6
    80001012:	10250513          	addi	a0,a0,258 # 80007110 <digits+0xd8>
    80001016:	f72ff0ef          	jal	ra,80000788 <panic>
      panic("mappages: remap");
    8000101a:	00006517          	auipc	a0,0x6
    8000101e:	10650513          	addi	a0,a0,262 # 80007120 <digits+0xe8>
    80001022:	f66ff0ef          	jal	ra,80000788 <panic>
      return -1;
    80001026:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001028:	60a6                	ld	ra,72(sp)
    8000102a:	6406                	ld	s0,64(sp)
    8000102c:	74e2                	ld	s1,56(sp)
    8000102e:	7942                	ld	s2,48(sp)
    80001030:	79a2                	ld	s3,40(sp)
    80001032:	7a02                	ld	s4,32(sp)
    80001034:	6ae2                	ld	s5,24(sp)
    80001036:	6b42                	ld	s6,16(sp)
    80001038:	6ba2                	ld	s7,8(sp)
    8000103a:	6161                	addi	sp,sp,80
    8000103c:	8082                	ret
  return 0;
    8000103e:	4501                	li	a0,0
    80001040:	b7e5                	j	80001028 <mappages+0x96>

0000000080001042 <kvmmap>:
{
    80001042:	1141                	addi	sp,sp,-16
    80001044:	e406                	sd	ra,8(sp)
    80001046:	e022                	sd	s0,0(sp)
    80001048:	0800                	addi	s0,sp,16
    8000104a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000104c:	86b2                	mv	a3,a2
    8000104e:	863e                	mv	a2,a5
    80001050:	f43ff0ef          	jal	ra,80000f92 <mappages>
    80001054:	e509                	bnez	a0,8000105e <kvmmap+0x1c>
}
    80001056:	60a2                	ld	ra,8(sp)
    80001058:	6402                	ld	s0,0(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret
    panic("kvmmap");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	0d250513          	addi	a0,a0,210 # 80007130 <digits+0xf8>
    80001066:	f22ff0ef          	jal	ra,80000788 <panic>

000000008000106a <kvmmake>:
{
    8000106a:	1101                	addi	sp,sp,-32
    8000106c:	ec06                	sd	ra,24(sp)
    8000106e:	e822                	sd	s0,16(sp)
    80001070:	e426                	sd	s1,8(sp)
    80001072:	e04a                	sd	s2,0(sp)
    80001074:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001076:	a25ff0ef          	jal	ra,80000a9a <kalloc>
    8000107a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000107c:	6605                	lui	a2,0x1
    8000107e:	4581                	li	a1,0
    80001080:	bbfff0ef          	jal	ra,80000c3e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001084:	4719                	li	a4,6
    80001086:	6685                	lui	a3,0x1
    80001088:	10000637          	lui	a2,0x10000
    8000108c:	100005b7          	lui	a1,0x10000
    80001090:	8526                	mv	a0,s1
    80001092:	fb1ff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001096:	4719                	li	a4,6
    80001098:	6685                	lui	a3,0x1
    8000109a:	10001637          	lui	a2,0x10001
    8000109e:	100015b7          	lui	a1,0x10001
    800010a2:	8526                	mv	a0,s1
    800010a4:	f9fff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010a8:	4719                	li	a4,6
    800010aa:	040006b7          	lui	a3,0x4000
    800010ae:	0c000637          	lui	a2,0xc000
    800010b2:	0c0005b7          	lui	a1,0xc000
    800010b6:	8526                	mv	a0,s1
    800010b8:	f8bff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010bc:	00006917          	auipc	s2,0x6
    800010c0:	f4490913          	addi	s2,s2,-188 # 80007000 <etext>
    800010c4:	4729                	li	a4,10
    800010c6:	80006697          	auipc	a3,0x80006
    800010ca:	f3a68693          	addi	a3,a3,-198 # 7000 <_entry-0x7fff9000>
    800010ce:	4605                	li	a2,1
    800010d0:	067e                	slli	a2,a2,0x1f
    800010d2:	85b2                	mv	a1,a2
    800010d4:	8526                	mv	a0,s1
    800010d6:	f6dff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010da:	4719                	li	a4,6
    800010dc:	46c5                	li	a3,17
    800010de:	06ee                	slli	a3,a3,0x1b
    800010e0:	412686b3          	sub	a3,a3,s2
    800010e4:	864a                	mv	a2,s2
    800010e6:	85ca                	mv	a1,s2
    800010e8:	8526                	mv	a0,s1
    800010ea:	f59ff0ef          	jal	ra,80001042 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010ee:	4729                	li	a4,10
    800010f0:	6685                	lui	a3,0x1
    800010f2:	00005617          	auipc	a2,0x5
    800010f6:	f0e60613          	addi	a2,a2,-242 # 80006000 <_trampoline>
    800010fa:	040005b7          	lui	a1,0x4000
    800010fe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001100:	05b2                	slli	a1,a1,0xc
    80001102:	8526                	mv	a0,s1
    80001104:	f3fff0ef          	jal	ra,80001042 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001108:	8526                	mv	a0,s1
    8000110a:	59a000ef          	jal	ra,800016a4 <proc_mapstacks>
}
    8000110e:	8526                	mv	a0,s1
    80001110:	60e2                	ld	ra,24(sp)
    80001112:	6442                	ld	s0,16(sp)
    80001114:	64a2                	ld	s1,8(sp)
    80001116:	6902                	ld	s2,0(sp)
    80001118:	6105                	addi	sp,sp,32
    8000111a:	8082                	ret

000000008000111c <kvminit>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001124:	f47ff0ef          	jal	ra,8000106a <kvmmake>
    80001128:	00006797          	auipc	a5,0x6
    8000112c:	74a7b823          	sd	a0,1872(a5) # 80007878 <kernel_pagetable>
}
    80001130:	60a2                	ld	ra,8(sp)
    80001132:	6402                	ld	s0,0(sp)
    80001134:	0141                	addi	sp,sp,16
    80001136:	8082                	ret

0000000080001138 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001138:	1101                	addi	sp,sp,-32
    8000113a:	ec06                	sd	ra,24(sp)
    8000113c:	e822                	sd	s0,16(sp)
    8000113e:	e426                	sd	s1,8(sp)
    80001140:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001142:	959ff0ef          	jal	ra,80000a9a <kalloc>
    80001146:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001148:	c509                	beqz	a0,80001152 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000114a:	6605                	lui	a2,0x1
    8000114c:	4581                	li	a1,0
    8000114e:	af1ff0ef          	jal	ra,80000c3e <memset>
  return pagetable;
}
    80001152:	8526                	mv	a0,s1
    80001154:	60e2                	ld	ra,24(sp)
    80001156:	6442                	ld	s0,16(sp)
    80001158:	64a2                	ld	s1,8(sp)
    8000115a:	6105                	addi	sp,sp,32
    8000115c:	8082                	ret

000000008000115e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000115e:	7139                	addi	sp,sp,-64
    80001160:	fc06                	sd	ra,56(sp)
    80001162:	f822                	sd	s0,48(sp)
    80001164:	f426                	sd	s1,40(sp)
    80001166:	f04a                	sd	s2,32(sp)
    80001168:	ec4e                	sd	s3,24(sp)
    8000116a:	e852                	sd	s4,16(sp)
    8000116c:	e456                	sd	s5,8(sp)
    8000116e:	e05a                	sd	s6,0(sp)
    80001170:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001172:	03459793          	slli	a5,a1,0x34
    80001176:	e785                	bnez	a5,8000119e <uvmunmap+0x40>
    80001178:	8a2a                	mv	s4,a0
    8000117a:	892e                	mv	s2,a1
    8000117c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000117e:	0632                	slli	a2,a2,0xc
    80001180:	00b609b3          	add	s3,a2,a1
    80001184:	6b05                	lui	s6,0x1
    80001186:	0335e763          	bltu	a1,s3,800011b4 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000118a:	70e2                	ld	ra,56(sp)
    8000118c:	7442                	ld	s0,48(sp)
    8000118e:	74a2                	ld	s1,40(sp)
    80001190:	7902                	ld	s2,32(sp)
    80001192:	69e2                	ld	s3,24(sp)
    80001194:	6a42                	ld	s4,16(sp)
    80001196:	6aa2                	ld	s5,8(sp)
    80001198:	6b02                	ld	s6,0(sp)
    8000119a:	6121                	addi	sp,sp,64
    8000119c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000119e:	00006517          	auipc	a0,0x6
    800011a2:	f9a50513          	addi	a0,a0,-102 # 80007138 <digits+0x100>
    800011a6:	de2ff0ef          	jal	ra,80000788 <panic>
    *pte = 0;
    800011aa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011ae:	995a                	add	s2,s2,s6
    800011b0:	fd397de3          	bgeu	s2,s3,8000118a <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011b4:	4601                	li	a2,0
    800011b6:	85ca                	mv	a1,s2
    800011b8:	8552                	mv	a0,s4
    800011ba:	d01ff0ef          	jal	ra,80000eba <walk>
    800011be:	84aa                	mv	s1,a0
    800011c0:	d57d                	beqz	a0,800011ae <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011c2:	611c                	ld	a5,0(a0)
    800011c4:	0017f713          	andi	a4,a5,1
    800011c8:	d37d                	beqz	a4,800011ae <uvmunmap+0x50>
    if(do_free){
    800011ca:	fe0a80e3          	beqz	s5,800011aa <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    800011ce:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011d0:	00c79513          	slli	a0,a5,0xc
    800011d4:	fe4ff0ef          	jal	ra,800009b8 <kfree>
    800011d8:	bfc9                	j	800011aa <uvmunmap+0x4c>

00000000800011da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011da:	1101                	addi	sp,sp,-32
    800011dc:	ec06                	sd	ra,24(sp)
    800011de:	e822                	sd	s0,16(sp)
    800011e0:	e426                	sd	s1,8(sp)
    800011e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011e6:	00b67d63          	bgeu	a2,a1,80001200 <uvmdealloc+0x26>
    800011ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800011ec:	6785                	lui	a5,0x1
    800011ee:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800011f0:	00f60733          	add	a4,a2,a5
    800011f4:	76fd                	lui	a3,0xfffff
    800011f6:	8f75                	and	a4,a4,a3
    800011f8:	97ae                	add	a5,a5,a1
    800011fa:	8ff5                	and	a5,a5,a3
    800011fc:	00f76863          	bltu	a4,a5,8000120c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001200:	8526                	mv	a0,s1
    80001202:	60e2                	ld	ra,24(sp)
    80001204:	6442                	ld	s0,16(sp)
    80001206:	64a2                	ld	s1,8(sp)
    80001208:	6105                	addi	sp,sp,32
    8000120a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000120c:	8f99                	sub	a5,a5,a4
    8000120e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001210:	4685                	li	a3,1
    80001212:	0007861b          	sext.w	a2,a5
    80001216:	85ba                	mv	a1,a4
    80001218:	f47ff0ef          	jal	ra,8000115e <uvmunmap>
    8000121c:	b7d5                	j	80001200 <uvmdealloc+0x26>

000000008000121e <uvmalloc>:
  if(newsz < oldsz)
    8000121e:	08b66963          	bltu	a2,a1,800012b0 <uvmalloc+0x92>
{
    80001222:	7139                	addi	sp,sp,-64
    80001224:	fc06                	sd	ra,56(sp)
    80001226:	f822                	sd	s0,48(sp)
    80001228:	f426                	sd	s1,40(sp)
    8000122a:	f04a                	sd	s2,32(sp)
    8000122c:	ec4e                	sd	s3,24(sp)
    8000122e:	e852                	sd	s4,16(sp)
    80001230:	e456                	sd	s5,8(sp)
    80001232:	e05a                	sd	s6,0(sp)
    80001234:	0080                	addi	s0,sp,64
    80001236:	8aaa                	mv	s5,a0
    80001238:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000123a:	6785                	lui	a5,0x1
    8000123c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000123e:	95be                	add	a1,a1,a5
    80001240:	77fd                	lui	a5,0xfffff
    80001242:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001246:	06c9f763          	bgeu	s3,a2,800012b4 <uvmalloc+0x96>
    8000124a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000124c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001250:	84bff0ef          	jal	ra,80000a9a <kalloc>
    80001254:	84aa                	mv	s1,a0
    if(mem == 0){
    80001256:	c11d                	beqz	a0,8000127c <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    80001258:	6605                	lui	a2,0x1
    8000125a:	4581                	li	a1,0
    8000125c:	9e3ff0ef          	jal	ra,80000c3e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001260:	875a                	mv	a4,s6
    80001262:	86a6                	mv	a3,s1
    80001264:	6605                	lui	a2,0x1
    80001266:	85ca                	mv	a1,s2
    80001268:	8556                	mv	a0,s5
    8000126a:	d29ff0ef          	jal	ra,80000f92 <mappages>
    8000126e:	e51d                	bnez	a0,8000129c <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001270:	6785                	lui	a5,0x1
    80001272:	993e                	add	s2,s2,a5
    80001274:	fd496ee3          	bltu	s2,s4,80001250 <uvmalloc+0x32>
  return newsz;
    80001278:	8552                	mv	a0,s4
    8000127a:	a039                	j	80001288 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000127c:	864e                	mv	a2,s3
    8000127e:	85ca                	mv	a1,s2
    80001280:	8556                	mv	a0,s5
    80001282:	f59ff0ef          	jal	ra,800011da <uvmdealloc>
      return 0;
    80001286:	4501                	li	a0,0
}
    80001288:	70e2                	ld	ra,56(sp)
    8000128a:	7442                	ld	s0,48(sp)
    8000128c:	74a2                	ld	s1,40(sp)
    8000128e:	7902                	ld	s2,32(sp)
    80001290:	69e2                	ld	s3,24(sp)
    80001292:	6a42                	ld	s4,16(sp)
    80001294:	6aa2                	ld	s5,8(sp)
    80001296:	6b02                	ld	s6,0(sp)
    80001298:	6121                	addi	sp,sp,64
    8000129a:	8082                	ret
      kfree(mem);
    8000129c:	8526                	mv	a0,s1
    8000129e:	f1aff0ef          	jal	ra,800009b8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012a2:	864e                	mv	a2,s3
    800012a4:	85ca                	mv	a1,s2
    800012a6:	8556                	mv	a0,s5
    800012a8:	f33ff0ef          	jal	ra,800011da <uvmdealloc>
      return 0;
    800012ac:	4501                	li	a0,0
    800012ae:	bfe9                	j	80001288 <uvmalloc+0x6a>
    return oldsz;
    800012b0:	852e                	mv	a0,a1
}
    800012b2:	8082                	ret
  return newsz;
    800012b4:	8532                	mv	a0,a2
    800012b6:	bfc9                	j	80001288 <uvmalloc+0x6a>

00000000800012b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012b8:	7179                	addi	sp,sp,-48
    800012ba:	f406                	sd	ra,40(sp)
    800012bc:	f022                	sd	s0,32(sp)
    800012be:	ec26                	sd	s1,24(sp)
    800012c0:	e84a                	sd	s2,16(sp)
    800012c2:	e44e                	sd	s3,8(sp)
    800012c4:	e052                	sd	s4,0(sp)
    800012c6:	1800                	addi	s0,sp,48
    800012c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012ca:	84aa                	mv	s1,a0
    800012cc:	6905                	lui	s2,0x1
    800012ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012d0:	4985                	li	s3,1
    800012d2:	a819                	j	800012e8 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800012d6:	00c79513          	slli	a0,a5,0xc
    800012da:	fdfff0ef          	jal	ra,800012b8 <freewalk>
      pagetable[i] = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012e2:	04a1                	addi	s1,s1,8
    800012e4:	01248f63          	beq	s1,s2,80001302 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800012e8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012ea:	00f7f713          	andi	a4,a5,15
    800012ee:	ff3703e3          	beq	a4,s3,800012d4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012f2:	8b85                	andi	a5,a5,1
    800012f4:	d7fd                	beqz	a5,800012e2 <freewalk+0x2a>
      panic("freewalk: leaf");
    800012f6:	00006517          	auipc	a0,0x6
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80007150 <digits+0x118>
    800012fe:	c8aff0ef          	jal	ra,80000788 <panic>
    }
  }
  kfree((void*)pagetable);
    80001302:	8552                	mv	a0,s4
    80001304:	eb4ff0ef          	jal	ra,800009b8 <kfree>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret

0000000080001318 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
    80001322:	84aa                	mv	s1,a0
  if(sz > 0)
    80001324:	e989                	bnez	a1,80001336 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001326:	8526                	mv	a0,s1
    80001328:	f91ff0ef          	jal	ra,800012b8 <freewalk>
}
    8000132c:	60e2                	ld	ra,24(sp)
    8000132e:	6442                	ld	s0,16(sp)
    80001330:	64a2                	ld	s1,8(sp)
    80001332:	6105                	addi	sp,sp,32
    80001334:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001336:	6785                	lui	a5,0x1
    80001338:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000133a:	95be                	add	a1,a1,a5
    8000133c:	4685                	li	a3,1
    8000133e:	00c5d613          	srli	a2,a1,0xc
    80001342:	4581                	li	a1,0
    80001344:	e1bff0ef          	jal	ra,8000115e <uvmunmap>
    80001348:	bff9                	j	80001326 <uvmfree+0xe>

000000008000134a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000134a:	ce49                	beqz	a2,800013e4 <uvmcopy+0x9a>
{
    8000134c:	715d                	addi	sp,sp,-80
    8000134e:	e486                	sd	ra,72(sp)
    80001350:	e0a2                	sd	s0,64(sp)
    80001352:	fc26                	sd	s1,56(sp)
    80001354:	f84a                	sd	s2,48(sp)
    80001356:	f44e                	sd	s3,40(sp)
    80001358:	f052                	sd	s4,32(sp)
    8000135a:	ec56                	sd	s5,24(sp)
    8000135c:	e85a                	sd	s6,16(sp)
    8000135e:	e45e                	sd	s7,8(sp)
    80001360:	0880                	addi	s0,sp,80
    80001362:	8aaa                	mv	s5,a0
    80001364:	8b2e                	mv	s6,a1
    80001366:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001368:	4481                	li	s1,0
    8000136a:	a029                	j	80001374 <uvmcopy+0x2a>
    8000136c:	6785                	lui	a5,0x1
    8000136e:	94be                	add	s1,s1,a5
    80001370:	0544fe63          	bgeu	s1,s4,800013cc <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001374:	4601                	li	a2,0
    80001376:	85a6                	mv	a1,s1
    80001378:	8556                	mv	a0,s5
    8000137a:	b41ff0ef          	jal	ra,80000eba <walk>
    8000137e:	d57d                	beqz	a0,8000136c <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001380:	6118                	ld	a4,0(a0)
    80001382:	00177793          	andi	a5,a4,1
    80001386:	d3fd                	beqz	a5,8000136c <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001388:	00a75593          	srli	a1,a4,0xa
    8000138c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001390:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001394:	f06ff0ef          	jal	ra,80000a9a <kalloc>
    80001398:	89aa                	mv	s3,a0
    8000139a:	c105                	beqz	a0,800013ba <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000139c:	6605                	lui	a2,0x1
    8000139e:	85de                	mv	a1,s7
    800013a0:	8fbff0ef          	jal	ra,80000c9a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013a4:	874a                	mv	a4,s2
    800013a6:	86ce                	mv	a3,s3
    800013a8:	6605                	lui	a2,0x1
    800013aa:	85a6                	mv	a1,s1
    800013ac:	855a                	mv	a0,s6
    800013ae:	be5ff0ef          	jal	ra,80000f92 <mappages>
    800013b2:	dd4d                	beqz	a0,8000136c <uvmcopy+0x22>
      kfree(mem);
    800013b4:	854e                	mv	a0,s3
    800013b6:	e02ff0ef          	jal	ra,800009b8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013ba:	4685                	li	a3,1
    800013bc:	00c4d613          	srli	a2,s1,0xc
    800013c0:	4581                	li	a1,0
    800013c2:	855a                	mv	a0,s6
    800013c4:	d9bff0ef          	jal	ra,8000115e <uvmunmap>
  return -1;
    800013c8:	557d                	li	a0,-1
    800013ca:	a011                	j	800013ce <uvmcopy+0x84>
  return 0;
    800013cc:	4501                	li	a0,0
}
    800013ce:	60a6                	ld	ra,72(sp)
    800013d0:	6406                	ld	s0,64(sp)
    800013d2:	74e2                	ld	s1,56(sp)
    800013d4:	7942                	ld	s2,48(sp)
    800013d6:	79a2                	ld	s3,40(sp)
    800013d8:	7a02                	ld	s4,32(sp)
    800013da:	6ae2                	ld	s5,24(sp)
    800013dc:	6b42                	ld	s6,16(sp)
    800013de:	6ba2                	ld	s7,8(sp)
    800013e0:	6161                	addi	sp,sp,80
    800013e2:	8082                	ret
  return 0;
    800013e4:	4501                	li	a0,0
}
    800013e6:	8082                	ret

00000000800013e8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013e8:	1141                	addi	sp,sp,-16
    800013ea:	e406                	sd	ra,8(sp)
    800013ec:	e022                	sd	s0,0(sp)
    800013ee:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800013f0:	4601                	li	a2,0
    800013f2:	ac9ff0ef          	jal	ra,80000eba <walk>
  if(pte == 0)
    800013f6:	c901                	beqz	a0,80001406 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800013f8:	611c                	ld	a5,0(a0)
    800013fa:	9bbd                	andi	a5,a5,-17
    800013fc:	e11c                	sd	a5,0(a0)
}
    800013fe:	60a2                	ld	ra,8(sp)
    80001400:	6402                	ld	s0,0(sp)
    80001402:	0141                	addi	sp,sp,16
    80001404:	8082                	ret
    panic("uvmclear");
    80001406:	00006517          	auipc	a0,0x6
    8000140a:	d5a50513          	addi	a0,a0,-678 # 80007160 <digits+0x128>
    8000140e:	b7aff0ef          	jal	ra,80000788 <panic>

0000000080001412 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001412:	c2cd                	beqz	a3,800014b4 <copyinstr+0xa2>
{
    80001414:	715d                	addi	sp,sp,-80
    80001416:	e486                	sd	ra,72(sp)
    80001418:	e0a2                	sd	s0,64(sp)
    8000141a:	fc26                	sd	s1,56(sp)
    8000141c:	f84a                	sd	s2,48(sp)
    8000141e:	f44e                	sd	s3,40(sp)
    80001420:	f052                	sd	s4,32(sp)
    80001422:	ec56                	sd	s5,24(sp)
    80001424:	e85a                	sd	s6,16(sp)
    80001426:	e45e                	sd	s7,8(sp)
    80001428:	0880                	addi	s0,sp,80
    8000142a:	8a2a                	mv	s4,a0
    8000142c:	8b2e                	mv	s6,a1
    8000142e:	8bb2                	mv	s7,a2
    80001430:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001432:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001434:	6985                	lui	s3,0x1
    80001436:	a02d                	j	80001460 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001438:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000143c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000143e:	37fd                	addiw	a5,a5,-1
    80001440:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
    srcva = va0 + PGSIZE;
    8000145a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000145e:	c4b9                	beqz	s1,800014ac <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80001460:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001464:	85ca                	mv	a1,s2
    80001466:	8552                	mv	a0,s4
    80001468:	aedff0ef          	jal	ra,80000f54 <walkaddr>
    if(pa0 == 0)
    8000146c:	c131                	beqz	a0,800014b0 <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    8000146e:	417906b3          	sub	a3,s2,s7
    80001472:	96ce                	add	a3,a3,s3
    80001474:	00d4f363          	bgeu	s1,a3,8000147a <copyinstr+0x68>
    80001478:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000147a:	955e                	add	a0,a0,s7
    8000147c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001480:	dee9                	beqz	a3,8000145a <copyinstr+0x48>
    80001482:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001484:	41650633          	sub	a2,a0,s6
    80001488:	fff48593          	addi	a1,s1,-1
    8000148c:	95da                	add	a1,a1,s6
    while(n > 0){
    8000148e:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001490:	00f60733          	add	a4,a2,a5
    80001494:	00074703          	lbu	a4,0(a4)
    80001498:	d345                	beqz	a4,80001438 <copyinstr+0x26>
        *dst = *p;
    8000149a:	00e78023          	sb	a4,0(a5)
      --max;
    8000149e:	40f584b3          	sub	s1,a1,a5
      dst++;
    800014a2:	0785                	addi	a5,a5,1
    while(n > 0){
    800014a4:	fed796e3          	bne	a5,a3,80001490 <copyinstr+0x7e>
      dst++;
    800014a8:	8b3e                	mv	s6,a5
    800014aa:	bf45                	j	8000145a <copyinstr+0x48>
    800014ac:	4781                	li	a5,0
    800014ae:	bf41                	j	8000143e <copyinstr+0x2c>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	bf49                	j	80001444 <copyinstr+0x32>
  int got_null = 0;
    800014b4:	4781                	li	a5,0
  if(got_null){
    800014b6:	37fd                	addiw	a5,a5,-1
    800014b8:	0007851b          	sext.w	a0,a5
}
    800014bc:	8082                	ret

00000000800014be <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014be:	1141                	addi	sp,sp,-16
    800014c0:	e406                	sd	ra,8(sp)
    800014c2:	e022                	sd	s0,0(sp)
    800014c4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014c6:	4601                	li	a2,0
    800014c8:	9f3ff0ef          	jal	ra,80000eba <walk>
  if (pte == 0) {
    800014cc:	c519                	beqz	a0,800014da <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014ce:	6108                	ld	a0,0(a0)
    return 0;
    800014d0:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014d2:	60a2                	ld	ra,8(sp)
    800014d4:	6402                	ld	s0,0(sp)
    800014d6:	0141                	addi	sp,sp,16
    800014d8:	8082                	ret
    return 0;
    800014da:	4501                	li	a0,0
    800014dc:	bfdd                	j	800014d2 <ismapped+0x14>

00000000800014de <vmfault>:
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	89aa                	mv	s3,a0
    800014f0:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800014f2:	310000ef          	jal	ra,80001802 <myproc>
  if (va >= p->sz)
    800014f6:	653c                	ld	a5,72(a0)
    800014f8:	00f4ec63          	bltu	s1,a5,80001510 <vmfault+0x32>
    return 0;
    800014fc:	4981                	li	s3,0
}
    800014fe:	854e                	mv	a0,s3
    80001500:	70a2                	ld	ra,40(sp)
    80001502:	7402                	ld	s0,32(sp)
    80001504:	64e2                	ld	s1,24(sp)
    80001506:	6942                	ld	s2,16(sp)
    80001508:	69a2                	ld	s3,8(sp)
    8000150a:	6a02                	ld	s4,0(sp)
    8000150c:	6145                	addi	sp,sp,48
    8000150e:	8082                	ret
    80001510:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001512:	77fd                	lui	a5,0xfffff
    80001514:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001516:	85a6                	mv	a1,s1
    80001518:	854e                	mv	a0,s3
    8000151a:	fa5ff0ef          	jal	ra,800014be <ismapped>
    return 0;
    8000151e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001520:	fd79                	bnez	a0,800014fe <vmfault+0x20>
  mem = (uint64) kalloc();
    80001522:	d78ff0ef          	jal	ra,80000a9a <kalloc>
    80001526:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001528:	d979                	beqz	a0,800014fe <vmfault+0x20>
  mem = (uint64) kalloc();
    8000152a:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000152c:	6605                	lui	a2,0x1
    8000152e:	4581                	li	a1,0
    80001530:	f0eff0ef          	jal	ra,80000c3e <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001534:	4759                	li	a4,22
    80001536:	86d2                	mv	a3,s4
    80001538:	6605                	lui	a2,0x1
    8000153a:	85a6                	mv	a1,s1
    8000153c:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001540:	a53ff0ef          	jal	ra,80000f92 <mappages>
    80001544:	dd4d                	beqz	a0,800014fe <vmfault+0x20>
    kfree((void *)mem);
    80001546:	8552                	mv	a0,s4
    80001548:	c70ff0ef          	jal	ra,800009b8 <kfree>
    return 0;
    8000154c:	4981                	li	s3,0
    8000154e:	bf45                	j	800014fe <vmfault+0x20>

0000000080001550 <copyout>:
  while(len > 0){
    80001550:	cec1                	beqz	a3,800015e8 <copyout+0x98>
{
    80001552:	711d                	addi	sp,sp,-96
    80001554:	ec86                	sd	ra,88(sp)
    80001556:	e8a2                	sd	s0,80(sp)
    80001558:	e4a6                	sd	s1,72(sp)
    8000155a:	e0ca                	sd	s2,64(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f852                	sd	s4,48(sp)
    80001560:	f456                	sd	s5,40(sp)
    80001562:	f05a                	sd	s6,32(sp)
    80001564:	ec5e                	sd	s7,24(sp)
    80001566:	e862                	sd	s8,16(sp)
    80001568:	e466                	sd	s9,8(sp)
    8000156a:	e06a                	sd	s10,0(sp)
    8000156c:	1080                	addi	s0,sp,96
    8000156e:	8c2a                	mv	s8,a0
    80001570:	8b2e                	mv	s6,a1
    80001572:	8bb2                	mv	s7,a2
    80001574:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001576:	74fd                	lui	s1,0xfffff
    80001578:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000157a:	57fd                	li	a5,-1
    8000157c:	83e9                	srli	a5,a5,0x1a
    8000157e:	0697e763          	bltu	a5,s1,800015ec <copyout+0x9c>
    80001582:	6d05                	lui	s10,0x1
    80001584:	8cbe                	mv	s9,a5
    80001586:	a015                	j	800015aa <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001588:	409b0533          	sub	a0,s6,s1
    8000158c:	0009861b          	sext.w	a2,s3
    80001590:	85de                	mv	a1,s7
    80001592:	954a                	add	a0,a0,s2
    80001594:	f06ff0ef          	jal	ra,80000c9a <memmove>
    len -= n;
    80001598:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000159c:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000159e:	040a0363          	beqz	s4,800015e4 <copyout+0x94>
    if(va0 >= MAXVA)
    800015a2:	055ce763          	bltu	s9,s5,800015f0 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015a6:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015a8:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015aa:	85a6                	mv	a1,s1
    800015ac:	8562                	mv	a0,s8
    800015ae:	9a7ff0ef          	jal	ra,80000f54 <walkaddr>
    800015b2:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015b4:	e901                	bnez	a0,800015c4 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015b6:	4601                	li	a2,0
    800015b8:	85a6                	mv	a1,s1
    800015ba:	8562                	mv	a0,s8
    800015bc:	f23ff0ef          	jal	ra,800014de <vmfault>
    800015c0:	892a                	mv	s2,a0
    800015c2:	c90d                	beqz	a0,800015f4 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015c4:	4601                	li	a2,0
    800015c6:	85a6                	mv	a1,s1
    800015c8:	8562                	mv	a0,s8
    800015ca:	8f1ff0ef          	jal	ra,80000eba <walk>
    if((*pte & PTE_W) == 0)
    800015ce:	611c                	ld	a5,0(a0)
    800015d0:	8b91                	andi	a5,a5,4
    800015d2:	c39d                	beqz	a5,800015f8 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015d4:	01a48ab3          	add	s5,s1,s10
    800015d8:	416a89b3          	sub	s3,s5,s6
    800015dc:	fb3a76e3          	bgeu	s4,s3,80001588 <copyout+0x38>
    800015e0:	89d2                	mv	s3,s4
    800015e2:	b75d                	j	80001588 <copyout+0x38>
  return 0;
    800015e4:	4501                	li	a0,0
    800015e6:	a811                	j	800015fa <copyout+0xaa>
    800015e8:	4501                	li	a0,0
}
    800015ea:	8082                	ret
      return -1;
    800015ec:	557d                	li	a0,-1
    800015ee:	a031                	j	800015fa <copyout+0xaa>
    800015f0:	557d                	li	a0,-1
    800015f2:	a021                	j	800015fa <copyout+0xaa>
        return -1;
    800015f4:	557d                	li	a0,-1
    800015f6:	a011                	j	800015fa <copyout+0xaa>
      return -1;
    800015f8:	557d                	li	a0,-1
}
    800015fa:	60e6                	ld	ra,88(sp)
    800015fc:	6446                	ld	s0,80(sp)
    800015fe:	64a6                	ld	s1,72(sp)
    80001600:	6906                	ld	s2,64(sp)
    80001602:	79e2                	ld	s3,56(sp)
    80001604:	7a42                	ld	s4,48(sp)
    80001606:	7aa2                	ld	s5,40(sp)
    80001608:	7b02                	ld	s6,32(sp)
    8000160a:	6be2                	ld	s7,24(sp)
    8000160c:	6c42                	ld	s8,16(sp)
    8000160e:	6ca2                	ld	s9,8(sp)
    80001610:	6d02                	ld	s10,0(sp)
    80001612:	6125                	addi	sp,sp,96
    80001614:	8082                	ret

0000000080001616 <copyin>:
  while(len > 0){
    80001616:	c6c9                	beqz	a3,800016a0 <copyin+0x8a>
{
    80001618:	715d                	addi	sp,sp,-80
    8000161a:	e486                	sd	ra,72(sp)
    8000161c:	e0a2                	sd	s0,64(sp)
    8000161e:	fc26                	sd	s1,56(sp)
    80001620:	f84a                	sd	s2,48(sp)
    80001622:	f44e                	sd	s3,40(sp)
    80001624:	f052                	sd	s4,32(sp)
    80001626:	ec56                	sd	s5,24(sp)
    80001628:	e85a                	sd	s6,16(sp)
    8000162a:	e45e                	sd	s7,8(sp)
    8000162c:	e062                	sd	s8,0(sp)
    8000162e:	0880                	addi	s0,sp,80
    80001630:	8baa                	mv	s7,a0
    80001632:	8aae                	mv	s5,a1
    80001634:	8932                	mv	s2,a2
    80001636:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001638:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000163a:	6b05                	lui	s6,0x1
    8000163c:	a035                	j	80001668 <copyin+0x52>
    8000163e:	412984b3          	sub	s1,s3,s2
    80001642:	94da                	add	s1,s1,s6
    80001644:	009a7363          	bgeu	s4,s1,8000164a <copyin+0x34>
    80001648:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000164a:	413905b3          	sub	a1,s2,s3
    8000164e:	0004861b          	sext.w	a2,s1
    80001652:	95aa                	add	a1,a1,a0
    80001654:	8556                	mv	a0,s5
    80001656:	e44ff0ef          	jal	ra,80000c9a <memmove>
    len -= n;
    8000165a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000165e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001660:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001664:	020a0163          	beqz	s4,80001686 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001668:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000166c:	85ce                	mv	a1,s3
    8000166e:	855e                	mv	a0,s7
    80001670:	8e5ff0ef          	jal	ra,80000f54 <walkaddr>
    if(pa0 == 0) {
    80001674:	f569                	bnez	a0,8000163e <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001676:	4601                	li	a2,0
    80001678:	85ce                	mv	a1,s3
    8000167a:	855e                	mv	a0,s7
    8000167c:	e63ff0ef          	jal	ra,800014de <vmfault>
    80001680:	fd5d                	bnez	a0,8000163e <copyin+0x28>
        return -1;
    80001682:	557d                	li	a0,-1
    80001684:	a011                	j	80001688 <copyin+0x72>
  return 0;
    80001686:	4501                	li	a0,0
}
    80001688:	60a6                	ld	ra,72(sp)
    8000168a:	6406                	ld	s0,64(sp)
    8000168c:	74e2                	ld	s1,56(sp)
    8000168e:	7942                	ld	s2,48(sp)
    80001690:	79a2                	ld	s3,40(sp)
    80001692:	7a02                	ld	s4,32(sp)
    80001694:	6ae2                	ld	s5,24(sp)
    80001696:	6b42                	ld	s6,16(sp)
    80001698:	6ba2                	ld	s7,8(sp)
    8000169a:	6c02                	ld	s8,0(sp)
    8000169c:	6161                	addi	sp,sp,80
    8000169e:	8082                	ret
  return 0;
    800016a0:	4501                	li	a0,0
}
    800016a2:	8082                	ret

00000000800016a4 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016a4:	7139                	addi	sp,sp,-64
    800016a6:	fc06                	sd	ra,56(sp)
    800016a8:	f822                	sd	s0,48(sp)
    800016aa:	f426                	sd	s1,40(sp)
    800016ac:	f04a                	sd	s2,32(sp)
    800016ae:	ec4e                	sd	s3,24(sp)
    800016b0:	e852                	sd	s4,16(sp)
    800016b2:	e456                	sd	s5,8(sp)
    800016b4:	e05a                	sd	s6,0(sp)
    800016b6:	0080                	addi	s0,sp,64
    800016b8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016ba:	0000e497          	auipc	s1,0xe
    800016be:	6fe48493          	addi	s1,s1,1790 # 8000fdb8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016c2:	8b26                	mv	s6,s1
    800016c4:	00006a97          	auipc	s5,0x6
    800016c8:	93ca8a93          	addi	s5,s5,-1732 # 80007000 <etext>
    800016cc:	04000937          	lui	s2,0x4000
    800016d0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800016d2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d4:	00014a17          	auipc	s4,0x14
    800016d8:	4e4a0a13          	addi	s4,s4,1252 # 80015bb8 <tickslock>
    char *pa = kalloc();
    800016dc:	bbeff0ef          	jal	ra,80000a9a <kalloc>
    800016e0:	862a                	mv	a2,a0
    if(pa == 0)
    800016e2:	c121                	beqz	a0,80001722 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e4:	416485b3          	sub	a1,s1,s6
    800016e8:	858d                	srai	a1,a1,0x3
    800016ea:	000ab783          	ld	a5,0(s5)
    800016ee:	02f585b3          	mul	a1,a1,a5
    800016f2:	2585                	addiw	a1,a1,1
    800016f4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016f8:	4719                	li	a4,6
    800016fa:	6685                	lui	a3,0x1
    800016fc:	40b905b3          	sub	a1,s2,a1
    80001700:	854e                	mv	a0,s3
    80001702:	941ff0ef          	jal	ra,80001042 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001706:	17848493          	addi	s1,s1,376
    8000170a:	fd4499e3          	bne	s1,s4,800016dc <proc_mapstacks+0x38>
  }
}
    8000170e:	70e2                	ld	ra,56(sp)
    80001710:	7442                	ld	s0,48(sp)
    80001712:	74a2                	ld	s1,40(sp)
    80001714:	7902                	ld	s2,32(sp)
    80001716:	69e2                	ld	s3,24(sp)
    80001718:	6a42                	ld	s4,16(sp)
    8000171a:	6aa2                	ld	s5,8(sp)
    8000171c:	6b02                	ld	s6,0(sp)
    8000171e:	6121                	addi	sp,sp,64
    80001720:	8082                	ret
      panic("kalloc");
    80001722:	00006517          	auipc	a0,0x6
    80001726:	a4e50513          	addi	a0,a0,-1458 # 80007170 <digits+0x138>
    8000172a:	85eff0ef          	jal	ra,80000788 <panic>

000000008000172e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000172e:	7139                	addi	sp,sp,-64
    80001730:	fc06                	sd	ra,56(sp)
    80001732:	f822                	sd	s0,48(sp)
    80001734:	f426                	sd	s1,40(sp)
    80001736:	f04a                	sd	s2,32(sp)
    80001738:	ec4e                	sd	s3,24(sp)
    8000173a:	e852                	sd	s4,16(sp)
    8000173c:	e456                	sd	s5,8(sp)
    8000173e:	e05a                	sd	s6,0(sp)
    80001740:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001742:	00006597          	auipc	a1,0x6
    80001746:	a3658593          	addi	a1,a1,-1482 # 80007178 <digits+0x140>
    8000174a:	0000e517          	auipc	a0,0xe
    8000174e:	23e50513          	addi	a0,a0,574 # 8000f988 <pid_lock>
    80001752:	b98ff0ef          	jal	ra,80000aea <initlock>
  initlock(&wait_lock, "wait_lock");
    80001756:	00006597          	auipc	a1,0x6
    8000175a:	a2a58593          	addi	a1,a1,-1494 # 80007180 <digits+0x148>
    8000175e:	0000e517          	auipc	a0,0xe
    80001762:	24250513          	addi	a0,a0,578 # 8000f9a0 <wait_lock>
    80001766:	b84ff0ef          	jal	ra,80000aea <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	0000e497          	auipc	s1,0xe
    8000176e:	64e48493          	addi	s1,s1,1614 # 8000fdb8 <proc>
      initlock(&p->lock, "proc");
    80001772:	00006b17          	auipc	s6,0x6
    80001776:	a1eb0b13          	addi	s6,s6,-1506 # 80007190 <digits+0x158>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000177a:	8aa6                	mv	s5,s1
    8000177c:	00006a17          	auipc	s4,0x6
    80001780:	884a0a13          	addi	s4,s4,-1916 # 80007000 <etext>
    80001784:	04000937          	lui	s2,0x4000
    80001788:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000178a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178c:	00014997          	auipc	s3,0x14
    80001790:	42c98993          	addi	s3,s3,1068 # 80015bb8 <tickslock>
      initlock(&p->lock, "proc");
    80001794:	85da                	mv	a1,s6
    80001796:	8526                	mv	a0,s1
    80001798:	b52ff0ef          	jal	ra,80000aea <initlock>
      p->state = UNUSED;
    8000179c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017a0:	415487b3          	sub	a5,s1,s5
    800017a4:	878d                	srai	a5,a5,0x3
    800017a6:	000a3703          	ld	a4,0(s4)
    800017aa:	02e787b3          	mul	a5,a5,a4
    800017ae:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde069>
    800017b0:	00d7979b          	slliw	a5,a5,0xd
    800017b4:	40f907b3          	sub	a5,s2,a5
    800017b8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	17848493          	addi	s1,s1,376
    800017be:	fd349be3          	bne	s1,s3,80001794 <procinit+0x66>
  }
}
    800017c2:	70e2                	ld	ra,56(sp)
    800017c4:	7442                	ld	s0,48(sp)
    800017c6:	74a2                	ld	s1,40(sp)
    800017c8:	7902                	ld	s2,32(sp)
    800017ca:	69e2                	ld	s3,24(sp)
    800017cc:	6a42                	ld	s4,16(sp)
    800017ce:	6aa2                	ld	s5,8(sp)
    800017d0:	6b02                	ld	s6,0(sp)
    800017d2:	6121                	addi	sp,sp,64
    800017d4:	8082                	ret

00000000800017d6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017d6:	1141                	addi	sp,sp,-16
    800017d8:	e422                	sd	s0,8(sp)
    800017da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017de:	2501                	sext.w	a0,a0
    800017e0:	6422                	ld	s0,8(sp)
    800017e2:	0141                	addi	sp,sp,16
    800017e4:	8082                	ret

00000000800017e6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017e6:	1141                	addi	sp,sp,-16
    800017e8:	e422                	sd	s0,8(sp)
    800017ea:	0800                	addi	s0,sp,16
    800017ec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017ee:	2781                	sext.w	a5,a5
    800017f0:	079e                	slli	a5,a5,0x7
  return c;
}
    800017f2:	0000e517          	auipc	a0,0xe
    800017f6:	1c650513          	addi	a0,a0,454 # 8000f9b8 <cpus>
    800017fa:	953e                	add	a0,a0,a5
    800017fc:	6422                	ld	s0,8(sp)
    800017fe:	0141                	addi	sp,sp,16
    80001800:	8082                	ret

0000000080001802 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001802:	1101                	addi	sp,sp,-32
    80001804:	ec06                	sd	ra,24(sp)
    80001806:	e822                	sd	s0,16(sp)
    80001808:	e426                	sd	s1,8(sp)
    8000180a:	1000                	addi	s0,sp,32
  push_off();
    8000180c:	b1eff0ef          	jal	ra,80000b2a <push_off>
    80001810:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001812:	2781                	sext.w	a5,a5
    80001814:	079e                	slli	a5,a5,0x7
    80001816:	0000e717          	auipc	a4,0xe
    8000181a:	17270713          	addi	a4,a4,370 # 8000f988 <pid_lock>
    8000181e:	97ba                	add	a5,a5,a4
    80001820:	7b84                	ld	s1,48(a5)
  pop_off();
    80001822:	b8cff0ef          	jal	ra,80000bae <pop_off>
  return p;
}
    80001826:	8526                	mv	a0,s1
    80001828:	60e2                	ld	ra,24(sp)
    8000182a:	6442                	ld	s0,16(sp)
    8000182c:	64a2                	ld	s1,8(sp)
    8000182e:	6105                	addi	sp,sp,32
    80001830:	8082                	ret

0000000080001832 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001832:	7179                	addi	sp,sp,-48
    80001834:	f406                	sd	ra,40(sp)
    80001836:	f022                	sd	s0,32(sp)
    80001838:	ec26                	sd	s1,24(sp)
    8000183a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000183c:	fc7ff0ef          	jal	ra,80001802 <myproc>
    80001840:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001842:	bc0ff0ef          	jal	ra,80000c02 <release>

  if (first) {
    80001846:	00006797          	auipc	a5,0x6
    8000184a:	fea7a783          	lw	a5,-22(a5) # 80007830 <first.1>
    8000184e:	cf8d                	beqz	a5,80001888 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001850:	4505                	li	a0,1
    80001852:	617010ef          	jal	ra,80003668 <fsinit>

    first = 0;
    80001856:	00006797          	auipc	a5,0x6
    8000185a:	fc07ad23          	sw	zero,-38(a5) # 80007830 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000185e:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001862:	00006517          	auipc	a0,0x6
    80001866:	93650513          	addi	a0,a0,-1738 # 80007198 <digits+0x160>
    8000186a:	fca43823          	sd	a0,-48(s0)
    8000186e:	fc043c23          	sd	zero,-40(s0)
    80001872:	fd040593          	addi	a1,s0,-48
    80001876:	6a1020ef          	jal	ra,80004716 <kexec>
    8000187a:	6cbc                	ld	a5,88(s1)
    8000187c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000187e:	6cbc                	ld	a5,88(s1)
    80001880:	7bb8                	ld	a4,112(a5)
    80001882:	57fd                	li	a5,-1
    80001884:	02f70d63          	beq	a4,a5,800018be <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001888:	4f3000ef          	jal	ra,8000257a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000188c:	68a8                	ld	a0,80(s1)
    8000188e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001890:	04000737          	lui	a4,0x4000
    80001894:	00005797          	auipc	a5,0x5
    80001898:	80878793          	addi	a5,a5,-2040 # 8000609c <userret>
    8000189c:	00004697          	auipc	a3,0x4
    800018a0:	76468693          	addi	a3,a3,1892 # 80006000 <_trampoline>
    800018a4:	8f95                	sub	a5,a5,a3
    800018a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800018a8:	0732                	slli	a4,a4,0xc
    800018aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018ac:	577d                	li	a4,-1
    800018ae:	177e                	slli	a4,a4,0x3f
    800018b0:	8d59                	or	a0,a0,a4
    800018b2:	9782                	jalr	a5
}
    800018b4:	70a2                	ld	ra,40(sp)
    800018b6:	7402                	ld	s0,32(sp)
    800018b8:	64e2                	ld	s1,24(sp)
    800018ba:	6145                	addi	sp,sp,48
    800018bc:	8082                	ret
      panic("exec");
    800018be:	00006517          	auipc	a0,0x6
    800018c2:	8e250513          	addi	a0,a0,-1822 # 800071a0 <digits+0x168>
    800018c6:	ec3fe0ef          	jal	ra,80000788 <panic>

00000000800018ca <allocpid>:
{
    800018ca:	1101                	addi	sp,sp,-32
    800018cc:	ec06                	sd	ra,24(sp)
    800018ce:	e822                	sd	s0,16(sp)
    800018d0:	e426                	sd	s1,8(sp)
    800018d2:	e04a                	sd	s2,0(sp)
    800018d4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018d6:	0000e917          	auipc	s2,0xe
    800018da:	0b290913          	addi	s2,s2,178 # 8000f988 <pid_lock>
    800018de:	854a                	mv	a0,s2
    800018e0:	a8aff0ef          	jal	ra,80000b6a <acquire>
  pid = nextpid;
    800018e4:	00006797          	auipc	a5,0x6
    800018e8:	f5078793          	addi	a5,a5,-176 # 80007834 <nextpid>
    800018ec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018ee:	0014871b          	addiw	a4,s1,1
    800018f2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f4:	854a                	mv	a0,s2
    800018f6:	b0cff0ef          	jal	ra,80000c02 <release>
}
    800018fa:	8526                	mv	a0,s1
    800018fc:	60e2                	ld	ra,24(sp)
    800018fe:	6442                	ld	s0,16(sp)
    80001900:	64a2                	ld	s1,8(sp)
    80001902:	6902                	ld	s2,0(sp)
    80001904:	6105                	addi	sp,sp,32
    80001906:	8082                	ret

0000000080001908 <proc_pagetable>:
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	e426                	sd	s1,8(sp)
    80001910:	e04a                	sd	s2,0(sp)
    80001912:	1000                	addi	s0,sp,32
    80001914:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001916:	823ff0ef          	jal	ra,80001138 <uvmcreate>
    8000191a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000191c:	cd05                	beqz	a0,80001954 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000191e:	4729                	li	a4,10
    80001920:	00004697          	auipc	a3,0x4
    80001924:	6e068693          	addi	a3,a3,1760 # 80006000 <_trampoline>
    80001928:	6605                	lui	a2,0x1
    8000192a:	040005b7          	lui	a1,0x4000
    8000192e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	05b2                	slli	a1,a1,0xc
    80001932:	e60ff0ef          	jal	ra,80000f92 <mappages>
    80001936:	02054663          	bltz	a0,80001962 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000193a:	4719                	li	a4,6
    8000193c:	05893683          	ld	a3,88(s2)
    80001940:	6605                	lui	a2,0x1
    80001942:	020005b7          	lui	a1,0x2000
    80001946:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001948:	05b6                	slli	a1,a1,0xd
    8000194a:	8526                	mv	a0,s1
    8000194c:	e46ff0ef          	jal	ra,80000f92 <mappages>
    80001950:	00054f63          	bltz	a0,8000196e <proc_pagetable+0x66>
}
    80001954:	8526                	mv	a0,s1
    80001956:	60e2                	ld	ra,24(sp)
    80001958:	6442                	ld	s0,16(sp)
    8000195a:	64a2                	ld	s1,8(sp)
    8000195c:	6902                	ld	s2,0(sp)
    8000195e:	6105                	addi	sp,sp,32
    80001960:	8082                	ret
    uvmfree(pagetable, 0);
    80001962:	4581                	li	a1,0
    80001964:	8526                	mv	a0,s1
    80001966:	9b3ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000196a:	4481                	li	s1,0
    8000196c:	b7e5                	j	80001954 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000196e:	4681                	li	a3,0
    80001970:	4605                	li	a2,1
    80001972:	040005b7          	lui	a1,0x4000
    80001976:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001978:	05b2                	slli	a1,a1,0xc
    8000197a:	8526                	mv	a0,s1
    8000197c:	fe2ff0ef          	jal	ra,8000115e <uvmunmap>
    uvmfree(pagetable, 0);
    80001980:	4581                	li	a1,0
    80001982:	8526                	mv	a0,s1
    80001984:	995ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001988:	4481                	li	s1,0
    8000198a:	b7e9                	j	80001954 <proc_pagetable+0x4c>

000000008000198c <proc_freepagetable>:
{
    8000198c:	1101                	addi	sp,sp,-32
    8000198e:	ec06                	sd	ra,24(sp)
    80001990:	e822                	sd	s0,16(sp)
    80001992:	e426                	sd	s1,8(sp)
    80001994:	e04a                	sd	s2,0(sp)
    80001996:	1000                	addi	s0,sp,32
    80001998:	84aa                	mv	s1,a0
    8000199a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000199c:	4681                	li	a3,0
    8000199e:	4605                	li	a2,1
    800019a0:	040005b7          	lui	a1,0x4000
    800019a4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019a6:	05b2                	slli	a1,a1,0xc
    800019a8:	fb6ff0ef          	jal	ra,8000115e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019ac:	4681                	li	a3,0
    800019ae:	4605                	li	a2,1
    800019b0:	020005b7          	lui	a1,0x2000
    800019b4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019b6:	05b6                	slli	a1,a1,0xd
    800019b8:	8526                	mv	a0,s1
    800019ba:	fa4ff0ef          	jal	ra,8000115e <uvmunmap>
  uvmfree(pagetable, sz);
    800019be:	85ca                	mv	a1,s2
    800019c0:	8526                	mv	a0,s1
    800019c2:	957ff0ef          	jal	ra,80001318 <uvmfree>
}
    800019c6:	60e2                	ld	ra,24(sp)
    800019c8:	6442                	ld	s0,16(sp)
    800019ca:	64a2                	ld	s1,8(sp)
    800019cc:	6902                	ld	s2,0(sp)
    800019ce:	6105                	addi	sp,sp,32
    800019d0:	8082                	ret

00000000800019d2 <freeproc>:
{
    800019d2:	1101                	addi	sp,sp,-32
    800019d4:	ec06                	sd	ra,24(sp)
    800019d6:	e822                	sd	s0,16(sp)
    800019d8:	e426                	sd	s1,8(sp)
    800019da:	1000                	addi	s0,sp,32
    800019dc:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019de:	6d28                	ld	a0,88(a0)
    800019e0:	c119                	beqz	a0,800019e6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019e2:	fd7fe0ef          	jal	ra,800009b8 <kfree>
  p->trapframe = 0;
    800019e6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019ea:	68a8                	ld	a0,80(s1)
    800019ec:	c501                	beqz	a0,800019f4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019ee:	64ac                	ld	a1,72(s1)
    800019f0:	f9dff0ef          	jal	ra,8000198c <proc_freepagetable>
  p->pagetable = 0;
    800019f4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019f8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019fc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a00:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a04:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a08:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a0c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a10:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a14:	0004ac23          	sw	zero,24(s1)
}
    80001a18:	60e2                	ld	ra,24(sp)
    80001a1a:	6442                	ld	s0,16(sp)
    80001a1c:	64a2                	ld	s1,8(sp)
    80001a1e:	6105                	addi	sp,sp,32
    80001a20:	8082                	ret

0000000080001a22 <allocproc>:
{
    80001a22:	1101                	addi	sp,sp,-32
    80001a24:	ec06                	sd	ra,24(sp)
    80001a26:	e822                	sd	s0,16(sp)
    80001a28:	e426                	sd	s1,8(sp)
    80001a2a:	e04a                	sd	s2,0(sp)
    80001a2c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a2e:	0000e497          	auipc	s1,0xe
    80001a32:	38a48493          	addi	s1,s1,906 # 8000fdb8 <proc>
    80001a36:	00014917          	auipc	s2,0x14
    80001a3a:	18290913          	addi	s2,s2,386 # 80015bb8 <tickslock>
    acquire(&p->lock);
    80001a3e:	8526                	mv	a0,s1
    80001a40:	92aff0ef          	jal	ra,80000b6a <acquire>
    if(p->state == UNUSED) {
    80001a44:	4c9c                	lw	a5,24(s1)
    80001a46:	cb91                	beqz	a5,80001a5a <allocproc+0x38>
      release(&p->lock);
    80001a48:	8526                	mv	a0,s1
    80001a4a:	9b8ff0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a4e:	17848493          	addi	s1,s1,376
    80001a52:	ff2496e3          	bne	s1,s2,80001a3e <allocproc+0x1c>
  return 0;
    80001a56:	4481                	li	s1,0
    80001a58:	a0b1                	j	80001aa4 <allocproc+0x82>
  p->pid = allocpid();
    80001a5a:	e71ff0ef          	jal	ra,800018ca <allocpid>
    80001a5e:	d888                	sw	a0,48(s1)
  p->priority = 10; // Prioridade intermediaria (0-19)
    80001a60:	47a9                	li	a5,10
    80001a62:	16f4a423          	sw	a5,360(s1)
  p->runs = 0;
    80001a66:	1604b823          	sd	zero,368(s1)
  p->state = USED;
    80001a6a:	4785                	li	a5,1
    80001a6c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a6e:	82cff0ef          	jal	ra,80000a9a <kalloc>
    80001a72:	892a                	mv	s2,a0
    80001a74:	eca8                	sd	a0,88(s1)
    80001a76:	cd15                	beqz	a0,80001ab2 <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001a78:	8526                	mv	a0,s1
    80001a7a:	e8fff0ef          	jal	ra,80001908 <proc_pagetable>
    80001a7e:	892a                	mv	s2,a0
    80001a80:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a82:	c121                	beqz	a0,80001ac2 <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001a84:	07000613          	li	a2,112
    80001a88:	4581                	li	a1,0
    80001a8a:	06048513          	addi	a0,s1,96
    80001a8e:	9b0ff0ef          	jal	ra,80000c3e <memset>
  p->context.ra = (uint64)forkret;
    80001a92:	00000797          	auipc	a5,0x0
    80001a96:	da078793          	addi	a5,a5,-608 # 80001832 <forkret>
    80001a9a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a9c:	60bc                	ld	a5,64(s1)
    80001a9e:	6705                	lui	a4,0x1
    80001aa0:	97ba                	add	a5,a5,a4
    80001aa2:	f4bc                	sd	a5,104(s1)
}
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	60e2                	ld	ra,24(sp)
    80001aa8:	6442                	ld	s0,16(sp)
    80001aaa:	64a2                	ld	s1,8(sp)
    80001aac:	6902                	ld	s2,0(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret
    freeproc(p);
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	f1fff0ef          	jal	ra,800019d2 <freeproc>
    release(&p->lock);
    80001ab8:	8526                	mv	a0,s1
    80001aba:	948ff0ef          	jal	ra,80000c02 <release>
    return 0;
    80001abe:	84ca                	mv	s1,s2
    80001ac0:	b7d5                	j	80001aa4 <allocproc+0x82>
    freeproc(p);
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	f0fff0ef          	jal	ra,800019d2 <freeproc>
    release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	938ff0ef          	jal	ra,80000c02 <release>
    return 0;
    80001ace:	84ca                	mv	s1,s2
    80001ad0:	bfd1                	j	80001aa4 <allocproc+0x82>

0000000080001ad2 <userinit>:
{
    80001ad2:	1101                	addi	sp,sp,-32
    80001ad4:	ec06                	sd	ra,24(sp)
    80001ad6:	e822                	sd	s0,16(sp)
    80001ad8:	e426                	sd	s1,8(sp)
    80001ada:	1000                	addi	s0,sp,32
  p = allocproc();
    80001adc:	f47ff0ef          	jal	ra,80001a22 <allocproc>
    80001ae0:	84aa                	mv	s1,a0
  initproc = p;
    80001ae2:	00006797          	auipc	a5,0x6
    80001ae6:	d8a7bf23          	sd	a0,-610(a5) # 80007880 <initproc>
  p->cwd = namei("/");
    80001aea:	00005517          	auipc	a0,0x5
    80001aee:	6be50513          	addi	a0,a0,1726 # 800071a8 <digits+0x170>
    80001af2:	07a020ef          	jal	ra,80003b6c <namei>
    80001af6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001afa:	478d                	li	a5,3
    80001afc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001afe:	8526                	mv	a0,s1
    80001b00:	902ff0ef          	jal	ra,80000c02 <release>
}
    80001b04:	60e2                	ld	ra,24(sp)
    80001b06:	6442                	ld	s0,16(sp)
    80001b08:	64a2                	ld	s1,8(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <growproc>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b1c:	ce7ff0ef          	jal	ra,80001802 <myproc>
    80001b20:	892a                	mv	s2,a0
  sz = p->sz;
    80001b22:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b24:	02905963          	blez	s1,80001b56 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b28:	00b48633          	add	a2,s1,a1
    80001b2c:	020007b7          	lui	a5,0x2000
    80001b30:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001b32:	07b6                	slli	a5,a5,0xd
    80001b34:	02c7ea63          	bltu	a5,a2,80001b68 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b38:	4691                	li	a3,4
    80001b3a:	6928                	ld	a0,80(a0)
    80001b3c:	ee2ff0ef          	jal	ra,8000121e <uvmalloc>
    80001b40:	85aa                	mv	a1,a0
    80001b42:	c50d                	beqz	a0,80001b6c <growproc+0x5e>
  p->sz = sz;
    80001b44:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b48:	4501                	li	a0,0
}
    80001b4a:	60e2                	ld	ra,24(sp)
    80001b4c:	6442                	ld	s0,16(sp)
    80001b4e:	64a2                	ld	s1,8(sp)
    80001b50:	6902                	ld	s2,0(sp)
    80001b52:	6105                	addi	sp,sp,32
    80001b54:	8082                	ret
  } else if(n < 0){
    80001b56:	fe04d7e3          	bgez	s1,80001b44 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b5a:	00b48633          	add	a2,s1,a1
    80001b5e:	6928                	ld	a0,80(a0)
    80001b60:	e7aff0ef          	jal	ra,800011da <uvmdealloc>
    80001b64:	85aa                	mv	a1,a0
    80001b66:	bff9                	j	80001b44 <growproc+0x36>
      return -1;
    80001b68:	557d                	li	a0,-1
    80001b6a:	b7c5                	j	80001b4a <growproc+0x3c>
      return -1;
    80001b6c:	557d                	li	a0,-1
    80001b6e:	bff1                	j	80001b4a <growproc+0x3c>

0000000080001b70 <kfork>:
{
    80001b70:	7139                	addi	sp,sp,-64
    80001b72:	fc06                	sd	ra,56(sp)
    80001b74:	f822                	sd	s0,48(sp)
    80001b76:	f426                	sd	s1,40(sp)
    80001b78:	f04a                	sd	s2,32(sp)
    80001b7a:	ec4e                	sd	s3,24(sp)
    80001b7c:	e852                	sd	s4,16(sp)
    80001b7e:	e456                	sd	s5,8(sp)
    80001b80:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b82:	c81ff0ef          	jal	ra,80001802 <myproc>
    80001b86:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b88:	e9bff0ef          	jal	ra,80001a22 <allocproc>
    80001b8c:	0e050663          	beqz	a0,80001c78 <kfork+0x108>
    80001b90:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b92:	048ab603          	ld	a2,72(s5)
    80001b96:	692c                	ld	a1,80(a0)
    80001b98:	050ab503          	ld	a0,80(s5)
    80001b9c:	faeff0ef          	jal	ra,8000134a <uvmcopy>
    80001ba0:	04054863          	bltz	a0,80001bf0 <kfork+0x80>
  np->sz = p->sz;
    80001ba4:	048ab783          	ld	a5,72(s5)
    80001ba8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001bac:	058ab683          	ld	a3,88(s5)
    80001bb0:	87b6                	mv	a5,a3
    80001bb2:	058a3703          	ld	a4,88(s4)
    80001bb6:	12068693          	addi	a3,a3,288
    80001bba:	0007b803          	ld	a6,0(a5)
    80001bbe:	6788                	ld	a0,8(a5)
    80001bc0:	6b8c                	ld	a1,16(a5)
    80001bc2:	6f90                	ld	a2,24(a5)
    80001bc4:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bc8:	e708                	sd	a0,8(a4)
    80001bca:	eb0c                	sd	a1,16(a4)
    80001bcc:	ef10                	sd	a2,24(a4)
    80001bce:	02078793          	addi	a5,a5,32
    80001bd2:	02070713          	addi	a4,a4,32
    80001bd6:	fed792e3          	bne	a5,a3,80001bba <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bda:	058a3783          	ld	a5,88(s4)
    80001bde:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001be2:	0d0a8493          	addi	s1,s5,208
    80001be6:	0d0a0913          	addi	s2,s4,208
    80001bea:	150a8993          	addi	s3,s5,336
    80001bee:	a829                	j	80001c08 <kfork+0x98>
    freeproc(np);
    80001bf0:	8552                	mv	a0,s4
    80001bf2:	de1ff0ef          	jal	ra,800019d2 <freeproc>
    release(&np->lock);
    80001bf6:	8552                	mv	a0,s4
    80001bf8:	80aff0ef          	jal	ra,80000c02 <release>
    return -1;
    80001bfc:	597d                	li	s2,-1
    80001bfe:	a09d                	j	80001c64 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001c00:	04a1                	addi	s1,s1,8
    80001c02:	0921                	addi	s2,s2,8
    80001c04:	01348963          	beq	s1,s3,80001c16 <kfork+0xa6>
    if(p->ofile[i])
    80001c08:	6088                	ld	a0,0(s1)
    80001c0a:	d97d                	beqz	a0,80001c00 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c0c:	518020ef          	jal	ra,80004124 <filedup>
    80001c10:	00a93023          	sd	a0,0(s2)
    80001c14:	b7f5                	j	80001c00 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001c16:	150ab503          	ld	a0,336(s5)
    80001c1a:	728010ef          	jal	ra,80003342 <idup>
    80001c1e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c22:	4641                	li	a2,16
    80001c24:	158a8593          	addi	a1,s5,344
    80001c28:	158a0513          	addi	a0,s4,344
    80001c2c:	958ff0ef          	jal	ra,80000d84 <safestrcpy>
  pid = np->pid;
    80001c30:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c34:	8552                	mv	a0,s4
    80001c36:	fcdfe0ef          	jal	ra,80000c02 <release>
  acquire(&wait_lock);
    80001c3a:	0000e497          	auipc	s1,0xe
    80001c3e:	d6648493          	addi	s1,s1,-666 # 8000f9a0 <wait_lock>
    80001c42:	8526                	mv	a0,s1
    80001c44:	f27fe0ef          	jal	ra,80000b6a <acquire>
  np->parent = p;
    80001c48:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fb5fe0ef          	jal	ra,80000c02 <release>
  acquire(&np->lock);
    80001c52:	8552                	mv	a0,s4
    80001c54:	f17fe0ef          	jal	ra,80000b6a <acquire>
  np->state = RUNNABLE;
    80001c58:	478d                	li	a5,3
    80001c5a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c5e:	8552                	mv	a0,s4
    80001c60:	fa3fe0ef          	jal	ra,80000c02 <release>
}
    80001c64:	854a                	mv	a0,s2
    80001c66:	70e2                	ld	ra,56(sp)
    80001c68:	7442                	ld	s0,48(sp)
    80001c6a:	74a2                	ld	s1,40(sp)
    80001c6c:	7902                	ld	s2,32(sp)
    80001c6e:	69e2                	ld	s3,24(sp)
    80001c70:	6a42                	ld	s4,16(sp)
    80001c72:	6aa2                	ld	s5,8(sp)
    80001c74:	6121                	addi	sp,sp,64
    80001c76:	8082                	ret
    return -1;
    80001c78:	597d                	li	s2,-1
    80001c7a:	b7ed                	j	80001c64 <kfork+0xf4>

0000000080001c7c <scheduler>:
{
    80001c7c:	711d                	addi	sp,sp,-96
    80001c7e:	ec86                	sd	ra,88(sp)
    80001c80:	e8a2                	sd	s0,80(sp)
    80001c82:	e4a6                	sd	s1,72(sp)
    80001c84:	e0ca                	sd	s2,64(sp)
    80001c86:	fc4e                	sd	s3,56(sp)
    80001c88:	f852                	sd	s4,48(sp)
    80001c8a:	f456                	sd	s5,40(sp)
    80001c8c:	f05a                	sd	s6,32(sp)
    80001c8e:	ec5e                	sd	s7,24(sp)
    80001c90:	e862                	sd	s8,16(sp)
    80001c92:	e466                	sd	s9,8(sp)
    80001c94:	1080                	addi	s0,sp,96
    80001c96:	8792                	mv	a5,tp
  int id = r_tp();
    80001c98:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c9a:	00779b13          	slli	s6,a5,0x7
    80001c9e:	0000e717          	auipc	a4,0xe
    80001ca2:	cea70713          	addi	a4,a4,-790 # 8000f988 <pid_lock>
    80001ca6:	975a                	add	a4,a4,s6
    80001ca8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001cac:	0000e717          	auipc	a4,0xe
    80001cb0:	d1470713          	addi	a4,a4,-748 # 8000f9c0 <cpus+0x8>
    80001cb4:	9b3a                	add	s6,s6,a4
    int highest = 9999; // menor número = maior prioridade
    80001cb6:	6c09                	lui	s8,0x2
    80001cb8:	70fc0c13          	addi	s8,s8,1807 # 270f <_entry-0x7fffd8f1>
      if(p->state == RUNNABLE && p->priority < highest)
    80001cbc:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001cbe:	00014917          	auipc	s2,0x14
    80001cc2:	efa90913          	addi	s2,s2,-262 # 80015bb8 <tickslock>
        p->state = RUNNING;
    80001cc6:	4b91                	li	s7,4
        c->proc = p;
    80001cc8:	079e                	slli	a5,a5,0x7
    80001cca:	0000ea97          	auipc	s5,0xe
    80001cce:	cbea8a93          	addi	s5,s5,-834 # 8000f988 <pid_lock>
    80001cd2:	9abe                	add	s5,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cd4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cd8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cdc:	10079073          	csrw	sstatus,a5
    int highest = 9999; // menor número = maior prioridade
    80001ce0:	8a62                	mv	s4,s8
    for(p = proc; p < &proc[NPROC]; p++){
    80001ce2:	0000e497          	auipc	s1,0xe
    80001ce6:	0d648493          	addi	s1,s1,214 # 8000fdb8 <proc>
    80001cea:	a811                	j	80001cfe <scheduler+0x82>
    80001cec:	00070a1b          	sext.w	s4,a4
      release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	f11fe0ef          	jal	ra,80000c02 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001cf6:	17848493          	addi	s1,s1,376
    80001cfa:	03248063          	beq	s1,s2,80001d1a <scheduler+0x9e>
      acquire(&p->lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	e6bfe0ef          	jal	ra,80000b6a <acquire>
      if(p->state == RUNNABLE && p->priority < highest)
    80001d04:	4c9c                	lw	a5,24(s1)
    80001d06:	ff3795e3          	bne	a5,s3,80001cf0 <scheduler+0x74>
    80001d0a:	1684a783          	lw	a5,360(s1)
    80001d0e:	873e                	mv	a4,a5
    80001d10:	2781                	sext.w	a5,a5
    80001d12:	fcfa5de3          	bge	s4,a5,80001cec <scheduler+0x70>
    80001d16:	8752                	mv	a4,s4
    80001d18:	bfd1                	j	80001cec <scheduler+0x70>
    for(p = proc; p < &proc[NPROC]; p++){
    80001d1a:	0000e497          	auipc	s1,0xe
    80001d1e:	09e48493          	addi	s1,s1,158 # 8000fdb8 <proc>
    80001d22:	a801                	j	80001d32 <scheduler+0xb6>
      release(&p->lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	eddfe0ef          	jal	ra,80000c02 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001d2a:	17848493          	addi	s1,s1,376
    80001d2e:	fb2483e3          	beq	s1,s2,80001cd4 <scheduler+0x58>
      acquire(&p->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	e37fe0ef          	jal	ra,80000b6a <acquire>
      if(p->state == RUNNABLE && p->priority == highest){
    80001d38:	4c9c                	lw	a5,24(s1)
    80001d3a:	ff3795e3          	bne	a5,s3,80001d24 <scheduler+0xa8>
    80001d3e:	1684a783          	lw	a5,360(s1)
    80001d42:	ff4791e3          	bne	a5,s4,80001d24 <scheduler+0xa8>
        p->state = RUNNING;
    80001d46:	0174ac23          	sw	s7,24(s1)
        p->runs++;
    80001d4a:	1704b783          	ld	a5,368(s1)
    80001d4e:	0785                	addi	a5,a5,1
    80001d50:	16f4b823          	sd	a5,368(s1)
        c->proc = p;
    80001d54:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001d58:	06048593          	addi	a1,s1,96
    80001d5c:	855a                	mv	a0,s6
    80001d5e:	776000ef          	jal	ra,800024d4 <swtch>
        c->proc = 0;
    80001d62:	020ab823          	sd	zero,48(s5)
    80001d66:	bf7d                	j	80001d24 <scheduler+0xa8>

0000000080001d68 <sched>:
{
    80001d68:	7179                	addi	sp,sp,-48
    80001d6a:	f406                	sd	ra,40(sp)
    80001d6c:	f022                	sd	s0,32(sp)
    80001d6e:	ec26                	sd	s1,24(sp)
    80001d70:	e84a                	sd	s2,16(sp)
    80001d72:	e44e                	sd	s3,8(sp)
    80001d74:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d76:	a8dff0ef          	jal	ra,80001802 <myproc>
    80001d7a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d7c:	d85fe0ef          	jal	ra,80000b00 <holding>
    80001d80:	c92d                	beqz	a0,80001df2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d82:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d84:	2781                	sext.w	a5,a5
    80001d86:	079e                	slli	a5,a5,0x7
    80001d88:	0000e717          	auipc	a4,0xe
    80001d8c:	c0070713          	addi	a4,a4,-1024 # 8000f988 <pid_lock>
    80001d90:	97ba                	add	a5,a5,a4
    80001d92:	0a87a703          	lw	a4,168(a5)
    80001d96:	4785                	li	a5,1
    80001d98:	06f71363          	bne	a4,a5,80001dfe <sched+0x96>
  if(p->state == RUNNING)
    80001d9c:	4c98                	lw	a4,24(s1)
    80001d9e:	4791                	li	a5,4
    80001da0:	06f70563          	beq	a4,a5,80001e0a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001da8:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001daa:	e7b5                	bnez	a5,80001e16 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dac:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001dae:	0000e917          	auipc	s2,0xe
    80001db2:	bda90913          	addi	s2,s2,-1062 # 8000f988 <pid_lock>
    80001db6:	2781                	sext.w	a5,a5
    80001db8:	079e                	slli	a5,a5,0x7
    80001dba:	97ca                	add	a5,a5,s2
    80001dbc:	0ac7a983          	lw	s3,172(a5)
    80001dc0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001dc2:	2781                	sext.w	a5,a5
    80001dc4:	079e                	slli	a5,a5,0x7
    80001dc6:	0000e597          	auipc	a1,0xe
    80001dca:	bfa58593          	addi	a1,a1,-1030 # 8000f9c0 <cpus+0x8>
    80001dce:	95be                	add	a1,a1,a5
    80001dd0:	06048513          	addi	a0,s1,96
    80001dd4:	700000ef          	jal	ra,800024d4 <swtch>
    80001dd8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001dda:	2781                	sext.w	a5,a5
    80001ddc:	079e                	slli	a5,a5,0x7
    80001dde:	993e                	add	s2,s2,a5
    80001de0:	0b392623          	sw	s3,172(s2)
}
    80001de4:	70a2                	ld	ra,40(sp)
    80001de6:	7402                	ld	s0,32(sp)
    80001de8:	64e2                	ld	s1,24(sp)
    80001dea:	6942                	ld	s2,16(sp)
    80001dec:	69a2                	ld	s3,8(sp)
    80001dee:	6145                	addi	sp,sp,48
    80001df0:	8082                	ret
    panic("sched p->lock");
    80001df2:	00005517          	auipc	a0,0x5
    80001df6:	3be50513          	addi	a0,a0,958 # 800071b0 <digits+0x178>
    80001dfa:	98ffe0ef          	jal	ra,80000788 <panic>
    panic("sched locks");
    80001dfe:	00005517          	auipc	a0,0x5
    80001e02:	3c250513          	addi	a0,a0,962 # 800071c0 <digits+0x188>
    80001e06:	983fe0ef          	jal	ra,80000788 <panic>
    panic("sched RUNNING");
    80001e0a:	00005517          	auipc	a0,0x5
    80001e0e:	3c650513          	addi	a0,a0,966 # 800071d0 <digits+0x198>
    80001e12:	977fe0ef          	jal	ra,80000788 <panic>
    panic("sched interruptible");
    80001e16:	00005517          	auipc	a0,0x5
    80001e1a:	3ca50513          	addi	a0,a0,970 # 800071e0 <digits+0x1a8>
    80001e1e:	96bfe0ef          	jal	ra,80000788 <panic>

0000000080001e22 <yield>:
{
    80001e22:	1101                	addi	sp,sp,-32
    80001e24:	ec06                	sd	ra,24(sp)
    80001e26:	e822                	sd	s0,16(sp)
    80001e28:	e426                	sd	s1,8(sp)
    80001e2a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e2c:	9d7ff0ef          	jal	ra,80001802 <myproc>
    80001e30:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e32:	d39fe0ef          	jal	ra,80000b6a <acquire>
  p->state = RUNNABLE;
    80001e36:	478d                	li	a5,3
    80001e38:	cc9c                	sw	a5,24(s1)
  sched();
    80001e3a:	f2fff0ef          	jal	ra,80001d68 <sched>
  release(&p->lock);
    80001e3e:	8526                	mv	a0,s1
    80001e40:	dc3fe0ef          	jal	ra,80000c02 <release>
}
    80001e44:	60e2                	ld	ra,24(sp)
    80001e46:	6442                	ld	s0,16(sp)
    80001e48:	64a2                	ld	s1,8(sp)
    80001e4a:	6105                	addi	sp,sp,32
    80001e4c:	8082                	ret

0000000080001e4e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001e4e:	7179                	addi	sp,sp,-48
    80001e50:	f406                	sd	ra,40(sp)
    80001e52:	f022                	sd	s0,32(sp)
    80001e54:	ec26                	sd	s1,24(sp)
    80001e56:	e84a                	sd	s2,16(sp)
    80001e58:	e44e                	sd	s3,8(sp)
    80001e5a:	1800                	addi	s0,sp,48
    80001e5c:	89aa                	mv	s3,a0
    80001e5e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e60:	9a3ff0ef          	jal	ra,80001802 <myproc>
    80001e64:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e66:	d05fe0ef          	jal	ra,80000b6a <acquire>
  release(lk);
    80001e6a:	854a                	mv	a0,s2
    80001e6c:	d97fe0ef          	jal	ra,80000c02 <release>

  // Go to sleep.
  p->chan = chan;
    80001e70:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e74:	4789                	li	a5,2
    80001e76:	cc9c                	sw	a5,24(s1)

  sched();
    80001e78:	ef1ff0ef          	jal	ra,80001d68 <sched>

  // Tidy up.
  p->chan = 0;
    80001e7c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	d81fe0ef          	jal	ra,80000c02 <release>
  acquire(lk);
    80001e86:	854a                	mv	a0,s2
    80001e88:	ce3fe0ef          	jal	ra,80000b6a <acquire>
}
    80001e8c:	70a2                	ld	ra,40(sp)
    80001e8e:	7402                	ld	s0,32(sp)
    80001e90:	64e2                	ld	s1,24(sp)
    80001e92:	6942                	ld	s2,16(sp)
    80001e94:	69a2                	ld	s3,8(sp)
    80001e96:	6145                	addi	sp,sp,48
    80001e98:	8082                	ret

0000000080001e9a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e9a:	7139                	addi	sp,sp,-64
    80001e9c:	fc06                	sd	ra,56(sp)
    80001e9e:	f822                	sd	s0,48(sp)
    80001ea0:	f426                	sd	s1,40(sp)
    80001ea2:	f04a                	sd	s2,32(sp)
    80001ea4:	ec4e                	sd	s3,24(sp)
    80001ea6:	e852                	sd	s4,16(sp)
    80001ea8:	e456                	sd	s5,8(sp)
    80001eaa:	0080                	addi	s0,sp,64
    80001eac:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001eae:	0000e497          	auipc	s1,0xe
    80001eb2:	f0a48493          	addi	s1,s1,-246 # 8000fdb8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001eb6:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001eb8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eba:	00014917          	auipc	s2,0x14
    80001ebe:	cfe90913          	addi	s2,s2,-770 # 80015bb8 <tickslock>
    80001ec2:	a801                	j	80001ed2 <wakeup+0x38>
      }
      release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	d3dfe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eca:	17848493          	addi	s1,s1,376
    80001ece:	03248263          	beq	s1,s2,80001ef2 <wakeup+0x58>
    if(p != myproc()){
    80001ed2:	931ff0ef          	jal	ra,80001802 <myproc>
    80001ed6:	fea48ae3          	beq	s1,a0,80001eca <wakeup+0x30>
      acquire(&p->lock);
    80001eda:	8526                	mv	a0,s1
    80001edc:	c8ffe0ef          	jal	ra,80000b6a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001ee0:	4c9c                	lw	a5,24(s1)
    80001ee2:	ff3791e3          	bne	a5,s3,80001ec4 <wakeup+0x2a>
    80001ee6:	709c                	ld	a5,32(s1)
    80001ee8:	fd479ee3          	bne	a5,s4,80001ec4 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001eec:	0154ac23          	sw	s5,24(s1)
    80001ef0:	bfd1                	j	80001ec4 <wakeup+0x2a>
    }
  }
}
    80001ef2:	70e2                	ld	ra,56(sp)
    80001ef4:	7442                	ld	s0,48(sp)
    80001ef6:	74a2                	ld	s1,40(sp)
    80001ef8:	7902                	ld	s2,32(sp)
    80001efa:	69e2                	ld	s3,24(sp)
    80001efc:	6a42                	ld	s4,16(sp)
    80001efe:	6aa2                	ld	s5,8(sp)
    80001f00:	6121                	addi	sp,sp,64
    80001f02:	8082                	ret

0000000080001f04 <reparent>:
{
    80001f04:	7179                	addi	sp,sp,-48
    80001f06:	f406                	sd	ra,40(sp)
    80001f08:	f022                	sd	s0,32(sp)
    80001f0a:	ec26                	sd	s1,24(sp)
    80001f0c:	e84a                	sd	s2,16(sp)
    80001f0e:	e44e                	sd	s3,8(sp)
    80001f10:	e052                	sd	s4,0(sp)
    80001f12:	1800                	addi	s0,sp,48
    80001f14:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f16:	0000e497          	auipc	s1,0xe
    80001f1a:	ea248493          	addi	s1,s1,-350 # 8000fdb8 <proc>
      pp->parent = initproc;
    80001f1e:	00006a17          	auipc	s4,0x6
    80001f22:	962a0a13          	addi	s4,s4,-1694 # 80007880 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f26:	00014997          	auipc	s3,0x14
    80001f2a:	c9298993          	addi	s3,s3,-878 # 80015bb8 <tickslock>
    80001f2e:	a029                	j	80001f38 <reparent+0x34>
    80001f30:	17848493          	addi	s1,s1,376
    80001f34:	01348b63          	beq	s1,s3,80001f4a <reparent+0x46>
    if(pp->parent == p){
    80001f38:	7c9c                	ld	a5,56(s1)
    80001f3a:	ff279be3          	bne	a5,s2,80001f30 <reparent+0x2c>
      pp->parent = initproc;
    80001f3e:	000a3503          	ld	a0,0(s4)
    80001f42:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f44:	f57ff0ef          	jal	ra,80001e9a <wakeup>
    80001f48:	b7e5                	j	80001f30 <reparent+0x2c>
}
    80001f4a:	70a2                	ld	ra,40(sp)
    80001f4c:	7402                	ld	s0,32(sp)
    80001f4e:	64e2                	ld	s1,24(sp)
    80001f50:	6942                	ld	s2,16(sp)
    80001f52:	69a2                	ld	s3,8(sp)
    80001f54:	6a02                	ld	s4,0(sp)
    80001f56:	6145                	addi	sp,sp,48
    80001f58:	8082                	ret

0000000080001f5a <kexit>:
{
    80001f5a:	7179                	addi	sp,sp,-48
    80001f5c:	f406                	sd	ra,40(sp)
    80001f5e:	f022                	sd	s0,32(sp)
    80001f60:	ec26                	sd	s1,24(sp)
    80001f62:	e84a                	sd	s2,16(sp)
    80001f64:	e44e                	sd	s3,8(sp)
    80001f66:	e052                	sd	s4,0(sp)
    80001f68:	1800                	addi	s0,sp,48
    80001f6a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f6c:	897ff0ef          	jal	ra,80001802 <myproc>
    80001f70:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f72:	00006797          	auipc	a5,0x6
    80001f76:	90e7b783          	ld	a5,-1778(a5) # 80007880 <initproc>
    80001f7a:	0d050493          	addi	s1,a0,208
    80001f7e:	15050913          	addi	s2,a0,336
    80001f82:	00a79f63          	bne	a5,a0,80001fa0 <kexit+0x46>
    panic("init exiting");
    80001f86:	00005517          	auipc	a0,0x5
    80001f8a:	27250513          	addi	a0,a0,626 # 800071f8 <digits+0x1c0>
    80001f8e:	ffafe0ef          	jal	ra,80000788 <panic>
      fileclose(f);
    80001f92:	1d8020ef          	jal	ra,8000416a <fileclose>
      p->ofile[fd] = 0;
    80001f96:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f9a:	04a1                	addi	s1,s1,8
    80001f9c:	01248563          	beq	s1,s2,80001fa6 <kexit+0x4c>
    if(p->ofile[fd]){
    80001fa0:	6088                	ld	a0,0(s1)
    80001fa2:	f965                	bnez	a0,80001f92 <kexit+0x38>
    80001fa4:	bfdd                	j	80001f9a <kexit+0x40>
  begin_op();
    80001fa6:	5bb010ef          	jal	ra,80003d60 <begin_op>
  iput(p->cwd);
    80001faa:	1509b503          	ld	a0,336(s3)
    80001fae:	548010ef          	jal	ra,800034f6 <iput>
  end_op();
    80001fb2:	61d010ef          	jal	ra,80003dce <end_op>
  p->cwd = 0;
    80001fb6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001fba:	0000e497          	auipc	s1,0xe
    80001fbe:	9e648493          	addi	s1,s1,-1562 # 8000f9a0 <wait_lock>
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	ba7fe0ef          	jal	ra,80000b6a <acquire>
  reparent(p);
    80001fc8:	854e                	mv	a0,s3
    80001fca:	f3bff0ef          	jal	ra,80001f04 <reparent>
  wakeup(p->parent);
    80001fce:	0389b503          	ld	a0,56(s3)
    80001fd2:	ec9ff0ef          	jal	ra,80001e9a <wakeup>
  acquire(&p->lock);
    80001fd6:	854e                	mv	a0,s3
    80001fd8:	b93fe0ef          	jal	ra,80000b6a <acquire>
  p->xstate = status;
    80001fdc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001fe0:	4795                	li	a5,5
    80001fe2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	c1bfe0ef          	jal	ra,80000c02 <release>
  sched();
    80001fec:	d7dff0ef          	jal	ra,80001d68 <sched>
  panic("zombie exit");
    80001ff0:	00005517          	auipc	a0,0x5
    80001ff4:	21850513          	addi	a0,a0,536 # 80007208 <digits+0x1d0>
    80001ff8:	f90fe0ef          	jal	ra,80000788 <panic>

0000000080001ffc <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001ffc:	7179                	addi	sp,sp,-48
    80001ffe:	f406                	sd	ra,40(sp)
    80002000:	f022                	sd	s0,32(sp)
    80002002:	ec26                	sd	s1,24(sp)
    80002004:	e84a                	sd	s2,16(sp)
    80002006:	e44e                	sd	s3,8(sp)
    80002008:	1800                	addi	s0,sp,48
    8000200a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000200c:	0000e497          	auipc	s1,0xe
    80002010:	dac48493          	addi	s1,s1,-596 # 8000fdb8 <proc>
    80002014:	00014997          	auipc	s3,0x14
    80002018:	ba498993          	addi	s3,s3,-1116 # 80015bb8 <tickslock>
    acquire(&p->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	b4dfe0ef          	jal	ra,80000b6a <acquire>
    if(p->pid == pid){
    80002022:	589c                	lw	a5,48(s1)
    80002024:	01278b63          	beq	a5,s2,8000203a <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002028:	8526                	mv	a0,s1
    8000202a:	bd9fe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000202e:	17848493          	addi	s1,s1,376
    80002032:	ff3495e3          	bne	s1,s3,8000201c <kkill+0x20>
  }
  return -1;
    80002036:	557d                	li	a0,-1
    80002038:	a819                	j	8000204e <kkill+0x52>
      p->killed = 1;
    8000203a:	4785                	li	a5,1
    8000203c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000203e:	4c98                	lw	a4,24(s1)
    80002040:	4789                	li	a5,2
    80002042:	00f70d63          	beq	a4,a5,8000205c <kkill+0x60>
      release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	bbbfe0ef          	jal	ra,80000c02 <release>
      return 0;
    8000204c:	4501                	li	a0,0
}
    8000204e:	70a2                	ld	ra,40(sp)
    80002050:	7402                	ld	s0,32(sp)
    80002052:	64e2                	ld	s1,24(sp)
    80002054:	6942                	ld	s2,16(sp)
    80002056:	69a2                	ld	s3,8(sp)
    80002058:	6145                	addi	sp,sp,48
    8000205a:	8082                	ret
        p->state = RUNNABLE;
    8000205c:	478d                	li	a5,3
    8000205e:	cc9c                	sw	a5,24(s1)
    80002060:	b7dd                	j	80002046 <kkill+0x4a>

0000000080002062 <setkilled>:

void
setkilled(struct proc *p)
{
    80002062:	1101                	addi	sp,sp,-32
    80002064:	ec06                	sd	ra,24(sp)
    80002066:	e822                	sd	s0,16(sp)
    80002068:	e426                	sd	s1,8(sp)
    8000206a:	1000                	addi	s0,sp,32
    8000206c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000206e:	afdfe0ef          	jal	ra,80000b6a <acquire>
  p->killed = 1;
    80002072:	4785                	li	a5,1
    80002074:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002076:	8526                	mv	a0,s1
    80002078:	b8bfe0ef          	jal	ra,80000c02 <release>
}
    8000207c:	60e2                	ld	ra,24(sp)
    8000207e:	6442                	ld	s0,16(sp)
    80002080:	64a2                	ld	s1,8(sp)
    80002082:	6105                	addi	sp,sp,32
    80002084:	8082                	ret

0000000080002086 <killed>:

int
killed(struct proc *p)
{
    80002086:	1101                	addi	sp,sp,-32
    80002088:	ec06                	sd	ra,24(sp)
    8000208a:	e822                	sd	s0,16(sp)
    8000208c:	e426                	sd	s1,8(sp)
    8000208e:	e04a                	sd	s2,0(sp)
    80002090:	1000                	addi	s0,sp,32
    80002092:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002094:	ad7fe0ef          	jal	ra,80000b6a <acquire>
  k = p->killed;
    80002098:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	b65fe0ef          	jal	ra,80000c02 <release>
  return k;
}
    800020a2:	854a                	mv	a0,s2
    800020a4:	60e2                	ld	ra,24(sp)
    800020a6:	6442                	ld	s0,16(sp)
    800020a8:	64a2                	ld	s1,8(sp)
    800020aa:	6902                	ld	s2,0(sp)
    800020ac:	6105                	addi	sp,sp,32
    800020ae:	8082                	ret

00000000800020b0 <kwait>:
{
    800020b0:	715d                	addi	sp,sp,-80
    800020b2:	e486                	sd	ra,72(sp)
    800020b4:	e0a2                	sd	s0,64(sp)
    800020b6:	fc26                	sd	s1,56(sp)
    800020b8:	f84a                	sd	s2,48(sp)
    800020ba:	f44e                	sd	s3,40(sp)
    800020bc:	f052                	sd	s4,32(sp)
    800020be:	ec56                	sd	s5,24(sp)
    800020c0:	e85a                	sd	s6,16(sp)
    800020c2:	e45e                	sd	s7,8(sp)
    800020c4:	e062                	sd	s8,0(sp)
    800020c6:	0880                	addi	s0,sp,80
    800020c8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020ca:	f38ff0ef          	jal	ra,80001802 <myproc>
    800020ce:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020d0:	0000e517          	auipc	a0,0xe
    800020d4:	8d050513          	addi	a0,a0,-1840 # 8000f9a0 <wait_lock>
    800020d8:	a93fe0ef          	jal	ra,80000b6a <acquire>
    havekids = 0;
    800020dc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800020de:	4a15                	li	s4,5
        havekids = 1;
    800020e0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020e2:	00014997          	auipc	s3,0x14
    800020e6:	ad698993          	addi	s3,s3,-1322 # 80015bb8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800020ea:	0000ec17          	auipc	s8,0xe
    800020ee:	8b6c0c13          	addi	s8,s8,-1866 # 8000f9a0 <wait_lock>
    havekids = 0;
    800020f2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020f4:	0000e497          	auipc	s1,0xe
    800020f8:	cc448493          	addi	s1,s1,-828 # 8000fdb8 <proc>
    800020fc:	a899                	j	80002152 <kwait+0xa2>
          pid = pp->pid;
    800020fe:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002102:	000b0c63          	beqz	s6,8000211a <kwait+0x6a>
    80002106:	4691                	li	a3,4
    80002108:	02c48613          	addi	a2,s1,44
    8000210c:	85da                	mv	a1,s6
    8000210e:	05093503          	ld	a0,80(s2)
    80002112:	c3eff0ef          	jal	ra,80001550 <copyout>
    80002116:	00054f63          	bltz	a0,80002134 <kwait+0x84>
          freeproc(pp);
    8000211a:	8526                	mv	a0,s1
    8000211c:	8b7ff0ef          	jal	ra,800019d2 <freeproc>
          release(&pp->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	ae1fe0ef          	jal	ra,80000c02 <release>
          release(&wait_lock);
    80002126:	0000e517          	auipc	a0,0xe
    8000212a:	87a50513          	addi	a0,a0,-1926 # 8000f9a0 <wait_lock>
    8000212e:	ad5fe0ef          	jal	ra,80000c02 <release>
          return pid;
    80002132:	a891                	j	80002186 <kwait+0xd6>
            release(&pp->lock);
    80002134:	8526                	mv	a0,s1
    80002136:	acdfe0ef          	jal	ra,80000c02 <release>
            release(&wait_lock);
    8000213a:	0000e517          	auipc	a0,0xe
    8000213e:	86650513          	addi	a0,a0,-1946 # 8000f9a0 <wait_lock>
    80002142:	ac1fe0ef          	jal	ra,80000c02 <release>
            return -1;
    80002146:	59fd                	li	s3,-1
    80002148:	a83d                	j	80002186 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214a:	17848493          	addi	s1,s1,376
    8000214e:	03348063          	beq	s1,s3,8000216e <kwait+0xbe>
      if(pp->parent == p){
    80002152:	7c9c                	ld	a5,56(s1)
    80002154:	ff279be3          	bne	a5,s2,8000214a <kwait+0x9a>
        acquire(&pp->lock);
    80002158:	8526                	mv	a0,s1
    8000215a:	a11fe0ef          	jal	ra,80000b6a <acquire>
        if(pp->state == ZOMBIE){
    8000215e:	4c9c                	lw	a5,24(s1)
    80002160:	f9478fe3          	beq	a5,s4,800020fe <kwait+0x4e>
        release(&pp->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	a9dfe0ef          	jal	ra,80000c02 <release>
        havekids = 1;
    8000216a:	8756                	mv	a4,s5
    8000216c:	bff9                	j	8000214a <kwait+0x9a>
    if(!havekids || killed(p)){
    8000216e:	c709                	beqz	a4,80002178 <kwait+0xc8>
    80002170:	854a                	mv	a0,s2
    80002172:	f15ff0ef          	jal	ra,80002086 <killed>
    80002176:	c50d                	beqz	a0,800021a0 <kwait+0xf0>
      release(&wait_lock);
    80002178:	0000e517          	auipc	a0,0xe
    8000217c:	82850513          	addi	a0,a0,-2008 # 8000f9a0 <wait_lock>
    80002180:	a83fe0ef          	jal	ra,80000c02 <release>
      return -1;
    80002184:	59fd                	li	s3,-1
}
    80002186:	854e                	mv	a0,s3
    80002188:	60a6                	ld	ra,72(sp)
    8000218a:	6406                	ld	s0,64(sp)
    8000218c:	74e2                	ld	s1,56(sp)
    8000218e:	7942                	ld	s2,48(sp)
    80002190:	79a2                	ld	s3,40(sp)
    80002192:	7a02                	ld	s4,32(sp)
    80002194:	6ae2                	ld	s5,24(sp)
    80002196:	6b42                	ld	s6,16(sp)
    80002198:	6ba2                	ld	s7,8(sp)
    8000219a:	6c02                	ld	s8,0(sp)
    8000219c:	6161                	addi	sp,sp,80
    8000219e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021a0:	85e2                	mv	a1,s8
    800021a2:	854a                	mv	a0,s2
    800021a4:	cabff0ef          	jal	ra,80001e4e <sleep>
    havekids = 0;
    800021a8:	b7a9                	j	800020f2 <kwait+0x42>

00000000800021aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800021aa:	7179                	addi	sp,sp,-48
    800021ac:	f406                	sd	ra,40(sp)
    800021ae:	f022                	sd	s0,32(sp)
    800021b0:	ec26                	sd	s1,24(sp)
    800021b2:	e84a                	sd	s2,16(sp)
    800021b4:	e44e                	sd	s3,8(sp)
    800021b6:	e052                	sd	s4,0(sp)
    800021b8:	1800                	addi	s0,sp,48
    800021ba:	84aa                	mv	s1,a0
    800021bc:	892e                	mv	s2,a1
    800021be:	89b2                	mv	s3,a2
    800021c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021c2:	e40ff0ef          	jal	ra,80001802 <myproc>
  if(user_dst){
    800021c6:	cc99                	beqz	s1,800021e4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800021c8:	86d2                	mv	a3,s4
    800021ca:	864e                	mv	a2,s3
    800021cc:	85ca                	mv	a1,s2
    800021ce:	6928                	ld	a0,80(a0)
    800021d0:	b80ff0ef          	jal	ra,80001550 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800021d4:	70a2                	ld	ra,40(sp)
    800021d6:	7402                	ld	s0,32(sp)
    800021d8:	64e2                	ld	s1,24(sp)
    800021da:	6942                	ld	s2,16(sp)
    800021dc:	69a2                	ld	s3,8(sp)
    800021de:	6a02                	ld	s4,0(sp)
    800021e0:	6145                	addi	sp,sp,48
    800021e2:	8082                	ret
    memmove((char *)dst, src, len);
    800021e4:	000a061b          	sext.w	a2,s4
    800021e8:	85ce                	mv	a1,s3
    800021ea:	854a                	mv	a0,s2
    800021ec:	aaffe0ef          	jal	ra,80000c9a <memmove>
    return 0;
    800021f0:	8526                	mv	a0,s1
    800021f2:	b7cd                	j	800021d4 <either_copyout+0x2a>

00000000800021f4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800021f4:	7179                	addi	sp,sp,-48
    800021f6:	f406                	sd	ra,40(sp)
    800021f8:	f022                	sd	s0,32(sp)
    800021fa:	ec26                	sd	s1,24(sp)
    800021fc:	e84a                	sd	s2,16(sp)
    800021fe:	e44e                	sd	s3,8(sp)
    80002200:	e052                	sd	s4,0(sp)
    80002202:	1800                	addi	s0,sp,48
    80002204:	892a                	mv	s2,a0
    80002206:	84ae                	mv	s1,a1
    80002208:	89b2                	mv	s3,a2
    8000220a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000220c:	df6ff0ef          	jal	ra,80001802 <myproc>
  if(user_src){
    80002210:	cc99                	beqz	s1,8000222e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002212:	86d2                	mv	a3,s4
    80002214:	864e                	mv	a2,s3
    80002216:	85ca                	mv	a1,s2
    80002218:	6928                	ld	a0,80(a0)
    8000221a:	bfcff0ef          	jal	ra,80001616 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6a02                	ld	s4,0(sp)
    8000222a:	6145                	addi	sp,sp,48
    8000222c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000222e:	000a061b          	sext.w	a2,s4
    80002232:	85ce                	mv	a1,s3
    80002234:	854a                	mv	a0,s2
    80002236:	a65fe0ef          	jal	ra,80000c9a <memmove>
    return 0;
    8000223a:	8526                	mv	a0,s1
    8000223c:	b7cd                	j	8000221e <either_copyin+0x2a>

000000008000223e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000223e:	715d                	addi	sp,sp,-80
    80002240:	e486                	sd	ra,72(sp)
    80002242:	e0a2                	sd	s0,64(sp)
    80002244:	fc26                	sd	s1,56(sp)
    80002246:	f84a                	sd	s2,48(sp)
    80002248:	f44e                	sd	s3,40(sp)
    8000224a:	f052                	sd	s4,32(sp)
    8000224c:	ec56                	sd	s5,24(sp)
    8000224e:	e85a                	sd	s6,16(sp)
    80002250:	e45e                	sd	s7,8(sp)
    80002252:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002254:	00005517          	auipc	a0,0x5
    80002258:	e6c50513          	addi	a0,a0,-404 # 800070c0 <digits+0x88>
    8000225c:	a66fe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002260:	0000e497          	auipc	s1,0xe
    80002264:	cb048493          	addi	s1,s1,-848 # 8000ff10 <proc+0x158>
    80002268:	00014917          	auipc	s2,0x14
    8000226c:	aa890913          	addi	s2,s2,-1368 # 80015d10 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002270:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002272:	00005997          	auipc	s3,0x5
    80002276:	fa698993          	addi	s3,s3,-90 # 80007218 <digits+0x1e0>
    printf("%d %s %s", p->pid, state, p->name);
    8000227a:	00005a97          	auipc	s5,0x5
    8000227e:	fa6a8a93          	addi	s5,s5,-90 # 80007220 <digits+0x1e8>
    printf("\n");
    80002282:	00005a17          	auipc	s4,0x5
    80002286:	e3ea0a13          	addi	s4,s4,-450 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000228a:	00005b97          	auipc	s7,0x5
    8000228e:	fd6b8b93          	addi	s7,s7,-42 # 80007260 <states.0>
    80002292:	a829                	j	800022ac <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002294:	ed86a583          	lw	a1,-296(a3)
    80002298:	8556                	mv	a0,s5
    8000229a:	a28fe0ef          	jal	ra,800004c2 <printf>
    printf("\n");
    8000229e:	8552                	mv	a0,s4
    800022a0:	a22fe0ef          	jal	ra,800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a4:	17848493          	addi	s1,s1,376
    800022a8:	03248263          	beq	s1,s2,800022cc <procdump+0x8e>
    if(p->state == UNUSED)
    800022ac:	86a6                	mv	a3,s1
    800022ae:	ec04a783          	lw	a5,-320(s1)
    800022b2:	dbed                	beqz	a5,800022a4 <procdump+0x66>
      state = "???";
    800022b4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022b6:	fcfb6fe3          	bltu	s6,a5,80002294 <procdump+0x56>
    800022ba:	02079713          	slli	a4,a5,0x20
    800022be:	01d75793          	srli	a5,a4,0x1d
    800022c2:	97de                	add	a5,a5,s7
    800022c4:	6390                	ld	a2,0(a5)
    800022c6:	f679                	bnez	a2,80002294 <procdump+0x56>
      state = "???";
    800022c8:	864e                	mv	a2,s3
    800022ca:	b7e9                	j	80002294 <procdump+0x56>
  }
}
    800022cc:	60a6                	ld	ra,72(sp)
    800022ce:	6406                	ld	s0,64(sp)
    800022d0:	74e2                	ld	s1,56(sp)
    800022d2:	7942                	ld	s2,48(sp)
    800022d4:	79a2                	ld	s3,40(sp)
    800022d6:	7a02                	ld	s4,32(sp)
    800022d8:	6ae2                	ld	s5,24(sp)
    800022da:	6b42                	ld	s6,16(sp)
    800022dc:	6ba2                	ld	s7,8(sp)
    800022de:	6161                	addi	sp,sp,80
    800022e0:	8082                	ret

00000000800022e2 <get_runnable_procs>:

int
get_runnable_procs(uint64 user_array)
{
    800022e2:	711d                	addi	sp,sp,-96
    800022e4:	ec86                	sd	ra,88(sp)
    800022e6:	e8a2                	sd	s0,80(sp)
    800022e8:	e4a6                	sd	s1,72(sp)
    800022ea:	e0ca                	sd	s2,64(sp)
    800022ec:	fc4e                	sd	s3,56(sp)
    800022ee:	f852                	sd	s4,48(sp)
    800022f0:	f456                	sd	s5,40(sp)
    800022f2:	f05a                	sd	s6,32(sp)
    800022f4:	1080                	addi	s0,sp,96
    800022f6:	8b2a                	mv	s6,a0
  struct proc *p;
  struct proc_info local_info;
  int count = 0;
  uint64 offset = 0;
    800022f8:	4a01                	li	s4,0
  int count = 0;
    800022fa:	4a81                	li	s5,0

  // Walking array of global process
  for(p = proc; p < &proc[NPROC]; p++){
    800022fc:	0000e497          	auipc	s1,0xe
    80002300:	abc48493          	addi	s1,s1,-1348 # 8000fdb8 <proc>
    acquire(&p->lock); // lock process for security read

    if(p->state == RUNNABLE){
    80002304:	490d                	li	s2,3
  for(p = proc; p < &proc[NPROC]; p++){
    80002306:	00014997          	auipc	s3,0x14
    8000230a:	8b298993          	addi	s3,s3,-1870 # 80015bb8 <tickslock>
    8000230e:	a03d                	j	8000233c <get_runnable_procs+0x5a>
      local_info.size = p->sz;
      safestrcpy(local_info.name, p->name, sizeof(local_info.name));

      // Transfer a local struct for user space
      if(copyout(myproc()->pagetable, user_array + offset, (char*) &local_info, sizeof(local_info)) < 0){
        release(&p->lock); // Unlock process if error
    80002310:	8526                	mv	a0,s1
    80002312:	8f1fe0ef          	jal	ra,80000c02 <release>
        return -1;
    80002316:	5afd                	li	s5,-1

    release(&p->lock); // Unlock process if sucess
  }

  return count; // Return num of process found
}
    80002318:	8556                	mv	a0,s5
    8000231a:	60e6                	ld	ra,88(sp)
    8000231c:	6446                	ld	s0,80(sp)
    8000231e:	64a6                	ld	s1,72(sp)
    80002320:	6906                	ld	s2,64(sp)
    80002322:	79e2                	ld	s3,56(sp)
    80002324:	7a42                	ld	s4,48(sp)
    80002326:	7aa2                	ld	s5,40(sp)
    80002328:	7b02                	ld	s6,32(sp)
    8000232a:	6125                	addi	sp,sp,96
    8000232c:	8082                	ret
    release(&p->lock); // Unlock process if sucess
    8000232e:	8526                	mv	a0,s1
    80002330:	8d3fe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002334:	17848493          	addi	s1,s1,376
    80002338:	ff3480e3          	beq	s1,s3,80002318 <get_runnable_procs+0x36>
    acquire(&p->lock); // lock process for security read
    8000233c:	8526                	mv	a0,s1
    8000233e:	82dfe0ef          	jal	ra,80000b6a <acquire>
    if(p->state == RUNNABLE){
    80002342:	4c9c                	lw	a5,24(s1)
    80002344:	ff2795e3          	bne	a5,s2,8000232e <get_runnable_procs+0x4c>
      local_info.pid = p->pid;
    80002348:	589c                	lw	a5,48(s1)
    8000234a:	faf42023          	sw	a5,-96(s0)
      local_info.state = p->state;
    8000234e:	fb242223          	sw	s2,-92(s0)
      local_info.size = p->sz;
    80002352:	64bc                	ld	a5,72(s1)
    80002354:	faf43423          	sd	a5,-88(s0)
      safestrcpy(local_info.name, p->name, sizeof(local_info.name));
    80002358:	4641                	li	a2,16
    8000235a:	15848593          	addi	a1,s1,344
    8000235e:	fb040513          	addi	a0,s0,-80
    80002362:	a23fe0ef          	jal	ra,80000d84 <safestrcpy>
      if(copyout(myproc()->pagetable, user_array + offset, (char*) &local_info, sizeof(local_info)) < 0){
    80002366:	c9cff0ef          	jal	ra,80001802 <myproc>
    8000236a:	02000693          	li	a3,32
    8000236e:	fa040613          	addi	a2,s0,-96
    80002372:	014b05b3          	add	a1,s6,s4
    80002376:	6928                	ld	a0,80(a0)
    80002378:	9d8ff0ef          	jal	ra,80001550 <copyout>
    8000237c:	f8054ae3          	bltz	a0,80002310 <get_runnable_procs+0x2e>
      count++;
    80002380:	2a85                	addiw	s5,s5,1
      offset += sizeof(local_info); // Increment offset for the next position of array
    80002382:	020a0a13          	addi	s4,s4,32
    80002386:	b765                	j	8000232e <get_runnable_procs+0x4c>

0000000080002388 <set_priority>:
set_priority(int pid, int priority)
{
  struct proc *p; // Variaveis para guardar processo

  // Validacao da prioridade
  if(priority < 0 || priority > 19)
    80002388:	47cd                	li	a5,19
    8000238a:	06b7e163          	bltu	a5,a1,800023ec <set_priority+0x64>
{
    8000238e:	7179                	addi	sp,sp,-48
    80002390:	f406                	sd	ra,40(sp)
    80002392:	f022                	sd	s0,32(sp)
    80002394:	ec26                	sd	s1,24(sp)
    80002396:	e84a                	sd	s2,16(sp)
    80002398:	e44e                	sd	s3,8(sp)
    8000239a:	e052                	sd	s4,0(sp)
    8000239c:	1800                	addi	s0,sp,48
    8000239e:	892a                	mv	s2,a0
    800023a0:	8a2e                	mv	s4,a1
    return -1;

  // Procurando pelo processo procurado pelo pid  
  for(p = proc; p < &proc[NPROC]; p++){
    800023a2:	0000e497          	auipc	s1,0xe
    800023a6:	a1648493          	addi	s1,s1,-1514 # 8000fdb8 <proc>
    800023aa:	00014997          	auipc	s3,0x14
    800023ae:	80e98993          	addi	s3,s3,-2034 # 80015bb8 <tickslock>
    acquire(&p->lock); // trava o processo atual
    800023b2:	8526                	mv	a0,s1
    800023b4:	fb6fe0ef          	jal	ra,80000b6a <acquire>
    if(p->pid == pid){
    800023b8:	589c                	lw	a5,48(s1)
    800023ba:	01278b63          	beq	a5,s2,800023d0 <set_priority+0x48>
      p->priority = priority; // Define prioridade para processo encontrado
      release(&p->lock);
      return 0;
    }
    release(&p->lock); // Destrava o processo atual
    800023be:	8526                	mv	a0,s1
    800023c0:	843fe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c4:	17848493          	addi	s1,s1,376
    800023c8:	ff3495e3          	bne	s1,s3,800023b2 <set_priority+0x2a>
  }
  return -1; // pid não encontrado
    800023cc:	557d                	li	a0,-1
    800023ce:	a039                	j	800023dc <set_priority+0x54>
      p->priority = priority; // Define prioridade para processo encontrado
    800023d0:	1744a423          	sw	s4,360(s1)
      release(&p->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	82dfe0ef          	jal	ra,80000c02 <release>
      return 0;
    800023da:	4501                	li	a0,0
}
    800023dc:	70a2                	ld	ra,40(sp)
    800023de:	7402                	ld	s0,32(sp)
    800023e0:	64e2                	ld	s1,24(sp)
    800023e2:	6942                	ld	s2,16(sp)
    800023e4:	69a2                	ld	s3,8(sp)
    800023e6:	6a02                	ld	s4,0(sp)
    800023e8:	6145                	addi	sp,sp,48
    800023ea:	8082                	ret
    return -1;
    800023ec:	557d                	li	a0,-1
}
    800023ee:	8082                	ret

00000000800023f0 <getpinfo>:

int
getpinfo(struct pstat *ps)
{
    800023f0:	81010113          	addi	sp,sp,-2032
    800023f4:	7e113423          	sd	ra,2024(sp)
    800023f8:	7e813023          	sd	s0,2016(sp)
    800023fc:	7c913c23          	sd	s1,2008(sp)
    80002400:	7d213823          	sd	s2,2000(sp)
    80002404:	7d313423          	sd	s3,1992(sp)
    80002408:	7d413023          	sd	s4,1984(sp)
    8000240c:	7b513c23          	sd	s5,1976(sp)
    80002410:	7b613823          	sd	s6,1968(sp)
    80002414:	7f010413          	addi	s0,sp,2032
    80002418:	db010113          	addi	sp,sp,-592
    8000241c:	8aaa                	mv	s5,a0
  struct proc *p;
  struct pstat kps; // buffer no espaço do kernel
  int i = 0;

  // Percorrendo os processos e prenchendo a struct de retorno
  for(p = proc; p < &proc[NPROC]; p++){
    8000241e:	797d                	lui	s2,0xfffff
    80002420:	5c090793          	addi	a5,s2,1472 # fffffffffffff5c0 <end+0xffffffff7ffde628>
    80002424:	00878933          	add	s2,a5,s0
    80002428:	9c040a13          	addi	s4,s0,-1600
    8000242c:	bc040993          	addi	s3,s0,-1088
    80002430:	0000e497          	auipc	s1,0xe
    80002434:	98848493          	addi	s1,s1,-1656 # 8000fdb8 <proc>
    80002438:	00013b17          	auipc	s6,0x13
    8000243c:	780b0b13          	addi	s6,s6,1920 # 80015bb8 <tickslock>
    acquire(&p->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	f28fe0ef          	jal	ra,80000b6a <acquire>
    kps.inuse[i]    = (p->state != UNUSED);
    80002446:	4c9c                	lw	a5,24(s1)
    80002448:	00f03733          	snez	a4,a5
    8000244c:	00e92023          	sw	a4,0(s2)
    kps.pid[i]      = p->pid;
    80002450:	5898                	lw	a4,48(s1)
    80002452:	10e92023          	sw	a4,256(s2)
    kps.priority[i] = p->priority;
    80002456:	1684a703          	lw	a4,360(s1)
    8000245a:	20e92023          	sw	a4,512(s2)
    kps.state[i]    = p->state;
    8000245e:	30f92023          	sw	a5,768(s2)
    kps.runs[i]     = p->runs;
    80002462:	1704b783          	ld	a5,368(s1)
    80002466:	00fa3023          	sd	a5,0(s4)
    safestrcpy(kps.name[i], p->name, sizeof(kps.name[i]));
    8000246a:	4641                	li	a2,16
    8000246c:	15848593          	addi	a1,s1,344
    80002470:	854e                	mv	a0,s3
    80002472:	913fe0ef          	jal	ra,80000d84 <safestrcpy>
    release(&p->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	f8afe0ef          	jal	ra,80000c02 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000247c:	17848493          	addi	s1,s1,376
    80002480:	0911                	addi	s2,s2,4
    80002482:	0a21                	addi	s4,s4,8
    80002484:	09c1                	addi	s3,s3,16
    80002486:	fb649de3          	bne	s1,s6,80002440 <getpinfo+0x50>
    i++;
  }

  struct proc *cp = myproc();
    8000248a:	b78ff0ef          	jal	ra,80001802 <myproc>
  if(copyout(cp->pagetable, (uint64)ps, (char*)&kps, sizeof(kps)) < 0)
    8000248e:	6685                	lui	a3,0x1
    80002490:	a0068693          	addi	a3,a3,-1536 # a00 <_entry-0x7ffff600>
    80002494:	767d                	lui	a2,0xfffff
    80002496:	5c060793          	addi	a5,a2,1472 # fffffffffffff5c0 <end+0xffffffff7ffde628>
    8000249a:	00878633          	add	a2,a5,s0
    8000249e:	85d6                	mv	a1,s5
    800024a0:	6928                	ld	a0,80(a0)
    800024a2:	8aeff0ef          	jal	ra,80001550 <copyout>
    return -1;

  return 0;
}
    800024a6:	41f5551b          	sraiw	a0,a0,0x1f
    800024aa:	25010113          	addi	sp,sp,592
    800024ae:	7e813083          	ld	ra,2024(sp)
    800024b2:	7e013403          	ld	s0,2016(sp)
    800024b6:	7d813483          	ld	s1,2008(sp)
    800024ba:	7d013903          	ld	s2,2000(sp)
    800024be:	7c813983          	ld	s3,1992(sp)
    800024c2:	7c013a03          	ld	s4,1984(sp)
    800024c6:	7b813a83          	ld	s5,1976(sp)
    800024ca:	7b013b03          	ld	s6,1968(sp)
    800024ce:	7f010113          	addi	sp,sp,2032
    800024d2:	8082                	ret

00000000800024d4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024d4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024d8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024dc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024de:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024e0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024e4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024e8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024ec:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024f0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024f4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024f8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024fc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002500:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002504:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002508:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000250c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002510:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002512:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002514:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002518:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000251c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002520:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002524:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002528:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000252c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002530:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002534:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002538:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000253c:	8082                	ret

000000008000253e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000253e:	1141                	addi	sp,sp,-16
    80002540:	e406                	sd	ra,8(sp)
    80002542:	e022                	sd	s0,0(sp)
    80002544:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002546:	00005597          	auipc	a1,0x5
    8000254a:	d4a58593          	addi	a1,a1,-694 # 80007290 <states.0+0x30>
    8000254e:	00013517          	auipc	a0,0x13
    80002552:	66a50513          	addi	a0,a0,1642 # 80015bb8 <tickslock>
    80002556:	d94fe0ef          	jal	ra,80000aea <initlock>
}
    8000255a:	60a2                	ld	ra,8(sp)
    8000255c:	6402                	ld	s0,0(sp)
    8000255e:	0141                	addi	sp,sp,16
    80002560:	8082                	ret

0000000080002562 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002562:	1141                	addi	sp,sp,-16
    80002564:	e422                	sd	s0,8(sp)
    80002566:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002568:	00003797          	auipc	a5,0x3
    8000256c:	ec878793          	addi	a5,a5,-312 # 80005430 <kernelvec>
    80002570:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002574:	6422                	ld	s0,8(sp)
    80002576:	0141                	addi	sp,sp,16
    80002578:	8082                	ret

000000008000257a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000257a:	1141                	addi	sp,sp,-16
    8000257c:	e406                	sd	ra,8(sp)
    8000257e:	e022                	sd	s0,0(sp)
    80002580:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002582:	a80ff0ef          	jal	ra,80001802 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002586:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000258a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000258c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002590:	04000737          	lui	a4,0x4000
    80002594:	00004797          	auipc	a5,0x4
    80002598:	a6c78793          	addi	a5,a5,-1428 # 80006000 <_trampoline>
    8000259c:	00004697          	auipc	a3,0x4
    800025a0:	a6468693          	addi	a3,a3,-1436 # 80006000 <_trampoline>
    800025a4:	8f95                	sub	a5,a5,a3
    800025a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800025a8:	0732                	slli	a4,a4,0xc
    800025aa:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025ac:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800025b2:	18002773          	csrr	a4,satp
    800025b6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025b8:	6d38                	ld	a4,88(a0)
    800025ba:	613c                	ld	a5,64(a0)
    800025bc:	6685                	lui	a3,0x1
    800025be:	97b6                	add	a5,a5,a3
    800025c0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025c2:	6d3c                	ld	a5,88(a0)
    800025c4:	00000717          	auipc	a4,0x0
    800025c8:	0f470713          	addi	a4,a4,244 # 800026b8 <usertrap>
    800025cc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800025ce:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800025d0:	8712                	mv	a4,tp
    800025d2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025d8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025dc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025e0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025e6:	6f9c                	ld	a5,24(a5)
    800025e8:	14179073          	csrw	sepc,a5
}
    800025ec:	60a2                	ld	ra,8(sp)
    800025ee:	6402                	ld	s0,0(sp)
    800025f0:	0141                	addi	sp,sp,16
    800025f2:	8082                	ret

00000000800025f4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025f4:	1101                	addi	sp,sp,-32
    800025f6:	ec06                	sd	ra,24(sp)
    800025f8:	e822                	sd	s0,16(sp)
    800025fa:	e426                	sd	s1,8(sp)
    800025fc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800025fe:	9d8ff0ef          	jal	ra,800017d6 <cpuid>
    80002602:	cd19                	beqz	a0,80002620 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002604:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002608:	000f4737          	lui	a4,0xf4
    8000260c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002610:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002612:	14d79073          	csrw	0x14d,a5
}
    80002616:	60e2                	ld	ra,24(sp)
    80002618:	6442                	ld	s0,16(sp)
    8000261a:	64a2                	ld	s1,8(sp)
    8000261c:	6105                	addi	sp,sp,32
    8000261e:	8082                	ret
    acquire(&tickslock);
    80002620:	00013497          	auipc	s1,0x13
    80002624:	59848493          	addi	s1,s1,1432 # 80015bb8 <tickslock>
    80002628:	8526                	mv	a0,s1
    8000262a:	d40fe0ef          	jal	ra,80000b6a <acquire>
    ticks++;
    8000262e:	00005517          	auipc	a0,0x5
    80002632:	25a50513          	addi	a0,a0,602 # 80007888 <ticks>
    80002636:	411c                	lw	a5,0(a0)
    80002638:	2785                	addiw	a5,a5,1
    8000263a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000263c:	85fff0ef          	jal	ra,80001e9a <wakeup>
    release(&tickslock);
    80002640:	8526                	mv	a0,s1
    80002642:	dc0fe0ef          	jal	ra,80000c02 <release>
    80002646:	bf7d                	j	80002604 <clockintr+0x10>

0000000080002648 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002648:	1101                	addi	sp,sp,-32
    8000264a:	ec06                	sd	ra,24(sp)
    8000264c:	e822                	sd	s0,16(sp)
    8000264e:	e426                	sd	s1,8(sp)
    80002650:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002652:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002656:	57fd                	li	a5,-1
    80002658:	17fe                	slli	a5,a5,0x3f
    8000265a:	07a5                	addi	a5,a5,9
    8000265c:	00f70d63          	beq	a4,a5,80002676 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002660:	57fd                	li	a5,-1
    80002662:	17fe                	slli	a5,a5,0x3f
    80002664:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002666:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002668:	04f70463          	beq	a4,a5,800026b0 <devintr+0x68>
  }
}
    8000266c:	60e2                	ld	ra,24(sp)
    8000266e:	6442                	ld	s0,16(sp)
    80002670:	64a2                	ld	s1,8(sp)
    80002672:	6105                	addi	sp,sp,32
    80002674:	8082                	ret
    int irq = plic_claim();
    80002676:	663020ef          	jal	ra,800054d8 <plic_claim>
    8000267a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000267c:	47a9                	li	a5,10
    8000267e:	02f50363          	beq	a0,a5,800026a4 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002682:	4785                	li	a5,1
    80002684:	02f50363          	beq	a0,a5,800026aa <devintr+0x62>
    return 1;
    80002688:	4505                	li	a0,1
    } else if(irq){
    8000268a:	d0ed                	beqz	s1,8000266c <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000268c:	85a6                	mv	a1,s1
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	c0a50513          	addi	a0,a0,-1014 # 80007298 <states.0+0x38>
    80002696:	e2dfd0ef          	jal	ra,800004c2 <printf>
      plic_complete(irq);
    8000269a:	8526                	mv	a0,s1
    8000269c:	65d020ef          	jal	ra,800054f8 <plic_complete>
    return 1;
    800026a0:	4505                	li	a0,1
    800026a2:	b7e9                	j	8000266c <devintr+0x24>
      uartintr();
    800026a4:	ab0fe0ef          	jal	ra,80000954 <uartintr>
    800026a8:	bfcd                	j	8000269a <devintr+0x52>
      virtio_disk_intr();
    800026aa:	2ba030ef          	jal	ra,80005964 <virtio_disk_intr>
    800026ae:	b7f5                	j	8000269a <devintr+0x52>
    clockintr();
    800026b0:	f45ff0ef          	jal	ra,800025f4 <clockintr>
    return 2;
    800026b4:	4509                	li	a0,2
    800026b6:	bf5d                	j	8000266c <devintr+0x24>

00000000800026b8 <usertrap>:
{
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	e04a                	sd	s2,0(sp)
    800026c2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800026c8:	1007f793          	andi	a5,a5,256
    800026cc:	eba5                	bnez	a5,8000273c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ce:	00003797          	auipc	a5,0x3
    800026d2:	d6278793          	addi	a5,a5,-670 # 80005430 <kernelvec>
    800026d6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026da:	928ff0ef          	jal	ra,80001802 <myproc>
    800026de:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026e2:	14102773          	csrr	a4,sepc
    800026e6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026ec:	47a1                	li	a5,8
    800026ee:	04f70d63          	beq	a4,a5,80002748 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800026f2:	f57ff0ef          	jal	ra,80002648 <devintr>
    800026f6:	892a                	mv	s2,a0
    800026f8:	e945                	bnez	a0,800027a8 <usertrap+0xf0>
    800026fa:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026fe:	47bd                	li	a5,15
    80002700:	08f70863          	beq	a4,a5,80002790 <usertrap+0xd8>
    80002704:	14202773          	csrr	a4,scause
    80002708:	47b5                	li	a5,13
    8000270a:	08f70363          	beq	a4,a5,80002790 <usertrap+0xd8>
    8000270e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002712:	5890                	lw	a2,48(s1)
    80002714:	00005517          	auipc	a0,0x5
    80002718:	bc450513          	addi	a0,a0,-1084 # 800072d8 <states.0+0x78>
    8000271c:	da7fd0ef          	jal	ra,800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002720:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002724:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	be050513          	addi	a0,a0,-1056 # 80007308 <states.0+0xa8>
    80002730:	d93fd0ef          	jal	ra,800004c2 <printf>
    setkilled(p);
    80002734:	8526                	mv	a0,s1
    80002736:	92dff0ef          	jal	ra,80002062 <setkilled>
    8000273a:	a035                	j	80002766 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000273c:	00005517          	auipc	a0,0x5
    80002740:	b7c50513          	addi	a0,a0,-1156 # 800072b8 <states.0+0x58>
    80002744:	844fe0ef          	jal	ra,80000788 <panic>
    if(killed(p))
    80002748:	93fff0ef          	jal	ra,80002086 <killed>
    8000274c:	ed15                	bnez	a0,80002788 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000274e:	6cb8                	ld	a4,88(s1)
    80002750:	6f1c                	ld	a5,24(a4)
    80002752:	0791                	addi	a5,a5,4
    80002754:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002756:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000275a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000275e:	10079073          	csrw	sstatus,a5
    syscall();
    80002762:	246000ef          	jal	ra,800029a8 <syscall>
  if(killed(p))
    80002766:	8526                	mv	a0,s1
    80002768:	91fff0ef          	jal	ra,80002086 <killed>
    8000276c:	e139                	bnez	a0,800027b2 <usertrap+0xfa>
  prepare_return();
    8000276e:	e0dff0ef          	jal	ra,8000257a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002772:	68a8                	ld	a0,80(s1)
    80002774:	8131                	srli	a0,a0,0xc
    80002776:	57fd                	li	a5,-1
    80002778:	17fe                	slli	a5,a5,0x3f
    8000277a:	8d5d                	or	a0,a0,a5
}
    8000277c:	60e2                	ld	ra,24(sp)
    8000277e:	6442                	ld	s0,16(sp)
    80002780:	64a2                	ld	s1,8(sp)
    80002782:	6902                	ld	s2,0(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret
      kexit(-1);
    80002788:	557d                	li	a0,-1
    8000278a:	fd0ff0ef          	jal	ra,80001f5a <kexit>
    8000278e:	b7c1                	j	8000274e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002790:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002794:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002798:	164d                	addi	a2,a2,-13
    8000279a:	00163613          	seqz	a2,a2
    8000279e:	68a8                	ld	a0,80(s1)
    800027a0:	d3ffe0ef          	jal	ra,800014de <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800027a4:	f169                	bnez	a0,80002766 <usertrap+0xae>
    800027a6:	b7a5                	j	8000270e <usertrap+0x56>
  if(killed(p))
    800027a8:	8526                	mv	a0,s1
    800027aa:	8ddff0ef          	jal	ra,80002086 <killed>
    800027ae:	c511                	beqz	a0,800027ba <usertrap+0x102>
    800027b0:	a011                	j	800027b4 <usertrap+0xfc>
    800027b2:	4901                	li	s2,0
    kexit(-1);
    800027b4:	557d                	li	a0,-1
    800027b6:	fa4ff0ef          	jal	ra,80001f5a <kexit>
  if(which_dev == 2)
    800027ba:	4789                	li	a5,2
    800027bc:	faf919e3          	bne	s2,a5,8000276e <usertrap+0xb6>
    yield();
    800027c0:	e62ff0ef          	jal	ra,80001e22 <yield>
    800027c4:	b76d                	j	8000276e <usertrap+0xb6>

00000000800027c6 <kerneltrap>:
{
    800027c6:	7179                	addi	sp,sp,-48
    800027c8:	f406                	sd	ra,40(sp)
    800027ca:	f022                	sd	s0,32(sp)
    800027cc:	ec26                	sd	s1,24(sp)
    800027ce:	e84a                	sd	s2,16(sp)
    800027d0:	e44e                	sd	s3,8(sp)
    800027d2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027d4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027dc:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800027e0:	1004f793          	andi	a5,s1,256
    800027e4:	c795                	beqz	a5,80002810 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027ea:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800027ec:	eb85                	bnez	a5,8000281c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800027ee:	e5bff0ef          	jal	ra,80002648 <devintr>
    800027f2:	c91d                	beqz	a0,80002828 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800027f4:	4789                	li	a5,2
    800027f6:	04f50a63          	beq	a0,a5,8000284a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027fa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027fe:	10049073          	csrw	sstatus,s1
}
    80002802:	70a2                	ld	ra,40(sp)
    80002804:	7402                	ld	s0,32(sp)
    80002806:	64e2                	ld	s1,24(sp)
    80002808:	6942                	ld	s2,16(sp)
    8000280a:	69a2                	ld	s3,8(sp)
    8000280c:	6145                	addi	sp,sp,48
    8000280e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002810:	00005517          	auipc	a0,0x5
    80002814:	b2050513          	addi	a0,a0,-1248 # 80007330 <states.0+0xd0>
    80002818:	f71fd0ef          	jal	ra,80000788 <panic>
    panic("kerneltrap: interrupts enabled");
    8000281c:	00005517          	auipc	a0,0x5
    80002820:	b3c50513          	addi	a0,a0,-1220 # 80007358 <states.0+0xf8>
    80002824:	f65fd0ef          	jal	ra,80000788 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002828:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000282c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002830:	85ce                	mv	a1,s3
    80002832:	00005517          	auipc	a0,0x5
    80002836:	b4650513          	addi	a0,a0,-1210 # 80007378 <states.0+0x118>
    8000283a:	c89fd0ef          	jal	ra,800004c2 <printf>
    panic("kerneltrap");
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	b6250513          	addi	a0,a0,-1182 # 800073a0 <states.0+0x140>
    80002846:	f43fd0ef          	jal	ra,80000788 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000284a:	fb9fe0ef          	jal	ra,80001802 <myproc>
    8000284e:	d555                	beqz	a0,800027fa <kerneltrap+0x34>
    yield();
    80002850:	dd2ff0ef          	jal	ra,80001e22 <yield>
    80002854:	b75d                	j	800027fa <kerneltrap+0x34>

0000000080002856 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002856:	1101                	addi	sp,sp,-32
    80002858:	ec06                	sd	ra,24(sp)
    8000285a:	e822                	sd	s0,16(sp)
    8000285c:	e426                	sd	s1,8(sp)
    8000285e:	1000                	addi	s0,sp,32
    80002860:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002862:	fa1fe0ef          	jal	ra,80001802 <myproc>
  switch (n) {
    80002866:	4795                	li	a5,5
    80002868:	0497e163          	bltu	a5,s1,800028aa <argraw+0x54>
    8000286c:	048a                	slli	s1,s1,0x2
    8000286e:	00005717          	auipc	a4,0x5
    80002872:	b6a70713          	addi	a4,a4,-1174 # 800073d8 <states.0+0x178>
    80002876:	94ba                	add	s1,s1,a4
    80002878:	409c                	lw	a5,0(s1)
    8000287a:	97ba                	add	a5,a5,a4
    8000287c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000287e:	6d3c                	ld	a5,88(a0)
    80002880:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002882:	60e2                	ld	ra,24(sp)
    80002884:	6442                	ld	s0,16(sp)
    80002886:	64a2                	ld	s1,8(sp)
    80002888:	6105                	addi	sp,sp,32
    8000288a:	8082                	ret
    return p->trapframe->a1;
    8000288c:	6d3c                	ld	a5,88(a0)
    8000288e:	7fa8                	ld	a0,120(a5)
    80002890:	bfcd                	j	80002882 <argraw+0x2c>
    return p->trapframe->a2;
    80002892:	6d3c                	ld	a5,88(a0)
    80002894:	63c8                	ld	a0,128(a5)
    80002896:	b7f5                	j	80002882 <argraw+0x2c>
    return p->trapframe->a3;
    80002898:	6d3c                	ld	a5,88(a0)
    8000289a:	67c8                	ld	a0,136(a5)
    8000289c:	b7dd                	j	80002882 <argraw+0x2c>
    return p->trapframe->a4;
    8000289e:	6d3c                	ld	a5,88(a0)
    800028a0:	6bc8                	ld	a0,144(a5)
    800028a2:	b7c5                	j	80002882 <argraw+0x2c>
    return p->trapframe->a5;
    800028a4:	6d3c                	ld	a5,88(a0)
    800028a6:	6fc8                	ld	a0,152(a5)
    800028a8:	bfe9                	j	80002882 <argraw+0x2c>
  panic("argraw");
    800028aa:	00005517          	auipc	a0,0x5
    800028ae:	b0650513          	addi	a0,a0,-1274 # 800073b0 <states.0+0x150>
    800028b2:	ed7fd0ef          	jal	ra,80000788 <panic>

00000000800028b6 <fetchaddr>:
{
    800028b6:	1101                	addi	sp,sp,-32
    800028b8:	ec06                	sd	ra,24(sp)
    800028ba:	e822                	sd	s0,16(sp)
    800028bc:	e426                	sd	s1,8(sp)
    800028be:	e04a                	sd	s2,0(sp)
    800028c0:	1000                	addi	s0,sp,32
    800028c2:	84aa                	mv	s1,a0
    800028c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028c6:	f3dfe0ef          	jal	ra,80001802 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028ca:	653c                	ld	a5,72(a0)
    800028cc:	02f4f663          	bgeu	s1,a5,800028f8 <fetchaddr+0x42>
    800028d0:	00848713          	addi	a4,s1,8
    800028d4:	02e7e463          	bltu	a5,a4,800028fc <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028d8:	46a1                	li	a3,8
    800028da:	8626                	mv	a2,s1
    800028dc:	85ca                	mv	a1,s2
    800028de:	6928                	ld	a0,80(a0)
    800028e0:	d37fe0ef          	jal	ra,80001616 <copyin>
    800028e4:	00a03533          	snez	a0,a0
    800028e8:	40a00533          	neg	a0,a0
}
    800028ec:	60e2                	ld	ra,24(sp)
    800028ee:	6442                	ld	s0,16(sp)
    800028f0:	64a2                	ld	s1,8(sp)
    800028f2:	6902                	ld	s2,0(sp)
    800028f4:	6105                	addi	sp,sp,32
    800028f6:	8082                	ret
    return -1;
    800028f8:	557d                	li	a0,-1
    800028fa:	bfcd                	j	800028ec <fetchaddr+0x36>
    800028fc:	557d                	li	a0,-1
    800028fe:	b7fd                	j	800028ec <fetchaddr+0x36>

0000000080002900 <fetchstr>:
{
    80002900:	7179                	addi	sp,sp,-48
    80002902:	f406                	sd	ra,40(sp)
    80002904:	f022                	sd	s0,32(sp)
    80002906:	ec26                	sd	s1,24(sp)
    80002908:	e84a                	sd	s2,16(sp)
    8000290a:	e44e                	sd	s3,8(sp)
    8000290c:	1800                	addi	s0,sp,48
    8000290e:	892a                	mv	s2,a0
    80002910:	84ae                	mv	s1,a1
    80002912:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002914:	eeffe0ef          	jal	ra,80001802 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002918:	86ce                	mv	a3,s3
    8000291a:	864a                	mv	a2,s2
    8000291c:	85a6                	mv	a1,s1
    8000291e:	6928                	ld	a0,80(a0)
    80002920:	af3fe0ef          	jal	ra,80001412 <copyinstr>
    80002924:	00054c63          	bltz	a0,8000293c <fetchstr+0x3c>
  return strlen(buf);
    80002928:	8526                	mv	a0,s1
    8000292a:	c8cfe0ef          	jal	ra,80000db6 <strlen>
}
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6145                	addi	sp,sp,48
    8000293a:	8082                	ret
    return -1;
    8000293c:	557d                	li	a0,-1
    8000293e:	bfc5                	j	8000292e <fetchstr+0x2e>

0000000080002940 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002940:	1101                	addi	sp,sp,-32
    80002942:	ec06                	sd	ra,24(sp)
    80002944:	e822                	sd	s0,16(sp)
    80002946:	e426                	sd	s1,8(sp)
    80002948:	1000                	addi	s0,sp,32
    8000294a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000294c:	f0bff0ef          	jal	ra,80002856 <argraw>
    80002950:	c088                	sw	a0,0(s1)
}
    80002952:	60e2                	ld	ra,24(sp)
    80002954:	6442                	ld	s0,16(sp)
    80002956:	64a2                	ld	s1,8(sp)
    80002958:	6105                	addi	sp,sp,32
    8000295a:	8082                	ret

000000008000295c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	e426                	sd	s1,8(sp)
    80002964:	1000                	addi	s0,sp,32
    80002966:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002968:	eefff0ef          	jal	ra,80002856 <argraw>
    8000296c:	e088                	sd	a0,0(s1)
}
    8000296e:	60e2                	ld	ra,24(sp)
    80002970:	6442                	ld	s0,16(sp)
    80002972:	64a2                	ld	s1,8(sp)
    80002974:	6105                	addi	sp,sp,32
    80002976:	8082                	ret

0000000080002978 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002978:	7179                	addi	sp,sp,-48
    8000297a:	f406                	sd	ra,40(sp)
    8000297c:	f022                	sd	s0,32(sp)
    8000297e:	ec26                	sd	s1,24(sp)
    80002980:	e84a                	sd	s2,16(sp)
    80002982:	1800                	addi	s0,sp,48
    80002984:	84ae                	mv	s1,a1
    80002986:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002988:	fd840593          	addi	a1,s0,-40
    8000298c:	fd1ff0ef          	jal	ra,8000295c <argaddr>
  return fetchstr(addr, buf, max);
    80002990:	864a                	mv	a2,s2
    80002992:	85a6                	mv	a1,s1
    80002994:	fd843503          	ld	a0,-40(s0)
    80002998:	f69ff0ef          	jal	ra,80002900 <fetchstr>
}
    8000299c:	70a2                	ld	ra,40(sp)
    8000299e:	7402                	ld	s0,32(sp)
    800029a0:	64e2                	ld	s1,24(sp)
    800029a2:	6942                	ld	s2,16(sp)
    800029a4:	6145                	addi	sp,sp,48
    800029a6:	8082                	ret

00000000800029a8 <syscall>:
[SYS_setpriority] sys_setpriority
};

void
syscall(void)
{
    800029a8:	1101                	addi	sp,sp,-32
    800029aa:	ec06                	sd	ra,24(sp)
    800029ac:	e822                	sd	s0,16(sp)
    800029ae:	e426                	sd	s1,8(sp)
    800029b0:	e04a                	sd	s2,0(sp)
    800029b2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029b4:	e4ffe0ef          	jal	ra,80001802 <myproc>
    800029b8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029ba:	05853903          	ld	s2,88(a0)
    800029be:	0a893783          	ld	a5,168(s2)
    800029c2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029c6:	37fd                	addiw	a5,a5,-1
    800029c8:	4759                	li	a4,22
    800029ca:	00f76f63          	bltu	a4,a5,800029e8 <syscall+0x40>
    800029ce:	00369713          	slli	a4,a3,0x3
    800029d2:	00005797          	auipc	a5,0x5
    800029d6:	a1e78793          	addi	a5,a5,-1506 # 800073f0 <syscalls>
    800029da:	97ba                	add	a5,a5,a4
    800029dc:	639c                	ld	a5,0(a5)
    800029de:	c789                	beqz	a5,800029e8 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029e0:	9782                	jalr	a5
    800029e2:	06a93823          	sd	a0,112(s2)
    800029e6:	a829                	j	80002a00 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029e8:	15848613          	addi	a2,s1,344
    800029ec:	588c                	lw	a1,48(s1)
    800029ee:	00005517          	auipc	a0,0x5
    800029f2:	9ca50513          	addi	a0,a0,-1590 # 800073b8 <states.0+0x158>
    800029f6:	acdfd0ef          	jal	ra,800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800029fa:	6cbc                	ld	a5,88(s1)
    800029fc:	577d                	li	a4,-1
    800029fe:	fbb8                	sd	a4,112(a5)
  }
}
    80002a00:	60e2                	ld	ra,24(sp)
    80002a02:	6442                	ld	s0,16(sp)
    80002a04:	64a2                	ld	s1,8(sp)
    80002a06:	6902                	ld	s2,0(sp)
    80002a08:	6105                	addi	sp,sp,32
    80002a0a:	8082                	ret

0000000080002a0c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a0c:	1101                	addi	sp,sp,-32
    80002a0e:	ec06                	sd	ra,24(sp)
    80002a10:	e822                	sd	s0,16(sp)
    80002a12:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a14:	fec40593          	addi	a1,s0,-20
    80002a18:	4501                	li	a0,0
    80002a1a:	f27ff0ef          	jal	ra,80002940 <argint>
  kexit(n);
    80002a1e:	fec42503          	lw	a0,-20(s0)
    80002a22:	d38ff0ef          	jal	ra,80001f5a <kexit>
  return 0;  // not reached
}
    80002a26:	4501                	li	a0,0
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	6105                	addi	sp,sp,32
    80002a2e:	8082                	ret

0000000080002a30 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a30:	1141                	addi	sp,sp,-16
    80002a32:	e406                	sd	ra,8(sp)
    80002a34:	e022                	sd	s0,0(sp)
    80002a36:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a38:	dcbfe0ef          	jal	ra,80001802 <myproc>
}
    80002a3c:	5908                	lw	a0,48(a0)
    80002a3e:	60a2                	ld	ra,8(sp)
    80002a40:	6402                	ld	s0,0(sp)
    80002a42:	0141                	addi	sp,sp,16
    80002a44:	8082                	ret

0000000080002a46 <sys_fork>:

uint64
sys_fork(void)
{
    80002a46:	1141                	addi	sp,sp,-16
    80002a48:	e406                	sd	ra,8(sp)
    80002a4a:	e022                	sd	s0,0(sp)
    80002a4c:	0800                	addi	s0,sp,16
  return kfork();
    80002a4e:	922ff0ef          	jal	ra,80001b70 <kfork>
}
    80002a52:	60a2                	ld	ra,8(sp)
    80002a54:	6402                	ld	s0,0(sp)
    80002a56:	0141                	addi	sp,sp,16
    80002a58:	8082                	ret

0000000080002a5a <sys_wait>:

uint64
sys_wait(void)
{
    80002a5a:	1101                	addi	sp,sp,-32
    80002a5c:	ec06                	sd	ra,24(sp)
    80002a5e:	e822                	sd	s0,16(sp)
    80002a60:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a62:	fe840593          	addi	a1,s0,-24
    80002a66:	4501                	li	a0,0
    80002a68:	ef5ff0ef          	jal	ra,8000295c <argaddr>
  return kwait(p);
    80002a6c:	fe843503          	ld	a0,-24(s0)
    80002a70:	e40ff0ef          	jal	ra,800020b0 <kwait>
}
    80002a74:	60e2                	ld	ra,24(sp)
    80002a76:	6442                	ld	s0,16(sp)
    80002a78:	6105                	addi	sp,sp,32
    80002a7a:	8082                	ret

0000000080002a7c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a7c:	7179                	addi	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a86:	fd840593          	addi	a1,s0,-40
    80002a8a:	4501                	li	a0,0
    80002a8c:	eb5ff0ef          	jal	ra,80002940 <argint>
  argint(1, &t);
    80002a90:	fdc40593          	addi	a1,s0,-36
    80002a94:	4505                	li	a0,1
    80002a96:	eabff0ef          	jal	ra,80002940 <argint>
  addr = myproc()->sz;
    80002a9a:	d69fe0ef          	jal	ra,80001802 <myproc>
    80002a9e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002aa0:	fdc42703          	lw	a4,-36(s0)
    80002aa4:	4785                	li	a5,1
    80002aa6:	02f70763          	beq	a4,a5,80002ad4 <sys_sbrk+0x58>
    80002aaa:	fd842783          	lw	a5,-40(s0)
    80002aae:	0207c363          	bltz	a5,80002ad4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002ab2:	97a6                	add	a5,a5,s1
    80002ab4:	0297ee63          	bltu	a5,s1,80002af0 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002ab8:	02000737          	lui	a4,0x2000
    80002abc:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002abe:	0736                	slli	a4,a4,0xd
    80002ac0:	02f76a63          	bltu	a4,a5,80002af4 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002ac4:	d3ffe0ef          	jal	ra,80001802 <myproc>
    80002ac8:	fd842703          	lw	a4,-40(s0)
    80002acc:	653c                	ld	a5,72(a0)
    80002ace:	97ba                	add	a5,a5,a4
    80002ad0:	e53c                	sd	a5,72(a0)
    80002ad2:	a039                	j	80002ae0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ad4:	fd842503          	lw	a0,-40(s0)
    80002ad8:	836ff0ef          	jal	ra,80001b0e <growproc>
    80002adc:	00054863          	bltz	a0,80002aec <sys_sbrk+0x70>
  }
  return addr;
}
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	70a2                	ld	ra,40(sp)
    80002ae4:	7402                	ld	s0,32(sp)
    80002ae6:	64e2                	ld	s1,24(sp)
    80002ae8:	6145                	addi	sp,sp,48
    80002aea:	8082                	ret
      return -1;
    80002aec:	54fd                	li	s1,-1
    80002aee:	bfcd                	j	80002ae0 <sys_sbrk+0x64>
      return -1;
    80002af0:	54fd                	li	s1,-1
    80002af2:	b7fd                	j	80002ae0 <sys_sbrk+0x64>
      return -1;
    80002af4:	54fd                	li	s1,-1
    80002af6:	b7ed                	j	80002ae0 <sys_sbrk+0x64>

0000000080002af8 <sys_pause>:

uint64
sys_pause(void)
{
    80002af8:	7139                	addi	sp,sp,-64
    80002afa:	fc06                	sd	ra,56(sp)
    80002afc:	f822                	sd	s0,48(sp)
    80002afe:	f426                	sd	s1,40(sp)
    80002b00:	f04a                	sd	s2,32(sp)
    80002b02:	ec4e                	sd	s3,24(sp)
    80002b04:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b06:	fcc40593          	addi	a1,s0,-52
    80002b0a:	4501                	li	a0,0
    80002b0c:	e35ff0ef          	jal	ra,80002940 <argint>
  if(n < 0)
    80002b10:	fcc42783          	lw	a5,-52(s0)
    80002b14:	0607c563          	bltz	a5,80002b7e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b18:	00013517          	auipc	a0,0x13
    80002b1c:	0a050513          	addi	a0,a0,160 # 80015bb8 <tickslock>
    80002b20:	84afe0ef          	jal	ra,80000b6a <acquire>
  ticks0 = ticks;
    80002b24:	00005917          	auipc	s2,0x5
    80002b28:	d6492903          	lw	s2,-668(s2) # 80007888 <ticks>
  while(ticks - ticks0 < n){
    80002b2c:	fcc42783          	lw	a5,-52(s0)
    80002b30:	cb8d                	beqz	a5,80002b62 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b32:	00013997          	auipc	s3,0x13
    80002b36:	08698993          	addi	s3,s3,134 # 80015bb8 <tickslock>
    80002b3a:	00005497          	auipc	s1,0x5
    80002b3e:	d4e48493          	addi	s1,s1,-690 # 80007888 <ticks>
    if(killed(myproc())){
    80002b42:	cc1fe0ef          	jal	ra,80001802 <myproc>
    80002b46:	d40ff0ef          	jal	ra,80002086 <killed>
    80002b4a:	ed0d                	bnez	a0,80002b84 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b4c:	85ce                	mv	a1,s3
    80002b4e:	8526                	mv	a0,s1
    80002b50:	afeff0ef          	jal	ra,80001e4e <sleep>
  while(ticks - ticks0 < n){
    80002b54:	409c                	lw	a5,0(s1)
    80002b56:	412787bb          	subw	a5,a5,s2
    80002b5a:	fcc42703          	lw	a4,-52(s0)
    80002b5e:	fee7e2e3          	bltu	a5,a4,80002b42 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002b62:	00013517          	auipc	a0,0x13
    80002b66:	05650513          	addi	a0,a0,86 # 80015bb8 <tickslock>
    80002b6a:	898fe0ef          	jal	ra,80000c02 <release>
  return 0;
    80002b6e:	4501                	li	a0,0
}
    80002b70:	70e2                	ld	ra,56(sp)
    80002b72:	7442                	ld	s0,48(sp)
    80002b74:	74a2                	ld	s1,40(sp)
    80002b76:	7902                	ld	s2,32(sp)
    80002b78:	69e2                	ld	s3,24(sp)
    80002b7a:	6121                	addi	sp,sp,64
    80002b7c:	8082                	ret
    n = 0;
    80002b7e:	fc042623          	sw	zero,-52(s0)
    80002b82:	bf59                	j	80002b18 <sys_pause+0x20>
      release(&tickslock);
    80002b84:	00013517          	auipc	a0,0x13
    80002b88:	03450513          	addi	a0,a0,52 # 80015bb8 <tickslock>
    80002b8c:	876fe0ef          	jal	ra,80000c02 <release>
      return -1;
    80002b90:	557d                	li	a0,-1
    80002b92:	bff9                	j	80002b70 <sys_pause+0x78>

0000000080002b94 <sys_kill>:

uint64
sys_kill(void)
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b9c:	fec40593          	addi	a1,s0,-20
    80002ba0:	4501                	li	a0,0
    80002ba2:	d9fff0ef          	jal	ra,80002940 <argint>
  return kkill(pid);
    80002ba6:	fec42503          	lw	a0,-20(s0)
    80002baa:	c52ff0ef          	jal	ra,80001ffc <kkill>
}
    80002bae:	60e2                	ld	ra,24(sp)
    80002bb0:	6442                	ld	s0,16(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret

0000000080002bb6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bc0:	00013517          	auipc	a0,0x13
    80002bc4:	ff850513          	addi	a0,a0,-8 # 80015bb8 <tickslock>
    80002bc8:	fa3fd0ef          	jal	ra,80000b6a <acquire>
  xticks = ticks;
    80002bcc:	00005497          	auipc	s1,0x5
    80002bd0:	cbc4a483          	lw	s1,-836(s1) # 80007888 <ticks>
  release(&tickslock);
    80002bd4:	00013517          	auipc	a0,0x13
    80002bd8:	fe450513          	addi	a0,a0,-28 # 80015bb8 <tickslock>
    80002bdc:	826fe0ef          	jal	ra,80000c02 <release>
  return xticks;
}
    80002be0:	02049513          	slli	a0,s1,0x20
    80002be4:	9101                	srli	a0,a0,0x20
    80002be6:	60e2                	ld	ra,24(sp)
    80002be8:	6442                	ld	s0,16(sp)
    80002bea:	64a2                	ld	s1,8(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <sys_getpinfo>:

// Return an array of all process in ready qeue
uint64
sys_getpinfo(void)
{
    80002bf0:	1101                	addi	sp,sp,-32
    80002bf2:	ec06                	sd	ra,24(sp)
    80002bf4:	e822                	sd	s0,16(sp)
    80002bf6:	1000                	addi	s0,sp,32
  uint64 addr;
  argaddr(0, &addr);
    80002bf8:	fe840593          	addi	a1,s0,-24
    80002bfc:	4501                	li	a0,0
    80002bfe:	d5fff0ef          	jal	ra,8000295c <argaddr>
  return getpinfo((struct pstat*)addr);
    80002c02:	fe843503          	ld	a0,-24(s0)
    80002c06:	feaff0ef          	jal	ra,800023f0 <getpinfo>
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret

0000000080002c12 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	1000                	addi	s0,sp,32
  int pid, priority;
  argint(0, &pid);
    80002c1a:	fec40593          	addi	a1,s0,-20
    80002c1e:	4501                	li	a0,0
    80002c20:	d21ff0ef          	jal	ra,80002940 <argint>
  argint(1, &priority);
    80002c24:	fe840593          	addi	a1,s0,-24
    80002c28:	4505                	li	a0,1
    80002c2a:	d17ff0ef          	jal	ra,80002940 <argint>
  return set_priority(pid, priority);
    80002c2e:	fe842583          	lw	a1,-24(s0)
    80002c32:	fec42503          	lw	a0,-20(s0)
    80002c36:	f52ff0ef          	jal	ra,80002388 <set_priority>
}
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c42:	7179                	addi	sp,sp,-48
    80002c44:	f406                	sd	ra,40(sp)
    80002c46:	f022                	sd	s0,32(sp)
    80002c48:	ec26                	sd	s1,24(sp)
    80002c4a:	e84a                	sd	s2,16(sp)
    80002c4c:	e44e                	sd	s3,8(sp)
    80002c4e:	e052                	sd	s4,0(sp)
    80002c50:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c52:	00005597          	auipc	a1,0x5
    80002c56:	85e58593          	addi	a1,a1,-1954 # 800074b0 <syscalls+0xc0>
    80002c5a:	00013517          	auipc	a0,0x13
    80002c5e:	f7650513          	addi	a0,a0,-138 # 80015bd0 <bcache>
    80002c62:	e89fd0ef          	jal	ra,80000aea <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c66:	0001b797          	auipc	a5,0x1b
    80002c6a:	f6a78793          	addi	a5,a5,-150 # 8001dbd0 <bcache+0x8000>
    80002c6e:	0001b717          	auipc	a4,0x1b
    80002c72:	1ca70713          	addi	a4,a4,458 # 8001de38 <bcache+0x8268>
    80002c76:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c7a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c7e:	00013497          	auipc	s1,0x13
    80002c82:	f6a48493          	addi	s1,s1,-150 # 80015be8 <bcache+0x18>
    b->next = bcache.head.next;
    80002c86:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c88:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c8a:	00005a17          	auipc	s4,0x5
    80002c8e:	82ea0a13          	addi	s4,s4,-2002 # 800074b8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002c92:	2b893783          	ld	a5,696(s2)
    80002c96:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c98:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c9c:	85d2                	mv	a1,s4
    80002c9e:	01048513          	addi	a0,s1,16
    80002ca2:	302010ef          	jal	ra,80003fa4 <initsleeplock>
    bcache.head.next->prev = b;
    80002ca6:	2b893783          	ld	a5,696(s2)
    80002caa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cb0:	45848493          	addi	s1,s1,1112
    80002cb4:	fd349fe3          	bne	s1,s3,80002c92 <binit+0x50>
  }
}
    80002cb8:	70a2                	ld	ra,40(sp)
    80002cba:	7402                	ld	s0,32(sp)
    80002cbc:	64e2                	ld	s1,24(sp)
    80002cbe:	6942                	ld	s2,16(sp)
    80002cc0:	69a2                	ld	s3,8(sp)
    80002cc2:	6a02                	ld	s4,0(sp)
    80002cc4:	6145                	addi	sp,sp,48
    80002cc6:	8082                	ret

0000000080002cc8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002cc8:	7179                	addi	sp,sp,-48
    80002cca:	f406                	sd	ra,40(sp)
    80002ccc:	f022                	sd	s0,32(sp)
    80002cce:	ec26                	sd	s1,24(sp)
    80002cd0:	e84a                	sd	s2,16(sp)
    80002cd2:	e44e                	sd	s3,8(sp)
    80002cd4:	1800                	addi	s0,sp,48
    80002cd6:	892a                	mv	s2,a0
    80002cd8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cda:	00013517          	auipc	a0,0x13
    80002cde:	ef650513          	addi	a0,a0,-266 # 80015bd0 <bcache>
    80002ce2:	e89fd0ef          	jal	ra,80000b6a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ce6:	0001b497          	auipc	s1,0x1b
    80002cea:	1a24b483          	ld	s1,418(s1) # 8001de88 <bcache+0x82b8>
    80002cee:	0001b797          	auipc	a5,0x1b
    80002cf2:	14a78793          	addi	a5,a5,330 # 8001de38 <bcache+0x8268>
    80002cf6:	02f48b63          	beq	s1,a5,80002d2c <bread+0x64>
    80002cfa:	873e                	mv	a4,a5
    80002cfc:	a021                	j	80002d04 <bread+0x3c>
    80002cfe:	68a4                	ld	s1,80(s1)
    80002d00:	02e48663          	beq	s1,a4,80002d2c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d04:	449c                	lw	a5,8(s1)
    80002d06:	ff279ce3          	bne	a5,s2,80002cfe <bread+0x36>
    80002d0a:	44dc                	lw	a5,12(s1)
    80002d0c:	ff3799e3          	bne	a5,s3,80002cfe <bread+0x36>
      b->refcnt++;
    80002d10:	40bc                	lw	a5,64(s1)
    80002d12:	2785                	addiw	a5,a5,1
    80002d14:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d16:	00013517          	auipc	a0,0x13
    80002d1a:	eba50513          	addi	a0,a0,-326 # 80015bd0 <bcache>
    80002d1e:	ee5fd0ef          	jal	ra,80000c02 <release>
      acquiresleep(&b->lock);
    80002d22:	01048513          	addi	a0,s1,16
    80002d26:	2b4010ef          	jal	ra,80003fda <acquiresleep>
      return b;
    80002d2a:	a889                	j	80002d7c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d2c:	0001b497          	auipc	s1,0x1b
    80002d30:	1544b483          	ld	s1,340(s1) # 8001de80 <bcache+0x82b0>
    80002d34:	0001b797          	auipc	a5,0x1b
    80002d38:	10478793          	addi	a5,a5,260 # 8001de38 <bcache+0x8268>
    80002d3c:	00f48863          	beq	s1,a5,80002d4c <bread+0x84>
    80002d40:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d42:	40bc                	lw	a5,64(s1)
    80002d44:	cb91                	beqz	a5,80002d58 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d46:	64a4                	ld	s1,72(s1)
    80002d48:	fee49de3          	bne	s1,a4,80002d42 <bread+0x7a>
  panic("bget: no buffers");
    80002d4c:	00004517          	auipc	a0,0x4
    80002d50:	77450513          	addi	a0,a0,1908 # 800074c0 <syscalls+0xd0>
    80002d54:	a35fd0ef          	jal	ra,80000788 <panic>
      b->dev = dev;
    80002d58:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d5c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d60:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d64:	4785                	li	a5,1
    80002d66:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d68:	00013517          	auipc	a0,0x13
    80002d6c:	e6850513          	addi	a0,a0,-408 # 80015bd0 <bcache>
    80002d70:	e93fd0ef          	jal	ra,80000c02 <release>
      acquiresleep(&b->lock);
    80002d74:	01048513          	addi	a0,s1,16
    80002d78:	262010ef          	jal	ra,80003fda <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d7c:	409c                	lw	a5,0(s1)
    80002d7e:	cb89                	beqz	a5,80002d90 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d80:	8526                	mv	a0,s1
    80002d82:	70a2                	ld	ra,40(sp)
    80002d84:	7402                	ld	s0,32(sp)
    80002d86:	64e2                	ld	s1,24(sp)
    80002d88:	6942                	ld	s2,16(sp)
    80002d8a:	69a2                	ld	s3,8(sp)
    80002d8c:	6145                	addi	sp,sp,48
    80002d8e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d90:	4581                	li	a1,0
    80002d92:	8526                	mv	a0,s1
    80002d94:	1b7020ef          	jal	ra,8000574a <virtio_disk_rw>
    b->valid = 1;
    80002d98:	4785                	li	a5,1
    80002d9a:	c09c                	sw	a5,0(s1)
  return b;
    80002d9c:	b7d5                	j	80002d80 <bread+0xb8>

0000000080002d9e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d9e:	1101                	addi	sp,sp,-32
    80002da0:	ec06                	sd	ra,24(sp)
    80002da2:	e822                	sd	s0,16(sp)
    80002da4:	e426                	sd	s1,8(sp)
    80002da6:	1000                	addi	s0,sp,32
    80002da8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002daa:	0541                	addi	a0,a0,16
    80002dac:	2ac010ef          	jal	ra,80004058 <holdingsleep>
    80002db0:	c911                	beqz	a0,80002dc4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002db2:	4585                	li	a1,1
    80002db4:	8526                	mv	a0,s1
    80002db6:	195020ef          	jal	ra,8000574a <virtio_disk_rw>
}
    80002dba:	60e2                	ld	ra,24(sp)
    80002dbc:	6442                	ld	s0,16(sp)
    80002dbe:	64a2                	ld	s1,8(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret
    panic("bwrite");
    80002dc4:	00004517          	auipc	a0,0x4
    80002dc8:	71450513          	addi	a0,a0,1812 # 800074d8 <syscalls+0xe8>
    80002dcc:	9bdfd0ef          	jal	ra,80000788 <panic>

0000000080002dd0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
    80002ddc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dde:	01050913          	addi	s2,a0,16
    80002de2:	854a                	mv	a0,s2
    80002de4:	274010ef          	jal	ra,80004058 <holdingsleep>
    80002de8:	c13d                	beqz	a0,80002e4e <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002dea:	854a                	mv	a0,s2
    80002dec:	234010ef          	jal	ra,80004020 <releasesleep>

  acquire(&bcache.lock);
    80002df0:	00013517          	auipc	a0,0x13
    80002df4:	de050513          	addi	a0,a0,-544 # 80015bd0 <bcache>
    80002df8:	d73fd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt--;
    80002dfc:	40bc                	lw	a5,64(s1)
    80002dfe:	37fd                	addiw	a5,a5,-1
    80002e00:	0007871b          	sext.w	a4,a5
    80002e04:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e06:	eb05                	bnez	a4,80002e36 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e08:	68bc                	ld	a5,80(s1)
    80002e0a:	64b8                	ld	a4,72(s1)
    80002e0c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002e0e:	64bc                	ld	a5,72(s1)
    80002e10:	68b8                	ld	a4,80(s1)
    80002e12:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e14:	0001b797          	auipc	a5,0x1b
    80002e18:	dbc78793          	addi	a5,a5,-580 # 8001dbd0 <bcache+0x8000>
    80002e1c:	2b87b703          	ld	a4,696(a5)
    80002e20:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e22:	0001b717          	auipc	a4,0x1b
    80002e26:	01670713          	addi	a4,a4,22 # 8001de38 <bcache+0x8268>
    80002e2a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e2c:	2b87b703          	ld	a4,696(a5)
    80002e30:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e32:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e36:	00013517          	auipc	a0,0x13
    80002e3a:	d9a50513          	addi	a0,a0,-614 # 80015bd0 <bcache>
    80002e3e:	dc5fd0ef          	jal	ra,80000c02 <release>
}
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	6902                	ld	s2,0(sp)
    80002e4a:	6105                	addi	sp,sp,32
    80002e4c:	8082                	ret
    panic("brelse");
    80002e4e:	00004517          	auipc	a0,0x4
    80002e52:	69250513          	addi	a0,a0,1682 # 800074e0 <syscalls+0xf0>
    80002e56:	933fd0ef          	jal	ra,80000788 <panic>

0000000080002e5a <bpin>:

void
bpin(struct buf *b) {
    80002e5a:	1101                	addi	sp,sp,-32
    80002e5c:	ec06                	sd	ra,24(sp)
    80002e5e:	e822                	sd	s0,16(sp)
    80002e60:	e426                	sd	s1,8(sp)
    80002e62:	1000                	addi	s0,sp,32
    80002e64:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e66:	00013517          	auipc	a0,0x13
    80002e6a:	d6a50513          	addi	a0,a0,-662 # 80015bd0 <bcache>
    80002e6e:	cfdfd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt++;
    80002e72:	40bc                	lw	a5,64(s1)
    80002e74:	2785                	addiw	a5,a5,1
    80002e76:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e78:	00013517          	auipc	a0,0x13
    80002e7c:	d5850513          	addi	a0,a0,-680 # 80015bd0 <bcache>
    80002e80:	d83fd0ef          	jal	ra,80000c02 <release>
}
    80002e84:	60e2                	ld	ra,24(sp)
    80002e86:	6442                	ld	s0,16(sp)
    80002e88:	64a2                	ld	s1,8(sp)
    80002e8a:	6105                	addi	sp,sp,32
    80002e8c:	8082                	ret

0000000080002e8e <bunpin>:

void
bunpin(struct buf *b) {
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	e426                	sd	s1,8(sp)
    80002e96:	1000                	addi	s0,sp,32
    80002e98:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e9a:	00013517          	auipc	a0,0x13
    80002e9e:	d3650513          	addi	a0,a0,-714 # 80015bd0 <bcache>
    80002ea2:	cc9fd0ef          	jal	ra,80000b6a <acquire>
  b->refcnt--;
    80002ea6:	40bc                	lw	a5,64(s1)
    80002ea8:	37fd                	addiw	a5,a5,-1
    80002eaa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002eac:	00013517          	auipc	a0,0x13
    80002eb0:	d2450513          	addi	a0,a0,-732 # 80015bd0 <bcache>
    80002eb4:	d4ffd0ef          	jal	ra,80000c02 <release>
}
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	64a2                	ld	s1,8(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret

0000000080002ec2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	e04a                	sd	s2,0(sp)
    80002ecc:	1000                	addi	s0,sp,32
    80002ece:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ed0:	00d5d59b          	srliw	a1,a1,0xd
    80002ed4:	0001b797          	auipc	a5,0x1b
    80002ed8:	3d87a783          	lw	a5,984(a5) # 8001e2ac <sb+0x1c>
    80002edc:	9dbd                	addw	a1,a1,a5
    80002ede:	debff0ef          	jal	ra,80002cc8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ee2:	0074f713          	andi	a4,s1,7
    80002ee6:	4785                	li	a5,1
    80002ee8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002eec:	14ce                	slli	s1,s1,0x33
    80002eee:	90d9                	srli	s1,s1,0x36
    80002ef0:	00950733          	add	a4,a0,s1
    80002ef4:	05874703          	lbu	a4,88(a4)
    80002ef8:	00e7f6b3          	and	a3,a5,a4
    80002efc:	c29d                	beqz	a3,80002f22 <bfree+0x60>
    80002efe:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f00:	94aa                	add	s1,s1,a0
    80002f02:	fff7c793          	not	a5,a5
    80002f06:	8f7d                	and	a4,a4,a5
    80002f08:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f0c:	7d7000ef          	jal	ra,80003ee2 <log_write>
  brelse(bp);
    80002f10:	854a                	mv	a0,s2
    80002f12:	ebfff0ef          	jal	ra,80002dd0 <brelse>
}
    80002f16:	60e2                	ld	ra,24(sp)
    80002f18:	6442                	ld	s0,16(sp)
    80002f1a:	64a2                	ld	s1,8(sp)
    80002f1c:	6902                	ld	s2,0(sp)
    80002f1e:	6105                	addi	sp,sp,32
    80002f20:	8082                	ret
    panic("freeing free block");
    80002f22:	00004517          	auipc	a0,0x4
    80002f26:	5c650513          	addi	a0,a0,1478 # 800074e8 <syscalls+0xf8>
    80002f2a:	85ffd0ef          	jal	ra,80000788 <panic>

0000000080002f2e <balloc>:
{
    80002f2e:	711d                	addi	sp,sp,-96
    80002f30:	ec86                	sd	ra,88(sp)
    80002f32:	e8a2                	sd	s0,80(sp)
    80002f34:	e4a6                	sd	s1,72(sp)
    80002f36:	e0ca                	sd	s2,64(sp)
    80002f38:	fc4e                	sd	s3,56(sp)
    80002f3a:	f852                	sd	s4,48(sp)
    80002f3c:	f456                	sd	s5,40(sp)
    80002f3e:	f05a                	sd	s6,32(sp)
    80002f40:	ec5e                	sd	s7,24(sp)
    80002f42:	e862                	sd	s8,16(sp)
    80002f44:	e466                	sd	s9,8(sp)
    80002f46:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f48:	0001b797          	auipc	a5,0x1b
    80002f4c:	34c7a783          	lw	a5,844(a5) # 8001e294 <sb+0x4>
    80002f50:	cff1                	beqz	a5,8000302c <balloc+0xfe>
    80002f52:	8baa                	mv	s7,a0
    80002f54:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f56:	0001bb17          	auipc	s6,0x1b
    80002f5a:	33ab0b13          	addi	s6,s6,826 # 8001e290 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f5e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f60:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f62:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f64:	6c89                	lui	s9,0x2
    80002f66:	a0b5                	j	80002fd2 <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f68:	97ca                	add	a5,a5,s2
    80002f6a:	8e55                	or	a2,a2,a3
    80002f6c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f70:	854a                	mv	a0,s2
    80002f72:	771000ef          	jal	ra,80003ee2 <log_write>
        brelse(bp);
    80002f76:	854a                	mv	a0,s2
    80002f78:	e59ff0ef          	jal	ra,80002dd0 <brelse>
  bp = bread(dev, bno);
    80002f7c:	85a6                	mv	a1,s1
    80002f7e:	855e                	mv	a0,s7
    80002f80:	d49ff0ef          	jal	ra,80002cc8 <bread>
    80002f84:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f86:	40000613          	li	a2,1024
    80002f8a:	4581                	li	a1,0
    80002f8c:	05850513          	addi	a0,a0,88
    80002f90:	caffd0ef          	jal	ra,80000c3e <memset>
  log_write(bp);
    80002f94:	854a                	mv	a0,s2
    80002f96:	74d000ef          	jal	ra,80003ee2 <log_write>
  brelse(bp);
    80002f9a:	854a                	mv	a0,s2
    80002f9c:	e35ff0ef          	jal	ra,80002dd0 <brelse>
}
    80002fa0:	8526                	mv	a0,s1
    80002fa2:	60e6                	ld	ra,88(sp)
    80002fa4:	6446                	ld	s0,80(sp)
    80002fa6:	64a6                	ld	s1,72(sp)
    80002fa8:	6906                	ld	s2,64(sp)
    80002faa:	79e2                	ld	s3,56(sp)
    80002fac:	7a42                	ld	s4,48(sp)
    80002fae:	7aa2                	ld	s5,40(sp)
    80002fb0:	7b02                	ld	s6,32(sp)
    80002fb2:	6be2                	ld	s7,24(sp)
    80002fb4:	6c42                	ld	s8,16(sp)
    80002fb6:	6ca2                	ld	s9,8(sp)
    80002fb8:	6125                	addi	sp,sp,96
    80002fba:	8082                	ret
    brelse(bp);
    80002fbc:	854a                	mv	a0,s2
    80002fbe:	e13ff0ef          	jal	ra,80002dd0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002fc2:	015c87bb          	addw	a5,s9,s5
    80002fc6:	00078a9b          	sext.w	s5,a5
    80002fca:	004b2703          	lw	a4,4(s6)
    80002fce:	04eaff63          	bgeu	s5,a4,8000302c <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    80002fd2:	41fad79b          	sraiw	a5,s5,0x1f
    80002fd6:	0137d79b          	srliw	a5,a5,0x13
    80002fda:	015787bb          	addw	a5,a5,s5
    80002fde:	40d7d79b          	sraiw	a5,a5,0xd
    80002fe2:	01cb2583          	lw	a1,28(s6)
    80002fe6:	9dbd                	addw	a1,a1,a5
    80002fe8:	855e                	mv	a0,s7
    80002fea:	cdfff0ef          	jal	ra,80002cc8 <bread>
    80002fee:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff0:	004b2503          	lw	a0,4(s6)
    80002ff4:	000a849b          	sext.w	s1,s5
    80002ff8:	8762                	mv	a4,s8
    80002ffa:	fca4f1e3          	bgeu	s1,a0,80002fbc <balloc+0x8e>
      m = 1 << (bi % 8);
    80002ffe:	00777693          	andi	a3,a4,7
    80003002:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003006:	41f7579b          	sraiw	a5,a4,0x1f
    8000300a:	01d7d79b          	srliw	a5,a5,0x1d
    8000300e:	9fb9                	addw	a5,a5,a4
    80003010:	4037d79b          	sraiw	a5,a5,0x3
    80003014:	00f90633          	add	a2,s2,a5
    80003018:	05864603          	lbu	a2,88(a2)
    8000301c:	00c6f5b3          	and	a1,a3,a2
    80003020:	d5a1                	beqz	a1,80002f68 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003022:	2705                	addiw	a4,a4,1
    80003024:	2485                	addiw	s1,s1,1
    80003026:	fd471ae3          	bne	a4,s4,80002ffa <balloc+0xcc>
    8000302a:	bf49                	j	80002fbc <balloc+0x8e>
  printf("balloc: out of blocks\n");
    8000302c:	00004517          	auipc	a0,0x4
    80003030:	4d450513          	addi	a0,a0,1236 # 80007500 <syscalls+0x110>
    80003034:	c8efd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003038:	4481                	li	s1,0
    8000303a:	b79d                	j	80002fa0 <balloc+0x72>

000000008000303c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000303c:	7179                	addi	sp,sp,-48
    8000303e:	f406                	sd	ra,40(sp)
    80003040:	f022                	sd	s0,32(sp)
    80003042:	ec26                	sd	s1,24(sp)
    80003044:	e84a                	sd	s2,16(sp)
    80003046:	e44e                	sd	s3,8(sp)
    80003048:	e052                	sd	s4,0(sp)
    8000304a:	1800                	addi	s0,sp,48
    8000304c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000304e:	47ad                	li	a5,11
    80003050:	02b7e663          	bltu	a5,a1,8000307c <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80003054:	02059793          	slli	a5,a1,0x20
    80003058:	01e7d593          	srli	a1,a5,0x1e
    8000305c:	00b504b3          	add	s1,a0,a1
    80003060:	0504a903          	lw	s2,80(s1)
    80003064:	06091663          	bnez	s2,800030d0 <bmap+0x94>
      addr = balloc(ip->dev);
    80003068:	4108                	lw	a0,0(a0)
    8000306a:	ec5ff0ef          	jal	ra,80002f2e <balloc>
    8000306e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003072:	04090f63          	beqz	s2,800030d0 <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003076:	0524a823          	sw	s2,80(s1)
    8000307a:	a899                	j	800030d0 <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000307c:	ff45849b          	addiw	s1,a1,-12
    80003080:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003084:	0ff00793          	li	a5,255
    80003088:	06e7eb63          	bltu	a5,a4,800030fe <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000308c:	08052903          	lw	s2,128(a0)
    80003090:	00091b63          	bnez	s2,800030a6 <bmap+0x6a>
      addr = balloc(ip->dev);
    80003094:	4108                	lw	a0,0(a0)
    80003096:	e99ff0ef          	jal	ra,80002f2e <balloc>
    8000309a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000309e:	02090963          	beqz	s2,800030d0 <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030a2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800030a6:	85ca                	mv	a1,s2
    800030a8:	0009a503          	lw	a0,0(s3)
    800030ac:	c1dff0ef          	jal	ra,80002cc8 <bread>
    800030b0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030b2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030b6:	02049713          	slli	a4,s1,0x20
    800030ba:	01e75593          	srli	a1,a4,0x1e
    800030be:	00b784b3          	add	s1,a5,a1
    800030c2:	0004a903          	lw	s2,0(s1)
    800030c6:	00090e63          	beqz	s2,800030e2 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030ca:	8552                	mv	a0,s4
    800030cc:	d05ff0ef          	jal	ra,80002dd0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800030d0:	854a                	mv	a0,s2
    800030d2:	70a2                	ld	ra,40(sp)
    800030d4:	7402                	ld	s0,32(sp)
    800030d6:	64e2                	ld	s1,24(sp)
    800030d8:	6942                	ld	s2,16(sp)
    800030da:	69a2                	ld	s3,8(sp)
    800030dc:	6a02                	ld	s4,0(sp)
    800030de:	6145                	addi	sp,sp,48
    800030e0:	8082                	ret
      addr = balloc(ip->dev);
    800030e2:	0009a503          	lw	a0,0(s3)
    800030e6:	e49ff0ef          	jal	ra,80002f2e <balloc>
    800030ea:	0005091b          	sext.w	s2,a0
      if(addr){
    800030ee:	fc090ee3          	beqz	s2,800030ca <bmap+0x8e>
        a[bn] = addr;
    800030f2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030f6:	8552                	mv	a0,s4
    800030f8:	5eb000ef          	jal	ra,80003ee2 <log_write>
    800030fc:	b7f9                	j	800030ca <bmap+0x8e>
  panic("bmap: out of range");
    800030fe:	00004517          	auipc	a0,0x4
    80003102:	41a50513          	addi	a0,a0,1050 # 80007518 <syscalls+0x128>
    80003106:	e82fd0ef          	jal	ra,80000788 <panic>

000000008000310a <iget>:
{
    8000310a:	7179                	addi	sp,sp,-48
    8000310c:	f406                	sd	ra,40(sp)
    8000310e:	f022                	sd	s0,32(sp)
    80003110:	ec26                	sd	s1,24(sp)
    80003112:	e84a                	sd	s2,16(sp)
    80003114:	e44e                	sd	s3,8(sp)
    80003116:	e052                	sd	s4,0(sp)
    80003118:	1800                	addi	s0,sp,48
    8000311a:	89aa                	mv	s3,a0
    8000311c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000311e:	0001b517          	auipc	a0,0x1b
    80003122:	19250513          	addi	a0,a0,402 # 8001e2b0 <itable>
    80003126:	a45fd0ef          	jal	ra,80000b6a <acquire>
  empty = 0;
    8000312a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000312c:	0001b497          	auipc	s1,0x1b
    80003130:	19c48493          	addi	s1,s1,412 # 8001e2c8 <itable+0x18>
    80003134:	0001d697          	auipc	a3,0x1d
    80003138:	c2468693          	addi	a3,a3,-988 # 8001fd58 <log>
    8000313c:	a039                	j	8000314a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000313e:	02090963          	beqz	s2,80003170 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003142:	08848493          	addi	s1,s1,136
    80003146:	02d48863          	beq	s1,a3,80003176 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000314a:	449c                	lw	a5,8(s1)
    8000314c:	fef059e3          	blez	a5,8000313e <iget+0x34>
    80003150:	4098                	lw	a4,0(s1)
    80003152:	ff3716e3          	bne	a4,s3,8000313e <iget+0x34>
    80003156:	40d8                	lw	a4,4(s1)
    80003158:	ff4713e3          	bne	a4,s4,8000313e <iget+0x34>
      ip->ref++;
    8000315c:	2785                	addiw	a5,a5,1
    8000315e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003160:	0001b517          	auipc	a0,0x1b
    80003164:	15050513          	addi	a0,a0,336 # 8001e2b0 <itable>
    80003168:	a9bfd0ef          	jal	ra,80000c02 <release>
      return ip;
    8000316c:	8926                	mv	s2,s1
    8000316e:	a02d                	j	80003198 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003170:	fbe9                	bnez	a5,80003142 <iget+0x38>
    80003172:	8926                	mv	s2,s1
    80003174:	b7f9                	j	80003142 <iget+0x38>
  if(empty == 0)
    80003176:	02090a63          	beqz	s2,800031aa <iget+0xa0>
  ip->dev = dev;
    8000317a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000317e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003182:	4785                	li	a5,1
    80003184:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003188:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000318c:	0001b517          	auipc	a0,0x1b
    80003190:	12450513          	addi	a0,a0,292 # 8001e2b0 <itable>
    80003194:	a6ffd0ef          	jal	ra,80000c02 <release>
}
    80003198:	854a                	mv	a0,s2
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6a02                	ld	s4,0(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret
    panic("iget: no inodes");
    800031aa:	00004517          	auipc	a0,0x4
    800031ae:	38650513          	addi	a0,a0,902 # 80007530 <syscalls+0x140>
    800031b2:	dd6fd0ef          	jal	ra,80000788 <panic>

00000000800031b6 <iinit>:
{
    800031b6:	7179                	addi	sp,sp,-48
    800031b8:	f406                	sd	ra,40(sp)
    800031ba:	f022                	sd	s0,32(sp)
    800031bc:	ec26                	sd	s1,24(sp)
    800031be:	e84a                	sd	s2,16(sp)
    800031c0:	e44e                	sd	s3,8(sp)
    800031c2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031c4:	00004597          	auipc	a1,0x4
    800031c8:	37c58593          	addi	a1,a1,892 # 80007540 <syscalls+0x150>
    800031cc:	0001b517          	auipc	a0,0x1b
    800031d0:	0e450513          	addi	a0,a0,228 # 8001e2b0 <itable>
    800031d4:	917fd0ef          	jal	ra,80000aea <initlock>
  for(i = 0; i < NINODE; i++) {
    800031d8:	0001b497          	auipc	s1,0x1b
    800031dc:	10048493          	addi	s1,s1,256 # 8001e2d8 <itable+0x28>
    800031e0:	0001d997          	auipc	s3,0x1d
    800031e4:	b8898993          	addi	s3,s3,-1144 # 8001fd68 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031e8:	00004917          	auipc	s2,0x4
    800031ec:	36090913          	addi	s2,s2,864 # 80007548 <syscalls+0x158>
    800031f0:	85ca                	mv	a1,s2
    800031f2:	8526                	mv	a0,s1
    800031f4:	5b1000ef          	jal	ra,80003fa4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031f8:	08848493          	addi	s1,s1,136
    800031fc:	ff349ae3          	bne	s1,s3,800031f0 <iinit+0x3a>
}
    80003200:	70a2                	ld	ra,40(sp)
    80003202:	7402                	ld	s0,32(sp)
    80003204:	64e2                	ld	s1,24(sp)
    80003206:	6942                	ld	s2,16(sp)
    80003208:	69a2                	ld	s3,8(sp)
    8000320a:	6145                	addi	sp,sp,48
    8000320c:	8082                	ret

000000008000320e <ialloc>:
{
    8000320e:	715d                	addi	sp,sp,-80
    80003210:	e486                	sd	ra,72(sp)
    80003212:	e0a2                	sd	s0,64(sp)
    80003214:	fc26                	sd	s1,56(sp)
    80003216:	f84a                	sd	s2,48(sp)
    80003218:	f44e                	sd	s3,40(sp)
    8000321a:	f052                	sd	s4,32(sp)
    8000321c:	ec56                	sd	s5,24(sp)
    8000321e:	e85a                	sd	s6,16(sp)
    80003220:	e45e                	sd	s7,8(sp)
    80003222:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003224:	0001b717          	auipc	a4,0x1b
    80003228:	07872703          	lw	a4,120(a4) # 8001e29c <sb+0xc>
    8000322c:	4785                	li	a5,1
    8000322e:	04e7f663          	bgeu	a5,a4,8000327a <ialloc+0x6c>
    80003232:	8aaa                	mv	s5,a0
    80003234:	8bae                	mv	s7,a1
    80003236:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003238:	0001ba17          	auipc	s4,0x1b
    8000323c:	058a0a13          	addi	s4,s4,88 # 8001e290 <sb>
    80003240:	00048b1b          	sext.w	s6,s1
    80003244:	0044d593          	srli	a1,s1,0x4
    80003248:	018a2783          	lw	a5,24(s4)
    8000324c:	9dbd                	addw	a1,a1,a5
    8000324e:	8556                	mv	a0,s5
    80003250:	a79ff0ef          	jal	ra,80002cc8 <bread>
    80003254:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003256:	05850993          	addi	s3,a0,88
    8000325a:	00f4f793          	andi	a5,s1,15
    8000325e:	079a                	slli	a5,a5,0x6
    80003260:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003262:	00099783          	lh	a5,0(s3)
    80003266:	cf85                	beqz	a5,8000329e <ialloc+0x90>
    brelse(bp);
    80003268:	b69ff0ef          	jal	ra,80002dd0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000326c:	0485                	addi	s1,s1,1
    8000326e:	00ca2703          	lw	a4,12(s4)
    80003272:	0004879b          	sext.w	a5,s1
    80003276:	fce7e5e3          	bltu	a5,a4,80003240 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000327a:	00004517          	auipc	a0,0x4
    8000327e:	2d650513          	addi	a0,a0,726 # 80007550 <syscalls+0x160>
    80003282:	a40fd0ef          	jal	ra,800004c2 <printf>
  return 0;
    80003286:	4501                	li	a0,0
}
    80003288:	60a6                	ld	ra,72(sp)
    8000328a:	6406                	ld	s0,64(sp)
    8000328c:	74e2                	ld	s1,56(sp)
    8000328e:	7942                	ld	s2,48(sp)
    80003290:	79a2                	ld	s3,40(sp)
    80003292:	7a02                	ld	s4,32(sp)
    80003294:	6ae2                	ld	s5,24(sp)
    80003296:	6b42                	ld	s6,16(sp)
    80003298:	6ba2                	ld	s7,8(sp)
    8000329a:	6161                	addi	sp,sp,80
    8000329c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000329e:	04000613          	li	a2,64
    800032a2:	4581                	li	a1,0
    800032a4:	854e                	mv	a0,s3
    800032a6:	999fd0ef          	jal	ra,80000c3e <memset>
      dip->type = type;
    800032aa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800032ae:	854a                	mv	a0,s2
    800032b0:	433000ef          	jal	ra,80003ee2 <log_write>
      brelse(bp);
    800032b4:	854a                	mv	a0,s2
    800032b6:	b1bff0ef          	jal	ra,80002dd0 <brelse>
      return iget(dev, inum);
    800032ba:	85da                	mv	a1,s6
    800032bc:	8556                	mv	a0,s5
    800032be:	e4dff0ef          	jal	ra,8000310a <iget>
    800032c2:	b7d9                	j	80003288 <ialloc+0x7a>

00000000800032c4 <iupdate>:
{
    800032c4:	1101                	addi	sp,sp,-32
    800032c6:	ec06                	sd	ra,24(sp)
    800032c8:	e822                	sd	s0,16(sp)
    800032ca:	e426                	sd	s1,8(sp)
    800032cc:	e04a                	sd	s2,0(sp)
    800032ce:	1000                	addi	s0,sp,32
    800032d0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032d2:	415c                	lw	a5,4(a0)
    800032d4:	0047d79b          	srliw	a5,a5,0x4
    800032d8:	0001b597          	auipc	a1,0x1b
    800032dc:	fd05a583          	lw	a1,-48(a1) # 8001e2a8 <sb+0x18>
    800032e0:	9dbd                	addw	a1,a1,a5
    800032e2:	4108                	lw	a0,0(a0)
    800032e4:	9e5ff0ef          	jal	ra,80002cc8 <bread>
    800032e8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032ea:	05850793          	addi	a5,a0,88
    800032ee:	40d8                	lw	a4,4(s1)
    800032f0:	8b3d                	andi	a4,a4,15
    800032f2:	071a                	slli	a4,a4,0x6
    800032f4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032f6:	04449703          	lh	a4,68(s1)
    800032fa:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032fe:	04649703          	lh	a4,70(s1)
    80003302:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003306:	04849703          	lh	a4,72(s1)
    8000330a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000330e:	04a49703          	lh	a4,74(s1)
    80003312:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003316:	44f8                	lw	a4,76(s1)
    80003318:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000331a:	03400613          	li	a2,52
    8000331e:	05048593          	addi	a1,s1,80
    80003322:	00c78513          	addi	a0,a5,12
    80003326:	975fd0ef          	jal	ra,80000c9a <memmove>
  log_write(bp);
    8000332a:	854a                	mv	a0,s2
    8000332c:	3b7000ef          	jal	ra,80003ee2 <log_write>
  brelse(bp);
    80003330:	854a                	mv	a0,s2
    80003332:	a9fff0ef          	jal	ra,80002dd0 <brelse>
}
    80003336:	60e2                	ld	ra,24(sp)
    80003338:	6442                	ld	s0,16(sp)
    8000333a:	64a2                	ld	s1,8(sp)
    8000333c:	6902                	ld	s2,0(sp)
    8000333e:	6105                	addi	sp,sp,32
    80003340:	8082                	ret

0000000080003342 <idup>:
{
    80003342:	1101                	addi	sp,sp,-32
    80003344:	ec06                	sd	ra,24(sp)
    80003346:	e822                	sd	s0,16(sp)
    80003348:	e426                	sd	s1,8(sp)
    8000334a:	1000                	addi	s0,sp,32
    8000334c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000334e:	0001b517          	auipc	a0,0x1b
    80003352:	f6250513          	addi	a0,a0,-158 # 8001e2b0 <itable>
    80003356:	815fd0ef          	jal	ra,80000b6a <acquire>
  ip->ref++;
    8000335a:	449c                	lw	a5,8(s1)
    8000335c:	2785                	addiw	a5,a5,1
    8000335e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003360:	0001b517          	auipc	a0,0x1b
    80003364:	f5050513          	addi	a0,a0,-176 # 8001e2b0 <itable>
    80003368:	89bfd0ef          	jal	ra,80000c02 <release>
}
    8000336c:	8526                	mv	a0,s1
    8000336e:	60e2                	ld	ra,24(sp)
    80003370:	6442                	ld	s0,16(sp)
    80003372:	64a2                	ld	s1,8(sp)
    80003374:	6105                	addi	sp,sp,32
    80003376:	8082                	ret

0000000080003378 <ilock>:
{
    80003378:	1101                	addi	sp,sp,-32
    8000337a:	ec06                	sd	ra,24(sp)
    8000337c:	e822                	sd	s0,16(sp)
    8000337e:	e426                	sd	s1,8(sp)
    80003380:	e04a                	sd	s2,0(sp)
    80003382:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003384:	c105                	beqz	a0,800033a4 <ilock+0x2c>
    80003386:	84aa                	mv	s1,a0
    80003388:	451c                	lw	a5,8(a0)
    8000338a:	00f05d63          	blez	a5,800033a4 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000338e:	0541                	addi	a0,a0,16
    80003390:	44b000ef          	jal	ra,80003fda <acquiresleep>
  if(ip->valid == 0){
    80003394:	40bc                	lw	a5,64(s1)
    80003396:	cf89                	beqz	a5,800033b0 <ilock+0x38>
}
    80003398:	60e2                	ld	ra,24(sp)
    8000339a:	6442                	ld	s0,16(sp)
    8000339c:	64a2                	ld	s1,8(sp)
    8000339e:	6902                	ld	s2,0(sp)
    800033a0:	6105                	addi	sp,sp,32
    800033a2:	8082                	ret
    panic("ilock");
    800033a4:	00004517          	auipc	a0,0x4
    800033a8:	1c450513          	addi	a0,a0,452 # 80007568 <syscalls+0x178>
    800033ac:	bdcfd0ef          	jal	ra,80000788 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033b0:	40dc                	lw	a5,4(s1)
    800033b2:	0047d79b          	srliw	a5,a5,0x4
    800033b6:	0001b597          	auipc	a1,0x1b
    800033ba:	ef25a583          	lw	a1,-270(a1) # 8001e2a8 <sb+0x18>
    800033be:	9dbd                	addw	a1,a1,a5
    800033c0:	4088                	lw	a0,0(s1)
    800033c2:	907ff0ef          	jal	ra,80002cc8 <bread>
    800033c6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033c8:	05850593          	addi	a1,a0,88
    800033cc:	40dc                	lw	a5,4(s1)
    800033ce:	8bbd                	andi	a5,a5,15
    800033d0:	079a                	slli	a5,a5,0x6
    800033d2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033d4:	00059783          	lh	a5,0(a1)
    800033d8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033dc:	00259783          	lh	a5,2(a1)
    800033e0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033e4:	00459783          	lh	a5,4(a1)
    800033e8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033ec:	00659783          	lh	a5,6(a1)
    800033f0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033f4:	459c                	lw	a5,8(a1)
    800033f6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033f8:	03400613          	li	a2,52
    800033fc:	05b1                	addi	a1,a1,12
    800033fe:	05048513          	addi	a0,s1,80
    80003402:	899fd0ef          	jal	ra,80000c9a <memmove>
    brelse(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	9c9ff0ef          	jal	ra,80002dd0 <brelse>
    ip->valid = 1;
    8000340c:	4785                	li	a5,1
    8000340e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003410:	04449783          	lh	a5,68(s1)
    80003414:	f3d1                	bnez	a5,80003398 <ilock+0x20>
      panic("ilock: no type");
    80003416:	00004517          	auipc	a0,0x4
    8000341a:	15a50513          	addi	a0,a0,346 # 80007570 <syscalls+0x180>
    8000341e:	b6afd0ef          	jal	ra,80000788 <panic>

0000000080003422 <iunlock>:
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	e426                	sd	s1,8(sp)
    8000342a:	e04a                	sd	s2,0(sp)
    8000342c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000342e:	c505                	beqz	a0,80003456 <iunlock+0x34>
    80003430:	84aa                	mv	s1,a0
    80003432:	01050913          	addi	s2,a0,16
    80003436:	854a                	mv	a0,s2
    80003438:	421000ef          	jal	ra,80004058 <holdingsleep>
    8000343c:	cd09                	beqz	a0,80003456 <iunlock+0x34>
    8000343e:	449c                	lw	a5,8(s1)
    80003440:	00f05b63          	blez	a5,80003456 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003444:	854a                	mv	a0,s2
    80003446:	3db000ef          	jal	ra,80004020 <releasesleep>
}
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6902                	ld	s2,0(sp)
    80003452:	6105                	addi	sp,sp,32
    80003454:	8082                	ret
    panic("iunlock");
    80003456:	00004517          	auipc	a0,0x4
    8000345a:	12a50513          	addi	a0,a0,298 # 80007580 <syscalls+0x190>
    8000345e:	b2afd0ef          	jal	ra,80000788 <panic>

0000000080003462 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003462:	7179                	addi	sp,sp,-48
    80003464:	f406                	sd	ra,40(sp)
    80003466:	f022                	sd	s0,32(sp)
    80003468:	ec26                	sd	s1,24(sp)
    8000346a:	e84a                	sd	s2,16(sp)
    8000346c:	e44e                	sd	s3,8(sp)
    8000346e:	e052                	sd	s4,0(sp)
    80003470:	1800                	addi	s0,sp,48
    80003472:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003474:	05050493          	addi	s1,a0,80
    80003478:	08050913          	addi	s2,a0,128
    8000347c:	a021                	j	80003484 <itrunc+0x22>
    8000347e:	0491                	addi	s1,s1,4
    80003480:	01248b63          	beq	s1,s2,80003496 <itrunc+0x34>
    if(ip->addrs[i]){
    80003484:	408c                	lw	a1,0(s1)
    80003486:	dde5                	beqz	a1,8000347e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003488:	0009a503          	lw	a0,0(s3)
    8000348c:	a37ff0ef          	jal	ra,80002ec2 <bfree>
      ip->addrs[i] = 0;
    80003490:	0004a023          	sw	zero,0(s1)
    80003494:	b7ed                	j	8000347e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003496:	0809a583          	lw	a1,128(s3)
    8000349a:	ed91                	bnez	a1,800034b6 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000349c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034a0:	854e                	mv	a0,s3
    800034a2:	e23ff0ef          	jal	ra,800032c4 <iupdate>
}
    800034a6:	70a2                	ld	ra,40(sp)
    800034a8:	7402                	ld	s0,32(sp)
    800034aa:	64e2                	ld	s1,24(sp)
    800034ac:	6942                	ld	s2,16(sp)
    800034ae:	69a2                	ld	s3,8(sp)
    800034b0:	6a02                	ld	s4,0(sp)
    800034b2:	6145                	addi	sp,sp,48
    800034b4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034b6:	0009a503          	lw	a0,0(s3)
    800034ba:	80fff0ef          	jal	ra,80002cc8 <bread>
    800034be:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800034c0:	05850493          	addi	s1,a0,88
    800034c4:	45850913          	addi	s2,a0,1112
    800034c8:	a021                	j	800034d0 <itrunc+0x6e>
    800034ca:	0491                	addi	s1,s1,4
    800034cc:	01248963          	beq	s1,s2,800034de <itrunc+0x7c>
      if(a[j])
    800034d0:	408c                	lw	a1,0(s1)
    800034d2:	dde5                	beqz	a1,800034ca <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800034d4:	0009a503          	lw	a0,0(s3)
    800034d8:	9ebff0ef          	jal	ra,80002ec2 <bfree>
    800034dc:	b7fd                	j	800034ca <itrunc+0x68>
    brelse(bp);
    800034de:	8552                	mv	a0,s4
    800034e0:	8f1ff0ef          	jal	ra,80002dd0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034e4:	0809a583          	lw	a1,128(s3)
    800034e8:	0009a503          	lw	a0,0(s3)
    800034ec:	9d7ff0ef          	jal	ra,80002ec2 <bfree>
    ip->addrs[NDIRECT] = 0;
    800034f0:	0809a023          	sw	zero,128(s3)
    800034f4:	b765                	j	8000349c <itrunc+0x3a>

00000000800034f6 <iput>:
{
    800034f6:	1101                	addi	sp,sp,-32
    800034f8:	ec06                	sd	ra,24(sp)
    800034fa:	e822                	sd	s0,16(sp)
    800034fc:	e426                	sd	s1,8(sp)
    800034fe:	e04a                	sd	s2,0(sp)
    80003500:	1000                	addi	s0,sp,32
    80003502:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003504:	0001b517          	auipc	a0,0x1b
    80003508:	dac50513          	addi	a0,a0,-596 # 8001e2b0 <itable>
    8000350c:	e5efd0ef          	jal	ra,80000b6a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003510:	4498                	lw	a4,8(s1)
    80003512:	4785                	li	a5,1
    80003514:	02f70163          	beq	a4,a5,80003536 <iput+0x40>
  ip->ref--;
    80003518:	449c                	lw	a5,8(s1)
    8000351a:	37fd                	addiw	a5,a5,-1
    8000351c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000351e:	0001b517          	auipc	a0,0x1b
    80003522:	d9250513          	addi	a0,a0,-622 # 8001e2b0 <itable>
    80003526:	edcfd0ef          	jal	ra,80000c02 <release>
}
    8000352a:	60e2                	ld	ra,24(sp)
    8000352c:	6442                	ld	s0,16(sp)
    8000352e:	64a2                	ld	s1,8(sp)
    80003530:	6902                	ld	s2,0(sp)
    80003532:	6105                	addi	sp,sp,32
    80003534:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003536:	40bc                	lw	a5,64(s1)
    80003538:	d3e5                	beqz	a5,80003518 <iput+0x22>
    8000353a:	04a49783          	lh	a5,74(s1)
    8000353e:	ffe9                	bnez	a5,80003518 <iput+0x22>
    acquiresleep(&ip->lock);
    80003540:	01048913          	addi	s2,s1,16
    80003544:	854a                	mv	a0,s2
    80003546:	295000ef          	jal	ra,80003fda <acquiresleep>
    release(&itable.lock);
    8000354a:	0001b517          	auipc	a0,0x1b
    8000354e:	d6650513          	addi	a0,a0,-666 # 8001e2b0 <itable>
    80003552:	eb0fd0ef          	jal	ra,80000c02 <release>
    itrunc(ip);
    80003556:	8526                	mv	a0,s1
    80003558:	f0bff0ef          	jal	ra,80003462 <itrunc>
    ip->type = 0;
    8000355c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003560:	8526                	mv	a0,s1
    80003562:	d63ff0ef          	jal	ra,800032c4 <iupdate>
    ip->valid = 0;
    80003566:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000356a:	854a                	mv	a0,s2
    8000356c:	2b5000ef          	jal	ra,80004020 <releasesleep>
    acquire(&itable.lock);
    80003570:	0001b517          	auipc	a0,0x1b
    80003574:	d4050513          	addi	a0,a0,-704 # 8001e2b0 <itable>
    80003578:	df2fd0ef          	jal	ra,80000b6a <acquire>
    8000357c:	bf71                	j	80003518 <iput+0x22>

000000008000357e <iunlockput>:
{
    8000357e:	1101                	addi	sp,sp,-32
    80003580:	ec06                	sd	ra,24(sp)
    80003582:	e822                	sd	s0,16(sp)
    80003584:	e426                	sd	s1,8(sp)
    80003586:	1000                	addi	s0,sp,32
    80003588:	84aa                	mv	s1,a0
  iunlock(ip);
    8000358a:	e99ff0ef          	jal	ra,80003422 <iunlock>
  iput(ip);
    8000358e:	8526                	mv	a0,s1
    80003590:	f67ff0ef          	jal	ra,800034f6 <iput>
}
    80003594:	60e2                	ld	ra,24(sp)
    80003596:	6442                	ld	s0,16(sp)
    80003598:	64a2                	ld	s1,8(sp)
    8000359a:	6105                	addi	sp,sp,32
    8000359c:	8082                	ret

000000008000359e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000359e:	0001b717          	auipc	a4,0x1b
    800035a2:	cfe72703          	lw	a4,-770(a4) # 8001e29c <sb+0xc>
    800035a6:	4785                	li	a5,1
    800035a8:	0ae7ff63          	bgeu	a5,a4,80003666 <ireclaim+0xc8>
{
    800035ac:	7139                	addi	sp,sp,-64
    800035ae:	fc06                	sd	ra,56(sp)
    800035b0:	f822                	sd	s0,48(sp)
    800035b2:	f426                	sd	s1,40(sp)
    800035b4:	f04a                	sd	s2,32(sp)
    800035b6:	ec4e                	sd	s3,24(sp)
    800035b8:	e852                	sd	s4,16(sp)
    800035ba:	e456                	sd	s5,8(sp)
    800035bc:	e05a                	sd	s6,0(sp)
    800035be:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035c0:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035c2:	00050a1b          	sext.w	s4,a0
    800035c6:	0001ba97          	auipc	s5,0x1b
    800035ca:	ccaa8a93          	addi	s5,s5,-822 # 8001e290 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035ce:	00004b17          	auipc	s6,0x4
    800035d2:	fbab0b13          	addi	s6,s6,-70 # 80007588 <syscalls+0x198>
    800035d6:	a099                	j	8000361c <ireclaim+0x7e>
    800035d8:	85ce                	mv	a1,s3
    800035da:	855a                	mv	a0,s6
    800035dc:	ee7fc0ef          	jal	ra,800004c2 <printf>
      ip = iget(dev, inum);
    800035e0:	85ce                	mv	a1,s3
    800035e2:	8552                	mv	a0,s4
    800035e4:	b27ff0ef          	jal	ra,8000310a <iget>
    800035e8:	89aa                	mv	s3,a0
    brelse(bp);
    800035ea:	854a                	mv	a0,s2
    800035ec:	fe4ff0ef          	jal	ra,80002dd0 <brelse>
    if (ip) {
    800035f0:	00098f63          	beqz	s3,8000360e <ireclaim+0x70>
      begin_op();
    800035f4:	76c000ef          	jal	ra,80003d60 <begin_op>
      ilock(ip);
    800035f8:	854e                	mv	a0,s3
    800035fa:	d7fff0ef          	jal	ra,80003378 <ilock>
      iunlock(ip);
    800035fe:	854e                	mv	a0,s3
    80003600:	e23ff0ef          	jal	ra,80003422 <iunlock>
      iput(ip);
    80003604:	854e                	mv	a0,s3
    80003606:	ef1ff0ef          	jal	ra,800034f6 <iput>
      end_op();
    8000360a:	7c4000ef          	jal	ra,80003dce <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000360e:	0485                	addi	s1,s1,1
    80003610:	00caa703          	lw	a4,12(s5)
    80003614:	0004879b          	sext.w	a5,s1
    80003618:	02e7fd63          	bgeu	a5,a4,80003652 <ireclaim+0xb4>
    8000361c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003620:	0044d593          	srli	a1,s1,0x4
    80003624:	018aa783          	lw	a5,24(s5)
    80003628:	9dbd                	addw	a1,a1,a5
    8000362a:	8552                	mv	a0,s4
    8000362c:	e9cff0ef          	jal	ra,80002cc8 <bread>
    80003630:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003632:	05850793          	addi	a5,a0,88
    80003636:	00f9f713          	andi	a4,s3,15
    8000363a:	071a                	slli	a4,a4,0x6
    8000363c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000363e:	00079703          	lh	a4,0(a5)
    80003642:	c701                	beqz	a4,8000364a <ireclaim+0xac>
    80003644:	00679783          	lh	a5,6(a5)
    80003648:	dbc1                	beqz	a5,800035d8 <ireclaim+0x3a>
    brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	f84ff0ef          	jal	ra,80002dd0 <brelse>
    if (ip) {
    80003650:	bf7d                	j	8000360e <ireclaim+0x70>
}
    80003652:	70e2                	ld	ra,56(sp)
    80003654:	7442                	ld	s0,48(sp)
    80003656:	74a2                	ld	s1,40(sp)
    80003658:	7902                	ld	s2,32(sp)
    8000365a:	69e2                	ld	s3,24(sp)
    8000365c:	6a42                	ld	s4,16(sp)
    8000365e:	6aa2                	ld	s5,8(sp)
    80003660:	6b02                	ld	s6,0(sp)
    80003662:	6121                	addi	sp,sp,64
    80003664:	8082                	ret
    80003666:	8082                	ret

0000000080003668 <fsinit>:
fsinit(int dev) {
    80003668:	7179                	addi	sp,sp,-48
    8000366a:	f406                	sd	ra,40(sp)
    8000366c:	f022                	sd	s0,32(sp)
    8000366e:	ec26                	sd	s1,24(sp)
    80003670:	e84a                	sd	s2,16(sp)
    80003672:	e44e                	sd	s3,8(sp)
    80003674:	1800                	addi	s0,sp,48
    80003676:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003678:	4585                	li	a1,1
    8000367a:	e4eff0ef          	jal	ra,80002cc8 <bread>
    8000367e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003680:	0001b997          	auipc	s3,0x1b
    80003684:	c1098993          	addi	s3,s3,-1008 # 8001e290 <sb>
    80003688:	02000613          	li	a2,32
    8000368c:	05850593          	addi	a1,a0,88
    80003690:	854e                	mv	a0,s3
    80003692:	e08fd0ef          	jal	ra,80000c9a <memmove>
  brelse(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	f38ff0ef          	jal	ra,80002dd0 <brelse>
  if(sb.magic != FSMAGIC)
    8000369c:	0009a703          	lw	a4,0(s3)
    800036a0:	102037b7          	lui	a5,0x10203
    800036a4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036a8:	02f71363          	bne	a4,a5,800036ce <fsinit+0x66>
  initlog(dev, &sb);
    800036ac:	0001b597          	auipc	a1,0x1b
    800036b0:	be458593          	addi	a1,a1,-1052 # 8001e290 <sb>
    800036b4:	8526                	mv	a0,s1
    800036b6:	61e000ef          	jal	ra,80003cd4 <initlog>
  ireclaim(dev);
    800036ba:	8526                	mv	a0,s1
    800036bc:	ee3ff0ef          	jal	ra,8000359e <ireclaim>
}
    800036c0:	70a2                	ld	ra,40(sp)
    800036c2:	7402                	ld	s0,32(sp)
    800036c4:	64e2                	ld	s1,24(sp)
    800036c6:	6942                	ld	s2,16(sp)
    800036c8:	69a2                	ld	s3,8(sp)
    800036ca:	6145                	addi	sp,sp,48
    800036cc:	8082                	ret
    panic("invalid file system");
    800036ce:	00004517          	auipc	a0,0x4
    800036d2:	eda50513          	addi	a0,a0,-294 # 800075a8 <syscalls+0x1b8>
    800036d6:	8b2fd0ef          	jal	ra,80000788 <panic>

00000000800036da <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036da:	1141                	addi	sp,sp,-16
    800036dc:	e422                	sd	s0,8(sp)
    800036de:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036e0:	411c                	lw	a5,0(a0)
    800036e2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036e4:	415c                	lw	a5,4(a0)
    800036e6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036e8:	04451783          	lh	a5,68(a0)
    800036ec:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036f0:	04a51783          	lh	a5,74(a0)
    800036f4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036f8:	04c56783          	lwu	a5,76(a0)
    800036fc:	e99c                	sd	a5,16(a1)
}
    800036fe:	6422                	ld	s0,8(sp)
    80003700:	0141                	addi	sp,sp,16
    80003702:	8082                	ret

0000000080003704 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003704:	457c                	lw	a5,76(a0)
    80003706:	0cd7ef63          	bltu	a5,a3,800037e4 <readi+0xe0>
{
    8000370a:	7159                	addi	sp,sp,-112
    8000370c:	f486                	sd	ra,104(sp)
    8000370e:	f0a2                	sd	s0,96(sp)
    80003710:	eca6                	sd	s1,88(sp)
    80003712:	e8ca                	sd	s2,80(sp)
    80003714:	e4ce                	sd	s3,72(sp)
    80003716:	e0d2                	sd	s4,64(sp)
    80003718:	fc56                	sd	s5,56(sp)
    8000371a:	f85a                	sd	s6,48(sp)
    8000371c:	f45e                	sd	s7,40(sp)
    8000371e:	f062                	sd	s8,32(sp)
    80003720:	ec66                	sd	s9,24(sp)
    80003722:	e86a                	sd	s10,16(sp)
    80003724:	e46e                	sd	s11,8(sp)
    80003726:	1880                	addi	s0,sp,112
    80003728:	8b2a                	mv	s6,a0
    8000372a:	8bae                	mv	s7,a1
    8000372c:	8a32                	mv	s4,a2
    8000372e:	84b6                	mv	s1,a3
    80003730:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003732:	9f35                	addw	a4,a4,a3
    return 0;
    80003734:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003736:	08d76663          	bltu	a4,a3,800037c2 <readi+0xbe>
  if(off + n > ip->size)
    8000373a:	00e7f463          	bgeu	a5,a4,80003742 <readi+0x3e>
    n = ip->size - off;
    8000373e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003742:	080a8f63          	beqz	s5,800037e0 <readi+0xdc>
    80003746:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003748:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000374c:	5c7d                	li	s8,-1
    8000374e:	a80d                	j	80003780 <readi+0x7c>
    80003750:	020d1d93          	slli	s11,s10,0x20
    80003754:	020ddd93          	srli	s11,s11,0x20
    80003758:	05890613          	addi	a2,s2,88
    8000375c:	86ee                	mv	a3,s11
    8000375e:	963a                	add	a2,a2,a4
    80003760:	85d2                	mv	a1,s4
    80003762:	855e                	mv	a0,s7
    80003764:	a47fe0ef          	jal	ra,800021aa <either_copyout>
    80003768:	05850763          	beq	a0,s8,800037b6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000376c:	854a                	mv	a0,s2
    8000376e:	e62ff0ef          	jal	ra,80002dd0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003772:	013d09bb          	addw	s3,s10,s3
    80003776:	009d04bb          	addw	s1,s10,s1
    8000377a:	9a6e                	add	s4,s4,s11
    8000377c:	0559f163          	bgeu	s3,s5,800037be <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003780:	00a4d59b          	srliw	a1,s1,0xa
    80003784:	855a                	mv	a0,s6
    80003786:	8b7ff0ef          	jal	ra,8000303c <bmap>
    8000378a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000378e:	c985                	beqz	a1,800037be <readi+0xba>
    bp = bread(ip->dev, addr);
    80003790:	000b2503          	lw	a0,0(s6)
    80003794:	d34ff0ef          	jal	ra,80002cc8 <bread>
    80003798:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000379a:	3ff4f713          	andi	a4,s1,1023
    8000379e:	40ec87bb          	subw	a5,s9,a4
    800037a2:	413a86bb          	subw	a3,s5,s3
    800037a6:	8d3e                	mv	s10,a5
    800037a8:	2781                	sext.w	a5,a5
    800037aa:	0006861b          	sext.w	a2,a3
    800037ae:	faf671e3          	bgeu	a2,a5,80003750 <readi+0x4c>
    800037b2:	8d36                	mv	s10,a3
    800037b4:	bf71                	j	80003750 <readi+0x4c>
      brelse(bp);
    800037b6:	854a                	mv	a0,s2
    800037b8:	e18ff0ef          	jal	ra,80002dd0 <brelse>
      tot = -1;
    800037bc:	59fd                	li	s3,-1
  }
  return tot;
    800037be:	0009851b          	sext.w	a0,s3
}
    800037c2:	70a6                	ld	ra,104(sp)
    800037c4:	7406                	ld	s0,96(sp)
    800037c6:	64e6                	ld	s1,88(sp)
    800037c8:	6946                	ld	s2,80(sp)
    800037ca:	69a6                	ld	s3,72(sp)
    800037cc:	6a06                	ld	s4,64(sp)
    800037ce:	7ae2                	ld	s5,56(sp)
    800037d0:	7b42                	ld	s6,48(sp)
    800037d2:	7ba2                	ld	s7,40(sp)
    800037d4:	7c02                	ld	s8,32(sp)
    800037d6:	6ce2                	ld	s9,24(sp)
    800037d8:	6d42                	ld	s10,16(sp)
    800037da:	6da2                	ld	s11,8(sp)
    800037dc:	6165                	addi	sp,sp,112
    800037de:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037e0:	89d6                	mv	s3,s5
    800037e2:	bff1                	j	800037be <readi+0xba>
    return 0;
    800037e4:	4501                	li	a0,0
}
    800037e6:	8082                	ret

00000000800037e8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037e8:	457c                	lw	a5,76(a0)
    800037ea:	0ed7ea63          	bltu	a5,a3,800038de <writei+0xf6>
{
    800037ee:	7159                	addi	sp,sp,-112
    800037f0:	f486                	sd	ra,104(sp)
    800037f2:	f0a2                	sd	s0,96(sp)
    800037f4:	eca6                	sd	s1,88(sp)
    800037f6:	e8ca                	sd	s2,80(sp)
    800037f8:	e4ce                	sd	s3,72(sp)
    800037fa:	e0d2                	sd	s4,64(sp)
    800037fc:	fc56                	sd	s5,56(sp)
    800037fe:	f85a                	sd	s6,48(sp)
    80003800:	f45e                	sd	s7,40(sp)
    80003802:	f062                	sd	s8,32(sp)
    80003804:	ec66                	sd	s9,24(sp)
    80003806:	e86a                	sd	s10,16(sp)
    80003808:	e46e                	sd	s11,8(sp)
    8000380a:	1880                	addi	s0,sp,112
    8000380c:	8aaa                	mv	s5,a0
    8000380e:	8bae                	mv	s7,a1
    80003810:	8a32                	mv	s4,a2
    80003812:	8936                	mv	s2,a3
    80003814:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003816:	00e687bb          	addw	a5,a3,a4
    8000381a:	0cd7e463          	bltu	a5,a3,800038e2 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000381e:	00043737          	lui	a4,0x43
    80003822:	0cf76263          	bltu	a4,a5,800038e6 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003826:	0a0b0a63          	beqz	s6,800038da <writei+0xf2>
    8000382a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000382c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003830:	5c7d                	li	s8,-1
    80003832:	a825                	j	8000386a <writei+0x82>
    80003834:	020d1d93          	slli	s11,s10,0x20
    80003838:	020ddd93          	srli	s11,s11,0x20
    8000383c:	05848513          	addi	a0,s1,88
    80003840:	86ee                	mv	a3,s11
    80003842:	8652                	mv	a2,s4
    80003844:	85de                	mv	a1,s7
    80003846:	953a                	add	a0,a0,a4
    80003848:	9adfe0ef          	jal	ra,800021f4 <either_copyin>
    8000384c:	05850a63          	beq	a0,s8,800038a0 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003850:	8526                	mv	a0,s1
    80003852:	690000ef          	jal	ra,80003ee2 <log_write>
    brelse(bp);
    80003856:	8526                	mv	a0,s1
    80003858:	d78ff0ef          	jal	ra,80002dd0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000385c:	013d09bb          	addw	s3,s10,s3
    80003860:	012d093b          	addw	s2,s10,s2
    80003864:	9a6e                	add	s4,s4,s11
    80003866:	0569f063          	bgeu	s3,s6,800038a6 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000386a:	00a9559b          	srliw	a1,s2,0xa
    8000386e:	8556                	mv	a0,s5
    80003870:	fccff0ef          	jal	ra,8000303c <bmap>
    80003874:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003878:	c59d                	beqz	a1,800038a6 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000387a:	000aa503          	lw	a0,0(s5)
    8000387e:	c4aff0ef          	jal	ra,80002cc8 <bread>
    80003882:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003884:	3ff97713          	andi	a4,s2,1023
    80003888:	40ec87bb          	subw	a5,s9,a4
    8000388c:	413b06bb          	subw	a3,s6,s3
    80003890:	8d3e                	mv	s10,a5
    80003892:	2781                	sext.w	a5,a5
    80003894:	0006861b          	sext.w	a2,a3
    80003898:	f8f67ee3          	bgeu	a2,a5,80003834 <writei+0x4c>
    8000389c:	8d36                	mv	s10,a3
    8000389e:	bf59                	j	80003834 <writei+0x4c>
      brelse(bp);
    800038a0:	8526                	mv	a0,s1
    800038a2:	d2eff0ef          	jal	ra,80002dd0 <brelse>
  }

  if(off > ip->size)
    800038a6:	04caa783          	lw	a5,76(s5)
    800038aa:	0127f463          	bgeu	a5,s2,800038b2 <writei+0xca>
    ip->size = off;
    800038ae:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038b2:	8556                	mv	a0,s5
    800038b4:	a11ff0ef          	jal	ra,800032c4 <iupdate>

  return tot;
    800038b8:	0009851b          	sext.w	a0,s3
}
    800038bc:	70a6                	ld	ra,104(sp)
    800038be:	7406                	ld	s0,96(sp)
    800038c0:	64e6                	ld	s1,88(sp)
    800038c2:	6946                	ld	s2,80(sp)
    800038c4:	69a6                	ld	s3,72(sp)
    800038c6:	6a06                	ld	s4,64(sp)
    800038c8:	7ae2                	ld	s5,56(sp)
    800038ca:	7b42                	ld	s6,48(sp)
    800038cc:	7ba2                	ld	s7,40(sp)
    800038ce:	7c02                	ld	s8,32(sp)
    800038d0:	6ce2                	ld	s9,24(sp)
    800038d2:	6d42                	ld	s10,16(sp)
    800038d4:	6da2                	ld	s11,8(sp)
    800038d6:	6165                	addi	sp,sp,112
    800038d8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038da:	89da                	mv	s3,s6
    800038dc:	bfd9                	j	800038b2 <writei+0xca>
    return -1;
    800038de:	557d                	li	a0,-1
}
    800038e0:	8082                	ret
    return -1;
    800038e2:	557d                	li	a0,-1
    800038e4:	bfe1                	j	800038bc <writei+0xd4>
    return -1;
    800038e6:	557d                	li	a0,-1
    800038e8:	bfd1                	j	800038bc <writei+0xd4>

00000000800038ea <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038ea:	1141                	addi	sp,sp,-16
    800038ec:	e406                	sd	ra,8(sp)
    800038ee:	e022                	sd	s0,0(sp)
    800038f0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038f2:	4639                	li	a2,14
    800038f4:	c16fd0ef          	jal	ra,80000d0a <strncmp>
}
    800038f8:	60a2                	ld	ra,8(sp)
    800038fa:	6402                	ld	s0,0(sp)
    800038fc:	0141                	addi	sp,sp,16
    800038fe:	8082                	ret

0000000080003900 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003900:	7139                	addi	sp,sp,-64
    80003902:	fc06                	sd	ra,56(sp)
    80003904:	f822                	sd	s0,48(sp)
    80003906:	f426                	sd	s1,40(sp)
    80003908:	f04a                	sd	s2,32(sp)
    8000390a:	ec4e                	sd	s3,24(sp)
    8000390c:	e852                	sd	s4,16(sp)
    8000390e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003910:	04451703          	lh	a4,68(a0)
    80003914:	4785                	li	a5,1
    80003916:	00f71a63          	bne	a4,a5,8000392a <dirlookup+0x2a>
    8000391a:	892a                	mv	s2,a0
    8000391c:	89ae                	mv	s3,a1
    8000391e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003920:	457c                	lw	a5,76(a0)
    80003922:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003924:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003926:	e39d                	bnez	a5,8000394c <dirlookup+0x4c>
    80003928:	a095                	j	8000398c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000392a:	00004517          	auipc	a0,0x4
    8000392e:	c9650513          	addi	a0,a0,-874 # 800075c0 <syscalls+0x1d0>
    80003932:	e57fc0ef          	jal	ra,80000788 <panic>
      panic("dirlookup read");
    80003936:	00004517          	auipc	a0,0x4
    8000393a:	ca250513          	addi	a0,a0,-862 # 800075d8 <syscalls+0x1e8>
    8000393e:	e4bfc0ef          	jal	ra,80000788 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003942:	24c1                	addiw	s1,s1,16
    80003944:	04c92783          	lw	a5,76(s2)
    80003948:	04f4f163          	bgeu	s1,a5,8000398a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000394c:	4741                	li	a4,16
    8000394e:	86a6                	mv	a3,s1
    80003950:	fc040613          	addi	a2,s0,-64
    80003954:	4581                	li	a1,0
    80003956:	854a                	mv	a0,s2
    80003958:	dadff0ef          	jal	ra,80003704 <readi>
    8000395c:	47c1                	li	a5,16
    8000395e:	fcf51ce3          	bne	a0,a5,80003936 <dirlookup+0x36>
    if(de.inum == 0)
    80003962:	fc045783          	lhu	a5,-64(s0)
    80003966:	dff1                	beqz	a5,80003942 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003968:	fc240593          	addi	a1,s0,-62
    8000396c:	854e                	mv	a0,s3
    8000396e:	f7dff0ef          	jal	ra,800038ea <namecmp>
    80003972:	f961                	bnez	a0,80003942 <dirlookup+0x42>
      if(poff)
    80003974:	000a0463          	beqz	s4,8000397c <dirlookup+0x7c>
        *poff = off;
    80003978:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000397c:	fc045583          	lhu	a1,-64(s0)
    80003980:	00092503          	lw	a0,0(s2)
    80003984:	f86ff0ef          	jal	ra,8000310a <iget>
    80003988:	a011                	j	8000398c <dirlookup+0x8c>
  return 0;
    8000398a:	4501                	li	a0,0
}
    8000398c:	70e2                	ld	ra,56(sp)
    8000398e:	7442                	ld	s0,48(sp)
    80003990:	74a2                	ld	s1,40(sp)
    80003992:	7902                	ld	s2,32(sp)
    80003994:	69e2                	ld	s3,24(sp)
    80003996:	6a42                	ld	s4,16(sp)
    80003998:	6121                	addi	sp,sp,64
    8000399a:	8082                	ret

000000008000399c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000399c:	711d                	addi	sp,sp,-96
    8000399e:	ec86                	sd	ra,88(sp)
    800039a0:	e8a2                	sd	s0,80(sp)
    800039a2:	e4a6                	sd	s1,72(sp)
    800039a4:	e0ca                	sd	s2,64(sp)
    800039a6:	fc4e                	sd	s3,56(sp)
    800039a8:	f852                	sd	s4,48(sp)
    800039aa:	f456                	sd	s5,40(sp)
    800039ac:	f05a                	sd	s6,32(sp)
    800039ae:	ec5e                	sd	s7,24(sp)
    800039b0:	e862                	sd	s8,16(sp)
    800039b2:	e466                	sd	s9,8(sp)
    800039b4:	e06a                	sd	s10,0(sp)
    800039b6:	1080                	addi	s0,sp,96
    800039b8:	84aa                	mv	s1,a0
    800039ba:	8b2e                	mv	s6,a1
    800039bc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800039be:	00054703          	lbu	a4,0(a0)
    800039c2:	02f00793          	li	a5,47
    800039c6:	00f70f63          	beq	a4,a5,800039e4 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039ca:	e39fd0ef          	jal	ra,80001802 <myproc>
    800039ce:	15053503          	ld	a0,336(a0)
    800039d2:	971ff0ef          	jal	ra,80003342 <idup>
    800039d6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800039d8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800039dc:	4cb5                	li	s9,13
  len = path - s;
    800039de:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039e0:	4c05                	li	s8,1
    800039e2:	a879                	j	80003a80 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800039e4:	4585                	li	a1,1
    800039e6:	4505                	li	a0,1
    800039e8:	f22ff0ef          	jal	ra,8000310a <iget>
    800039ec:	8a2a                	mv	s4,a0
    800039ee:	b7ed                	j	800039d8 <namex+0x3c>
      iunlockput(ip);
    800039f0:	8552                	mv	a0,s4
    800039f2:	b8dff0ef          	jal	ra,8000357e <iunlockput>
      return 0;
    800039f6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039f8:	8552                	mv	a0,s4
    800039fa:	60e6                	ld	ra,88(sp)
    800039fc:	6446                	ld	s0,80(sp)
    800039fe:	64a6                	ld	s1,72(sp)
    80003a00:	6906                	ld	s2,64(sp)
    80003a02:	79e2                	ld	s3,56(sp)
    80003a04:	7a42                	ld	s4,48(sp)
    80003a06:	7aa2                	ld	s5,40(sp)
    80003a08:	7b02                	ld	s6,32(sp)
    80003a0a:	6be2                	ld	s7,24(sp)
    80003a0c:	6c42                	ld	s8,16(sp)
    80003a0e:	6ca2                	ld	s9,8(sp)
    80003a10:	6d02                	ld	s10,0(sp)
    80003a12:	6125                	addi	sp,sp,96
    80003a14:	8082                	ret
      iunlock(ip);
    80003a16:	8552                	mv	a0,s4
    80003a18:	a0bff0ef          	jal	ra,80003422 <iunlock>
      return ip;
    80003a1c:	bff1                	j	800039f8 <namex+0x5c>
      iunlockput(ip);
    80003a1e:	8552                	mv	a0,s4
    80003a20:	b5fff0ef          	jal	ra,8000357e <iunlockput>
      return 0;
    80003a24:	8a4e                	mv	s4,s3
    80003a26:	bfc9                	j	800039f8 <namex+0x5c>
  len = path - s;
    80003a28:	40998633          	sub	a2,s3,s1
    80003a2c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003a30:	09acd063          	bge	s9,s10,80003ab0 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003a34:	4639                	li	a2,14
    80003a36:	85a6                	mv	a1,s1
    80003a38:	8556                	mv	a0,s5
    80003a3a:	a60fd0ef          	jal	ra,80000c9a <memmove>
    80003a3e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a40:	0004c783          	lbu	a5,0(s1)
    80003a44:	01279763          	bne	a5,s2,80003a52 <namex+0xb6>
    path++;
    80003a48:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a4a:	0004c783          	lbu	a5,0(s1)
    80003a4e:	ff278de3          	beq	a5,s2,80003a48 <namex+0xac>
    ilock(ip);
    80003a52:	8552                	mv	a0,s4
    80003a54:	925ff0ef          	jal	ra,80003378 <ilock>
    if(ip->type != T_DIR){
    80003a58:	044a1783          	lh	a5,68(s4)
    80003a5c:	f9879ae3          	bne	a5,s8,800039f0 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003a60:	000b0563          	beqz	s6,80003a6a <namex+0xce>
    80003a64:	0004c783          	lbu	a5,0(s1)
    80003a68:	d7dd                	beqz	a5,80003a16 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a6a:	865e                	mv	a2,s7
    80003a6c:	85d6                	mv	a1,s5
    80003a6e:	8552                	mv	a0,s4
    80003a70:	e91ff0ef          	jal	ra,80003900 <dirlookup>
    80003a74:	89aa                	mv	s3,a0
    80003a76:	d545                	beqz	a0,80003a1e <namex+0x82>
    iunlockput(ip);
    80003a78:	8552                	mv	a0,s4
    80003a7a:	b05ff0ef          	jal	ra,8000357e <iunlockput>
    ip = next;
    80003a7e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a80:	0004c783          	lbu	a5,0(s1)
    80003a84:	01279763          	bne	a5,s2,80003a92 <namex+0xf6>
    path++;
    80003a88:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a8a:	0004c783          	lbu	a5,0(s1)
    80003a8e:	ff278de3          	beq	a5,s2,80003a88 <namex+0xec>
  if(*path == 0)
    80003a92:	cb8d                	beqz	a5,80003ac4 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003a94:	0004c783          	lbu	a5,0(s1)
    80003a98:	89a6                	mv	s3,s1
  len = path - s;
    80003a9a:	8d5e                	mv	s10,s7
    80003a9c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003a9e:	01278963          	beq	a5,s2,80003ab0 <namex+0x114>
    80003aa2:	d3d9                	beqz	a5,80003a28 <namex+0x8c>
    path++;
    80003aa4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003aa6:	0009c783          	lbu	a5,0(s3)
    80003aaa:	ff279ce3          	bne	a5,s2,80003aa2 <namex+0x106>
    80003aae:	bfad                	j	80003a28 <namex+0x8c>
    memmove(name, s, len);
    80003ab0:	2601                	sext.w	a2,a2
    80003ab2:	85a6                	mv	a1,s1
    80003ab4:	8556                	mv	a0,s5
    80003ab6:	9e4fd0ef          	jal	ra,80000c9a <memmove>
    name[len] = 0;
    80003aba:	9d56                	add	s10,s10,s5
    80003abc:	000d0023          	sb	zero,0(s10) # 1000 <_entry-0x7ffff000>
    80003ac0:	84ce                	mv	s1,s3
    80003ac2:	bfbd                	j	80003a40 <namex+0xa4>
  if(nameiparent){
    80003ac4:	f20b0ae3          	beqz	s6,800039f8 <namex+0x5c>
    iput(ip);
    80003ac8:	8552                	mv	a0,s4
    80003aca:	a2dff0ef          	jal	ra,800034f6 <iput>
    return 0;
    80003ace:	4a01                	li	s4,0
    80003ad0:	b725                	j	800039f8 <namex+0x5c>

0000000080003ad2 <dirlink>:
{
    80003ad2:	7139                	addi	sp,sp,-64
    80003ad4:	fc06                	sd	ra,56(sp)
    80003ad6:	f822                	sd	s0,48(sp)
    80003ad8:	f426                	sd	s1,40(sp)
    80003ada:	f04a                	sd	s2,32(sp)
    80003adc:	ec4e                	sd	s3,24(sp)
    80003ade:	e852                	sd	s4,16(sp)
    80003ae0:	0080                	addi	s0,sp,64
    80003ae2:	892a                	mv	s2,a0
    80003ae4:	8a2e                	mv	s4,a1
    80003ae6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ae8:	4601                	li	a2,0
    80003aea:	e17ff0ef          	jal	ra,80003900 <dirlookup>
    80003aee:	e52d                	bnez	a0,80003b58 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003af0:	04c92483          	lw	s1,76(s2)
    80003af4:	c48d                	beqz	s1,80003b1e <dirlink+0x4c>
    80003af6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003af8:	4741                	li	a4,16
    80003afa:	86a6                	mv	a3,s1
    80003afc:	fc040613          	addi	a2,s0,-64
    80003b00:	4581                	li	a1,0
    80003b02:	854a                	mv	a0,s2
    80003b04:	c01ff0ef          	jal	ra,80003704 <readi>
    80003b08:	47c1                	li	a5,16
    80003b0a:	04f51b63          	bne	a0,a5,80003b60 <dirlink+0x8e>
    if(de.inum == 0)
    80003b0e:	fc045783          	lhu	a5,-64(s0)
    80003b12:	c791                	beqz	a5,80003b1e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b14:	24c1                	addiw	s1,s1,16
    80003b16:	04c92783          	lw	a5,76(s2)
    80003b1a:	fcf4efe3          	bltu	s1,a5,80003af8 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b1e:	4639                	li	a2,14
    80003b20:	85d2                	mv	a1,s4
    80003b22:	fc240513          	addi	a0,s0,-62
    80003b26:	a20fd0ef          	jal	ra,80000d46 <strncpy>
  de.inum = inum;
    80003b2a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b2e:	4741                	li	a4,16
    80003b30:	86a6                	mv	a3,s1
    80003b32:	fc040613          	addi	a2,s0,-64
    80003b36:	4581                	li	a1,0
    80003b38:	854a                	mv	a0,s2
    80003b3a:	cafff0ef          	jal	ra,800037e8 <writei>
    80003b3e:	1541                	addi	a0,a0,-16
    80003b40:	00a03533          	snez	a0,a0
    80003b44:	40a00533          	neg	a0,a0
}
    80003b48:	70e2                	ld	ra,56(sp)
    80003b4a:	7442                	ld	s0,48(sp)
    80003b4c:	74a2                	ld	s1,40(sp)
    80003b4e:	7902                	ld	s2,32(sp)
    80003b50:	69e2                	ld	s3,24(sp)
    80003b52:	6a42                	ld	s4,16(sp)
    80003b54:	6121                	addi	sp,sp,64
    80003b56:	8082                	ret
    iput(ip);
    80003b58:	99fff0ef          	jal	ra,800034f6 <iput>
    return -1;
    80003b5c:	557d                	li	a0,-1
    80003b5e:	b7ed                	j	80003b48 <dirlink+0x76>
      panic("dirlink read");
    80003b60:	00004517          	auipc	a0,0x4
    80003b64:	a8850513          	addi	a0,a0,-1400 # 800075e8 <syscalls+0x1f8>
    80003b68:	c21fc0ef          	jal	ra,80000788 <panic>

0000000080003b6c <namei>:

struct inode*
namei(char *path)
{
    80003b6c:	1101                	addi	sp,sp,-32
    80003b6e:	ec06                	sd	ra,24(sp)
    80003b70:	e822                	sd	s0,16(sp)
    80003b72:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b74:	fe040613          	addi	a2,s0,-32
    80003b78:	4581                	li	a1,0
    80003b7a:	e23ff0ef          	jal	ra,8000399c <namex>
}
    80003b7e:	60e2                	ld	ra,24(sp)
    80003b80:	6442                	ld	s0,16(sp)
    80003b82:	6105                	addi	sp,sp,32
    80003b84:	8082                	ret

0000000080003b86 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b86:	1141                	addi	sp,sp,-16
    80003b88:	e406                	sd	ra,8(sp)
    80003b8a:	e022                	sd	s0,0(sp)
    80003b8c:	0800                	addi	s0,sp,16
    80003b8e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b90:	4585                	li	a1,1
    80003b92:	e0bff0ef          	jal	ra,8000399c <namex>
}
    80003b96:	60a2                	ld	ra,8(sp)
    80003b98:	6402                	ld	s0,0(sp)
    80003b9a:	0141                	addi	sp,sp,16
    80003b9c:	8082                	ret

0000000080003b9e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b9e:	1101                	addi	sp,sp,-32
    80003ba0:	ec06                	sd	ra,24(sp)
    80003ba2:	e822                	sd	s0,16(sp)
    80003ba4:	e426                	sd	s1,8(sp)
    80003ba6:	e04a                	sd	s2,0(sp)
    80003ba8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003baa:	0001c917          	auipc	s2,0x1c
    80003bae:	1ae90913          	addi	s2,s2,430 # 8001fd58 <log>
    80003bb2:	01892583          	lw	a1,24(s2)
    80003bb6:	02492503          	lw	a0,36(s2)
    80003bba:	90eff0ef          	jal	ra,80002cc8 <bread>
    80003bbe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003bc0:	02892683          	lw	a3,40(s2)
    80003bc4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003bc6:	02d05863          	blez	a3,80003bf6 <write_head+0x58>
    80003bca:	0001c797          	auipc	a5,0x1c
    80003bce:	1ba78793          	addi	a5,a5,442 # 8001fd84 <log+0x2c>
    80003bd2:	05c50713          	addi	a4,a0,92
    80003bd6:	36fd                	addiw	a3,a3,-1
    80003bd8:	02069613          	slli	a2,a3,0x20
    80003bdc:	01e65693          	srli	a3,a2,0x1e
    80003be0:	0001c617          	auipc	a2,0x1c
    80003be4:	1a860613          	addi	a2,a2,424 # 8001fd88 <log+0x30>
    80003be8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003bea:	4390                	lw	a2,0(a5)
    80003bec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bee:	0791                	addi	a5,a5,4
    80003bf0:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003bf2:	fed79ce3          	bne	a5,a3,80003bea <write_head+0x4c>
  }
  bwrite(buf);
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	9a6ff0ef          	jal	ra,80002d9e <bwrite>
  brelse(buf);
    80003bfc:	8526                	mv	a0,s1
    80003bfe:	9d2ff0ef          	jal	ra,80002dd0 <brelse>
}
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	64a2                	ld	s1,8(sp)
    80003c08:	6902                	ld	s2,0(sp)
    80003c0a:	6105                	addi	sp,sp,32
    80003c0c:	8082                	ret

0000000080003c0e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c0e:	0001c797          	auipc	a5,0x1c
    80003c12:	1727a783          	lw	a5,370(a5) # 8001fd80 <log+0x28>
    80003c16:	0af05e63          	blez	a5,80003cd2 <install_trans+0xc4>
{
    80003c1a:	715d                	addi	sp,sp,-80
    80003c1c:	e486                	sd	ra,72(sp)
    80003c1e:	e0a2                	sd	s0,64(sp)
    80003c20:	fc26                	sd	s1,56(sp)
    80003c22:	f84a                	sd	s2,48(sp)
    80003c24:	f44e                	sd	s3,40(sp)
    80003c26:	f052                	sd	s4,32(sp)
    80003c28:	ec56                	sd	s5,24(sp)
    80003c2a:	e85a                	sd	s6,16(sp)
    80003c2c:	e45e                	sd	s7,8(sp)
    80003c2e:	0880                	addi	s0,sp,80
    80003c30:	8b2a                	mv	s6,a0
    80003c32:	0001ca97          	auipc	s5,0x1c
    80003c36:	152a8a93          	addi	s5,s5,338 # 8001fd84 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c3a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c3c:	00004b97          	auipc	s7,0x4
    80003c40:	9bcb8b93          	addi	s7,s7,-1604 # 800075f8 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c44:	0001ca17          	auipc	s4,0x1c
    80003c48:	114a0a13          	addi	s4,s4,276 # 8001fd58 <log>
    80003c4c:	a025                	j	80003c74 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c4e:	000aa603          	lw	a2,0(s5)
    80003c52:	85ce                	mv	a1,s3
    80003c54:	855e                	mv	a0,s7
    80003c56:	86dfc0ef          	jal	ra,800004c2 <printf>
    80003c5a:	a839                	j	80003c78 <install_trans+0x6a>
    brelse(lbuf);
    80003c5c:	854a                	mv	a0,s2
    80003c5e:	972ff0ef          	jal	ra,80002dd0 <brelse>
    brelse(dbuf);
    80003c62:	8526                	mv	a0,s1
    80003c64:	96cff0ef          	jal	ra,80002dd0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c68:	2985                	addiw	s3,s3,1
    80003c6a:	0a91                	addi	s5,s5,4
    80003c6c:	028a2783          	lw	a5,40(s4)
    80003c70:	04f9d663          	bge	s3,a5,80003cbc <install_trans+0xae>
    if(recovering) {
    80003c74:	fc0b1de3          	bnez	s6,80003c4e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c78:	018a2583          	lw	a1,24(s4)
    80003c7c:	013585bb          	addw	a1,a1,s3
    80003c80:	2585                	addiw	a1,a1,1
    80003c82:	024a2503          	lw	a0,36(s4)
    80003c86:	842ff0ef          	jal	ra,80002cc8 <bread>
    80003c8a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c8c:	000aa583          	lw	a1,0(s5)
    80003c90:	024a2503          	lw	a0,36(s4)
    80003c94:	834ff0ef          	jal	ra,80002cc8 <bread>
    80003c98:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c9a:	40000613          	li	a2,1024
    80003c9e:	05890593          	addi	a1,s2,88
    80003ca2:	05850513          	addi	a0,a0,88
    80003ca6:	ff5fc0ef          	jal	ra,80000c9a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003caa:	8526                	mv	a0,s1
    80003cac:	8f2ff0ef          	jal	ra,80002d9e <bwrite>
    if(recovering == 0)
    80003cb0:	fa0b16e3          	bnez	s6,80003c5c <install_trans+0x4e>
      bunpin(dbuf);
    80003cb4:	8526                	mv	a0,s1
    80003cb6:	9d8ff0ef          	jal	ra,80002e8e <bunpin>
    80003cba:	b74d                	j	80003c5c <install_trans+0x4e>
}
    80003cbc:	60a6                	ld	ra,72(sp)
    80003cbe:	6406                	ld	s0,64(sp)
    80003cc0:	74e2                	ld	s1,56(sp)
    80003cc2:	7942                	ld	s2,48(sp)
    80003cc4:	79a2                	ld	s3,40(sp)
    80003cc6:	7a02                	ld	s4,32(sp)
    80003cc8:	6ae2                	ld	s5,24(sp)
    80003cca:	6b42                	ld	s6,16(sp)
    80003ccc:	6ba2                	ld	s7,8(sp)
    80003cce:	6161                	addi	sp,sp,80
    80003cd0:	8082                	ret
    80003cd2:	8082                	ret

0000000080003cd4 <initlog>:
{
    80003cd4:	7179                	addi	sp,sp,-48
    80003cd6:	f406                	sd	ra,40(sp)
    80003cd8:	f022                	sd	s0,32(sp)
    80003cda:	ec26                	sd	s1,24(sp)
    80003cdc:	e84a                	sd	s2,16(sp)
    80003cde:	e44e                	sd	s3,8(sp)
    80003ce0:	1800                	addi	s0,sp,48
    80003ce2:	892a                	mv	s2,a0
    80003ce4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ce6:	0001c497          	auipc	s1,0x1c
    80003cea:	07248493          	addi	s1,s1,114 # 8001fd58 <log>
    80003cee:	00004597          	auipc	a1,0x4
    80003cf2:	92a58593          	addi	a1,a1,-1750 # 80007618 <syscalls+0x228>
    80003cf6:	8526                	mv	a0,s1
    80003cf8:	df3fc0ef          	jal	ra,80000aea <initlock>
  log.start = sb->logstart;
    80003cfc:	0149a583          	lw	a1,20(s3)
    80003d00:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d02:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d06:	854a                	mv	a0,s2
    80003d08:	fc1fe0ef          	jal	ra,80002cc8 <bread>
  log.lh.n = lh->n;
    80003d0c:	4d34                	lw	a3,88(a0)
    80003d0e:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d10:	02d05663          	blez	a3,80003d3c <initlog+0x68>
    80003d14:	05c50793          	addi	a5,a0,92
    80003d18:	0001c717          	auipc	a4,0x1c
    80003d1c:	06c70713          	addi	a4,a4,108 # 8001fd84 <log+0x2c>
    80003d20:	36fd                	addiw	a3,a3,-1
    80003d22:	02069613          	slli	a2,a3,0x20
    80003d26:	01e65693          	srli	a3,a2,0x1e
    80003d2a:	06050613          	addi	a2,a0,96
    80003d2e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003d30:	4390                	lw	a2,0(a5)
    80003d32:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d34:	0791                	addi	a5,a5,4
    80003d36:	0711                	addi	a4,a4,4
    80003d38:	fed79ce3          	bne	a5,a3,80003d30 <initlog+0x5c>
  brelse(buf);
    80003d3c:	894ff0ef          	jal	ra,80002dd0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d40:	4505                	li	a0,1
    80003d42:	ecdff0ef          	jal	ra,80003c0e <install_trans>
  log.lh.n = 0;
    80003d46:	0001c797          	auipc	a5,0x1c
    80003d4a:	0207ad23          	sw	zero,58(a5) # 8001fd80 <log+0x28>
  write_head(); // clear the log
    80003d4e:	e51ff0ef          	jal	ra,80003b9e <write_head>
}
    80003d52:	70a2                	ld	ra,40(sp)
    80003d54:	7402                	ld	s0,32(sp)
    80003d56:	64e2                	ld	s1,24(sp)
    80003d58:	6942                	ld	s2,16(sp)
    80003d5a:	69a2                	ld	s3,8(sp)
    80003d5c:	6145                	addi	sp,sp,48
    80003d5e:	8082                	ret

0000000080003d60 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d60:	1101                	addi	sp,sp,-32
    80003d62:	ec06                	sd	ra,24(sp)
    80003d64:	e822                	sd	s0,16(sp)
    80003d66:	e426                	sd	s1,8(sp)
    80003d68:	e04a                	sd	s2,0(sp)
    80003d6a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d6c:	0001c517          	auipc	a0,0x1c
    80003d70:	fec50513          	addi	a0,a0,-20 # 8001fd58 <log>
    80003d74:	df7fc0ef          	jal	ra,80000b6a <acquire>
  while(1){
    if(log.committing){
    80003d78:	0001c497          	auipc	s1,0x1c
    80003d7c:	fe048493          	addi	s1,s1,-32 # 8001fd58 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d80:	4979                	li	s2,30
    80003d82:	a029                	j	80003d8c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d84:	85a6                	mv	a1,s1
    80003d86:	8526                	mv	a0,s1
    80003d88:	8c6fe0ef          	jal	ra,80001e4e <sleep>
    if(log.committing){
    80003d8c:	509c                	lw	a5,32(s1)
    80003d8e:	fbfd                	bnez	a5,80003d84 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d90:	4cd8                	lw	a4,28(s1)
    80003d92:	2705                	addiw	a4,a4,1
    80003d94:	0007069b          	sext.w	a3,a4
    80003d98:	0027179b          	slliw	a5,a4,0x2
    80003d9c:	9fb9                	addw	a5,a5,a4
    80003d9e:	0017979b          	slliw	a5,a5,0x1
    80003da2:	5498                	lw	a4,40(s1)
    80003da4:	9fb9                	addw	a5,a5,a4
    80003da6:	00f95763          	bge	s2,a5,80003db4 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003daa:	85a6                	mv	a1,s1
    80003dac:	8526                	mv	a0,s1
    80003dae:	8a0fe0ef          	jal	ra,80001e4e <sleep>
    80003db2:	bfe9                	j	80003d8c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003db4:	0001c517          	auipc	a0,0x1c
    80003db8:	fa450513          	addi	a0,a0,-92 # 8001fd58 <log>
    80003dbc:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003dbe:	e45fc0ef          	jal	ra,80000c02 <release>
      break;
    }
  }
}
    80003dc2:	60e2                	ld	ra,24(sp)
    80003dc4:	6442                	ld	s0,16(sp)
    80003dc6:	64a2                	ld	s1,8(sp)
    80003dc8:	6902                	ld	s2,0(sp)
    80003dca:	6105                	addi	sp,sp,32
    80003dcc:	8082                	ret

0000000080003dce <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003dce:	7139                	addi	sp,sp,-64
    80003dd0:	fc06                	sd	ra,56(sp)
    80003dd2:	f822                	sd	s0,48(sp)
    80003dd4:	f426                	sd	s1,40(sp)
    80003dd6:	f04a                	sd	s2,32(sp)
    80003dd8:	ec4e                	sd	s3,24(sp)
    80003dda:	e852                	sd	s4,16(sp)
    80003ddc:	e456                	sd	s5,8(sp)
    80003dde:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003de0:	0001c497          	auipc	s1,0x1c
    80003de4:	f7848493          	addi	s1,s1,-136 # 8001fd58 <log>
    80003de8:	8526                	mv	a0,s1
    80003dea:	d81fc0ef          	jal	ra,80000b6a <acquire>
  log.outstanding -= 1;
    80003dee:	4cdc                	lw	a5,28(s1)
    80003df0:	37fd                	addiw	a5,a5,-1
    80003df2:	0007891b          	sext.w	s2,a5
    80003df6:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003df8:	509c                	lw	a5,32(s1)
    80003dfa:	ef9d                	bnez	a5,80003e38 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003dfc:	04091463          	bnez	s2,80003e44 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e00:	0001c497          	auipc	s1,0x1c
    80003e04:	f5848493          	addi	s1,s1,-168 # 8001fd58 <log>
    80003e08:	4785                	li	a5,1
    80003e0a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e0c:	8526                	mv	a0,s1
    80003e0e:	df5fc0ef          	jal	ra,80000c02 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e12:	549c                	lw	a5,40(s1)
    80003e14:	04f04b63          	bgtz	a5,80003e6a <end_op+0x9c>
    acquire(&log.lock);
    80003e18:	0001c497          	auipc	s1,0x1c
    80003e1c:	f4048493          	addi	s1,s1,-192 # 8001fd58 <log>
    80003e20:	8526                	mv	a0,s1
    80003e22:	d49fc0ef          	jal	ra,80000b6a <acquire>
    log.committing = 0;
    80003e26:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	86efe0ef          	jal	ra,80001e9a <wakeup>
    release(&log.lock);
    80003e30:	8526                	mv	a0,s1
    80003e32:	dd1fc0ef          	jal	ra,80000c02 <release>
}
    80003e36:	a00d                	j	80003e58 <end_op+0x8a>
    panic("log.committing");
    80003e38:	00003517          	auipc	a0,0x3
    80003e3c:	7e850513          	addi	a0,a0,2024 # 80007620 <syscalls+0x230>
    80003e40:	949fc0ef          	jal	ra,80000788 <panic>
    wakeup(&log);
    80003e44:	0001c497          	auipc	s1,0x1c
    80003e48:	f1448493          	addi	s1,s1,-236 # 8001fd58 <log>
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	84cfe0ef          	jal	ra,80001e9a <wakeup>
  release(&log.lock);
    80003e52:	8526                	mv	a0,s1
    80003e54:	daffc0ef          	jal	ra,80000c02 <release>
}
    80003e58:	70e2                	ld	ra,56(sp)
    80003e5a:	7442                	ld	s0,48(sp)
    80003e5c:	74a2                	ld	s1,40(sp)
    80003e5e:	7902                	ld	s2,32(sp)
    80003e60:	69e2                	ld	s3,24(sp)
    80003e62:	6a42                	ld	s4,16(sp)
    80003e64:	6aa2                	ld	s5,8(sp)
    80003e66:	6121                	addi	sp,sp,64
    80003e68:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6a:	0001ca97          	auipc	s5,0x1c
    80003e6e:	f1aa8a93          	addi	s5,s5,-230 # 8001fd84 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e72:	0001ca17          	auipc	s4,0x1c
    80003e76:	ee6a0a13          	addi	s4,s4,-282 # 8001fd58 <log>
    80003e7a:	018a2583          	lw	a1,24(s4)
    80003e7e:	012585bb          	addw	a1,a1,s2
    80003e82:	2585                	addiw	a1,a1,1
    80003e84:	024a2503          	lw	a0,36(s4)
    80003e88:	e41fe0ef          	jal	ra,80002cc8 <bread>
    80003e8c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e8e:	000aa583          	lw	a1,0(s5)
    80003e92:	024a2503          	lw	a0,36(s4)
    80003e96:	e33fe0ef          	jal	ra,80002cc8 <bread>
    80003e9a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e9c:	40000613          	li	a2,1024
    80003ea0:	05850593          	addi	a1,a0,88
    80003ea4:	05848513          	addi	a0,s1,88
    80003ea8:	df3fc0ef          	jal	ra,80000c9a <memmove>
    bwrite(to);  // write the log
    80003eac:	8526                	mv	a0,s1
    80003eae:	ef1fe0ef          	jal	ra,80002d9e <bwrite>
    brelse(from);
    80003eb2:	854e                	mv	a0,s3
    80003eb4:	f1dfe0ef          	jal	ra,80002dd0 <brelse>
    brelse(to);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	f17fe0ef          	jal	ra,80002dd0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ebe:	2905                	addiw	s2,s2,1
    80003ec0:	0a91                	addi	s5,s5,4
    80003ec2:	028a2783          	lw	a5,40(s4)
    80003ec6:	faf94ae3          	blt	s2,a5,80003e7a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003eca:	cd5ff0ef          	jal	ra,80003b9e <write_head>
    install_trans(0); // Now install writes to home locations
    80003ece:	4501                	li	a0,0
    80003ed0:	d3fff0ef          	jal	ra,80003c0e <install_trans>
    log.lh.n = 0;
    80003ed4:	0001c797          	auipc	a5,0x1c
    80003ed8:	ea07a623          	sw	zero,-340(a5) # 8001fd80 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003edc:	cc3ff0ef          	jal	ra,80003b9e <write_head>
    80003ee0:	bf25                	j	80003e18 <end_op+0x4a>

0000000080003ee2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ee2:	1101                	addi	sp,sp,-32
    80003ee4:	ec06                	sd	ra,24(sp)
    80003ee6:	e822                	sd	s0,16(sp)
    80003ee8:	e426                	sd	s1,8(sp)
    80003eea:	e04a                	sd	s2,0(sp)
    80003eec:	1000                	addi	s0,sp,32
    80003eee:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ef0:	0001c917          	auipc	s2,0x1c
    80003ef4:	e6890913          	addi	s2,s2,-408 # 8001fd58 <log>
    80003ef8:	854a                	mv	a0,s2
    80003efa:	c71fc0ef          	jal	ra,80000b6a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003efe:	02892603          	lw	a2,40(s2)
    80003f02:	47f5                	li	a5,29
    80003f04:	04c7cc63          	blt	a5,a2,80003f5c <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f08:	0001c797          	auipc	a5,0x1c
    80003f0c:	e6c7a783          	lw	a5,-404(a5) # 8001fd74 <log+0x1c>
    80003f10:	04f05c63          	blez	a5,80003f68 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f14:	4781                	li	a5,0
    80003f16:	04c05f63          	blez	a2,80003f74 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f1a:	44cc                	lw	a1,12(s1)
    80003f1c:	0001c717          	auipc	a4,0x1c
    80003f20:	e6870713          	addi	a4,a4,-408 # 8001fd84 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f24:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f26:	4314                	lw	a3,0(a4)
    80003f28:	04b68663          	beq	a3,a1,80003f74 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f2c:	2785                	addiw	a5,a5,1
    80003f2e:	0711                	addi	a4,a4,4
    80003f30:	fef61be3          	bne	a2,a5,80003f26 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f34:	0621                	addi	a2,a2,8
    80003f36:	060a                	slli	a2,a2,0x2
    80003f38:	0001c797          	auipc	a5,0x1c
    80003f3c:	e2078793          	addi	a5,a5,-480 # 8001fd58 <log>
    80003f40:	97b2                	add	a5,a5,a2
    80003f42:	44d8                	lw	a4,12(s1)
    80003f44:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f46:	8526                	mv	a0,s1
    80003f48:	f13fe0ef          	jal	ra,80002e5a <bpin>
    log.lh.n++;
    80003f4c:	0001c717          	auipc	a4,0x1c
    80003f50:	e0c70713          	addi	a4,a4,-500 # 8001fd58 <log>
    80003f54:	571c                	lw	a5,40(a4)
    80003f56:	2785                	addiw	a5,a5,1
    80003f58:	d71c                	sw	a5,40(a4)
    80003f5a:	a80d                	j	80003f8c <log_write+0xaa>
    panic("too big a transaction");
    80003f5c:	00003517          	auipc	a0,0x3
    80003f60:	6d450513          	addi	a0,a0,1748 # 80007630 <syscalls+0x240>
    80003f64:	825fc0ef          	jal	ra,80000788 <panic>
    panic("log_write outside of trans");
    80003f68:	00003517          	auipc	a0,0x3
    80003f6c:	6e050513          	addi	a0,a0,1760 # 80007648 <syscalls+0x258>
    80003f70:	819fc0ef          	jal	ra,80000788 <panic>
  log.lh.block[i] = b->blockno;
    80003f74:	00878693          	addi	a3,a5,8
    80003f78:	068a                	slli	a3,a3,0x2
    80003f7a:	0001c717          	auipc	a4,0x1c
    80003f7e:	dde70713          	addi	a4,a4,-546 # 8001fd58 <log>
    80003f82:	9736                	add	a4,a4,a3
    80003f84:	44d4                	lw	a3,12(s1)
    80003f86:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f88:	faf60fe3          	beq	a2,a5,80003f46 <log_write+0x64>
  }
  release(&log.lock);
    80003f8c:	0001c517          	auipc	a0,0x1c
    80003f90:	dcc50513          	addi	a0,a0,-564 # 8001fd58 <log>
    80003f94:	c6ffc0ef          	jal	ra,80000c02 <release>
}
    80003f98:	60e2                	ld	ra,24(sp)
    80003f9a:	6442                	ld	s0,16(sp)
    80003f9c:	64a2                	ld	s1,8(sp)
    80003f9e:	6902                	ld	s2,0(sp)
    80003fa0:	6105                	addi	sp,sp,32
    80003fa2:	8082                	ret

0000000080003fa4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fa4:	1101                	addi	sp,sp,-32
    80003fa6:	ec06                	sd	ra,24(sp)
    80003fa8:	e822                	sd	s0,16(sp)
    80003faa:	e426                	sd	s1,8(sp)
    80003fac:	e04a                	sd	s2,0(sp)
    80003fae:	1000                	addi	s0,sp,32
    80003fb0:	84aa                	mv	s1,a0
    80003fb2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003fb4:	00003597          	auipc	a1,0x3
    80003fb8:	6b458593          	addi	a1,a1,1716 # 80007668 <syscalls+0x278>
    80003fbc:	0521                	addi	a0,a0,8
    80003fbe:	b2dfc0ef          	jal	ra,80000aea <initlock>
  lk->name = name;
    80003fc2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003fc6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fca:	0204a423          	sw	zero,40(s1)
}
    80003fce:	60e2                	ld	ra,24(sp)
    80003fd0:	6442                	ld	s0,16(sp)
    80003fd2:	64a2                	ld	s1,8(sp)
    80003fd4:	6902                	ld	s2,0(sp)
    80003fd6:	6105                	addi	sp,sp,32
    80003fd8:	8082                	ret

0000000080003fda <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fda:	1101                	addi	sp,sp,-32
    80003fdc:	ec06                	sd	ra,24(sp)
    80003fde:	e822                	sd	s0,16(sp)
    80003fe0:	e426                	sd	s1,8(sp)
    80003fe2:	e04a                	sd	s2,0(sp)
    80003fe4:	1000                	addi	s0,sp,32
    80003fe6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fe8:	00850913          	addi	s2,a0,8
    80003fec:	854a                	mv	a0,s2
    80003fee:	b7dfc0ef          	jal	ra,80000b6a <acquire>
  while (lk->locked) {
    80003ff2:	409c                	lw	a5,0(s1)
    80003ff4:	c799                	beqz	a5,80004002 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ff6:	85ca                	mv	a1,s2
    80003ff8:	8526                	mv	a0,s1
    80003ffa:	e55fd0ef          	jal	ra,80001e4e <sleep>
  while (lk->locked) {
    80003ffe:	409c                	lw	a5,0(s1)
    80004000:	fbfd                	bnez	a5,80003ff6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004002:	4785                	li	a5,1
    80004004:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004006:	ffcfd0ef          	jal	ra,80001802 <myproc>
    8000400a:	591c                	lw	a5,48(a0)
    8000400c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000400e:	854a                	mv	a0,s2
    80004010:	bf3fc0ef          	jal	ra,80000c02 <release>
}
    80004014:	60e2                	ld	ra,24(sp)
    80004016:	6442                	ld	s0,16(sp)
    80004018:	64a2                	ld	s1,8(sp)
    8000401a:	6902                	ld	s2,0(sp)
    8000401c:	6105                	addi	sp,sp,32
    8000401e:	8082                	ret

0000000080004020 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	e426                	sd	s1,8(sp)
    80004028:	e04a                	sd	s2,0(sp)
    8000402a:	1000                	addi	s0,sp,32
    8000402c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000402e:	00850913          	addi	s2,a0,8
    80004032:	854a                	mv	a0,s2
    80004034:	b37fc0ef          	jal	ra,80000b6a <acquire>
  lk->locked = 0;
    80004038:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000403c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004040:	8526                	mv	a0,s1
    80004042:	e59fd0ef          	jal	ra,80001e9a <wakeup>
  release(&lk->lk);
    80004046:	854a                	mv	a0,s2
    80004048:	bbbfc0ef          	jal	ra,80000c02 <release>
}
    8000404c:	60e2                	ld	ra,24(sp)
    8000404e:	6442                	ld	s0,16(sp)
    80004050:	64a2                	ld	s1,8(sp)
    80004052:	6902                	ld	s2,0(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004058:	7179                	addi	sp,sp,-48
    8000405a:	f406                	sd	ra,40(sp)
    8000405c:	f022                	sd	s0,32(sp)
    8000405e:	ec26                	sd	s1,24(sp)
    80004060:	e84a                	sd	s2,16(sp)
    80004062:	e44e                	sd	s3,8(sp)
    80004064:	1800                	addi	s0,sp,48
    80004066:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004068:	00850913          	addi	s2,a0,8
    8000406c:	854a                	mv	a0,s2
    8000406e:	afdfc0ef          	jal	ra,80000b6a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004072:	409c                	lw	a5,0(s1)
    80004074:	ef89                	bnez	a5,8000408e <holdingsleep+0x36>
    80004076:	4481                	li	s1,0
  release(&lk->lk);
    80004078:	854a                	mv	a0,s2
    8000407a:	b89fc0ef          	jal	ra,80000c02 <release>
  return r;
}
    8000407e:	8526                	mv	a0,s1
    80004080:	70a2                	ld	ra,40(sp)
    80004082:	7402                	ld	s0,32(sp)
    80004084:	64e2                	ld	s1,24(sp)
    80004086:	6942                	ld	s2,16(sp)
    80004088:	69a2                	ld	s3,8(sp)
    8000408a:	6145                	addi	sp,sp,48
    8000408c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000408e:	0284a983          	lw	s3,40(s1)
    80004092:	f70fd0ef          	jal	ra,80001802 <myproc>
    80004096:	5904                	lw	s1,48(a0)
    80004098:	413484b3          	sub	s1,s1,s3
    8000409c:	0014b493          	seqz	s1,s1
    800040a0:	bfe1                	j	80004078 <holdingsleep+0x20>

00000000800040a2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040a2:	1141                	addi	sp,sp,-16
    800040a4:	e406                	sd	ra,8(sp)
    800040a6:	e022                	sd	s0,0(sp)
    800040a8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040aa:	00003597          	auipc	a1,0x3
    800040ae:	5ce58593          	addi	a1,a1,1486 # 80007678 <syscalls+0x288>
    800040b2:	0001c517          	auipc	a0,0x1c
    800040b6:	dee50513          	addi	a0,a0,-530 # 8001fea0 <ftable>
    800040ba:	a31fc0ef          	jal	ra,80000aea <initlock>
}
    800040be:	60a2                	ld	ra,8(sp)
    800040c0:	6402                	ld	s0,0(sp)
    800040c2:	0141                	addi	sp,sp,16
    800040c4:	8082                	ret

00000000800040c6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800040c6:	1101                	addi	sp,sp,-32
    800040c8:	ec06                	sd	ra,24(sp)
    800040ca:	e822                	sd	s0,16(sp)
    800040cc:	e426                	sd	s1,8(sp)
    800040ce:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040d0:	0001c517          	auipc	a0,0x1c
    800040d4:	dd050513          	addi	a0,a0,-560 # 8001fea0 <ftable>
    800040d8:	a93fc0ef          	jal	ra,80000b6a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040dc:	0001c497          	auipc	s1,0x1c
    800040e0:	ddc48493          	addi	s1,s1,-548 # 8001feb8 <ftable+0x18>
    800040e4:	0001d717          	auipc	a4,0x1d
    800040e8:	d7470713          	addi	a4,a4,-652 # 80020e58 <disk>
    if(f->ref == 0){
    800040ec:	40dc                	lw	a5,4(s1)
    800040ee:	cf89                	beqz	a5,80004108 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040f0:	02848493          	addi	s1,s1,40
    800040f4:	fee49ce3          	bne	s1,a4,800040ec <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040f8:	0001c517          	auipc	a0,0x1c
    800040fc:	da850513          	addi	a0,a0,-600 # 8001fea0 <ftable>
    80004100:	b03fc0ef          	jal	ra,80000c02 <release>
  return 0;
    80004104:	4481                	li	s1,0
    80004106:	a809                	j	80004118 <filealloc+0x52>
      f->ref = 1;
    80004108:	4785                	li	a5,1
    8000410a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000410c:	0001c517          	auipc	a0,0x1c
    80004110:	d9450513          	addi	a0,a0,-620 # 8001fea0 <ftable>
    80004114:	aeffc0ef          	jal	ra,80000c02 <release>
}
    80004118:	8526                	mv	a0,s1
    8000411a:	60e2                	ld	ra,24(sp)
    8000411c:	6442                	ld	s0,16(sp)
    8000411e:	64a2                	ld	s1,8(sp)
    80004120:	6105                	addi	sp,sp,32
    80004122:	8082                	ret

0000000080004124 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004124:	1101                	addi	sp,sp,-32
    80004126:	ec06                	sd	ra,24(sp)
    80004128:	e822                	sd	s0,16(sp)
    8000412a:	e426                	sd	s1,8(sp)
    8000412c:	1000                	addi	s0,sp,32
    8000412e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004130:	0001c517          	auipc	a0,0x1c
    80004134:	d7050513          	addi	a0,a0,-656 # 8001fea0 <ftable>
    80004138:	a33fc0ef          	jal	ra,80000b6a <acquire>
  if(f->ref < 1)
    8000413c:	40dc                	lw	a5,4(s1)
    8000413e:	02f05063          	blez	a5,8000415e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004142:	2785                	addiw	a5,a5,1
    80004144:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004146:	0001c517          	auipc	a0,0x1c
    8000414a:	d5a50513          	addi	a0,a0,-678 # 8001fea0 <ftable>
    8000414e:	ab5fc0ef          	jal	ra,80000c02 <release>
  return f;
}
    80004152:	8526                	mv	a0,s1
    80004154:	60e2                	ld	ra,24(sp)
    80004156:	6442                	ld	s0,16(sp)
    80004158:	64a2                	ld	s1,8(sp)
    8000415a:	6105                	addi	sp,sp,32
    8000415c:	8082                	ret
    panic("filedup");
    8000415e:	00003517          	auipc	a0,0x3
    80004162:	52250513          	addi	a0,a0,1314 # 80007680 <syscalls+0x290>
    80004166:	e22fc0ef          	jal	ra,80000788 <panic>

000000008000416a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000416a:	7139                	addi	sp,sp,-64
    8000416c:	fc06                	sd	ra,56(sp)
    8000416e:	f822                	sd	s0,48(sp)
    80004170:	f426                	sd	s1,40(sp)
    80004172:	f04a                	sd	s2,32(sp)
    80004174:	ec4e                	sd	s3,24(sp)
    80004176:	e852                	sd	s4,16(sp)
    80004178:	e456                	sd	s5,8(sp)
    8000417a:	0080                	addi	s0,sp,64
    8000417c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000417e:	0001c517          	auipc	a0,0x1c
    80004182:	d2250513          	addi	a0,a0,-734 # 8001fea0 <ftable>
    80004186:	9e5fc0ef          	jal	ra,80000b6a <acquire>
  if(f->ref < 1)
    8000418a:	40dc                	lw	a5,4(s1)
    8000418c:	04f05963          	blez	a5,800041de <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004190:	37fd                	addiw	a5,a5,-1
    80004192:	0007871b          	sext.w	a4,a5
    80004196:	c0dc                	sw	a5,4(s1)
    80004198:	04e04963          	bgtz	a4,800041ea <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000419c:	0004a903          	lw	s2,0(s1)
    800041a0:	0094ca83          	lbu	s5,9(s1)
    800041a4:	0104ba03          	ld	s4,16(s1)
    800041a8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800041ac:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041b0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041b4:	0001c517          	auipc	a0,0x1c
    800041b8:	cec50513          	addi	a0,a0,-788 # 8001fea0 <ftable>
    800041bc:	a47fc0ef          	jal	ra,80000c02 <release>

  if(ff.type == FD_PIPE){
    800041c0:	4785                	li	a5,1
    800041c2:	04f90363          	beq	s2,a5,80004208 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800041c6:	3979                	addiw	s2,s2,-2
    800041c8:	4785                	li	a5,1
    800041ca:	0327e663          	bltu	a5,s2,800041f6 <fileclose+0x8c>
    begin_op();
    800041ce:	b93ff0ef          	jal	ra,80003d60 <begin_op>
    iput(ff.ip);
    800041d2:	854e                	mv	a0,s3
    800041d4:	b22ff0ef          	jal	ra,800034f6 <iput>
    end_op();
    800041d8:	bf7ff0ef          	jal	ra,80003dce <end_op>
    800041dc:	a829                	j	800041f6 <fileclose+0x8c>
    panic("fileclose");
    800041de:	00003517          	auipc	a0,0x3
    800041e2:	4aa50513          	addi	a0,a0,1194 # 80007688 <syscalls+0x298>
    800041e6:	da2fc0ef          	jal	ra,80000788 <panic>
    release(&ftable.lock);
    800041ea:	0001c517          	auipc	a0,0x1c
    800041ee:	cb650513          	addi	a0,a0,-842 # 8001fea0 <ftable>
    800041f2:	a11fc0ef          	jal	ra,80000c02 <release>
  }
}
    800041f6:	70e2                	ld	ra,56(sp)
    800041f8:	7442                	ld	s0,48(sp)
    800041fa:	74a2                	ld	s1,40(sp)
    800041fc:	7902                	ld	s2,32(sp)
    800041fe:	69e2                	ld	s3,24(sp)
    80004200:	6a42                	ld	s4,16(sp)
    80004202:	6aa2                	ld	s5,8(sp)
    80004204:	6121                	addi	sp,sp,64
    80004206:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004208:	85d6                	mv	a1,s5
    8000420a:	8552                	mv	a0,s4
    8000420c:	2ec000ef          	jal	ra,800044f8 <pipeclose>
    80004210:	b7dd                	j	800041f6 <fileclose+0x8c>

0000000080004212 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004212:	715d                	addi	sp,sp,-80
    80004214:	e486                	sd	ra,72(sp)
    80004216:	e0a2                	sd	s0,64(sp)
    80004218:	fc26                	sd	s1,56(sp)
    8000421a:	f84a                	sd	s2,48(sp)
    8000421c:	f44e                	sd	s3,40(sp)
    8000421e:	0880                	addi	s0,sp,80
    80004220:	84aa                	mv	s1,a0
    80004222:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004224:	ddefd0ef          	jal	ra,80001802 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004228:	409c                	lw	a5,0(s1)
    8000422a:	37f9                	addiw	a5,a5,-2
    8000422c:	4705                	li	a4,1
    8000422e:	02f76f63          	bltu	a4,a5,8000426c <filestat+0x5a>
    80004232:	892a                	mv	s2,a0
    ilock(f->ip);
    80004234:	6c88                	ld	a0,24(s1)
    80004236:	942ff0ef          	jal	ra,80003378 <ilock>
    stati(f->ip, &st);
    8000423a:	fb840593          	addi	a1,s0,-72
    8000423e:	6c88                	ld	a0,24(s1)
    80004240:	c9aff0ef          	jal	ra,800036da <stati>
    iunlock(f->ip);
    80004244:	6c88                	ld	a0,24(s1)
    80004246:	9dcff0ef          	jal	ra,80003422 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000424a:	46e1                	li	a3,24
    8000424c:	fb840613          	addi	a2,s0,-72
    80004250:	85ce                	mv	a1,s3
    80004252:	05093503          	ld	a0,80(s2)
    80004256:	afafd0ef          	jal	ra,80001550 <copyout>
    8000425a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000425e:	60a6                	ld	ra,72(sp)
    80004260:	6406                	ld	s0,64(sp)
    80004262:	74e2                	ld	s1,56(sp)
    80004264:	7942                	ld	s2,48(sp)
    80004266:	79a2                	ld	s3,40(sp)
    80004268:	6161                	addi	sp,sp,80
    8000426a:	8082                	ret
  return -1;
    8000426c:	557d                	li	a0,-1
    8000426e:	bfc5                	j	8000425e <filestat+0x4c>

0000000080004270 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004270:	7179                	addi	sp,sp,-48
    80004272:	f406                	sd	ra,40(sp)
    80004274:	f022                	sd	s0,32(sp)
    80004276:	ec26                	sd	s1,24(sp)
    80004278:	e84a                	sd	s2,16(sp)
    8000427a:	e44e                	sd	s3,8(sp)
    8000427c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000427e:	00854783          	lbu	a5,8(a0)
    80004282:	cbc1                	beqz	a5,80004312 <fileread+0xa2>
    80004284:	84aa                	mv	s1,a0
    80004286:	89ae                	mv	s3,a1
    80004288:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000428a:	411c                	lw	a5,0(a0)
    8000428c:	4705                	li	a4,1
    8000428e:	04e78363          	beq	a5,a4,800042d4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004292:	470d                	li	a4,3
    80004294:	04e78563          	beq	a5,a4,800042de <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004298:	4709                	li	a4,2
    8000429a:	06e79663          	bne	a5,a4,80004306 <fileread+0x96>
    ilock(f->ip);
    8000429e:	6d08                	ld	a0,24(a0)
    800042a0:	8d8ff0ef          	jal	ra,80003378 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042a4:	874a                	mv	a4,s2
    800042a6:	5094                	lw	a3,32(s1)
    800042a8:	864e                	mv	a2,s3
    800042aa:	4585                	li	a1,1
    800042ac:	6c88                	ld	a0,24(s1)
    800042ae:	c56ff0ef          	jal	ra,80003704 <readi>
    800042b2:	892a                	mv	s2,a0
    800042b4:	00a05563          	blez	a0,800042be <fileread+0x4e>
      f->off += r;
    800042b8:	509c                	lw	a5,32(s1)
    800042ba:	9fa9                	addw	a5,a5,a0
    800042bc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042be:	6c88                	ld	a0,24(s1)
    800042c0:	962ff0ef          	jal	ra,80003422 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800042c4:	854a                	mv	a0,s2
    800042c6:	70a2                	ld	ra,40(sp)
    800042c8:	7402                	ld	s0,32(sp)
    800042ca:	64e2                	ld	s1,24(sp)
    800042cc:	6942                	ld	s2,16(sp)
    800042ce:	69a2                	ld	s3,8(sp)
    800042d0:	6145                	addi	sp,sp,48
    800042d2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042d4:	6908                	ld	a0,16(a0)
    800042d6:	34e000ef          	jal	ra,80004624 <piperead>
    800042da:	892a                	mv	s2,a0
    800042dc:	b7e5                	j	800042c4 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042de:	02451783          	lh	a5,36(a0)
    800042e2:	03079693          	slli	a3,a5,0x30
    800042e6:	92c1                	srli	a3,a3,0x30
    800042e8:	4725                	li	a4,9
    800042ea:	02d76663          	bltu	a4,a3,80004316 <fileread+0xa6>
    800042ee:	0792                	slli	a5,a5,0x4
    800042f0:	0001c717          	auipc	a4,0x1c
    800042f4:	b1070713          	addi	a4,a4,-1264 # 8001fe00 <devsw>
    800042f8:	97ba                	add	a5,a5,a4
    800042fa:	639c                	ld	a5,0(a5)
    800042fc:	cf99                	beqz	a5,8000431a <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800042fe:	4505                	li	a0,1
    80004300:	9782                	jalr	a5
    80004302:	892a                	mv	s2,a0
    80004304:	b7c1                	j	800042c4 <fileread+0x54>
    panic("fileread");
    80004306:	00003517          	auipc	a0,0x3
    8000430a:	39250513          	addi	a0,a0,914 # 80007698 <syscalls+0x2a8>
    8000430e:	c7afc0ef          	jal	ra,80000788 <panic>
    return -1;
    80004312:	597d                	li	s2,-1
    80004314:	bf45                	j	800042c4 <fileread+0x54>
      return -1;
    80004316:	597d                	li	s2,-1
    80004318:	b775                	j	800042c4 <fileread+0x54>
    8000431a:	597d                	li	s2,-1
    8000431c:	b765                	j	800042c4 <fileread+0x54>

000000008000431e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000431e:	715d                	addi	sp,sp,-80
    80004320:	e486                	sd	ra,72(sp)
    80004322:	e0a2                	sd	s0,64(sp)
    80004324:	fc26                	sd	s1,56(sp)
    80004326:	f84a                	sd	s2,48(sp)
    80004328:	f44e                	sd	s3,40(sp)
    8000432a:	f052                	sd	s4,32(sp)
    8000432c:	ec56                	sd	s5,24(sp)
    8000432e:	e85a                	sd	s6,16(sp)
    80004330:	e45e                	sd	s7,8(sp)
    80004332:	e062                	sd	s8,0(sp)
    80004334:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004336:	00954783          	lbu	a5,9(a0)
    8000433a:	0e078863          	beqz	a5,8000442a <filewrite+0x10c>
    8000433e:	892a                	mv	s2,a0
    80004340:	8b2e                	mv	s6,a1
    80004342:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004344:	411c                	lw	a5,0(a0)
    80004346:	4705                	li	a4,1
    80004348:	02e78263          	beq	a5,a4,8000436c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000434c:	470d                	li	a4,3
    8000434e:	02e78463          	beq	a5,a4,80004376 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004352:	4709                	li	a4,2
    80004354:	0ce79563          	bne	a5,a4,8000441e <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004358:	0ac05163          	blez	a2,800043fa <filewrite+0xdc>
    int i = 0;
    8000435c:	4981                	li	s3,0
    8000435e:	6b85                	lui	s7,0x1
    80004360:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004364:	6c05                	lui	s8,0x1
    80004366:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000436a:	a041                	j	800043ea <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    8000436c:	6908                	ld	a0,16(a0)
    8000436e:	1e2000ef          	jal	ra,80004550 <pipewrite>
    80004372:	8a2a                	mv	s4,a0
    80004374:	a071                	j	80004400 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004376:	02451783          	lh	a5,36(a0)
    8000437a:	03079693          	slli	a3,a5,0x30
    8000437e:	92c1                	srli	a3,a3,0x30
    80004380:	4725                	li	a4,9
    80004382:	0ad76663          	bltu	a4,a3,8000442e <filewrite+0x110>
    80004386:	0792                	slli	a5,a5,0x4
    80004388:	0001c717          	auipc	a4,0x1c
    8000438c:	a7870713          	addi	a4,a4,-1416 # 8001fe00 <devsw>
    80004390:	97ba                	add	a5,a5,a4
    80004392:	679c                	ld	a5,8(a5)
    80004394:	cfd9                	beqz	a5,80004432 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004396:	4505                	li	a0,1
    80004398:	9782                	jalr	a5
    8000439a:	8a2a                	mv	s4,a0
    8000439c:	a095                	j	80004400 <filewrite+0xe2>
    8000439e:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800043a2:	9bfff0ef          	jal	ra,80003d60 <begin_op>
      ilock(f->ip);
    800043a6:	01893503          	ld	a0,24(s2)
    800043aa:	fcffe0ef          	jal	ra,80003378 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043ae:	8756                	mv	a4,s5
    800043b0:	02092683          	lw	a3,32(s2)
    800043b4:	01698633          	add	a2,s3,s6
    800043b8:	4585                	li	a1,1
    800043ba:	01893503          	ld	a0,24(s2)
    800043be:	c2aff0ef          	jal	ra,800037e8 <writei>
    800043c2:	84aa                	mv	s1,a0
    800043c4:	00a05763          	blez	a0,800043d2 <filewrite+0xb4>
        f->off += r;
    800043c8:	02092783          	lw	a5,32(s2)
    800043cc:	9fa9                	addw	a5,a5,a0
    800043ce:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043d2:	01893503          	ld	a0,24(s2)
    800043d6:	84cff0ef          	jal	ra,80003422 <iunlock>
      end_op();
    800043da:	9f5ff0ef          	jal	ra,80003dce <end_op>

      if(r != n1){
    800043de:	009a9f63          	bne	s5,s1,800043fc <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800043e2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043e6:	0149db63          	bge	s3,s4,800043fc <filewrite+0xde>
      int n1 = n - i;
    800043ea:	413a04bb          	subw	s1,s4,s3
    800043ee:	0004879b          	sext.w	a5,s1
    800043f2:	fafbd6e3          	bge	s7,a5,8000439e <filewrite+0x80>
    800043f6:	84e2                	mv	s1,s8
    800043f8:	b75d                	j	8000439e <filewrite+0x80>
    int i = 0;
    800043fa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800043fc:	013a1f63          	bne	s4,s3,8000441a <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004400:	8552                	mv	a0,s4
    80004402:	60a6                	ld	ra,72(sp)
    80004404:	6406                	ld	s0,64(sp)
    80004406:	74e2                	ld	s1,56(sp)
    80004408:	7942                	ld	s2,48(sp)
    8000440a:	79a2                	ld	s3,40(sp)
    8000440c:	7a02                	ld	s4,32(sp)
    8000440e:	6ae2                	ld	s5,24(sp)
    80004410:	6b42                	ld	s6,16(sp)
    80004412:	6ba2                	ld	s7,8(sp)
    80004414:	6c02                	ld	s8,0(sp)
    80004416:	6161                	addi	sp,sp,80
    80004418:	8082                	ret
    ret = (i == n ? n : -1);
    8000441a:	5a7d                	li	s4,-1
    8000441c:	b7d5                	j	80004400 <filewrite+0xe2>
    panic("filewrite");
    8000441e:	00003517          	auipc	a0,0x3
    80004422:	28a50513          	addi	a0,a0,650 # 800076a8 <syscalls+0x2b8>
    80004426:	b62fc0ef          	jal	ra,80000788 <panic>
    return -1;
    8000442a:	5a7d                	li	s4,-1
    8000442c:	bfd1                	j	80004400 <filewrite+0xe2>
      return -1;
    8000442e:	5a7d                	li	s4,-1
    80004430:	bfc1                	j	80004400 <filewrite+0xe2>
    80004432:	5a7d                	li	s4,-1
    80004434:	b7f1                	j	80004400 <filewrite+0xe2>

0000000080004436 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004436:	7179                	addi	sp,sp,-48
    80004438:	f406                	sd	ra,40(sp)
    8000443a:	f022                	sd	s0,32(sp)
    8000443c:	ec26                	sd	s1,24(sp)
    8000443e:	e84a                	sd	s2,16(sp)
    80004440:	e44e                	sd	s3,8(sp)
    80004442:	e052                	sd	s4,0(sp)
    80004444:	1800                	addi	s0,sp,48
    80004446:	84aa                	mv	s1,a0
    80004448:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000444a:	0005b023          	sd	zero,0(a1)
    8000444e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004452:	c75ff0ef          	jal	ra,800040c6 <filealloc>
    80004456:	e088                	sd	a0,0(s1)
    80004458:	cd35                	beqz	a0,800044d4 <pipealloc+0x9e>
    8000445a:	c6dff0ef          	jal	ra,800040c6 <filealloc>
    8000445e:	00aa3023          	sd	a0,0(s4)
    80004462:	c52d                	beqz	a0,800044cc <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004464:	e36fc0ef          	jal	ra,80000a9a <kalloc>
    80004468:	892a                	mv	s2,a0
    8000446a:	cd31                	beqz	a0,800044c6 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    8000446c:	4985                	li	s3,1
    8000446e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004472:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004476:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000447a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000447e:	00003597          	auipc	a1,0x3
    80004482:	23a58593          	addi	a1,a1,570 # 800076b8 <syscalls+0x2c8>
    80004486:	e64fc0ef          	jal	ra,80000aea <initlock>
  (*f0)->type = FD_PIPE;
    8000448a:	609c                	ld	a5,0(s1)
    8000448c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004490:	609c                	ld	a5,0(s1)
    80004492:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004496:	609c                	ld	a5,0(s1)
    80004498:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000449c:	609c                	ld	a5,0(s1)
    8000449e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044a2:	000a3783          	ld	a5,0(s4)
    800044a6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800044aa:	000a3783          	ld	a5,0(s4)
    800044ae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800044b2:	000a3783          	ld	a5,0(s4)
    800044b6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800044ba:	000a3783          	ld	a5,0(s4)
    800044be:	0127b823          	sd	s2,16(a5)
  return 0;
    800044c2:	4501                	li	a0,0
    800044c4:	a005                	j	800044e4 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800044c6:	6088                	ld	a0,0(s1)
    800044c8:	e501                	bnez	a0,800044d0 <pipealloc+0x9a>
    800044ca:	a029                	j	800044d4 <pipealloc+0x9e>
    800044cc:	6088                	ld	a0,0(s1)
    800044ce:	c11d                	beqz	a0,800044f4 <pipealloc+0xbe>
    fileclose(*f0);
    800044d0:	c9bff0ef          	jal	ra,8000416a <fileclose>
  if(*f1)
    800044d4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044d8:	557d                	li	a0,-1
  if(*f1)
    800044da:	c789                	beqz	a5,800044e4 <pipealloc+0xae>
    fileclose(*f1);
    800044dc:	853e                	mv	a0,a5
    800044de:	c8dff0ef          	jal	ra,8000416a <fileclose>
  return -1;
    800044e2:	557d                	li	a0,-1
}
    800044e4:	70a2                	ld	ra,40(sp)
    800044e6:	7402                	ld	s0,32(sp)
    800044e8:	64e2                	ld	s1,24(sp)
    800044ea:	6942                	ld	s2,16(sp)
    800044ec:	69a2                	ld	s3,8(sp)
    800044ee:	6a02                	ld	s4,0(sp)
    800044f0:	6145                	addi	sp,sp,48
    800044f2:	8082                	ret
  return -1;
    800044f4:	557d                	li	a0,-1
    800044f6:	b7fd                	j	800044e4 <pipealloc+0xae>

00000000800044f8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044f8:	1101                	addi	sp,sp,-32
    800044fa:	ec06                	sd	ra,24(sp)
    800044fc:	e822                	sd	s0,16(sp)
    800044fe:	e426                	sd	s1,8(sp)
    80004500:	e04a                	sd	s2,0(sp)
    80004502:	1000                	addi	s0,sp,32
    80004504:	84aa                	mv	s1,a0
    80004506:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004508:	e62fc0ef          	jal	ra,80000b6a <acquire>
  if(writable){
    8000450c:	02090763          	beqz	s2,8000453a <pipeclose+0x42>
    pi->writeopen = 0;
    80004510:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004514:	21848513          	addi	a0,s1,536
    80004518:	983fd0ef          	jal	ra,80001e9a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000451c:	2204b783          	ld	a5,544(s1)
    80004520:	e785                	bnez	a5,80004548 <pipeclose+0x50>
    release(&pi->lock);
    80004522:	8526                	mv	a0,s1
    80004524:	edefc0ef          	jal	ra,80000c02 <release>
    kfree((char*)pi);
    80004528:	8526                	mv	a0,s1
    8000452a:	c8efc0ef          	jal	ra,800009b8 <kfree>
  } else
    release(&pi->lock);
}
    8000452e:	60e2                	ld	ra,24(sp)
    80004530:	6442                	ld	s0,16(sp)
    80004532:	64a2                	ld	s1,8(sp)
    80004534:	6902                	ld	s2,0(sp)
    80004536:	6105                	addi	sp,sp,32
    80004538:	8082                	ret
    pi->readopen = 0;
    8000453a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000453e:	21c48513          	addi	a0,s1,540
    80004542:	959fd0ef          	jal	ra,80001e9a <wakeup>
    80004546:	bfd9                	j	8000451c <pipeclose+0x24>
    release(&pi->lock);
    80004548:	8526                	mv	a0,s1
    8000454a:	eb8fc0ef          	jal	ra,80000c02 <release>
}
    8000454e:	b7c5                	j	8000452e <pipeclose+0x36>

0000000080004550 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004550:	711d                	addi	sp,sp,-96
    80004552:	ec86                	sd	ra,88(sp)
    80004554:	e8a2                	sd	s0,80(sp)
    80004556:	e4a6                	sd	s1,72(sp)
    80004558:	e0ca                	sd	s2,64(sp)
    8000455a:	fc4e                	sd	s3,56(sp)
    8000455c:	f852                	sd	s4,48(sp)
    8000455e:	f456                	sd	s5,40(sp)
    80004560:	f05a                	sd	s6,32(sp)
    80004562:	ec5e                	sd	s7,24(sp)
    80004564:	e862                	sd	s8,16(sp)
    80004566:	1080                	addi	s0,sp,96
    80004568:	84aa                	mv	s1,a0
    8000456a:	8aae                	mv	s5,a1
    8000456c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000456e:	a94fd0ef          	jal	ra,80001802 <myproc>
    80004572:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004574:	8526                	mv	a0,s1
    80004576:	df4fc0ef          	jal	ra,80000b6a <acquire>
  while(i < n){
    8000457a:	09405c63          	blez	s4,80004612 <pipewrite+0xc2>
  int i = 0;
    8000457e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004580:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004582:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004586:	21c48b93          	addi	s7,s1,540
    8000458a:	a81d                	j	800045c0 <pipewrite+0x70>
      release(&pi->lock);
    8000458c:	8526                	mv	a0,s1
    8000458e:	e74fc0ef          	jal	ra,80000c02 <release>
      return -1;
    80004592:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004594:	854a                	mv	a0,s2
    80004596:	60e6                	ld	ra,88(sp)
    80004598:	6446                	ld	s0,80(sp)
    8000459a:	64a6                	ld	s1,72(sp)
    8000459c:	6906                	ld	s2,64(sp)
    8000459e:	79e2                	ld	s3,56(sp)
    800045a0:	7a42                	ld	s4,48(sp)
    800045a2:	7aa2                	ld	s5,40(sp)
    800045a4:	7b02                	ld	s6,32(sp)
    800045a6:	6be2                	ld	s7,24(sp)
    800045a8:	6c42                	ld	s8,16(sp)
    800045aa:	6125                	addi	sp,sp,96
    800045ac:	8082                	ret
      wakeup(&pi->nread);
    800045ae:	8562                	mv	a0,s8
    800045b0:	8ebfd0ef          	jal	ra,80001e9a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800045b4:	85a6                	mv	a1,s1
    800045b6:	855e                	mv	a0,s7
    800045b8:	897fd0ef          	jal	ra,80001e4e <sleep>
  while(i < n){
    800045bc:	05495c63          	bge	s2,s4,80004614 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800045c0:	2204a783          	lw	a5,544(s1)
    800045c4:	d7e1                	beqz	a5,8000458c <pipewrite+0x3c>
    800045c6:	854e                	mv	a0,s3
    800045c8:	abffd0ef          	jal	ra,80002086 <killed>
    800045cc:	f161                	bnez	a0,8000458c <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800045ce:	2184a783          	lw	a5,536(s1)
    800045d2:	21c4a703          	lw	a4,540(s1)
    800045d6:	2007879b          	addiw	a5,a5,512
    800045da:	fcf70ae3          	beq	a4,a5,800045ae <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045de:	4685                	li	a3,1
    800045e0:	01590633          	add	a2,s2,s5
    800045e4:	faf40593          	addi	a1,s0,-81
    800045e8:	0509b503          	ld	a0,80(s3)
    800045ec:	82afd0ef          	jal	ra,80001616 <copyin>
    800045f0:	03650263          	beq	a0,s6,80004614 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045f4:	21c4a783          	lw	a5,540(s1)
    800045f8:	0017871b          	addiw	a4,a5,1
    800045fc:	20e4ae23          	sw	a4,540(s1)
    80004600:	1ff7f793          	andi	a5,a5,511
    80004604:	97a6                	add	a5,a5,s1
    80004606:	faf44703          	lbu	a4,-81(s0)
    8000460a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000460e:	2905                	addiw	s2,s2,1
    80004610:	b775                	j	800045bc <pipewrite+0x6c>
  int i = 0;
    80004612:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004614:	21848513          	addi	a0,s1,536
    80004618:	883fd0ef          	jal	ra,80001e9a <wakeup>
  release(&pi->lock);
    8000461c:	8526                	mv	a0,s1
    8000461e:	de4fc0ef          	jal	ra,80000c02 <release>
  return i;
    80004622:	bf8d                	j	80004594 <pipewrite+0x44>

0000000080004624 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004624:	715d                	addi	sp,sp,-80
    80004626:	e486                	sd	ra,72(sp)
    80004628:	e0a2                	sd	s0,64(sp)
    8000462a:	fc26                	sd	s1,56(sp)
    8000462c:	f84a                	sd	s2,48(sp)
    8000462e:	f44e                	sd	s3,40(sp)
    80004630:	f052                	sd	s4,32(sp)
    80004632:	ec56                	sd	s5,24(sp)
    80004634:	e85a                	sd	s6,16(sp)
    80004636:	0880                	addi	s0,sp,80
    80004638:	84aa                	mv	s1,a0
    8000463a:	892e                	mv	s2,a1
    8000463c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000463e:	9c4fd0ef          	jal	ra,80001802 <myproc>
    80004642:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004644:	8526                	mv	a0,s1
    80004646:	d24fc0ef          	jal	ra,80000b6a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000464a:	2184a703          	lw	a4,536(s1)
    8000464e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004652:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004656:	02f71363          	bne	a4,a5,8000467c <piperead+0x58>
    8000465a:	2244a783          	lw	a5,548(s1)
    8000465e:	cf99                	beqz	a5,8000467c <piperead+0x58>
    if(killed(pr)){
    80004660:	8552                	mv	a0,s4
    80004662:	a25fd0ef          	jal	ra,80002086 <killed>
    80004666:	e151                	bnez	a0,800046ea <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004668:	85a6                	mv	a1,s1
    8000466a:	854e                	mv	a0,s3
    8000466c:	fe2fd0ef          	jal	ra,80001e4e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004670:	2184a703          	lw	a4,536(s1)
    80004674:	21c4a783          	lw	a5,540(s1)
    80004678:	fef701e3          	beq	a4,a5,8000465a <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000467c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000467e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004680:	05505363          	blez	s5,800046c6 <piperead+0xa2>
    if(pi->nread == pi->nwrite)
    80004684:	2184a783          	lw	a5,536(s1)
    80004688:	21c4a703          	lw	a4,540(s1)
    8000468c:	02f70d63          	beq	a4,a5,800046c6 <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004690:	1ff7f793          	andi	a5,a5,511
    80004694:	97a6                	add	a5,a5,s1
    80004696:	0187c783          	lbu	a5,24(a5)
    8000469a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000469e:	4685                	li	a3,1
    800046a0:	fbf40613          	addi	a2,s0,-65
    800046a4:	85ca                	mv	a1,s2
    800046a6:	050a3503          	ld	a0,80(s4)
    800046aa:	ea7fc0ef          	jal	ra,80001550 <copyout>
    800046ae:	05650363          	beq	a0,s6,800046f4 <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046b2:	2184a783          	lw	a5,536(s1)
    800046b6:	2785                	addiw	a5,a5,1
    800046b8:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046bc:	2985                	addiw	s3,s3,1
    800046be:	0905                	addi	s2,s2,1
    800046c0:	fd3a92e3          	bne	s5,s3,80004684 <piperead+0x60>
    800046c4:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046c6:	21c48513          	addi	a0,s1,540
    800046ca:	fd0fd0ef          	jal	ra,80001e9a <wakeup>
  release(&pi->lock);
    800046ce:	8526                	mv	a0,s1
    800046d0:	d32fc0ef          	jal	ra,80000c02 <release>
  return i;
}
    800046d4:	854e                	mv	a0,s3
    800046d6:	60a6                	ld	ra,72(sp)
    800046d8:	6406                	ld	s0,64(sp)
    800046da:	74e2                	ld	s1,56(sp)
    800046dc:	7942                	ld	s2,48(sp)
    800046de:	79a2                	ld	s3,40(sp)
    800046e0:	7a02                	ld	s4,32(sp)
    800046e2:	6ae2                	ld	s5,24(sp)
    800046e4:	6b42                	ld	s6,16(sp)
    800046e6:	6161                	addi	sp,sp,80
    800046e8:	8082                	ret
      release(&pi->lock);
    800046ea:	8526                	mv	a0,s1
    800046ec:	d16fc0ef          	jal	ra,80000c02 <release>
      return -1;
    800046f0:	59fd                	li	s3,-1
    800046f2:	b7cd                	j	800046d4 <piperead+0xb0>
      if(i == 0)
    800046f4:	fc0999e3          	bnez	s3,800046c6 <piperead+0xa2>
        i = -1;
    800046f8:	89aa                	mv	s3,a0
    800046fa:	b7f1                	j	800046c6 <piperead+0xa2>

00000000800046fc <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046fc:	1141                	addi	sp,sp,-16
    800046fe:	e422                	sd	s0,8(sp)
    80004700:	0800                	addi	s0,sp,16
    80004702:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004704:	8905                	andi	a0,a0,1
    80004706:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004708:	8b89                	andi	a5,a5,2
    8000470a:	c399                	beqz	a5,80004710 <flags2perm+0x14>
      perm |= PTE_W;
    8000470c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004710:	6422                	ld	s0,8(sp)
    80004712:	0141                	addi	sp,sp,16
    80004714:	8082                	ret

0000000080004716 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004716:	de010113          	addi	sp,sp,-544
    8000471a:	20113c23          	sd	ra,536(sp)
    8000471e:	20813823          	sd	s0,528(sp)
    80004722:	20913423          	sd	s1,520(sp)
    80004726:	21213023          	sd	s2,512(sp)
    8000472a:	ffce                	sd	s3,504(sp)
    8000472c:	fbd2                	sd	s4,496(sp)
    8000472e:	f7d6                	sd	s5,488(sp)
    80004730:	f3da                	sd	s6,480(sp)
    80004732:	efde                	sd	s7,472(sp)
    80004734:	ebe2                	sd	s8,464(sp)
    80004736:	e7e6                	sd	s9,456(sp)
    80004738:	e3ea                	sd	s10,448(sp)
    8000473a:	ff6e                	sd	s11,440(sp)
    8000473c:	1400                	addi	s0,sp,544
    8000473e:	892a                	mv	s2,a0
    80004740:	dea43423          	sd	a0,-536(s0)
    80004744:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004748:	8bafd0ef          	jal	ra,80001802 <myproc>
    8000474c:	84aa                	mv	s1,a0

  begin_op();
    8000474e:	e12ff0ef          	jal	ra,80003d60 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004752:	854a                	mv	a0,s2
    80004754:	c18ff0ef          	jal	ra,80003b6c <namei>
    80004758:	c13d                	beqz	a0,800047be <kexec+0xa8>
    8000475a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000475c:	c1dfe0ef          	jal	ra,80003378 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004760:	04000713          	li	a4,64
    80004764:	4681                	li	a3,0
    80004766:	e5040613          	addi	a2,s0,-432
    8000476a:	4581                	li	a1,0
    8000476c:	8556                	mv	a0,s5
    8000476e:	f97fe0ef          	jal	ra,80003704 <readi>
    80004772:	04000793          	li	a5,64
    80004776:	00f51a63          	bne	a0,a5,8000478a <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000477a:	e5042703          	lw	a4,-432(s0)
    8000477e:	464c47b7          	lui	a5,0x464c4
    80004782:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004786:	04f70063          	beq	a4,a5,800047c6 <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000478a:	8556                	mv	a0,s5
    8000478c:	df3fe0ef          	jal	ra,8000357e <iunlockput>
    end_op();
    80004790:	e3eff0ef          	jal	ra,80003dce <end_op>
  }
  return -1;
    80004794:	557d                	li	a0,-1
}
    80004796:	21813083          	ld	ra,536(sp)
    8000479a:	21013403          	ld	s0,528(sp)
    8000479e:	20813483          	ld	s1,520(sp)
    800047a2:	20013903          	ld	s2,512(sp)
    800047a6:	79fe                	ld	s3,504(sp)
    800047a8:	7a5e                	ld	s4,496(sp)
    800047aa:	7abe                	ld	s5,488(sp)
    800047ac:	7b1e                	ld	s6,480(sp)
    800047ae:	6bfe                	ld	s7,472(sp)
    800047b0:	6c5e                	ld	s8,464(sp)
    800047b2:	6cbe                	ld	s9,456(sp)
    800047b4:	6d1e                	ld	s10,448(sp)
    800047b6:	7dfa                	ld	s11,440(sp)
    800047b8:	22010113          	addi	sp,sp,544
    800047bc:	8082                	ret
    end_op();
    800047be:	e10ff0ef          	jal	ra,80003dce <end_op>
    return -1;
    800047c2:	557d                	li	a0,-1
    800047c4:	bfc9                	j	80004796 <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    800047c6:	8526                	mv	a0,s1
    800047c8:	940fd0ef          	jal	ra,80001908 <proc_pagetable>
    800047cc:	8b2a                	mv	s6,a0
    800047ce:	dd55                	beqz	a0,8000478a <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047d0:	e7042783          	lw	a5,-400(s0)
    800047d4:	e8845703          	lhu	a4,-376(s0)
    800047d8:	c325                	beqz	a4,80004838 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047da:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047dc:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800047e0:	6a05                	lui	s4,0x1
    800047e2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800047e6:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800047ea:	6d85                	lui	s11,0x1
    800047ec:	7d7d                	lui	s10,0xfffff
    800047ee:	a409                	j	800049f0 <kexec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800047f0:	00003517          	auipc	a0,0x3
    800047f4:	ed050513          	addi	a0,a0,-304 # 800076c0 <syscalls+0x2d0>
    800047f8:	f91fb0ef          	jal	ra,80000788 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047fc:	874a                	mv	a4,s2
    800047fe:	009c86bb          	addw	a3,s9,s1
    80004802:	4581                	li	a1,0
    80004804:	8556                	mv	a0,s5
    80004806:	efffe0ef          	jal	ra,80003704 <readi>
    8000480a:	2501                	sext.w	a0,a0
    8000480c:	18a91163          	bne	s2,a0,8000498e <kexec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80004810:	009d84bb          	addw	s1,s11,s1
    80004814:	013d09bb          	addw	s3,s10,s3
    80004818:	1b74fc63          	bgeu	s1,s7,800049d0 <kexec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    8000481c:	02049593          	slli	a1,s1,0x20
    80004820:	9181                	srli	a1,a1,0x20
    80004822:	95e2                	add	a1,a1,s8
    80004824:	855a                	mv	a0,s6
    80004826:	f2efc0ef          	jal	ra,80000f54 <walkaddr>
    8000482a:	862a                	mv	a2,a0
    if(pa == 0)
    8000482c:	d171                	beqz	a0,800047f0 <kexec+0xda>
      n = PGSIZE;
    8000482e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004830:	fd49f6e3          	bgeu	s3,s4,800047fc <kexec+0xe6>
      n = sz - i;
    80004834:	894e                	mv	s2,s3
    80004836:	b7d9                	j	800047fc <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004838:	4901                	li	s2,0
  iunlockput(ip);
    8000483a:	8556                	mv	a0,s5
    8000483c:	d43fe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    80004840:	d8eff0ef          	jal	ra,80003dce <end_op>
  p = myproc();
    80004844:	fbffc0ef          	jal	ra,80001802 <myproc>
    80004848:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000484a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000484e:	6785                	lui	a5,0x1
    80004850:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004852:	97ca                	add	a5,a5,s2
    80004854:	777d                	lui	a4,0xfffff
    80004856:	8ff9                	and	a5,a5,a4
    80004858:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000485c:	4691                	li	a3,4
    8000485e:	6609                	lui	a2,0x2
    80004860:	963e                	add	a2,a2,a5
    80004862:	85be                	mv	a1,a5
    80004864:	855a                	mv	a0,s6
    80004866:	9b9fc0ef          	jal	ra,8000121e <uvmalloc>
    8000486a:	8c2a                	mv	s8,a0
  ip = 0;
    8000486c:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000486e:	12050063          	beqz	a0,8000498e <kexec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004872:	75f9                	lui	a1,0xffffe
    80004874:	95aa                	add	a1,a1,a0
    80004876:	855a                	mv	a0,s6
    80004878:	b71fc0ef          	jal	ra,800013e8 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000487c:	7afd                	lui	s5,0xfffff
    8000487e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004880:	df043783          	ld	a5,-528(s0)
    80004884:	6388                	ld	a0,0(a5)
    80004886:	c135                	beqz	a0,800048ea <kexec+0x1d4>
    80004888:	e9040993          	addi	s3,s0,-368
    8000488c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004890:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004892:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004894:	d22fc0ef          	jal	ra,80000db6 <strlen>
    80004898:	0015079b          	addiw	a5,a0,1
    8000489c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800048a0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800048a4:	11596a63          	bltu	s2,s5,800049b8 <kexec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800048a8:	df043d83          	ld	s11,-528(s0)
    800048ac:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800048b0:	8552                	mv	a0,s4
    800048b2:	d04fc0ef          	jal	ra,80000db6 <strlen>
    800048b6:	0015069b          	addiw	a3,a0,1
    800048ba:	8652                	mv	a2,s4
    800048bc:	85ca                	mv	a1,s2
    800048be:	855a                	mv	a0,s6
    800048c0:	c91fc0ef          	jal	ra,80001550 <copyout>
    800048c4:	0e054e63          	bltz	a0,800049c0 <kexec+0x2aa>
    ustack[argc] = sp;
    800048c8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800048cc:	0485                	addi	s1,s1,1
    800048ce:	008d8793          	addi	a5,s11,8
    800048d2:	def43823          	sd	a5,-528(s0)
    800048d6:	008db503          	ld	a0,8(s11)
    800048da:	c911                	beqz	a0,800048ee <kexec+0x1d8>
    if(argc >= MAXARG)
    800048dc:	09a1                	addi	s3,s3,8
    800048de:	fb3c9be3          	bne	s9,s3,80004894 <kexec+0x17e>
  sz = sz1;
    800048e2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800048e6:	4a81                	li	s5,0
    800048e8:	a05d                	j	8000498e <kexec+0x278>
  sp = sz;
    800048ea:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800048ec:	4481                	li	s1,0
  ustack[argc] = 0;
    800048ee:	00349793          	slli	a5,s1,0x3
    800048f2:	f9078793          	addi	a5,a5,-112
    800048f6:	97a2                	add	a5,a5,s0
    800048f8:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048fc:	00148693          	addi	a3,s1,1
    80004900:	068e                	slli	a3,a3,0x3
    80004902:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004906:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000490a:	01597663          	bgeu	s2,s5,80004916 <kexec+0x200>
  sz = sz1;
    8000490e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004912:	4a81                	li	s5,0
    80004914:	a8ad                	j	8000498e <kexec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004916:	e9040613          	addi	a2,s0,-368
    8000491a:	85ca                	mv	a1,s2
    8000491c:	855a                	mv	a0,s6
    8000491e:	c33fc0ef          	jal	ra,80001550 <copyout>
    80004922:	0a054363          	bltz	a0,800049c8 <kexec+0x2b2>
  p->trapframe->a1 = sp;
    80004926:	058bb783          	ld	a5,88(s7)
    8000492a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000492e:	de843783          	ld	a5,-536(s0)
    80004932:	0007c703          	lbu	a4,0(a5)
    80004936:	cf11                	beqz	a4,80004952 <kexec+0x23c>
    80004938:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000493a:	02f00693          	li	a3,47
    8000493e:	a039                	j	8000494c <kexec+0x236>
      last = s+1;
    80004940:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004944:	0785                	addi	a5,a5,1
    80004946:	fff7c703          	lbu	a4,-1(a5)
    8000494a:	c701                	beqz	a4,80004952 <kexec+0x23c>
    if(*s == '/')
    8000494c:	fed71ce3          	bne	a4,a3,80004944 <kexec+0x22e>
    80004950:	bfc5                	j	80004940 <kexec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004952:	4641                	li	a2,16
    80004954:	de843583          	ld	a1,-536(s0)
    80004958:	158b8513          	addi	a0,s7,344
    8000495c:	c28fc0ef          	jal	ra,80000d84 <safestrcpy>
  oldpagetable = p->pagetable;
    80004960:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004964:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004968:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000496c:	058bb783          	ld	a5,88(s7)
    80004970:	e6843703          	ld	a4,-408(s0)
    80004974:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004976:	058bb783          	ld	a5,88(s7)
    8000497a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000497e:	85ea                	mv	a1,s10
    80004980:	80cfd0ef          	jal	ra,8000198c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004984:	0004851b          	sext.w	a0,s1
    80004988:	b539                	j	80004796 <kexec+0x80>
    8000498a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000498e:	df843583          	ld	a1,-520(s0)
    80004992:	855a                	mv	a0,s6
    80004994:	ff9fc0ef          	jal	ra,8000198c <proc_freepagetable>
  if(ip){
    80004998:	de0a99e3          	bnez	s5,8000478a <kexec+0x74>
  return -1;
    8000499c:	557d                	li	a0,-1
    8000499e:	bbe5                	j	80004796 <kexec+0x80>
    800049a0:	df243c23          	sd	s2,-520(s0)
    800049a4:	b7ed                	j	8000498e <kexec+0x278>
    800049a6:	df243c23          	sd	s2,-520(s0)
    800049aa:	b7d5                	j	8000498e <kexec+0x278>
    800049ac:	df243c23          	sd	s2,-520(s0)
    800049b0:	bff9                	j	8000498e <kexec+0x278>
    800049b2:	df243c23          	sd	s2,-520(s0)
    800049b6:	bfe1                	j	8000498e <kexec+0x278>
  sz = sz1;
    800049b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049bc:	4a81                	li	s5,0
    800049be:	bfc1                	j	8000498e <kexec+0x278>
  sz = sz1;
    800049c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049c4:	4a81                	li	s5,0
    800049c6:	b7e1                	j	8000498e <kexec+0x278>
  sz = sz1;
    800049c8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800049cc:	4a81                	li	s5,0
    800049ce:	b7c1                	j	8000498e <kexec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049d0:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049d4:	e0843783          	ld	a5,-504(s0)
    800049d8:	0017869b          	addiw	a3,a5,1
    800049dc:	e0d43423          	sd	a3,-504(s0)
    800049e0:	e0043783          	ld	a5,-512(s0)
    800049e4:	0387879b          	addiw	a5,a5,56
    800049e8:	e8845703          	lhu	a4,-376(s0)
    800049ec:	e4e6d7e3          	bge	a3,a4,8000483a <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049f0:	2781                	sext.w	a5,a5
    800049f2:	e0f43023          	sd	a5,-512(s0)
    800049f6:	03800713          	li	a4,56
    800049fa:	86be                	mv	a3,a5
    800049fc:	e1840613          	addi	a2,s0,-488
    80004a00:	4581                	li	a1,0
    80004a02:	8556                	mv	a0,s5
    80004a04:	d01fe0ef          	jal	ra,80003704 <readi>
    80004a08:	03800793          	li	a5,56
    80004a0c:	f6f51fe3          	bne	a0,a5,8000498a <kexec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80004a10:	e1842783          	lw	a5,-488(s0)
    80004a14:	4705                	li	a4,1
    80004a16:	fae79fe3          	bne	a5,a4,800049d4 <kexec+0x2be>
    if(ph.memsz < ph.filesz)
    80004a1a:	e4043483          	ld	s1,-448(s0)
    80004a1e:	e3843783          	ld	a5,-456(s0)
    80004a22:	f6f4efe3          	bltu	s1,a5,800049a0 <kexec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a26:	e2843783          	ld	a5,-472(s0)
    80004a2a:	94be                	add	s1,s1,a5
    80004a2c:	f6f4ede3          	bltu	s1,a5,800049a6 <kexec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80004a30:	de043703          	ld	a4,-544(s0)
    80004a34:	8ff9                	and	a5,a5,a4
    80004a36:	fbbd                	bnez	a5,800049ac <kexec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a38:	e1c42503          	lw	a0,-484(s0)
    80004a3c:	cc1ff0ef          	jal	ra,800046fc <flags2perm>
    80004a40:	86aa                	mv	a3,a0
    80004a42:	8626                	mv	a2,s1
    80004a44:	85ca                	mv	a1,s2
    80004a46:	855a                	mv	a0,s6
    80004a48:	fd6fc0ef          	jal	ra,8000121e <uvmalloc>
    80004a4c:	dea43c23          	sd	a0,-520(s0)
    80004a50:	d12d                	beqz	a0,800049b2 <kexec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a52:	e2843c03          	ld	s8,-472(s0)
    80004a56:	e2042c83          	lw	s9,-480(s0)
    80004a5a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a5e:	f60b89e3          	beqz	s7,800049d0 <kexec+0x2ba>
    80004a62:	89de                	mv	s3,s7
    80004a64:	4481                	li	s1,0
    80004a66:	bb5d                	j	8000481c <kexec+0x106>

0000000080004a68 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a68:	7179                	addi	sp,sp,-48
    80004a6a:	f406                	sd	ra,40(sp)
    80004a6c:	f022                	sd	s0,32(sp)
    80004a6e:	ec26                	sd	s1,24(sp)
    80004a70:	e84a                	sd	s2,16(sp)
    80004a72:	1800                	addi	s0,sp,48
    80004a74:	892e                	mv	s2,a1
    80004a76:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a78:	fdc40593          	addi	a1,s0,-36
    80004a7c:	ec5fd0ef          	jal	ra,80002940 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a80:	fdc42703          	lw	a4,-36(s0)
    80004a84:	47bd                	li	a5,15
    80004a86:	02e7e963          	bltu	a5,a4,80004ab8 <argfd+0x50>
    80004a8a:	d79fc0ef          	jal	ra,80001802 <myproc>
    80004a8e:	fdc42703          	lw	a4,-36(s0)
    80004a92:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffde082>
    80004a96:	078e                	slli	a5,a5,0x3
    80004a98:	953e                	add	a0,a0,a5
    80004a9a:	611c                	ld	a5,0(a0)
    80004a9c:	c385                	beqz	a5,80004abc <argfd+0x54>
    return -1;
  if(pfd)
    80004a9e:	00090463          	beqz	s2,80004aa6 <argfd+0x3e>
    *pfd = fd;
    80004aa2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aa6:	4501                	li	a0,0
  if(pf)
    80004aa8:	c091                	beqz	s1,80004aac <argfd+0x44>
    *pf = f;
    80004aaa:	e09c                	sd	a5,0(s1)
}
    80004aac:	70a2                	ld	ra,40(sp)
    80004aae:	7402                	ld	s0,32(sp)
    80004ab0:	64e2                	ld	s1,24(sp)
    80004ab2:	6942                	ld	s2,16(sp)
    80004ab4:	6145                	addi	sp,sp,48
    80004ab6:	8082                	ret
    return -1;
    80004ab8:	557d                	li	a0,-1
    80004aba:	bfcd                	j	80004aac <argfd+0x44>
    80004abc:	557d                	li	a0,-1
    80004abe:	b7fd                	j	80004aac <argfd+0x44>

0000000080004ac0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004ac0:	1101                	addi	sp,sp,-32
    80004ac2:	ec06                	sd	ra,24(sp)
    80004ac4:	e822                	sd	s0,16(sp)
    80004ac6:	e426                	sd	s1,8(sp)
    80004ac8:	1000                	addi	s0,sp,32
    80004aca:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004acc:	d37fc0ef          	jal	ra,80001802 <myproc>
    80004ad0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ad2:	0d050793          	addi	a5,a0,208
    80004ad6:	4501                	li	a0,0
    80004ad8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ada:	6398                	ld	a4,0(a5)
    80004adc:	cb19                	beqz	a4,80004af2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ade:	2505                	addiw	a0,a0,1
    80004ae0:	07a1                	addi	a5,a5,8
    80004ae2:	fed51ce3          	bne	a0,a3,80004ada <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ae6:	557d                	li	a0,-1
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6105                	addi	sp,sp,32
    80004af0:	8082                	ret
      p->ofile[fd] = f;
    80004af2:	01a50793          	addi	a5,a0,26
    80004af6:	078e                	slli	a5,a5,0x3
    80004af8:	963e                	add	a2,a2,a5
    80004afa:	e204                	sd	s1,0(a2)
      return fd;
    80004afc:	b7f5                	j	80004ae8 <fdalloc+0x28>

0000000080004afe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004afe:	715d                	addi	sp,sp,-80
    80004b00:	e486                	sd	ra,72(sp)
    80004b02:	e0a2                	sd	s0,64(sp)
    80004b04:	fc26                	sd	s1,56(sp)
    80004b06:	f84a                	sd	s2,48(sp)
    80004b08:	f44e                	sd	s3,40(sp)
    80004b0a:	f052                	sd	s4,32(sp)
    80004b0c:	ec56                	sd	s5,24(sp)
    80004b0e:	e85a                	sd	s6,16(sp)
    80004b10:	0880                	addi	s0,sp,80
    80004b12:	8b2e                	mv	s6,a1
    80004b14:	89b2                	mv	s3,a2
    80004b16:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b18:	fb040593          	addi	a1,s0,-80
    80004b1c:	86aff0ef          	jal	ra,80003b86 <nameiparent>
    80004b20:	84aa                	mv	s1,a0
    80004b22:	10050b63          	beqz	a0,80004c38 <create+0x13a>
    return 0;

  ilock(dp);
    80004b26:	853fe0ef          	jal	ra,80003378 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b2a:	4601                	li	a2,0
    80004b2c:	fb040593          	addi	a1,s0,-80
    80004b30:	8526                	mv	a0,s1
    80004b32:	dcffe0ef          	jal	ra,80003900 <dirlookup>
    80004b36:	8aaa                	mv	s5,a0
    80004b38:	c521                	beqz	a0,80004b80 <create+0x82>
    iunlockput(dp);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	a43fe0ef          	jal	ra,8000357e <iunlockput>
    ilock(ip);
    80004b40:	8556                	mv	a0,s5
    80004b42:	837fe0ef          	jal	ra,80003378 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b46:	000b059b          	sext.w	a1,s6
    80004b4a:	4789                	li	a5,2
    80004b4c:	02f59563          	bne	a1,a5,80004b76 <create+0x78>
    80004b50:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde0ac>
    80004b54:	37f9                	addiw	a5,a5,-2
    80004b56:	17c2                	slli	a5,a5,0x30
    80004b58:	93c1                	srli	a5,a5,0x30
    80004b5a:	4705                	li	a4,1
    80004b5c:	00f76d63          	bltu	a4,a5,80004b76 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b60:	8556                	mv	a0,s5
    80004b62:	60a6                	ld	ra,72(sp)
    80004b64:	6406                	ld	s0,64(sp)
    80004b66:	74e2                	ld	s1,56(sp)
    80004b68:	7942                	ld	s2,48(sp)
    80004b6a:	79a2                	ld	s3,40(sp)
    80004b6c:	7a02                	ld	s4,32(sp)
    80004b6e:	6ae2                	ld	s5,24(sp)
    80004b70:	6b42                	ld	s6,16(sp)
    80004b72:	6161                	addi	sp,sp,80
    80004b74:	8082                	ret
    iunlockput(ip);
    80004b76:	8556                	mv	a0,s5
    80004b78:	a07fe0ef          	jal	ra,8000357e <iunlockput>
    return 0;
    80004b7c:	4a81                	li	s5,0
    80004b7e:	b7cd                	j	80004b60 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b80:	85da                	mv	a1,s6
    80004b82:	4088                	lw	a0,0(s1)
    80004b84:	e8afe0ef          	jal	ra,8000320e <ialloc>
    80004b88:	8a2a                	mv	s4,a0
    80004b8a:	cd1d                	beqz	a0,80004bc8 <create+0xca>
  ilock(ip);
    80004b8c:	fecfe0ef          	jal	ra,80003378 <ilock>
  ip->major = major;
    80004b90:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b94:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b98:	4905                	li	s2,1
    80004b9a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b9e:	8552                	mv	a0,s4
    80004ba0:	f24fe0ef          	jal	ra,800032c4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ba4:	000b059b          	sext.w	a1,s6
    80004ba8:	03258563          	beq	a1,s2,80004bd2 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bac:	004a2603          	lw	a2,4(s4)
    80004bb0:	fb040593          	addi	a1,s0,-80
    80004bb4:	8526                	mv	a0,s1
    80004bb6:	f1dfe0ef          	jal	ra,80003ad2 <dirlink>
    80004bba:	06054363          	bltz	a0,80004c20 <create+0x122>
  iunlockput(dp);
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	9bffe0ef          	jal	ra,8000357e <iunlockput>
  return ip;
    80004bc4:	8ad2                	mv	s5,s4
    80004bc6:	bf69                	j	80004b60 <create+0x62>
    iunlockput(dp);
    80004bc8:	8526                	mv	a0,s1
    80004bca:	9b5fe0ef          	jal	ra,8000357e <iunlockput>
    return 0;
    80004bce:	8ad2                	mv	s5,s4
    80004bd0:	bf41                	j	80004b60 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bd2:	004a2603          	lw	a2,4(s4)
    80004bd6:	00003597          	auipc	a1,0x3
    80004bda:	b0a58593          	addi	a1,a1,-1270 # 800076e0 <syscalls+0x2f0>
    80004bde:	8552                	mv	a0,s4
    80004be0:	ef3fe0ef          	jal	ra,80003ad2 <dirlink>
    80004be4:	02054e63          	bltz	a0,80004c20 <create+0x122>
    80004be8:	40d0                	lw	a2,4(s1)
    80004bea:	00003597          	auipc	a1,0x3
    80004bee:	afe58593          	addi	a1,a1,-1282 # 800076e8 <syscalls+0x2f8>
    80004bf2:	8552                	mv	a0,s4
    80004bf4:	edffe0ef          	jal	ra,80003ad2 <dirlink>
    80004bf8:	02054463          	bltz	a0,80004c20 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bfc:	004a2603          	lw	a2,4(s4)
    80004c00:	fb040593          	addi	a1,s0,-80
    80004c04:	8526                	mv	a0,s1
    80004c06:	ecdfe0ef          	jal	ra,80003ad2 <dirlink>
    80004c0a:	00054b63          	bltz	a0,80004c20 <create+0x122>
    dp->nlink++;  // for ".."
    80004c0e:	04a4d783          	lhu	a5,74(s1)
    80004c12:	2785                	addiw	a5,a5,1
    80004c14:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	eaafe0ef          	jal	ra,800032c4 <iupdate>
    80004c1e:	b745                	j	80004bbe <create+0xc0>
  ip->nlink = 0;
    80004c20:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c24:	8552                	mv	a0,s4
    80004c26:	e9efe0ef          	jal	ra,800032c4 <iupdate>
  iunlockput(ip);
    80004c2a:	8552                	mv	a0,s4
    80004c2c:	953fe0ef          	jal	ra,8000357e <iunlockput>
  iunlockput(dp);
    80004c30:	8526                	mv	a0,s1
    80004c32:	94dfe0ef          	jal	ra,8000357e <iunlockput>
  return 0;
    80004c36:	b72d                	j	80004b60 <create+0x62>
    return 0;
    80004c38:	8aaa                	mv	s5,a0
    80004c3a:	b71d                	j	80004b60 <create+0x62>

0000000080004c3c <sys_dup>:
{
    80004c3c:	7179                	addi	sp,sp,-48
    80004c3e:	f406                	sd	ra,40(sp)
    80004c40:	f022                	sd	s0,32(sp)
    80004c42:	ec26                	sd	s1,24(sp)
    80004c44:	e84a                	sd	s2,16(sp)
    80004c46:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c48:	fd840613          	addi	a2,s0,-40
    80004c4c:	4581                	li	a1,0
    80004c4e:	4501                	li	a0,0
    80004c50:	e19ff0ef          	jal	ra,80004a68 <argfd>
    return -1;
    80004c54:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c56:	00054f63          	bltz	a0,80004c74 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
    80004c5a:	fd843903          	ld	s2,-40(s0)
    80004c5e:	854a                	mv	a0,s2
    80004c60:	e61ff0ef          	jal	ra,80004ac0 <fdalloc>
    80004c64:	84aa                	mv	s1,a0
    return -1;
    80004c66:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c68:	00054663          	bltz	a0,80004c74 <sys_dup+0x38>
  filedup(f);
    80004c6c:	854a                	mv	a0,s2
    80004c6e:	cb6ff0ef          	jal	ra,80004124 <filedup>
  return fd;
    80004c72:	87a6                	mv	a5,s1
}
    80004c74:	853e                	mv	a0,a5
    80004c76:	70a2                	ld	ra,40(sp)
    80004c78:	7402                	ld	s0,32(sp)
    80004c7a:	64e2                	ld	s1,24(sp)
    80004c7c:	6942                	ld	s2,16(sp)
    80004c7e:	6145                	addi	sp,sp,48
    80004c80:	8082                	ret

0000000080004c82 <sys_read>:
{
    80004c82:	7179                	addi	sp,sp,-48
    80004c84:	f406                	sd	ra,40(sp)
    80004c86:	f022                	sd	s0,32(sp)
    80004c88:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c8a:	fd840593          	addi	a1,s0,-40
    80004c8e:	4505                	li	a0,1
    80004c90:	ccdfd0ef          	jal	ra,8000295c <argaddr>
  argint(2, &n);
    80004c94:	fe440593          	addi	a1,s0,-28
    80004c98:	4509                	li	a0,2
    80004c9a:	ca7fd0ef          	jal	ra,80002940 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c9e:	fe840613          	addi	a2,s0,-24
    80004ca2:	4581                	li	a1,0
    80004ca4:	4501                	li	a0,0
    80004ca6:	dc3ff0ef          	jal	ra,80004a68 <argfd>
    80004caa:	87aa                	mv	a5,a0
    return -1;
    80004cac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cae:	0007ca63          	bltz	a5,80004cc2 <sys_read+0x40>
  return fileread(f, p, n);
    80004cb2:	fe442603          	lw	a2,-28(s0)
    80004cb6:	fd843583          	ld	a1,-40(s0)
    80004cba:	fe843503          	ld	a0,-24(s0)
    80004cbe:	db2ff0ef          	jal	ra,80004270 <fileread>
}
    80004cc2:	70a2                	ld	ra,40(sp)
    80004cc4:	7402                	ld	s0,32(sp)
    80004cc6:	6145                	addi	sp,sp,48
    80004cc8:	8082                	ret

0000000080004cca <sys_write>:
{
    80004cca:	7179                	addi	sp,sp,-48
    80004ccc:	f406                	sd	ra,40(sp)
    80004cce:	f022                	sd	s0,32(sp)
    80004cd0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cd2:	fd840593          	addi	a1,s0,-40
    80004cd6:	4505                	li	a0,1
    80004cd8:	c85fd0ef          	jal	ra,8000295c <argaddr>
  argint(2, &n);
    80004cdc:	fe440593          	addi	a1,s0,-28
    80004ce0:	4509                	li	a0,2
    80004ce2:	c5ffd0ef          	jal	ra,80002940 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce6:	fe840613          	addi	a2,s0,-24
    80004cea:	4581                	li	a1,0
    80004cec:	4501                	li	a0,0
    80004cee:	d7bff0ef          	jal	ra,80004a68 <argfd>
    80004cf2:	87aa                	mv	a5,a0
    return -1;
    80004cf4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf6:	0007ca63          	bltz	a5,80004d0a <sys_write+0x40>
  return filewrite(f, p, n);
    80004cfa:	fe442603          	lw	a2,-28(s0)
    80004cfe:	fd843583          	ld	a1,-40(s0)
    80004d02:	fe843503          	ld	a0,-24(s0)
    80004d06:	e18ff0ef          	jal	ra,8000431e <filewrite>
}
    80004d0a:	70a2                	ld	ra,40(sp)
    80004d0c:	7402                	ld	s0,32(sp)
    80004d0e:	6145                	addi	sp,sp,48
    80004d10:	8082                	ret

0000000080004d12 <sys_close>:
{
    80004d12:	1101                	addi	sp,sp,-32
    80004d14:	ec06                	sd	ra,24(sp)
    80004d16:	e822                	sd	s0,16(sp)
    80004d18:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d1a:	fe040613          	addi	a2,s0,-32
    80004d1e:	fec40593          	addi	a1,s0,-20
    80004d22:	4501                	li	a0,0
    80004d24:	d45ff0ef          	jal	ra,80004a68 <argfd>
    return -1;
    80004d28:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d2a:	02054063          	bltz	a0,80004d4a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d2e:	ad5fc0ef          	jal	ra,80001802 <myproc>
    80004d32:	fec42783          	lw	a5,-20(s0)
    80004d36:	07e9                	addi	a5,a5,26
    80004d38:	078e                	slli	a5,a5,0x3
    80004d3a:	953e                	add	a0,a0,a5
    80004d3c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d40:	fe043503          	ld	a0,-32(s0)
    80004d44:	c26ff0ef          	jal	ra,8000416a <fileclose>
  return 0;
    80004d48:	4781                	li	a5,0
}
    80004d4a:	853e                	mv	a0,a5
    80004d4c:	60e2                	ld	ra,24(sp)
    80004d4e:	6442                	ld	s0,16(sp)
    80004d50:	6105                	addi	sp,sp,32
    80004d52:	8082                	ret

0000000080004d54 <sys_fstat>:
{
    80004d54:	1101                	addi	sp,sp,-32
    80004d56:	ec06                	sd	ra,24(sp)
    80004d58:	e822                	sd	s0,16(sp)
    80004d5a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d5c:	fe040593          	addi	a1,s0,-32
    80004d60:	4505                	li	a0,1
    80004d62:	bfbfd0ef          	jal	ra,8000295c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d66:	fe840613          	addi	a2,s0,-24
    80004d6a:	4581                	li	a1,0
    80004d6c:	4501                	li	a0,0
    80004d6e:	cfbff0ef          	jal	ra,80004a68 <argfd>
    80004d72:	87aa                	mv	a5,a0
    return -1;
    80004d74:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d76:	0007c863          	bltz	a5,80004d86 <sys_fstat+0x32>
  return filestat(f, st);
    80004d7a:	fe043583          	ld	a1,-32(s0)
    80004d7e:	fe843503          	ld	a0,-24(s0)
    80004d82:	c90ff0ef          	jal	ra,80004212 <filestat>
}
    80004d86:	60e2                	ld	ra,24(sp)
    80004d88:	6442                	ld	s0,16(sp)
    80004d8a:	6105                	addi	sp,sp,32
    80004d8c:	8082                	ret

0000000080004d8e <sys_link>:
{
    80004d8e:	7169                	addi	sp,sp,-304
    80004d90:	f606                	sd	ra,296(sp)
    80004d92:	f222                	sd	s0,288(sp)
    80004d94:	ee26                	sd	s1,280(sp)
    80004d96:	ea4a                	sd	s2,272(sp)
    80004d98:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d9a:	08000613          	li	a2,128
    80004d9e:	ed040593          	addi	a1,s0,-304
    80004da2:	4501                	li	a0,0
    80004da4:	bd5fd0ef          	jal	ra,80002978 <argstr>
    return -1;
    80004da8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004daa:	0c054663          	bltz	a0,80004e76 <sys_link+0xe8>
    80004dae:	08000613          	li	a2,128
    80004db2:	f5040593          	addi	a1,s0,-176
    80004db6:	4505                	li	a0,1
    80004db8:	bc1fd0ef          	jal	ra,80002978 <argstr>
    return -1;
    80004dbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dbe:	0a054c63          	bltz	a0,80004e76 <sys_link+0xe8>
  begin_op();
    80004dc2:	f9ffe0ef          	jal	ra,80003d60 <begin_op>
  if((ip = namei(old)) == 0){
    80004dc6:	ed040513          	addi	a0,s0,-304
    80004dca:	da3fe0ef          	jal	ra,80003b6c <namei>
    80004dce:	84aa                	mv	s1,a0
    80004dd0:	c525                	beqz	a0,80004e38 <sys_link+0xaa>
  ilock(ip);
    80004dd2:	da6fe0ef          	jal	ra,80003378 <ilock>
  if(ip->type == T_DIR){
    80004dd6:	04449703          	lh	a4,68(s1)
    80004dda:	4785                	li	a5,1
    80004ddc:	06f70263          	beq	a4,a5,80004e40 <sys_link+0xb2>
  ip->nlink++;
    80004de0:	04a4d783          	lhu	a5,74(s1)
    80004de4:	2785                	addiw	a5,a5,1
    80004de6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dea:	8526                	mv	a0,s1
    80004dec:	cd8fe0ef          	jal	ra,800032c4 <iupdate>
  iunlock(ip);
    80004df0:	8526                	mv	a0,s1
    80004df2:	e30fe0ef          	jal	ra,80003422 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004df6:	fd040593          	addi	a1,s0,-48
    80004dfa:	f5040513          	addi	a0,s0,-176
    80004dfe:	d89fe0ef          	jal	ra,80003b86 <nameiparent>
    80004e02:	892a                	mv	s2,a0
    80004e04:	c921                	beqz	a0,80004e54 <sys_link+0xc6>
  ilock(dp);
    80004e06:	d72fe0ef          	jal	ra,80003378 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e0a:	00092703          	lw	a4,0(s2)
    80004e0e:	409c                	lw	a5,0(s1)
    80004e10:	02f71f63          	bne	a4,a5,80004e4e <sys_link+0xc0>
    80004e14:	40d0                	lw	a2,4(s1)
    80004e16:	fd040593          	addi	a1,s0,-48
    80004e1a:	854a                	mv	a0,s2
    80004e1c:	cb7fe0ef          	jal	ra,80003ad2 <dirlink>
    80004e20:	02054763          	bltz	a0,80004e4e <sys_link+0xc0>
  iunlockput(dp);
    80004e24:	854a                	mv	a0,s2
    80004e26:	f58fe0ef          	jal	ra,8000357e <iunlockput>
  iput(ip);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ecafe0ef          	jal	ra,800034f6 <iput>
  end_op();
    80004e30:	f9ffe0ef          	jal	ra,80003dce <end_op>
  return 0;
    80004e34:	4781                	li	a5,0
    80004e36:	a081                	j	80004e76 <sys_link+0xe8>
    end_op();
    80004e38:	f97fe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80004e3c:	57fd                	li	a5,-1
    80004e3e:	a825                	j	80004e76 <sys_link+0xe8>
    iunlockput(ip);
    80004e40:	8526                	mv	a0,s1
    80004e42:	f3cfe0ef          	jal	ra,8000357e <iunlockput>
    end_op();
    80004e46:	f89fe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80004e4a:	57fd                	li	a5,-1
    80004e4c:	a02d                	j	80004e76 <sys_link+0xe8>
    iunlockput(dp);
    80004e4e:	854a                	mv	a0,s2
    80004e50:	f2efe0ef          	jal	ra,8000357e <iunlockput>
  ilock(ip);
    80004e54:	8526                	mv	a0,s1
    80004e56:	d22fe0ef          	jal	ra,80003378 <ilock>
  ip->nlink--;
    80004e5a:	04a4d783          	lhu	a5,74(s1)
    80004e5e:	37fd                	addiw	a5,a5,-1
    80004e60:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e64:	8526                	mv	a0,s1
    80004e66:	c5efe0ef          	jal	ra,800032c4 <iupdate>
  iunlockput(ip);
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	f12fe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    80004e70:	f5ffe0ef          	jal	ra,80003dce <end_op>
  return -1;
    80004e74:	57fd                	li	a5,-1
}
    80004e76:	853e                	mv	a0,a5
    80004e78:	70b2                	ld	ra,296(sp)
    80004e7a:	7412                	ld	s0,288(sp)
    80004e7c:	64f2                	ld	s1,280(sp)
    80004e7e:	6952                	ld	s2,272(sp)
    80004e80:	6155                	addi	sp,sp,304
    80004e82:	8082                	ret

0000000080004e84 <sys_unlink>:
{
    80004e84:	7151                	addi	sp,sp,-240
    80004e86:	f586                	sd	ra,232(sp)
    80004e88:	f1a2                	sd	s0,224(sp)
    80004e8a:	eda6                	sd	s1,216(sp)
    80004e8c:	e9ca                	sd	s2,208(sp)
    80004e8e:	e5ce                	sd	s3,200(sp)
    80004e90:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e92:	08000613          	li	a2,128
    80004e96:	f3040593          	addi	a1,s0,-208
    80004e9a:	4501                	li	a0,0
    80004e9c:	addfd0ef          	jal	ra,80002978 <argstr>
    80004ea0:	12054b63          	bltz	a0,80004fd6 <sys_unlink+0x152>
  begin_op();
    80004ea4:	ebdfe0ef          	jal	ra,80003d60 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ea8:	fb040593          	addi	a1,s0,-80
    80004eac:	f3040513          	addi	a0,s0,-208
    80004eb0:	cd7fe0ef          	jal	ra,80003b86 <nameiparent>
    80004eb4:	84aa                	mv	s1,a0
    80004eb6:	c54d                	beqz	a0,80004f60 <sys_unlink+0xdc>
  ilock(dp);
    80004eb8:	cc0fe0ef          	jal	ra,80003378 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ebc:	00003597          	auipc	a1,0x3
    80004ec0:	82458593          	addi	a1,a1,-2012 # 800076e0 <syscalls+0x2f0>
    80004ec4:	fb040513          	addi	a0,s0,-80
    80004ec8:	a23fe0ef          	jal	ra,800038ea <namecmp>
    80004ecc:	10050a63          	beqz	a0,80004fe0 <sys_unlink+0x15c>
    80004ed0:	00003597          	auipc	a1,0x3
    80004ed4:	81858593          	addi	a1,a1,-2024 # 800076e8 <syscalls+0x2f8>
    80004ed8:	fb040513          	addi	a0,s0,-80
    80004edc:	a0ffe0ef          	jal	ra,800038ea <namecmp>
    80004ee0:	10050063          	beqz	a0,80004fe0 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ee4:	f2c40613          	addi	a2,s0,-212
    80004ee8:	fb040593          	addi	a1,s0,-80
    80004eec:	8526                	mv	a0,s1
    80004eee:	a13fe0ef          	jal	ra,80003900 <dirlookup>
    80004ef2:	892a                	mv	s2,a0
    80004ef4:	0e050663          	beqz	a0,80004fe0 <sys_unlink+0x15c>
  ilock(ip);
    80004ef8:	c80fe0ef          	jal	ra,80003378 <ilock>
  if(ip->nlink < 1)
    80004efc:	04a91783          	lh	a5,74(s2)
    80004f00:	06f05463          	blez	a5,80004f68 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f04:	04491703          	lh	a4,68(s2)
    80004f08:	4785                	li	a5,1
    80004f0a:	06f70563          	beq	a4,a5,80004f74 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004f0e:	4641                	li	a2,16
    80004f10:	4581                	li	a1,0
    80004f12:	fc040513          	addi	a0,s0,-64
    80004f16:	d29fb0ef          	jal	ra,80000c3e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f1a:	4741                	li	a4,16
    80004f1c:	f2c42683          	lw	a3,-212(s0)
    80004f20:	fc040613          	addi	a2,s0,-64
    80004f24:	4581                	li	a1,0
    80004f26:	8526                	mv	a0,s1
    80004f28:	8c1fe0ef          	jal	ra,800037e8 <writei>
    80004f2c:	47c1                	li	a5,16
    80004f2e:	08f51563          	bne	a0,a5,80004fb8 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f32:	04491703          	lh	a4,68(s2)
    80004f36:	4785                	li	a5,1
    80004f38:	08f70663          	beq	a4,a5,80004fc4 <sys_unlink+0x140>
  iunlockput(dp);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	e40fe0ef          	jal	ra,8000357e <iunlockput>
  ip->nlink--;
    80004f42:	04a95783          	lhu	a5,74(s2)
    80004f46:	37fd                	addiw	a5,a5,-1
    80004f48:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	b76fe0ef          	jal	ra,800032c4 <iupdate>
  iunlockput(ip);
    80004f52:	854a                	mv	a0,s2
    80004f54:	e2afe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    80004f58:	e77fe0ef          	jal	ra,80003dce <end_op>
  return 0;
    80004f5c:	4501                	li	a0,0
    80004f5e:	a079                	j	80004fec <sys_unlink+0x168>
    end_op();
    80004f60:	e6ffe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	a059                	j	80004fec <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f68:	00002517          	auipc	a0,0x2
    80004f6c:	78850513          	addi	a0,a0,1928 # 800076f0 <syscalls+0x300>
    80004f70:	819fb0ef          	jal	ra,80000788 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f74:	04c92703          	lw	a4,76(s2)
    80004f78:	02000793          	li	a5,32
    80004f7c:	f8e7f9e3          	bgeu	a5,a4,80004f0e <sys_unlink+0x8a>
    80004f80:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f84:	4741                	li	a4,16
    80004f86:	86ce                	mv	a3,s3
    80004f88:	f1840613          	addi	a2,s0,-232
    80004f8c:	4581                	li	a1,0
    80004f8e:	854a                	mv	a0,s2
    80004f90:	f74fe0ef          	jal	ra,80003704 <readi>
    80004f94:	47c1                	li	a5,16
    80004f96:	00f51b63          	bne	a0,a5,80004fac <sys_unlink+0x128>
    if(de.inum != 0)
    80004f9a:	f1845783          	lhu	a5,-232(s0)
    80004f9e:	ef95                	bnez	a5,80004fda <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fa0:	29c1                	addiw	s3,s3,16
    80004fa2:	04c92783          	lw	a5,76(s2)
    80004fa6:	fcf9efe3          	bltu	s3,a5,80004f84 <sys_unlink+0x100>
    80004faa:	b795                	j	80004f0e <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004fac:	00002517          	auipc	a0,0x2
    80004fb0:	75c50513          	addi	a0,a0,1884 # 80007708 <syscalls+0x318>
    80004fb4:	fd4fb0ef          	jal	ra,80000788 <panic>
    panic("unlink: writei");
    80004fb8:	00002517          	auipc	a0,0x2
    80004fbc:	76850513          	addi	a0,a0,1896 # 80007720 <syscalls+0x330>
    80004fc0:	fc8fb0ef          	jal	ra,80000788 <panic>
    dp->nlink--;
    80004fc4:	04a4d783          	lhu	a5,74(s1)
    80004fc8:	37fd                	addiw	a5,a5,-1
    80004fca:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	af4fe0ef          	jal	ra,800032c4 <iupdate>
    80004fd4:	b7a5                	j	80004f3c <sys_unlink+0xb8>
    return -1;
    80004fd6:	557d                	li	a0,-1
    80004fd8:	a811                	j	80004fec <sys_unlink+0x168>
    iunlockput(ip);
    80004fda:	854a                	mv	a0,s2
    80004fdc:	da2fe0ef          	jal	ra,8000357e <iunlockput>
  iunlockput(dp);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	d9cfe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    80004fe6:	de9fe0ef          	jal	ra,80003dce <end_op>
  return -1;
    80004fea:	557d                	li	a0,-1
}
    80004fec:	70ae                	ld	ra,232(sp)
    80004fee:	740e                	ld	s0,224(sp)
    80004ff0:	64ee                	ld	s1,216(sp)
    80004ff2:	694e                	ld	s2,208(sp)
    80004ff4:	69ae                	ld	s3,200(sp)
    80004ff6:	616d                	addi	sp,sp,240
    80004ff8:	8082                	ret

0000000080004ffa <sys_open>:

uint64
sys_open(void)
{
    80004ffa:	7131                	addi	sp,sp,-192
    80004ffc:	fd06                	sd	ra,184(sp)
    80004ffe:	f922                	sd	s0,176(sp)
    80005000:	f526                	sd	s1,168(sp)
    80005002:	f14a                	sd	s2,160(sp)
    80005004:	ed4e                	sd	s3,152(sp)
    80005006:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005008:	f4c40593          	addi	a1,s0,-180
    8000500c:	4505                	li	a0,1
    8000500e:	933fd0ef          	jal	ra,80002940 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005012:	08000613          	li	a2,128
    80005016:	f5040593          	addi	a1,s0,-176
    8000501a:	4501                	li	a0,0
    8000501c:	95dfd0ef          	jal	ra,80002978 <argstr>
    80005020:	87aa                	mv	a5,a0
    return -1;
    80005022:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005024:	0807cd63          	bltz	a5,800050be <sys_open+0xc4>

  begin_op();
    80005028:	d39fe0ef          	jal	ra,80003d60 <begin_op>

  if(omode & O_CREATE){
    8000502c:	f4c42783          	lw	a5,-180(s0)
    80005030:	2007f793          	andi	a5,a5,512
    80005034:	c3c5                	beqz	a5,800050d4 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005036:	4681                	li	a3,0
    80005038:	4601                	li	a2,0
    8000503a:	4589                	li	a1,2
    8000503c:	f5040513          	addi	a0,s0,-176
    80005040:	abfff0ef          	jal	ra,80004afe <create>
    80005044:	84aa                	mv	s1,a0
    if(ip == 0){
    80005046:	c159                	beqz	a0,800050cc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005048:	04449703          	lh	a4,68(s1)
    8000504c:	478d                	li	a5,3
    8000504e:	00f71763          	bne	a4,a5,8000505c <sys_open+0x62>
    80005052:	0464d703          	lhu	a4,70(s1)
    80005056:	47a5                	li	a5,9
    80005058:	0ae7e963          	bltu	a5,a4,8000510a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000505c:	86aff0ef          	jal	ra,800040c6 <filealloc>
    80005060:	89aa                	mv	s3,a0
    80005062:	0c050963          	beqz	a0,80005134 <sys_open+0x13a>
    80005066:	a5bff0ef          	jal	ra,80004ac0 <fdalloc>
    8000506a:	892a                	mv	s2,a0
    8000506c:	0c054163          	bltz	a0,8000512e <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005070:	04449703          	lh	a4,68(s1)
    80005074:	478d                	li	a5,3
    80005076:	0af70163          	beq	a4,a5,80005118 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000507a:	4789                	li	a5,2
    8000507c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005080:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005084:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005088:	f4c42783          	lw	a5,-180(s0)
    8000508c:	0017c713          	xori	a4,a5,1
    80005090:	8b05                	andi	a4,a4,1
    80005092:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005096:	0037f713          	andi	a4,a5,3
    8000509a:	00e03733          	snez	a4,a4
    8000509e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050a2:	4007f793          	andi	a5,a5,1024
    800050a6:	c791                	beqz	a5,800050b2 <sys_open+0xb8>
    800050a8:	04449703          	lh	a4,68(s1)
    800050ac:	4789                	li	a5,2
    800050ae:	06f70c63          	beq	a4,a5,80005126 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    800050b2:	8526                	mv	a0,s1
    800050b4:	b6efe0ef          	jal	ra,80003422 <iunlock>
  end_op();
    800050b8:	d17fe0ef          	jal	ra,80003dce <end_op>

  return fd;
    800050bc:	854a                	mv	a0,s2
}
    800050be:	70ea                	ld	ra,184(sp)
    800050c0:	744a                	ld	s0,176(sp)
    800050c2:	74aa                	ld	s1,168(sp)
    800050c4:	790a                	ld	s2,160(sp)
    800050c6:	69ea                	ld	s3,152(sp)
    800050c8:	6129                	addi	sp,sp,192
    800050ca:	8082                	ret
      end_op();
    800050cc:	d03fe0ef          	jal	ra,80003dce <end_op>
      return -1;
    800050d0:	557d                	li	a0,-1
    800050d2:	b7f5                	j	800050be <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800050d4:	f5040513          	addi	a0,s0,-176
    800050d8:	a95fe0ef          	jal	ra,80003b6c <namei>
    800050dc:	84aa                	mv	s1,a0
    800050de:	c115                	beqz	a0,80005102 <sys_open+0x108>
    ilock(ip);
    800050e0:	a98fe0ef          	jal	ra,80003378 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050e4:	04449703          	lh	a4,68(s1)
    800050e8:	4785                	li	a5,1
    800050ea:	f4f71fe3          	bne	a4,a5,80005048 <sys_open+0x4e>
    800050ee:	f4c42783          	lw	a5,-180(s0)
    800050f2:	d7ad                	beqz	a5,8000505c <sys_open+0x62>
      iunlockput(ip);
    800050f4:	8526                	mv	a0,s1
    800050f6:	c88fe0ef          	jal	ra,8000357e <iunlockput>
      end_op();
    800050fa:	cd5fe0ef          	jal	ra,80003dce <end_op>
      return -1;
    800050fe:	557d                	li	a0,-1
    80005100:	bf7d                	j	800050be <sys_open+0xc4>
      end_op();
    80005102:	ccdfe0ef          	jal	ra,80003dce <end_op>
      return -1;
    80005106:	557d                	li	a0,-1
    80005108:	bf5d                	j	800050be <sys_open+0xc4>
    iunlockput(ip);
    8000510a:	8526                	mv	a0,s1
    8000510c:	c72fe0ef          	jal	ra,8000357e <iunlockput>
    end_op();
    80005110:	cbffe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80005114:	557d                	li	a0,-1
    80005116:	b765                	j	800050be <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005118:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000511c:	04649783          	lh	a5,70(s1)
    80005120:	02f99223          	sh	a5,36(s3)
    80005124:	b785                	j	80005084 <sys_open+0x8a>
    itrunc(ip);
    80005126:	8526                	mv	a0,s1
    80005128:	b3afe0ef          	jal	ra,80003462 <itrunc>
    8000512c:	b759                	j	800050b2 <sys_open+0xb8>
      fileclose(f);
    8000512e:	854e                	mv	a0,s3
    80005130:	83aff0ef          	jal	ra,8000416a <fileclose>
    iunlockput(ip);
    80005134:	8526                	mv	a0,s1
    80005136:	c48fe0ef          	jal	ra,8000357e <iunlockput>
    end_op();
    8000513a:	c95fe0ef          	jal	ra,80003dce <end_op>
    return -1;
    8000513e:	557d                	li	a0,-1
    80005140:	bfbd                	j	800050be <sys_open+0xc4>

0000000080005142 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005142:	7175                	addi	sp,sp,-144
    80005144:	e506                	sd	ra,136(sp)
    80005146:	e122                	sd	s0,128(sp)
    80005148:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000514a:	c17fe0ef          	jal	ra,80003d60 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000514e:	08000613          	li	a2,128
    80005152:	f7040593          	addi	a1,s0,-144
    80005156:	4501                	li	a0,0
    80005158:	821fd0ef          	jal	ra,80002978 <argstr>
    8000515c:	02054363          	bltz	a0,80005182 <sys_mkdir+0x40>
    80005160:	4681                	li	a3,0
    80005162:	4601                	li	a2,0
    80005164:	4585                	li	a1,1
    80005166:	f7040513          	addi	a0,s0,-144
    8000516a:	995ff0ef          	jal	ra,80004afe <create>
    8000516e:	c911                	beqz	a0,80005182 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005170:	c0efe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    80005174:	c5bfe0ef          	jal	ra,80003dce <end_op>
  return 0;
    80005178:	4501                	li	a0,0
}
    8000517a:	60aa                	ld	ra,136(sp)
    8000517c:	640a                	ld	s0,128(sp)
    8000517e:	6149                	addi	sp,sp,144
    80005180:	8082                	ret
    end_op();
    80005182:	c4dfe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80005186:	557d                	li	a0,-1
    80005188:	bfcd                	j	8000517a <sys_mkdir+0x38>

000000008000518a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000518a:	7135                	addi	sp,sp,-160
    8000518c:	ed06                	sd	ra,152(sp)
    8000518e:	e922                	sd	s0,144(sp)
    80005190:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005192:	bcffe0ef          	jal	ra,80003d60 <begin_op>
  argint(1, &major);
    80005196:	f6c40593          	addi	a1,s0,-148
    8000519a:	4505                	li	a0,1
    8000519c:	fa4fd0ef          	jal	ra,80002940 <argint>
  argint(2, &minor);
    800051a0:	f6840593          	addi	a1,s0,-152
    800051a4:	4509                	li	a0,2
    800051a6:	f9afd0ef          	jal	ra,80002940 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051aa:	08000613          	li	a2,128
    800051ae:	f7040593          	addi	a1,s0,-144
    800051b2:	4501                	li	a0,0
    800051b4:	fc4fd0ef          	jal	ra,80002978 <argstr>
    800051b8:	02054563          	bltz	a0,800051e2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051bc:	f6841683          	lh	a3,-152(s0)
    800051c0:	f6c41603          	lh	a2,-148(s0)
    800051c4:	458d                	li	a1,3
    800051c6:	f7040513          	addi	a0,s0,-144
    800051ca:	935ff0ef          	jal	ra,80004afe <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ce:	c911                	beqz	a0,800051e2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051d0:	baefe0ef          	jal	ra,8000357e <iunlockput>
  end_op();
    800051d4:	bfbfe0ef          	jal	ra,80003dce <end_op>
  return 0;
    800051d8:	4501                	li	a0,0
}
    800051da:	60ea                	ld	ra,152(sp)
    800051dc:	644a                	ld	s0,144(sp)
    800051de:	610d                	addi	sp,sp,160
    800051e0:	8082                	ret
    end_op();
    800051e2:	bedfe0ef          	jal	ra,80003dce <end_op>
    return -1;
    800051e6:	557d                	li	a0,-1
    800051e8:	bfcd                	j	800051da <sys_mknod+0x50>

00000000800051ea <sys_chdir>:

uint64
sys_chdir(void)
{
    800051ea:	7135                	addi	sp,sp,-160
    800051ec:	ed06                	sd	ra,152(sp)
    800051ee:	e922                	sd	s0,144(sp)
    800051f0:	e526                	sd	s1,136(sp)
    800051f2:	e14a                	sd	s2,128(sp)
    800051f4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051f6:	e0cfc0ef          	jal	ra,80001802 <myproc>
    800051fa:	892a                	mv	s2,a0
  
  begin_op();
    800051fc:	b65fe0ef          	jal	ra,80003d60 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005200:	08000613          	li	a2,128
    80005204:	f6040593          	addi	a1,s0,-160
    80005208:	4501                	li	a0,0
    8000520a:	f6efd0ef          	jal	ra,80002978 <argstr>
    8000520e:	04054163          	bltz	a0,80005250 <sys_chdir+0x66>
    80005212:	f6040513          	addi	a0,s0,-160
    80005216:	957fe0ef          	jal	ra,80003b6c <namei>
    8000521a:	84aa                	mv	s1,a0
    8000521c:	c915                	beqz	a0,80005250 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000521e:	95afe0ef          	jal	ra,80003378 <ilock>
  if(ip->type != T_DIR){
    80005222:	04449703          	lh	a4,68(s1)
    80005226:	4785                	li	a5,1
    80005228:	02f71863          	bne	a4,a5,80005258 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000522c:	8526                	mv	a0,s1
    8000522e:	9f4fe0ef          	jal	ra,80003422 <iunlock>
  iput(p->cwd);
    80005232:	15093503          	ld	a0,336(s2)
    80005236:	ac0fe0ef          	jal	ra,800034f6 <iput>
  end_op();
    8000523a:	b95fe0ef          	jal	ra,80003dce <end_op>
  p->cwd = ip;
    8000523e:	14993823          	sd	s1,336(s2)
  return 0;
    80005242:	4501                	li	a0,0
}
    80005244:	60ea                	ld	ra,152(sp)
    80005246:	644a                	ld	s0,144(sp)
    80005248:	64aa                	ld	s1,136(sp)
    8000524a:	690a                	ld	s2,128(sp)
    8000524c:	610d                	addi	sp,sp,160
    8000524e:	8082                	ret
    end_op();
    80005250:	b7ffe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80005254:	557d                	li	a0,-1
    80005256:	b7fd                	j	80005244 <sys_chdir+0x5a>
    iunlockput(ip);
    80005258:	8526                	mv	a0,s1
    8000525a:	b24fe0ef          	jal	ra,8000357e <iunlockput>
    end_op();
    8000525e:	b71fe0ef          	jal	ra,80003dce <end_op>
    return -1;
    80005262:	557d                	li	a0,-1
    80005264:	b7c5                	j	80005244 <sys_chdir+0x5a>

0000000080005266 <sys_exec>:

uint64
sys_exec(void)
{
    80005266:	7145                	addi	sp,sp,-464
    80005268:	e786                	sd	ra,456(sp)
    8000526a:	e3a2                	sd	s0,448(sp)
    8000526c:	ff26                	sd	s1,440(sp)
    8000526e:	fb4a                	sd	s2,432(sp)
    80005270:	f74e                	sd	s3,424(sp)
    80005272:	f352                	sd	s4,416(sp)
    80005274:	ef56                	sd	s5,408(sp)
    80005276:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005278:	e3840593          	addi	a1,s0,-456
    8000527c:	4505                	li	a0,1
    8000527e:	edefd0ef          	jal	ra,8000295c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005282:	08000613          	li	a2,128
    80005286:	f4040593          	addi	a1,s0,-192
    8000528a:	4501                	li	a0,0
    8000528c:	eecfd0ef          	jal	ra,80002978 <argstr>
    80005290:	87aa                	mv	a5,a0
    return -1;
    80005292:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005294:	0a07c563          	bltz	a5,8000533e <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80005298:	10000613          	li	a2,256
    8000529c:	4581                	li	a1,0
    8000529e:	e4040513          	addi	a0,s0,-448
    800052a2:	99dfb0ef          	jal	ra,80000c3e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052a6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800052aa:	89a6                	mv	s3,s1
    800052ac:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800052ae:	02000a13          	li	s4,32
    800052b2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052b6:	00391513          	slli	a0,s2,0x3
    800052ba:	e3040593          	addi	a1,s0,-464
    800052be:	e3843783          	ld	a5,-456(s0)
    800052c2:	953e                	add	a0,a0,a5
    800052c4:	df2fd0ef          	jal	ra,800028b6 <fetchaddr>
    800052c8:	02054663          	bltz	a0,800052f4 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800052cc:	e3043783          	ld	a5,-464(s0)
    800052d0:	cf8d                	beqz	a5,8000530a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052d2:	fc8fb0ef          	jal	ra,80000a9a <kalloc>
    800052d6:	85aa                	mv	a1,a0
    800052d8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052dc:	cd01                	beqz	a0,800052f4 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052de:	6605                	lui	a2,0x1
    800052e0:	e3043503          	ld	a0,-464(s0)
    800052e4:	e1cfd0ef          	jal	ra,80002900 <fetchstr>
    800052e8:	00054663          	bltz	a0,800052f4 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800052ec:	0905                	addi	s2,s2,1
    800052ee:	09a1                	addi	s3,s3,8
    800052f0:	fd4911e3          	bne	s2,s4,800052b2 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052f4:	f4040913          	addi	s2,s0,-192
    800052f8:	6088                	ld	a0,0(s1)
    800052fa:	c129                	beqz	a0,8000533c <sys_exec+0xd6>
    kfree(argv[i]);
    800052fc:	ebcfb0ef          	jal	ra,800009b8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005300:	04a1                	addi	s1,s1,8
    80005302:	ff249be3          	bne	s1,s2,800052f8 <sys_exec+0x92>
  return -1;
    80005306:	557d                	li	a0,-1
    80005308:	a81d                	j	8000533e <sys_exec+0xd8>
      argv[i] = 0;
    8000530a:	0a8e                	slli	s5,s5,0x3
    8000530c:	fc0a8793          	addi	a5,s5,-64
    80005310:	00878ab3          	add	s5,a5,s0
    80005314:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005318:	e4040593          	addi	a1,s0,-448
    8000531c:	f4040513          	addi	a0,s0,-192
    80005320:	bf6ff0ef          	jal	ra,80004716 <kexec>
    80005324:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005326:	f4040993          	addi	s3,s0,-192
    8000532a:	6088                	ld	a0,0(s1)
    8000532c:	c511                	beqz	a0,80005338 <sys_exec+0xd2>
    kfree(argv[i]);
    8000532e:	e8afb0ef          	jal	ra,800009b8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005332:	04a1                	addi	s1,s1,8
    80005334:	ff349be3          	bne	s1,s3,8000532a <sys_exec+0xc4>
  return ret;
    80005338:	854a                	mv	a0,s2
    8000533a:	a011                	j	8000533e <sys_exec+0xd8>
  return -1;
    8000533c:	557d                	li	a0,-1
}
    8000533e:	60be                	ld	ra,456(sp)
    80005340:	641e                	ld	s0,448(sp)
    80005342:	74fa                	ld	s1,440(sp)
    80005344:	795a                	ld	s2,432(sp)
    80005346:	79ba                	ld	s3,424(sp)
    80005348:	7a1a                	ld	s4,416(sp)
    8000534a:	6afa                	ld	s5,408(sp)
    8000534c:	6179                	addi	sp,sp,464
    8000534e:	8082                	ret

0000000080005350 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005350:	7139                	addi	sp,sp,-64
    80005352:	fc06                	sd	ra,56(sp)
    80005354:	f822                	sd	s0,48(sp)
    80005356:	f426                	sd	s1,40(sp)
    80005358:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000535a:	ca8fc0ef          	jal	ra,80001802 <myproc>
    8000535e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005360:	fd840593          	addi	a1,s0,-40
    80005364:	4501                	li	a0,0
    80005366:	df6fd0ef          	jal	ra,8000295c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000536a:	fc840593          	addi	a1,s0,-56
    8000536e:	fd040513          	addi	a0,s0,-48
    80005372:	8c4ff0ef          	jal	ra,80004436 <pipealloc>
    return -1;
    80005376:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005378:	0a054463          	bltz	a0,80005420 <sys_pipe+0xd0>
  fd0 = -1;
    8000537c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005380:	fd043503          	ld	a0,-48(s0)
    80005384:	f3cff0ef          	jal	ra,80004ac0 <fdalloc>
    80005388:	fca42223          	sw	a0,-60(s0)
    8000538c:	08054163          	bltz	a0,8000540e <sys_pipe+0xbe>
    80005390:	fc843503          	ld	a0,-56(s0)
    80005394:	f2cff0ef          	jal	ra,80004ac0 <fdalloc>
    80005398:	fca42023          	sw	a0,-64(s0)
    8000539c:	06054063          	bltz	a0,800053fc <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053a0:	4691                	li	a3,4
    800053a2:	fc440613          	addi	a2,s0,-60
    800053a6:	fd843583          	ld	a1,-40(s0)
    800053aa:	68a8                	ld	a0,80(s1)
    800053ac:	9a4fc0ef          	jal	ra,80001550 <copyout>
    800053b0:	00054e63          	bltz	a0,800053cc <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053b4:	4691                	li	a3,4
    800053b6:	fc040613          	addi	a2,s0,-64
    800053ba:	fd843583          	ld	a1,-40(s0)
    800053be:	0591                	addi	a1,a1,4
    800053c0:	68a8                	ld	a0,80(s1)
    800053c2:	98efc0ef          	jal	ra,80001550 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053c6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053c8:	04055c63          	bgez	a0,80005420 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053cc:	fc442783          	lw	a5,-60(s0)
    800053d0:	07e9                	addi	a5,a5,26
    800053d2:	078e                	slli	a5,a5,0x3
    800053d4:	97a6                	add	a5,a5,s1
    800053d6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053da:	fc042783          	lw	a5,-64(s0)
    800053de:	07e9                	addi	a5,a5,26
    800053e0:	078e                	slli	a5,a5,0x3
    800053e2:	94be                	add	s1,s1,a5
    800053e4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053e8:	fd043503          	ld	a0,-48(s0)
    800053ec:	d7ffe0ef          	jal	ra,8000416a <fileclose>
    fileclose(wf);
    800053f0:	fc843503          	ld	a0,-56(s0)
    800053f4:	d77fe0ef          	jal	ra,8000416a <fileclose>
    return -1;
    800053f8:	57fd                	li	a5,-1
    800053fa:	a01d                	j	80005420 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053fc:	fc442783          	lw	a5,-60(s0)
    80005400:	0007c763          	bltz	a5,8000540e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005404:	07e9                	addi	a5,a5,26
    80005406:	078e                	slli	a5,a5,0x3
    80005408:	97a6                	add	a5,a5,s1
    8000540a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000540e:	fd043503          	ld	a0,-48(s0)
    80005412:	d59fe0ef          	jal	ra,8000416a <fileclose>
    fileclose(wf);
    80005416:	fc843503          	ld	a0,-56(s0)
    8000541a:	d51fe0ef          	jal	ra,8000416a <fileclose>
    return -1;
    8000541e:	57fd                	li	a5,-1
}
    80005420:	853e                	mv	a0,a5
    80005422:	70e2                	ld	ra,56(sp)
    80005424:	7442                	ld	s0,48(sp)
    80005426:	74a2                	ld	s1,40(sp)
    80005428:	6121                	addi	sp,sp,64
    8000542a:	8082                	ret
    8000542c:	0000                	unimp
	...

0000000080005430 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005430:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005432:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005434:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005436:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005438:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000543a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000543c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000543e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005440:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005442:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005444:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005446:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005448:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000544a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000544c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000544e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005450:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005452:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005454:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005456:	b70fd0ef          	jal	ra,800027c6 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000545a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000545c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000545e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005460:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005462:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005464:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005466:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005468:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000546a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000546c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000546e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005470:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005472:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005474:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005476:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005478:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000547a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000547c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000547e:	10200073          	sret
	...

000000008000548e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000548e:	1141                	addi	sp,sp,-16
    80005490:	e422                	sd	s0,8(sp)
    80005492:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005494:	0c0007b7          	lui	a5,0xc000
    80005498:	4705                	li	a4,1
    8000549a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000549c:	c3d8                	sw	a4,4(a5)
}
    8000549e:	6422                	ld	s0,8(sp)
    800054a0:	0141                	addi	sp,sp,16
    800054a2:	8082                	ret

00000000800054a4 <plicinithart>:

void
plicinithart(void)
{
    800054a4:	1141                	addi	sp,sp,-16
    800054a6:	e406                	sd	ra,8(sp)
    800054a8:	e022                	sd	s0,0(sp)
    800054aa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054ac:	b2afc0ef          	jal	ra,800017d6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054b0:	0085171b          	slliw	a4,a0,0x8
    800054b4:	0c0027b7          	lui	a5,0xc002
    800054b8:	97ba                	add	a5,a5,a4
    800054ba:	40200713          	li	a4,1026
    800054be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054c2:	00d5151b          	slliw	a0,a0,0xd
    800054c6:	0c2017b7          	lui	a5,0xc201
    800054ca:	97aa                	add	a5,a5,a0
    800054cc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800054d0:	60a2                	ld	ra,8(sp)
    800054d2:	6402                	ld	s0,0(sp)
    800054d4:	0141                	addi	sp,sp,16
    800054d6:	8082                	ret

00000000800054d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054d8:	1141                	addi	sp,sp,-16
    800054da:	e406                	sd	ra,8(sp)
    800054dc:	e022                	sd	s0,0(sp)
    800054de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054e0:	af6fc0ef          	jal	ra,800017d6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054e4:	00d5151b          	slliw	a0,a0,0xd
    800054e8:	0c2017b7          	lui	a5,0xc201
    800054ec:	97aa                	add	a5,a5,a0
  return irq;
}
    800054ee:	43c8                	lw	a0,4(a5)
    800054f0:	60a2                	ld	ra,8(sp)
    800054f2:	6402                	ld	s0,0(sp)
    800054f4:	0141                	addi	sp,sp,16
    800054f6:	8082                	ret

00000000800054f8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054f8:	1101                	addi	sp,sp,-32
    800054fa:	ec06                	sd	ra,24(sp)
    800054fc:	e822                	sd	s0,16(sp)
    800054fe:	e426                	sd	s1,8(sp)
    80005500:	1000                	addi	s0,sp,32
    80005502:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005504:	ad2fc0ef          	jal	ra,800017d6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005508:	00d5151b          	slliw	a0,a0,0xd
    8000550c:	0c2017b7          	lui	a5,0xc201
    80005510:	97aa                	add	a5,a5,a0
    80005512:	c3c4                	sw	s1,4(a5)
}
    80005514:	60e2                	ld	ra,24(sp)
    80005516:	6442                	ld	s0,16(sp)
    80005518:	64a2                	ld	s1,8(sp)
    8000551a:	6105                	addi	sp,sp,32
    8000551c:	8082                	ret

000000008000551e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000551e:	1141                	addi	sp,sp,-16
    80005520:	e406                	sd	ra,8(sp)
    80005522:	e022                	sd	s0,0(sp)
    80005524:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005526:	479d                	li	a5,7
    80005528:	04a7ca63          	blt	a5,a0,8000557c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000552c:	0001c797          	auipc	a5,0x1c
    80005530:	92c78793          	addi	a5,a5,-1748 # 80020e58 <disk>
    80005534:	97aa                	add	a5,a5,a0
    80005536:	0187c783          	lbu	a5,24(a5)
    8000553a:	e7b9                	bnez	a5,80005588 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000553c:	00451693          	slli	a3,a0,0x4
    80005540:	0001c797          	auipc	a5,0x1c
    80005544:	91878793          	addi	a5,a5,-1768 # 80020e58 <disk>
    80005548:	6398                	ld	a4,0(a5)
    8000554a:	9736                	add	a4,a4,a3
    8000554c:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005550:	6398                	ld	a4,0(a5)
    80005552:	9736                	add	a4,a4,a3
    80005554:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005558:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000555c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005560:	97aa                	add	a5,a5,a0
    80005562:	4705                	li	a4,1
    80005564:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005568:	0001c517          	auipc	a0,0x1c
    8000556c:	90850513          	addi	a0,a0,-1784 # 80020e70 <disk+0x18>
    80005570:	92bfc0ef          	jal	ra,80001e9a <wakeup>
}
    80005574:	60a2                	ld	ra,8(sp)
    80005576:	6402                	ld	s0,0(sp)
    80005578:	0141                	addi	sp,sp,16
    8000557a:	8082                	ret
    panic("free_desc 1");
    8000557c:	00002517          	auipc	a0,0x2
    80005580:	1b450513          	addi	a0,a0,436 # 80007730 <syscalls+0x340>
    80005584:	a04fb0ef          	jal	ra,80000788 <panic>
    panic("free_desc 2");
    80005588:	00002517          	auipc	a0,0x2
    8000558c:	1b850513          	addi	a0,a0,440 # 80007740 <syscalls+0x350>
    80005590:	9f8fb0ef          	jal	ra,80000788 <panic>

0000000080005594 <virtio_disk_init>:
{
    80005594:	1101                	addi	sp,sp,-32
    80005596:	ec06                	sd	ra,24(sp)
    80005598:	e822                	sd	s0,16(sp)
    8000559a:	e426                	sd	s1,8(sp)
    8000559c:	e04a                	sd	s2,0(sp)
    8000559e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055a0:	00002597          	auipc	a1,0x2
    800055a4:	1b058593          	addi	a1,a1,432 # 80007750 <syscalls+0x360>
    800055a8:	0001c517          	auipc	a0,0x1c
    800055ac:	9d850513          	addi	a0,a0,-1576 # 80020f80 <disk+0x128>
    800055b0:	d3afb0ef          	jal	ra,80000aea <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055b4:	100017b7          	lui	a5,0x10001
    800055b8:	4398                	lw	a4,0(a5)
    800055ba:	2701                	sext.w	a4,a4
    800055bc:	747277b7          	lui	a5,0x74727
    800055c0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055c4:	12f71f63          	bne	a4,a5,80005702 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055c8:	100017b7          	lui	a5,0x10001
    800055cc:	43dc                	lw	a5,4(a5)
    800055ce:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055d0:	4709                	li	a4,2
    800055d2:	12e79863          	bne	a5,a4,80005702 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055d6:	100017b7          	lui	a5,0x10001
    800055da:	479c                	lw	a5,8(a5)
    800055dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055de:	12e79263          	bne	a5,a4,80005702 <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055e2:	100017b7          	lui	a5,0x10001
    800055e6:	47d8                	lw	a4,12(a5)
    800055e8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055ea:	554d47b7          	lui	a5,0x554d4
    800055ee:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055f2:	10f71863          	bne	a4,a5,80005702 <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f6:	100017b7          	lui	a5,0x10001
    800055fa:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055fe:	4705                	li	a4,1
    80005600:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005602:	470d                	li	a4,3
    80005604:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005606:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005608:	c7ffe6b7          	lui	a3,0xc7ffe
    8000560c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd7c7>
    80005610:	8f75                	and	a4,a4,a3
    80005612:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005614:	472d                	li	a4,11
    80005616:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005618:	5bbc                	lw	a5,112(a5)
    8000561a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000561e:	8ba1                	andi	a5,a5,8
    80005620:	0e078763          	beqz	a5,8000570e <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005624:	100017b7          	lui	a5,0x10001
    80005628:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000562c:	43fc                	lw	a5,68(a5)
    8000562e:	2781                	sext.w	a5,a5
    80005630:	0e079563          	bnez	a5,8000571a <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005634:	100017b7          	lui	a5,0x10001
    80005638:	5bdc                	lw	a5,52(a5)
    8000563a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000563c:	0e078563          	beqz	a5,80005726 <virtio_disk_init+0x192>
  if(max < NUM)
    80005640:	471d                	li	a4,7
    80005642:	0ef77863          	bgeu	a4,a5,80005732 <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80005646:	c54fb0ef          	jal	ra,80000a9a <kalloc>
    8000564a:	0001c497          	auipc	s1,0x1c
    8000564e:	80e48493          	addi	s1,s1,-2034 # 80020e58 <disk>
    80005652:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005654:	c46fb0ef          	jal	ra,80000a9a <kalloc>
    80005658:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000565a:	c40fb0ef          	jal	ra,80000a9a <kalloc>
    8000565e:	87aa                	mv	a5,a0
    80005660:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005662:	6088                	ld	a0,0(s1)
    80005664:	cd69                	beqz	a0,8000573e <virtio_disk_init+0x1aa>
    80005666:	0001b717          	auipc	a4,0x1b
    8000566a:	7fa73703          	ld	a4,2042(a4) # 80020e60 <disk+0x8>
    8000566e:	cb61                	beqz	a4,8000573e <virtio_disk_init+0x1aa>
    80005670:	c7f9                	beqz	a5,8000573e <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80005672:	6605                	lui	a2,0x1
    80005674:	4581                	li	a1,0
    80005676:	dc8fb0ef          	jal	ra,80000c3e <memset>
  memset(disk.avail, 0, PGSIZE);
    8000567a:	0001b497          	auipc	s1,0x1b
    8000567e:	7de48493          	addi	s1,s1,2014 # 80020e58 <disk>
    80005682:	6605                	lui	a2,0x1
    80005684:	4581                	li	a1,0
    80005686:	6488                	ld	a0,8(s1)
    80005688:	db6fb0ef          	jal	ra,80000c3e <memset>
  memset(disk.used, 0, PGSIZE);
    8000568c:	6605                	lui	a2,0x1
    8000568e:	4581                	li	a1,0
    80005690:	6888                	ld	a0,16(s1)
    80005692:	dacfb0ef          	jal	ra,80000c3e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005696:	100017b7          	lui	a5,0x10001
    8000569a:	4721                	li	a4,8
    8000569c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000569e:	4098                	lw	a4,0(s1)
    800056a0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056a4:	40d8                	lw	a4,4(s1)
    800056a6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056aa:	6498                	ld	a4,8(s1)
    800056ac:	0007069b          	sext.w	a3,a4
    800056b0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056b4:	9701                	srai	a4,a4,0x20
    800056b6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800056ba:	6898                	ld	a4,16(s1)
    800056bc:	0007069b          	sext.w	a3,a4
    800056c0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056c4:	9701                	srai	a4,a4,0x20
    800056c6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056ca:	4705                	li	a4,1
    800056cc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800056ce:	00e48c23          	sb	a4,24(s1)
    800056d2:	00e48ca3          	sb	a4,25(s1)
    800056d6:	00e48d23          	sb	a4,26(s1)
    800056da:	00e48da3          	sb	a4,27(s1)
    800056de:	00e48e23          	sb	a4,28(s1)
    800056e2:	00e48ea3          	sb	a4,29(s1)
    800056e6:	00e48f23          	sb	a4,30(s1)
    800056ea:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056ee:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056f2:	0727a823          	sw	s2,112(a5)
}
    800056f6:	60e2                	ld	ra,24(sp)
    800056f8:	6442                	ld	s0,16(sp)
    800056fa:	64a2                	ld	s1,8(sp)
    800056fc:	6902                	ld	s2,0(sp)
    800056fe:	6105                	addi	sp,sp,32
    80005700:	8082                	ret
    panic("could not find virtio disk");
    80005702:	00002517          	auipc	a0,0x2
    80005706:	05e50513          	addi	a0,a0,94 # 80007760 <syscalls+0x370>
    8000570a:	87efb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000570e:	00002517          	auipc	a0,0x2
    80005712:	07250513          	addi	a0,a0,114 # 80007780 <syscalls+0x390>
    80005716:	872fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk should not be ready");
    8000571a:	00002517          	auipc	a0,0x2
    8000571e:	08650513          	addi	a0,a0,134 # 800077a0 <syscalls+0x3b0>
    80005722:	866fb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk has no queue 0");
    80005726:	00002517          	auipc	a0,0x2
    8000572a:	09a50513          	addi	a0,a0,154 # 800077c0 <syscalls+0x3d0>
    8000572e:	85afb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk max queue too short");
    80005732:	00002517          	auipc	a0,0x2
    80005736:	0ae50513          	addi	a0,a0,174 # 800077e0 <syscalls+0x3f0>
    8000573a:	84efb0ef          	jal	ra,80000788 <panic>
    panic("virtio disk kalloc");
    8000573e:	00002517          	auipc	a0,0x2
    80005742:	0c250513          	addi	a0,a0,194 # 80007800 <syscalls+0x410>
    80005746:	842fb0ef          	jal	ra,80000788 <panic>

000000008000574a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000574a:	7119                	addi	sp,sp,-128
    8000574c:	fc86                	sd	ra,120(sp)
    8000574e:	f8a2                	sd	s0,112(sp)
    80005750:	f4a6                	sd	s1,104(sp)
    80005752:	f0ca                	sd	s2,96(sp)
    80005754:	ecce                	sd	s3,88(sp)
    80005756:	e8d2                	sd	s4,80(sp)
    80005758:	e4d6                	sd	s5,72(sp)
    8000575a:	e0da                	sd	s6,64(sp)
    8000575c:	fc5e                	sd	s7,56(sp)
    8000575e:	f862                	sd	s8,48(sp)
    80005760:	f466                	sd	s9,40(sp)
    80005762:	f06a                	sd	s10,32(sp)
    80005764:	ec6e                	sd	s11,24(sp)
    80005766:	0100                	addi	s0,sp,128
    80005768:	8aaa                	mv	s5,a0
    8000576a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000576c:	00c52d03          	lw	s10,12(a0)
    80005770:	001d1d1b          	slliw	s10,s10,0x1
    80005774:	1d02                	slli	s10,s10,0x20
    80005776:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000577a:	0001c517          	auipc	a0,0x1c
    8000577e:	80650513          	addi	a0,a0,-2042 # 80020f80 <disk+0x128>
    80005782:	be8fb0ef          	jal	ra,80000b6a <acquire>
  for(int i = 0; i < 3; i++){
    80005786:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005788:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000578a:	0001bb97          	auipc	s7,0x1b
    8000578e:	6ceb8b93          	addi	s7,s7,1742 # 80020e58 <disk>
  for(int i = 0; i < 3; i++){
    80005792:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005794:	0001bc97          	auipc	s9,0x1b
    80005798:	7ecc8c93          	addi	s9,s9,2028 # 80020f80 <disk+0x128>
    8000579c:	a8a9                	j	800057f6 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    8000579e:	00fb8733          	add	a4,s7,a5
    800057a2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057a6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057a8:	0207c563          	bltz	a5,800057d2 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800057ac:	2905                	addiw	s2,s2,1
    800057ae:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057b0:	05690863          	beq	s2,s6,80005800 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800057b4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057b6:	0001b717          	auipc	a4,0x1b
    800057ba:	6a270713          	addi	a4,a4,1698 # 80020e58 <disk>
    800057be:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057c0:	01874683          	lbu	a3,24(a4)
    800057c4:	fee9                	bnez	a3,8000579e <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800057c6:	2785                	addiw	a5,a5,1
    800057c8:	0705                	addi	a4,a4,1
    800057ca:	fe979be3          	bne	a5,s1,800057c0 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800057ce:	57fd                	li	a5,-1
    800057d0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057d2:	01205b63          	blez	s2,800057e8 <virtio_disk_rw+0x9e>
    800057d6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800057d8:	000a2503          	lw	a0,0(s4)
    800057dc:	d43ff0ef          	jal	ra,8000551e <free_desc>
      for(int j = 0; j < i; j++)
    800057e0:	2d85                	addiw	s11,s11,1
    800057e2:	0a11                	addi	s4,s4,4
    800057e4:	ff2d9ae3          	bne	s11,s2,800057d8 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057e8:	85e6                	mv	a1,s9
    800057ea:	0001b517          	auipc	a0,0x1b
    800057ee:	68650513          	addi	a0,a0,1670 # 80020e70 <disk+0x18>
    800057f2:	e5cfc0ef          	jal	ra,80001e4e <sleep>
  for(int i = 0; i < 3; i++){
    800057f6:	f8040a13          	addi	s4,s0,-128
{
    800057fa:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800057fc:	894e                	mv	s2,s3
    800057fe:	bf5d                	j	800057b4 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005800:	f8042503          	lw	a0,-128(s0)
    80005804:	00a50713          	addi	a4,a0,10
    80005808:	0712                	slli	a4,a4,0x4

  if(write)
    8000580a:	0001b797          	auipc	a5,0x1b
    8000580e:	64e78793          	addi	a5,a5,1614 # 80020e58 <disk>
    80005812:	00e786b3          	add	a3,a5,a4
    80005816:	01803633          	snez	a2,s8
    8000581a:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000581c:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005820:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005824:	f6070613          	addi	a2,a4,-160
    80005828:	6394                	ld	a3,0(a5)
    8000582a:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000582c:	00870593          	addi	a1,a4,8
    80005830:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005832:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005834:	0007b803          	ld	a6,0(a5)
    80005838:	9642                	add	a2,a2,a6
    8000583a:	46c1                	li	a3,16
    8000583c:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000583e:	4585                	li	a1,1
    80005840:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005844:	f8442683          	lw	a3,-124(s0)
    80005848:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000584c:	0692                	slli	a3,a3,0x4
    8000584e:	9836                	add	a6,a6,a3
    80005850:	058a8613          	addi	a2,s5,88
    80005854:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005858:	0007b803          	ld	a6,0(a5)
    8000585c:	96c2                	add	a3,a3,a6
    8000585e:	40000613          	li	a2,1024
    80005862:	c690                	sw	a2,8(a3)
  if(write)
    80005864:	001c3613          	seqz	a2,s8
    80005868:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000586c:	00166613          	ori	a2,a2,1
    80005870:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005874:	f8842603          	lw	a2,-120(s0)
    80005878:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000587c:	00250693          	addi	a3,a0,2
    80005880:	0692                	slli	a3,a3,0x4
    80005882:	96be                	add	a3,a3,a5
    80005884:	58fd                	li	a7,-1
    80005886:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000588a:	0612                	slli	a2,a2,0x4
    8000588c:	9832                	add	a6,a6,a2
    8000588e:	f9070713          	addi	a4,a4,-112
    80005892:	973e                	add	a4,a4,a5
    80005894:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005898:	6398                	ld	a4,0(a5)
    8000589a:	9732                	add	a4,a4,a2
    8000589c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000589e:	4609                	li	a2,2
    800058a0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800058a4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058a8:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800058ac:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058b0:	6794                	ld	a3,8(a5)
    800058b2:	0026d703          	lhu	a4,2(a3)
    800058b6:	8b1d                	andi	a4,a4,7
    800058b8:	0706                	slli	a4,a4,0x1
    800058ba:	96ba                	add	a3,a3,a4
    800058bc:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800058c0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058c4:	6798                	ld	a4,8(a5)
    800058c6:	00275783          	lhu	a5,2(a4)
    800058ca:	2785                	addiw	a5,a5,1
    800058cc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058d0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058d4:	100017b7          	lui	a5,0x10001
    800058d8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058dc:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800058e0:	0001b917          	auipc	s2,0x1b
    800058e4:	6a090913          	addi	s2,s2,1696 # 80020f80 <disk+0x128>
  while(b->disk == 1) {
    800058e8:	4485                	li	s1,1
    800058ea:	00b79a63          	bne	a5,a1,800058fe <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800058ee:	85ca                	mv	a1,s2
    800058f0:	8556                	mv	a0,s5
    800058f2:	d5cfc0ef          	jal	ra,80001e4e <sleep>
  while(b->disk == 1) {
    800058f6:	004aa783          	lw	a5,4(s5)
    800058fa:	fe978ae3          	beq	a5,s1,800058ee <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800058fe:	f8042903          	lw	s2,-128(s0)
    80005902:	00290713          	addi	a4,s2,2
    80005906:	0712                	slli	a4,a4,0x4
    80005908:	0001b797          	auipc	a5,0x1b
    8000590c:	55078793          	addi	a5,a5,1360 # 80020e58 <disk>
    80005910:	97ba                	add	a5,a5,a4
    80005912:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005916:	0001b997          	auipc	s3,0x1b
    8000591a:	54298993          	addi	s3,s3,1346 # 80020e58 <disk>
    8000591e:	00491713          	slli	a4,s2,0x4
    80005922:	0009b783          	ld	a5,0(s3)
    80005926:	97ba                	add	a5,a5,a4
    80005928:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000592c:	854a                	mv	a0,s2
    8000592e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005932:	bedff0ef          	jal	ra,8000551e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005936:	8885                	andi	s1,s1,1
    80005938:	f0fd                	bnez	s1,8000591e <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000593a:	0001b517          	auipc	a0,0x1b
    8000593e:	64650513          	addi	a0,a0,1606 # 80020f80 <disk+0x128>
    80005942:	ac0fb0ef          	jal	ra,80000c02 <release>
}
    80005946:	70e6                	ld	ra,120(sp)
    80005948:	7446                	ld	s0,112(sp)
    8000594a:	74a6                	ld	s1,104(sp)
    8000594c:	7906                	ld	s2,96(sp)
    8000594e:	69e6                	ld	s3,88(sp)
    80005950:	6a46                	ld	s4,80(sp)
    80005952:	6aa6                	ld	s5,72(sp)
    80005954:	6b06                	ld	s6,64(sp)
    80005956:	7be2                	ld	s7,56(sp)
    80005958:	7c42                	ld	s8,48(sp)
    8000595a:	7ca2                	ld	s9,40(sp)
    8000595c:	7d02                	ld	s10,32(sp)
    8000595e:	6de2                	ld	s11,24(sp)
    80005960:	6109                	addi	sp,sp,128
    80005962:	8082                	ret

0000000080005964 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005964:	1101                	addi	sp,sp,-32
    80005966:	ec06                	sd	ra,24(sp)
    80005968:	e822                	sd	s0,16(sp)
    8000596a:	e426                	sd	s1,8(sp)
    8000596c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000596e:	0001b497          	auipc	s1,0x1b
    80005972:	4ea48493          	addi	s1,s1,1258 # 80020e58 <disk>
    80005976:	0001b517          	auipc	a0,0x1b
    8000597a:	60a50513          	addi	a0,a0,1546 # 80020f80 <disk+0x128>
    8000597e:	9ecfb0ef          	jal	ra,80000b6a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005982:	10001737          	lui	a4,0x10001
    80005986:	533c                	lw	a5,96(a4)
    80005988:	8b8d                	andi	a5,a5,3
    8000598a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000598c:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005990:	689c                	ld	a5,16(s1)
    80005992:	0204d703          	lhu	a4,32(s1)
    80005996:	0027d783          	lhu	a5,2(a5)
    8000599a:	04f70663          	beq	a4,a5,800059e6 <virtio_disk_intr+0x82>
    __sync_synchronize();
    8000599e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059a2:	6898                	ld	a4,16(s1)
    800059a4:	0204d783          	lhu	a5,32(s1)
    800059a8:	8b9d                	andi	a5,a5,7
    800059aa:	078e                	slli	a5,a5,0x3
    800059ac:	97ba                	add	a5,a5,a4
    800059ae:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059b0:	00278713          	addi	a4,a5,2
    800059b4:	0712                	slli	a4,a4,0x4
    800059b6:	9726                	add	a4,a4,s1
    800059b8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800059bc:	e321                	bnez	a4,800059fc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800059be:	0789                	addi	a5,a5,2
    800059c0:	0792                	slli	a5,a5,0x4
    800059c2:	97a6                	add	a5,a5,s1
    800059c4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059c6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059ca:	cd0fc0ef          	jal	ra,80001e9a <wakeup>

    disk.used_idx += 1;
    800059ce:	0204d783          	lhu	a5,32(s1)
    800059d2:	2785                	addiw	a5,a5,1
    800059d4:	17c2                	slli	a5,a5,0x30
    800059d6:	93c1                	srli	a5,a5,0x30
    800059d8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059dc:	6898                	ld	a4,16(s1)
    800059de:	00275703          	lhu	a4,2(a4)
    800059e2:	faf71ee3          	bne	a4,a5,8000599e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800059e6:	0001b517          	auipc	a0,0x1b
    800059ea:	59a50513          	addi	a0,a0,1434 # 80020f80 <disk+0x128>
    800059ee:	a14fb0ef          	jal	ra,80000c02 <release>
}
    800059f2:	60e2                	ld	ra,24(sp)
    800059f4:	6442                	ld	s0,16(sp)
    800059f6:	64a2                	ld	s1,8(sp)
    800059f8:	6105                	addi	sp,sp,32
    800059fa:	8082                	ret
      panic("virtio_disk_intr status");
    800059fc:	00002517          	auipc	a0,0x2
    80005a00:	e1c50513          	addi	a0,a0,-484 # 80007818 <syscalls+0x428>
    80005a04:	d85fa0ef          	jal	ra,80000788 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
