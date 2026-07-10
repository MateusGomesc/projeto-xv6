#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Uso correto: renice <pid> <prioridade>\n");
        exit(1);
    }

    int pid = atoi(argv[1]);
    int priority = atoi(argv[2]);

    if (priority < 0 || priority > 19) {
        printf("Erro: A prioridade deve estar entre 0 (maxima) e 20 (minima).\n");
        exit(1);
    }

    printf("Tentando mudar a prioridade do processo %d para %d...\n", pid, priority);

    if (setpriority(pid, priority) == 0) {
        printf("Sucesso: Prioridade do processo %d alterada!\n", pid);
    } else {
        printf("Erro: Nao foi possivel alterar a prioridade. O PID %d existe?\n", pid);
    }

    exit(0);
}