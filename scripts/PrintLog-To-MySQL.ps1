<#
    Script: PrintLog-To-MySQL.ps1
    Função: Ler eventos 307 do log de impressão do Windows e gravar no MySQL (tabela printlog)
    Versão: 26/11/2025 – Mauro Paiva – DUPLICAÇÕES CORRIGIDAS (RecordId)
#>

# ========================
# 1. CONFIGURAÇÕES
# ========================

$MySqlConnectorPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.1.0\MySql.Data.dll"

$MySQLServer   = "xxx.xxx.xxx"
$MySQLPort     = 3306
$MySQLDatabase = "printlog"
$MySQLUser     = "user"
$MySQLPassword = "senha_forte"

# Identificação da unidade / setor (personalizar por servidor/local)
$Sector = "MATRIZ_SP"

# Prefixo base do nome da tabela (uma tabela por unidade/setor)
$MySQLTablePrefix = "printlog"

# Diretórios e logs (usar ProgramData, que é oculto para usuários comuns)
$BasePath        = "C:\ProgramData\PrintLog"
$InfoLogFile     = Join-Path $BasePath "PrintLog-To-MySQL.log"
$ErrorLogFile    = Join-Path $BasePath "PrintLog-To-MySQL-error.log"
$RecordIdFile    = Join-Path $BasePath "last_recordid.txt"

if (-not (Test-Path $BasePath)) {
    New-Item -Path $BasePath -ItemType Directory -Force | Out-Null
}

# Monta nome da tabela a partir do prefixo e do setor
function Get-TableName {
    param(
        [string]$BaseName,
        [string]$Sector
    )

    # Sanitiza o setor para uso em nome de tabela (apenas letras, números e underscore)
    $safeSector = ($Sector -replace '[^A-Za-z0-9_]', '_').ToLower()
    return "{0}_{1}" -f $BaseName, $safeSector
}

$MySQLTableName = Get-TableName -BaseName $MySQLTablePrefix -Sector $Sector

# ========================
# 2. FUNÇÕES AUXILIARES
# ========================

function Write-LogInfo {
    param([string]$Message)
    $line = "{0} - {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $InfoLogFile -Value $line
}

function Write-LogError {
    param([string]$Message)
    $line = "{0} - ERROR - {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $ErrorLogFile -Value $line
}

function Convert-ToAmericanDateFormat {
    param([datetime]$dateTime)
    return $dateTime.ToString("yyyy-MM-dd HH:mm:ss")
}

# Controle por RecordId (NÃO DUPLICA JAMAIS)
function Get-LastRecordId {
    if (Test-Path $RecordIdFile) {
        try {
            return [int64](Get-Content $RecordIdFile)
        } catch {
            return 0
        }
    }
    return 0
}

function Set-LastRecordId {
    param([long]$RecordId)
    Set-Content -Path $RecordIdFile -Value $RecordId -Encoding UTF8
}

function Insert-PrintLogData {
    param(
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]  $TableName,
        [string]  $Sector,
        [string]  $Address,
        [int]     $PageCount,
        [long]    $JobBytes,
        [string]  $Client,
        [int]     $EventId,
        [long]    $JobId,
        [datetime]$TimeCreated,
        [string]  $FileName,
        [string]  $UserName,
        [string]  $PrinterName,
        [int]     $TotalPages
    )

    $americanDateTime = Convert-ToAmericanDateFormat -dateTime $TimeCreated

    $query = @"
INSERT INTO $TableName
(address, pagecount, jobbytes, client, eventid, jobid, timecreated, filename, user, printer, totalpages, setor)
VALUES (@address, @pagecount, @jobbytes, @client, @eventid, @jobid, @timecreated, @filename, @user, @printer, @totalpages, @setor)
"@

    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $query

    $cmd.Parameters.AddWithValue("@address",     $Address)     | Out-Null
    $cmd.Parameters.AddWithValue("@pagecount",   $PageCount)   | Out-Null
    $cmd.Parameters.AddWithValue("@jobbytes",    $JobBytes)    | Out-Null
    $cmd.Parameters.AddWithValue("@client",      $Client)      | Out-Null
    $cmd.Parameters.AddWithValue("@eventid",     $EventId)     | Out-Null
    $cmd.Parameters.AddWithValue("@jobid",       $JobId)       | Out-Null
    $cmd.Parameters.AddWithValue("@timecreated", $americanDateTime) | Out-Null
    $cmd.Parameters.AddWithValue("@filename",    $FileName)    | Out-Null
    $cmd.Parameters.AddWithValue("@user",        $UserName)    | Out-Null
    $cmd.Parameters.AddWithValue("@printer",     $PrinterName) | Out-Null
    $cmd.Parameters.AddWithValue("@totalpages",  $TotalPages)  | Out-Null
    $cmd.Parameters.AddWithValue("@setor",       $Sector)      | Out-Null

    [void]$cmd.ExecuteNonQuery()
}

function Ensure-TableExists {
    param(
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [string]$TableName
    )

    $ddl = @"
CREATE TABLE IF NOT EXISTS $TableName (
    id INT AUTO_INCREMENT PRIMARY KEY,
    address     VARCHAR(255),
    pagecount   INT,
    jobbytes    BIGINT,
    client      VARCHAR(255),
    eventid     INT,
    jobid       BIGINT,
    timecreated DATETIME,
    filename    VARCHAR(255),
    user        VARCHAR(255),
    printer     VARCHAR(255),
    totalpages  INT,
    setor       VARCHAR(255),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $ddl
    [void]$cmd.ExecuteNonQuery()
}

# ========================
# 3. CARREGAR DLL DO MYSQL
# ========================

try {
    Import-Module $MySqlConnectorPath -ErrorAction Stop
    Write-LogInfo "MySql.Data.dll carregado."
}
catch {
    Write-LogError "Erro ao carregar MySql.Data.dll: $($_.Exception.Message)"
    throw
}

# ========================
# 4. CONECTAR AO MYSQL
# ========================

$ConnectionString = "server=$MySQLServer;port=$MySQLPort;database=$MySQLDatabase;uid=$MySQLUser;pwd=$MySQLPassword;charset=utf8;"
$Connection = New-Object MySql.Data.MySqlClient.MySqlConnection($ConnectionString)

try {
    $Connection.Open()
    Write-LogInfo "Conexão MySQL aberta com sucesso."

    # Garante que a tabela para este setor exista
    Ensure-TableExists -Connection $Connection -TableName $MySQLTableName
    Write-LogInfo "Tabela $MySQLTableName verificada/criada com sucesso."
}
catch {
    Write-LogError "Erro ao abrir conexão MySQL ou criar tabela: $($_.Exception.Message)"
    throw
}

# ========================
# 5. BUSCAR EVENTOS 307 (SEM DUPLICAR)
# ========================

try {
    $LastRecordId = Get-LastRecordId
    Write-LogInfo "Último RecordId processado: $LastRecordId"

    # Buscar apenas eventos acima do último RecordId
    $events = Get-WinEvent -FilterHashtable @{
        LogName = "Microsoft-Windows-PrintService/Operational"
        Id      = 307
    } | Where-Object { $_.RecordId -gt $LastRecordId }

    $events = $events | Sort-Object RecordId

    if (-not $events) {
        Write-LogInfo "Nenhum novo evento encontrado."
    }
    else {
        $countInserted = 0

        foreach ($event in $events) {

            # Extração dos campos do Windows
            $jobId        = [long]   $event.Properties[0].Value
            $documentName = [string] $event.Properties[1].Value
            $userName     = [string] $event.Properties[2].Value
            $client       = [string] $event.Properties[3].Value
            $printerName  = [string] $event.Properties[4].Value
            $addressRaw   = [string] $event.Properties[5].Value
            $jobBytes     = [long]   $event.Properties[6].Value
            $pageCount    = [int]    $event.Properties[7].Value

            # Extrair APENAS ip cru
            $Address = ($addressRaw -replace '\\','').Trim()

            # Inserir no MySQL
            try {
                Insert-PrintLogData `
                    -Connection  $Connection `
                    -TableName   $MySQLTableName `
                    -Sector      $Sector `
                    -Address     $Address `
                    -PageCount   $PageCount `
                    -JobBytes    $JobBytes `
                    -Client      $Client `
                    -EventId     307 `
                    -JobId       $jobId `
                    -TimeCreated $event.TimeCreated `
                    -FileName    $documentName `
                    -UserName    $userName `
                    -PrinterName $printerName `
                    -TotalPages  $pageCount

                $countInserted++

                # Atualiza RecordId
                Set-LastRecordId $event.RecordId
            }
            catch {
                Write-LogError "Erro ao inserir RecordId $($event.RecordId): $($_.Exception.Message)"
            }
        }

        Write-LogInfo "Eventos inseridos: $countInserted"
    }
}
catch {
    Write-LogError "Erro geral ao processar eventos 307: $($_.Exception.Message)"
}
finally {
    $Connection.Close()
    Write-LogInfo "Conexão MySQL fechada."
}
