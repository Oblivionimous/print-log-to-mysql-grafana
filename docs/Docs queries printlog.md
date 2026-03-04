# Documentação das Queries – Logs de Impressão (MySQL)

Este documento descreve **todas as queries utilizadas no projeto de Logs de Impressão**, explicando **objetivo, uso e contexto no Grafana**.  
As consultas assumem uma tabela com a mesma estrutura do `printlog` original; no modelo atual, essa tabela é criada automaticamente com o nome `printlog_<setor>` (por exemplo, `printlog_matriz_sp`).

---

## 📊 Gráfico de Impressões Mensais (por usuário)

### Objetivo
Exibir o **total de páginas impressas por usuário no mês atual**, ordenado do maior para o menor.

```sql
SELECT
    user AS usuario,
    SUM(totalpages) AS value
FROM printlog_matriz_sp
WHERE MONTH(timecreated) = MONTH(NOW())
  AND YEAR(timecreated) = YEAR(NOW())
GROUP BY user
ORDER BY value DESC;
```

---

## 👤 Número de Impressões por Usuário (Hoje)

```sql
SELECT 
    user AS usuario,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
WHERE DATE(timecreated) = CURRENT_DATE()
GROUP BY user
ORDER BY total_paginas DESC;
```

---

## 🖨️ Número de Impressões por Impressora (Hoje)

```sql
SELECT 
    printer AS impressora,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
WHERE DATE(timecreated) = CURRENT_DATE()
GROUP BY printer
ORDER BY total_paginas DESC;
```

---

## 📄 Total de Páginas Impressas (Geral)

```sql
SELECT 
    SUM(totalpages) AS total_impresso
FROM printlog_matriz_sp;
```

---

## 📅 Total de Impressões no Mês Atual

```sql
SELECT 
    SUM(totalpages) AS total_paginas_mes
FROM printlog_matriz_sp
WHERE 
    YEAR(timecreated) = YEAR(CURRENT_DATE())
    AND MONTH(timecreated) = MONTH(CURRENT_DATE());
```

---

## ⏮️ Total de Páginas Impressas Ontem

```sql
SELECT 
    SUM(totalpages) AS total_ontem
FROM printlog_matriz_sp
WHERE DATE(timecreated) = DATE(NOW() - INTERVAL 1 DAY);
```

---

## 📆 Total de Páginas Impressas Hoje

```sql
SELECT 
    SUM(totalpages) AS total_hoje
FROM printlog_matriz_sp
WHERE DATE(timecreated) = CURRENT_DATE();
```

---

## 🏆 TOP 10 – Uso de Impressoras Hoje

```sql
SELECT
    printer AS impressora,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
WHERE DATE(timecreated) = CURRENT_DATE()
GROUP BY printer
ORDER BY total_paginas DESC
LIMIT 10;
```

---

## 🏆 TOP 10 – Uso por Login (Mensal)

```sql
SELECT 
    user AS usuario,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
WHERE 
    YEAR(timecreated) = YEAR(CURRENT_DATE())
    AND MONTH(timecreated) = MONTH(CURRENT_DATE())
GROUP BY user
ORDER BY total_paginas DESC
LIMIT 10;
```

---

## 🏆 TOP 10 – Uso de Impressoras (Mensal)

```sql
SELECT
    printer AS impressora,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
WHERE MONTH(timecreated) = MONTH(CURDATE())
  AND YEAR(timecreated) = YEAR(CURDATE())
GROUP BY printer
ORDER BY total_paginas DESC
LIMIT 10;
```

---

## 📈 Quantidade de Impressões por Mês (Últimos 12 Meses)

```sql
SELECT
    DATE_FORMAT(timecreated, '%Y-%m')  AS ano_mes,
    DATE_FORMAT(timecreated, '%M %Y') AS mes,
    SUM(totalpages)                  AS total_paginas
FROM printlog_matriz_sp
WHERE timecreated >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY ano_mes, mes
ORDER BY ano_mes;
```

---

## 📆 Quantidade de Impressões por Dia

```sql
SELECT 
    DATE(timecreated) AS dia,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
GROUP BY DATE(timecreated)
ORDER BY dia ASC;
```

---

## 🖨️ Número de Impressões por Impressora (Total)

```sql
SELECT 
    printer AS impressora,
    SUM(totalpages) AS total_paginas
FROM printlog_matriz_sp
GROUP BY printer
ORDER BY total_paginas DESC;
```

---

## 📜 Logs Detalhados de Impressão

```sql
SELECT 
    jobid AS trabalho,
    DATE_FORMAT(timecreated, '%d/%m/%Y') AS data,
    DATE_FORMAT(timecreated, '%H:%i:%s') AS hora,
    client AS estacao,
    user AS usuario,
    printer AS impressora,
    filename AS arquivo,
    jobbytes AS tamanho,
    pagecount AS paginas,
    totalpages AS total
FROM printlog_matriz_sp
ORDER BY timecreated DESC
LIMIT 500;
```

---

## 📌 Observações Gerais

- `timecreated` deve ser usado como **campo de tempo no Grafana**
- `totalpages` é a métrica principal de volume
- Substitua `printlog_matriz_sp` pelo nome da tabela correspondente ao valor configurado em `$Sector` no script (por exemplo, `printlog_rj_filial1`).
- Caso você utilize uma **view consolidando várias tabelas de unidades**, pode apontar todas essas queries para essa view em vez de uma tabela única.
