#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "kernel/param.h" // NPROC

struct pstat {
  int inuse[NPROC];     // processo está em uso?
  int pid[NPROC];       // pid
  int priority[NPROC];  // prioridade atual
  int state[NPROC];     // enum procstate (0=UNUSED ... )
  uint64 runs[NPROC];   // vezes escalonado
  char name[NPROC][16]; // nome do processo
};

#endif