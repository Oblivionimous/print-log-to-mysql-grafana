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
print-log-to-mysql-grafana/
├── Dashboard/
│   └── Dashboards Grafana e arquivos relacionados
├── Plugin/
│   └── Componentes auxiliares / experimentais
├── samples/
│   └── Exemplos de eventos e logs de impressão
├── scripts/
│   └── Scripts PowerShell para coleta e envio ao MySQL
└── README.md
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

---

## 📊 Dashboards Grafana

A pasta `Dashboard/` contém ou destina-se a conter:

- Dashboards de volume de impressão
- Impressões por usuário
- Impressões por impressora
- Análise temporal (dia, mês, ano)

---

## ⏱️ Execução e Automação

Os scripts podem ser executados via:

- Agendador de Tarefas do Windows
- Execução manual
- Trigger automático baseado em evento do Windows

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

## 🛣️ Roadmap

- [ ] Controle de eventos já processados
- [ ] Tratamento de falhas de conexão
- [ ] Padronização de dashboards Grafana
- [ ] Documentação SQL
- [ ] Otimização de performance

---

## 📄 Observações

Projeto voltado para uso **administrativo, operacional e educacional**.  
Adapte conforme políticas de segurança e compliance do ambiente.
