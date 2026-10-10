import pandas as pd
import psycopg2
from getpass import getpass

# 1. Read cleaned market data
file_path = "data/cleaned/market_prices_clean.csv"
data = pd.read_csv(file_path)

print("CSV rows:", len(data))

# 2. PostgreSQL password
password = getpass("Enter PostgreSQL password: ")

# 3. Connect to PostgreSQL
connection = psycopg2.connect(
    host="localhost",
    port="5432",
    database="semiconductor_analytics_db",
    user="postgres",
    password=password
)

cursor = connection.cursor()

print("PostgreSQL connected!")

# 4. Insert every CSV row into staging table
insert_query = """
INSERT INTO market_prices_staging (
    price_date,
    adjusted_close,
    close_price,
    high_price,
    low_price,
    open_price,
    volume,
    ticker
)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
"""

for _, row in data.iterrows():
    cursor.execute(
        insert_query,
        (
            row["Date"],
            row["Adj Close"],
            row["Close"],
            row["High"],
            row["Low"],
            row["Open"],
            int(row["Volume"]),
            row["Ticker"]
        )
    )

# 5. Save changes
connection.commit()

print(f"{len(data)} rows inserted successfully!")

# 6. Close database connection
cursor.close()
connection.close()

print("Database connection closed.")