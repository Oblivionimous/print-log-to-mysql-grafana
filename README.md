# Print Log to MySQL + Grafana

Projeto para coleta, armazenamento e visualização de **logs de impressão do Windows** utilizando **PowerShell**, **MySQL** e **Grafana**.

Este repositório consolida scripts, exemplos e dashboards voltados ao **monitoramento, auditoria e análise de impressões**, com base nos eventos do **PrintService** do Windows.

---

## 🎯 Objetivo

Centralizar os eventos de impressão do Windows — principalmente o **Event ID 307** — em um banco de dados MySQL, possibilitando:

- Auditoria de impressões
- Identificação de usuários e impressoras
- Análise de volume de páginas
- Controle operacional e de custos
- Visualização em dashboards Grafana

<img width="2559" height="915" alt="image" src="https://github.com/user-attachments/assets/4b4c5d04-4719-4e73-87a8-c1b7dbac5ce9" />

---

## 🧩 Arquitetura da Solução

```
Windows Print Server
 └─ Event Viewer
     └─ Microsoft-Windows-PrintService/Operational
         └─ PowerShell
             └─ MySQL
                 └─ Grafana
```

---

## 📂 Estrutura do Projeto

Estrutura atual do repositório:

```
Servidor-de-logs-de-impressao-Mysql-Grafana/
│
├── README.md
│   └── Documentação principal do projeto, visão geral,
│       arquitetura, pré-requisitos e links para os demais documentos
│
├── dashboard/
│   └── Dashboards do Grafana
│       └── Log_de_impressoes_do_Windows_em_banco_de_dados_MySQL.json
│          (Dashboard exportado do Grafana)
│
├── docs/
│   ├── Configuracao log impressao windows.md
│   │   └── Habilitação e configuração do log de impressão no Windows
│   │
│   ├── Configuracao powershell printlog.md
│   │   └── Explicação detalhada do script PowerShell de coleta
│   │
│   ├── Docs agendamento task scheduler.md
│   │   └── Criação e configuração da tarefa agendada no Windows
│   │
│   └── Docs queries printlog.md
│       └── Documentação completa de todas as queries MySQL usadas
│           nos painéis do Grafana
│
├── plugin/
│   └── mysql-connector-net-8.1.0.msi
│       └── Driver MySQL Connector para integração via PowerShell
│
├── prints/
│   ├── Dashboard (1).png
│   ├── Dashboard (2).png
│   ├── Dashboard (3).png
│   ├── Dashboard (4).png
│   └── Dashboard (5).png
│       └── Evidências visuais e prints dos dashboards do Grafana
│
├── event/
│   └── EventID307_PrintLog.xml
│       └── Exemplo real de evento de impressão (Event ID 307)
│
├── scripts/
│   └── PrintLog-To-MySQL.ps1
│       └── Script PowerShell responsável por:
│           - Ler eventos do PrintService
│           - Tratar os dados
│           - Inserir no banco MySQL
│
├── sql/
│   ├── Banco.png
│   │   └── Evidência visual da estrutura do banco MySQL
│   │
│   ├── Criacao banco mysql logs impressao.md
│   │   └── Documentação da criação e estrutura do banco de dados
│   │
│   └── schema.sql
│       └── Schema MySQL alinhado com a tabela real `printlog`
│
└── samples/
    └── EventID307_PrintLog.xml (template do agendador de tarefas)

```

---

## 🔧 Pré-requisitos

- Windows Server ou Windows Desktop com:
  - Serviço **Print Spooler** ativo
  - Log **Microsoft-Windows-PrintService/Operational** habilitado
- PowerShell 5.1 ou superior
- MySQL Server
- MySQL Connector .NET  
  Exemplo:
  ```
  mysql-connector-net-8.1.0.msi
  ```
https://downloads.mysql.com/archives/c-net/
---

## 📜 Scripts PowerShell

Localização:

```
scripts/
```

Funções principais:

- Leitura dos eventos do Event Viewer
- Filtro por **Event ID 307**
- Extração de informações como:
  - Usuário
  - Impressora
  - Documento
  - Quantidade de páginas
  - Data e hora
- Inserção dos dados no banco MySQL

Os scripts podem ser executados manualmente ou de forma automatizada.

---

## 🗄️ Banco de Dados MySQL

O banco de dados armazena os registros de impressão de forma estruturada, permitindo:

- Consultas SQL
- Integração com Grafana
- Relatórios personalizados
- Auditoria histórica

A modelagem pode ser ajustada conforme a necessidade do ambiente.

<img width="726" height="682" alt="image" src="https://github.com/user-attachments/assets/2ce24437-c4ea-4aad-aa4a-41aca749a74d" />

---

## 📊 Dashboards Grafana

A pasta `Dashboard/` contém ou destina-se a conter:

- Dashboards de volume de impressão
- Impressões por usuário
- Impressões por impressora
- Análise temporal (dia, mês, ano)

<img width="2558" height="911" alt="image" src="https://github.com/user-attachments/assets/004ef38f-8acb-49b0-ad84-c612e2289234" />

## ⏱️ Execução e Automação

Os scripts podem ser executados via:

- Agendador de Tarefas do Windows
- Execução manual
- Trigger automático baseado em evento do Windows

<img width="632" height="486" alt="image" src="https://github.com/user-attachments/assets/e4fe9378-66ac-427f-8d12-9569ef50d8ee" />

---

## 📌 Referências

Este projeto é inspirado e fundamentado em materiais amplamente utilizados pela comunidade:

- Huttel – Salvar log de impressões do Windows em MySQL  
  https://www.huttel.com.br/2016/07/salvar-log-de-impressoes-do-windows-server-2012-em-banco-de-dados-mysql/

- Repositório original (Huttel)  
  https://github.com/wanderleihuttel/printlog

- Analista de TI – Eventos de impressão no Windows  
  http://www.analistadeti.com/print-server-gerar-evento-de-impressao-event-viewer/

- TechNet – Script para geração de eventos de impressão  
  https://gallery.technet.microsoft.com/Script-to-generate-print-84bdcf69

- Thomas Maurer – Executar queries MySQL via PowerShell  
  http://www.thomasmaurer.ch/2011/04/powershell-run-mysql-querys-with-powershell/

- Microsoft – Trigger de PowerShell via eventos  
  https://blogs.technet.microsoft.com/wincat/2011/08/25/trigger-a-powershell-script-from-a-windows-event/

- Microsoft KB – Print Service Logging  
  https://support.microsoft.com/en-us/kb/919736

---

## 📄 Observações

Projeto voltado para uso **administrativo, operacional e educacional**.  
Adapte conforme políticas de segurança e compliance do ambiente.
