# data_1

This program ingests invalid json data into a PostgreSQL database and transforms it into a summary table containing book counts and average pricing per year.

## Implementation Details

### 1. Data Cleaning (`data_clean.py`)
The raw input file `task1_d.json` is not formatted as valid JSON, but rather as an array of Ruby hashes (`{:key=>value}`). Python script uses Regular Expressions to standardize the syntax into valid JSON keys (`"key":value`). It outputs cleaned data into a JSON Lines `.jsonl` file, ensuring PostgreSQL can easily ingest it row by row.

### 2. Orchestration (`pipeline.sh`)
The bash script acts as the entry point for the pipeline. It:
- Executes the Python cleaning script.
- Creates the target PostgreSQL database.
- Sets up a `raw_data` table with a single `JSONB` column.
- Uses Postgres native `\copy` command to rapidly load the JSON Lines file into the database.
- Executes the SQL transformation script.

### 3. Data Transformation (`transform.sql`)
The transformation strictly runs inside the database using SQL:
- **`processed_data` Table:** Extracts data from the `JSONB` column into tabular format. Because the provided record `id` exceed integer limits, they are cast to `NUMERIC`. Pricing data is parsed using `REGEXP_REPLACE` to strip currency symbols. If the raw string indicates Euros, the script multiplies the numeric value by the 1.2 conversion rate. 
- **`summary_table` Table:** Aggregates the parsed data, grouped by `publication_year`, calculating the total `book_count` and using `ROUND(AVG(price_usd), 2)` to calculate the exact average price in USD rounded to cents.

## Usage
Ensure Python 3 and PostgreSQL are installed. Run the bash script:
```bash
chmod +x pipeline.sh
./pipeline.sh