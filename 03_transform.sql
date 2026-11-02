INSERT INTO district
    SELECT
        TO_NUMBER(a1),
        a2,
        a3,
        TO_NUMBER(a4),
        TO_NUMBER(a5),
        TO_NUMBER(a6),
        TO_NUMBER(a7),
        TO_NUMBER(a8),
        TO_NUMBER(a9),
        TO_NUMBER(a10),
        TO_NUMBER(a11),
        TO_NUMBER(nullif(a12, '?')),
        TO_NUMBER(a13),
        TO_NUMBER(a14),
        TO_NUMBER(nullif(a15, '?')),
        TO_NUMBER(a16)
    FROM
        stg_district;

SELECT
    *
FROM
    account;

INSERT INTO account
    SELECT
        TO_NUMBER(account_id),
        TO_NUMBER(district_id),
        CASE frequency
            WHEN 'POPLATEK MESICNE'   THEN
                'Monthly' --translating from czech
            WHEN 'POPLATEK TYDNE'     THEN
                'Weekly'
            WHEN 'POPLATEK PO OBRATU' THEN
                'After transaction'
        END,
        TO_DATE('19' || date_raw, 'YYYYMMDD') --930101 to 1993-01-01
    FROM
        stg_account;

INSERT INTO client
    SELECT
        TO_NUMBER(client_id),
        CASE
            WHEN TO_NUMBER(substr(birth_number, 3, 2)) > 50 THEN
                'F'
            ELSE
                'M'
        END,
        TO_DATE('19'
                || substr(birth_number, 1, 2)
                || lpad(
            MOD(TO_NUMBER(substr(birth_number, 3, 2)),
                50),
            2,
            '0'
        )
                || substr(birth_number, 5, 2),
                'YYYYMMDD'),
        TO_NUMBER(district_id)
    FROM
        stg_client;

INSERT INTO disp
    SELECT
        TO_NUMBER(disp_id),
        TO_NUMBER(client_id),
        TO_NUMBER(account_id),
        CASE disp_type
            WHEN 'OWNER' THEN
                'Owner'
            ELSE
                'User'
        END
    FROM
        stg_disp;

COMMIT;

INSERT INTO perm_order
    SELECT
        TO_NUMBER(order_id),
        TO_NUMBER(account_id),
        bank_to,
        account_to,
        TO_NUMBER(amount),
        CASE TRIM(k_symbol)
            WHEN 'SIPO'     THEN
                'Household'
            WHEN 'UVER'     THEN
                'Loan payment'
            WHEN 'POJISTNE' THEN
                'Insurance'
            WHEN 'LEASING'  THEN
                'Leasing'
        END                                  -- blanks become NULL
    FROM
        stg_order;

INSERT INTO trans
    SELECT
        TO_NUMBER(trans_id),
        TO_NUMBER(account_id),
        TO_DATE('19' || date_raw, 'YYYYMMDD'),
        CASE trans_type
            WHEN 'PRIJEM' THEN
                'Credit'
            ELSE
                'Debit'
        END,  -- VYDAJ and VYBER
        CASE operation
            WHEN 'VYBER'          THEN
                'Cash withdrawal'
            WHEN 'VYBER KARTOU'   THEN
                'Card withdrawal'
            WHEN 'VKLAD'          THEN
                'Cash deposit'
            WHEN 'PREVOD NA UCET' THEN
                'Transfer to other bank'
            WHEN 'PREVOD Z UCTU'  THEN
                'Transfer from other bank'
        END,
        TO_NUMBER(amount),
        TO_NUMBER(balance),
        CASE TRIM(k_symbol)
            WHEN 'UROK'        THEN
                'Interest'
            WHEN 'SANKC. UROK' THEN
                'Penalty interest'
            WHEN 'SLUZBY'      THEN
                'Statement fee'
            WHEN 'SIPO'        THEN
                'Household'
            WHEN 'DUCHOD'      THEN
                'Pension'
            WHEN 'POJISTNE'    THEN
                'Insurance'
            WHEN 'UVER'        THEN
                'Loan payment'
        END,
        TRIM(bank),
        nullif(
            trim(partner_account),
            '0'
        )   -- '0' means no account
    FROM
        stg_trans;

INSERT INTO loan
    SELECT
        TO_NUMBER(loan_id),
        TO_NUMBER(account_id),
        TO_DATE('19' || date_raw, 'YYYYMMDD'),
        TO_NUMBER(amount),
        TO_NUMBER(duration),
        TO_NUMBER(payments),
        status,
        CASE status
            WHEN 'A' THEN
                'Finished, paid'
            WHEN 'B' THEN
                'Finished, not paid'
            WHEN 'C' THEN
                'Running, OK'
            WHEN 'D' THEN
                'Running, in debt'
        END
    FROM
        stg_loan;

INSERT INTO card
    SELECT
        TO_NUMBER(card_id),
        TO_NUMBER(disp_id),
        card_type,
        TO_DATE('19'
                || substr(issued, 1, 6),
                'YYYYMMDD')
    FROM
        stg_card;

COMMIT;