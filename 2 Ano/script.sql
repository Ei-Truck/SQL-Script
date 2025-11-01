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
drop view if exists vw_motorista_pontuacao_mensal;
drop view if exists vw_relatorio_simples_viagem;
drop view if exists vw_visao_basica_viagem_info;
drop view if exists vw_visao_basica_viagem_motorista_info;
drop view if exists vw_ocorrencia_por_viagem;
drop view if exists vw_total_ocorrencias;
drop view if exists vw_ocorrencias_por_gravidade;
drop view if exists vw_motorista_quantidade_infracoes;
drop view if exists vw_variacao_mes_passado_por_mes_ano;
drop view if exists vw_ocorrencias_por_tipo;
drop view if exists vw_qntd_infracoes_viagem_motorista;
drop view if exists vw_relatorio_semanal_infracoes;
drop procedure if exists prc_registrar_login_usuario(integer);
drop procedure if exists prc_atualiza_segmento();
drop procedure if exists prc_atualiza_endereco();
drop procedure if exists prc_atualiza_unidade();
drop procedure if exists prc_atualiza_analista();
drop procedure if exists prc_atualiza_administrador();
drop function if exists fn_atualizar_dau();


-- =============================
-- STATUS E TABELAS DE APOIO
-- =============================
CREATE TABLE tb_tipo_gravidade (
    id               SERIAL PRIMARY KEY,
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
    rua              TEXT,
    numero           INTEGER,
    bairro           TEXT,
    estado           VARCHAR(2),
    cidade           VARCHAR(80) NOT NULL,
    pais             TEXT,
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
-- VIEWS
-- =============================
CREATE VIEW vw_relatorio_simples_viagem (
    id_viagem,
    placa_caminhao,
    data_inicio_viagem,
    km_viagem,
    id_segmento,
    id_unidade,
    id_localidade,
    pontuacao_total,
    was_analyzed
) AS
SELECT
    v.id              AS id_viagem,
    c.placa           AS placa_caminhao,
    v.dt_hr_inicio    AS data_inicio_viagem,
    v.km_viagem       AS km_viagem,
    s.id              AS id_segmento,
    u.id              AS id_unidade,
    l.id  AS id_localidade,
    SUM(ti.pontuacao) AS pontuacao_total,
    v.was_analyzed    AS was_analyzed
FROM tb_viagem v
JOIN tb_infracao o on v.id = o.id_viagem
JOIN tb_caminhao c  ON v.id_caminhao = c.id
JOIN tb_motorista m ON m.id = o.id_motorista
JOIN tb_segmento s ON s.id = c.id_segmento
JOIN tb_unidade u ON u.id = m.id_unidade
JOIN tb_localidade l ON u.id_localidade = l.id
JOIN tb_tipo_infracao ti ON o.id_tipo_infracao = ti.id
GROUP BY v.id, c.placa, v.dt_hr_inicio, v.km_viagem, v.was_analyzed, s.id, u.id, l.id
order by v.id;


CREATE OR REPLACE VIEW vw_visao_basica_viagem_info (
    id_viagem,
    placa_caminhao,
    data_inicio_viagem,
    data_fim_viagem,
    km_viagem,
    segmento
    ) AS
SELECT
    v.id            AS id_viagem,
    c.placa         AS placa_caminhao,
    v.dt_hr_inicio  AS data_inicio_viagem,
    v.dt_hr_fim     AS data_fim_viagem,
    v.km_viagem     AS km_viagem,
    s.nome AS segmento
FROM tb_viagem v
         JOIN tb_infracao o            ON o.id_viagem = v.id
         JOIN tb_motorista m          ON m.id = o.id_motorista
         JOIN tb_tipo_infracao t      ON t.id = o.id_tipo_infracao
         JOIN tb_tipo_gravidade tg    ON t.id_tipo_gravidade = tg.id
         JOIN tb_midia_concatenada mc ON mc.id_motorista = m.id AND mc.id_viagem = v.id
         JOIN tb_caminhao c           ON c.id = v.id_caminhao
         JOIN tb_segmento s           ON s.id = c.id_segmento
GROUP BY v.id, c.id, s.nome
ORDER BY v.id;

CREATE VIEW vw_visao_basica_viagem_motorista_info (
    id_viagem,
    id_motorista,
    id_segmento,
    segmento,
    id_unidade,
    unidade,
    id_localidade,
    nome_motorista,
    risco_motorista,
    url_midia_concatenada,
    url_foto_motorista
) AS
SELECT
    v.id            AS id_viagem,
    m.id            AS id_motorista,
    s.id            AS id_segmento,
    s.nome          AS segmento,
    u.id            AS id_unidade,
    u.nome          AS unidade,
    l.id            AS id_localidade,
    m.nome_completo AS nome_motorista,
    tr.nome         AS risco_motorista,
    mc.url          AS url_midia_concatenada,
    m.url_foto      AS url_foto_motorista
FROM tb_viagem v
JOIN tb_infracao o            ON o.id_viagem = v.id
JOIN tb_motorista m          ON m.id = o.id_motorista
JOIN tb_tipo_risco tr        ON m.id_tipo_risco = tr.id
JOIN tb_tipo_infracao t      ON t.id = o.id_tipo_infracao
JOIN tb_tipo_gravidade tg    ON t.id_tipo_gravidade = tg.id
FULL JOIN tb_midia_concatenada mc ON mc.id_motorista = m.id AND mc.id_viagem = v.id
JOIN tb_unidade u            ON u.id = m.id_unidade
JOIN tb_segmento s           ON s.id = m.id_unidade
JOIN tb_caminhao c           ON c.id = v.id_caminhao
JOIN tb_localidade l on u.id_localidade = l.id
GROUP BY v.id, c.id, s.id, u.id,  l.id, m.id, tr.nome, mc.url
ORDER BY v.id;


CREATE VIEW vw_ocorrencia_por_viagem (
    id_viagem,
    total_ocorrencias
) AS
SELECT
    v.id        AS id_viagem,
    COUNT(o.id) AS total_ocorrencias
FROM tb_infracao o
JOIN tb_viagem v ON o.id_viagem = v.id
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
GROUP BY v.id;

CREATE VIEW vw_motorista_pontuacao_mensal(
    ranking_pontuacao,
    motorista,
    id_unidade,
    unidade,
    id_segmento,
    segmento,
    pontuacao_ultimo_mes,
    id_localidade,
    localidade_estado
) AS
SELECT
    DENSE_RANK() OVER (ORDER BY SUM(ti.pontuacao) DESC) AS rank_pontuacao,
    m.nome_completo   AS motorista,
    u.id              AS id_unidade,
    u.nome            AS unidade,
    s.id              AS id_segmento,
    s.nome            AS segmento,
    SUM(ti.pontuacao) AS pontuacao_ultimo_mes,
    u.id_localidade   AS id_localidade,
    l.estado          AS localidade_estado
FROM tb_infracao i
JOIN public.tb_motorista m      ON i.id_motorista = m.id
JOIN public.tb_tipo_infracao ti ON i.id_tipo_infracao = ti.id
JOIN public.tb_unidade u        ON m.id_unidade = u.id
JOIN public.tb_segmento s       ON u.id_segmento = s.id
JOIN public.tb_localidade l     ON u.id_localidade = l.id
WHERE
    EXTRACT(MONTH FROM i.dt_hr_evento) >= EXTRACT(MONTH FROM current_date) - 1
    AND EXTRACT(YEAR FROM i.dt_hr_evento) = EXTRACT(YEAR FROM current_date)
GROUP BY m.id, m.nome_completo, u.id, u.nome, s.id, s.nome, u.id_localidade, l.estado
ORDER BY rank_pontuacao;


CREATE VIEW vw_relatorio_semanal_infracoes(
    dia_semana,
    total_infracoes,
    id_unidade,
    id_segmento,
    id_localidade
) AS
SELECT
    CASE EXTRACT(ISODOW FROM dt_hr_evento)
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END AS dia_semana,
    COUNT(*) AS total_infracoes,
    u.id AS id_unidade,
    u.id_segmento,
    u.id_localidade
FROM tb_infracao i
         JOIN tb_motorista m ON i.id_motorista = m.id
         JOIN tb_unidade u ON m.id_unidade = u.id
WHERE dt_hr_evento >= CURRENT_DATE - INTERVAL '1 week'
GROUP BY EXTRACT(ISODOW FROM dt_hr_evento), u.id, u.id_segmento, u.id_localidade
ORDER BY EXTRACT(ISODOW FROM dt_hr_evento);


CREATE VIEW vw_total_ocorrencias (
    mes,
    ano,
    id_unidade,
    id_segmento,
    id_localidade,
    total_ocorrencias
) AS
SELECT
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano,
    m.id_unidade,
    u.id_segmento,
    u.id_localidade,
    COUNT(o.id) AS total_ocorrencias
FROM tb_infracao o
JOIN tb_motorista m ON o.id_motorista = m.id
JOIN tb_unidade u ON m.id_unidade = u.id
group by mes, ano, m.id_unidade, u.id_segmento, u.id_localidade
order by ano desc, mes desc;


CREATE VIEW vw_ocorrencias_por_gravidade (
    mes,
    ano,
    id_unidade,
    id_segmento,
    id_localidade,
    total_ocorrencias,
    gravidade
) AS
SELECT
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano,
    m.id_unidade,
    u.id_segmento,
    u.id_localidade,
    COUNT(o.id) AS total_ocorrencias,
    tg.nome AS gravidade
FROM tb_infracao o
JOIN tb_tipo_infracao t     ON o.id_tipo_infracao = t.id
JOIN tb_tipo_gravidade tg   ON t.id_tipo_gravidade = tg.id
JOIN tb_motorista m on o.id_motorista = m.id
JOIN tb_unidade u on m.id_unidade = u.id
GROUP BY tg.nome, mes, ano, m.id_unidade, u.id_segmento, u.id;


CREATE VIEW vw_motorista_quantidade_infracoes (
    mes,
    ano,
    id_unidade,
    id_segmento,
    id_localidade,
    motorista,
    quantidade_infracoes
) AS
SELECT
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano,
    m.id_unidade,
    u.id_segmento,
    u.id_localidade,
    m.nome_completo as motorista,
    count(i.id) as quantidade_infracoes
FROM tb_motorista m
JOIN tb_infracao i on m.id = i.id_motorista
JOIN tb_unidade u on m.id_unidade = u.id
group by m.nome_completo, mes, ano, m.id_unidade, u.id_segmento, u.id
order by quantidade_infracoes desc;


CREATE OR REPLACE VIEW vw_variacao_mes_passado_por_mes_ano AS
WITH totais_mes_atual AS (
    SELECT
        u.id AS id_unidade,
        u.id_segmento AS id_segmento,
        u.id_localidade AS id_localidade,
        EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) AS mes,
        EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) AS ano,
        COUNT(*) AS total_infracoes
    FROM tb_infracao i
             JOIN tb_motorista m ON i.id_motorista = m.id
             JOIN tb_unidade u ON m.id_unidade = u.id
    WHERE EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) = EXTRACT(MONTH FROM (CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo'))
      AND EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) = EXTRACT(YEAR FROM (CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo'))
    GROUP BY EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')),
             EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')),
             u.id_localidade, u.id, u.id_segmento
),
totais_mes_passado AS (
    SELECT
        u.id AS id_unidade,
        u.id_segmento AS id_segmento,
        u.id_localidade AS id_localidade,
        EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) AS mes,
        EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) AS ano,
        COUNT(*) AS total_infracoes
    FROM tb_infracao i
             JOIN tb_motorista m ON i.id_motorista = m.id
             JOIN tb_unidade u ON m.id_unidade = u.id
    WHERE EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) =
              EXTRACT(MONTH FROM (CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo') - INTERVAL '1 month')
      AND EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) =
              EXTRACT(YEAR FROM (CURRENT_TIMESTAMP AT TIME ZONE 'America/Sao_Paulo') - INTERVAL '1 month')
    GROUP BY EXTRACT(YEAR FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')),
             EXTRACT(MONTH FROM (i.dt_hr_evento AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')),
             u.id_localidade, u.id, u.id_segmento
)
SELECT DISTINCT
      t1.id_unidade,
      t1.id_segmento,
      t1.id_localidade,
      t1.mes,
      t1.ano,
      t1.total_infracoes AS infracoes_mes_atual,
      t2.total_infracoes AS infracoes_mes_passado,
      ((t1.total_infracoes - t2.total_infracoes)::numeric / NULLIF(t2.total_infracoes, 0)) * 100 AS variacao
FROM totais_mes_atual t1
JOIN totais_mes_passado t2
  ON t1.id_unidade = t2.id_unidade
 AND t1.id_segmento = t2.id_segmento
 AND t1.id_localidade = t2.id_localidade;


CREATE VIEW vw_ocorrencias_por_tipo (
    mes,
    ano,
    id_unidade,
    id_segmento,
    id_localidade,
    tipo_infracao,
    total_ocorrencias,
    porcentagem_do_total
) AS
SELECT
    extract(month from dt_hr_evento) mes,
    extract(year from dt_hr_evento) ano,
    u.id AS id_unidade,
    u.id_segmento,
    u.id_localidade,
    t.nome AS tipo_infracao,
    COUNT(o.id) AS total_ocorrencias,
    ROUND((COUNT(o.id)::decimal / SUM(COUNT(o.id)) OVER (PARTITION BY extract(month from dt_hr_evento), extract(year from dt_hr_evento))) * 100, 2) AS porcentagem_do_total
FROM tb_infracao o
JOIN tb_tipo_infracao t ON o.id_tipo_infracao = t.id
JOIN tb_motorista m ON o.id_motorista = m.id
JOIN tb_unidade u ON m.id_unidade = u.id
GROUP BY t.nome, mes, ano, u.id, u.id_segmento;


CREATE VIEW vw_qntd_infracoes_viagem_motorista(
    id_motorista,
    id_viagem,
    quantidade_infracao
) AS
SELECT
    i.id_motorista,
    i.id_viagem,
    COUNT(i.id) AS quantidade_infracoes
FROM tb_infracao i
GROUP BY
    i.id_motorista,
    i.id_viagem
ORDER BY
    i.id_viagem;

CREATE VIEW vw_quantidade_infracao_tipo_gravidade (
id_viagem,
id_motorista,
id_unidade,
id_localidade,
tipo_leve,
tipo_media,
tipo_grave,
tipo_gravissima
) AS
SELECT
    v.id AS id_viagem,
    m.id AS id_motorista,
    m.id_unidade AS id_unidade,
    u.id_localidade AS id_localidade,
    SUM(CASE WHEN tg.nome = 'Leve' THEN 1 ELSE 0 END) AS tipo_leve,
    SUM(CASE WHEN tg.nome = 'Média' THEN 1 ELSE 0 END) AS tipo_media,
    SUM(CASE WHEN tg.nome = 'Grave' THEN 1 ELSE 0 END) AS tipo_grave,
    SUM(CASE WHEN tg.nome = 'Gravíssima' THEN 1 ELSE 0 END) AS tipo_gravissima
FROM tb_infracao i
JOIN tb_viagem v ON i.id_viagem = v.id
JOIN tb_motorista m ON i.id_motorista = m.id
LEFT JOIN tb_tipo_infracao t ON i.id_tipo_infracao = t.id
LEFT JOIN tb_tipo_gravidade tg ON t.id_tipo_gravidade = tg.id
LEFT JOIN tb_unidade u ON m.id_unidade = u.id
GROUP BY v.id, m.id, u.id, m.id_unidade
ORDER BY v.id;


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
-- PROCS RPA
-- =============================

CREATE OR REPLACE PROCEDURE prc_atualiza_segmento()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_segmento
    SET nome = segmento_temp.nome, transaction_made = 'UPDATE', updated_at = CURRENT_DATE, is_inactive = FALSE
    FROM segmento_temp
    WHERE tb_segmento.id = segmento_temp.id;

    UPDATE tb_segmento
    SET transaction_made = 'DELETE', updated_at = CURRENT_DATE, is_inactive = TRUE
    WHERE NOT EXISTS( SELECT 1 FROM segmento_temp WHERE segmento_temp.id = tb_segmento.id );

    INSERT INTO tb_segmento (nome, transaction_made, updated_at, is_inactive)
    SELECT segmento_temp.nome, 'INSERT', CURRENT_DATE, FALSE
    FROM segmento_temp
    WHERE NOT EXISTS( SELECT 1 FROM tb_segmento WHERE segmento_temp.id = tb_segmento.id );
END;
$$;


CREATE OR REPLACE PROCEDURE prc_atualiza_endereco()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_localidade
    SET cep = endereco_temp.cep, numero = endereco_temp.numero, rua = endereco_temp.rua, cidade = endereco_temp.cidade, estado = endereco_temp.estado, bairro = endereco_temp.bairro, pais = endereco_temp.pais, transaction_made = 'UPDATE', updated_at = CURRENT_DATE, is_inactive = FALSE
    FROM endereco_temp
    WHERE tb_localidade.id = endereco_temp.id;

    UPDATE tb_localidade
    SET transaction_made = 'DELETE', updated_at = CURRENT_DATE, is_inactive = TRUE
    WHERE NOT EXISTS( SELECT 1 FROM endereco_temp WHERE endereco_temp.id = tb_localidade.id );

    INSERT INTO tb_localidade (cep, rua, numero, estado, cidade, bairro, pais, transaction_made, updated_at, is_inactive)
    SELECT endereco_temp.cep, endereco_temp.rua, endereco_temp.numero, endereco_temp.estado, endereco_temp.cidade, endereco_temp.bairro, endereco_temp.pais, 'INSERT', CURRENT_DATE, FALSE
    FROM endereco_temp
    WHERE NOT EXISTS( SELECT 1 FROM tb_localidade WHERE endereco_temp.id = tb_localidade.id );
END;
$$;


CREATE OR REPLACE PROCEDURE prc_atualiza_unidade()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_unidade
    SET nome = unidade_temp.nome, id_segmento = unidade_temp.id_segmento, id_localidade = unidade_temp.id_endereco, transaction_made = 'UPDATE', updated_at = CURRENT_DATE, is_inactive = FALSE
    FROM unidade_temp
    WHERE tb_unidade.id = unidade_temp.id;

    UPDATE tb_unidade
    SET transaction_made = 'DELETE', updated_at = CURRENT_DATE, is_inactive = TRUE
    WHERE NOT EXISTS( SELECT 1 FROM unidade_temp WHERE unidade_temp.id = tb_unidade.id );

    INSERT INTO tb_unidade (nome, id_segmento, id_localidade, transaction_made, updated_at, is_inactive)
    SELECT unidade_temp.nome, unidade_temp.id_segmento, unidade_temp.id_endereco, 'INSERT', CURRENT_DATE, FALSE
    FROM unidade_temp
    WHERE NOT EXISTS( SELECT 1 FROM tb_unidade WHERE unidade_temp.id = tb_unidade.id );
END;
$$;


CREATE OR REPLACE PROCEDURE prc_atualiza_tipo_ocorrencia()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_tipo_infracao
    SET
        pontuacao = tipo_ocorrencia_temp.pontuacao,
        nome = tipo_ocorrencia_temp.tipo_evento,
        id_tipo_gravidade = (select id from tb_tipo_gravidade where tipo_ocorrencia_temp.gravidade = tb_tipo_gravidade.nome),
        transaction_made = 'UPDATE',
        updated_at = CURRENT_DATE,
        is_inactive = FALSE
    FROM tipo_ocorrencia_temp
    WHERE tb_tipo_infracao.id = tipo_ocorrencia_temp.id;

    UPDATE tb_tipo_infracao
    SET transaction_made = 'DELETE', updated_at = CURRENT_DATE, is_inactive = TRUE
    WHERE NOT EXISTS( SELECT 1 FROM tipo_ocorrencia_temp WHERE tipo_ocorrencia_temp.id = tb_tipo_infracao.id );

    INSERT INTO tb_tipo_gravidade (nome, transaction_made, updated_at, is_inactive)
    SELECT DISTINCT tipo_ocorrencia_temp.gravidade, 'INSERT', CURRENT_DATE, FALSE
    FROM tipo_ocorrencia_temp
    WHERE tipo_ocorrencia_temp.gravidade IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM tb_tipo_gravidade WHERE tb_tipo_gravidade.nome = tipo_ocorrencia_temp.gravidade);

    INSERT INTO tb_tipo_infracao (nome, pontuacao, id_tipo_gravidade, transaction_made, updated_at, is_inactive)
    SELECT tipo_ocorrencia_temp.tipo_evento, tipo_ocorrencia_temp.pontuacao, tb_tipo_gravidade.id, 'INSERT', CURRENT_DATE, FALSE
    FROM tipo_ocorrencia_temp
    JOIN tb_tipo_gravidade on tipo_ocorrencia_temp.gravidade = tb_tipo_gravidade.nome

    WHERE NOT EXISTS( SELECT 1 FROM tb_tipo_infracao WHERE tipo_ocorrencia_temp.id = tb_tipo_infracao.id );
END;
$$;


CREATE OR REPLACE PROCEDURE prc_atualiza_analista()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_usuario
    SET
        cpf = a.cpf,
        id_unidade = a.id_unidade,
        dt_contratacao = a.dt_contratacao,
        nome_completo = a.nome_completo,
        telefone = a.telefone,
        email = a.email,
        hash_senha = a.senha,
        id_cargo = (SELECT c.id FROM tb_cargo c WHERE c.nome = a.cargo),
        transaction_made = 'UPDATE',
        updated_at = CURRENT_DATE,
        is_inactive = FALSE
    FROM analista_temp a
    WHERE tb_usuario.id = a.id
    AND tb_usuario.id_cargo <> 1;

    UPDATE tb_usuario
    SET transaction_made = 'DELETE',
        updated_at = CURRENT_DATE,
        is_inactive = TRUE
    WHERE tb_usuario.id_cargo <> 1
    AND NOT EXISTS (SELECT 1 FROM analista_temp a WHERE a.id = tb_usuario.id);

    INSERT INTO tb_cargo (nome, transaction_made, updated_at, is_inactive)
    SELECT DISTINCT a.cargo, 'INSERT', CURRENT_DATE, FALSE
    FROM analista_temp a
    WHERE NOT EXISTS (SELECT 1 FROM tb_cargo c WHERE c.nome = a.cargo);

    INSERT INTO tb_usuario (cpf, id_unidade, dt_contratacao, nome_completo, telefone, email, hash_senha, id_cargo, transaction_made, updated_at, is_inactive)
    SELECT a.cpf, a.id_unidade, a.dt_contratacao, a.nome_completo, a.telefone, a.email, a.senha, c.id, 'INSERT', CURRENT_DATE, FALSE
    FROM analista_temp a
    JOIN tb_cargo c ON a.cargo = c.nome
    LEFT JOIN tb_usuario u ON u.cpf = a.cpf
    WHERE u.cpf IS NULL;
END;
$$;


CREATE OR REPLACE PROCEDURE prc_atualiza_administrador()
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_usuario
    SET
        cpf = ad.cpf,
        nome_completo = ad.nome_completo,
        telefone = ad.telefone,
        email = ad.email,
        hash_senha = ad.senha,
        id_cargo = 1,
        transaction_made = 'UPDATE',
        updated_at = CURRENT_DATE,
        is_inactive = FALSE
    FROM administrador_temp ad
    WHERE tb_usuario.id = ad.id
    AND tb_usuario.id_cargo = 1;

    UPDATE tb_usuario
    SET transaction_made = 'DELETE',
        updated_at = CURRENT_DATE,
        is_inactive = TRUE
    WHERE tb_usuario.id_cargo = 1
    AND NOT EXISTS (SELECT 1 FROM administrador_temp ad WHERE ad.id = tb_usuario.id);

    INSERT INTO tb_usuario (cpf, nome_completo, telefone, email, hash_senha, id_cargo, transaction_made, updated_at, is_inactive)
    SELECT ad.cpf, ad.nome_completo, ad.telefone, ad.email, ad.senha, 1, 'INSERT', CURRENT_DATE, FALSE
    FROM administrador_temp ad
    LEFT JOIN tb_usuario u ON u.cpf = ad.cpf
    WHERE u.cpf IS NULL;
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



-- =============================
-- ÍNDICES
-- =============================


-- Otimizam consultas que buscam tipos, gravidades ou unidades.
-- Frequentemente usados em JOINs com tb_infracao e tb_viagem.
CREATE INDEX idx_tipo_infracao_gravidade ON tb_tipo_infracao (id_tipo_gravidade);

-- Acesso rápido a unidades por segmento (relatórios regionais, dashboards)
CREATE INDEX idx_unidade_segmento        ON tb_unidade (id_segmento);
-- Acesso rápido a unidades por localização (consultas geográficas ou filtros)
CREATE INDEX idx_unidade_localidade      ON tb_unidade (id_localidade);

-- Consultas de usuários por unidade e cargo (ex: “usuários de uma unidade”)
CREATE INDEX idx_usuario_unidade         ON tb_usuario (id_unidade);
CREATE INDEX idx_usuario_cargo           ON tb_usuario (id_cargo);

-- Busca por e-mail e telefone em autenticação e gestão de contas
CREATE INDEX idx_usuario_email           ON tb_usuario (email);
CREATE INDEX idx_usuario_telefone        ON tb_usuario (telefone);

-- JOINs entre caminhão, unidade e segmento — comuns em relatórios de frota
CREATE INDEX idx_caminhao_segmento       ON tb_caminhao (id_segmento);
CREATE INDEX idx_caminhao_unidade        ON tb_caminhao (id_unidade);

-- Busca direta de caminhões por placa ou número de frota (consultas administrativas)
CREATE INDEX idx_caminhao_placa          ON tb_caminhao (placa);
CREATE INDEX idx_caminhao_num_frota      ON tb_caminhao (numero_frota);

-- JOINs com unidade e tipo de risco em relatórios de desempenho
CREATE INDEX idx_motorista_unidade       ON tb_motorista (id_unidade);
CREATE INDEX idx_motorista_tipo_risco    ON tb_motorista (id_tipo_risco);

-- Busca rápida de motorista por CPF (consultas e validações)
CREATE INDEX idx_motorista_cpf           ON tb_motorista (cpf);

-- Melhoram os JOINs mais comuns: viagem ↔ caminhão / usuário / localidade
CREATE INDEX idx_viagem_caminhao         ON tb_viagem (id_caminhao);
CREATE INDEX idx_viagem_usuario          ON tb_viagem (id_usuario);
CREATE INDEX idx_viagem_origem           ON tb_viagem (id_origem);
CREATE INDEX idx_viagem_destino          ON tb_viagem (id_destino);

-- Filtros frequentes por datas de início/fim (relatórios, análises mensais)
CREATE INDEX idx_viagem_dt_inicio        ON tb_viagem (dt_hr_inicio);
CREATE INDEX idx_viagem_dt_fim           ON tb_viagem (dt_hr_fim);

-- Flag de viagens já analisadas — usada em painéis e dashboards
CREATE INDEX idx_viagem_was_analyzed     ON tb_viagem (was_analyzed);

-- JOINs e relatórios de registros por viagem e motorista
CREATE INDEX idx_registro_viagem         ON tb_registro (id_viagem);
CREATE INDEX idx_registro_motorista      ON tb_registro (id_motorista);

-- Filtros por data de registro (histórico de tratativas)
CREATE INDEX idx_registro_dt             ON tb_registro (dt_hr_registro);

-- JOINs com viagem, motorista e tipo de infração (consultas analíticas e dashboards)
CREATE INDEX idx_infracao_viagem         ON tb_infracao (id_viagem);
CREATE INDEX idx_infracao_motorista      ON tb_infracao (id_motorista);
CREATE INDEX idx_infracao_tipo           ON tb_infracao (id_tipo_infracao);

-- Consultas por data e localização (mapas de calor, gráficos temporais)
CREATE INDEX idx_infracao_dt_evento      ON tb_infracao (dt_hr_evento);
CREATE INDEX idx_infracao_coords         ON tb_infracao (latitude, longitude);

-- JOINs frequentes nas views de relatórios de mídia
CREATE INDEX idx_midia_infracao_viagem    ON tb_midia_infracao (id_viagem);
CREATE INDEX idx_midia_infracao_motorista ON tb_midia_infracao (id_motorista);
CREATE INDEX idx_midia_infracao_infracao  ON tb_midia_infracao (id_infracao);

-- Consulta rápida das mídias concatenadas por viagem e motorista
CREATE INDEX idx_midia_concat_viagem      ON tb_midia_concatenada (id_viagem);
CREATE INDEX idx_midia_concat_motorista   ON tb_midia_concatenada (id_motorista);

-- JOINs e contagens de logins por usuário (relatórios de acesso)
CREATE INDEX idx_login_usuario           ON lg_login_usuario (id_usuario);
-- Relatórios temporais (logins por data/hora)
CREATE INDEX idx_login_data              ON lg_login_usuario (dt_hr_login);

-- Métricas de Daily Active Users
CREATE INDEX idx_dau_data                ON tb_daily_active_users (data);

-- Otimizam relatórios que filtram por registros ativos/inativos ou atualizações recentes
CREATE INDEX idx_updated_at_inactive     ON tb_usuario (updated_at, is_inactive);
CREATE INDEX idx_updated_at_inactive_m   ON tb_motorista (updated_at, is_inactive);
CREATE INDEX idx_updated_at_inactive_v   ON tb_viagem (updated_at, is_inactive);
CREATE INDEX idx_updated_at_inactive_inf ON tb_infracao (updated_at, is_inactive);
CREATE INDEX idx_updated_at_inactive_mid ON tb_midia_infracao (updated_at, is_inactive);
CREATE INDEX idx_updated_at_inactive_mc  ON tb_midia_concatenada (updated_at, is_inactive);


COMMIT;
