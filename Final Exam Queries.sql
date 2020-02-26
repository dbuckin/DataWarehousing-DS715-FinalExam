--Final Exam - Category I - Option 1
--By Deane Buckingham

--tb offers cube
SELECT DISTINCT S.Name "Supplier Name",
		        S.City "Supplier City",
		        S.State "Supplier State",
		        P.Name "Product Name",
				P.Product_Packaging "Packaging",
	   	        SUM(Quantity) "Total Offers Quantity",
	   	        SUM(Quantity*Price) "Total Offers Value",
				MAX(Price) "Maximum Price",
				MIN(Price) "Minimum Price"
  INTO Tb_Offers_Cube
  FROM Tb_Supplier S,  Tb_Product P, Tb_Offers O
  WHERE S.Supp_ID=O.Supp_ID AND
		    P.Prod_ID=O.Prod_ID
  GROUP BY CUBE((S.State, S.City, S.Name),(P.Product_Packaging, P.Name)),
  ROLLUP(S.State, S.City, S.Name),
  ROLLUP(P.Product_Packaging, P.Name)

/*
1 - Value of products offered by supplier and by product packaging? (2 points)
*/
SELECT [Supplier Name], [Packaging], [Total Offers Value]
FROM Tb_Offers_Cube
WHERE "Supplier Name" IS NOT NULL
  	AND "Supplier City" IS NOT NULL
  	AND "Supplier State" IS NOT NULL
  	AND "Product Name" IS NULL
	AND "Packaging" IS NOT NULL
	ORDER BY "Supplier Name"
/*
2 - Volume of milk offered by each supplier in Wisconsin? (2 points)
*/
SELECT [Product Name], [Supplier Name], [Supplier State], [Total Offers Quantity]
FROM Tb_Offers_Cube
WHERE "Supplier Name" IS NOT NULL
  	AND "Supplier City" IS NOT NULL
  	AND "Supplier State" = 'Wisconsin'
  	AND "Product Name" = 'Milk'
	AND "Packaging" IS NOT NULL
	ORDER BY "Supplier Name"
/*
3 - Find the maximum price for each product offered in Madison? (5 points)
*/
SELECT [Product Name], [Supplier City], [Maximum Price]
FROM Tb_Offers_Cube
WHERE "Supplier Name" IS NULL
  	AND "Supplier City" = 'Madison'
  	AND "Supplier State" IS NOT NULL
  	AND "Product Name" IS NOT NULL
	AND "Packaging" IS NOT NULL
	ORDER BY "Product Name"
/*
4 - For each supplier city find the product offered in largest quantity? (8 points)
*/
SELECT T1."Supplier City", T2."Product Name", T2."Total Offers Quantity"
FROM (SELECT "Supplier City", MAX("Total Offers Quantity") AS qty
		FROM Tb_Offers_Cube
		WHERE "Supplier Name" IS NULL
  			AND "Supplier City" IS NOT NULL
  			AND "Supplier State" IS NOT NULL
  			AND "Product Name" IS NOT NULL
			AND "Packaging" IS NOT NULL
		GROUP BY "Supplier City") AS T1, 
				(SELECT "Supplier City", "Total Offers Quantity", "Product Name"
				FROM Tb_Offers_Cube
				WHERE "Supplier Name" IS NULL
  					AND "Supplier City" IS NOT NULL
  					AND "Supplier State" IS NOT NULL
  					AND "Product Name" IS NOT NULL
					AND "Packaging" IS NOT NULL) AS T2
WHERE T1."Supplier City" = T2."Supplier City"
AND T1.qty = T2."Total Offers Quantity"
ORDER BY "Supplier City"

/*
5 - For each product find the city where it is offered at the lowest price? (8 points)
*/
SELECT T1."Product Name", T2."Supplier City", T2."Minimum Price"
FROM (SELECT [Product Name], [Minimum Price]
	FROM Tb_Offers_Cube
	WHERE "Supplier Name" IS NULL
  		AND "Supplier City" IS NULL
  		AND "Supplier State" IS NULL
  		AND "Product Name" IS NOT NULL
		AND "Packaging" IS NOT NULL) AS T1,
			(SELECT [Product Name], [Supplier City], [Minimum Price]
			FROM Tb_Offers_Cube
			WHERE "Supplier Name" IS NULL
  				AND "Supplier City" IS NOT NULL
  				AND "Supplier State" IS NOT NULL
  				AND "Product Name" IS NOT NULL
				AND "Packaging" IS NOT NULL) AS T2
WHERE T1."Product Name" = T2."Product Name"
AND T1."Minimum Price" = T2."Minimum Price"
ORDER BY "Product Name"

