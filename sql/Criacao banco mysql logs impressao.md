# Criação e Estrutura do Banco de Dados MySQL – Logs de Impressão

Este documento descreve a **estrutura real do banco de dados MySQL** utilizada no projeto **Print Log to MySQL + Grafana**, já **alinhada com a tabela existente em produção/lab** (`printlog`).

> ⚠️ Importante: este documento **não propõe recriação do banco em produção**.  
> Ele serve como **documentação técnica versionada** e referência para ambientes de laboratório.

---

## 🎯 Objetivo

Armazenar eventos de impressão do Windows (principalmente **Event ID 307**) coletados via PowerShell, possibilitando:

- Auditoria de impressões
- Análise histórica
- Dashboards no Grafana
- Controle de volume por usuário, impressora e período

---

## 🧩 Visão Geral da Arquitetura

```
Windows Print Server
 └─ Event Viewer (PrintService)
     └─ PowerShell
         └─ MySQL (printlog)
             └─ Grafana
```

---

## 📌 Banco de Dados

### Nome do banco
```sql
printlog
```

### Charset e Collation
- Charset: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

---

## 🗄️ Tabela Principal

### Nome da tabela
```sql
printlog
```

### Finalidade
Armazenar cada evento de impressão registrado no Windows, com informações completas do job, usuário, impressora e estação.

---

## 📐 Estrutura Real da Tabela

```sql
CREATE TABLE printlog (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    address VARCHAR(45),
    pagecount INT UNSIGNED,
    jobbytes BIGINT UNSIGNED,
    client VARCHAR(255),
    eventid INT,
    jobid BIGINT UNSIGNED,
    timecreated DATETIME,
    filename VARCHAR(512),
    user VARCHAR(255),
    printer VARCHAR(255),
    totalpages INT UNSIGNED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🧾 Descrição dos Campos

| Campo | Descrição |
|------|----------|
| id | Identificador interno (auto_increment) |
| address | Endereço/IP da impressora |
| pagecount | Quantidade de impressões (jobs) |
| jobbytes | Tamanho do arquivo impresso (bytes) |
| client | Estação/computador de origem |
| eventid | ID do evento do Windows (ex: 307) |
| jobid | ID do trabalho de impressão |
| timecreated | Data e hora do evento |
| filename | Nome do documento impresso |
| user | Usuário que realizou a impressão |
| printer | Nome da impressora |
| totalpages | Total de páginas impressas |
| created_at | Data de inserção no banco |

---

## ⚙️ Índices Recomendados

Para melhor desempenho em consultas e dashboards:

```sql
CREATE INDEX idx_timecreated ON printlog (timecreated);
CREATE INDEX idx_user ON printlog (user);
CREATE INDEX idx_printer ON printlog (printer);
CREATE INDEX idx_client ON printlog (client);
CREATE INDEX idx_eventid ON printlog (eventid);
```

---

## 🧪 Inserção Manual para Testes

Exemplo de inserção completa:

```sql
INSERT INTO printlog (
    address,
    pagecount,
    jobbytes,
    client,
    eventid,
    jobid,
    timecreated,
    filename,
    user,
    printer,
    totalpages
) VALUES (
    '10.96.10.45',
    1,
    4620288,
    '\\NOTEBOOK-MAURO',
    307,
    12345,
    '2025-06-15 10:22:00',
    'Documento_Teste.pdf',
    'usuario.teste',
    'IMPRESSORA-01',
    3
);
```

---

## 📊 Uso no Grafana

- Utilize a coluna `timecreated` como **campo de tempo**
- Agregações recomendadas:
  - `COUNT(*)` → total de jobs
  - `SUM(totalpages)` → volume de páginas
  - `SUM(jobbytes)` → volume de dados

---

## ⚠️ Boas Práticas

- Não armazenar valores formatados (ex: "4.5 MiB") no banco
- Sempre gravar tamanhos em **bytes**
- Converter unidades apenas na query ou no Grafana
- Evitar alterações estruturais diretas em produção
- Versionar alterações no schema no GitHub

---

## 📄 Observação Final

Esta estrutura está **validada com dados reais e simulados**, pronta para uso em produção e dashboards analíticos.

Qualquer ajuste futuro deve considerar impacto no script PowerShell e nos painéis do Grafana.
