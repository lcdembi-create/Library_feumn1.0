CREATE TABLE feumn_registro_tratamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    operacao VARCHAR(50) NOT NULL,
    dados TEXT NOT NULL,
    finalidade VARCHAR(255),
    base_legal VARCHAR(100),
    usuario VARCHAR(100),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_operacao (operacao),
    INDEX idx_data (created_at)
);

-- Trigger para registrar acessos a dados sensíveis
DELIMITER $$
CREATE TRIGGER log_dados_sensiveis
AFTER SELECT ON borrowers
FOR EACH ROW
BEGIN
    IF NEW.categorycode IN ('DOC', 'FUNC') THEN
        INSERT INTO feumn_registro_tratamento 
        (operacao, dados, usuario, ip_address)
        VALUES 
        ('ACESSO_DOCENTE', 
         CONCAT('Acesso ao perfil: ', NEW.borrowernumber),
         USER(),
         SUBSTRING_INDEX(USER(), '@', -1));
    END IF;
END$$
DELIMITER ;