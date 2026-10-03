CREATE DATABASE IF NOT EXISTS online_banking_system;
USE online_banking_system;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type ENUM('SAVINGS','CHECKING') NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_balance_non_negative CHECK (balance >= 0)
);

CREATE TABLE cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    card_number_masked VARCHAR(19) NOT NULL UNIQUE,
    card_type ENUM('DEBIT','CREDIT') NOT NULL,
    expiry_date DATE NOT NULL,
    status ENUM('ACTIVE','BLOCKED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_cards_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    related_account_id INT NULL,
    transaction_type ENUM('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transactions_related_account
        FOREIGN KEY (related_account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_amount_positive CHECK (amount > 0)
);

CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_cards_account_id ON cards(account_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
-- sample data
INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('Anand', 'Akshita', 'anand.akshita@email.com', '9876543210', 'Hyderabad, India'),
('Rohit', 'Sharma', 'rohit.sharma@email.com', '9876543211', 'Bengaluru, India');

INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'SAVINGS', 62400.00),
(1, 'CHECKING', 22120.00),
(2, 'CHECKING', 5000.00);

INSERT INTO cards (account_id, card_number_masked, card_type, expiry_date) VALUES
(1, '**** **** **** 4821', 'DEBIT', '2029-05-31'),
(2, '**** **** **** 7294', 'DEBIT', '2028-11-30');

INSERT INTO transactions (account_id, related_account_id, transaction_type, amount, description) VALUES
(1, NULL, 'DEPOSIT', 85000.00, 'Salary Deposit'),
(2, 3, 'TRANSFER_OUT', 5000.00, 'Transfer to Rohit Sharma'),
(3, 2, 'TRANSFER_IN', 5000.00, 'Transfer from Anand Akshita'),
(1, NULL, 'DEPOSIT', 430.20, 'Interest Credit');

SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM cards;
SELECT * FROM transactions;
-- Total balance across a customer's accounts
SELECT c.first_name, c.last_name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE c.customer_id = 1
GROUP BY c.customer_id;
-- All transactions for a customer, most recent first
SELECT t.transaction_id, t.transaction_type, t.amount, t.description, t.created_at
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE a.customer_id = 1
ORDER BY t.created_at DESC;
