-- 1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 
WITH VendasJan2020 AS (
    SELECT 
        I.CustomerID AS VendedorID, 
        COUNT(O.ID) AS TotalVendasJan2020
    FROM 
        Item I
    JOIN 
        [Order] O ON I.ID = O.ItemID
    WHERE 
        -- Verifica se as vendas ocorreram em janeiro de 2020
        MONTH(O.DataOrdem) = 1 
        AND YEAR(O.DataOrdem) = 2020
    GROUP BY 
        I.CustomerID
    HAVING 
        -- Condição para verificar se o número de vendas foi maior que 1500
        COUNT(O.ID) > 1500
)

SELECT 
    C.ID,
    C.Nome,
    C.Sobrenome,
    C.Email,
    C.Nascimento,
    S.TotalVendasJan2020
FROM 
    SalesJan2020 S
JOIN 
    Customer C ON S.VendedorID = C.ID
WHERE 
    -- Condição para verificar se o aniversário é hoje
    MONTH(C.Nascimento) = MONTH(GETDATE()) 
    AND DAY(C.Nascimento) = DAY(GETDATE());

-- 2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
--- Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, 
--- cantidad de productos vendidos y el monto total transaccionado. 
WITH MonthlySales AS (
    SELECT 
        C.ID AS VendedorID,
        C.Nome,
        C.Sobrenome,
        MONTH(O.DataOrdem) AS Mes,
        YEAR(O.DataOrdem) AS Ano,
        COUNT(O.ID) AS NumeroVendas,
        SUM(O.Quantidade) AS NumeroProdutosVendidos,
        SUM(O.Quantidade * O.Valor) AS ValorTotalTransacionado
    FROM 
        Customer C
    JOIN 
        Item I ON C.ID = I.CustomerID
    JOIN 
        Category Cat ON I.CategoryID = Cat.ID
    JOIN 
        [Order] O ON I.ID = O.ItemID
    WHERE 
        Cat.Categoria = 'Celular'  -- Filtro para a categoria Celular
        AND YEAR(O.DataOrdem) = 2020  -- Filtro para o ano de 2020
    GROUP BY 
        C.ID, C.Nome, C.Sobrenome, MONTH(O.DataOrdem), YEAR(O.DataOrdem)
),
Top5Vendedores AS (
    SELECT 
        VendedorID,
        Nome,
        Sobrenome,
        Mes,
        Ano,
        NumeroVendas,
        NumeroProdutosVendidos,
        ValorTotalTransacionado,
        ROW_NUMBER() OVER (PARTITION BY Mes, Ano ORDER BY ValorTotalTransacionado DESC) AS Ranking
    FROM 
        MonthlySales
)

SELECT 
    Mes,
    Ano,
    Nome,
    Sobrenome,
    NumeroVendas,
    NumeroProdutosVendidos,
    ValorTotalTransacionado
FROM 
    Top5Vendedores
WHERE 
    Ranking <= 5
ORDER BY 
    Ano, Mes, Ranking;

-- Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. 
--- Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. 
CREATE PROCEDURE UpdateDailyItemStatus
AS
BEGIN
    -- Insere os registros com o último status informado
    INSERT INTO DailyItemStatus (ItemID, CustomerID, CategoryID, NomeItem, Preco, Status, DataAtualizacao)
    SELECT 
        ID AS ItemID,
        CustomerID,
        CategoryID,
        NomeItem,
        Preco,
        Status,
        DataAtualizacao
    FROM 
        Item
    WHERE -- Insere apenas itens atualizados hoje
        YEAR(DataAtualizacao) = YEAR(GETDATE())
        AND MONTH(DataAtualizacao) = MONTH(GETDATE())
        AND DAY(DataAtualizacao) = DAY(GETDATE())
    -- Confirma a transação para garantir que os dados são persistidos
    COMMIT;
END;
