CREATE TABLE perfil_acesso (
    id serial PRIMARY KEY,
    nome_perfil varchar(50) NOT NULL UNIQUE,
    funcao text
);
CREATE TABLE permissao (
    id serial PRIMARY KEY,
    nome_permissao varchar(50) NOT NULL UNIQUE,
    descricao text
);
CREATE TABLE perfil_permissao (
    id_perfil int REFERENCES perfil_acesso(id) NOT NULL,
    id_permissao int REFERENCES permissao(id) NOT NULL,
    PRIMARY KEY(id_perfil, id_permissao)
);
CREATE TABLE administrador (
    cpf serial PRIMARY KEY ,
    id_perfil int REFERENCES perfil_acesso(id) NOT NULL,
    nome_completo varchar(150) NOT NULL ,
    email varchar(150) UNIQUE NOT NULL ,
    senha varchar(100) NOT NULL ,
    ativo boolean DEFAULT TRUE
);
CREATE TABLE segmento (
    id serial PRIMARY KEY,
    nome varchar(40) NOT NULL,
    ativo boolean DEFAULT TRUE
);
CREATE TABLE unidade (
    id serial PRIMARY KEY,
    id_segmento int REFERENCES segmento(id),
    nome varchar(100) NOT NULL ,
    cidade varchar(50) NOT NULL,
    uf_estado varchar(2)
        CONSTRAINT uf_valido
            CHECK(LENGTH(uf_estado) = 2)
);
CREATE TABLE caminhao (
    chassi varchar(20) PRIMARY KEY,
    segmento int REFERENCES segmento(id),
    unidade int REFERENCES unidade(id),
    placa varchar(10) NOT NULL UNIQUE,
    modelo varchar(80) DEFAULT 'Não informado',
    ano_fabricacao int
        CONSTRAINT ano_valido
            CHECK(ano_fabricacao >= 1900 AND ano_fabricacao <= EXTRACT(YEAR FROM CURRENT_DATE)),
    numero_frota int NOT NULL,
    ativo boolean DEFAULT TRUE
);
CREATE TABLE analista (
    cpf varchar(15) PRIMARY KEY
        CONSTRAINT digitos_cpf
            CHECK(LENGTH(REPLACE(REPLACE(cpf, '-', ''), '.', '')) = 11),
    id_unidade int REFERENCES unidade(id),
    id_perfil_acesso int REFERENCES perfil_acesso(id),
    matricula varchar(30) NOT NULL UNIQUE,
    dt_contratacao date
        CONSTRAINT contratacao_valida
            CHECK(dt_contratacao <= CURRENT_DATE),
    nome_completo varchar(150) NOT NULL,
    email_institucional varchar(150) UNIQUE NOT NULL,
    senha varchar(100) NOT NULL,
    ativo boolean DEFAULT TRUE
);
CREATE TABLE motorista (
    cpf varchar(15) PRIMARY KEY
        CONSTRAINT digitos_cpf
            CHECK(LENGTH(REPLACE(REPLACE(cpf, '-', ''), '.', '')) = 11),
    id_unidade int REFERENCES unidade(id),
    cnh varchar(15) NOT NULL UNIQUE,
    nome_completo varchar(150) NOT NULL,
    telefone varchar(15) NOT NULL,
    email_empresa varchar(150),
    ativo boolean DEFAULT TRUE,
    qtde_viagens int DEFAULT 0
);
CREATE TABLE viagem (
    id serial PRIMARY KEY,
    chassi_caminhao varchar(20) REFERENCES caminhao(chassi) NOT NULL,
    cpf_motorista varchar(15) REFERENCES motorista(cpf) NOT NULL,
    dt_hr_inicio timestamp
        CONSTRAINT dt_inicio_valida
            CHECK(dt_hr_inicio <= CURRENT_TIMESTAMP),
    dt_hr_fim timestamp
        CONSTRAINT dt_fim_valida
            CHECK(dt_hr_fim <= CURRENT_TIMESTAMP),
    origem varchar(80) NOT NULL,
    destino varchar(80) NOT NULL
);
CREATE TABLE ocorrencia (
    id serial PRIMARY KEY,
    id_viagem int REFERENCES viagem(id),
    chassi_caminhao varchar(20) REFERENCES caminhao(chassi) NOT NULL ,
    cpf_motorista varchar(15) REFERENCES motorista(cpf) NOT NULL,
    cpf_analista varchar(15) REFERENCES analista(cpf),
    dt_hr_evento timestamp DEFAULT CURRENT_TIMESTAMP
        CONSTRAINT evento_valido
            CHECK(dt_hr_evento <= CURRENT_TIMESTAMP),
    tipo_evento varchar(50),
    latitude decimal(9, 7),
    longitude decimal(9, 7),
    velocidade_kmh decimal(5, 2)
);
CREATE TABLE registro (
    id serial PRIMARY KEY,
    id_ocorrencia int REFERENCES ocorrencia(id) NOT NULL,
    cpf_analista varchar(15) REFERENCES analista(cpf),
    arquivo varchar(250) NOT NULL,
    duracao_clipe decimal(6, 2),
    dt_hr_registro timestamp DEFAULT CURRENT_TIMESTAMP,
    tratativa text
);
