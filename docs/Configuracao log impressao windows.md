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
<img width="494" height="304" alt="image" src="https://github.com/user-attachments/assets/e45de9b6-ec21-4aa6-8ddd-c34dbd4476b2" />
<br>
<img width="270" height="76" alt="image" src="https://github.com/user-attachments/assets/d3ea7caa-6281-4441-9786-3867a5cd06cc" />

---

### 3️⃣ Habilitar o Log Operational

- Clique com o botão direito em **Operational**
- Selecione **Habilitar Log**

Após habilitado, o ícone ficará ativo e o Windows começará a registrar eventos de impressão.
<img width="881" height="589" alt="image" src="https://github.com/user-attachments/assets/0e162948-b9dd-4c37-bad6-4e0e69ebc125" />

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
<img width="600" height="438" alt="image" src="https://github.com/user-attachments/assets/0c973876-55ff-48e2-830d-95fbbea89251" />

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
<br>
<img width="446" height="296" alt="image" src="https://github.com/user-attachments/assets/6543e83a-7ea6-477a-89da-d272e697239b" />

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
