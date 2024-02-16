--3. a. Which drug (generic_name) had the highest total drug cost?
-- Insulin Glargine
SELECT drug.generic_name,
SUM(prescription.total_drug_cost_ge65) AS total_drug_cost
FROM drug
JOIN prescription 
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY total_drug_cost DESC;

--3 b. Which drug (generic_name) has the hightest total cost per day?
-- C1 ESTERASE INHIBITOR
SELECT drug.generic_name,
SUM(prescription.total_drug_cost) AS total_cost,
SUM(prescription.total_day_supply) AS total_day,
SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)
AS cost_per_day
FROM drug
JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC;

-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs
SELECT drug_name,
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither'
			END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- Opioids
SELECT drug_type,
SUM(total_drug_cost) AS total_cost
FROM (SELECT drug.drug_name,
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			ELSE 'neither'
			END AS drug_type, total_drug_cost AS total_drug_cost
	 FROM prescription
	 JOIN drug ON prescription.drug_name = drug.drug_name) AS subqery
	 GROUP BY drug_type
	 ORDER BY total_cost DESC;

--5a. How many CBSAs are in Tennessee? 
-- 10
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
WHERE fips_county.state = 'TN';

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--
