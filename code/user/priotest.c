#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/pstat.h"

int
main(int argc, char *argv[])
{
  int pid1;

  pid1 = fork();
  if(pid1 == 0){
    setpriority(getpid(), 5);   // alta prioridade
    // Explica para o compilador que a variavel pode mudar de maneira inesperada
    for(volatile int i = 0; i < 500000000; i++);

    struct pstat ps;
    if(getpinfo(&ps) < 0){
        printf("getpinfo falhou\n");
        exit(1);
    }
    
    printf("PID\tPRIO\tSTATE\tRUNS\tNAME\n");
    for(int i = 0; i < NPROC; i++){
        if(ps.inuse[i])
        printf("%d\t%d\t%d\t%d\t%s\n",
        ps.pid[i], ps.priority[i], ps.state[i], (int)ps.runs[i], ps.name[i]);
    }

    exit(0);
    }

  wait(0);
  wait(0);

  exit(0);
}