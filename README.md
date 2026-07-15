# Projeto XV6
Modificações no sistema operacional de código aberto XV6.

## Integrantes do grupo

- Carlos Eduardo Rabelo Rodrigues Pelet
- Davi Gonçalves Cabeceira
- Leornardo Pereira da Silva
- Mateus Gomes Costa
- Yasmin Moreira Soares

## ETAPA 1

Planejamento e mapeamento das soluções e algoritmos que serão implementados no código base do xv6.
Materias referentes a etapa de encontram nas pastas `/slides` e `/video`.

## ETAPA 2

# Modificações do Round Robin com Prioridade no xv6

Este projeto apresenta a implementação de um escalonador baseado em prioridades no sistema operacional didático **xv6-riscv**. Além da alteração no algoritmo de escalonamento, foram implementadas chamadas de sistema (system calls) para consultar o estado dos processos e alterar dinamicamente suas prioridades, além de um programa de teste em espaço de usuário para validação.

---

## 🛠️ Modificações Realizadas

Abaixo está o mapeamento detalhado das modificações efetuadas na estrutura do kernel e do espaço de usuário do xv6:

### 1. Definições do Kernel e Estruturas de Dados
*   **`kernel/param.h`**: Verificação de limites de processos e parâmetros gerais do sistema.
*   **`kernel/proc.h`**: 
    *   Adicionado o campo `priority` à estrutura `proc` para armazenar a prioridade atual do processo.
    *   Adicionado o campo `runs` (`uint64`) para rastrear quantas vezes o processo foi selecionado pelo escalonador.
*   **`kernel/pstat.h`**: Criação deste arquivo para definir a estrutura `pstat` (utilizada tanto no espaço de kernel quanto de usuário) para reportar estatísticas e status de todos os processos ativos do sistema.

### 2. Implementação do Kernel (`kernel/proc.c`)
*   **`allocproc()`**: Inicialização padrão dos campos adicionados:
    *   Prioridade padrão definida como `10`.
    *   Contador de execuções (`runs`) inicializado em `0`.
*   **`scheduler()`**: Modificação da lógica do escalonador principal no final do arquivo para priorizar a execução de processos com maior prioridade (menor ou maior valor numérico, dependendo da convenção escolhida) e atualizar o contador de execuções (`runs`).
*   **Novas Funções**: Implementação física das funções auxiliares do kernel:
    *   `setpriority(int pid, int priority)`: Altera a prioridade de um processo específico.
    *   `getpinfo(struct pstat *)`: Preenche a estrutura com informações de status de todos os processos em execução.
*   **Inclusões**: Adicionado `#include "pstat.h"` para permitir o uso da estrutura de status.

### 3. Mecanismo de Chamadas de Sistema (System Calls)
*   **`kernel/defs.h`**: Declaração das assinaturas de `setpriority`, `getpinfo` e da estrutura `pstat` para visibilidade global dentro do kernel.
*   **`kernel/syscall.h`**: Mapeamento dos identificadores numéricos das novas chamadas de sistema:
    *   `SYS_getpinfo` definido como `22`.
    *   `SYS_setpriority` definido como `23`.
*   **`kernel/syscall.c`**: Registro dos protótipos externos e mapeamento no vetor de chamadas de sistema:
    *   `extern uint64 sys_getpinfo(void);`
    *   `extern uint64 sys_setpriority(void);`
*   **`kernel/sysproc.c`**: Implementação das funções de interface de sistema `sys_getpinfo` e `sys_setpriority`, responsáveis por recuperar os argumentos passados pelo usuário e invocar as funções internas do kernel correspondentes.

### 4. Interface e Espaço de Usuário
*   **`user/user.h`**: Declaração da `struct pstat` e dos protótipos de funções disponíveis para o usuário: `getpinfo()` e `setpriority()`.
*   **`user/usys.pl`**: Adicionadas as entradas para gerar automaticamente o código assembly que faz a transição do modo usuário para o modo kernel (trampolim de syscall):
    *   `entry("getpinfo");`
    *   `entry("setpriority");`
*   **`user/priotest.c`**: Programa desenvolvido especificamente para estressar e validar o novo escalonador baseado em prioridades, alterando prioridades e exibindo o comportamento dos processos através de `getpinfo`.
*   **`Makefile`**: Registro de `priotest` na lista de programas de usuário (`UPROGS`) para compilação automática junto à imagem do sistema operacional.

---

## ⏱️ Nota sobre o Quantum de Tempo do xv6

Durante a análise do escalonador original do xv6, constatamos que o **quantum de tempo não é definido de forma explícita** no arquivo do escalonador (`kernel/proc.c`). 

Em vez disso, o sistema conta com uma interrupção periódica gerada por hardware (timer interrupt):
*   Essa interrupção é configurada no arquivo `kernel/start.c` dentro da função `timerinit()`.
*   O intervalo configurado é de **1.000.000 de ciclos** de CPU, o que equivale a aproximadamente **1 milissegundo (1ms)**. 
*   A cada interrupção de tempo, a CPU cede controle ao kernel, que força o processo atual a abrir mão da CPU (`yield()`), permitindo uma nova rodada do escalonador.

---

## 🚀 Como Executar e Testar

1. Certifique-se de ter a toolchain do RISC-V e o QEMU instalados.
2. Compile e execute o xv6:
   ```bash
   make qemu
   ```
3. No prompt do xv6, execute o programa de testes:
   ```bash
   $ priotest
   ```
