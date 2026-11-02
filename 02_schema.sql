CREATE TABLE district (
    district_id            NUMBER(2) PRIMARY KEY,
    district_name          VARCHAR2(30) NOT NULL,
    region                 VARCHAR2(20) NOT NULL,
    inhabitants            NUMBER(8),
    munic_lt_500           NUMBER(4),
    munic_500_1999         NUMBER(4),
    munic_2000_9999        NUMBER(4),
    munic_gt_10000         NUMBER(4),
    num_cities             NUMBER(3),
    urban_pct              NUMBER(4, 1),
    avg_salary             NUMBER(6),
    unemp_1995             NUMBER(4, 2),
    unemp_1996             NUMBER(4, 2),
    entrepreneurs_per_1000 NUMBER(4),
    crimes_1995            NUMBER(6),
    crimes_1996            NUMBER(6)
);

CREATE TABLE account (
    account_id     NUMBER(5) PRIMARY KEY,
    district_id    NUMBER(2) NOT NULL
        REFERENCES district ( district_id ),
    statement_freq VARCHAR2(20) NOT NULL,
    open_date      DATE NOT NULL
);

CREATE TABLE client (
    client_id   NUMBER(5) PRIMARY KEY,
    gender      CHAR(1) CHECK ( gender IN ( 'M', 'F' ) ),
    birth_date  DATE NOT NULL,
    district_id NUMBER(2) NOT NULL
        REFERENCES district ( district_id )
);

CREATE TABLE disp (
    disp_id    NUMBER(5) PRIMARY KEY,
    client_id  NUMBER(5) NOT NULL
        REFERENCES client ( client_id ),
    account_id NUMBER(5) NOT NULL
        REFERENCES account ( account_id ),
    disp_type  VARCHAR2(10) CHECK ( disp_type IN ( 'Owner', 'User' ) )
);

CREATE TABLE perm_order (
    order_id   NUMBER(5) PRIMARY KEY,
    account_id NUMBER(5) NOT NULL
        REFERENCES account ( account_id ),
    bank_to    VARCHAR(2),
    account_to VARCHAR2(8),
    amount     NUMBER(8, 2),
    purpose    VARCHAR2(20)
);

CREATE TABLE trans (
    trans_id        NUMBER(7) PRIMARY KEY,
    account_id      NUMBER(5) NOT NULL
        REFERENCES account ( account_id ),
    trans_date      DATE NOT NULL,
    direction       VARCHAR2(6) CHECK ( direction IN ( 'Credit', 'Debit' ) ),
    operation       VARCHAR2(30),
    amount          NUMBER(9, 2),
    balance         NUMBER(10, 2),
    purpose         VARCHAR2(20),
    partner_bank    VARCHAR2(2),
    partner_account VARCHAR2(8)
);

CREATE TABLE loan (
    loan_id         NUMBER(4) PRIMARY KEY,
    account_id      NUMBER(5) NOT NULL UNIQUE
        REFERENCES account ( account_id ),
    loan_date       DATE NOT NULL,
    amount          NUMBER(8),
    duration_months NUMBER(3),
    monthly_payment NUMBER(7, 2),
    status          CHAR(1) CHECK ( status IN ( 'A', 'B', 'C', 'D' ) ),
    status_desc     VARCHAR2(40)
);

CREATE TABLE card (
    card_id    NUMBER(4) PRIMARY KEY,
    disp_id    NUMBER(5) NOT NULL UNIQUE
        REFERENCES disp ( disp_id ),
    card_type  VARCHAR2(10),
    issue_date DATE NOT NULL
);