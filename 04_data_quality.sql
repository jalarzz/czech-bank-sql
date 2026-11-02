--Find out wealth ini district and regions.
SELECT district_id,
       district_name,
       region,
       avg_salary
FROM district
ORDER BY avg_salary DESC;

--find out average loan amount
SELECT AVG(amount)
FROM loan;

--Loans that are still running and are more than 100000 in amount
SELECT loan_id,
       account_id,
       amount,
       status_desc
FROM loan
WHERE amount > 100000
      AND status_desc != 'Finished, paid'
ORDER BY amount DESC;

--To find out toal amount of clients account and loans for bigger picture
SELECT ( SELECT COUNT(*)
        FROM client
       ) AS total_clients,
       ( SELECT COUNT(*)
         FROM account
       ) AS total_accounts,
       ( SELECT COUNT(*)
         FROM loan
       ) AS total_loans
FROM dual;

--Gender profiling
SELECT gender,
       COUNT(*) AS clients
FROM client
GROUP BY gender
ORDER BY clients DESC;

--Loan size by loan status
-- Shows whether problem loans tend to be larger than healthy ones,
--which helps the bank set loan limits and review large applications more carefully.
SELECT status_desc,
       COUNT(*)              AS total_loans,
       MIN(amount)           AS smallest_loan,
       MAX(amount)           AS largest_loan,
       ROUND(AVG(amount), 2) AS average_loan
FROM loan
GROUP BY status_desc
ORDER BY average_loan DESC;