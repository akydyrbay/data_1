DROP TABLE IF EXISTS processed_data CASCADE;
DROP TABLE IF EXISTS summary_table CASCADE;

CREATE TABLE processed_data AS
SELECT
    (data->>'id')::NUMERIC AS id,
    data->>'title' AS title,
    data->>'author' AS author,
    data->> 'genre' AS genre, 
    data->> 'publisher' AS publisher,
    (data->>'year')::INT AS publication_year,
    CASE
        WHEN data->>'price' LIKE '€%' THEN 
            CAST(REGEXP_REPLACE(data->>'price', '[^0-9\.]', '', 'g') AS NUMERIC) * 1.2
        ELSE 
            CAST(REGEXP_REPLACE(data->>'price', '[^0-9\.]', '', 'g') AS NUMERIC)
    END AS price_usd
FROM raw_data;

CREATE TABLE summary_table AS
SELECT
    publication_year,
    COUNT(*) AS book_count,
    ROUND(AVG(price_usd), 2) AS average_price
FROM processed_data
GROUP BY publication_year;
