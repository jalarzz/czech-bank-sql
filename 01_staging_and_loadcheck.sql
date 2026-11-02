--so data reads as decimal    
ALTER SESSION SET nls_numeric_characters = '.,'; 
--disctrict table
CREATE TABLE stg_district (
    a1  VARCHAR2(10),
    a2  VARCHAR2(50),
    a3  VARCHAR2(50),
    a4  VARCHAR2(20),
    a5  VARCHAR2(20),
    a6  VARCHAR2(20),
    a7  VARCHAR2(20),
    a8  VARCHAR2(20),
    a9  VARCHAR2(20),
    a10 VARCHAR2(20),
    a11 VARCHAR2(20),
    a12 VARCHAR2(20),
    a13 VARCHAR2(20),
    a14 VARCHAR2(20),
    a15 VARCHAR2(20),
    a16 VARCHAR2(20)
);

CREATE TABLE stg_account (
    account_id  VARCHAR2(10),
    district_id VARCHAR2(10),
    frequency   VARCHAR2(30),
    date_raw    VARCHAR2(20)
);

CREATE TABLE stf_disp (
    disp_id    VARCHAR2(10),
    client_id  VARCHAR2(10),
    account_id VARCHAR2(10),
    disp_type  VARCHAR2(20)
);

CREATE TABLE stg_client (
    client_id    VARCHAR2(10),
    birth_number VARCHAR2(10),
    district_id  VARCHAR2(10)
);

CREATE TABLE stg_order (
    order_id   VARCHAR2(10),
    account_id VARCHAR2(10),
    bank_to    VARCHAR2(5),
    account_to VARCHAR2(20),
    amount     VARCHAR2(20),
    k_symbol   VARCHAR2(20)
);

CREATE TABLE stg_trans (
    trans_id        VARCHAR2(10),
    account_id      VARCHAR2(10),
    date_raw        VARCHAR2(10),
    trans_type      VARCHAR2(10),
    operation       VARCHAR2(30),
    amount          VARCHAR2(20),
    balance         VARCHAR2(20),
    k_symbol        VARCHAR2(20),
    bank            VARCHAR2(5),
    partner_account VARCHAR2(20)
);

CREATE TABLE stg_loan (
    loan_id    VARCHAR2(10),
    account_id VARCHAR2(10),
    date_raw   VARCHAR2(10),
    amount     VARCHAR2(20),
    duration   VARCHAR2(10),
    payments   VARCHAR2(20),
    status     VARCHAR2(5)
);

CREATE TABLE stg_card (
    card_id   VARCHAR2(10),
    disp_id   VARCHAR2(10),
    card_type VARCHAR2(20),
    issued    VARCHAR2(20)
);

SELECT
    *
FROM
    stg_disp;

ALTER TABLE stf_disp RENAME TO stg_disp; --rename the table because of misspelling
--to check if the data is matching
SELECT 'district' tbl, COUNT(*) n FROM stg_district UNION ALL
SELECT 'account', COUNT(*) FROM stg_account UNION ALL
SELECT 'client',  COUNT(*) FROM stg_client  UNION ALL
SELECT 'disp',    COUNT(*) FROM stg_disp    UNION ALL
SELECT 'order',   COUNT(*) FROM stg_order   UNION ALL
SELECT 'trans',   COUNT(*) FROM stg_trans   UNION ALL
SELECT 'loan',    COUNT(*) FROM stg_loan    UNION ALL
SELECT 'card',    COUNT(*) FROM stg_card;


