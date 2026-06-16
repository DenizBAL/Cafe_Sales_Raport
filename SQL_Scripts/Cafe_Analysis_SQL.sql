-- Null Değer Kontrolü
SELECT * FROM dirty_cafe_sales WHERE Item IS NULL 
							   OR Quantity IS NULL
							   OR Price_Per_Unit IS NULL
							   OR Total_Spent IS NULL
							   OR Payment_Method IS NULL
							   OR Location IS NULL
							   OR Transaction_Date IS NULL

-- Yedekleme 
SELECT * INTO cleaned_cafe_sales FROM dirty_cafe_sales

--Değer Düzeltme/Kurtarma (Imputation)
UPDATE cleaned_cafe_sales
SET Price_Per_Unit=Case
					  WHEN Item = 'Cookie' THEN 10
					  WHEN Item = 'Tea' THEN 15
					  WHEN Item = 'Coffee' THEN 20
					  WHEN Item = 'Juice' THEN 30
					  WHEN Item = 'Cake' THEN 30
					  WHEN Item = 'Smoothie' THEN 40
					  WHEN Item = 'Sandwich' THEN 40
					  WHEN Item = 'Salad' THEN 50
					END
WHERE Price_Per_Unit IS NULL AND Item NOT IN ('UNKNOWN','ERROR') AND Item IS NOT NULL;

UPDATE cleaned_cafe_sales
SET Total_Spent=Quantity*Price_Per_Unit
WHERE Total_Spent IS NULL AND Quantity IS NOT NULL AND Price_Per_Unit IS NOT NULL;

UPDATE cleaned_cafe_sales
SET Quantity=Total_Spent/Price_Per_Unit
WHERE Quantity IS NULL AND Total_Spent IS NOT NULL AND Price_Per_Unit IS NOT NULL;

UPDATE cleaned_cafe_sales
SET Price_Per_Unit= Total_Spent/Quantity
WHERE Price_Per_Unit IS NULL AND Total_Spent IS NOT NULL AND Quantity IS NOT NULL;

--Metinsel Hatalar = 'Not Specified' 
UPDATE cleaned_cafe_sales
SET Item=CASE
	WHEN Price_Per_Unit='10' THEN 'Cookie'
	WHEN Price_Per_Unit='15' THEN 'Tea'
	WHEN Price_Per_Unit='20' THEN 'Coffee'
	WHEN Price_Per_Unit='50' THEN 'Salad'
	WHEN Price_Per_Unit='30' THEN 'Not Specified Cake/Juice'
	WHEN Price_Per_Unit='40' THEN 'Not Specified Smoothie/Sandwich'
END 
WHERE Item IS NULL OR Item IN ('UNKNOWN', 'ERROR');

UPDATE cleaned_cafe_sales
SET Item='Not Specified',
	Quantity=1,
	Price_Per_Unit=Total_Spent
WHERE Total_Spent>0 AND (Item IS NULL OR Quantity IS NULL OR Price_Per_Unit IS NULL)

UPDATE cleaned_cafe_sales
SET Item='Not Specified',
	Quantity = 0,
	Price_Per_Unit=0,
	Total_Spent=0
WHERE Total_Spent IS NULL OR (Item IS NULL OR Quantity IS NULL OR Price_Per_Unit IS NULL)

UPDATE cleaned_cafe_sales
SET Payment_Method='Not Specified'
WHERE Payment_Method IS NULL OR Payment_Method IN ('ERROR','UNKNOWN')

UPDATE cleaned_cafe_sales
SET Location='Not Specified'
WHERE Location IS NULL OR Location IN ('UNKNOWN','ERROR')

-- İşlem Tarihi Düzeltme

UPDATE cleaned_cafe_sales
SET Transaction_Date=DATEADD(DAY,ABS(CHECKSUM(NEWID()))%365,'2023-01-01')
WHERE Transaction_Date IS NULL;


-- Null Değer Kontrolü

SELECT 
    SUM(CASE WHEN Transaction_ID IS NULL THEN 1 ELSE 0 END) AS Null_Transaction_ID,
    SUM(CASE WHEN Item IS NULL THEN 1 ELSE 0 END) AS Null_Item,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Price_Per_Unit IS NULL THEN 1 ELSE 0 END) AS Null_Price,
    SUM(CASE WHEN Total_Spent IS NULL THEN 1 ELSE 0 END) AS Null_Total_Spent,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Null_Payment_Method,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Null_Location,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS Null_Transaction_Date
FROM cleaned_cafe_sales;


--VIEW Oluşturma

CREATE VIEW vW_Cleaned_Cafe_Sales AS
SELECT 
    Transaction_ID,
    Item,
    Quantity,
    Price_Per_Unit,
    Total_Spent,
    Payment_Method,
    Location,
    Transaction_Date
FROM cleaned_cafe_sales;