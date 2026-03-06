-- Tabela de faculdades
CREATE TABLE feumn_faculdades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    sigla VARCHAR(10) NOT NULL,
    endereco TEXT,
    telefone VARCHAR(20),
    email VARCHAR(100),
    logo_url VARCHAR(255),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codigo (codigo),
    INDEX idx_ativo (ativo)
);

-- Tabela de bibliotecas (uma faculdade pode ter múltiplas)
CREATE TABLE feumn_bibliotecas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    faculdade_id INT NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM('central', 'setorial', 'digital') DEFAULT 'setorial',
    localizacao VARCHAR(255),
    horario_funcionamento TEXT,
    responsavel VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100),
    capacidade INT,
    ativo BOOLEAN DEFAULT TRUE,
    config JSON, -- Configurações específicas (RFID, etc)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (faculdade_id) REFERENCES feumn_faculdades(id) ON DELETE CASCADE,
    INDEX idx_codigo (codigo),
    INDEX idx_tipo (tipo)
);

-- Tabela de categorias de usuários (dinâmica por faculdade)
CREATE TABLE feumn_categorias_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    faculdade_id INT NOT NULL,
    biblioteca_id INT,
    codigo VARCHAR(20) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo ENUM('estudante', 'docente', 'funcionario', 'externo') NOT NULL,
    
    -- Regras de empréstimo
    max_emprestimos INT DEFAULT 3,
    dias_emprestimo INT DEFAULT 14,
    renovacoes_permitidas INT DEFAULT 1,
    
    -- Taxas
    taxa_valor DECIMAL(10,2) DEFAULT 0,
    taxa_periodo ENUM('mensal', 'semestral', 'anual') DEFAULT 'anual',
    taxa_isencao BOOLEAN DEFAULT FALSE,
    
    -- Período de validade
    validade_dias INT, -- NULL = indefinido
    renovacao_automatica BOOLEAN DEFAULT FALSE,
    
    -- Restrições
    bloqueia_apos_pendencia BOOLEAN DEFAULT TRUE,
    dias_tolerancia INT DEFAULT 7,
    
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_categoria_faculdade (faculdade_id, codigo),
    FOREIGN KEY (faculdade_id) REFERENCES feumn_faculdades(id),
    FOREIGN KEY (biblioteca_id) REFERENCES feumn_bibliotecas(id) ON DELETE SET NULL,
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo)
);

-- Tabela de configurações de taxa por período
CREATE TABLE feumn_taxas_historicas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    motivo TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES feumn_categorias_usuarios(id),
    INDEX idx_periodo (data_inicio, data_fim)
);

-- Tabela de usuários estendida
ALTER TABLE borrowers ADD COLUMN (
    faculdade_id INT,
    biblioteca_principal_id INT,
    numero_estudante VARCHAR(50),
    ano_ingresso INT,
    curso VARCHAR(100),
    periodo VARCHAR(20),
    data_formatura DATE,
    nif VARCHAR(20),
    tipo_documento ENUM('bi', 'passaporte', 'diploma') DEFAULT 'bi',
    numero_documento VARCHAR(50),
    validade_documento DATE,
    emergencia_nome VARCHAR(100),
    emergencia_telefone VARCHAR(20),
    emergencia_parentesco VARCHAR(50),
    preferencias JSON, -- preferências de contato, notificações, etc
    termos_aceitos BOOLEAN DEFAULT FALSE,
    termos_aceitos_em TIMESTAMP NULL,
    ultimo_acesso TIMESTAMP NULL,
    ultimo_ip VARCHAR(45),
    FOREIGN KEY (faculdade_id) REFERENCES feumn_faculdades(id),
    FOREIGN KEY (biblioteca_principal_id) REFERENCES feumn_bibliotecas(id),
    INDEX idx_numero_estudante (numero_estudante),
    INDEX idx_curso (curso),
    INDEX idx_ultimo_acesso (ultimo_acesso)
);

-- Log de acesso por faculdade
CREATE TABLE feumn_acessos_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    borrowernumber INT NOT NULL,
    faculdade_id INT NOT NULL,
    biblioteca_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    acao VARCHAR(50),
    recurso VARCHAR(255),
    status ENUM('sucesso', 'bloqueado', 'erro') DEFAULT 'sucesso',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (borrowernumber) REFERENCES borrowers(borrowernumber),
    FOREIGN KEY (faculdade_id) REFERENCES feumn_faculdades(id),
    FOREIGN KEY (biblioteca_id) REFERENCES feumn_bibliotecas(id),
    INDEX idx_faculdade_data (faculdade_id, created_at),
    INDEX idx_borrower (borrowernumber)
);

-- Dados iniciais
INSERT INTO feumn_faculdades (codigo, nome, sigla) VALUES
('FEUMN', 'Faculdade de Economia da Universidade Mandume Ya Ndemufayo', 'FEUMN'),
('FDU', 'Faculdade de Direito', 'FDU'),
('FCS', 'Faculdade de Ciências Sociais', 'FCS'),
('FCT', 'Faculdade de Ciências e Tecnologias', 'FCT'),
('FMC', 'Faculdade de Medicina', 'FMC');

INSERT INTO feumn_bibliotecas (faculdade_id, codigo, nome, tipo, localizacao) VALUES
(1, 'BEC', 'Biblioteca de Economia', 'central', 'Campus Principal - Bloco A'),
(1, 'BEC-DIG', 'Biblioteca Digital FEUMN', 'digital', 'Online'),
(2, 'BJD', 'Biblioteca Jurídica', 'setorial', 'Campus Direito - Bloco B'),
(3, 'BCS', 'Biblioteca de Ciências Sociais', 'setorial', 'Campus Social - Bloco C'),
(4, 'BCT', 'Biblioteca de Ciências e Tecnologias', 'central', 'Campus Tecnológico'),
(5, 'BMC', 'Biblioteca de Medicina', 'central', 'Hospital Universitário');

-- Inserir categorias
INSERT INTO feumn_categorias_usuarios 
    (faculdade_id, codigo, nome, tipo, max_emprestimos, dias_emprestimo, taxa_valor, taxa_periodo) 
VALUES
(1, 'EST_FEUMN', 'Estudante FEUMN', 'estudante', 3, 14, 5000, 'anual'),
(1, 'DOC_FEUMN', 'Docente FEUMN', 'docente', 10, 30, 0, 'anual'),
(1, 'FUNC_FEUMN', 'Funcionário FEUMN', 'funcionario', 5, 21, 2500, 'anual'),
(2, 'EST_FDU', 'Estudante Direito', 'estudante', 3, 14, 5000, 'anual'),
(2, 'DOC_FDU', 'Docente Direito', 'docente', 10, 30, 0, 'anual'),
(3, 'EST_FCS', 'Estudante Ciências Sociais', 'estudante', 3, 14, 5000, 'anual'),
(4, 'EST_FCT', 'Estudante Ciências/Tecnologia', 'estudante', 4, 21, 7500, 'anual');