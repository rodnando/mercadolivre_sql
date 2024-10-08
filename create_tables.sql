-- Código escrito levando em consideração particularidades do MS SQL Server

-- Cria tabela Customer
-- ID é definida como chave primária para ser referenciada em outras tabelas
-- CHECK é usado para validar a entrada para Sexo, permitindo M e F
-- UNIQUE é usado para garantir a não duplicidade de emails
CREATE TABLE Customer (
    ID INT PRIMARY KEY,
    Nome VARCHAR(255),
    Sobrenome VARCHAR(255),
    Email VARCHAR(255),
    Sexo VARCHAR(10) CONSTRAINT CHK_Sexo CHECK (Sexo IN ('M', 'F')),
    Nascimento DATE,
    Telefone INT,
    Endereço VARCHAR(255),
    CONSTRAINT UQ_Customer_Email UNIQUE (Email)
);

-- Cria tabela Category
-- ID é definida como chave primária para ser referenciada em outras tabelas
CREATE TABLE Category (
    ID INT PRIMARY KEY,
    Categoria VARCHAR(255),
    Caminho VARCHAR(255)
);

-- Cria tabela Item
-- ID é definida como chave primária para ser referenciada em outras tabelas
-- NULL é usado para permitir entrada de nulos nas colunas DataRemocao e Status
-- REFERENCES é utilizado para definir as relações entre as tabelas
CREATE TABLE Item (
    ID INT PRIMARY KEY,
    CustomerID INT,
    CategoryID INT,
    Produto VARCHAR(255),
    Preco FLOAT,
    DataEntrada DATE,
    DataAtualizacao DATE,
    DataRemocao DATE NULL,
    Condicao VARCHAR(255),
    Status INT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
    FOREIGN KEY (CategoryID) REFERENCES Category(ID)
);

-- Cria tabela Order 
-- Order é uma palavra reservada, por isso a utilizacão de []
-- ID é definida como chave primária para ser referenciada em outras tabelas
-- REFERENCES é utilizado para definir as relações entre as tabelas
-- Uma CONSTRAINT é definida para garantir que a valor da coluna Quantidade seja maior que 0
CREATE TABLE [Order] (
    ID INT PRIMARY KEY,
    CustomerID INT,
    ItemID INT,
    DataOrdem DATE,
    Quantidade INT,
    Valor FLOAT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
    FOREIGN KEY (ItemID) REFERENCES Item(ID),
    CONSTRAINT CHK_Order_Quantidade CHECK (Quantidade > 0)
);

-- Cria tabela que será responsável por receber os dados históricos da tabela Item
CREATE TABLE DailyItemStatus (
    ItemID INT NOT NULL,
    CustomerID INT,
    CategoryID INT,
    NomeItem VARCHAR(255),
    Preco FLOAT,
    Condicao VARCHAR(255),
    Status VARCHAR(255),
    DataAtualizacao DATE
);
