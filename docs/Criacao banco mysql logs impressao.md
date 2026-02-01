# Criação do Banco de Dados MySQL para Logs de Impressão

Este documento descreve o **passo a passo para criação e configuração do banco de dados MySQL** utilizado para armazenar os logs de impressão coletados do Windows (Event ID 307).

---

## 🎯 Objetivo

Disponibilizar uma estrutura de banco de dados confiável para:

- Armazenar logs de impressão do Windows
- Permitir consultas SQL
- Integrar com dashboards Grafana
- Manter histórico de auditoria

---

## 🧩 Visão Geral da Arquitetura

```
Windows Print Server
 └─ PowerShell
     └─ MySQL
         └─ Grafana / Relatórios
```

---

## 🔧 Pré-requisitos

- MySQL Server 5.7+ ou MySQL 8.x
- Usuário com permissão administrativa no MySQL
- Acesso ao servidor MySQL via terminal ou MySQL Workbench

---

## 1️⃣ Criação do Banco de Dados

Conecte-se ao MySQL:

```bash
mysql -u root -p
```

Crie o banco de dados:

```sql
CREATE DATABASE print_logs
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

---

## 2️⃣ Criação do Usuário de Acesso

Crie um usuário exclusivo para o projeto:

```sql
CREATE USER 'printlog_user'@'%' IDENTIFIED BY 'SenhaForteAqui';
```

> 🔐 Recomenda-se utilizar senha forte e, se possível, restringir o host (`localhost` ou IP específico).

---

## 3️⃣ Concessão de Permissões

Conceda permissões apenas no banco do projeto:

```sql
GRANT SELECT, INSERT, UPDATE
ON print_logs.*
TO 'printlog_user'@'%';
```

Aplique as permissões:

```sql
FLUSH PRIVILEGES;
```

---

## 4️⃣ Selecionar o Banco de Dados

```sql
USE print_logs;
```

---

## 5️⃣ Criação da Tabela de Logs de Impressão

Estrutura sugerida da tabela principal:

```sql
CREATE TABLE print_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_time DATETIME NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    printer_name VARCHAR(255) NOT NULL,
    document_name VARCHAR(255),
    pages INT DEFAULT 0,
    computer_name VARCHAR(255),
    job_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

---

## 6️⃣ Descrição dos Campos

| Campo | Descrição |
|------|----------|
| id | Identificador único do registro |
| event_time | Data e hora do evento de impressão |
| user_name | Usuário que realizou a impressão |
| printer_name | Impressora utilizada |
| document_name | Nome do documento impresso |
| pages | Quantidade de páginas |
| computer_name | Computador de origem |
| job_id | ID do trabalho de impressão |
| created_at | Data de inserção no banco |

---

## 7️⃣ Índices Recomendados (Opcional)

Para melhor performance em consultas e dashboards:

```sql
CREATE INDEX idx_event_time ON print_logs(event_time);
CREATE INDEX idx_user_name ON print_logs(user_name);
CREATE INDEX idx_printer_name ON print_logs(printer_name);
```

---

## 8️⃣ Teste de Inserção

Teste manual de inserção:

```sql
INSERT INTO print_logs (
    event_time,
    user_name,
    printer_name,
    document_name,
    pages,
    computer_name,
    job_id
) VALUES (
    NOW(),
    'usuario.teste',
    'IMPRESSORA-01',
    'documento_teste.pdf',
    2,
    'PC-TESTE',
    12345
);
```

Valide os dados:

```sql
SELECT * FROM print_logs ORDER BY id DESC;
```

---

## 📊 Integração com Grafana

- Configure o MySQL como **Data Source**
- Utilize consultas SQL para análises por:
  - Usuário
  - Impressora
  - Período
  - Volume de páginas

---

## 📌 Boas Práticas

- Utilizar usuário dedicado
- Evitar permissões excessivas
- Criar índices conforme crescimento da base
- Monitorar tamanho do banco
- Implementar rotina de backup

---

## 📄 Observações Finais

A estrutura apresentada pode ser adaptada conforme a necessidade do ambiente, desde que mantenha os campos essenciais para auditoria e análise.

Este banco é a base para todo o ecossistema de monitoramento de impressões.
