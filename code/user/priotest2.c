#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/pstat.h"

void
print_table(void)
{
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
}

void
burn_cpu(void)
{
  for(volatile int i = 0; i < 500000000; i++);
}

int
main(int argc, char *argv[])
{
  int pid1;

  pid1 = fork();
  if(pid1 == 0){
    // ---- nível 1: filho do processo principal ----
    setpriority(getpid(), 5); // alta prioridade

    int pid2 = fork();
    if(pid2 == 0){
      // ---- nível 2: filho do filho1 (neto do processo principal) ----
      setpriority(getpid(), 10); // prioridade média

      int pid3 = fork();
      if(pid3 == 0){
        // ---- nível 3: filho do filho2 (bisneto do processo principal) ----
        setpriority(getpid(), 15); // baixa prioridade

        // Nesse ponto pai, filho1 e filho2 ainda estão vivos (ocupados),
        // então a tabela mostra a cadeia inteira.
        print_table();

        burn_cpu();
        exit(0);
      }

      // filho1 espera o neto terminar, mantendo-se ocupado nesse meio tempo
      burn_cpu();
      wait(0);
      exit(0);
    }

    // processo principal-filho (nível 1) espera o nível 2 terminar
    burn_cpu();
    wait(0);
    exit(0);
  }

  wait(0);
  exit(0);
}