# Configuração de Log de Impressão no Windows (PrintService)

Este documento descreve o **passo a passo para habilitar e validar os logs de impressão no Windows**, necessários para projetos de auditoria, integração com PowerShell, MySQL e Grafana.

---

## 🎯 Objetivo

Habilitar o log **Microsoft-Windows-PrintService/Operational**, que registra eventos detalhados de impressão, incluindo:

- Usuário que imprimiu
- Impressora utilizada
- Documento
- Quantidade de páginas
- Data e hora

O principal evento utilizado é o **Event ID 307**.

---

## 🖥️ Sistemas Compatíveis

- Windows Server 2012 / 2016 / 2019 / 2022
- Windows 10 / 11
- Servidor de Impressão (Print Server)

---

## ✅ Pré-requisitos

- Serviço **Print Spooler** ativo
- Usuário com permissões administrativas
- Impressoras já instaladas e em funcionamento

---

## 🔧 Passo a Passo – Habilitar Log de Impressão

### 1️⃣ Abrir o Visualizador de Eventos

- Pressione `Win + R`
- Digite:
  ```
  eventvwr.msc
  ```
- Pressione **Enter**

---

### 2️⃣ Navegar até o Log de Impressão

No painel esquerdo, siga o caminho:

```
Visualizador de Eventos
└── Logs de Aplicativos e Serviços
    └── Microsoft
        └── Windows
            └── PrintService
```

---

### 3️⃣ Habilitar o Log Operational

- Clique com o botão direito em **Operational**
- Selecione **Habilitar Log**

Após habilitado, o ícone ficará ativo e o Windows começará a registrar eventos de impressão.

---

## 🧾 Eventos Importantes

### 🔑 Event ID 307 (Principal)

Evento gerado **a cada impressão concluída**.

Informações disponíveis:
- Usuário
- Impressora
- Documento
- Número de páginas
- Tamanho do trabalho
- Computador de origem

Este é o evento utilizado para integração com PowerShell e banco de dados.

---

### Outros eventos úteis

| Event ID | Descrição |
|--------|----------|
| 805 | Trabalho de impressão iniciado |
| 806 | Trabalho de impressão concluído |
| 842 | Falha de impressão |

---

## 🔍 Validando o Funcionamento

1. Envie um documento para impressão
2. No log **PrintService → Operational**, verifique se surgiu um evento **ID 307**
3. Clique no evento e valide os dados exibidos

Se o evento aparecer, o log está funcionando corretamente.

---

## ⚙️ Habilitar via Linha de Comando (Opcional)

Também é possível habilitar o log via **PowerShell**:

```powershell
wevtutil sl Microsoft-Windows-PrintService/Operational /e:true
```

Para validar o status:

```powershell
wevtutil gl Microsoft-Windows-PrintService/Operational
```

---

## 🧪 Teste Rápido

Execute no PowerShell para listar os últimos eventos:

```powershell
Get-WinEvent -LogName "Microsoft-Windows-PrintService/Operational" -MaxEvents 5 |
Select TimeCreated, Id, Message
```

---

## 📌 Boas Práticas

- Manter o log ativo apenas no **servidor de impressão**
- Ajustar retenção do log conforme volume
- Integrar com script para evitar crescimento excessivo
- Monitorar espaço em disco

---

## 📚 Referências

- Microsoft – Print Service Logging  
  https://support.microsoft.com/en-us/kb/919736

- Huttel – Log de Impressões no Windows  
  https://www.huttel.com.br/2016/07/salvar-log-de-impressoes-do-windows-server-2012-em-banco-de-dados-mysql/

---

## 📝 Observação Final

Sem este log habilitado, **nenhum script ou integração conseguirá capturar os eventos de impressão**.  
Esta etapa é obrigatória para qualquer solução de auditoria de impressão baseada em Event Viewer.
