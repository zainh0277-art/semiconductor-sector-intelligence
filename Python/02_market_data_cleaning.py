import pandas as pd

tickers = ["NVDA", "AMD", "INTC", "AVGO", "QCOM"]

all_data = []

for ticker in tickers:

    file_path = f"data/raw/market/{ticker}_prices.csv"

    # Read CSV
    data = pd.read_csv(file_path)

    # Add company ticker
    data["Ticker"] = ticker

    # Convert Date into proper date type
    data["Date"] = pd.to_datetime(data["Date"])

    # Add this company's data to our list
    all_data.append(data)

# Combine all 5 DataFrames
market_data = pd.concat(all_data, ignore_index=True)

# Sort by company and date
market_data = market_data.sort_values(
    by=["Ticker", "Date"]
)

# Check dataset
print("\n--- DATASET SHAPE ---")
print(market_data.shape)

print("\n--- FIRST 5 ROWS ---")
print(market_data.head())

print("\n--- DATA TYPES ---")
print(market_data.dtypes)

print("\n--- MISSING VALUES ---")
print(market_data.isnull().sum())

print("\n--- DUPLICATE ROWS ---")
print(
    market_data.duplicated(
        subset=["Ticker", "Date"]
    ).sum()
)

# Save clean combined dataset
output_path = "data/cleaned/market_prices_clean.csv"

market_data.to_csv(
    output_path,
    index=False
)

print("\nClean market dataset saved:")
print(output_path)