DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;


CREATE TABLE merchants(
  id SERIAL8 PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE tags(
  id SERIAL8 PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE transactions(
  id SERIAL8 PRIMARY KEY,
  description VARCHAR,
  amount DECIMAL,
  transaction_timestamp TIMESTAMP,
  merchant_id INT REFERENCES merchants(id),
  tag_id INT REFERENCES tags(id)
);

CREATE TABLE users(
  id SERIAL8 PRIMARY KEY,
  first_name VARCHAR,
  last_name VARCHAR,
  balance DECIMAL,
  balance_warning DECIMAL
);
