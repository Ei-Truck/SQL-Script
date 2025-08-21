ROLLBACK;

BEGIN;

-- =============================
-- DROPS
-- =============================

drop table if exists tb_midia_infracao cascade;
drop table if exists tb_registro cascade;
drop table if exists tb_infracao cascade;
drop table if exists tb_tipo_infracao cascade;
drop table if exists tb_usuario cascade;
drop table if exists tb_cargo cascade;
drop table if exists tb_viagem cascade;
drop table if exists tb_localidade cascade;
drop table if exists tb_caminhao cascade;
drop table if exists tb_motorista cascade;
drop table if exists tb_tipo_risco cascade;
drop table if exists tb_unidade cascade;
drop table if exists tb_segmento cascade;
drop table if exists tb_status cascade;
drop table if exists tb_tipo_gravidade cascade;
drop view if exists vw_relatorio_simples_viagem;
drop view if exists vw_visao_basica_viagem;
drop view if exists vw_ocorrencia_por_viagem;

-- =============================
-- STATUS E TABELAS DE APOIO
-- =============================
CREATE TABLE tb_status (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(20) NOT NULL UNIQUE,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_gravidade (
    id         INTEGER PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_infracao (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    pontuacao  INTEGER NOT NULL,
    id_tipo_gravidade INTEGER REFERENCES tb_tipo_gravidade,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_localidade (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(80) NOT NULL UNIQUE,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_risco (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    descricao  TEXT,
    isinactive BOOLEAN DEFAULT FALSE
);

-- =============================
-- SEGMENTO E UNIDADE
-- =============================
CREATE TABLE tb_segmento (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(40) NOT NULL UNIQUE,
    id_status  INTEGER REFERENCES tb_status,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_unidade (
    id          SERIAL PRIMARY KEY,
    id_segmento INTEGER REFERENCES tb_segmento,
    nome        VARCHAR(100) NOT NULL,
    cidade      VARCHAR(50) NOT NULL,
    uf_estado   VARCHAR(2),
    isinactive  BOOLEAN DEFAULT FALSE
);

-- =============================
-- USUÁRIOS
-- =============================
CREATE TABLE tb_cargo (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(255) NOT NULL UNIQUE,
    isinactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_usuario (
    id             SERIAL PRIMARY KEY,
    cpf            VARCHAR(15) NOT NULL UNIQUE,
    id_unidade     INTEGER REFERENCES tb_unidade,
    id_perfil      INTEGER,
    dt_contratacao DATE,
    nome_completo  VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    hash_senha     VARCHAR(100) NOT NULL,
    url_foto       VARCHAR(255) DEFAULT 'Sem foto',
    id_status      INTEGER REFERENCES tb_status,
    id_cargo       INTEGER NOT NULL REFERENCES tb_cargo,
    isinactive     BOOLEAN DEFAULT FALSE
);

-- =============================
-- CAMINHÃO
-- =============================
CREATE TABLE tb_caminhao (
    id             SERIAL PRIMARY KEY,
    chassi         VARCHAR(20) NOT NULL UNIQUE,
    id_segmento    INTEGER REFERENCES tb_segmento,
    id_unidade     INTEGER REFERENCES tb_unidade,
    placa          VARCHAR(10) NOT NULL UNIQUE,
    modelo         VARCHAR(80) DEFAULT 'Não informado',
    ano_fabricacao INTEGER,
    numero_frota   INTEGER NOT NULL,
    id_status      INTEGER REFERENCES tb_status,
    isinactive     BOOLEAN DEFAULT FALSE
);

-- =============================
-- MOTORISTA
-- =============================
CREATE TABLE tb_motorista (
    id            SERIAL PRIMARY KEY,
    cpf           VARCHAR(15) NOT NULL UNIQUE,
    id_unidade    INTEGER REFERENCES tb_unidade,
    cnh           VARCHAR(15) NOT NULL UNIQUE,
    nome_completo VARCHAR(150) NOT NULL,
    telefone      VARCHAR(15) NOT NULL,
    email_empresa VARCHAR(150),
    risco         INTEGER REFERENCES tb_tipo_risco,
    url_foto      VARCHAR(255) DEFAULT 'Sem foto',
    id_status     INTEGER REFERENCES tb_status,
    isinactive    BOOLEAN DEFAULT FALSE
);

-- =============================
-- VIAGEM
-- =============================
CREATE TABLE tb_viagem (
    id           SERIAL PRIMARY KEY,
    id_caminhao  INTEGER NOT NULL REFERENCES tb_caminhao,
    id_motorista INTEGER NOT NULL REFERENCES tb_motorista,
    id_origem    INTEGER REFERENCES tb_localidade,
    id_destino   INTEGER REFERENCES tb_localidade,
    dt_hr_inicio TIMESTAMP,
    dt_hr_fim    TIMESTAMP,
    tratativa    TEXT,
    km_viagem    VARCHAR DEFAULT 'Não informado',
    isinactive   BOOLEAN DEFAULT FALSE
);

-- =============================
-- OCORRÊNCIA
-- =============================
CREATE TABLE tb_infracao (
    id                 SERIAL PRIMARY KEY,
    id_viagem          INTEGER REFERENCES tb_viagem,
    id_caminhao        INTEGER NOT NULL REFERENCES tb_caminhao,
    id_motorista       INTEGER NOT NULL REFERENCES tb_motorista,
    id_usuario         INTEGER REFERENCES tb_usuario,
    dt_hr_evento       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_tipo_infracao   INTEGER REFERENCES tb_tipo_infracao,
    latitude           NUMERIC(9, 7),
    longitude          NUMERIC(9, 7),
    velocidade_kmh     NUMERIC(5, 2),
    isinactive         BOOLEAN DEFAULT FALSE
);

-- =============================
-- MÍDIA DE OCORRÊNCIA
-- =============================
CREATE TABLE tb_midia_infracao (
    id             SERIAL PRIMARY KEY,
    id_infracao  INTEGER NOT NULL REFERENCES tb_infracao,
    arquivo        VARCHAR(250) NOT NULL,
    duracao_clipe  NUMERIC(6, 2),
    dt_hr_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    isinactive     BOOLEAN DEFAULT FALSE
);


-- =============================
-- LOAD
-- =============================

-- 1) STATUS
INSERT INTO tb_status (id, nome, isinactive) VALUES
(1, 'Ativo', false),
(2, 'Inativo', true),
(3, 'Em manutenção', false),
(4, 'Em trânsito', false),
(5, 'Bloqueado', true),
(6, 'Disponível', false),
(7, 'Em uso', false),
(8, 'Desativado', true),
(9, 'Pendente', false),
(10, 'Suspenso', true);

INSERT INTO tb_tipo_gravidade(id, nome, isinactive) VALUES
(1,'Não informado',false);

-- 2) TIPO_OCORRENCIA
INSERT INTO tb_tipo_infracao (id, nome, pontuacao,id_tipo_gravidade, isinactive) VALUES
(1, 'Excesso de velocidade', 5,1, false),
(2, 'Frenagem brusca', 3,1, false),
(3, 'Aceleração brusca', 3,1, false),
(4, 'Colisão', 10,1, false),
(5, 'Pane mecânica', 6,1, false),
(6, 'Desvio de rota', 4,1, true),
(7, 'Falha de comunicação', 2,1, false),
(8, 'Carga violada', 8,1, false),
(9, 'Parada não autorizada', 4,1, false),
(10, 'Uso não autorizado', 7,1, true);


-- 3) LOCALIDADE
INSERT INTO tb_localidade (id, nome, isinactive) VALUES
(1, 'São Paulo - SP', false),
(2, 'Campinas - SP', false),
(3, 'Rio de Janeiro - RJ', false),
(4, 'Curitiba - PR', false),
(5, 'Belo Horizonte - MG', false),
(6, 'Porto Alegre - RS', false),
(7, 'Recife - PE', false),
(8, 'Salvador - BA', false),
(9, 'Goiânia - GO', false),
(10, 'Fortaleza - CE', false);

-- 4) SEGMENTO
INSERT INTO tb_segmento (id, nome, id_status, isinactive) VALUES
(1, 'Transporte de Carga Seca', 1, false),
(2, 'Transporte Refrigerado', 6, false),
(3, 'Transporte de Combustível', 3, false),
(4, 'Transporte de Produtos Químicos', 1, false),
(5, 'Transporte de Gases', 1, false),
(6, 'Transporte Fracionado', 6, false),
(7, 'Transporte de Veículos', 7, false),
(8, 'Transporte de Encomendas', 1, false),
(9, 'Transporte de Animais', 9, false),
(10, 'Transporte Especial', 1, true);

-- 5) UNIDADE
INSERT INTO tb_unidade (id, id_segmento, nome, cidade, uf_estado, isinactive) VALUES
(1, 1, 'Unidade São Paulo', 'São Paulo', 'SP', false),
(2, 2, 'Unidade Campinas', 'Campinas', 'SP', false),
(3, 3, 'Unidade Rio', 'Rio de Janeiro', 'RJ', false),
(4, 4, 'Unidade Curitiba', 'Curitiba', 'PR', false),
(5, 5, 'Unidade BH', 'Belo Horizonte', 'MG', false),
(6, 6, 'Unidade Porto Alegre', 'Porto Alegre', 'RS', false),
(7, 7, 'Unidade Recife', 'Recife', 'PE', false),
(8, 8, 'Unidade Salvador', 'Salvador', 'BA', false),
(9, 9, 'Unidade Goiânia', 'Goiânia', 'GO', false),
(10, 10, 'Unidade Fortaleza', 'Fortaleza', 'CE', false);

-- 6) CARGO
INSERT INTO tb_cargo (id, nome, isinactive) VALUES
(1, 'Motorista', false),
(2, 'Supervisor de Frota', false),
(3, 'Mecânico', false),
(4, 'Analista de Risco', false),
(5, 'Coordenador de Operações', false),
(6, 'Gerente de Logística', false),
(7, 'Auxiliar Administrativo', false),
(8, 'Inspetor de Segurança', false),
(9, 'Encarregado de Manutenção', false),
(10, 'Diretor de Operações', false);

-- 7) USUARIO
INSERT INTO tb_usuario (id, cpf, id_unidade, id_perfil, dt_contratacao, nome_completo, email, hash_senha, id_status, id_cargo, isinactive) VALUES
(1, '123.456.789-09', 1, 1, '2018-05-10', 'João da Silva', 'joao.silva@empresa.com', 'hash1', 1, 2, false),
(2, '987.654.321-00', 2, 1, '2019-02-15', 'Maria Oliveira', 'maria.oliveira@empresa.com', 'hash2', 1, 4, false),
(3, '321.654.987-01', 3, 2, '2017-07-22', 'Carlos Souza', 'carlos.souza@empresa.com', 'hash3', 1, 6, false),
(4, '111.222.333-96', 4, 3, '2020-01-10', 'Fernanda Lima', 'fernanda.lima@empresa.com', 'hash4', 1, 5, false),
(5, '444.555.666-09', 5, 2, '2021-09-05', 'Ricardo Alves', 'ricardo.alves@empresa.com', 'hash5', 1, 7, false),
(6, '777.888.999-15', 6, 1, '2015-11-12', 'Paula Mendes', 'paula.mendes@empresa.com', 'hash6', 2, 8, false),
(7, '222.333.444-98', 7, 2, '2016-03-30', 'Bruno Ferreira', 'bruno.ferreira@empresa.com', 'hash7', 1, 9, false),
(8, '555.666.777-20', 8, 1, '2022-04-18', 'Aline Costa', 'aline.costa@empresa.com', 'hash8', 1, 3, false),
(9, '888.999.000-05', 9, 3, '2018-06-25', 'Gustavo Pereira', 'gustavo.pereira@empresa.com', 'hash9', 1, 10, false),
(10, '666.555.444-33', 10, 2, '2023-02-14', 'Larissa Martins', 'larissa.martins@empresa.com', 'hash10', 1, 1, false);

-- 8) TIPO_RISCO
INSERT INTO tb_tipo_risco (id, nome, descricao, isinactive) VALUES
(1, 'Baixo', 'Risco baixo de acidentes', false),
(2, 'Médio', 'Risco moderado', false),
(3, 'Alto', 'Risco elevado de acidentes', false),
(4, 'Crítico', 'Risco muito alto', false),
(5, 'Especial', 'Risco em cargas especiais', false),
(6, 'Ambiental', 'Risco ambiental', false),
(7, 'Químico', 'Risco relacionado a produtos químicos', false),
(8, 'Inflamável', 'Risco de incêndio', false),
(9, 'Explosivo', 'Risco de explosão', false),
(10, 'Biológico', 'Risco de contaminação', false);

-- 9) MOTORISTA
INSERT INTO tb_motorista (id, cpf, id_unidade, cnh, nome_completo, telefone, email_empresa, risco, id_status, isinactive) VALUES
(1, '123.123.123-12', 1, 'MG1234567', 'Paulo Gomes', '(11)98888-1111', 'paulo.gomes@empresa.com', 1, 1, false),
(2, '234.234.234-23', 2, 'SP2345678', 'Rodrigo Santos', '(19)97777-2222', 'rodrigo.santos@empresa.com', 2, 1, false),
(3, '345.345.345-34', 3, 'RJ3456789', 'Marcelo Almeida', '(21)96666-3333', 'marcelo.almeida@empresa.com', 3, 1, false),
(4, '456.456.456-45', 4, 'PR4567890', 'Felipe Rocha', '(41)95555-4444', 'felipe.rocha@empresa.com', 4, 1, false),
(5, '567.567.567-56', 5, 'MG5678901', 'Renato Dias', '(31)94444-5555', 'renato.dias@empresa.com', 5, 1, false),
(6, '678.678.678-67', 6, 'RS6789012', 'Eduardo Moraes', '(51)93333-6666', 'eduardo.moraes@empresa.com', 6, 1, false),
(7, '789.789.789-78', 7, 'PE7890123', 'André Ferreira', '(81)92222-7777', 'andre.ferreira@empresa.com', 7, 1, false),
(8, '890.890.890-89', 8, 'BA8901234', 'Thiago Campos', '(71)91111-8888', 'thiago.campos@empresa.com', 8, 1, false),
(9, '901.901.901-90', 9, 'GO9012345', 'Diego Farias', '(62)90000-9999', 'diego.farias@empresa.com', 9, 1, false),
(10, '012.012.012-01', 10, 'CE0123456', 'Rafael Souza', '(85)98888-0000', 'rafael.souza@empresa.com', 10, 1, false);

-- 10) CAMINHAO
INSERT INTO tb_caminhao (id, chassi, id_segmento, id_unidade, placa, modelo, ano_fabricacao, numero_frota, id_status, isinactive) VALUES
(1, '9BWZZZ377VT004251', 1, 1, 'BRA1A23', 'Volvo FH 540', 2019, 101, 1, false),
(2, '8AWZZZ377VT004252', 2, 2, 'BRA2B34', 'Scania R450', 2020, 102, 1, false),
(3, '7CWZZZ377VT004253', 3, 3, 'BRA3C45', 'Mercedes Actros', 2018, 103, 1, false),
(4, '6DWZZZ377VT004254', 4, 4, 'BRA4D56', 'Volvo VM 270', 2021, 104, 1, false),
(5, '5EWZZZ377VT004255', 5, 5, 'BRA4D51','Iveco Hi-Way', 2017, 105, 1, false),
(6, '4FWZZZ377VT004256', 6, 6, 'BRA4D52','MAN TGX', 2022, 106, 1, false),
(7, '3GWZZZ377VT004257', 7, 7, 'BRA4D53','Scania S500', 2019, 107, 1, false),
(8, '2HWZZZ377VT004258', 8, 8,'BRA4D54', 'Volvo FH 460', 2023, 108, 1, false),
(9, '1IWZZZ377VT004259', 9, 9, 'BRA4D55','Mercedes Axor', 2016, 109, 1, false),
(10, '0JWZZZ377VT004260', 10, 10,'BRA4D57', 'Volkswagen Constellation', 2015, 110, 1, false);

-- 12) VIAGEM
INSERT INTO tb_viagem (id, id_caminhao, id_motorista, id_origem, id_destino, dt_hr_inicio, dt_hr_fim, tratativa, isinactive) VALUES
(1, 1, 1, 1, 2, '2023-01-10 08:00:00', '2023-01-10 14:00:00', 'Registro sem ação.', false),
(2, 2, 2, 2, 3, '2023-02-15 09:15:00', '2023-02-15 16:40:00',  'Motorista advertido verbalmente.', false),
(3, 3, 3, 3, 4, '2023-03-05 07:30:00', '2023-03-05 19:20:00',  'Encaminhar para treinamento.', false),
(4, 4, 4, 4, 5, '2023-04-12 06:50:00', '2023-04-12 13:45:00',  'Suspensão de 3 dias.', false),
(5, 5, 5, 5, 6, '2023-05-20 08:10:00', '2023-05-20 15:55:00',  'Multa de R$ 500,00 aplicada.', false),
(6, 6, 6, 6, 7, '2023-06-18 10:00:00', '2023-06-18 17:40:00',  'Enviar veículo para revisão.', false),
(7, 7, 7, 7, 8, '2023-07-01 09:00:00', '2023-07-01 14:50:00',  'Seguro acionado.', false),
(8, 8, 8, 8, 9, '2023-08-08 05:40:00', '2023-08-08 12:30:00',  'Ocorrência encerrada.', false),
(9, 9, 9, 9, 10, '2023-09-22 06:10:00', '2023-09-22 15:15:00',  'Encaminhado à polícia.', false),
(10, 10, 10, 10, 1, '2023-10-05 08:30:00', '2023-10-05 17:00:00',  'Rota alterada conforme recomendação.', false);

-- 13) OCORRENCIA
INSERT INTO tb_infracao (id, id_viagem, id_caminhao, id_motorista, id_usuario, dt_hr_evento, id_tipo_infracao, latitude, longitude, velocidade_kmh, isinactive) VALUES
(1, 1, 1, 1, 1, '2023-01-10 10:15:00', 1, -23.550520, -46.633308, 95.5, false),
(2, 2, 2, 2, 2, '2023-02-15 11:30:00', 2, -22.909938, -47.062633, 80.0, false),
(3, 3, 3, 3, 3, '2023-03-05 13:10:00', 4, -22.906847, -43.172896, 60.0, false),
(4, 4, 4, 4, 4, '2023-04-12 09:20:00', 5, -25.428356, -49.273251, 50.0, false),
(5, 5, 5, 5, 5, '2023-05-20 12:45:00', 6, -19.916681, -43.934493, 70.0, false),
(6, 6, 6, 6, 6, '2023-06-18 14:30:00', 7, -30.034647, -51.217658, 65.0, false),
(7, 7, 7, 7, 7, '2023-07-01 11:00:00', 8, -8.047562, -34.877000, 40.0, false),
(8, 8, 8, 8, 8, '2023-08-08 08:30:00', 9, -12.977749, -38.501630, 55.0, false),
(9, 9, 9, 9, 9, '2023-09-22 10:20:00', 10, -16.686882, -49.264788, 50.0, false),
(10, 10, 10, 10, 10, '2023-10-05 12:45:00', 3, -3.731862, -38.526669, 85.0, false);

-- 14) MÍDIA DA OCORRÊNCIA
INSERT INTO tb_midia_infracao (id, id_infracao, arquivo, duracao_clipe, dt_hr_registro, isinactive) VALUES
(1, 1,  'ocorrencia1.mp4', 15.20, '2023-01-10 10:20:00', false),
(2, 2,  'ocorrencia2.mp4', 10.00, '2023-02-15 11:40:00', false),
(3, 3,  'ocorrencia3.mp4', 20.50, '2023-03-05 13:15:00', false),
(4, 4,  'ocorrencia4.mp4', 12.75, '2023-04-12 09:25:00', false),
(5, 5,  'ocorrencia5.mp4', 8.30, '2023-05-20 12:50:00', false),
(6, 6,  'ocorrencia6.mp4', 18.00, '2023-06-18 14:35:00', false),
(7, 7,  'ocorrencia7.mp4', 16.40, '2023-07-01 11:05:00', false),
(8, 8,  'ocorrencia8.mp4', 9.90, '2023-08-08 08:35:00', false),
(9, 9,  'ocorrencia9.mp4', 14.25, '2023-09-22 10:25:00', false),
(10, 10,  'ocorrencia10.mp4', 11.10, '2023-10-05 12:50:00', false);

-- =============================
-- VIEWS
-- =============================
CREATE VIEW vw_relatorio_simples_viagem (
    total_infracoes,
    placa_caminhao,
    data_inicio_viagem,
    id_infracao,
    id_viagem,
    id_caminhao
) AS
SELECT
    COUNT(o.id)    AS total_infracoes,
    c.placa        AS placa_caminhao,
    v.dt_hr_inicio AS data_inicio_viagem,
    o.id           AS id_infracao,
    v.id           AS id_viagem,
    c.id           AS id_caminhao
FROM tb_infracao o
JOIN tb_viagem v   ON o.id_viagem = v.id
JOIN tb_caminhao c ON v.id_caminhao = c.id
GROUP BY c.placa, v.dt_hr_inicio, o.id, v.id, c.id;

CREATE VIEW vw_visao_basica_viagem (
    placa_caminhao,
    data_inicio_viagem,
    data_fim_viagem,
    total_infracoes,
    nome_motorista,
    risco_motorista,
    id_viagem,
    id_motorista,
    id_tipo_risco,
    id_infracao,
    id_caminhao
) AS
SELECT
    c.placa         AS placa_caminhao,
    v.dt_hr_inicio  AS data_inicio_viagem,
    v.dt_hr_fim     AS data_fim_viagem,
    COUNT(o.id)     AS total_infracoes,
    m.nome_completo AS nome_motorista,
    tr.nome         AS risco_motorista,
    v.id            AS id_viagem,
    m.id            AS id_motorista,
    tr.id           AS id_tipo_risco,
    o.id            AS id_infracao,
    c.id            AS id_caminhao
FROM tb_viagem v
JOIN tb_motorista m ON m.id = v.id_motorista
JOIN tb_tipo_risco tr ON tr.id = m.risco
JOIN tb_infracao o ON o.id_viagem = v.id
JOIN tb_caminhao c ON c.id = v.id_caminhao
GROUP BY c.placa, v.dt_hr_inicio, v.dt_hr_fim, v.id, m.id, tr.id, o.id, c.id, m.nome_completo;

CREATE VIEW vw_ocorrencia_por_viagem (
    total_ocorrencias,
    nome_tipo_ocorrencia,
    id_viagem
) AS
SELECT
    COUNT(o.id) AS total_ocorrencias,
    t.nome      AS nome_tipo_ocorrencia,
    v.id        AS id_viagem
FROM tb_infracao o
JOIN tb_viagem v ON o.id_viagem = v.id
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
GROUP BY v.id, t.nome;

-- =============================
-- PROCS
-- =============================
CREATE OR REPLACE PROCEDURE prc_registrar_login_usuario(p_id_usuario INTEGER)
    LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO lg_login_usuario (id_usuario)
    VALUES (p_id_usuario);
END;
$$;


COMMIT;
