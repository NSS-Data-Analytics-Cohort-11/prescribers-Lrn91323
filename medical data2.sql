-- 1. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT prescription.npi, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name,prescriber.specialty_description,
SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescription.npi,  prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name,prescriber.specialty_description
ORDER BY total_claims DESC;

--2. a. Which specialty had the most total number of claims (totaled over all drugs)?
-- Family Practice
SELECT prescriber.specialty_description,
SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;

-- 2. b. Which specialty had the most total number of claims for opioids?
-- Nurse Practitioner
SELECT prescriber.specialty_description,
SUM(prescription.total_claim_count) AS opioid_claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY opioid_claims DESC;


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
SUM(total_drug_cost)::MONEY AS total_cost
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
-- 42
SELECT*
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE fips_county.state = 'TN';

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- Nashville-Davidson-Mufreesboro. Morristown.
SELECT cbsa.cbsaname,
SUM(population.population) AS total_population
FROM population
JOIN cbsa 
ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsa.cbsaname
ORDER BY total_population asc;

--5 c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- Sevier
SELECT SUM(population.population) AS population, fips_county.county
FROM fips_county
LEFT JOIN cbsa 
ON fips_county.fipscounty = cbsa.fipscounty
LEFT JOIN population
ON fips_county.fipscounty = population.fipscounty
WHERE cbsa.cbsa IS NULL
AND population IS NOT NULL
GROUP BY fips_county.county, population
ORDER BY population DESC;

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
FROM prescription
JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE prescription.total_claim_count >= 3000;

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, prescriber.nppes_provider_last_org_name, prescriber.nppes_provider_first_name
FROM prescription
INNER JOIN drug
ON prescription.drug_name = prescriber.npi
WHERE total_claim_count >= '3000'
ORDER BY total_claim_count DESC;

--7a.
SELECT prescriber.npi, prescription.drug_name
FROM prescriber
JOIN prescription 
ON prescriber.npi = prescription.npi
JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';

--7.b
SELECT prescriber.npi, drug.drug_name, prescription.total_claim_count
FROM prescriber
CROSS JOIN drug 
LEFT JOIN prescription 
USING (npi, drug_name)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'
ORDER BY prescriber.npi;

--7b AND C
SELECT prescriber.npi, prescription.drug_name, prescription.total_claim_count,
COALESCE(COUNT(prescription.total_claim_count), 0) AS total_claim_count
FROM prescriber
JOIN prescription 
ON prescriber.npi = prescription.npi
JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'
GROUP BY prescription.total_claim_count, prescriber.npi, prescription.drug_name;


