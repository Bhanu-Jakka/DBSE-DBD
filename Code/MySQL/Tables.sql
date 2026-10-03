use online_banking_system;
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_type VARCHAR(30) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    emi_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_loan_principal_positive CHECK (principal_amount > 0)
);

CREATE TABLE deposits (
    deposit_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    deposit_type VARCHAR(10) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    maturity_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_deposits_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_deposits_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_deposit_principal_positive CHECK (principal_amount > 0)
);

-- Transaction History "All Accounts" needs nothing new — handled at query level below

-- Notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    type VARCHAR(30) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Login activity (for Profile > Security)
CREATE TABLE login_activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    device_info VARCHAR(255),
    CONSTRAINT fk_login_activity_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Extra card management fields
ALTER TABLE cards ADD COLUMN daily_limit DECIMAL(12,2) NOT NULL DEFAULT 50000.00;
ALTER TABLE cards ADD COLUMN online_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE cards ADD COLUMN contactless_enabled BOOLEAN NOT NULL DEFAULT TRUE;

-- Profile security fields
ALTER TABLE customers ADD COLUMN two_factor_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE customers ADD COLUMN kyc_status VARCHAR(20) NOT NULL DEFAULT 'VERIFIED';
