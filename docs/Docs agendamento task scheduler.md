# Agendamento do Script no Task Scheduler (Windows)

Este documento descreve **como agendar o script PowerShell de coleta de logs de impressão** utilizando o **Agendador de Tarefas do Windows (Task Scheduler)**, garantindo execução automática e contínua.

---

## 🎯 Objetivo

Automatizar a execução do script `PrintLog-To-MySQL.ps1` para que os eventos de impressão (**Event ID 307**) sejam coletados periodicamente e enviados ao MySQL sem intervenção manual.

---

## 🧩 Visão Geral

```
Windows Task Scheduler
 └─ PowerShell
     └─ PrintLog-To-MySQL.ps1
         └─ MySQL
             └─ Grafana / Relatórios
```

---

## ✅ Pré-requisitos

- Script PowerShell funcional e testado manualmente
- Log de impressão habilitado:
  - `Microsoft-Windows-PrintService/Operational`
- Usuário com permissão:
  - Leitura do Event Viewer
  - Execução de PowerShell
- Pasta de logs e controle criada automaticamente (ex.: `C:\ProgramData\PrintLog`)

---

## 1️⃣ Abrir o Agendador de Tarefas

- Pressione `Win + R`
- Digite:
  ```
  taskschd.msc
  ```
- Pressione **Enter**

---

## 2️⃣ Criar Nova Tarefa

No painel direito, clique em **Criar Tarefa…**

> ⚠️ Utilize **Criar Tarefa** e **não** “Criar Tarefa Básica”, pois precisamos de opções avançadas.

---

## 3️⃣ Aba Geral

Configure:

- **Nome:**  
  ```
  Coleta Logs de Impressão - MySQL
  ```
- **Descrição:**  
  ```
  Executa script PowerShell para coletar logs de impressão (Event ID 307) e gravar no MySQL.
  ```
- **Opções:**
  - ☑ Executar estando o usuário conectado ou não
  - ☑ Executar com privilégios mais altos
- **Configurar para:**  
  - Windows Server (versão correspondente)
<br>
<img width="632" height="486" alt="image" src="https://github.com/user-attachments/assets/e4fe9378-66ac-427f-8d12-9569ef50d8ee" />

---

## 4️⃣ Aba Disparadores (Triggers)

Clique em **Novo…**

### Exemplo recomendado (intervalo fixo)

- **Iniciar a tarefa:** Conforme agendamento
- **Configurações:**
  - Diariamente
  - Hora inicial: `00:00`
 <img width="627" height="518" alt="image" src="https://github.com/user-attachments/assets/fc48f7ff-65d9-4386-995b-85b595268ea9" />
<br>
<img width="623" height="515" alt="image" src="https://github.com/user-attachments/assets/0ca6969e-76c4-4378-82ef-26203572b228" />

- **Configurações avançadas:**
  - ☑ Repetir a tarefa a cada: `5 minutos`
  - Por uma duração de: `Indefinidamente`
  - ☑ Habilitado

> 🔎 Intervalos comuns:
> - 1 minuto → ambientes críticos
> - 5 minutos → uso geral (recomendado)
> - 10 minutos → baixo volume de impressão

---

## 5️⃣ Aba Ações

Clique em **Novo…**

### Ação: Iniciar um programa

- **Programa/script:**
  ```
  powershell.exe
  ```

- **Adicionar argumentos:**
  ```
  -NoProfile -ExecutionPolicy Bypass -File "C:\ProgramData\PrintLog\PrintLog-To-MySQL.ps1"
  ```

- **Iniciar em (opcional, recomendado):**
  ```
  C:\ProgramData\PrintLog
  ```
<img width="640" height="632" alt="image" src="https://github.com/user-attachments/assets/3c49d403-79b9-4dd7-994a-87e0be6f5cd8" />

---

## 6️⃣ Aba Condições

Recomendações:

- ❌ Desmarcar:
  - “Iniciar a tarefa somente se o computador estiver em energia AC” (se for servidor)
- ❌ Desmarcar:
  - “Parar se o computador mudar para bateria” (caso apareça) 
    
<img width="637" height="486" alt="image" src="https://github.com/user-attachments/assets/90b5f4a2-85ef-4a2b-87fc-d150a388bd56" />

---

## 7️⃣ Aba Configurações

Marcar:

- ☑ Permitir que a tarefa seja executada sob demanda
- ☑ Executar a tarefa o mais rápido possível após um início agendado ser perdido
- ☑ Se a tarefa falhar, reiniciar a cada: `1 minuto`
- Tentativas de reinício: `3`

Desmarcar:

- ❌ Parar a tarefa se ela for executada por mais de:
  - (o script deve ser rápido e finalizar sozinho)

<img width="633" height="482" alt="image" src="https://github.com/user-attachments/assets/66ee9502-450d-424b-8b26-343e786af142" />

---

## 8️⃣ Credenciais

Ao salvar a tarefa:

- Informe a senha do usuário configurado
- Recomenda-se:
  - Conta de serviço dedicada
  - Membro do grupo **Event Log Readers**
  - Permissão de leitura/gravação na pasta `C:\ProgramData\PrintLog`

---

## 9️⃣ Teste da Tarefa

Após criar:

1. Clique com o botão direito na tarefa
2. Selecione **Executar**
3. Verifique:
   - Arquivo `C:\ProgramData\PrintLog\PrintLog-To-MySQL.log`
   - Arquivo `C:\ProgramData\PrintLog\PrintLog-To-MySQL-error.log`
4. Valide inserções no MySQL

```sql
SELECT * FROM printlog_matriz_sp ORDER BY timecreated DESC LIMIT 10;
```

> Substitua `printlog_matriz_sp` pelo nome da tabela correspondente ao setor configurado em `$Sector` no script.

---

## 🔁 Alternativa: Trigger por Evento (Avançado)

É possível configurar a tarefa para disparar ao ocorrer o **Event ID 307**, porém:

- Pode gerar muitas execuções simultâneas
- Menos previsível em ambientes de alto volume

Na prática, **intervalo fixo é mais estável e recomendado**.

---

## 🛠️ Troubleshooting

### Tarefa executa, mas não grava no MySQL
- Verifique:
  - Caminho do script
  - Caminho do MySQL Connector/NET
  - Permissões do usuário
- Consulte o arquivo:
  ```
  C:\ProgramData\PrintLog\PrintLog-To-MySQL-error.log
  ```

### Tarefa não executa
- Verifique se:
  - “Executar com privilégios mais altos” está marcado
  - Usuário possui senha válida
  - Política de execução não está bloqueando (Bypass já configurado)

### Execução manual funciona, agendada não
- Normalmente indica:
  - Problema de permissão do usuário
  - Diretório “Iniciar em” não definido
  - Caminhos relativos no script

---

## 📌 Boas Práticas

- Usar usuário dedicado
- Manter logs do script
- Monitorar falhas no Task Scheduler
- Revisar periodicamente o tamanho dos logs
- Documentar alterações na tarefa

---

## 📄 Observação Final

O Task Scheduler é o método **mais simples, estável e recomendado** para automação da coleta de logs de impressão no Windows.

Após essa etapa, o pipeline de coleta passa a operar de forma contínua e transparente.
