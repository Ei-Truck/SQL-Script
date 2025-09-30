ROLLBACK;

BEGIN;

-- =============================
-- DROPS
-- =============================

drop table if exists tb_midia_infracao cascade;
drop table if exists tb_midia_concatenada cascade;
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
drop table if exists tb_tipo_gravidade cascade;
drop table if exists lg_login_usuario cascade;
drop table if exists tb_daily_active_users cascade;
drop view if exists vw_relatorio_simples_viagem;
drop view if exists vw_visao_basica_viagem;
drop view if exists vw_ocorrencia_por_viagem;
drop view if exists vw_motorista_pontuacao_mensal;
drop view if exists vw_relatorio_semanal_infracoes;
drop procedure if exists prc_registrar_login_usuario;
drop function if exists fn_atualizar_dau;
drop trigger if exists trg_atualizar_dau on lg_login_usuario;


-- =============================
-- STATUS E TABELAS DE APOIO
-- =============================
CREATE TABLE tb_tipo_gravidade (
    id         INTEGER PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_infracao (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    pontuacao  INTEGER NOT NULL,
    id_tipo_gravidade INTEGER REFERENCES tb_tipo_gravidade,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_localidade (
    id         SERIAL PRIMARY KEY,
    cep        VARCHAR(10),
    numero_rua INTEGER,
    uf_estado  VARCHAR(2),
    nome       VARCHAR(80) NOT NULL UNIQUE,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_risco (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(50) NOT NULL UNIQUE,
    descricao  TEXT,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

-- =============================
-- SEGMENTO E UNIDADE
-- =============================
CREATE TABLE tb_segmento (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(40) NOT NULL UNIQUE,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_unidade (
    id               SERIAL PRIMARY KEY,
    id_segmento      INTEGER REFERENCES tb_segmento,
    nome             VARCHAR(100) NOT NULL,
    id_localidade    INTEGER REFERENCES tb_localidade,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

-- =============================
-- USUÁRIOS
-- =============================
CREATE TABLE tb_cargo (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(255) NOT NULL UNIQUE,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_usuario (
    id             SERIAL PRIMARY KEY,
    cpf            VARCHAR(15) NOT NULL UNIQUE,
    id_unidade     INTEGER REFERENCES tb_unidade,
    id_perfil      INTEGER,
    dt_contratacao DATE,
    nome_completo  VARCHAR(150) NOT NULL,
    telefone       VARCHAR(15) NOT NULL UNIQUE,
    email          VARCHAR(150) NOT NULL UNIQUE,
    hash_senha     VARCHAR(100) NOT NULL,
    url_foto       VARCHAR(255) DEFAULT 'Sem foto',
    id_cargo       INTEGER NOT NULL REFERENCES tb_cargo,
    transaction_made varchar(20),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive     BOOLEAN DEFAULT FALSE
);

-- =============================
-- CAMINHÃO
-- =============================
CREATE TABLE tb_caminhao (
    id               SERIAL PRIMARY KEY,
    chassi           VARCHAR(20) NOT NULL UNIQUE,
    id_segmento      INTEGER REFERENCES tb_segmento,
    id_unidade       INTEGER REFERENCES tb_unidade,
    placa            VARCHAR(10) NOT NULL UNIQUE,
    modelo           VARCHAR(80) DEFAULT 'Não informado',
    ano_fabricacao   INTEGER,
    numero_frota     INTEGER NOT NULL,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive       BOOLEAN DEFAULT FALSE
);

-- =============================
-- MOTORISTA
-- =============================
CREATE TABLE tb_motorista (
    id               SERIAL PRIMARY KEY,
    cpf              VARCHAR(15) NOT NULL UNIQUE,
    id_unidade       INTEGER REFERENCES tb_unidade,
    cnh              VARCHAR(15) NOT NULL UNIQUE,
    nome_completo    VARCHAR(150) NOT NULL,
    telefone         VARCHAR(15) NOT NULL,
    email_empresa    VARCHAR(150),
    id_tipo_risco    INTEGER REFERENCES tb_tipo_risco,
    url_foto         VARCHAR(255) DEFAULT 'Sem foto',
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive       BOOLEAN DEFAULT FALSE
);

-- =============================
-- VIAGEM
-- =============================
CREATE TABLE tb_viagem (
    id               SERIAL PRIMARY KEY,
    id_caminhao      INTEGER NOT NULL REFERENCES tb_caminhao,
    id_usuario       INTEGER REFERENCES tb_usuario,
    id_origem        INTEGER REFERENCES tb_localidade,
    id_destino       INTEGER REFERENCES tb_localidade,
    dt_hr_inicio     TIMESTAMP,
    dt_hr_fim        TIMESTAMP,
    km_viagem        VARCHAR DEFAULT 'Não informado',
    was_analyzed     BOOLEAN DEFAULT FALSE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive       BOOLEAN DEFAULT FALSE
);

-- =============================
-- TRATATIVA
-- =============================
CREATE TABLE tb_registro (
    id               SERIAL PRIMARY KEY,
    id_viagem        INTEGER NOT NULL REFERENCES tb_viagem,
    id_motorista     INTEGER REFERENCES tb_motorista,
    tratativa        TEXT NOT NULL,
    dt_hr_registro   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

-- =============================
-- OCORRÊNCIA
-- =============================
CREATE TABLE tb_infracao (
    id                 SERIAL PRIMARY KEY,
    id_viagem          INTEGER REFERENCES tb_viagem,
    id_motorista       INTEGER REFERENCES tb_motorista,
    dt_hr_evento       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_tipo_infracao   INTEGER REFERENCES tb_tipo_infracao,
    latitude           NUMERIC(9, 7),
    longitude          NUMERIC(9, 7),
    velocidade_kmh     NUMERIC(5, 2),
    transaction_made   VARCHAR(20),
    updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive         BOOLEAN DEFAULT FALSE
);

-- =============================
-- MÍDIA DE OCORRÊNCIA
-- =============================
CREATE TABLE tb_midia_infracao (
    id               SERIAL PRIMARY KEY,
    id_viagem        INTEGER NOT NULL REFERENCES tb_viagem,
    id_infracao      INTEGER NOT NULL REFERENCES tb_infracao,
    id_motorista     INTEGER NOT NULL REFERENCES tb_motorista,
    url              text NOT NULL,
    is_concat        BOOLEAN DEFAULT FALSE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

-- =============================
-- MÍDIA CONCATENADA
-- =============================
CREATE TABLE tb_midia_concatenada (
    id               SERIAL PRIMARY KEY,
    id_viagem        INTEGER NOT NULL REFERENCES tb_viagem,
    id_motorista     INTEGER NOT NULL REFERENCES tb_motorista,
    url              text NOT NULL,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive       BOOLEAN DEFAULT FALSE
);

-- =============================
-- ACESSOS
-- =============================
CREATE TABLE lg_login_usuario (
    id          SERIAL PRIMARY KEY,
    id_usuario  INTEGER REFERENCES tb_usuario,
    dt_hr_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- DAU
-- =============================
CREATE TABLE tb_daily_active_users (
    data         DATE PRIMARY KEY,
    qtd_usuarios INT DEFAULT 0
);

-- =============================
-- LOAD
-- =============================

-- 1) TIPO_GRAVIDADE
INSERT INTO tb_tipo_gravidade(id, nome) VALUES
(1, 'Leve'),
(2, 'Média'),
(3, 'Grave'),
(4, 'Gravíssima'),
(5, 'Crítica');

-- 2) TIPO_OCORRENCIA
INSERT INTO tb_tipo_infracao (id, nome, pontuacao, id_tipo_gravidade) VALUES
(1, 'Excesso de velocidade', 5,1),
(2, 'Frenagem brusca', 3,2),
(3, 'Aceleração brusca', 3,3),
(4, 'Colisão', 10,4),
(5, 'Pane mecânica', 6,5),
(6, 'Desvio de rota', 4,1),
(7, 'Falha de comunicação', 2,2),
(8, 'Carga violada', 8,3),
(9, 'Parada não autorizada', 4,4),
(10, 'Uso não autorizado', 7,5);

-- 3) LOCALIDADE
INSERT INTO tb_localidade (id, cep, numero_rua, uf_estado, nome) VALUES
(1, '00000-000', 0, 'SP', 'São Paulo'),
(2, '11111-111', 1, 'SP', 'Campinas'),
(3, '22222-222', 2, 'RJ', 'Rio de Janeiro'),
(4, '33333-333', 3, 'PR', 'Curitiba'),
(5, '44444-444', 4, 'MG', 'Belo Horizonte'),
(6, '55555-555', 5, 'RS', 'Porto Alegre'),
(7, '66666-666', 6, 'PE', 'Recife'),
(8, '77777-777', 7, 'BA', 'Salvador'),
(9, '88888-888', 8, 'GO', 'Goiânia'),
(10, '99999-999', 9, 'CE', 'Fortaleza');

-- 4) SEGMENTO
INSERT INTO tb_segmento (id, nome) VALUES
(1, 'Transporte de Carga Seca'),
(2, 'Transporte Refrigerado'),
(3, 'Transporte de Combustível'),
(4, 'Transporte de Produtos Químicos'),
(5, 'Transporte de Gases'),
(6, 'Transporte Fracionado'),
(7, 'Transporte de Veículos'),
(8, 'Transporte de Encomendas'),
(9, 'Transporte de Animais'),
(10, 'Transporte Especial');

-- 5) UNIDADE
INSERT INTO tb_unidade (id, id_segmento, nome, id_localidade) VALUES
(1, 1, 'Unidade São Paulo', 1),
(2, 2, 'Unidade Campinas', 2),
(3, 3, 'Unidade Rio', 3),
(4, 4, 'Unidade Curitiba', 4),
(5, 5, 'Unidade BH', 5),
(6, 6, 'Unidade Porto Alegre', 6),
(7, 7, 'Unidade Recife', 7),
(8, 8, 'Unidade Salvador', 8),
(9, 9, 'Unidade Goiânia', 9),
(10, 10, 'Unidade Fortaleza', 10);

-- 6) CARGO
INSERT INTO tb_cargo (id, nome) VALUES
(1, 'Gerente de Análise'),
(2, 'Analista Regional'),
(3, 'Analista Local');

-- 7) USUARIO
INSERT INTO tb_usuario (id, cpf, id_unidade, id_perfil, dt_contratacao, nome_completo, email, hash_senha, id_cargo) VALUES
(1, '123.456.789-09', 1, 1, '2018-05-10', 'João da Silva', '+11998877666', 'joao.silva@empresa.com', 'hash1', 2),
(2, '987.654.321-00', 2, 1, '2019-02-15', 'Maria Oliveira', '+11554433222', 'maria.oliveira@empresa.com', 'hash2', 3),
(3, '321.654.987-01', 3, 2, '2017-07-22', 'Carlos Souza', '+11223344555', 'carlos.souza@empresa.com', 'hash3', 1),
(4, '111.222.333-96', 4, 3, '2020-01-10', 'Fernanda Lima', '+11567788999', 'fernanda.lima@empresa.com', 'hash4', 2),
(5, '444.555.666-09', 5, 2, '2021-09-05', 'Ricardo Alves', '+11223377666' , 'ricardo.alves@empresa.com', 'hash5', 1),
(6, '777.888.999-15', 6, 1, '2015-11-12', 'Paula Mendes', '+21998877666', 'paula.mendes@empresa.com', 'hash6', 3),
(7, '222.333.444-98', 7, 2, '2016-03-30', 'Bruno Ferreira', '+21554433222', 'bruno.ferreira@empresa.com', 'hash7', 3),
(8, '555.666.777-20', 8, 1, '2022-04-18', 'Aline Costa', '+21223344555', 'aline.costa@empresa.com', 'hash8', 2),
(9, '888.999.000-05', 9, 3, '2018-06-25', 'Gustavo Pereira', '+21567788999', 'gustavo.pereira@empresa.com', 'hash9', 1),
(10, '666.555.444-33', 10, 2, '2023-02-14', 'Larissa Martins', '+21223377666', 'larissa.martins@empresa.com', 'hash10', 1);

-- 8) TIPO_RISCO
INSERT INTO tb_tipo_risco (id, nome, descricao) VALUES
(1, 'Baixo', 'Motoristas com baixo risco de infrações.'),
(2, 'Médio', 'Motoristas com risco moderado de infrações.'),
(3, 'Alto', 'Motoristas com alto risco de infrações.'),
(4, 'Crítico', 'Motoristas com risco crítico de infrações.'),
(5, 'Especial', 'Motoristas que requerem atenção especial.');

-- 9) MOTORISTA
INSERT INTO tb_motorista (id, cpf, id_unidade, cnh, nome_completo, telefone, email_empresa, id_tipo_risco) VALUES
(1, '123.123.123-12', 1, 'MG1234567', 'Paulo Gomes', '(11)98888-1111', 'paulo.gomes@empresa.com', 1),
(2, '234.234.234-23', 2, 'SP2345678', 'Rodrigo Santos', '(19)97777-2222', 'rodrigo.santos@empresa.com', 2),
(3, '345.345.345-34', 3, 'RJ3456789', 'Marcelo Almeida', '(21)96666-3333', 'marcelo.almeida@empresa.com', 3),
(4, '456.456.456-45', 4, 'PR4567890', 'Felipe Rocha', '(41)95555-4444', 'felipe.rocha@empresa.com', 4),
(5, '567.567.567-56', 5, 'MG5678901', 'Renato Dias', '(31)94444-5555', 'renato.dias@empresa.com', 5),
(6, '678.678.678-67', 6, 'RS6789012', 'Eduardo Moraes', '(51)93333-6666', 'eduardo.moraes@empresa.com', 1),
(7, '789.789.789-78', 7, 'PE7890123', 'André Ferreira', '(81)92222-7777', 'andre.ferreira@empresa.com', 2),
(8, '890.890.890-89', 8, 'BA8901234', 'Thiago Campos', '(71)91111-8888', 'thiago.campos@empresa.com', 3),
(9, '901.901.901-90', 9, 'GO9012345', 'Diego Farias', '(62)90000-9999', 'diego.farias@empresa.com', 4),
(10, '012.012.012-01', 10, 'CE0123456', 'Rafael Souza', '(85)98888-0000', 'rafael.souza@empresa.com', 5);

-- 10) CAMINHAO
INSERT INTO tb_caminhao (id, chassi, id_segmento, id_unidade, placa, modelo, ano_fabricacao, numero_frota) VALUES
(1, '9BWZZZ377VT004251', 1, 1, 'BRA1A23', 'Volvo FH 540', 2019, 101),
(2, '8AWZZZ377VT004252', 2, 2, 'BRA2B34', 'Scania R450', 2020, 102),
(3, '7CWZZZ377VT004253', 3, 3, 'BRA3C45', 'Mercedes Actros', 2018, 103),
(4, '6DWZZZ377VT004254', 4, 4, 'BRA4D56', 'Volvo VM 270', 2021, 104),
(5, '5EWZZZ377VT004255', 5, 5, 'BRA4D51','Iveco Hi-Way', 2017, 105),
(6, '4FWZZZ377VT004256', 6, 6, 'BRA4D52','MAN TGX', 2022, 106),
(7, '3GWZZZ377VT004257', 7, 7, 'BRA4D53','Scania S500', 2019, 107),
(8, '2HWZZZ377VT004258', 8, 8,'BRA4D54', 'Volvo FH 460', 2023, 108),
(9, '1IWZZZ377VT004259', 9, 9, 'BRA4D55','Mercedes Axor', 2016, 109),
(10, '0JWZZZ377VT004260', 10, 10,'BRA4D57', 'Volkswagen Constellation', 2015, 110);

-- 12) VIAGEM
INSERT INTO tb_viagem (id, id_caminhao, id_usuario, id_origem, id_destino, dt_hr_inicio, dt_hr_fim) VALUES
(1, 1, 1, 1, 2, '2023-01-10 08:00:00', '2023-01-10 14:00:00'),
(2, 2, 2, 2, 3, '2023-02-15 09:15:00', '2023-02-15 16:40:00'),
(3, 3, 3, 3, 4, '2023-03-05 07:30:00', '2023-03-05 19:20:00'),
(4, 4, 4, 4, 5, '2023-04-12 06:50:00', '2023-04-12 13:45:00'),
(5, 5, 5, 5, 6, '2023-05-20 08:10:00', '2023-05-20 15:55:00'),
(6, 6, 6, 6, 7, '2023-06-18 10:00:00', '2023-06-18 17:40:00'),
(7, 7, 7, 7, 8, '2023-07-01 09:00:00', '2023-07-01 14:50:00'),
(8, 8, 8, 8, 9, '2023-08-08 05:40:00', '2023-08-08 12:30:00'),
(9, 9, 9, 9, 10, '2023-09-22 06:10:00', '2023-09-22 15:15:00'),
(10, 10, 10, 10, 1, '2023-10-05 08:30:00', '2023-10-05 17:00:00');

-- 11) REGISTRO
INSERT INTO tb_registro (id, id_viagem, id_motorista, tratativa, dt_hr_registro) VALUES
(1, 1, 1, 'Motorista orientado a reduzir velocidade.', '2023-01-10 12:00:00'),
(2, 2, 2, 'Frenagem brusca analisada, sem medidas adicionais.', '2023-02-15 14:30:00'),
(3, 3, 3, 'Aceleração brusca discutida em reunião de equipe.', '2023-03-05 15:45:00'),
(4, 4, 4, 'Colisão investigada, medidas corretivas implementadas.', '2023-04-12 10:15:00'),
(5, 5, 5, 'Pane mecânica registrada e encaminhada para manutenção.', '2023-05-20 16:20:00'),
(6, 6, 6, 'Desvio de rota revisado com o motorista.', '2023-06-18 18:00:00'),
(7, 7, 7, 'Falha de comunicação abordada em treinamento.', '2023-07-01 13:30:00'),
(8, 8, 8, 'Carga violada reportada às autoridades competentes.', '2023-08-08 11:45:00'),
(9, 9, 9, 'Parada não autorizada discutida com o motorista.', '2023-09-22 14:10:00'),
(10, 10, 10,'Uso não autorizado do veículo investigado.', '2023-10-05 15:55:00');


-- 13) OCORRENCIA
INSERT INTO tb_infracao (id, id_viagem, id_motorista, dt_hr_evento, id_tipo_infracao, latitude, longitude, velocidade_kmh) VALUES
(1, 1, 1, '2023-01-10 10:15:00', 1, -23.550520, -46.633308, 95.5),
(2, 2, 2, '2023-02-15 11:30:00', 2, -22.909938, -47.062633, 80.0),
(3, 3, 3, '2023-03-05 13:10:00', 4, -22.906847, -43.172896, 60.0),
(4, 4, 4, '2023-04-12 09:20:00', 5, -25.428356, -49.273251, 50.0),
(5, 5, 5, '2023-05-20 12:45:00', 6, -19.916681, -43.934493, 70.0),
(6, 6, 6, '2023-06-18 14:30:00', 7, -30.034647, -51.217658, 65.0),
(7, 7, 7, '2023-07-01 11:00:00', 8, -8.047562, -34.877000, 40.0),
(8, 8, 8, '2023-08-08 08:30:00', 9, -12.977749, -38.501630, 55.0),
(9, 9, 9, '2023-09-22 10:20:00', 10, -16.686882, -49.264788, 50.0),
(10, 10, 10, '2023-10-05 12:45:00', 3, -3.731862, -38.526669, 85.0);

-- 14) MÍDIA DA OCORRÊNCIA
INSERT INTO tb_midia_infracao (id, id_viagem, id_infracao, id_motorista, url) VALUES
(1, 1, 1, 1, 'http://eitruck/video1.mp4'),
(2, 2, 2, 2, 'http://eitruck/video2.mp4'),
(3, 3, 3, 3, 'http://eitruck/video3.mp4'),
(4, 4, 4, 4, 'http://eitruck/video4.mp4'),
(5, 5, 5, 5, 'http://eitruck/video5.mp4'),
(6, 6, 6, 6, 'http://eitruck/video6.mp4'),
(7, 7, 7, 7, 'http://eitruck/video7.mp4'),
(8, 8, 8, 8, 'http://eitruck/video8.mp4'),
(9, 9, 9, 9, 'http://eitruck/video9.mp4'),
(10, 10, 10, 10, 'http://eitruck/video10.mp4');

-- 15) MÍDIA CONCATENADA
INSERT INTO tb_midia_concatenada (id, id_viagem, id_motorista, url) VALUES
(1, 1, 1, 'http://eitruck/concat_video1.mp4'),
(2, 2, 2, 'http://eitruck/concat_video2.mp4'),
(3, 3, 3, 'http://eitruck/concat_video3.mp4'),
(4, 4, 4, 'http://eitruck/concat_video4.mp4'),
(5, 5, 5, 'http://eitruck/concat_video5.mp4'),
(6, 6, 6, 'http://eitruck/concat_video6.mp4'),
(7, 7, 7, 'http://eitruck/concat_video7.mp4'),
(8, 8, 8, 'http://eitruck/concat_video8.mp4'),
(9, 9, 9, 'http://eitruck/concat_video9.mp4'),
(10, 10, 10, 'http://eitruck/concat_video10.mp4');

-- =============================
-- VIEWS
-- =============================
CREATE VIEW vw_relatorio_simples_viagem (
    placa_caminhao,
    data_inicio_viagem,
    id_infracao,
    id_viagem,
    id_motorista,
    nome_motorista,
    id_caminhao,
    km_viagem,
    pontuacao_total
) AS
SELECT
    c.placa         AS placa_caminhao,
    v.dt_hr_inicio  AS data_inicio_viagem,
    o.id            AS id_infracao,
    v.id            AS id_viagem,
    m.id            AS id_motorista,
    m.nome_completo AS nome_motorista,
    c.id            AS id_caminhao,
    v.km_viagem     AS km_viagem,
    SUM(ti.pontuacao) AS pontuacao_total
FROM tb_infracao o
JOIN tb_viagem v    ON o.id_viagem = v.id
JOIN tb_caminhao c  ON v.id_caminhao = c.id
JOIN tb_motorista m ON m.id = o.id_motorista
JOIN tb_tipo_infracao ti ON o.id_tipo_infracao = ti.id
GROUP BY c.placa, v.dt_hr_inicio, m.id, o.id, v.id, c.id;

CREATE VIEW vw_visao_basica_viagem (
    placa_caminhao,
    data_inicio_viagem,
    data_fim_viagem,
    segmento,
    nome_motorista,
    risco_motorista,
    id_midia_concatenada,
    url_midia_concatenada,
    id_viagem,
    id_segmento,
    id_motorista,
    id_tipo_gravidade,
    id_tipo_risco,
    id_infracao,
    id_caminhao
) AS
SELECT
    c.placa         AS placa_caminhao,
    v.dt_hr_inicio  AS data_inicio_viagem,
    v.dt_hr_fim     AS data_fim_viagem,
    s.nome          AS segmento,
    m.nome_completo AS nome_motorista,
    tr.nome         AS risco_motorista,
    mc.id           AS id_midia_concatenada,
    mc.url          AS url_midia_concatenada,
    v.id            AS id_viagem,
    s.id            AS id_segmento,
    m.id            AS id_motorista,
    tg.id           AS id_tipo_gravidade,
    tr.id           AS id_tipo_risco,
    o.id            AS id_infracao,
    c.id            AS id_caminhao
FROM tb_viagem v
JOIN tb_infracao o ON o.id_viagem = v.id
JOIN tb_motorista m ON m.id = o.id_motorista
JOIN tb_tipo_risco tr ON m.id_tipo_risco = tr.id
JOIN tb_tipo_infracao t ON t.id = o.id_tipo_infracao
JOIN tb_tipo_gravidade tg ON t.id_tipo_gravidade = tg.id
JOIN tb_midia_concatenada mc ON mc.id_motorista = m.id AND mc.id_viagem = v.id
JOIN tb_segmento s ON s.id = m.id_unidade
JOIN tb_caminhao c ON c.id = v.id_caminhao
GROUP BY c.placa, v.dt_hr_inicio, v.dt_hr_fim, m.nome_completo, tr.nome, v.id, m.id, tr.id, tg.id, o.id, c.id, s.nome, s.id, mc.id, mc.url;

CREATE VIEW vw_ocorrencia_por_viagem (
    total_ocorrencias,
    id_viagem
) AS
SELECT
    COUNT(o.id) AS total_ocorrencias,
    v.id        AS id_viagem
FROM tb_infracao o
JOIN tb_viagem v ON o.id_viagem = v.id
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
GROUP BY v.id, t.nome;

CREATE VIEW vw_motorista_pontuacao_mensal(
    id_motorista,
    motorista,
    id_unidade,
    unidade,
    id_segmento,
    segmento,
    pontuacao_ultimo_mes
) AS
SELECT
    m.id AS id_motorista,
    m.nome_completo AS motorista,
    u.id AS id_unidade,
    u.nome AS unidade,
    s.id as id_segmento,
    s.nome AS segmento,
    SUM(ti.pontuacao) AS pontuacao_ultimo_mes
FROM tb_infracao i
JOIN public.tb_motorista m ON i.id_motorista = m.id
JOIN public.tb_tipo_infracao ti ON i.id_tipo_infracao = ti.id
JOIN public.tb_unidade u ON m.id_unidade = u.id
JOIN public.tb_segmento s ON u.id_segmento = s.id
WHERE i.dt_hr_evento >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY m.id, m.nome_completo, u.id, u.nome, s.id, s.nome;


CREATE VIEW vw_relatorio_semanal_infracoes(
    dia_semana,
    total_infracoes
) AS 
SELECT 
    TO_CHAR(dt_hr_evento, 'FMDay') AS dia_semana,
    COUNT(*) AS total_infracoes
FROM tb_infracao i
WHERE dt_hr_evento >= CURRENT_DATE - interval '1 week'
GROUP BY TO_CHAR(dt_hr_evento, 'FMDay')
ORDER BY TO_CHAR(dt_hr_evento, 'FMDay');

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

-- =============================
-- FUNCS
-- =============================
CREATE OR REPLACE FUNCTION fn_atualizar_dau()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO tb_daily_active_users (data, qtd_usuarios)
    VALUES (
        CURRENT_DATE,
        (SELECT COUNT(DISTINCT id_usuario)
         FROM lg_login_usuario
         WHERE DATE(dt_hr_login) = CURRENT_DATE)
    )
    ON CONFLICT (data)
    DO UPDATE SET qtd_usuarios = EXCLUDED.qtd_usuarios;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================
-- TRIGGERS
-- =============================

CREATE TRIGGER trg_atualizar_dau
AFTER INSERT ON lg_login_usuario
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_dau();

COMMIT;
