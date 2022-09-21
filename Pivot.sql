SELECT '12 Months' AS Duration,
    COUNT(IF(`Zip Code` = 98104, 1, NULL)) AS zip1,
    COUNT(IF(`Zip Code` = 98115, 1, NULL)) AS zip2,
    COUNT(IF(Gender = 'M', 1, NULL)) AS M,
    COUNT(clients.ClientID) AS tot,
    COUNT(NumKids) AS fam
FROM clients
INNER JOIN assistances
	ON clients.LastAssistanceID = assistances.VisitID
WHERE DateDIFF(CURDATE(), DATE) between 0 and 365
GROUP BY Duration;