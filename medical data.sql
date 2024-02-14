--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
-- 1881634483
SELECT prescription.npi, 
SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
JOIN prescription
ON prescription.npi = prescriber.npi
GROUP BY prescription.npi
ORDER BY total_claims DESC;

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
JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;

-- 2. b. Which specialty had the most total number of claims for opioids?
-- Critical Care
SELECT prescriber.specialty_description,
SUM(prescription.total_claim_count) AS opioid_claims
FROM prescriber
JOIN prescription
ON prescriber.npi = prescription.npi
JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY opioid_claims;

--3. a. Which drug (generic_name) had the highest total drug cost?
--



