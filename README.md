# Servidor de Logs de Impressão do Windows em MySQL

Projeto para coletar **logs de impressão do Windows (Event Viewer)** e armazená-los em um **banco de dados MySQL**, permitindo auditoria, análise histórica e criação de dashboards (ex.: Grafana).

---

## 🎯 Objetivo

Centralizar eventos de impressão do Windows, com foco no **Event ID 307**, para identificar:

- Quem imprimiu
- O quê foi impresso
- Em qual impressora
- Quando ocorreu
- Quantidade de páginas

Essas informações ajudam no controle operacional, auditoria e apoio à tomada de decisão.

---

## 🧩 Arquitetura da Solução

```
Windows Server
 └─ Event Viewer (PrintService)
     └─ PowerShell
         └─ MySQL
             └─ Grafana / Relatórios
```

---

## 📂 Estrutura do Projeto

```
print-log-to-mysql/
├── README.md
├── scripts/
│   └── PrintLog-To-MySQL.ps1
├── sql/
│   └── schema.sql
├── docs/
│   ├── arquitetura.md
│   └── exemplo-evento.md
└── samples/
    └── EventID307_PrintLog.xml
```

---

## 🔧 Pré-requisitos

- Windows Server ou Windows com:
  - Serviço **Print Spooler** ativo
  - Log **Microsoft-Windows-PrintService/Operational** habilitado
- PowerShell 5.1 ou superior
- MySQL Server
- MySQL Connector .NET (ex.: `mysql-connector-net-8.1.0.msi`)

---

## 📜 Script PowerShell

Arquivo principal:

```
scripts/PrintLog-To-MySQL.ps1
```

Responsabilidades do script:

- Ler eventos do log de impressão do Windows
- Filtrar **Event ID 307**
- Extrair dados relevantes do evento
- Inserir os registros em uma tabela MySQL

Principais campos coletados:

- Data e hora do evento
- Usuário
- Impressora
- Documento
- Quantidade de páginas
- Computador de origem

---

## 🗄️ Estrutura do Banco de Dados (Exemplo)

```sql
CREATE TABLE print_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_time DATETIME NOT NULL,
    user_name VARCHAR(255),
    printer_name VARCHAR(255),
    document_name VARCHAR(255),
    pages INT,
    computer_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## ⏱️ Execução Automatizada

O script pode ser executado via:

- **Task Scheduler (Agendador de Tarefas do Windows)**
- Execução manual para testes
- Execução periódica (ex.: a cada 5 ou 10 minutos)

Recomenda-se implementar controle para evitar reprocessar eventos já coletados.

---

## 📊 Possibilidades de Uso

- Dashboards no Grafana
- Relatórios de consumo por usuário ou impressora
- Auditoria de impressões
- Base histórica para controle de custos

---

## 🛣️ Roadmap

- [ ] Controle de eventos já processados
- [ ] Tratamento de falhas de conexão com o banco
- [ ] Dashboard Grafana pronto
- [ ] Exportação CSV
- [ ] Documentação detalhada por query

---

## 📄 Licença

Projeto de uso interno / educacional. Ajuste conforme a política da organização.
