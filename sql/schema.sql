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
-- Tabela principal de logs de impressão
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS print_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Identificação do evento
    record_id BIGINT NOT NULL COMMENT 'RecordId do Event Viewer',
    event_time DATETIME NOT NULL COMMENT 'Data/hora do evento de impressão',

    -- Informações do trabalho de impressão
    job_id INT COMMENT 'ID do job de impressão',
    document_name VARCHAR(255) COMMENT 'Nome do documento impresso',
    pages INT DEFAULT 0 COMMENT 'Quantidade de páginas',
    job_bytes BIGINT COMMENT 'Tamanho do job em bytes',

    -- Usuário e origem
    user_name VARCHAR(255) NOT NULL COMMENT 'Usuário que realizou a impressão',
    computer_name VARCHAR(255) COMMENT 'Computador de origem',

    -- Impressora
    printer_name VARCHAR(255) NOT NULL COMMENT 'Nome da impressora',
    printer_port VARCHAR(255) COMMENT 'Porta/IP da impressora',

    -- Controle
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de inserção no banco',

    -- Garantia de não duplicidade
    UNIQUE KEY uk_record_id (record_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Índices para performance (Grafana / relatórios)
-- ------------------------------------------------------------
CREATE INDEX idx_event_time ON print_logs(event_time);
CREATE INDEX idx_user_name ON print_logs(user_name);
CREATE INDEX idx_printer_name ON print_logs(printer_name);
CREATE INDEX idx_computer_name ON print_logs(computer_name);

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
-- SELECT * FROM print_logs ORDER BY event_time DESC LIMIT 10;
