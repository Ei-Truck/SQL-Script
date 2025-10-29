# 🚚 dbEiTruck - Banco de Dados de Monitoramento de Viagens e Infrações

Este projeto contém o **modelo de banco de dados completo do sistema EiTruck**, utilizado para **gerenciar viagens, motoristas, caminhões, infrações, registros de ocorrências e mídia associada**.

O script inclui:
- Criação de todas as tabelas
- Relacionamentos (PK e FK)
- Cargas iniciais de dados (Localidades, Segmentos, Unidades, Usuários, Motoristas, Caminhões, Viagens, Infrações etc.)
- Estrutura para auditoria e análise

---

## 🧱 Modelo Lógico (Visão Geral)

A base foi organizada em **entidades principais**:

| Entidade | Descrição |
|---------|-----------|
| **tb_usuario** | Usuários da aplicação (analistas, administradores, etc). |
| **tb_motorista** | Motoristas associados às viagens. |
| **tb_caminhao** | Frota de caminhões cadastrados. |
| **tb_viagem** | Registro de viagens com origem, destino e períodos. |
| **tb_infracao** | Eventos de infração ocorridos durante a viagem. |
| **tb_registro** | Tratativas e anotações feitas após a análise. |
| **tb_midia_infracao** | Mídias referentes às infrações (vídeo/imagem). |
| **tb_midia_concatenada** | Vídeos gerados pela concatenação de ocorrências. |

Além disso, existem tabelas de apoio como:
`tb_tipo_gravidade`, `tb_tipo_infracao`, `tb_localidade`, `tb_unidade`, `tb_segmento`, `tb_tipo_risco`, `tb_cargo`.

---

## 🔗 Relacionamentos Importantes

- **Um motorista pode ter várias viagens**
- **Uma viagem pode ter várias infrações**
- **Uma infração pode possuir várias mídias**
- **Cada viagem pode ter um vídeo final concatenado por motorista**

---

## 📦 Como Executar o Script

### 1️⃣ Certifique-se de estar usando PostgreSQL
```sql
SELECT version();
```

### 2️⃣ Copie o conteúdo do arquivo `.sql` para sua ferramenta:
- DBeaver
- PgAdmin
- DataGrip
- psql terminal

### 3️⃣ Execute o script

---
