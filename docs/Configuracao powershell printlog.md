# Configuração do PowerShell para Coleta de Logs de Impressão (Windows → MySQL)

Este documento explica, de forma detalhada, como preparar o Windows e o PowerShell para executar o script **`PrintLog-To-MySQL.ps1`**, que lê eventos de impressão (**Event ID 307**) do log:

`Microsoft-Windows-PrintService/Operational`

e grava os dados em tabelas MySQL do tipo `printlog_<setor>` (uma tabela por unidade/setor).

---

## ✅ Pré-requisitos

### No Windows
- Serviço **Print Spooler** em execução
- Log de impressão habilitado no Event Viewer:
  - `Microsoft-Windows-PrintService/Operational` (habilitar “Operational”)
- Permissão para ler o log (recomendado executar como **Administrador**)

> Dica: se você for rodar com usuário não-admin, inclua o usuário no grupo **Event Log Readers** e valide acesso ao log.

### No MySQL
- Banco e tabela criados (veja o documento de criação do MySQL do projeto)
- Usuário MySQL com permissão para **INSERT** (e opcionalmente SELECT/UPDATE)

### Componentes necessários no Windows
- PowerShell 5.1+ (ou PowerShell 7+)
- **MySQL Connector/NET** instalado (para disponibilizar `MySql.Data.dll`)

---

## 1) Instalar o MySQL Connector/NET

Baixe e instale o **MySQL Connector/NET** (MSI). Exemplo:

- `mysql-connector-net-8.1.0.msi`

Após instalar, valide a DLL no caminho padrão (ajuste se necessário):

```
C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll
```

> Se sua versão for diferente, o diretório muda. O script depende desse caminho.

---

## 2) Preparar a pasta de execução e logs

O script utiliza por padrão a seguinte pasta (oculta no Windows) para **logs e arquivos de controle**:

```
C:\ProgramData\PrintLog
```

Dentro dessa pasta ele cria e atualiza:

- `PrintLog-To-MySQL.log` (log de informações)
- `PrintLog-To-MySQL-error.log` (log de erros)
- `last_recordid.txt` (controle anti-duplicação)

Você pode manter esse padrão ou alterar o **`$BasePath`**.

> 💡 Como a pasta `C:\ProgramData` é oculta por padrão, isso ajuda a “esconder” os arquivos de log e controle de usuários comuns.

---

## 3) Ajustar as configurações no script

Abra o arquivo:

```
scripts\PrintLog-To-MySQL.ps1
```

Na seção **CONFIGURAÇÕES**, ajuste os seguintes parâmetros:

### 3.1 Caminho da DLL do MySQL Connector
```powershell
$MySqlConnectorPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll"
```

### 3.2 Conexão com o MySQL
```powershell
$MySQLServer   = "SEU_IP_OU_HOST"
$MySQLPort     = 3306
$MySQLDatabase = "printlog"
$MySQLUser     = "usuario_mysql"
$MySQLPassword = "SENHA"
```

> ⚠️ **Segurança:** evite versionar senha no GitHub.  
> Recomendações:
> - usar um usuário MySQL dedicado com permissões mínimas
> - armazenar a senha fora do script (Credential Manager / arquivo protegido / variável de ambiente)
> - manter o repositório privado ou remover credenciais antes de publicar

### 3.3 Caminhos de logs e controle anti-duplicação
```powershell
$BasePath     = "C:\ProgramData\PrintLog"
$RecordIdFile = Join-Path $BasePath "last_recordid.txt"
```

O arquivo `last_recordid.txt` guarda o último **RecordId** processado no Event Viewer, garantindo que **não haja duplicação**.

### 3.4 Setor/Unidade (tabela por local)

Cada servidor/unidade pode ter um identificador próprio, usado tanto para **nome da tabela** no MySQL quanto para a coluna de **setor**:

```powershell
$Sector = "MATRIZ_SP"
```

- Esse valor será gravado na coluna `setor` e também compõe o nome da tabela:
  - Tabela resultante: `printlog_matriz_sp`  
  - Para outra unidade, por exemplo `"RJ_FILIAL1"`, a tabela será `printlog_rj_filial1`.

O próprio script garante a criação/verificação da tabela correspondente a cada setor, sem necessidade de criar manualmente no MySQL.

---

## 4) Como o script funciona (visão técnica)

### 4.1 Carrega a DLL
O script importa o assembly `MySql.Data.dll` para permitir conexão e comandos SQL:

```powershell
Import-Module $MySqlConnectorPath
```

### 4.2 Abre conexão no MySQL
Ele monta uma connection string e abre a conexão:

```powershell
$ConnectionString = "server=...;database=...;uid=...;pwd=...;"
$Connection.Open()
```

### 4.3 Busca eventos 307 e filtra por RecordId
O script lê os eventos 307 e filtra apenas os com `RecordId` maior que o último processado:

```powershell
$events = Get-WinEvent -FilterHashtable @{
  LogName = "Microsoft-Windows-PrintService/Operational"
  Id      = 307
} | Where-Object { $_.RecordId -gt $LastRecordId }
```

Depois ordena por RecordId (processamento em sequência).

### 4.4 Extrai os campos do evento
Ele usa `event.Properties[]` para coletar os dados do Event ID 307:

- `JobId`
- `DocumentName`
- `UserName`
- `Client`
- `PrinterName`
- `Address`
- `JobBytes`
- `PageCount`

### 4.5 Insere no MySQL com parâmetros
A inserção é feita com `INSERT INTO printlog_<setor> (...) VALUES (...)` usando parâmetros, reduzindo risco de SQL injection e problemas de escape.  
O `<setor>` vem do valor configurado em `$Sector` (por exemplo, `printlog_matriz_sp`, `printlog_rj_filial1`, etc.).

### 4.6 Atualiza o último RecordId processado
Ao inserir com sucesso, salva o `RecordId` no arquivo:

```
C:\ProgramData\PrintLog\last_recordid.txt
```

Se o script rodar novamente, ele continuará a partir desse ponto.

---

## 5) Executar manualmente para teste

Abra o PowerShell **como Administrador** e execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\caminho\do\repositorio\scripts
.\PrintLog-To-MySQL.ps1
```

### Validar logs gerados
Confira os arquivos:

- `C:\ProgramData\PrintLog\PrintLog-To-MySQL.log`
- `C:\ProgramData\PrintLog\PrintLog-To-MySQL-error.log`

### Validar no MySQL
No MySQL:

```sql
SELECT * FROM printlog_matriz_sp ORDER BY timecreated DESC LIMIT 20;
```

> Substitua `printlog_matriz_sp` pelo nome da tabela correspondente ao valor que você usou em `$Sector`.

---

## 6) Automatização (Recomendado)

### Opção A — Agendador de Tarefas (Task Scheduler)
Ideal para rodar a cada X minutos (ex.: a cada 1, 5 ou 10 minutos).

**Programa/script:**
```
powershell.exe
```

**Argumentos:**
```
-NoProfile -ExecutionPolicy Bypass -File "C:\PrintLog\scripts\PrintLog-To-MySQL.ps1"
```

> Ajuste o caminho conforme onde você armazenou o script.

**Configurações recomendadas:**
- “Executar estando o usuário logado ou não”
- “Executar com privilégios mais altos”
- Definir uma conta de serviço (se necessário) com permissão de leitura no Event Viewer

### Opção B — Trigger por Evento (avançado)
Rodar quando surgir um Event ID 307 pode funcionar, mas pode gerar muitas execuções.  
Na prática, **Task Scheduler com intervalo fixo** costuma ser mais estável.

---

## 7) Troubleshooting

### “Access is denied” no Get-WinEvent
- Execute como Administrador
- Ou adicione o usuário no grupo **Event Log Readers**
- Garanta que o log PrintService/Operational está habilitado

### Erro ao carregar `MySql.Data.dll`
- Confirme se o Connector/NET está instalado
- Ajuste o caminho em `$MySqlConnectorPath`

### Script insere duplicado
- Este script controla duplicação por `RecordId`
- Verifique se o arquivo `C:\ProgramData\PrintLog\last_recordid.txt` está sendo atualizado
- Se necessário, apague o arquivo para “reiniciar” a coleta (isso pode reprocessar eventos antigos)

### Não aparecem eventos 307
- Confirme que o log Operational está habilitado
- Faça uma impressão de teste
- Verifique no Event Viewer se o evento 307 está sendo gerado

---

## 📌 Observações Importantes

- **Não versionar senhas** no GitHub (mesmo em repositório privado, é boa prática remover).
- Garanta que o MySQL esteja acessível pela rede (porta 3306 liberada conforme política).
- Em ambientes com alto volume de impressão, ajuste:
  - intervalos de execução
  - índices no MySQL
  - retenção do Event Viewer

---
