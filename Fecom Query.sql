-- Remover registros duplicados baseado no ID do cliente
DELETE FROM customers
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM customers
    GROUP BY Customer_Trx_ID
);

-- Tratar valores ausentes
UPDATE customers
SET Age = COALESCE(Age, 30),  -- Preenchendo idade com a mediana (exemplo)
    Gender = COALESCE(Gender, 'Unknown');

-- Padronizar nomes das cidades
UPDATE customers
SET Customer_City = INITCAP(Customer_City);

-- Remover pedidos duplicados
DELETE FROM orders
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM orders
    GROUP BY Order_ID
);

-- Preencher valores ausentes em datas (usando a data da compra como fallback)
UPDATE orders
SET Order_Approved_At = COALESCE(Order_Approved_At, Order_Purchase_Timestamp),
    Order_Delivered_Carrier_Date = COALESCE(Order_Delivered_Carrier_Date, Order_Estimated_Delivery_Date),
    Order_Delivered_Customer_Date = COALESCE(Order_Delivered_Customer_Date, Order_Estimated_Delivery_Date);

-- Padronizar status do pedido para lowercase
UPDATE orders
SET Order_Status = LOWER(Order_Status);

-- Remover itens duplicados no mesmo pedido
DELETE FROM order_items
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM order_items
    GROUP BY Order_ID, Product_ID
);

-- Corrigir preços negativos ou nulos
UPDATE order_items
SET Price = ABS(Price),
    Freight_Value = COALESCE(Freight_Value, 0);

-- Remover registros duplicados de pagamentos para um mesmo pedido
DELETE FROM order_payments
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM order_payments
    GROUP BY Order_ID, Payment_Type
);

-- Corrigir valores negativos
UPDATE order_payments
SET Payment_Value = ABS(Payment_Value);

-- Padronizar nomes dos métodos de pagamento
UPDATE order_payments
SET Payment_Type = LOWER(Payment_Type);

-- Remover produtos duplicados
DELETE FROM products
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM products
    GROUP BY Product_ID
);

-- Preencher valores nulos
UPDATE products
SET Product_Category_Name = COALESCE(Product_Category_Name, 'Unknown');

-- Tratar valores de dimensões do produto
UPDATE products
SET Product_Weight_Gr = COALESCE(Product_Weight_Gr, (SELECT AVG(Product_Weight_Gr) FROM products)),
    Product_Length_Cm = COALESCE(Product_Length_Cm, (SELECT AVG(Product_Length_Cm) FROM products)),
    Product_Height_Cm = COALESCE(Product_Height_Cm, (SELECT AVG(Product_Height_Cm) FROM products)),
    Product_Width_Cm = COALESCE(Product_Width_Cm, (SELECT AVG(Product_Width_Cm) FROM products));

-- Remover duplicatas de geolocalização
DELETE FROM geolocations
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM geolocations
    GROUP BY Geo_Postal_Code, Geo_Lat, Geo_Lon
);

-- Preencher valores ausentes com coordenadas padrão
UPDATE geolocations
SET Geo_Lat = COALESCE(Geo_Lat, 0),
    Geo_Lon = COALESCE(Geo_Lon, 0);

-- Remover vendedores duplicados
DELETE FROM sellers
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM sellers
    GROUP BY Seller_ID
);

-- Padronizar nomes das cidades
UPDATE sellers
SET Seller_City = INITCAP(Seller_City);

-- Remover duplicatas de avaliações
DELETE FROM order_reviews
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM order_reviews
    GROUP BY Review_ID
);

-- Preencher valores ausentes
UPDATE order_reviews
SET Review_Comment_Title_En = COALESCE(Review_Comment_Title_En, 'No Title'),
    Review_Comment_Message_En = COALESCE(Review_Comment_Message_En, 'No Comment');
