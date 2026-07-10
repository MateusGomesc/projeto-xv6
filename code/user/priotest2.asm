
user/_priotest2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_table>:
#include "user/user.h"
#include "user/pstat.h"

void
print_table(void)
{
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7b513c23          	sd	s5,1976(sp)
  20:	7f010413          	addi	s0,sp,2032
  24:	db010113          	addi	sp,sp,-592
  struct pstat ps;

  if(getpinfo(&ps) < 0){
  28:	757d                	lui	a0,0xfffff
  2a:	5c050793          	addi	a5,a0,1472 # fffffffffffff5c0 <base+0xffffffffffffe5b0>
  2e:	00878533          	add	a0,a5,s0
  32:	472000ef          	jal	ra,4a4 <getpinfo>
  36:	02054863          	bltz	a0,66 <print_table+0x66>
    printf("getpinfo falhou\n");
    exit(1);
  }

  printf("PID\tPRIO\tSTATE\tRUNS\tNAME\n");
  3a:	00001517          	auipc	a0,0x1
  3e:	9ae50513          	addi	a0,a0,-1618 # 9e8 <malloc+0x104>
  42:	7ee000ef          	jal	ra,830 <printf>
  for(int i = 0; i < NPROC; i++){
  46:	74fd                	lui	s1,0xfffff
  48:	5c048793          	addi	a5,s1,1472 # fffffffffffff5c0 <base+0xffffffffffffe5b0>
  4c:	008784b3          	add	s1,a5,s0
  50:	9c040993          	addi	s3,s0,-1600
  54:	bc040913          	addi	s2,s0,-1088
  58:	10048a13          	addi	s4,s1,256
    if(ps.inuse[i])
      printf("%d\t%d\t%d\t%d\t%s\n",
  5c:	00001a97          	auipc	s5,0x1
  60:	9aca8a93          	addi	s5,s5,-1620 # a08 <malloc+0x124>
  64:	a839                	j	82 <print_table+0x82>
    printf("getpinfo falhou\n");
  66:	00001517          	auipc	a0,0x1
  6a:	96a50513          	addi	a0,a0,-1686 # 9d0 <malloc+0xec>
  6e:	7c2000ef          	jal	ra,830 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	390000ef          	jal	ra,404 <exit>
  for(int i = 0; i < NPROC; i++){
  78:	0491                	addi	s1,s1,4
  7a:	09a1                	addi	s3,s3,8
  7c:	0941                	addi	s2,s2,16
  7e:	03448163          	beq	s1,s4,a0 <print_table+0xa0>
    if(ps.inuse[i])
  82:	409c                	lw	a5,0(s1)
  84:	dbf5                	beqz	a5,78 <print_table+0x78>
      printf("%d\t%d\t%d\t%d\t%s\n",
  86:	87ca                	mv	a5,s2
  88:	0009a703          	lw	a4,0(s3)
  8c:	3004a683          	lw	a3,768(s1)
  90:	2004a603          	lw	a2,512(s1)
  94:	1004a583          	lw	a1,256(s1)
  98:	8556                	mv	a0,s5
  9a:	796000ef          	jal	ra,830 <printf>
  9e:	bfe9                	j	78 <print_table+0x78>
             ps.pid[i], ps.priority[i], ps.state[i], (int)ps.runs[i], ps.name[i]);
  }
}
  a0:	25010113          	addi	sp,sp,592
  a4:	7e813083          	ld	ra,2024(sp)
  a8:	7e013403          	ld	s0,2016(sp)
  ac:	7d813483          	ld	s1,2008(sp)
  b0:	7d013903          	ld	s2,2000(sp)
  b4:	7c813983          	ld	s3,1992(sp)
  b8:	7c013a03          	ld	s4,1984(sp)
  bc:	7b813a83          	ld	s5,1976(sp)
  c0:	7f010113          	addi	sp,sp,2032
  c4:	8082                	ret

00000000000000c6 <burn_cpu>:

void
burn_cpu(void)
{
  c6:	1101                	addi	sp,sp,-32
  c8:	ec22                	sd	s0,24(sp)
  ca:	1000                	addi	s0,sp,32
  for(volatile int i = 0; i < 500000000; i++);
  cc:	fe042623          	sw	zero,-20(s0)
  d0:	fec42703          	lw	a4,-20(s0)
  d4:	2701                	sext.w	a4,a4
  d6:	1dcd67b7          	lui	a5,0x1dcd6
  da:	4ff78793          	addi	a5,a5,1279 # 1dcd64ff <base+0x1dcd54ef>
  de:	00e7cd63          	blt	a5,a4,f8 <burn_cpu+0x32>
  e2:	873e                	mv	a4,a5
  e4:	fec42783          	lw	a5,-20(s0)
  e8:	2785                	addiw	a5,a5,1
  ea:	fef42623          	sw	a5,-20(s0)
  ee:	fec42783          	lw	a5,-20(s0)
  f2:	2781                	sext.w	a5,a5
  f4:	fef758e3          	bge	a4,a5,e4 <burn_cpu+0x1e>
}
  f8:	6462                	ld	s0,24(sp)
  fa:	6105                	addi	sp,sp,32
  fc:	8082                	ret

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	1141                	addi	sp,sp,-16
 100:	e406                	sd	ra,8(sp)
 102:	e022                	sd	s0,0(sp)
 104:	0800                	addi	s0,sp,16
  int pid1;

  pid1 = fork();
 106:	2f6000ef          	jal	ra,3fc <fork>
  if(pid1 == 0){
 10a:	ed29                	bnez	a0,164 <main+0x66>
    // ---- nível 1: filho do processo principal ----
    setpriority(getpid(), 5); // alta prioridade
 10c:	378000ef          	jal	ra,484 <getpid>
 110:	4595                	li	a1,5
 112:	39a000ef          	jal	ra,4ac <setpriority>

    int pid2 = fork();
 116:	2e6000ef          	jal	ra,3fc <fork>
    if(pid2 == 0){
 11a:	ed0d                	bnez	a0,154 <main+0x56>
      // ---- nível 2: filho do filho1 (neto do processo principal) ----
      setpriority(getpid(), 10); // prioridade média
 11c:	368000ef          	jal	ra,484 <getpid>
 120:	45a9                	li	a1,10
 122:	38a000ef          	jal	ra,4ac <setpriority>

      int pid3 = fork();
 126:	2d6000ef          	jal	ra,3fc <fork>
      if(pid3 == 0){
 12a:	ed09                	bnez	a0,144 <main+0x46>
        // ---- nível 3: filho do filho2 (bisneto do processo principal) ----
        setpriority(getpid(), 15); // baixa prioridade
 12c:	358000ef          	jal	ra,484 <getpid>
 130:	45bd                	li	a1,15
 132:	37a000ef          	jal	ra,4ac <setpriority>

        // Nesse ponto pai, filho1 e filho2 ainda estão vivos (ocupados),
        // então a tabela mostra a cadeia inteira.
        print_table();
 136:	ecbff0ef          	jal	ra,0 <print_table>

        burn_cpu();
 13a:	f8dff0ef          	jal	ra,c6 <burn_cpu>
        exit(0);
 13e:	4501                	li	a0,0
 140:	2c4000ef          	jal	ra,404 <exit>
      }

      // filho1 espera o neto terminar, mantendo-se ocupado nesse meio tempo
      burn_cpu();
 144:	f83ff0ef          	jal	ra,c6 <burn_cpu>
      wait(0);
 148:	4501                	li	a0,0
 14a:	2c2000ef          	jal	ra,40c <wait>
      exit(0);
 14e:	4501                	li	a0,0
 150:	2b4000ef          	jal	ra,404 <exit>
    }

    // processo principal-filho (nível 1) espera o nível 2 terminar
    burn_cpu();
 154:	f73ff0ef          	jal	ra,c6 <burn_cpu>
    wait(0);
 158:	4501                	li	a0,0
 15a:	2b2000ef          	jal	ra,40c <wait>
    exit(0);
 15e:	4501                	li	a0,0
 160:	2a4000ef          	jal	ra,404 <exit>
  }

  wait(0);
 164:	4501                	li	a0,0
 166:	2a6000ef          	jal	ra,40c <wait>
  exit(0);
 16a:	4501                	li	a0,0
 16c:	298000ef          	jal	ra,404 <exit>

0000000000000170 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 170:	1141                	addi	sp,sp,-16
 172:	e406                	sd	ra,8(sp)
 174:	e022                	sd	s0,0(sp)
 176:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 178:	f87ff0ef          	jal	ra,fe <main>
  exit(r);
 17c:	288000ef          	jal	ra,404 <exit>

0000000000000180 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 186:	87aa                	mv	a5,a0
 188:	0585                	addi	a1,a1,1
 18a:	0785                	addi	a5,a5,1
 18c:	fff5c703          	lbu	a4,-1(a1)
 190:	fee78fa3          	sb	a4,-1(a5)
 194:	fb75                	bnez	a4,188 <strcpy+0x8>
    ;
  return os;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb91                	beqz	a5,1ba <strcmp+0x1e>
 1a8:	0005c703          	lbu	a4,0(a1)
 1ac:	00f71763          	bne	a4,a5,1ba <strcmp+0x1e>
    p++, q++;
 1b0:	0505                	addi	a0,a0,1
 1b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbe5                	bnez	a5,1a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ba:	0005c503          	lbu	a0,0(a1)
}
 1be:	40a7853b          	subw	a0,a5,a0
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strlen>:

uint
strlen(const char *s)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	cf91                	beqz	a5,1ee <strlen+0x26>
 1d4:	0505                	addi	a0,a0,1
 1d6:	87aa                	mv	a5,a0
 1d8:	4685                	li	a3,1
 1da:	9e89                	subw	a3,a3,a0
 1dc:	00f6853b          	addw	a0,a3,a5
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff7c703          	lbu	a4,-1(a5)
 1e6:	fb7d                	bnez	a4,1dc <strlen+0x14>
    ;
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  for(n = 0; s[n]; n++)
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strlen+0x20>

00000000000001f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f8:	ca19                	beqz	a2,20e <memset+0x1c>
 1fa:	87aa                	mv	a5,a0
 1fc:	1602                	slli	a2,a2,0x20
 1fe:	9201                	srli	a2,a2,0x20
 200:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 204:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 208:	0785                	addi	a5,a5,1
 20a:	fee79de3          	bne	a5,a4,204 <memset+0x12>
  }
  return dst;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strchr>:

char*
strchr(const char *s, char c)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb99                	beqz	a5,234 <strchr+0x20>
    if(*s == c)
 220:	00f58763          	beq	a1,a5,22e <strchr+0x1a>
  for(; *s; s++)
 224:	0505                	addi	a0,a0,1
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbfd                	bnez	a5,220 <strchr+0xc>
      return (char*)s;
  return 0;
 22c:	4501                	li	a0,0
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  return 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <strchr+0x1a>

0000000000000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	711d                	addi	sp,sp,-96
 23a:	ec86                	sd	ra,88(sp)
 23c:	e8a2                	sd	s0,80(sp)
 23e:	e4a6                	sd	s1,72(sp)
 240:	e0ca                	sd	s2,64(sp)
 242:	fc4e                	sd	s3,56(sp)
 244:	f852                	sd	s4,48(sp)
 246:	f456                	sd	s5,40(sp)
 248:	f05a                	sd	s6,32(sp)
 24a:	ec5e                	sd	s7,24(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 256:	4aa9                	li	s5,10
 258:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	2485                	addiw	s1,s1,1
 25e:	0344d663          	bge	s1,s4,28a <gets+0x52>
    cc = read(0, &c, 1);
 262:	4605                	li	a2,1
 264:	faf40593          	addi	a1,s0,-81
 268:	4501                	li	a0,0
 26a:	1b2000ef          	jal	ra,41c <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x52>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x50>
 27e:	0905                	addi	s2,s2,1
 280:	fd679de3          	bne	a5,s6,25a <gets+0x22>
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	a011                	j	28a <gets+0x52>
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3)
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e426                	sd	s1,8(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	18c000ef          	jal	ra,444 <open>
  if(fd < 0)
 2bc:	02054163          	bltz	a0,2de <stat+0x36>
 2c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c2:	85ca                	mv	a1,s2
 2c4:	198000ef          	jal	ra,45c <fstat>
 2c8:	892a                	mv	s2,a0
  close(fd);
 2ca:	8526                	mv	a0,s1
 2cc:	160000ef          	jal	ra,42c <close>
  return r;
}
 2d0:	854a                	mv	a0,s2
 2d2:	60e2                	ld	ra,24(sp)
 2d4:	6442                	ld	s0,16(sp)
 2d6:	64a2                	ld	s1,8(sp)
 2d8:	6902                	ld	s2,0(sp)
 2da:	6105                	addi	sp,sp,32
 2dc:	8082                	ret
    return -1;
 2de:	597d                	li	s2,-1
 2e0:	bfc5                	j	2d0 <stat+0x28>

00000000000002e2 <atoi>:

int
atoi(const char *s)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e8:	00054683          	lbu	a3,0(a0)
 2ec:	fd06879b          	addiw	a5,a3,-48
 2f0:	0ff7f793          	zext.b	a5,a5
 2f4:	4625                	li	a2,9
 2f6:	02f66863          	bltu	a2,a5,326 <atoi+0x44>
 2fa:	872a                	mv	a4,a0
  n = 0;
 2fc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fe:	0705                	addi	a4,a4,1
 300:	0025179b          	slliw	a5,a0,0x2
 304:	9fa9                	addw	a5,a5,a0
 306:	0017979b          	slliw	a5,a5,0x1
 30a:	9fb5                	addw	a5,a5,a3
 30c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 310:	00074683          	lbu	a3,0(a4)
 314:	fd06879b          	addiw	a5,a3,-48
 318:	0ff7f793          	zext.b	a5,a5
 31c:	fef671e3          	bgeu	a2,a5,2fe <atoi+0x1c>
  return n;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  n = 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <atoi+0x3e>

000000000000032a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 330:	02b57463          	bgeu	a0,a1,358 <memmove+0x2e>
    while(n-- > 0)
 334:	00c05f63          	blez	a2,352 <memmove+0x28>
 338:	1602                	slli	a2,a2,0x20
 33a:	9201                	srli	a2,a2,0x20
 33c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 340:	872a                	mv	a4,a0
      *dst++ = *src++;
 342:	0585                	addi	a1,a1,1
 344:	0705                	addi	a4,a4,1
 346:	fff5c683          	lbu	a3,-1(a1)
 34a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34e:	fee79ae3          	bne	a5,a4,342 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret
    dst += n;
 358:	00c50733          	add	a4,a0,a2
    src += n;
 35c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35e:	fec05ae3          	blez	a2,352 <memmove+0x28>
 362:	fff6079b          	addiw	a5,a2,-1
 366:	1782                	slli	a5,a5,0x20
 368:	9381                	srli	a5,a5,0x20
 36a:	fff7c793          	not	a5,a5
 36e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 370:	15fd                	addi	a1,a1,-1
 372:	177d                	addi	a4,a4,-1
 374:	0005c683          	lbu	a3,0(a1)
 378:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37c:	fee79ae3          	bne	a5,a4,370 <memmove+0x46>
 380:	bfc9                	j	352 <memmove+0x28>

0000000000000382 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 388:	ca05                	beqz	a2,3b8 <memcmp+0x36>
 38a:	fff6069b          	addiw	a3,a2,-1
 38e:	1682                	slli	a3,a3,0x20
 390:	9281                	srli	a3,a3,0x20
 392:	0685                	addi	a3,a3,1
 394:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 396:	00054783          	lbu	a5,0(a0)
 39a:	0005c703          	lbu	a4,0(a1)
 39e:	00e79863          	bne	a5,a4,3ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a2:	0505                	addi	a0,a0,1
    p2++;
 3a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a6:	fed518e3          	bne	a0,a3,396 <memcmp+0x14>
  }
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	a019                	j	3b2 <memcmp+0x30>
      return *p1 - *p2;
 3ae:	40e7853b          	subw	a0,a5,a4
}
 3b2:	6422                	ld	s0,8(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret
  return 0;
 3b8:	4501                	li	a0,0
 3ba:	bfe5                	j	3b2 <memcmp+0x30>

00000000000003bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c4:	f67ff0ef          	jal	ra,32a <memmove>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <sbrk>:

char *
sbrk(int n) {
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3d8:	4585                	li	a1,1
 3da:	0b2000ef          	jal	ra,48c <sys_sbrk>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <sbrklazy>:

char *
sbrklazy(int n) {
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ee:	4589                	li	a1,2
 3f0:	09c000ef          	jal	ra,48c <sys_sbrk>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fc:	4885                	li	a7,1
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exit>:
.global exit
exit:
 li a7, SYS_exit
 404:	4889                	li	a7,2
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <wait>:
.global wait
wait:
 li a7, SYS_wait
 40c:	488d                	li	a7,3
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 414:	4891                	li	a7,4
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <read>:
.global read
read:
 li a7, SYS_read
 41c:	4895                	li	a7,5
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <write>:
.global write
write:
 li a7, SYS_write
 424:	48c1                	li	a7,16
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <close>:
.global close
close:
 li a7, SYS_close
 42c:	48d5                	li	a7,21
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <kill>:
.global kill
kill:
 li a7, SYS_kill
 434:	4899                	li	a7,6
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <exec>:
.global exec
exec:
 li a7, SYS_exec
 43c:	489d                	li	a7,7
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <open>:
.global open
open:
 li a7, SYS_open
 444:	48bd                	li	a7,15
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44c:	48c5                	li	a7,17
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 454:	48c9                	li	a7,18
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45c:	48a1                	li	a7,8
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <link>:
.global link
link:
 li a7, SYS_link
 464:	48cd                	li	a7,19
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46c:	48d1                	li	a7,20
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 474:	48a5                	li	a7,9
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <dup>:
.global dup
dup:
 li a7, SYS_dup
 47c:	48a9                	li	a7,10
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 484:	48ad                	li	a7,11
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 48c:	48b1                	li	a7,12
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <pause>:
.global pause
pause:
 li a7, SYS_pause
 494:	48b5                	li	a7,13
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49c:	48b9                	li	a7,14
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 4a4:	48d9                	li	a7,22
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 4ac:	48dd                	li	a7,23
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b4:	1101                	addi	sp,sp,-32
 4b6:	ec06                	sd	ra,24(sp)
 4b8:	e822                	sd	s0,16(sp)
 4ba:	1000                	addi	s0,sp,32
 4bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c0:	4605                	li	a2,1
 4c2:	fef40593          	addi	a1,s0,-17
 4c6:	f5fff0ef          	jal	ra,424 <write>
}
 4ca:	60e2                	ld	ra,24(sp)
 4cc:	6442                	ld	s0,16(sp)
 4ce:	6105                	addi	sp,sp,32
 4d0:	8082                	ret

00000000000004d2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d2:	715d                	addi	sp,sp,-80
 4d4:	e486                	sd	ra,72(sp)
 4d6:	e0a2                	sd	s0,64(sp)
 4d8:	fc26                	sd	s1,56(sp)
 4da:	f84a                	sd	s2,48(sp)
 4dc:	f44e                	sd	s3,40(sp)
 4de:	0880                	addi	s0,sp,80
 4e0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4e2:	c299                	beqz	a3,4e8 <printint+0x16>
 4e4:	0805c163          	bltz	a1,566 <printint+0x94>
  neg = 0;
 4e8:	4881                	li	a7,0
 4ea:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ee:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4f0:	00000517          	auipc	a0,0x0
 4f4:	53050513          	addi	a0,a0,1328 # a20 <digits>
 4f8:	883e                	mv	a6,a5
 4fa:	2785                	addiw	a5,a5,1
 4fc:	02c5f733          	remu	a4,a1,a2
 500:	972a                	add	a4,a4,a0
 502:	00074703          	lbu	a4,0(a4)
 506:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 50a:	872e                	mv	a4,a1
 50c:	02c5d5b3          	divu	a1,a1,a2
 510:	0685                	addi	a3,a3,1
 512:	fec773e3          	bgeu	a4,a2,4f8 <printint+0x26>
  if(neg)
 516:	00088b63          	beqz	a7,52c <printint+0x5a>
    buf[i++] = '-';
 51a:	fd078793          	addi	a5,a5,-48
 51e:	97a2                	add	a5,a5,s0
 520:	02d00713          	li	a4,45
 524:	fee78423          	sb	a4,-24(a5)
 528:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 52c:	02f05663          	blez	a5,558 <printint+0x86>
 530:	fb840713          	addi	a4,s0,-72
 534:	00f704b3          	add	s1,a4,a5
 538:	fff70993          	addi	s3,a4,-1
 53c:	99be                	add	s3,s3,a5
 53e:	37fd                	addiw	a5,a5,-1
 540:	1782                	slli	a5,a5,0x20
 542:	9381                	srli	a5,a5,0x20
 544:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 548:	fff4c583          	lbu	a1,-1(s1)
 54c:	854a                	mv	a0,s2
 54e:	f67ff0ef          	jal	ra,4b4 <putc>
  while(--i >= 0)
 552:	14fd                	addi	s1,s1,-1
 554:	ff349ae3          	bne	s1,s3,548 <printint+0x76>
}
 558:	60a6                	ld	ra,72(sp)
 55a:	6406                	ld	s0,64(sp)
 55c:	74e2                	ld	s1,56(sp)
 55e:	7942                	ld	s2,48(sp)
 560:	79a2                	ld	s3,40(sp)
 562:	6161                	addi	sp,sp,80
 564:	8082                	ret
    x = -xx;
 566:	40b005b3          	neg	a1,a1
    neg = 1;
 56a:	4885                	li	a7,1
    x = -xx;
 56c:	bfbd                	j	4ea <printint+0x18>

000000000000056e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56e:	7119                	addi	sp,sp,-128
 570:	fc86                	sd	ra,120(sp)
 572:	f8a2                	sd	s0,112(sp)
 574:	f4a6                	sd	s1,104(sp)
 576:	f0ca                	sd	s2,96(sp)
 578:	ecce                	sd	s3,88(sp)
 57a:	e8d2                	sd	s4,80(sp)
 57c:	e4d6                	sd	s5,72(sp)
 57e:	e0da                	sd	s6,64(sp)
 580:	fc5e                	sd	s7,56(sp)
 582:	f862                	sd	s8,48(sp)
 584:	f466                	sd	s9,40(sp)
 586:	f06a                	sd	s10,32(sp)
 588:	ec6e                	sd	s11,24(sp)
 58a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58c:	0005c903          	lbu	s2,0(a1)
 590:	24090c63          	beqz	s2,7e8 <vprintf+0x27a>
 594:	8b2a                	mv	s6,a0
 596:	8a2e                	mv	s4,a1
 598:	8bb2                	mv	s7,a2
  state = 0;
 59a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 59c:	4481                	li	s1,0
 59e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ac:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b0:	00000c97          	auipc	s9,0x0
 5b4:	470c8c93          	addi	s9,s9,1136 # a20 <digits>
 5b8:	a005                	j	5d8 <vprintf+0x6a>
        putc(fd, c0);
 5ba:	85ca                	mv	a1,s2
 5bc:	855a                	mv	a0,s6
 5be:	ef7ff0ef          	jal	ra,4b4 <putc>
 5c2:	a019                	j	5c8 <vprintf+0x5a>
    } else if(state == '%'){
 5c4:	03598263          	beq	s3,s5,5e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c8:	2485                	addiw	s1,s1,1
 5ca:	8726                	mv	a4,s1
 5cc:	009a07b3          	add	a5,s4,s1
 5d0:	0007c903          	lbu	s2,0(a5)
 5d4:	20090a63          	beqz	s2,7e8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5dc:	fe0994e3          	bnez	s3,5c4 <vprintf+0x56>
      if(c0 == '%'){
 5e0:	fd579de3          	bne	a5,s5,5ba <vprintf+0x4c>
        state = '%';
 5e4:	89be                	mv	s3,a5
 5e6:	b7cd                	j	5c8 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e8:	c3c1                	beqz	a5,668 <vprintf+0xfa>
 5ea:	00ea06b3          	add	a3,s4,a4
 5ee:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f4:	c681                	beqz	a3,5fc <vprintf+0x8e>
 5f6:	9752                	add	a4,a4,s4
 5f8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5fc:	03878e63          	beq	a5,s8,638 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 600:	05a78863          	beq	a5,s10,650 <vprintf+0xe2>
      } else if(c0 == 'u'){
 604:	0db78b63          	beq	a5,s11,6da <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 608:	07800713          	li	a4,120
 60c:	10e78d63          	beq	a5,a4,726 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 610:	07000713          	li	a4,112
 614:	14e78263          	beq	a5,a4,758 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 618:	06300713          	li	a4,99
 61c:	16e78f63          	beq	a5,a4,79a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 620:	07300713          	li	a4,115
 624:	18e78563          	beq	a5,a4,7ae <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 628:	05579063          	bne	a5,s5,668 <vprintf+0xfa>
        putc(fd, '%');
 62c:	85d6                	mv	a1,s5
 62e:	855a                	mv	a0,s6
 630:	e85ff0ef          	jal	ra,4b4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 634:	4981                	li	s3,0
 636:	bf49                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000ba583          	lw	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e8dff0ef          	jal	ra,4d2 <printint>
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bfad                	j	5c8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 650:	03868663          	beq	a3,s8,67c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 654:	05a68163          	beq	a3,s10,696 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 658:	09b68d63          	beq	a3,s11,6f2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65c:	03a68f63          	beq	a3,s10,69a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 660:	07800793          	li	a5,120
 664:	0cf68d63          	beq	a3,a5,73e <vprintf+0x1d0>
        putc(fd, '%');
 668:	85d6                	mv	a1,s5
 66a:	855a                	mv	a0,s6
 66c:	e49ff0ef          	jal	ra,4b4 <putc>
        putc(fd, c0);
 670:	85ca                	mv	a1,s2
 672:	855a                	mv	a0,s6
 674:	e41ff0ef          	jal	ra,4b4 <putc>
      state = 0;
 678:	4981                	li	s3,0
 67a:	b7b9                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 67c:	008b8913          	addi	s2,s7,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	e49ff0ef          	jal	ra,4d2 <printint>
        i += 1;
 68e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
        i += 1;
 694:	bf15                	j	5c8 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 696:	03860563          	beq	a2,s8,6c0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 69a:	07b60963          	beq	a2,s11,70c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 69e:	07800793          	li	a5,120
 6a2:	fcf613e3          	bne	a2,a5,668 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4641                	li	a2,16
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	e1fff0ef          	jal	ra,4d2 <printint>
        i += 2;
 6b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	b729                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4685                	li	a3,1
 6c6:	4629                	li	a2,10
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e05ff0ef          	jal	ra,4d2 <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	bdc5                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000be583          	lwu	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	debff0ef          	jal	ra,4d2 <printint>
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bde1                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	dd3ff0ef          	jal	ra,4d2 <printint>
        i += 1;
 704:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
        i += 1;
 70a:	bd7d                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	db9ff0ef          	jal	ra,4d2 <printint>
        i += 2;
 71e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 2;
 724:	b555                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000be583          	lwu	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	d9fff0ef          	jal	ra,4d2 <printint>
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b571                	j	5c8 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73e:	008b8913          	addi	s2,s7,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000bb583          	ld	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	d87ff0ef          	jal	ra,4d2 <printint>
        i += 1;
 750:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
        i += 1;
 756:	bd8d                	j	5c8 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 758:	008b8793          	addi	a5,s7,8
 75c:	f8f43423          	sd	a5,-120(s0)
 760:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 764:	03000593          	li	a1,48
 768:	855a                	mv	a0,s6
 76a:	d4bff0ef          	jal	ra,4b4 <putc>
  putc(fd, 'x');
 76e:	07800593          	li	a1,120
 772:	855a                	mv	a0,s6
 774:	d41ff0ef          	jal	ra,4b4 <putc>
 778:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77a:	03c9d793          	srli	a5,s3,0x3c
 77e:	97e6                	add	a5,a5,s9
 780:	0007c583          	lbu	a1,0(a5)
 784:	855a                	mv	a0,s6
 786:	d2fff0ef          	jal	ra,4b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 78a:	0992                	slli	s3,s3,0x4
 78c:	397d                	addiw	s2,s2,-1
 78e:	fe0916e3          	bnez	s2,77a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 792:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 796:	4981                	li	s3,0
 798:	bd05                	j	5c8 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 79a:	008b8913          	addi	s2,s7,8
 79e:	000bc583          	lbu	a1,0(s7)
 7a2:	855a                	mv	a0,s6
 7a4:	d11ff0ef          	jal	ra,4b4 <putc>
 7a8:	8bca                	mv	s7,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bd31                	j	5c8 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7ae:	008b8993          	addi	s3,s7,8
 7b2:	000bb903          	ld	s2,0(s7)
 7b6:	00090f63          	beqz	s2,7d4 <vprintf+0x266>
        for(; *s; s++)
 7ba:	00094583          	lbu	a1,0(s2)
 7be:	c195                	beqz	a1,7e2 <vprintf+0x274>
          putc(fd, *s);
 7c0:	855a                	mv	a0,s6
 7c2:	cf3ff0ef          	jal	ra,4b4 <putc>
        for(; *s; s++)
 7c6:	0905                	addi	s2,s2,1
 7c8:	00094583          	lbu	a1,0(s2)
 7cc:	f9f5                	bnez	a1,7c0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7ce:	8bce                	mv	s7,s3
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bbdd                	j	5c8 <vprintf+0x5a>
          s = "(null)";
 7d4:	00000917          	auipc	s2,0x0
 7d8:	24490913          	addi	s2,s2,580 # a18 <malloc+0x134>
        for(; *s; s++)
 7dc:	02800593          	li	a1,40
 7e0:	b7c5                	j	7c0 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7e2:	8bce                	mv	s7,s3
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	b3cd                	j	5c8 <vprintf+0x5a>
    }
  }
}
 7e8:	70e6                	ld	ra,120(sp)
 7ea:	7446                	ld	s0,112(sp)
 7ec:	74a6                	ld	s1,104(sp)
 7ee:	7906                	ld	s2,96(sp)
 7f0:	69e6                	ld	s3,88(sp)
 7f2:	6a46                	ld	s4,80(sp)
 7f4:	6aa6                	ld	s5,72(sp)
 7f6:	6b06                	ld	s6,64(sp)
 7f8:	7be2                	ld	s7,56(sp)
 7fa:	7c42                	ld	s8,48(sp)
 7fc:	7ca2                	ld	s9,40(sp)
 7fe:	7d02                	ld	s10,32(sp)
 800:	6de2                	ld	s11,24(sp)
 802:	6109                	addi	sp,sp,128
 804:	8082                	ret

0000000000000806 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 806:	715d                	addi	sp,sp,-80
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e010                	sd	a2,0(s0)
 810:	e414                	sd	a3,8(s0)
 812:	e818                	sd	a4,16(s0)
 814:	ec1c                	sd	a5,24(s0)
 816:	03043023          	sd	a6,32(s0)
 81a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 822:	8622                	mv	a2,s0
 824:	d4bff0ef          	jal	ra,56e <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6161                	addi	sp,sp,80
 82e:	8082                	ret

0000000000000830 <printf>:

void
printf(const char *fmt, ...)
{
 830:	711d                	addi	sp,sp,-96
 832:	ec06                	sd	ra,24(sp)
 834:	e822                	sd	s0,16(sp)
 836:	1000                	addi	s0,sp,32
 838:	e40c                	sd	a1,8(s0)
 83a:	e810                	sd	a2,16(s0)
 83c:	ec14                	sd	a3,24(s0)
 83e:	f018                	sd	a4,32(s0)
 840:	f41c                	sd	a5,40(s0)
 842:	03043823          	sd	a6,48(s0)
 846:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84a:	00840613          	addi	a2,s0,8
 84e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 852:	85aa                	mv	a1,a0
 854:	4505                	li	a0,1
 856:	d19ff0ef          	jal	ra,56e <vprintf>
}
 85a:	60e2                	ld	ra,24(sp)
 85c:	6442                	ld	s0,16(sp)
 85e:	6125                	addi	sp,sp,96
 860:	8082                	ret

0000000000000862 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 868:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	00000797          	auipc	a5,0x0
 870:	7947b783          	ld	a5,1940(a5) # 1000 <freep>
 874:	a02d                	j	89e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 876:	4618                	lw	a4,8(a2)
 878:	9f2d                	addw	a4,a4,a1
 87a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	6398                	ld	a4,0(a5)
 880:	6310                	ld	a2,0(a4)
 882:	a83d                	j	8c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9f31                	addw	a4,a4,a2
 88a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053683          	ld	a3,-16(a0)
 890:	a091                	j	8d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x3a>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x4a>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x30>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059813          	slli	a6,a1,0x20
 8b6:	01c85713          	srli	a4,a6,0x1c
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60de3          	beq	a2,a4,876 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061593          	slli	a1,a2,0x20
 8ca:	01c5d713          	srli	a4,a1,0x1c
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae68ae3          	beq	a3,a4,884 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	f04a                	sd	s2,32(sp)
 8ee:	ec4e                	sd	s3,24(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
 8f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f8:	02051493          	slli	s1,a0,0x20
 8fc:	9081                	srli	s1,s1,0x20
 8fe:	04bd                	addi	s1,s1,15
 900:	8091                	srli	s1,s1,0x4
 902:	0014899b          	addiw	s3,s1,1
 906:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 908:	00000517          	auipc	a0,0x0
 90c:	6f853503          	ld	a0,1784(a0) # 1000 <freep>
 910:	c515                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	02977f63          	bgeu	a4,s1,954 <malloc+0x70>
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	6d090913          	addi	s2,s2,1744 # 1000 <freep>
  if(p == SBRK_ERROR)
 938:	5afd                	li	s5,-1
 93a:	a885                	j	9aa <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 93c:	00000797          	auipc	a5,0x0
 940:	6d478793          	addi	a5,a5,1748 # 1010 <base>
 944:	00000717          	auipc	a4,0x0
 948:	6af73e23          	sd	a5,1724(a4) # 1000 <freep>
 94c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 952:	b7e1                	j	91a <malloc+0x36>
      if(p->s.size == nunits)
 954:	02e48c63          	beq	s1,a4,98c <malloc+0xa8>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	02071693          	slli	a3,a4,0x20
 962:	01c6d713          	srli	a4,a3,0x1c
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	68a73a23          	sd	a0,1684(a4) # 1000 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	7902                	ld	s2,32(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6a42                	ld	s4,16(sp)
 984:	6aa2                	ld	s5,8(sp)
 986:	6b02                	ld	s6,0(sp)
 988:	6121                	addi	sp,sp,64
 98a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	e118                	sd	a4,0(a0)
 990:	bff1                	j	96c <malloc+0x88>
  hp->s.size = nu;
 992:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 996:	0541                	addi	a0,a0,16
 998:	ecbff0ef          	jal	ra,862 <free>
  return freep;
 99c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a0:	dd61                	beqz	a0,978 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a4:	4798                	lw	a4,8(a5)
 9a6:	fa9777e3          	bgeu	a4,s1,954 <malloc+0x70>
    if(p == freep)
 9aa:	00093703          	ld	a4,0(s2)
 9ae:	853e                	mv	a0,a5
 9b0:	fef719e3          	bne	a4,a5,9a2 <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 9b4:	8552                	mv	a0,s4
 9b6:	a1bff0ef          	jal	ra,3d0 <sbrk>
  if(p == SBRK_ERROR)
 9ba:	fd551ce3          	bne	a0,s5,992 <malloc+0xae>
        return 0;
 9be:	4501                	li	a0,0
 9c0:	bf65                	j	978 <malloc+0x94>
