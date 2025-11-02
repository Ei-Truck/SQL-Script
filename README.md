# 🚚 dbEiTruck - Banco de Dados de Monitoramento de Viagens e Infrações

Este projeto contém o **modelo de banco de dados completo do sistema EiTruck**, utilizado para **gerenciar viagens, motoristas, caminhões, infrações, registros de ocorrências e mídia associada**.

O script inclui:
- Criação de todas as tabelas
- Relacionamentos (PK e FK)
- Cargas iniciais de dados (Localidades, Segmentos, Unidades, Usuários, Motoristas, Caminhões, Viagens, Infrações etc.)
- Estrutura para auditoria e análise

---

## 🛴 Foto do Modelo

<img width="1265" height="1033" alt="image" src="https://github.com/user-attachments/assets/b28d16d7-77fd-4a58-9d91-21d46093a1db" />


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

### 1️⃣ abra o arquivo `.sql` na sua ferramenta:
- DBeaver
- PgAdmin
- DataGrip
- psql terminal

### 2️⃣ Execute o script

---
