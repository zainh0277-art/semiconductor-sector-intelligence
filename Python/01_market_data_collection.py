import pandas as pd
import yfinance as yf

# Companies we want to analyze
tickers = ["NVDA", "AMD", "INTC", "AVGO", "QCOM"]

# Loop through every company
for ticker in tickers:

    print(f"\nDownloading {ticker}...")

    data = yf.download(
        ticker,
        start="2021-01-01",
        end="2026-01-01",
        interval="1d",
        auto_adjust=False,
        multi_level_index=False
    )

    # Check downloaded data
    print(f"{ticker} rows: {len(data)}")
    print(f"{ticker} missing values:")
    print(data.isnull().sum())

    # File path changes automatically for each ticker
    output_path = f"data/raw/market/{ticker}_prices.csv"

    # Save DataFrame
    data.to_csv(output_path)

    print(f"{ticker} saved successfully.")

print("\nAll market data downloaded successfully!")