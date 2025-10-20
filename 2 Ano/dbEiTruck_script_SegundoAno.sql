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
drop view if exists vw_total_ocorrencias;
drop view if exists vw_ocorrencias_por_gravidade;
drop view if exists vw_motorista_quantidade_infracoes;
drop view if exists vw_variacao_mes_passado;
drop view if exists vw_ocorrencias_por_tipo;
drop procedure if exists prc_registrar_login_usuario;
drop function if exists fn_atualizar_dau;
drop trigger if exists trg_atualizar_dau on lg_login_usuario;


-- =============================
-- STATUS E TABELAS DE APOIO
-- =============================
CREATE TABLE tb_tipo_gravidade (
    id               INTEGER PRIMARY KEY,
    nome             VARCHAR(50) NOT NULL UNIQUE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_infracao (
    id                SERIAL PRIMARY KEY,
    nome              VARCHAR(50) NOT NULL UNIQUE,
    pontuacao         INTEGER NOT NULL,
    id_tipo_gravidade INTEGER REFERENCES tb_tipo_gravidade,
    transaction_made  VARCHAR(20),
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive       BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_localidade (
    id               SERIAL PRIMARY KEY,
    cep              VARCHAR(10),
    numero_rua       INTEGER,
    uf_estado        VARCHAR(2),
    nome             VARCHAR(80) NOT NULL UNIQUE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_tipo_risco (
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(50) NOT NULL UNIQUE,
    descricao        TEXT,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

-- =============================
-- SEGMENTO E UNIDADE
-- =============================
CREATE TABLE tb_segmento (
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(40) NOT NULL UNIQUE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
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
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(255) NOT NULL UNIQUE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
);

CREATE TABLE tb_usuario (
    id               SERIAL PRIMARY KEY,
    cpf              VARCHAR(15) NOT NULL UNIQUE,
    id_unidade       INTEGER REFERENCES tb_unidade,
    id_perfil        INTEGER,
    dt_contratacao   DATE,
    nome_completo    VARCHAR(150) NOT NULL,
    telefone         VARCHAR(15) NOT NULL UNIQUE,
    email            VARCHAR(150) NOT NULL UNIQUE,
    hash_senha       VARCHAR(100) NOT NULL,
    url_foto         VARCHAR(255) DEFAULT 'Sem foto',
    id_cargo         INTEGER NOT NULL REFERENCES tb_cargo,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
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
    is_inactive      BOOLEAN DEFAULT FALSE
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
    is_inactive      BOOLEAN DEFAULT FALSE
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
    km_viagem        VARCHAR(50) DEFAULT 'Não informado',
    was_analyzed     BOOLEAN DEFAULT FALSE,
    transaction_made VARCHAR(20),
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_inactive      BOOLEAN DEFAULT FALSE
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
    is_inactive        BOOLEAN DEFAULT FALSE
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
    is_inactive      BOOLEAN DEFAULT FALSE
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
(5, 'Crítica'),
(6, 'Observacional'),
(7, 'Informativo');

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
(10, 'Uso não autorizado', 7,5),
(11, 'Uso de celular ao volante', 6, 3),
(12, 'Ultrapassagem indevida', 7, 4),
(13, 'Não uso de EPI (carga)', 4, 2),
(14, 'Porta aberta em movimento', 8, 4),
(15, 'Carga mal acondicionada', 5, 2),
(16, 'Ignorar sinalização', 6, 3),
(17, 'Rodagem em faixa interditada', 5, 1),
(18, 'Velocidade incompatível com pista', 6, 3),
(19, 'Falha no sistema de freio', 9, 5),
(20, 'Atitude agressiva/roubo de carga', 10, 5);

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
(10, '99999-999', 9, 'CE', 'Fortaleza'),
(11, '01010-010', 10, 'SP', 'Ribeirão Preto'),
(12, '02020-020', 20, 'SP', 'São José dos Campos'),
(13, '03030-030', 30, 'MG', 'Uberlândia'),
(14, '04040-040', 40, 'BA', 'Feira de Santana'),
(15, '05050-050', 50, 'PR', 'Londrina'),
(16, '06060-060', 60, 'SC', 'Joinville'),
(17, '07070-070', 70, 'MA', 'São Luís'),
(18, '08080-080', 80, 'BA', 'Ilhéus'),
(19, '09090-090', 90, 'AM', 'Manaus'),
(20, '10101-101', 101, 'MT', 'Cuiabá'),
(21, '11111-111', 111, 'PE', 'Jaboatão dos Guararapes'),
(22, '12121-121', 121, 'PB', 'Campina Grande'),
(23, '13131-131', 131, 'RO', 'Porto Velho'),
(24, '14141-141', 141, 'RR', 'Boa Vista'),
(25, '15151-151', 151, 'AP', 'Macapá');

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
(10, 'Transporte Especial'),
(11, 'Transporte Express'),
(12, 'Transporte Granulado'),
(13, 'Transporte Sólidos Perigosos'),
(14, 'Transporte Oversize'),
(15, 'Transporte E-commerce');

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
(10, 10, 'Unidade Fortaleza', 10),
(11, 11, 'Unidade Ribeirão Preto', 11),
(12, 12, 'Unidade São José dos Campos', 12),
(13, 13, 'Unidade Uberlândia', 13),
(14, 14, 'Unidade Feira de Santana', 14),
(15, 15, 'Unidade Londrina', 15),
(16, 1,  'Unidade Joinville', 16),
(17, 2,  'Unidade São Luís', 17),
(18, 3,  'Unidade Ilhéus', 18),
(19, 4,  'Unidade Manaus', 19),
(20, 5,  'Unidade Cuiabá', 20);

-- 6) CARGO
INSERT INTO tb_cargo (id, nome) VALUES
(1, 'Administrador'),
(2, 'Gerente de Análise'),
(3, 'Analista Regional'),
(4, 'Analista Local'),
(5, 'Supervisor de Frota'),
(6, 'Coordenador de Segurança'),
(7, 'Tecnico de Manutenção'),
(8, 'Operador de Rastreamento');

-- 7) USUARIO principal de QA
INSERT INTO tb_usuario (id, cpf, id_unidade, id_perfil, dt_contratacao, nome_completo, telefone, email, hash_senha, id_cargo, url_foto) VALUES
(1, '123.456.789-09', 1, 1, '2018-05-10', 'João da Silva', '+11998877666', 'joao.silva@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 3, 'https://eitruck.s3.sa-east-1.amazonaws.com/perfil/1/profile_1.jpg');

-- 7.1) USUARIOS FAKE
INSERT INTO tb_usuario (id, cpf, id_unidade, id_perfil, dt_contratacao, nome_completo, telefone, email, hash_senha, id_cargo) VALUES
(2, '987.654.321-00', 2, 1, '2019-02-15', 'Maria Oliveira', '+11554433222', 'maria.oliveira@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 4),
(3, '321.654.987-01', 3, 2, '2017-07-22', 'Carlos Souza', '+11223344555', 'carlos.souza@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 2),
(4, '111.222.333-96', 4, 3, '2020-01-10', 'Fernanda Lima', '+11567788999', 'fernanda.lima@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 3),
(5, '444.555.666-09', 5, 2, '2021-09-05', 'Ricardo Alves', '+11223377666' , 'ricardo.alves@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 2),
(6, '777.888.999-15', 6, 1, '2015-11-12', 'Paula Mendes', '+21998877666', 'paula.mendes@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 4),
(7, '222.333.444-98', 7, 2, '2016-03-30', 'Bruno Ferreira', '+21554433222', 'bruno.ferreira@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 4),
(8, '555.666.777-20', 8, 1, '2022-04-18', 'Aline Costa', '+21223344555', 'aline.costa@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 3),
(9, '888.999.000-05', 9, 3, '2018-06-25', 'Gustavo Pereira', '+21567788999', 'gustavo.pereira@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 2),
(10, '666.555.444-33', 10, 2, '2023-02-14', 'Larissa Martins', '+21223377666', 'larissa.martins@empresa.com', '$2a$12$bsiGyE38lzmLyZNG701O7OLP8HkS106s.KMrofJVsYwta/1bowsOK', 2),
(11, '101.202.303-44', 11, 1, '2020-03-01', 'Lúcia Fernandes', '+5514999990001', 'lucia.fernandes@empresa.com', '$2a$12$hashfake1', 5),
(12, '202.303.404-55', 12, 1, '2019-07-15', 'Hugo Ribeiro', '+5512999990002', 'hugo.ribeiro@empresa.com', '$2a$12$hashfake2', 6),
(13, '303.404.505-66', 13, 2, '2021-11-21', 'Marina Sales', '+5531999990003', 'marina.sales@empresa.com', '$2a$12$hashfake3', 7),
(14, '404.505.606-77', 14, 2, '2018-02-10', 'Anderson Lima', '+5571999990004', 'anderson.lima@empresa.com', '$2a$12$hashfake4', 5),
(15, '505.606.707-88', 15, 3, '2022-08-05', 'Camila Rocha', '+5541999990005', 'camila.rocha@empresa.com', '$2a$12$hashfake5', 6),
(16, '606.707.808-99', 16, 1, '2020-12-01', 'Diego Nunes', '+5571999990006', 'diego.nunes@empresa.com', '$2a$12$hashfake6', 7),
(17, '707.808.909-00', 17, 1, '2017-06-30', 'Patrícia Alves', '+5591999990007', 'patricia.alves@empresa.com', '$2a$12$hashfake7', 8),
(18, '808.909.010-11', 18, 2, '2016-09-18', 'Ronaldo Costa', '+5581999990008', 'ronaldo.costa@empresa.com', '$2a$12$hashfake8', 5),
(19, '909.010.111-22', 19, 3, '2015-01-04', 'Sofia Martins', '+559899990009',  'sofia.martins@empresa.com', '$2a$12$hashfake9', 6),
(20, '010.111.212-33', 20, 2, '2024-02-02', 'Igor Teixeira', '+5561999990010', 'igor.teixeira@empresa.com', '$2a$12$hashfake10', 7),
(21, '111.222.333-44', 11, 1, '2021-05-05', 'Natália Barros', '+5511999880011', 'natalia.barros@empresa.com', '$2a$12$hashfake11', 8),
(22, '222.333.444-55', 12, 1, '2019-10-10', 'Fábio Gomes', '+5513999880012', 'fabio.gomes@empresa.com', '$2a$12$hashfake12', 5),
(23, '333.444.555-66', 13, 2, '2018-12-12', 'Luan Pereira', '+5511999880013', 'luan.pereira@empresa.com', '$2a$12$hashfake13', 6),
(24, '444.555.666-77', 14, 2, '2022-03-03', 'Brenda Castro', '+5511999880014', 'brenda.castro@empresa.com', '$2a$12$hashfake14', 7),
(25, '555.666.777-88', 15, 1, '2020-06-06', 'Rita Moura', '+5511999880015', 'rita.moura@empresa.com', '$2a$12$hashfake15', 8),
(26, '666.777.888-99', 16, 3, '2016-07-07', 'Eduarda Lima', '+5511999880016', 'eduarda.lima@empresa.com', '$2a$12$hashfake16', 5),
(27, '777.888.999-00', 17, 1, '2015-08-08', 'Mateus Cardoso', '+5511999880017', 'mateus.cardoso@empresa.com', '$2a$12$hashfake17', 6),
(28, '888.999.000-11', 18, 1, '2014-09-09', 'Helena Reis', '+5511999880018', 'helena.reis@empresa.com', '$2a$12$hashfake18', 7),
(29, '999.000.111-22', 19, 2, '2013-10-10', 'Thiago Pinto', '+5511999880019', 'thiago.pinto@empresa.com', '$2a$12$hashfake19', 8),
(30, '000.111.222-33', 20, 3, '2023-11-11', 'Patricia Nascimento', '+5511999880020', 'patricia.nascimento@empresa.com', '$2a$12$hashfake20', 5);


-- 8) TIPO_RISCO
INSERT INTO tb_tipo_risco (id, nome, descricao) VALUES
(1, 'Baixo', 'Motoristas com baixo risco de infrações.'),
(2, 'Médio', 'Motoristas com risco moderado de infrações.'),
(3, 'Alto', 'Motoristas com alto risco de infrações.'),
(4, 'Crítico', 'Motoristas com risco crítico de infrações.'),
(5, 'Especial', 'Motoristas que requerem atenção especial.'),
(6, 'Recorrente', 'Motoristas com ocorrências recorrentes.'),
(7, 'Novo', 'Motoristas recém-contratados em avaliação.'),
(8, 'Seguro', 'Motoristas com histórico excelente.'),
(9, 'Treinamento', 'Requer treinamento complementar.'),
(10, 'Manutenção', 'Associado a veículos com problemas.');

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
(10, '012.012.012-01', 10, 'CE0123456', 'Rafael Souza', '(85)98888-0000', 'rafael.souza@empresa.com', 5),
(11, '111.111.111-11', 11, 'RJ1111111', 'Sérgio Rocha', '(16)98888-1111', 'sergio.rocha@empresa.com', 6),
(12, '222.222.222-22', 12, 'SP2222222', 'Paulo Henrique', '(12)97777-2222', 'paulo.henrique@empresa.com', 7),
(13, '333.333.333-33', 13, 'MG3333333', 'Alex Silva', '(34)96666-3333', 'alex.silva@empresa.com', 8),
(14, '444.444.444-44', 14, 'BA4444444', 'Marcos Vinicius', '(75)95555-4444', 'marcos.vinicius@empresa.com', 9),
(15, '555.555.555-55', 15, 'PR5555555', 'Geraldo Dias', '(43)94444-5555', 'geraldo.dias@empresa.com', 6),
(16, '666.666.666-66', 16, 'SC6666666', 'Ramon Costa', '(47)93333-6666', 'ramon.costa@empresa.com', 7),
(17, '777.777.777-77', 17, 'MA7777777', 'Elias Ferreira', '(98)92222-7777', 'elias.ferreira@empresa.com', 8),
(18, '888.888.888-88', 18, 'BA8888888', 'Vitor Andrade', '(73)91111-8888', 'vitor.andrade@empresa.com', 9),
(19, '999.999.999-99', 19, 'AM9999999', 'César Moreira', '(92)90000-9999', 'cesar.moreira@empresa.com', 10),
(20, '101.101.101-10', 20, 'MT1010101', 'Diego Rocha', '(65)98888-0000', 'diego.rocha@empresa.com', 6),
(21, '121.121.121-12', 11, 'RJ1212121', 'Filipe Nascimento', '(16)98888-1212', 'filipe.nascimento@empresa.com', 1),
(22, '131.131.131-13', 12, 'SP1313131', 'Jonas Lima', '(12)97777-1313', 'jonas.lima@empresa.com', 2),
(23, '141.141.141-14', 13, 'MG1414141', 'Rafael Moretti', '(34)96666-1414', 'rafael.moretti@empresa.com', 3),
(24, '151.151.151-15', 14, 'BA1515151', 'Nelson Braga', '(75)95555-1515', 'nelson.braga@empresa.com', 4),
(25, '161.161.161-16', 15, 'PR1616161', 'Wagner Souza', '(43)94444-1616', 'wagner.souza@empresa.com', 5),
(26, '171.171.171-17', 16, 'SC1717171', 'Henrique Duarte', '(47)93333-1717', 'henrique.duarte@empresa.com', 6),
(27, '181.181.181-18', 17, 'MA1818181', 'Roberto Alves', '(98)92222-1818', 'roberto.alves@empresa.com', 7),
(28, '191.191.191-19', 18, 'BA1919191', 'Mariana Freitas', '(73)91111-1919', 'mariana.freitas@empresa.com', 8),
(29, '202.202.202-20', 19, 'AM2020202', 'Paulo Cesar', '(92)90000-2020', 'paulo.cesar@empresa.com', 9),
(30, '212.212.212-21', 20, 'MT2121212', 'Rogério Campos', '(65)98888-2121', 'rogerio.campos@empresa.com', 10),
(31, '222.111.333-44', 11, 'RJ2223334', 'Bruno Santana', '(16)98888-3131', 'bruno.santana@empresa.com', 1),
(32, '333.222.444-55', 12, 'SP3334445', 'Igor Almeida', '(12)97777-3232', 'igor.almeida@empresa.com', 2),
(33, '444.333.555-66', 13, 'MG4445556', 'Otávio Rocha', '(34)96666-3333', 'otavio.rocha@empresa.com', 3),
(34, '555.444.666-77', 14, 'BA5556667', 'Sandro Melo', '(75)95555-3434', 'sandro.melo@empresa.com', 4),
(35, '666.555.777-88', 15, 'PR6667778', 'Robson Leite', '(43)94444-3535', 'robson.leite@empresa.com', 5),
(36, '777.666.888-99', 16, 'SC7778889', 'Fabiana Silva', '(47)93333-3636', 'fabiana.silva@empresa.com', 6),
(37, '888.777.999-00', 17, 'MA8889990', 'Alexandre Pinto', '(98)92222-3737', 'alexandre.pinto@empresa.com', 7),
(38, '999.888.000-11', 18, 'BA9990001', 'Sávio Ramos', '(73)91111-3838', 'savio.ramos@empresa.com', 8),
(39, '010.020.030-40', 19, 'AM0100200', 'Rodrigo Alves', '(92)90000-3939', 'rodrigo.alves@empresa.com', 9),
(40, '050.060.070-80', 20, 'MT0500600', 'Kleber Santos', '(65)98888-4040', 'kleber.santos@empresa.com', 10);


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
(10, '0JWZZZ377VT004260', 10, 10,'BRA4D57', 'Volkswagen Constellation', 2015, 110),
(11, '6KZWZZZ377VT004261', 11, 11, 'BRA5E61', 'Volvo FH 460', 2020, 201),
(12, '5LZWZZZ377VT004262', 12, 12, 'BRA6F72', 'Scania P360', 2019, 202),
(13, '4MZWZZZ377VT004263', 13, 13, 'BRA7G83', 'Iveco Stralis', 2018, 203),
(14, '3NZWZZZ377VT004264', 14, 14, 'BRA8H94', 'Mercedes Atego', 2017, 204),
(15, '2OZWZZZ377VT004265', 15, 15, 'BRA9I05', 'MAN TGS', 2021, 205),
(16, '1PZWZZZ377VT004266', 1, 11, 'BRB1A11', 'Volvo FH 540', 2022, 206),
(17, '0QZWZZZ377VT004267', 2, 12, 'BRC2B22', 'Scania R500', 2020, 207),
(18, '9RZWZZZ377VT004268', 3, 13, 'BRD3C33', 'Mercedes Actros', 2016, 208),
(19, '8SZWZZZ377VT004269', 4, 14, 'BRE4D44', 'Volvo VM 310', 2015, 209),
(20, '7TZWZZZ377VT004270', 5, 15, 'BRF5E55', 'Iveco Hi-Road', 2014, 210),
(21, '6UZWZZZ377VT004271', 6, 16, 'BRG6F66', 'Ford Cargo', 2019, 211),
(22, '5VZWZZZ377VT004272', 7, 17, 'BRH7G77', 'Scania S380', 2021, 212),
(23, '4WZWZZZ377VT004273', 8, 18, 'BRJ8H88', 'Volvo FMX', 2022, 213),
(24, '3XZWZZZ377VT004274', 9, 19, 'BRK9I99', 'Mercedes Axor', 2013, 214),
(25, '2YZWZZZ377VT004275', 10, 20, 'BRL0J00', 'VW Constellation', 2012, 215),
(26, '1AZWZZZ377VT004276', 11, 12, 'BRM1K11', 'Volvo FH 500', 2023, 216),
(27, '0BZWZZZ377VT004277', 12, 13, 'BRN2L22', 'Scania R620', 2024, 217),
(28, '9CZWZZZ377VT004278', 13, 14, 'BRO3M33', 'Iveco Hi-Way', 2020, 218),
(29, '8DZWZZZ377VT004279', 14, 15, 'BRP4N44', 'MAN TGX', 2018, 219),
(30, '7EZWZZZ377VT004280', 15, 16, 'BRQ5O55', 'Volvo FH 540', 2017, 220);

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
(10, 10, 10, 10, 1, '2023-10-05 08:30:00', '2023-10-05 17:00:00'),
(11, 1, 1, 1, 2, '2025-10-04 08:00:00', '2025-10-04 12:00:00'),
(12, 2, 2, 2, 3, '2025-10-05 09:00:00', '2025-10-05 13:30:00'),
(13, 3, 3, 3, 4, '2025-10-06 07:30:00', '2025-10-06 11:50:00'),
(14, 4, 4, 4, 5, '2025-10-07 06:40:00', '2025-10-07 12:10:00'),
(15, 5, 5, 5, 6, '2025-10-08 08:20:00', '2025-10-08 13:15:00'),
(16, 6, 6, 6, 7, '2025-10-10 09:10:00', '2025-10-10 14:50:00'),
(17, 7, 7, 7, 8, '2025-10-11 07:50:00', '2025-10-11 12:30:00');

INSERT INTO tb_viagem (id, id_caminhao, id_usuario, id_origem, id_destino, dt_hr_inicio, dt_hr_fim, km_viagem, was_analyzed) VALUES
(18, 11, 11, 11, 12, '2023-02-12 07:00:00', '2023-02-12 12:00:00', '320', TRUE),
(19, 12, 12, 12, 13, '2023-03-10 06:30:00', '2023-03-10 15:00:00', '780', FALSE),
(20, 13, 13, 13, 14, '2023-04-22 05:15:00', '2023-04-22 18:30:00', '920', TRUE),
(21, 14, 14, 14, 15, '2023-05-03 08:00:00', '2023-05-03 11:30:00', '210', FALSE),
(22, 15, 15, 15, 16, '2023-06-14 09:00:00', '2023-06-14 14:45:00', '450', TRUE),
(23, 16, 16, 16, 17, '2023-07-18 07:40:00', '2023-07-18 19:20:00', '1000', FALSE),
(24, 17, 17, 17, 18, '2023-08-21 06:50:00', '2023-08-21 13:10:00', '360', TRUE),
(25, 18, 18, 18, 19, '2023-09-30 05:00:00', '2023-09-30 15:40:00', '820', FALSE),
(26, 19, 19, 19, 20, '2023-10-12 08:15:00', '2023-10-12 16:00:00', '540', TRUE),
(27, 20, 20, 20, 11, '2023-11-04 07:30:00', '2023-11-04 13:30:00', '410', FALSE),
(28, 21, 21, 11, 13, '2024-01-18 06:00:00', '2024-01-18 14:00:00', '600', TRUE),
(29, 22, 22, 12, 14, '2024-02-22 05:45:00', '2024-02-22 13:15:00', '720', FALSE),
(30, 23, 23, 13, 15, '2024-03-20 07:20:00', '2024-03-20 12:00:00', '280', TRUE),
(31, 24, 24, 14, 16, '2024-04-15 08:30:00', '2024-04-15 17:55:00', '950', FALSE),
(32, 25, 25, 15, 17, '2024-05-10 06:10:00', '2024-05-10 16:45:00', '860', TRUE),
(33, 26, 26, 16, 18, '2024-06-06 09:00:00', '2024-06-06 20:30:00', '1200', FALSE),
(34, 27, 27, 17, 19, '2024-07-07 05:30:00', '2024-07-07 12:40:00', '400', TRUE),
(35, 28, 28, 18, 20, '2024-08-09 07:45:00', '2024-08-09 18:20:00', '980', FALSE),
(36, 29, 29, 19, 11, '2024-09-11 06:00:00', '2024-09-11 14:10:00', '640', TRUE),
(37, 30, 30, 20, 12, '2024-10-15 08:05:00', '2024-10-15 13:05:00', '320', FALSE),
(38, 11, 21, 11, 14, '2024-11-20 06:55:00', '2024-11-20 18:10:00', '980', TRUE),
(39, 12, 22, 12, 15, '2025-01-10 05:15:00', '2025-01-10 12:40:00', '720', TRUE),
(40, 13, 23, 13, 16, '2025-02-14 07:30:00', '2025-02-14 16:50:00', '840', FALSE),
(41, 14, 24, 14, 17, '2025-03-21 08:10:00', '2025-03-21 12:30:00', '300', TRUE),
(42, 15, 25, 15, 18, '2025-04-12 06:30:00', '2025-04-12 16:30:00', '960', FALSE),
(43, 16, 26, 16, 19, '2025-05-02 07:00:00', '2025-05-02 15:20:00', '700', TRUE),
(44, 17, 27, 17, 20, '2025-06-09 06:20:00', '2025-06-09 14:00:00', '560', FALSE),
(45, 18, 28, 18, 11, '2025-07-01 05:40:00', '2025-07-01 13:30:00', '680', TRUE),
(46, 19, 29, 19, 12, '2025-08-16 07:10:00', '2025-08-16 18:45:00', '1020', FALSE),
(47, 20, 30, 20, 13, '2025-09-05 06:00:00', '2025-09-05 14:00:00', '600', TRUE),
(48, 21, 11, 11, 15, '2025-09-20 08:20:00', '2025-09-20 12:50:00', '330', FALSE),
(49, 22, 12, 12, 16, '2025-09-25 07:30:00', '2025-09-25 16:10:00', '780', TRUE),
(50, 23, 13, 13, 17, '2025-09-28 06:15:00', '2025-09-28 15:45:00', '910', FALSE),
(51, 24, 14, 14, 18, '2025-10-01 05:50:00', '2025-10-01 13:50:00', '620', TRUE),
(52, 25, 15, 15, 19, '2025-10-02 09:10:00', '2025-10-02 18:30:00', '980', FALSE),
(53, 26, 16, 16, 20, '2025-10-03 06:05:00', '2025-10-03 15:00:00', '720', TRUE),
(54, 27, 17, 17, 11, '2025-10-04 07:00:00', '2025-10-04 13:00:00', '420', FALSE),
(55, 28, 18, 18, 12, '2025-10-05 08:30:00', '2025-10-05 13:30:00', '380', TRUE),
(56, 29, 19, 19, 13, '2025-10-06 06:45:00', '2025-10-06 11:45:00', '300', FALSE),
(57, 30, 20, 20, 14, '2025-10-07 09:00:00', '2025-10-07 16:30:00', '760', TRUE);



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
(10, 10, 10,'Uso não autorizado do veículo investigado.', '2023-10-05 15:55:00'),
(11, 11, 1, 'Excesso de velocidade registrado, motorista advertido.', '2025-10-04 11:30:00'),
(12, 12, 2, 'Desvio de rota identificado, orientações fornecidas.', '2025-10-05 12:45:00'),
(13, 13, 3, 'Frenagem brusca analisada, sem medidas adicionais.', '2025-10-06 10:15:00'),
(14, 14, 4, 'Colisão investigada, medidas corretivas implementadas.', '2025-10-07 13:20:00'),
(15, 15, 5, 'Uso não autorizado do veículo investigado.', '2025-10-08 14:50:00'),
(16, 18, 11, 'Orientado sobre manutenção preventiva do veículo.', '2023-02-12 13:00:00'),
(17, 19, 12, 'Frenagem brusca sem feridos; relatório enviado.', '2023-03-10 14:00:00'),
(18, 20, 13, 'Checagem de carga realizada antes da saída.', '2023-04-22 19:00:00'),
(19, 21, 14, 'Relatório de tempo de condução entregue ao RH.', '2023-05-03 12:00:00'),
(20, 22, 15, 'Motorista recebeu treinamento de segurança.', '2023-06-14 15:00:00'),
(21, 23, 16, 'Aviso sobre rota alternativa emitido.', '2023-07-18 20:00:00'),
(22, 24, 17, 'Verificação documental completa.', '2023-08-21 14:00:00'),
(23, 25, 18, 'Carga inspecionada, acondicionamento revisado.', '2023-09-30 16:00:00'),
(24, 26, 19, 'Manutenção corretiva agendada.', '2023-10-12 17:00:00'),
(25, 27, 20, 'Relatório de consumo e km enviado.', '2023-11-04 14:00:00'),
(26, 28, 21, 'Conduta exemplar na entrega.', '2024-01-18 15:00:00'),
(27, 29, 22, 'Falta de documentos menores regularizada.', '2024-02-22 13:30:00'),
(28, 30, 23, 'Acelerações detectadas; coaching aplicado.', '2024-03-20 12:30:00'),
(29, 31, 24, 'Alinhamento de políticas de carga.', '2024-04-15 18:30:00'),
(30, 32, 25, 'Ajuste de rota feito para evitar obras.', '2024-05-10 17:00:00'),
(31, 33, 26, 'Falha de comunicação; treinamento marcado.', '2024-06-06 21:00:00'),
(32, 34, 27, 'Colisão leve, motorista passa bem.', '2024-07-07 13:00:00'),
(33, 35, 28, 'Carga violada; polícia acionada.', '2024-08-09 20:00:00'),
(34, 36, 29, 'Parada não autorizada discutida.', '2024-09-11 15:00:00'),
(35, 37, 30, 'Uso indevido do veículo; suspensão temporária.', '2024-10-15 14:00:00'),
(36, 38, 21, 'Excesso de velocidade monitorado; advertência.', '2024-11-20 19:00:00'),
(37, 39, 22, 'Rota entregue; sem incidentes.', '2025-01-10 13:00:00'),
(38, 40, 23, 'Check-up antes da viagem de longa distância.', '2025-02-14 17:00:00'),
(39, 41, 24, 'Motorista premiado por segurança.', '2025-03-21 13:00:00'),
(40, 42, 25, 'Manutenção preventiva concluída.', '2025-04-12 17:30:00'),
(41, 43, 26, 'Relatório de batidas de radar anexado.', '2025-05-02 16:00:00'),
(42, 44, 27, 'Treinamento de direção defensiva finalizado.', '2025-06-09 15:30:00'),
(43, 45, 28, 'Relatório de carga entregue ao cliente.', '2025-07-01 14:00:00'),
(44, 46, 29, 'Investigação sobre perda de carga em andamento.', '2025-08-16 18:00:00'),
(45, 47, 30, 'Inventário do caminhão concluído.', '2025-09-05 15:00:00'),
(46, 48, 11, 'Orientações de direção para motorista novo.', '2025-09-20 13:30:00'),
(47, 49, 12, 'Falha de freio relatada ao setor de manutenção.', '2025-09-25 14:45:00'),
(48, 50, 13, 'Atenção à carga refrigerada: controle de temperatura.', '2025-09-28 16:30:00'),
(49, 51, 14, 'Registro de ocorrência interno', '2025-10-01 15:10:00'),
(50, 52, 15, 'Relatório de viagem curto', '2025-10-02 19:00:00'),
(51, 53, 16, 'Checklist obrigatório realizado', '2025-10-03 16:10:00'),
(52, 54, 17, 'Advertência por velocidade', '2025-10-04 11:30:00'),
(53, 55, 18, 'Reunião com cliente sobre avaria na carga', '2025-10-05 14:20:00'),
(54, 56, 19, 'Treinamento adicional agendado', '2025-10-06 12:00:00'),
(55, 57, 20, 'Registro de situação de emergência', '2025-10-07 17:00:00');


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
(10, 10, 10, '2023-10-05 12:45:00', 3, -3.731862, -38.526669, 85.0),
(11, 11, 1, '2025-10-04 09:15:00', 1, -23.550520, -46.633308, 98.2),
(12, 11, 2, '2025-10-04 10:05:00', 6, -23.548900, -46.650000, NULL),
(13, 12, 3, '2025-10-05 08:55:00', 2, -22.909938, -47.062633, 72.5),
(14, 12, 1, '2025-10-05 11:10:00', 1, -22.910500, -47.060000, 105.0),
(15, 12, 4, '2025-10-05 12:40:00', 5, -22.912000, -47.058000, 0.0),
(16, 12, 5, '2025-10-05 14:20:00', 9, -22.913500, -47.057000, NULL),
(17, 13, 6, '2025-10-06 07:30:00', 3, -22.906847, -43.172896, 88.7),
(18, 13, 7, '2025-10-06 09:45:00', 2, -22.905000, -43.170000, 66.0),
(19, 13, 8, '2025-10-06 13:20:00', 8, -22.904000, -43.168000, NULL),
(20, 14, 9, '2025-10-07 10:05:00', 4, -25.428356, -49.273251, 40.0),
(21, 14, 3, '2025-10-07 11:30:00', 1, -25.427000, -49.270000, 112.3),
(22, 14, 2, '2025-10-07 14:50:00', 6, -25.426000, -49.275000, NULL),
(23, 14, 1, '2025-10-07 16:10:00', 7, -25.425000, -49.276000, NULL),
(24, 15, 4, '2025-10-08 06:20:00', 1, -19.916681, -43.934493, 95.0),
(25, 15, 5, '2025-10-08 09:40:00', 10, -19.918000, -43.933000, NULL),
(26, 15, 3, '2025-10-08 11:55:00', 2, -19.919000, -43.932000, 70.2),
(27, 11, 6, '2025-10-09 08:15:00', 3, -30.034647, -51.217658, 82.5),
(28, 12, 7, '2025-10-09 13:30:00', 9, -30.035000, -51.218000, NULL),
(29, 16, 8, '2025-10-10 15:45:00', 1, -3.731862, -38.526669, 88.0),
(30, 16, 9, '2025-10-11 10:20:00', 2, -12.977749, -38.501630, 60.3),
(31, 18, 11, '2023-02-12 09:15:00', 11, -21.177, -47.810, 72.4),
(32, 18, 11, '2023-02-12 10:50:00', 15, -21.180, -47.820, 0.0),
(33, 19, 12, '2023-03-10 08:40:00', 2, -22.000, -47.000, 85.0),
(34, 19, 12, '2023-03-10 12:00:00', 12, -22.010, -47.010, 110.5),
(35, 20, 13, '2023-04-22 11:30:00', 3, -19.900, -43.900, 88.0),
(36, 20, 13, '2023-04-22 15:05:00', 14, -19.905, -43.905, NULL),
(37, 21, 14, '2023-05-03 09:10:00', 1, -25.000, -54.000, 95.3),
(38, 22, 15, '2023-06-14 10:25:00', 6, -23.000, -46.000, 60.0),
(39, 22, 15, '2023-06-14 13:20:00', 8, -23.002, -46.002, NULL),
(40, 23, 16, '2023-07-18 12:55:00', 4, -25.435, -49.272, 40.0),
(41, 24, 17, '2023-08-21 08:30:00', 5, -12.980, -38.500, 0.0),
(42, 25, 18, '2023-09-30 09:10:00', 7, -3.120, -60.025, 55.4),
(43, 26, 19, '2023-10-12 11:05:00', 9, -15.780, -47.900, NULL),
(44, 27, 20, '2023-11-04 09:55:00', 10, -23.550, -46.650, NULL),
(45, 28, 21, '2024-01-18 09:30:00', 11, -21.180, -47.810, 78.9),
(46, 29, 22, '2024-02-22 10:55:00', 12, -22.020, -47.020, 105.2),
(47, 30, 23, '2024-03-20 08:10:00', 16, -19.910, -43.930, 82.0),
(48, 31, 24, '2024-04-15 11:55:00', 17, -16.680, -49.260, 60.0),
(49, 32, 25, '2024-05-10 12:20:00', 18, -26.900, -49.200, 92.3),
(50, 33, 26, '2024-06-06 10:40:00', 19, -25.450, -49.300, 0.0),
(51, 34, 27, '2024-07-07 09:00:00', 20, -14.235, -51.925, NULL),
(52, 35, 28, '2024-08-09 14:15:00', 8, -38.501, -38.501, NULL),
(53, 36, 29, '2024-09-11 07:30:00', 3, -3.730, -38.520, 74.1),
(54, 37, 30, '2024-10-15 10:20:00', 1, -23.550, -46.620, 101.4),
(55, 38, 21, '2024-11-20 11:05:00', 11, -21.190, -47.820, 69.7),
(56, 39, 22, '2025-01-10 09:10:00', 12, -22.030, -47.030, 98.6),
(57, 40, 23, '2025-02-14 13:45:00', 2, -19.920, -43.920, 88.9),
(58, 41, 24, '2025-03-21 10:00:00', 4, -25.430, -49.275, 37.2),
(59, 42, 25, '2025-04-12 12:30:00', 5, -19.915, -43.935, 0.0),
(60, 43, 26, '2025-05-02 11:10:00', 6, -21.200, -47.860, 76.5),
(61, 44, 27, '2025-06-09 08:45:00', 7, -22.900, -43.170, 64.4),
(62, 45, 28, '2025-07-01 09:50:00', 8, -38.502, -38.502, NULL),
(63, 46, 29, '2025-08-16 10:35:00', 9, -3.130, -60.030, NULL),
(64, 47, 30, '2025-09-05 11:25:00', 10, -21.180, -47.820, NULL),
(65, 48, 11, '2025-09-20 10:05:00', 1, -23.560, -46.640, 97.8),
(66, 49, 12, '2025-09-25 14:20:00', 12, -22.040, -47.040, 103.1),
(67, 50, 13, '2025-09-28 09:40:00', 15, -19.920, -43.930, 0.0),
(68, 51, 14, '2025-10-01 09:00:00', 3, -25.426, -49.271, 81.2),
(69, 52, 15, '2025-10-02 12:00:00', 16, -19.919, -43.932, 66.6),
(70, 53, 16, '2025-10-03 10:15:00', 17, -22.912, -47.058, 59.0),
(71, 54, 17, '2025-10-04 08:45:00', 18, -23.550, -46.650, 88.8),
(72, 55, 18, '2025-10-05 11:50:00', 19, -22.909, -47.062, NULL),
(73, 56, 19, '2025-10-06 07:05:00', 20, -22.906, -43.170, NULL),
(74, 57, 20, '2025-10-07 12:10:00', 1, -25.428, -49.276, 112.0),
-- geração de mais ocorrências rápidas para testar volume e diversidade:
(75, 18, 11, '2023-02-12 07:35:00', 16, -21.175, -47.812, 65.0),
(76, 19, 12, '2023-03-10 09:00:00', 17, -22.011, -47.011, 55.0),
(77, 20, 13, '2023-04-22 12:00:00', 18, -19.906, -43.906, 90.0),
(78, 21, 14, '2023-05-03 10:30:00', 11, -25.001, -54.001, 98.0),
(79, 22, 15, '2023-06-14 14:00:00', 12, -23.003, -46.003, 108.5),
(80, 23, 16, '2023-07-18 18:00:00', 13, -25.436, -49.273, 0.0),
(81, 24, 17, '2023-08-21 11:00:00', 14, -12.981, -38.502, NULL),
(82, 25, 18, '2023-09-30 13:00:00', 15, -3.121, -60.026, 0.0),
(83, 26, 19, '2023-10-12 12:45:00', 11, -23.551, -46.651, 75.0),
(84, 27, 20, '2023-11-04 11:30:00', 12, -21.181, -47.821, 100.0),
(85, 28, 21, '2024-01-18 10:00:00', 16, -21.182, -47.822, 68.9),
(86, 29, 22, '2024-02-22 11:30:00', 17, -22.025, -47.025, 58.4),
(87, 30, 23, '2024-03-20 10:50:00', 18, -19.915, -43.915, 93.1),
(88, 31, 24, '2024-04-15 13:10:00', 19, -16.682, -49.262, NULL),
(89, 32, 25, '2024-05-10 14:05:00', 20, -26.902, -49.202, 0.0),
(90, 33, 26, '2024-06-06 16:00:00', 1, -25.452, -49.305, 85.6),
(91, 34, 27, '2024-07-07 11:00:00', 2, -14.236, -51.926, 92.2),
(92, 35, 28, '2024-08-09 17:30:00', 3, -38.503, -38.503, 80.0),
(93, 36, 29, '2024-09-11 09:55:00', 4, -3.732, -38.528, 42.0),
(94, 37, 30, '2024-10-15 12:00:00', 5, -23.555, -46.635, 0.0),
(95, 38, 21, '2024-11-20 12:30:00', 6, -21.195, -47.825, 79.5),
(96, 39, 22, '2025-01-10 11:00:00', 7, -22.035, -47.035, 63.0),
(97, 40, 23, '2025-02-14 15:30:00', 8, -19.930, -43.935, NULL),
(98, 41, 24, '2025-03-21 09:20:00', 9, -25.435, -49.278, NULL),
(99, 42, 25, '2025-04-12 09:45:00', 10, -19.917, -43.936, NULL),
(100, 43, 26, '2025-05-02 10:50:00', 11, -21.205, -47.865, 95.0),
(101, 44, 27, '2025-06-09 09:15:00', 12, -22.905, -43.169, 99.9),
(102, 45, 28, '2025-07-01 10:05:00', 13, -38.504, -38.504, 0.0),
(103, 46, 29, '2025-08-16 11:30:00', 14, -3.135, -60.035, NULL),
(104, 47, 30, '2025-09-05 12:40:00', 15, -21.185, -47.830, 0.0),
(105, 48, 11, '2025-09-20 09:50:00', 16, -23.562, -46.642, 68.0),
(106, 49, 12, '2025-09-25 10:40:00', 17, -22.045, -47.045, 57.5),
(107, 50, 13, '2025-09-28 11:30:00', 18, -19.925, -43.935, 89.0),
(108, 51, 14, '2025-10-01 11:20:00', 19, -25.427, -49.270, NULL),
(109, 52, 15, '2025-10-02 13:50:00', 20, -19.918, -43.933, NULL),
(110, 53, 16, '2025-10-03 13:10:00', 1, -22.912, -47.058, 102.0);

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
(10, 10, 10, 10, 'http://eitruck/video10.mp4'),
(11, 11, 11, 1, 'http://eitruck/video11.mp4'),
(12, 12, 12, 2, 'http://eitruck/video12.mp4'),
(13, 13, 13, 3, 'http://eitruck/video13.mp4'),
(14, 14, 14, 4, 'http://eitruck/video14.mp4'),
(15, 15, 15, 5, 'http://eitruck/video15.mp4'),
(16, 18, 31, 11, 'http://eitruck/video31.mp4', FALSE),
(17, 18, 32, 11, 'http://eitruck/video32.mp4', FALSE),
(18, 19, 33, 12, 'http://eitruck/video33.mp4', FALSE),
(19, 19, 34, 12, 'http://eitruck/video34.mp4', TRUE),
(20, 20, 35, 13, 'http://eitruck/video35.mp4', FALSE),
(21, 20, 36, 13, 'http://eitruck/video36.mp4', TRUE),
(22, 21, 37, 14, 'http://eitruck/video37.mp4', FALSE),
(23, 22, 38, 15, 'http://eitruck/video38.mp4', FALSE),
(24, 22, 39, 15, 'http://eitruck/video39.mp4', TRUE),
(25, 23, 40, 16, 'http://eitruck/video40.mp4', FALSE),
(26, 24, 41, 17, 'http://eitruck/video41.mp4', FALSE),
(27, 25, 42, 18, 'http://eitruck/video42.mp4', TRUE),
(28, 26, 43, 19, 'http://eitruck/video43.mp4', FALSE),
(29, 27, 44, 20, 'http://eitruck/video44.mp4', FALSE),
(30, 28, 45, 21, 'http://eitruck/video45.mp4', TRUE),
(31, 29, 46, 22, 'http://eitruck/video46.mp4', FALSE),
(32, 30, 47, 23, 'http://eitruck/video47.mp4', FALSE),
(33, 31, 48, 24, 'http://eitruck/video48.mp4', TRUE),
(34, 32, 49, 25, 'http://eitruck/video49.mp4', FALSE),
(35, 33, 50, 26, 'http://eitruck/video50.mp4', FALSE),
(36, 34, 51, 27, 'http://eitruck/video51.mp4', TRUE),
(37, 35, 52, 28, 'http://eitruck/video52.mp4', FALSE),
(38, 36, 53, 29, 'http://eitruck/video53.mp4', FALSE),
(39, 37, 54, 30, 'http://eitruck/video54.mp4', TRUE),
(40, 38, 55, 21, 'http://eitruck/video55.mp4', FALSE),
(41, 39, 56, 22, 'http://eitruck/video56.mp4', FALSE),
(42, 40, 57, 23, 'http://eitruck/video57.mp4', TRUE),
(43, 41, 58, 24, 'http://eitruck/video58.mp4', FALSE),
(44, 42, 59, 25, 'http://eitruck/video59.mp4', FALSE),
(45, 43, 60, 26, 'http://eitruck/video60.mp4', TRUE),
(46, 44, 61, 27, 'http://eitruck/video61.mp4', FALSE),
(47, 45, 62, 28, 'http://eitruck/video62.mp4', FALSE),
(48, 46, 63, 29, 'http://eitruck/video63.mp4', TRUE),
(49, 47, 64, 30, 'http://eitruck/video64.mp4', FALSE),
(50, 48, 65, 11, 'http://eitruck/video65.mp4', FALSE),
(51, 49, 66, 12, 'http://eitruck/video66.mp4', TRUE),
(52, 50, 67, 13, 'http://eitruck/video67.mp4', FALSE),
(53, 51, 68, 14, 'http://eitruck/video68.mp4', FALSE),
(54, 52, 69, 15, 'http://eitruck/video69.mp4', TRUE),
(55, 53, 70, 16, 'http://eitruck/video70.mp4', FALSE),
(56, 54, 71, 17, 'http://eitruck/video71.mp4', FALSE),
(57, 55, 72, 18, 'http://eitruck/video72.mp4', TRUE),
(58, 56, 73, 19, 'http://eitruck/video73.mp4', FALSE),
(59, 57, 74, 20, 'http://eitruck/video74.mp4', FALSE),
(60, 18, 75, 11, 'http://eitruck/video75.mp4', TRUE);

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
(10, 10, 10, 'http://eitruck/concat_video10.mp4'),
(11, 11, 1, 'http://eitruck/concat_video11.mp4'),
(12, 11, 2, 'http://eitruck/concat_video12.mp4'),
(13, 12, 3, 'http://eitruck/concat_video13.mp4'),
(14, 12, 1, 'http://eitruck/concat_video14.mp4'),
(15, 12, 4, 'http://eitruck/concat_video15.mp4'),
(16, 12, 5, 'http://eitruck/concat_video16.mp4'),
(17, 18, 11, 'http://eitruck/concat_video31_32.mp4'),
(18, 19, 12, 'http://eitruck/concat_video33_34.mp4'),
(19, 20, 13, 'http://eitruck/concat_video35_36.mp4'),
(20, 21, 14, 'http://eitruck/concat_video37_38.mp4'),
(21, 22, 15, 'http://eitruck/concat_video39_40.mp4'),
(22, 23, 16, 'http://eitruck/concat_video41_42.mp4'),
(23, 24, 17, 'http://eitruck/concat_video43_44.mp4'),
(24, 25, 18, 'http://eitruck/concat_video45_46.mp4'),
(25, 26, 19, 'http://eitruck/concat_video47_48.mp4'),
(26, 27, 20, 'http://eitruck/concat_video49_50.mp4'),
(27, 28, 21, 'http://eitruck/concat_video51_52.mp4'),
(28, 29, 22, 'http://eitruck/concat_video53_54.mp4'),
(29, 30, 23, 'http://eitruck/concat_video55_56.mp4'),
(30, 31, 24, 'http://eitruck/concat_video57_58.mp4'),
(31, 32, 25, 'http://eitruck/concat_video59_60.mp4'),
(32, 33, 26, 'http://eitruck/concat_video61_62.mp4'),
(33, 34, 27, 'http://eitruck/concat_video63_64.mp4'),
(34, 35, 28, 'http://eitruck/concat_video65_66.mp4'),
(35, 36, 29, 'http://eitruck/concat_video67_68.mp4'),
(36, 37, 30, 'http://eitruck/concat_video69_70.mp4'),
(37, 38, 21, 'http://eitruck/concat_video71_72.mp4'),
(38, 39, 22, 'http://eitruck/concat_video73_74.mp4'),
(39, 40, 23, 'http://eitruck/concat_video75_76.mp4'),
(40, 41, 24, 'http://eitruck/concat_video77_78.mp4');

-- =============================
-- VIEWS
-- =============================
CREATE VIEW vw_relatorio_simples_viagem (
    id_viagem,
    placa_caminhao,
    data_inicio_viagem,
    km_viagem,
    pontuacao_total,
    was_analyzed
) AS
SELECT
    v.id              AS id_viagem,
    c.placa           AS placa_caminhao,
    v.dt_hr_inicio    AS data_inicio_viagem,
    v.km_viagem       AS km_viagem,
    SUM(ti.pontuacao) AS pontuacao_total,
    v.was_analyzed    AS was_analyzed
FROM tb_viagem v
JOIN tb_infracao o on v.id = o.id_viagem
JOIN tb_caminhao c  ON v.id_caminhao = c.id
JOIN tb_motorista m ON m.id = o.id_motorista
JOIN tb_tipo_infracao ti ON o.id_tipo_infracao = ti.id
GROUP BY v.id, c.placa, v.dt_hr_inicio, v.km_viagem, v.was_analyzed
order by v.id;


CREATE VIEW vw_visao_basica_viagem (
    id_viagem,
    placa_caminhao,
    data_inicio_viagem,
    data_fim_viagem,
    km_viagem,
    segmento,
    unidade,
    nome_motorista,
    risco_motorista,
    url_midia_concatenada,
    tipo_gravidade,
    tipo_infracao
) AS
SELECT
    v.id            AS id_viagem,
    c.placa         AS placa_caminhao,
    v.dt_hr_inicio  AS data_inicio_viagem,
    v.dt_hr_fim     AS data_fim_viagem,
    v.km_viagem     AS km_viagem,
    s.nome          AS segmento,
    u.nome          AS unidade,
    m.nome_completo AS nome_motorista,
    tr.nome         AS risco_motorista,
    mc.url          AS url_midia_concatenada,
    tg.nome         AS tipo_gravidade,
    t.nome          AS tipo_infracao
FROM tb_viagem v
JOIN tb_infracao o           ON o.id_viagem = v.id
JOIN tb_motorista m          ON m.id = o.id_motorista
JOIN tb_tipo_risco tr        ON m.id_tipo_risco = tr.id
JOIN tb_tipo_infracao t      ON t.id = o.id_tipo_infracao
JOIN tb_tipo_gravidade tg    ON t.id_tipo_gravidade = tg.id
JOIN tb_midia_concatenada mc ON mc.id_motorista = m.id AND mc.id_viagem = v.id
JOIN tb_unidade u            ON u.id = m.id_unidade
JOIN tb_segmento s           ON s.id = m.id_unidade
JOIN tb_caminhao c           ON c.id = v.id_caminhao
GROUP BY v.id, c.placa, v.dt_hr_inicio, v.dt_hr_fim, s.nome, u.nome, m.nome_completo, tr.nome, mc.url, tg.nome, t.nome, m.id_unidade
ORDER BY v.id;


CREATE VIEW vw_ocorrencia_por_viagem (
    id_viagem,
    total_ocorrencias
) AS
SELECT
    COUNT(o.id) AS total_ocorrencias,
    v.id        AS id_viagem
FROM tb_infracao o
JOIN tb_viagem v ON o.id_viagem = v.id
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
GROUP BY v.id, t.nome;

CREATE VIEW vw_motorista_pontuacao_mensal(
    ranking_pontuacao,
    motorista,
    id_unidade,
    unidade,
    id_segmento,
    segmento,
    pontuacao_ultimo_mes
) AS
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(ti.pontuacao) DESC) AS rank_pontuacao,
    m.nome_completo   AS motorista,
    u.id              AS id_unidade,
    u.nome            AS unidade,
    s.id              AS id_segmento,
    s.nome            AS segmento,
    SUM(ti.pontuacao) AS pontuacao_ultimo_mes
FROM tb_infracao i
JOIN public.tb_motorista m      ON i.id_motorista = m.id
JOIN public.tb_tipo_infracao ti ON i.id_tipo_infracao = ti.id
JOIN public.tb_unidade u        ON m.id_unidade = u.id
JOIN public.tb_segmento s       ON u.id_segmento = s.id
WHERE
    EXTRACT(MONTH FROM i.dt_hr_evento) >= EXTRACT(MONTH FROM current_date) - 1
    AND EXTRACT(YEAR FROM i.dt_hr_evento) = EXTRACT(YEAR FROM current_date)
GROUP BY m.id, m.nome_completo, u.id, u.nome, s.id, s.nome
ORDER BY rank_pontuacao;


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


CREATE VIEW vw_total_ocorrencias (
    total_ocorrencias,
    mes,
    ano
) AS
SELECT
    COUNT(o.id) AS total_ocorrencias,
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano
FROM tb_infracao o
group by mes, ano
order by ano desc, mes desc;


CREATE VIEW vw_ocorrencias_por_gravidade (
    total_ocorrencias,
    gravidade,
    mes,
    ano
) AS
SELECT
    COUNT(o.id) AS total_ocorrencias,
    tg.nome AS gravidade,
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano
FROM tb_infracao o
JOIN tb_tipo_infracao t     ON o.id_tipo_infracao = t.id
JOIN tb_tipo_gravidade tg   ON t.id_tipo_gravidade = tg.id
GROUP BY tg.nome, mes, ano;


CREATE VIEW vw_motorista_quantidade_infracoes (
    motorista,
    quantidade_infracoes,
    mes,
    ano
) AS
SELECT
    m.nome_completo as motorista,
    count(ti.id) as quantidade_infracoes,
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano
FROM tb_motorista m
JOIN tb_infracao ti on m.id = ti.id_motorista
group by m.nome_completo, mes, ano
order by quantidade_infracoes;


CREATE VIEW vw_variacao_mes_passado_por_mes_ano AS
WITH totais AS (
    SELECT
        EXTRACT(MONTH FROM dt_hr_evento) AS mes,
        EXTRACT(YEAR FROM dt_hr_evento) AS ano,
        COUNT(*) AS total_infracoes
    FROM tb_infracao
    GROUP BY EXTRACT(YEAR FROM dt_hr_evento), EXTRACT(MONTH FROM dt_hr_evento)
) SELECT
    t1.mes,
    t1.ano,
    t1.total_infracoes AS infracoes_mes_atual,
    t2.total_infracoes AS infracoes_mes_passado,
    ((t1.total_infracoes - t2.total_infracoes)::numeric / NULLIF(t2.total_infracoes, 0)) * 100 AS variacao
FROM totais t1
LEFT JOIN totais t2 ON t1.mes = t2.mes + 1 AND t1.ano = t2.ano;


CREATE VIEW vw_ocorrencias_por_tipo (
    tipo_infracao,
    total_ocorrencias,
    porcentagem_do_total,
    mes,
    ano
) AS
SELECT
    t.nome AS tipo_infracao,
    COUNT(o.id) AS total_ocorrencias,
    ROUND((COUNT(o.id)::decimal / SUM(COUNT(o.id)) OVER (PARTITION BY extract(month from dt_hr_evento), extract(year from dt_hr_evento))) * 100, 2) AS porcentagem_do_total,
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano
FROM tb_infracao o
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
GROUP BY t.nome, mes, ano;


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




