-- =====================================================================
-- BANCO DE DADOS ZERADO: folks (Folks RH)
-- Apenas estrutura das tabelas + setores e funções base para cadastro
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `folks`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `folks`;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';

-- ---------------------------------------------------------------------
-- Tabela: setor
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `setor`;
CREATE TABLE `setor` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: endereco
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `endereco`;
CREATE TABLE `endereco` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `CEP` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Logradouro` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Numero` int DEFAULT NULL,
  `Bairro` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Cidade` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Estado` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: codigo_autenticacao
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `codigo_autenticacao`;
CREATE TABLE `codigo_autenticacao` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descricao` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Criado_Por_Id` int DEFAULT NULL,
  `Limite_Usos` int NOT NULL DEFAULT '1',
  `Usos_Atuais` int NOT NULL DEFAULT '0',
  `Ativo` tinyint(1) NOT NULL DEFAULT '1',
  `Data_Expiracao` datetime DEFAULT NULL,
  `Data_Criacao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Codigo` (`Codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: usuarios
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Nome` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Tipo` enum('admin','gestor','analista','assistente','auxiliar') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Funcao_Nome` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Setor_Id` int DEFAULT NULL,
  `E_mail` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Telefone` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Senha` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Codigo_Autenticacao_Id` int DEFAULT NULL,
  `Codigo_Utilizado` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_usuarios_setor` (`Setor_Id`),
  KEY `fk_usuarios_codigo_autenticacao` (`Codigo_Autenticacao_Id`),
  CONSTRAINT `fk_usuarios_codigo_autenticacao` FOREIGN KEY (`Codigo_Autenticacao_Id`) REFERENCES `codigo_autenticacao` (`Id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_usuarios_setor` FOREIGN KEY (`Setor_Id`) REFERENCES `setor` (`Id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: permissoes_usuario
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `permissoes_usuario`;
CREATE TABLE `permissoes_usuario` (
  `Usuario_Id` int NOT NULL,
  `Clientes` tinyint(1) NOT NULL DEFAULT '1',
  `Tarefas` tinyint(1) NOT NULL DEFAULT '1',
  `Notificacoes` tinyint(1) NOT NULL DEFAULT '1',
  `Funcionarios` tinyint(1) NOT NULL DEFAULT '0',
  `Criar_Tarefas` tinyint(1) NOT NULL DEFAULT '0',
  `Editar_Tarefas` tinyint(1) NOT NULL DEFAULT '1',
  `Excluir_Tarefas` tinyint(1) NOT NULL DEFAULT '1',
  `Alterar_Status` tinyint(1) NOT NULL DEFAULT '1',
  `Ver_Desempenho` tinyint(1) NOT NULL DEFAULT '0',
  `Gerenciar_Permissoes` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Usuario_Id`),
  CONSTRAINT `fk_permissoes_usuario` FOREIGN KEY (`Usuario_Id`) REFERENCES `usuarios` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: funcoes (Cargos)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `funcoes`;
CREATE TABLE `funcoes` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Nome` varchar(120) NOT NULL,
  `Tipo` varchar(30) NOT NULL DEFAULT 'assistente',
  `Departamento` varchar(120) NOT NULL DEFAULT 'Folks RH - Recrutamento & Seleção',
  `Criar_Tarefas` tinyint(1) NOT NULL DEFAULT '0',
  `Editar_Tarefas` tinyint(1) NOT NULL DEFAULT '1',
  `Excluir_Tarefas` tinyint(1) NOT NULL DEFAULT '1',
  `Alterar_Status` tinyint(1) NOT NULL DEFAULT '1',
  `Ver_Desempenho` tinyint(1) NOT NULL DEFAULT '0',
  `Gerenciar_Permissoes` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: clientes
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `clientes`;
CREATE TABLE `clientes` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Nome` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CPF_CNPJ` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `E_mail` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Endereco_Id` int DEFAULT NULL,
  `Telefone` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Data_Criacao` date DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_clientes_endereco` (`Endereco_Id`),
  CONSTRAINT `fk_clientes_endereco` FOREIGN KEY (`Endereco_Id`) REFERENCES `endereco` (`Id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: tarefas
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `tarefas`;
CREATE TABLE `tarefas` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Titulo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Clientes_Id` int DEFAULT NULL,
  `Usuarios_Id` int DEFAULT NULL,
  `Descricao` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` enum('pendente','em_andamento','concluida','cancelada') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendente',
  `Prioridade` enum('baixa','media','alta') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'media',
  `Data_Vencimento` date DEFAULT NULL,
  `Data_Conclusao` date DEFAULT NULL,
  `Data_Criacao` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Gestor_Nome` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Visualizado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Id`),
  KEY `fk_tarefas_cliente` (`Clientes_Id`),
  KEY `fk_tarefas_usuario` (`Usuarios_Id`),
  CONSTRAINT `fk_tarefas_cliente` FOREIGN KEY (`Clientes_Id`) REFERENCES `clientes` (`Id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tarefas_usuario` FOREIGN KEY (`Usuarios_Id`) REFERENCES `usuarios` (`Id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: log_tarefa
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `log_tarefa`;
CREATE TABLE `log_tarefa` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Tarefas_Id` int NOT NULL,
  `Acao` enum('criada','atualizada','concluida','cancelada','reativada') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descricao` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Data_Criacao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `fk_log_tarefa_tarefa` (`Tarefas_Id`),
  CONSTRAINT `fk_log_tarefa_tarefa` FOREIGN KEY (`Tarefas_Id`) REFERENCES `tarefas` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: desempenho
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `desempenho`;
CREATE TABLE `desempenho` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Usuarios_Id` int NOT NULL,
  `Tarefas_Concluidas` int DEFAULT '0',
  `Tempo_Medio` float DEFAULT '0',
  `Nota_Geral` int DEFAULT NULL,
  `Comentario` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Data_Avaliacao` date DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_desempenho_usuario` (`Usuarios_Id`),
  CONSTRAINT `fk_desempenho_usuario` FOREIGN KEY (`Usuarios_Id`) REFERENCES `usuarios` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabela: notificacoes
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `notificacoes`;
CREATE TABLE `notificacoes` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Usuario_Id` int DEFAULT NULL,
  `Titulo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Mensagem` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `Lida` tinyint(1) NOT NULL DEFAULT '0',
  `Data_Envio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Tipo` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'geral',
  PRIMARY KEY (`Id`),
  KEY `fk_notificacoes_usuario` (`Usuario_Id`),
  CONSTRAINT `fk_notificacoes_usuario` FOREIGN KEY (`Usuario_Id`) REFERENCES `usuarios` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- DADOS BASE MÍNIMOS (Setores e Funções para o formulário de cadastro)
-- =====================================================================

INSERT INTO `setor` (`Id`, `Descricao`) VALUES
(1, 'Recursos Humanos'),
(2, 'Tecnologia da Informação'),
(3, 'Financeiro'),
(4, 'Comercial');

INSERT INTO `funcoes` (`Id`, `Nome`, `Tipo`, `Departamento`, `Criar_Tarefas`, `Editar_Tarefas`, `Excluir_Tarefas`, `Alterar_Status`, `Ver_Desempenho`, `Gerenciar_Permissoes`) VALUES
(1, 'Gestor de RH', 'gestor', 'Recursos Humanos', 1, 1, 1, 1, 1, 1),
(2, 'Analista de RH', 'analista', 'Recursos Humanos', 1, 1, 0, 1, 1, 0),
(3, 'Assistente de RH', 'assistente', 'Recursos Humanos', 0, 1, 0, 1, 0, 0);

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE=@OLD_SQL_MODE;
