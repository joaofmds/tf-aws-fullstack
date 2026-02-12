START TRANSACTION;

CREATE SCHEMA IF NOT EXISTS product;

CREATE TABLE product.product
(
  id BigSerial NOT NULL,
  name Text NOT NULL,
  cost_price Decimal(12,2) NOT NULL,
  sale_price Decimal(12,2) NOT NULL,
  quantity Integer NOT NULL,
  created_at Timestamp NOT NULL
)
WITH (autovacuum_enabled=true);

ALTER TABLE product.product ADD CONSTRAINT pk_product PRIMARY KEY (id);

COMMIT;