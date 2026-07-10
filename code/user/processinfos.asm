
user/_processinfos:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
   e:	81010113          	addi	sp,sp,-2032
    struct proc_info ptable[64];
    int count;

    printf("Buscando processos na fila de pronto...\n");
  12:	00001517          	auipc	a0,0x1
  16:	8de50513          	addi	a0,a0,-1826 # 8f0 <malloc+0xe6>
  1a:	73c000ef          	jal	ra,756 <printf>

    count = getpinfo(ptable);
  1e:	77fd                	lui	a5,0xfffff
  20:	7d078793          	addi	a5,a5,2000 # fffffffffffff7d0 <base+0xffffffffffffe7c0>
  24:	00f40533          	add	a0,s0,a5
  28:	3a2000ef          	jal	ra,3ca <getpinfo>

    if(count < 0){
  2c:	04054c63          	bltz	a0,84 <main+0x84>
  30:	892a                	mv	s2,a0
        printf("Erro na syscall\n");
        exit(1);
    }

    printf("Encontrados %d processos prontos:\n", count);
  32:	85aa                	mv	a1,a0
  34:	00001517          	auipc	a0,0x1
  38:	90450513          	addi	a0,a0,-1788 # 938 <malloc+0x12e>
  3c:	71a000ef          	jal	ra,756 <printf>
    for(int i=0; i<count; i++){
  40:	03205f63          	blez	s2,7e <main+0x7e>
  44:	77fd                	lui	a5,0xfffff
  46:	7e078793          	addi	a5,a5,2016 # fffffffffffff7e0 <base+0xffffffffffffe7d0>
  4a:	00f404b3          	add	s1,s0,a5
  4e:	397d                	addiw	s2,s2,-1
  50:	02091793          	slli	a5,s2,0x20
  54:	01b7d913          	srli	s2,a5,0x1b
  58:	80040793          	addi	a5,s0,-2048
  5c:	993e                	add	s2,s2,a5
        printf("PID: %d | Mem: %ld bytes | Nome: %s\n", ptable[i].pid, ptable[i].size, ptable[i].name);
  5e:	00001997          	auipc	s3,0x1
  62:	90298993          	addi	s3,s3,-1790 # 960 <malloc+0x156>
  66:	86a6                	mv	a3,s1
  68:	ff84b603          	ld	a2,-8(s1)
  6c:	ff04a583          	lw	a1,-16(s1)
  70:	854e                	mv	a0,s3
  72:	6e4000ef          	jal	ra,756 <printf>
    for(int i=0; i<count; i++){
  76:	02048493          	addi	s1,s1,32
  7a:	ff2496e3          	bne	s1,s2,66 <main+0x66>
    }
    exit(0);
  7e:	4501                	li	a0,0
  80:	2aa000ef          	jal	ra,32a <exit>
        printf("Erro na syscall\n");
  84:	00001517          	auipc	a0,0x1
  88:	89c50513          	addi	a0,a0,-1892 # 920 <malloc+0x116>
  8c:	6ca000ef          	jal	ra,756 <printf>
        exit(1);
  90:	4505                	li	a0,1
  92:	298000ef          	jal	ra,32a <exit>

0000000000000096 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  96:	1141                	addi	sp,sp,-16
  98:	e406                	sd	ra,8(sp)
  9a:	e022                	sd	s0,0(sp)
  9c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  9e:	f63ff0ef          	jal	ra,0 <main>
  exit(r);
  a2:	288000ef          	jal	ra,32a <exit>

00000000000000a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ac:	87aa                	mv	a5,a0
  ae:	0585                	addi	a1,a1,1
  b0:	0785                	addi	a5,a5,1
  b2:	fff5c703          	lbu	a4,-1(a1)
  b6:	fee78fa3          	sb	a4,-1(a5)
  ba:	fb75                	bnez	a4,ae <strcpy+0x8>
    ;
  return os;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb91                	beqz	a5,e0 <strcmp+0x1e>
  ce:	0005c703          	lbu	a4,0(a1)
  d2:	00f71763          	bne	a4,a5,e0 <strcmp+0x1e>
    p++, q++;
  d6:	0505                	addi	a0,a0,1
  d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  da:	00054783          	lbu	a5,0(a0)
  de:	fbe5                	bnez	a5,ce <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e0:	0005c503          	lbu	a0,0(a1)
}
  e4:	40a7853b          	subw	a0,a5,a0
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strlen>:

uint
strlen(const char *s)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cf91                	beqz	a5,114 <strlen+0x26>
  fa:	0505                	addi	a0,a0,1
  fc:	87aa                	mv	a5,a0
  fe:	4685                	li	a3,1
 100:	9e89                	subw	a3,a3,a0
 102:	00f6853b          	addw	a0,a3,a5
 106:	0785                	addi	a5,a5,1
 108:	fff7c703          	lbu	a4,-1(a5)
 10c:	fb7d                	bnez	a4,102 <strlen+0x14>
    ;
  return n;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  for(n = 0; s[n]; n++)
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strlen+0x20>

0000000000000118 <memset>:

void*
memset(void *dst, int c, uint n)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11e:	ca19                	beqz	a2,134 <memset+0x1c>
 120:	87aa                	mv	a5,a0
 122:	1602                	slli	a2,a2,0x20
 124:	9201                	srli	a2,a2,0x20
 126:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12e:	0785                	addi	a5,a5,1
 130:	fee79de3          	bne	a5,a4,12a <memset+0x12>
  }
  return dst;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strchr>:

char*
strchr(const char *s, char c)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 140:	00054783          	lbu	a5,0(a0)
 144:	cb99                	beqz	a5,15a <strchr+0x20>
    if(*s == c)
 146:	00f58763          	beq	a1,a5,154 <strchr+0x1a>
  for(; *s; s++)
 14a:	0505                	addi	a0,a0,1
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbfd                	bnez	a5,146 <strchr+0xc>
      return (char*)s;
  return 0;
 152:	4501                	li	a0,0
}
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret
  return 0;
 15a:	4501                	li	a0,0
 15c:	bfe5                	j	154 <strchr+0x1a>

000000000000015e <gets>:

char*
gets(char *buf, int max)
{
 15e:	711d                	addi	sp,sp,-96
 160:	ec86                	sd	ra,88(sp)
 162:	e8a2                	sd	s0,80(sp)
 164:	e4a6                	sd	s1,72(sp)
 166:	e0ca                	sd	s2,64(sp)
 168:	fc4e                	sd	s3,56(sp)
 16a:	f852                	sd	s4,48(sp)
 16c:	f456                	sd	s5,40(sp)
 16e:	f05a                	sd	s6,32(sp)
 170:	ec5e                	sd	s7,24(sp)
 172:	1080                	addi	s0,sp,96
 174:	8baa                	mv	s7,a0
 176:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 178:	892a                	mv	s2,a0
 17a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17c:	4aa9                	li	s5,10
 17e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 180:	89a6                	mv	s3,s1
 182:	2485                	addiw	s1,s1,1
 184:	0344d663          	bge	s1,s4,1b0 <gets+0x52>
    cc = read(0, &c, 1);
 188:	4605                	li	a2,1
 18a:	faf40593          	addi	a1,s0,-81
 18e:	4501                	li	a0,0
 190:	1b2000ef          	jal	ra,342 <read>
    if(cc < 1)
 194:	00a05e63          	blez	a0,1b0 <gets+0x52>
    buf[i++] = c;
 198:	faf44783          	lbu	a5,-81(s0)
 19c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a0:	01578763          	beq	a5,s5,1ae <gets+0x50>
 1a4:	0905                	addi	s2,s2,1
 1a6:	fd679de3          	bne	a5,s6,180 <gets+0x22>
  for(i=0; i+1 < max; ){
 1aa:	89a6                	mv	s3,s1
 1ac:	a011                	j	1b0 <gets+0x52>
 1ae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b0:	99de                	add	s3,s3,s7
 1b2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b6:	855e                	mv	a0,s7
 1b8:	60e6                	ld	ra,88(sp)
 1ba:	6446                	ld	s0,80(sp)
 1bc:	64a6                	ld	s1,72(sp)
 1be:	6906                	ld	s2,64(sp)
 1c0:	79e2                	ld	s3,56(sp)
 1c2:	7a42                	ld	s4,48(sp)
 1c4:	7aa2                	ld	s5,40(sp)
 1c6:	7b02                	ld	s6,32(sp)
 1c8:	6be2                	ld	s7,24(sp)
 1ca:	6125                	addi	sp,sp,96
 1cc:	8082                	ret

00000000000001ce <stat>:

int
stat(const char *n, struct stat *st)
{
 1ce:	1101                	addi	sp,sp,-32
 1d0:	ec06                	sd	ra,24(sp)
 1d2:	e822                	sd	s0,16(sp)
 1d4:	e426                	sd	s1,8(sp)
 1d6:	e04a                	sd	s2,0(sp)
 1d8:	1000                	addi	s0,sp,32
 1da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1dc:	4581                	li	a1,0
 1de:	18c000ef          	jal	ra,36a <open>
  if(fd < 0)
 1e2:	02054163          	bltz	a0,204 <stat+0x36>
 1e6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e8:	85ca                	mv	a1,s2
 1ea:	198000ef          	jal	ra,382 <fstat>
 1ee:	892a                	mv	s2,a0
  close(fd);
 1f0:	8526                	mv	a0,s1
 1f2:	160000ef          	jal	ra,352 <close>
  return r;
}
 1f6:	854a                	mv	a0,s2
 1f8:	60e2                	ld	ra,24(sp)
 1fa:	6442                	ld	s0,16(sp)
 1fc:	64a2                	ld	s1,8(sp)
 1fe:	6902                	ld	s2,0(sp)
 200:	6105                	addi	sp,sp,32
 202:	8082                	ret
    return -1;
 204:	597d                	li	s2,-1
 206:	bfc5                	j	1f6 <stat+0x28>

0000000000000208 <atoi>:

int
atoi(const char *s)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 20e:	00054683          	lbu	a3,0(a0)
 212:	fd06879b          	addiw	a5,a3,-48
 216:	0ff7f793          	zext.b	a5,a5
 21a:	4625                	li	a2,9
 21c:	02f66863          	bltu	a2,a5,24c <atoi+0x44>
 220:	872a                	mv	a4,a0
  n = 0;
 222:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 224:	0705                	addi	a4,a4,1
 226:	0025179b          	slliw	a5,a0,0x2
 22a:	9fa9                	addw	a5,a5,a0
 22c:	0017979b          	slliw	a5,a5,0x1
 230:	9fb5                	addw	a5,a5,a3
 232:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 236:	00074683          	lbu	a3,0(a4)
 23a:	fd06879b          	addiw	a5,a3,-48
 23e:	0ff7f793          	zext.b	a5,a5
 242:	fef671e3          	bgeu	a2,a5,224 <atoi+0x1c>
  return n;
}
 246:	6422                	ld	s0,8(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret
  n = 0;
 24c:	4501                	li	a0,0
 24e:	bfe5                	j	246 <atoi+0x3e>

0000000000000250 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 256:	02b57463          	bgeu	a0,a1,27e <memmove+0x2e>
    while(n-- > 0)
 25a:	00c05f63          	blez	a2,278 <memmove+0x28>
 25e:	1602                	slli	a2,a2,0x20
 260:	9201                	srli	a2,a2,0x20
 262:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 266:	872a                	mv	a4,a0
      *dst++ = *src++;
 268:	0585                	addi	a1,a1,1
 26a:	0705                	addi	a4,a4,1
 26c:	fff5c683          	lbu	a3,-1(a1)
 270:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 274:	fee79ae3          	bne	a5,a4,268 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
    dst += n;
 27e:	00c50733          	add	a4,a0,a2
    src += n;
 282:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 284:	fec05ae3          	blez	a2,278 <memmove+0x28>
 288:	fff6079b          	addiw	a5,a2,-1
 28c:	1782                	slli	a5,a5,0x20
 28e:	9381                	srli	a5,a5,0x20
 290:	fff7c793          	not	a5,a5
 294:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 296:	15fd                	addi	a1,a1,-1
 298:	177d                	addi	a4,a4,-1
 29a:	0005c683          	lbu	a3,0(a1)
 29e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2a2:	fee79ae3          	bne	a5,a4,296 <memmove+0x46>
 2a6:	bfc9                	j	278 <memmove+0x28>

00000000000002a8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ae:	ca05                	beqz	a2,2de <memcmp+0x36>
 2b0:	fff6069b          	addiw	a3,a2,-1
 2b4:	1682                	slli	a3,a3,0x20
 2b6:	9281                	srli	a3,a3,0x20
 2b8:	0685                	addi	a3,a3,1
 2ba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	0005c703          	lbu	a4,0(a1)
 2c4:	00e79863          	bne	a5,a4,2d4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c8:	0505                	addi	a0,a0,1
    p2++;
 2ca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2cc:	fed518e3          	bne	a0,a3,2bc <memcmp+0x14>
  }
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	a019                	j	2d8 <memcmp+0x30>
      return *p1 - *p2;
 2d4:	40e7853b          	subw	a0,a5,a4
}
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
  return 0;
 2de:	4501                	li	a0,0
 2e0:	bfe5                	j	2d8 <memcmp+0x30>

00000000000002e2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e406                	sd	ra,8(sp)
 2e6:	e022                	sd	s0,0(sp)
 2e8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ea:	f67ff0ef          	jal	ra,250 <memmove>
}
 2ee:	60a2                	ld	ra,8(sp)
 2f0:	6402                	ld	s0,0(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <sbrk>:

char *
sbrk(int n) {
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e406                	sd	ra,8(sp)
 2fa:	e022                	sd	s0,0(sp)
 2fc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2fe:	4585                	li	a1,1
 300:	0b2000ef          	jal	ra,3b2 <sys_sbrk>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <sbrklazy>:

char *
sbrklazy(int n) {
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 314:	4589                	li	a1,2
 316:	09c000ef          	jal	ra,3b2 <sys_sbrk>
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 322:	4885                	li	a7,1
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <exit>:
.global exit
exit:
 li a7, SYS_exit
 32a:	4889                	li	a7,2
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <wait>:
.global wait
wait:
 li a7, SYS_wait
 332:	488d                	li	a7,3
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33a:	4891                	li	a7,4
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <read>:
.global read
read:
 li a7, SYS_read
 342:	4895                	li	a7,5
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <write>:
.global write
write:
 li a7, SYS_write
 34a:	48c1                	li	a7,16
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <close>:
.global close
close:
 li a7, SYS_close
 352:	48d5                	li	a7,21
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <kill>:
.global kill
kill:
 li a7, SYS_kill
 35a:	4899                	li	a7,6
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <exec>:
.global exec
exec:
 li a7, SYS_exec
 362:	489d                	li	a7,7
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <open>:
.global open
open:
 li a7, SYS_open
 36a:	48bd                	li	a7,15
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 372:	48c5                	li	a7,17
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37a:	48c9                	li	a7,18
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 382:	48a1                	li	a7,8
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <link>:
.global link
link:
 li a7, SYS_link
 38a:	48cd                	li	a7,19
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 392:	48d1                	li	a7,20
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39a:	48a5                	li	a7,9
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a2:	48a9                	li	a7,10
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3aa:	48ad                	li	a7,11
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3b2:	48b1                	li	a7,12
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ba:	48b5                	li	a7,13
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c2:	48b9                	li	a7,14
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3ca:	48d9                	li	a7,22
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 3d2:	48dd                	li	a7,23
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3da:	1101                	addi	sp,sp,-32
 3dc:	ec06                	sd	ra,24(sp)
 3de:	e822                	sd	s0,16(sp)
 3e0:	1000                	addi	s0,sp,32
 3e2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e6:	4605                	li	a2,1
 3e8:	fef40593          	addi	a1,s0,-17
 3ec:	f5fff0ef          	jal	ra,34a <write>
}
 3f0:	60e2                	ld	ra,24(sp)
 3f2:	6442                	ld	s0,16(sp)
 3f4:	6105                	addi	sp,sp,32
 3f6:	8082                	ret

00000000000003f8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3f8:	715d                	addi	sp,sp,-80
 3fa:	e486                	sd	ra,72(sp)
 3fc:	e0a2                	sd	s0,64(sp)
 3fe:	fc26                	sd	s1,56(sp)
 400:	f84a                	sd	s2,48(sp)
 402:	f44e                	sd	s3,40(sp)
 404:	0880                	addi	s0,sp,80
 406:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 408:	c299                	beqz	a3,40e <printint+0x16>
 40a:	0805c163          	bltz	a1,48c <printint+0x94>
  neg = 0;
 40e:	4881                	li	a7,0
 410:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 414:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 416:	00000517          	auipc	a0,0x0
 41a:	57a50513          	addi	a0,a0,1402 # 990 <digits>
 41e:	883e                	mv	a6,a5
 420:	2785                	addiw	a5,a5,1
 422:	02c5f733          	remu	a4,a1,a2
 426:	972a                	add	a4,a4,a0
 428:	00074703          	lbu	a4,0(a4)
 42c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 430:	872e                	mv	a4,a1
 432:	02c5d5b3          	divu	a1,a1,a2
 436:	0685                	addi	a3,a3,1
 438:	fec773e3          	bgeu	a4,a2,41e <printint+0x26>
  if(neg)
 43c:	00088b63          	beqz	a7,452 <printint+0x5a>
    buf[i++] = '-';
 440:	fd078793          	addi	a5,a5,-48
 444:	97a2                	add	a5,a5,s0
 446:	02d00713          	li	a4,45
 44a:	fee78423          	sb	a4,-24(a5)
 44e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 452:	02f05663          	blez	a5,47e <printint+0x86>
 456:	fb840713          	addi	a4,s0,-72
 45a:	00f704b3          	add	s1,a4,a5
 45e:	fff70993          	addi	s3,a4,-1
 462:	99be                	add	s3,s3,a5
 464:	37fd                	addiw	a5,a5,-1
 466:	1782                	slli	a5,a5,0x20
 468:	9381                	srli	a5,a5,0x20
 46a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 46e:	fff4c583          	lbu	a1,-1(s1)
 472:	854a                	mv	a0,s2
 474:	f67ff0ef          	jal	ra,3da <putc>
  while(--i >= 0)
 478:	14fd                	addi	s1,s1,-1
 47a:	ff349ae3          	bne	s1,s3,46e <printint+0x76>
}
 47e:	60a6                	ld	ra,72(sp)
 480:	6406                	ld	s0,64(sp)
 482:	74e2                	ld	s1,56(sp)
 484:	7942                	ld	s2,48(sp)
 486:	79a2                	ld	s3,40(sp)
 488:	6161                	addi	sp,sp,80
 48a:	8082                	ret
    x = -xx;
 48c:	40b005b3          	neg	a1,a1
    neg = 1;
 490:	4885                	li	a7,1
    x = -xx;
 492:	bfbd                	j	410 <printint+0x18>

0000000000000494 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 494:	7119                	addi	sp,sp,-128
 496:	fc86                	sd	ra,120(sp)
 498:	f8a2                	sd	s0,112(sp)
 49a:	f4a6                	sd	s1,104(sp)
 49c:	f0ca                	sd	s2,96(sp)
 49e:	ecce                	sd	s3,88(sp)
 4a0:	e8d2                	sd	s4,80(sp)
 4a2:	e4d6                	sd	s5,72(sp)
 4a4:	e0da                	sd	s6,64(sp)
 4a6:	fc5e                	sd	s7,56(sp)
 4a8:	f862                	sd	s8,48(sp)
 4aa:	f466                	sd	s9,40(sp)
 4ac:	f06a                	sd	s10,32(sp)
 4ae:	ec6e                	sd	s11,24(sp)
 4b0:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b2:	0005c903          	lbu	s2,0(a1)
 4b6:	24090c63          	beqz	s2,70e <vprintf+0x27a>
 4ba:	8b2a                	mv	s6,a0
 4bc:	8a2e                	mv	s4,a1
 4be:	8bb2                	mv	s7,a2
  state = 0;
 4c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c2:	4481                	li	s1,0
 4c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4ce:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4d2:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4d6:	00000c97          	auipc	s9,0x0
 4da:	4bac8c93          	addi	s9,s9,1210 # 990 <digits>
 4de:	a005                	j	4fe <vprintf+0x6a>
        putc(fd, c0);
 4e0:	85ca                	mv	a1,s2
 4e2:	855a                	mv	a0,s6
 4e4:	ef7ff0ef          	jal	ra,3da <putc>
 4e8:	a019                	j	4ee <vprintf+0x5a>
    } else if(state == '%'){
 4ea:	03598263          	beq	s3,s5,50e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ee:	2485                	addiw	s1,s1,1
 4f0:	8726                	mv	a4,s1
 4f2:	009a07b3          	add	a5,s4,s1
 4f6:	0007c903          	lbu	s2,0(a5)
 4fa:	20090a63          	beqz	s2,70e <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4fe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 502:	fe0994e3          	bnez	s3,4ea <vprintf+0x56>
      if(c0 == '%'){
 506:	fd579de3          	bne	a5,s5,4e0 <vprintf+0x4c>
        state = '%';
 50a:	89be                	mv	s3,a5
 50c:	b7cd                	j	4ee <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 50e:	c3c1                	beqz	a5,58e <vprintf+0xfa>
 510:	00ea06b3          	add	a3,s4,a4
 514:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 518:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 51a:	c681                	beqz	a3,522 <vprintf+0x8e>
 51c:	9752                	add	a4,a4,s4
 51e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 522:	03878e63          	beq	a5,s8,55e <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 526:	05a78863          	beq	a5,s10,576 <vprintf+0xe2>
      } else if(c0 == 'u'){
 52a:	0db78b63          	beq	a5,s11,600 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 52e:	07800713          	li	a4,120
 532:	10e78d63          	beq	a5,a4,64c <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 536:	07000713          	li	a4,112
 53a:	14e78263          	beq	a5,a4,67e <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 53e:	06300713          	li	a4,99
 542:	16e78f63          	beq	a5,a4,6c0 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 546:	07300713          	li	a4,115
 54a:	18e78563          	beq	a5,a4,6d4 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 54e:	05579063          	bne	a5,s5,58e <vprintf+0xfa>
        putc(fd, '%');
 552:	85d6                	mv	a1,s5
 554:	855a                	mv	a0,s6
 556:	e85ff0ef          	jal	ra,3da <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 55a:	4981                	li	s3,0
 55c:	bf49                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 55e:	008b8913          	addi	s2,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000ba583          	lw	a1,0(s7)
 56a:	855a                	mv	a0,s6
 56c:	e8dff0ef          	jal	ra,3f8 <printint>
 570:	8bca                	mv	s7,s2
      state = 0;
 572:	4981                	li	s3,0
 574:	bfad                	j	4ee <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 576:	03868663          	beq	a3,s8,5a2 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 57a:	05a68163          	beq	a3,s10,5bc <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 57e:	09b68d63          	beq	a3,s11,618 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 582:	03a68f63          	beq	a3,s10,5c0 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 586:	07800793          	li	a5,120
 58a:	0cf68d63          	beq	a3,a5,664 <vprintf+0x1d0>
        putc(fd, '%');
 58e:	85d6                	mv	a1,s5
 590:	855a                	mv	a0,s6
 592:	e49ff0ef          	jal	ra,3da <putc>
        putc(fd, c0);
 596:	85ca                	mv	a1,s2
 598:	855a                	mv	a0,s6
 59a:	e41ff0ef          	jal	ra,3da <putc>
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b7b9                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000bb583          	ld	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	e49ff0ef          	jal	ra,3f8 <printint>
        i += 1;
 5b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
        i += 1;
 5ba:	bf15                	j	4ee <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	03860563          	beq	a2,s8,5e6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c0:	07b60963          	beq	a2,s11,632 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5c4:	07800793          	li	a5,120
 5c8:	fcf613e3          	bne	a2,a5,58e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	e1fff0ef          	jal	ra,3f8 <printint>
        i += 2;
 5de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	b729                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4685                	li	a3,1
 5ec:	4629                	li	a2,10
 5ee:	000bb583          	ld	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	e05ff0ef          	jal	ra,3f8 <printint>
        i += 2;
 5f8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
        i += 2;
 5fe:	bdc5                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000be583          	lwu	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	debff0ef          	jal	ra,3f8 <printint>
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bde1                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	dd3ff0ef          	jal	ra,3f8 <printint>
        i += 1;
 62a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 1;
 630:	bd7d                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	db9ff0ef          	jal	ra,3f8 <printint>
        i += 2;
 644:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
        i += 2;
 64a:	b555                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4641                	li	a2,16
 654:	000be583          	lwu	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	d9fff0ef          	jal	ra,3f8 <printint>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	b571                	j	4ee <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4641                	li	a2,16
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	d87ff0ef          	jal	ra,3f8 <printint>
        i += 1;
 676:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 1;
 67c:	bd8d                	j	4ee <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 67e:	008b8793          	addi	a5,s7,8
 682:	f8f43423          	sd	a5,-120(s0)
 686:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 68a:	03000593          	li	a1,48
 68e:	855a                	mv	a0,s6
 690:	d4bff0ef          	jal	ra,3da <putc>
  putc(fd, 'x');
 694:	07800593          	li	a1,120
 698:	855a                	mv	a0,s6
 69a:	d41ff0ef          	jal	ra,3da <putc>
 69e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a0:	03c9d793          	srli	a5,s3,0x3c
 6a4:	97e6                	add	a5,a5,s9
 6a6:	0007c583          	lbu	a1,0(a5)
 6aa:	855a                	mv	a0,s6
 6ac:	d2fff0ef          	jal	ra,3da <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b0:	0992                	slli	s3,s3,0x4
 6b2:	397d                	addiw	s2,s2,-1
 6b4:	fe0916e3          	bnez	s2,6a0 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6b8:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bd05                	j	4ee <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	000bc583          	lbu	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	d11ff0ef          	jal	ra,3da <putc>
 6ce:	8bca                	mv	s7,s2
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bd31                	j	4ee <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6d4:	008b8993          	addi	s3,s7,8
 6d8:	000bb903          	ld	s2,0(s7)
 6dc:	00090f63          	beqz	s2,6fa <vprintf+0x266>
        for(; *s; s++)
 6e0:	00094583          	lbu	a1,0(s2)
 6e4:	c195                	beqz	a1,708 <vprintf+0x274>
          putc(fd, *s);
 6e6:	855a                	mv	a0,s6
 6e8:	cf3ff0ef          	jal	ra,3da <putc>
        for(; *s; s++)
 6ec:	0905                	addi	s2,s2,1
 6ee:	00094583          	lbu	a1,0(s2)
 6f2:	f9f5                	bnez	a1,6e6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6f4:	8bce                	mv	s7,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bbdd                	j	4ee <vprintf+0x5a>
          s = "(null)";
 6fa:	00000917          	auipc	s2,0x0
 6fe:	28e90913          	addi	s2,s2,654 # 988 <malloc+0x17e>
        for(; *s; s++)
 702:	02800593          	li	a1,40
 706:	b7c5                	j	6e6 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 708:	8bce                	mv	s7,s3
      state = 0;
 70a:	4981                	li	s3,0
 70c:	b3cd                	j	4ee <vprintf+0x5a>
    }
  }
}
 70e:	70e6                	ld	ra,120(sp)
 710:	7446                	ld	s0,112(sp)
 712:	74a6                	ld	s1,104(sp)
 714:	7906                	ld	s2,96(sp)
 716:	69e6                	ld	s3,88(sp)
 718:	6a46                	ld	s4,80(sp)
 71a:	6aa6                	ld	s5,72(sp)
 71c:	6b06                	ld	s6,64(sp)
 71e:	7be2                	ld	s7,56(sp)
 720:	7c42                	ld	s8,48(sp)
 722:	7ca2                	ld	s9,40(sp)
 724:	7d02                	ld	s10,32(sp)
 726:	6de2                	ld	s11,24(sp)
 728:	6109                	addi	sp,sp,128
 72a:	8082                	ret

000000000000072c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72c:	715d                	addi	sp,sp,-80
 72e:	ec06                	sd	ra,24(sp)
 730:	e822                	sd	s0,16(sp)
 732:	1000                	addi	s0,sp,32
 734:	e010                	sd	a2,0(s0)
 736:	e414                	sd	a3,8(s0)
 738:	e818                	sd	a4,16(s0)
 73a:	ec1c                	sd	a5,24(s0)
 73c:	03043023          	sd	a6,32(s0)
 740:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 744:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 748:	8622                	mv	a2,s0
 74a:	d4bff0ef          	jal	ra,494 <vprintf>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6161                	addi	sp,sp,80
 754:	8082                	ret

0000000000000756 <printf>:

void
printf(const char *fmt, ...)
{
 756:	711d                	addi	sp,sp,-96
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e40c                	sd	a1,8(s0)
 760:	e810                	sd	a2,16(s0)
 762:	ec14                	sd	a3,24(s0)
 764:	f018                	sd	a4,32(s0)
 766:	f41c                	sd	a5,40(s0)
 768:	03043823          	sd	a6,48(s0)
 76c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	00840613          	addi	a2,s0,8
 774:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 778:	85aa                	mv	a1,a0
 77a:	4505                	li	a0,1
 77c:	d19ff0ef          	jal	ra,494 <vprintf>
}
 780:	60e2                	ld	ra,24(sp)
 782:	6442                	ld	s0,16(sp)
 784:	6125                	addi	sp,sp,96
 786:	8082                	ret

0000000000000788 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 788:	1141                	addi	sp,sp,-16
 78a:	e422                	sd	s0,8(sp)
 78c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 792:	00001797          	auipc	a5,0x1
 796:	86e7b783          	ld	a5,-1938(a5) # 1000 <freep>
 79a:	a02d                	j	7c4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79c:	4618                	lw	a4,8(a2)
 79e:	9f2d                	addw	a4,a4,a1
 7a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	6398                	ld	a4,0(a5)
 7a6:	6310                	ld	a2,0(a4)
 7a8:	a83d                	j	7e6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7aa:	ff852703          	lw	a4,-8(a0)
 7ae:	9f31                	addw	a4,a4,a2
 7b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b2:	ff053683          	ld	a3,-16(a0)
 7b6:	a091                	j	7fa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	6398                	ld	a4,0(a5)
 7ba:	00e7e463          	bltu	a5,a4,7c2 <free+0x3a>
 7be:	00e6ea63          	bltu	a3,a4,7d2 <free+0x4a>
{
 7c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	fed7fae3          	bgeu	a5,a3,7b8 <free+0x30>
 7c8:	6398                	ld	a4,0(a5)
 7ca:	00e6e463          	bltu	a3,a4,7d2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	fee7eae3          	bltu	a5,a4,7c2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d2:	ff852583          	lw	a1,-8(a0)
 7d6:	6390                	ld	a2,0(a5)
 7d8:	02059813          	slli	a6,a1,0x20
 7dc:	01c85713          	srli	a4,a6,0x1c
 7e0:	9736                	add	a4,a4,a3
 7e2:	fae60de3          	beq	a2,a4,79c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ea:	4790                	lw	a2,8(a5)
 7ec:	02061593          	slli	a1,a2,0x20
 7f0:	01c5d713          	srli	a4,a1,0x1c
 7f4:	973e                	add	a4,a4,a5
 7f6:	fae68ae3          	beq	a3,a4,7aa <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7fc:	00001717          	auipc	a4,0x1
 800:	80f73223          	sd	a5,-2044(a4) # 1000 <freep>
}
 804:	6422                	ld	s0,8(sp)
 806:	0141                	addi	sp,sp,16
 808:	8082                	ret

000000000000080a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80a:	7139                	addi	sp,sp,-64
 80c:	fc06                	sd	ra,56(sp)
 80e:	f822                	sd	s0,48(sp)
 810:	f426                	sd	s1,40(sp)
 812:	f04a                	sd	s2,32(sp)
 814:	ec4e                	sd	s3,24(sp)
 816:	e852                	sd	s4,16(sp)
 818:	e456                	sd	s5,8(sp)
 81a:	e05a                	sd	s6,0(sp)
 81c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81e:	02051493          	slli	s1,a0,0x20
 822:	9081                	srli	s1,s1,0x20
 824:	04bd                	addi	s1,s1,15
 826:	8091                	srli	s1,s1,0x4
 828:	0014899b          	addiw	s3,s1,1
 82c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 82e:	00000517          	auipc	a0,0x0
 832:	7d253503          	ld	a0,2002(a0) # 1000 <freep>
 836:	c515                	beqz	a0,862 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 838:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83a:	4798                	lw	a4,8(a5)
 83c:	02977f63          	bgeu	a4,s1,87a <malloc+0x70>
 840:	8a4e                	mv	s4,s3
 842:	0009871b          	sext.w	a4,s3
 846:	6685                	lui	a3,0x1
 848:	00d77363          	bgeu	a4,a3,84e <malloc+0x44>
 84c:	6a05                	lui	s4,0x1
 84e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 852:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 856:	00000917          	auipc	s2,0x0
 85a:	7aa90913          	addi	s2,s2,1962 # 1000 <freep>
  if(p == SBRK_ERROR)
 85e:	5afd                	li	s5,-1
 860:	a885                	j	8d0 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 862:	00000797          	auipc	a5,0x0
 866:	7ae78793          	addi	a5,a5,1966 # 1010 <base>
 86a:	00000717          	auipc	a4,0x0
 86e:	78f73b23          	sd	a5,1942(a4) # 1000 <freep>
 872:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 874:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 878:	b7e1                	j	840 <malloc+0x36>
      if(p->s.size == nunits)
 87a:	02e48c63          	beq	s1,a4,8b2 <malloc+0xa8>
        p->s.size -= nunits;
 87e:	4137073b          	subw	a4,a4,s3
 882:	c798                	sw	a4,8(a5)
        p += p->s.size;
 884:	02071693          	slli	a3,a4,0x20
 888:	01c6d713          	srli	a4,a3,0x1c
 88c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 88e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 892:	00000717          	auipc	a4,0x0
 896:	76a73723          	sd	a0,1902(a4) # 1000 <freep>
      return (void*)(p + 1);
 89a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 89e:	70e2                	ld	ra,56(sp)
 8a0:	7442                	ld	s0,48(sp)
 8a2:	74a2                	ld	s1,40(sp)
 8a4:	7902                	ld	s2,32(sp)
 8a6:	69e2                	ld	s3,24(sp)
 8a8:	6a42                	ld	s4,16(sp)
 8aa:	6aa2                	ld	s5,8(sp)
 8ac:	6b02                	ld	s6,0(sp)
 8ae:	6121                	addi	sp,sp,64
 8b0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b2:	6398                	ld	a4,0(a5)
 8b4:	e118                	sd	a4,0(a0)
 8b6:	bff1                	j	892 <malloc+0x88>
  hp->s.size = nu;
 8b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8bc:	0541                	addi	a0,a0,16
 8be:	ecbff0ef          	jal	ra,788 <free>
  return freep;
 8c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c6:	dd61                	beqz	a0,89e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ca:	4798                	lw	a4,8(a5)
 8cc:	fa9777e3          	bgeu	a4,s1,87a <malloc+0x70>
    if(p == freep)
 8d0:	00093703          	ld	a4,0(s2)
 8d4:	853e                	mv	a0,a5
 8d6:	fef719e3          	bne	a4,a5,8c8 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 8da:	8552                	mv	a0,s4
 8dc:	a1bff0ef          	jal	ra,2f6 <sbrk>
  if(p == SBRK_ERROR)
 8e0:	fd551ce3          	bne	a0,s5,8b8 <malloc+0xae>
        return 0;
 8e4:	4501                	li	a0,0
 8e6:	bf65                	j	89e <malloc+0x94>
