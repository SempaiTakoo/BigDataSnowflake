-- Импортурем сырые данные из .csv
CREATE TABLE IF NOT EXISTS clean_data (
    id INT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age INT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price NUMERIC,
    product_quantity INT,
    sale_date DATE,
    sale_customer_id INT,
    sale_seller_id INT,
    sale_product_id INT,
    sale_quantity INT,
    sale_total_price NUMERIC,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight NUMERIC,
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating NUMERIC,
    product_reviews INT,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

COPY clean_data (
    id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code,
    product_name,
    product_category,
    product_price,
    product_quantity,
    sale_date,
    sale_customer_id,
    sale_seller_id,
    sale_product_id,
    sale_quantity,
    sale_total_price,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email,
    pet_category,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
)
FROM '/data/MOCK_DATA.csv'
WITH CSV HEADER DELIMITER ',' NULL '' ESCAPE '"';

COPY clean_data FROM '/data/MOCK_DATA (1).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (2).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (3).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (4).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (5).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (6).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (7).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (8).csv' WITH CSV HEADER;
COPY clean_data FROM '/data/MOCK_DATA (9).csv' WITH CSV HEADER;


-- Исправляем индексацию
ALTER TABLE clean_data
DROP COLUMN id;

ALTER TABLE clean_data
ADD COLUMN id SERIAL PRIMARY KEY;

ALTER TABLE clean_data
DROP COLUMN sale_customer_id;
ALTER TABLE clean_data
ADD COLUMN sale_customer_id SERIAL;

ALTER TABLE clean_data
DROP COLUMN sale_seller_id;
ALTER TABLE clean_data
ADD COLUMN sale_seller_id SERIAL;

ALTER TABLE clean_data
DROP COLUMN sale_product_id;
ALTER TABLE clean_data
ADD COLUMN sale_product_id SERIAL;


-- -- Запускаем скрипт для трансформации
-- \i ./docker-entrypoint-initdb.d/transform.sql;


-- Таблица клиентов
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT UNIQUE,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);

-- Таблица продавцов
CREATE TABLE IF NOT EXISTS sellers (
    seller_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT UNIQUE,
    country TEXT,
    postal_code TEXT
);

-- Таблица товаров
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name TEXT,
    category TEXT,
    price NUMERIC(10, 2),
    weight NUMERIC(10, 2),
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC(3, 1),
    reviews INT,
    release_date DATE,
    expiry_date DATE
);

-- Таблица магазинов
CREATE TABLE IF NOT EXISTS stores (
    store_id SERIAL PRIMARY KEY,
    name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT
);

-- Таблица поставщиков
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT,
    contact TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT
);

-- Фактовая таблица продаж
CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    seller_id INT REFERENCES sellers(seller_id),
    product_id INT REFERENCES products(product_id),
    store_id INT REFERENCES stores(store_id),
    supplier_id INT REFERENCES suppliers(supplier_id),
    sale_date DATE,
    quantity INT,
    total_price NUMERIC(10, 2)
);


-- Вставляем уникальных клиентов
INSERT INTO customers (
    first_name,
    last_name,
    age,
    email,
    country,
    postal_code,
    pet_type,
    pet_name,
    pet_breed
)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM clean_data;

-- Вставляем уникальных продавцов
INSERT INTO sellers (
    first_name,
    last_name,
    email,
    country,
    postal_code
)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM clean_data;

-- Вставляем уникальные товары
INSERT INTO products (
    name,
    category,
    price,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date
)
SELECT DISTINCT
    product_name,
    product_category,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date
FROM clean_data;

-- Вставляем уникальные магазины
INSERT INTO stores (
    name,
    location,
    city,
    state,
    country,
    phone,
    email
)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM clean_data;

-- Вставляем уникальных поставщиков
INSERT INTO suppliers (
    name,
    contact,
    email,
    phone,
    address,
    city,
    country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM clean_data;

-- Заполняем фактовую таблицу продаж
INSERT INTO fact_sales (
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_date,
    quantity,
    total_price
)
SELECT
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    sp.supplier_id,
    m.sale_date,
    m.sale_quantity,
    m.sale_total_price
FROM clean_data m
JOIN customers c ON m.customer_email = c.email
JOIN sellers s ON m.seller_email = s.email
JOIN products p ON m.product_name = p.name AND m.product_category = p.category
JOIN stores st ON m.store_name = st.name AND m.store_city = st.city
JOIN suppliers sp ON m.supplier_name = sp.name AND m.supplier_email = sp.email
LIMIT 1000 OFFSET 10;

-- Чистим временные данные
DROP TABLE clean_data;
