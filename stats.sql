DROP PROCEDURE IF EXISTS stats;
DELIMITER //
CREATE PROCEDURE stats()
	BEGIN
		SET session group_concat_max_len=15000;

		SELECT
			GROUP_CONCAT(CONCAT(
					' COUNT(IF(`Zip Code` = ', z.`Zip Code`,', 1, NULL)) AS ', 'Zip_', CAST(z.`Zip Code` AS CHAR)
			)) INTO @ZipQuery
		FROM
			(SELECT `Zip Code`
			FROM
				clients
			GROUP BY `Zip Code`) z;
			
		SELECT
			GROUP_CONCAT(CONCAT(
					' COUNT(IF(Gender = ', "'", g.Gender, "'", ', 1, NULL)) AS ', 'Gender_', g.Gender
			)) INTO @GenderQuery
		FROM
			(SELECT Gender
			FROM
				clients
			GROUP BY Gender) g;
			
		SELECT
			GROUP_CONCAT(CONCAT(
					' COUNT(IF(Race = ', "'", r.Race, "'",', 1, NULL)) AS ', 'Race_', r.Race
			)) INTO @RaceQuery
		FROM
			(SELECT Race
			FROM
				clients
			GROUP BY Race) r;

		SET @TwelveMonthQuery = CONCAT('SELECT ', "'12_Month'", ' AS Duration, 
		Count(clients.ClientID) AS Total,
		Count(NumKids) AS Families, ',
		@GenderQuery, ',', 
		@RaceQuery, ',',
		@ZipQuery,
		' FROM clients INNER JOIN assistances
			ON clients.LastAssistanceID = assistances.VisitID
		WHERE DateDIFF(CURDATE(), DATE) between 0 and 365 GROUP BY Duration');

		SET @SixMonthQuery = CONCAT('SELECT ', "'6_Month'", ' AS Duration, 
		Count(clients.ClientID) AS Total,
		Count(NumKids) AS Families, ',
		@GenderQuery, ',', 
		@RaceQuery, ',',
		@ZipQuery,
		' FROM clients INNER JOIN assistances
			ON clients.LastAssistanceID = assistances.VisitID
		WHERE DateDIFF(CURDATE(), DATE) between 0 and 182 GROUP BY Duration');

		SET @ThreeMonthQuery = CONCAT('SELECT ', "'3_Month'", ' AS Duration, 
		Count(clients.ClientID) AS Total,
		Count(NumKids) AS Families, ',
		@GenderQuery, ',', 
		@RaceQuery, ',',
		@ZipQuery,
		' FROM clients INNER JOIN assistances
			ON clients.LastAssistanceID = assistances.VisitID
		WHERE DateDIFF(CURDATE(), DATE) between 0 and 91 GROUP BY Duration');
        
        SET @OneMonthQuery = CONCAT('SELECT ', "'1_Month'", ' AS Duration, 
		Count(clients.ClientID) AS Total,
		Count(NumKids) AS Families, ',
		@GenderQuery, ',', 
		@RaceQuery, ',',
		@ZipQuery,
		' FROM clients INNER JOIN assistances
			ON clients.LastAssistanceID = assistances.VisitID
		WHERE DateDIFF(CURDATE(), DATE) between 0 and 30 GROUP BY Duration');

		SET @AllTimeQuery = CONCAT('SELECT ', "'All_Time'", ' AS Duration, 
		Count(clients.ClientID) AS Total,
		Count(NumKids) AS Families, ',
		@GenderQuery, ',', 
		@RaceQuery, ',',
		@ZipQuery,
		' FROM clients 
		GROUP BY Duration');

		SET @PivotQuery = CONCAT(@TwelveMonthQuery, ' UNION ALL ', @SixMonthQuery, ' UNION ALL ', @ThreeMonthQuery, ' UNION ALL ', @OneMonthQuery, ' UNION ALL ', @AllTimeQuery);

		PREPARE statement FROM @PivotQuery;
		EXECUTE statement;
		DEALLOCATE PREPARE statement;
	END//