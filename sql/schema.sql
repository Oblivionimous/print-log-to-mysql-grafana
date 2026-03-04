-- ============================================================
-- Schema MySQL - Logs de Impressão do Windows (PrintService)
-- Projeto: Print Log to MySQL + Grafana
-- ============================================================
-- Este schema cria a estrutura necessária para armazenar
-- eventos de impressão (Event ID 307) coletados via PowerShell.
-- ============================================================

-- ------------------------------------------------------------
-- Banco de dados
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS printlog
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE printlog;

-- ------------------------------------------------------------
-- Tabela exemplo de logs de impressão para uma unidade/setor
-- ------------------------------------------------------------
-- O script PowerShell cria automaticamente tabelas no formato:
--   printlog_<setor>
-- Exemplo abaixo para o setor "MATRIZ_SP" (tabela printlog_matriz_sp).

CREATE TABLE IF NOT EXISTS printlog_matriz_sp (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Campos alinhados com o script PrintLog-To-MySQL.ps1
    address     VARCHAR(255) COMMENT 'Endereço/IP da impressora',
    pagecount   INT          COMMENT 'Quantidade de páginas do job',
    jobbytes    BIGINT       COMMENT 'Tamanho do job em bytes',
    client      VARCHAR(255) COMMENT 'Estação/computador de origem',
    eventid     INT          COMMENT 'ID do evento do Windows (ex.: 307)',
    jobid       BIGINT       COMMENT 'ID do job de impressão',
    timecreated DATETIME     COMMENT 'Data/hora do evento de impressão',
    filename    VARCHAR(255) COMMENT 'Nome do documento impresso',
    user        VARCHAR(255) COMMENT 'Usuário que realizou a impressão',
    printer     VARCHAR(255) COMMENT 'Nome da impressora',
    totalpages  INT          COMMENT 'Total de páginas impressas',
    setor       VARCHAR(255) COMMENT 'Identificador da unidade/setor (ex.: MATRIZ_SP)',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de inserção no banco'
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Índices para performance (Grafana / relatórios)
-- ------------------------------------------------------------
CREATE INDEX idx_timecreated_matriz_sp ON printlog_matriz_sp(timecreated);
CREATE INDEX idx_user_matriz_sp        ON printlog_matriz_sp(user);
CREATE INDEX idx_printer_matriz_sp     ON printlog_matriz_sp(printer);
CREATE INDEX idx_client_matriz_sp      ON printlog_matriz_sp(client);
CREATE INDEX idx_eventid_matriz_sp     ON printlog_matriz_sp(eventid);

-- ------------------------------------------------------------
-- Exemplo de usuário dedicado (opcional)
-- Ajuste host, usuário e senha conforme política de segurança
-- ------------------------------------------------------------
-- CREATE USER 'printlog_user'@'%' IDENTIFIED BY 'SenhaForteAqui';
-- GRANT INSERT, SELECT ON printlog.* TO 'printlog_user'@'%';
-- FLUSH PRIVILEGES;

-- ------------------------------------------------------------
-- Consulta de validação
-- ------------------------------------------------------------
-- SELECT * FROM printlog_matriz_sp ORDER BY timecreated DESC LIMIT 10;
