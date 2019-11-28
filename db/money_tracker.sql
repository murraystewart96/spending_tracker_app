DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS tags;


CREATE TABLE merchants(
  id SERIAL8 PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE tags(
  id SERIAL8 PRIMARY KEY,
  category VARCHAR
);

CREATE TABLE transactions(
  id SERIAL8 PRIMARY KEY,
  description VARCHAR,
  amount INT,
  date_of_transaction VARCHAR,
  merchant_id INT REFERENCES merchants(id),
  tag_id INT REFERENCES tags(id)
);
