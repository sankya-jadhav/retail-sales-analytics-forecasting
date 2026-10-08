import pandas as pd
import mysql.connector


# -----------------------------
# 1. Read CSV
# -----------------------------

file_path = "data/50000 Sales Records.csv"

df = pd.read_csv(file_path)

print("Dataset shape:", df.shape)
print(df.head())


# -----------------------------
# 2. Clean column names
# -----------------------------

df.columns = df.columns.str.strip()


# -----------------------------
# 3. Clean text columns
# -----------------------------

df["Country"] = df["Country"].str.strip()

df["Region"] = df["Region"].str.strip()

df["Item Type"] = df["Item Type"].str.strip()

df["Sales Channel"] = df["Sales Channel"].str.strip()

df["Order Priority"] = df["Order Priority"].str.strip()


# -----------------------------
# 4. Convert dates
# -----------------------------

df["Order Date"] = pd.to_datetime(df["Order Date"])

df["Ship Date"] = pd.to_datetime(df["Ship Date"])


# -----------------------------
# 7. Create dimension datasets
# -----------------------------

# Product dimension
dim_product = (
    df[["Item Type"]]
    .drop_duplicates()
    .sort_values("Item Type")
    .reset_index(drop=True)
)

print("\nProducts:")
print(dim_product)


# Geography dimension
dim_geography = (
    df[["Country", "Region"]]
    .drop_duplicates()
    .sort_values("Country")
    .reset_index(drop=True)
)

print("\nGeography:")
print(dim_geography.head())


# Sales Channel dimension
dim_sales_channel = (
    df[["Sales Channel"]]
    .drop_duplicates()
    .sort_values("Sales Channel")
    .reset_index(drop=True)
)

print("\nSales Channels:")
print(dim_sales_channel)


# Priority dimension
dim_priority = (
    df[["Order Priority"]]
    .drop_duplicates()
    .sort_values("Order Priority")
    .reset_index(drop=True)
)

print("\nPriorities:")
print(dim_priority)

# -----------------------------
# Date dimension
# -----------------------------

min_date = min(df["Order Date"].min(), df["Ship Date"].min())
max_date = max(df["Order Date"].max(), df["Ship Date"].max())

date_range = pd.date_range(
    start=min_date,
    end=max_date,
    freq="D"
)

dim_date = pd.DataFrame({
    "full_date": date_range
})

dim_date["date_id"] = (
    dim_date["full_date"].dt.strftime("%Y%m%d").astype(int)
)

dim_date["day"] = dim_date["full_date"].dt.day

dim_date["month"] = dim_date["full_date"].dt.month

dim_date["month_name"] = dim_date["full_date"].dt.month_name()

dim_date["quarter"] = dim_date["full_date"].dt.quarter

dim_date["year"] = dim_date["full_date"].dt.year

dim_date = dim_date[
    [
        "date_id",
        "full_date",
        "day",
        "month",
        "month_name",
        "quarter",
        "year"
    ]
]

print("\nDate dimension:")
print(dim_date.head())

print("\nDate dimension shape:", dim_date.shape)


# -----------------------------
# 5. Connect to MySQL
# -----------------------------

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Root@123",
    database="retail_sales_analytics"
)

cursor = conn.cursor()

print("MySQL connection successful!")

# # -----------------------------
# # 8. Insert dimension data
# # -----------------------------

# cursor = conn.cursor()


# # Product dimension
# product_query = """
#     INSERT INTO dim_product (item_type)
#     VALUES (%s)
# """

# for item_type in dim_product["Item Type"]:
#     cursor.execute(product_query, (item_type,))


# # Geography dimension
# geography_query = """
#     INSERT INTO dim_geography (country, region)
#     VALUES (%s, %s)
# """

# for _, row in dim_geography.iterrows():
#     cursor.execute(
#         geography_query,
#         (row["Country"], row["Region"])
#     )


# # Sales channel dimension
# channel_query = """
#     INSERT INTO dim_sales_channel (sales_channel)
#     VALUES (%s)
# """

# for channel in dim_sales_channel["Sales Channel"]:
#     cursor.execute(channel_query, (channel,))


# # Priority dimension
# priority_query = """
#     INSERT INTO dim_priority (priority_code)
#     VALUES (%s)
# """

# for priority in dim_priority["Order Priority"]:
#     cursor.execute(priority_query, (priority,))


# # Date dimension
# date_query = """
#     INSERT INTO dim_date (
#         date_id,
#         full_date,
#         day,
#         month,
#         month_name,
#         quarter,
#         year
#     )
#     VALUES (%s, %s, %s, %s, %s, %s, %s)
# """

# for _, row in dim_date.iterrows():
#     cursor.execute(
#         date_query,
#         (
#             row["date_id"],
#             row["full_date"].date(),
#             row["day"],
#             row["month"],
#             row["month_name"],
#             row["quarter"],
#             row["year"]
#         )
#     )


# conn.commit()

# print("Dimension tables loaded successfully!")


# -----------------------------
# 9. Create ID mappings
# -----------------------------

df["order_date_id"] = (
    df["Order Date"]
    .dt.strftime("%Y%m%d")
    .astype(int)
)

df["ship_date_id"] = (
    df["Ship Date"]
    .dt.strftime("%Y%m%d")
    .astype(int)
)

# Product mapping
cursor.execute("""
    SELECT product_id, item_type
    FROM dim_product
""")

product_map = {
    item_type: product_id
    for product_id, item_type in cursor.fetchall()
}


# Geography mapping
cursor.execute("""
    SELECT geography_id, country
    FROM dim_geography
""")

geography_map = {
    country: geography_id
    for geography_id, country in cursor.fetchall()
}


# Sales channel mapping
cursor.execute("""
    SELECT sales_channel_id, sales_channel
    FROM dim_sales_channel
""")

channel_map = {
    sales_channel: sales_channel_id
    for sales_channel_id, sales_channel in cursor.fetchall()
}


# Priority mapping
cursor.execute("""
    SELECT priority_id, priority_code
    FROM dim_priority
""")

priority_map = {
    priority_code: priority_id
    for priority_id, priority_code in cursor.fetchall()
}


# -----------------------------
# 10. Map dimension IDs
# -----------------------------

df["product_id"] = df["Item Type"].map(product_map)

df["geography_id"] = df["Country"].map(geography_map)

df["sales_channel_id"] = df["Sales Channel"].map(channel_map)

df["priority_id"] = df["Order Priority"].map(priority_map)


print(
    df[
        [
            "Item Type",
            "product_id",
            "Country",
            "geography_id",
            "Sales Channel",
            "sales_channel_id",
            "Order Priority",
            "priority_id",
            "order_date_id",
            "ship_date_id"
        ]
    ].head()
)


print("\nMissing product IDs:", df["product_id"].isna().sum())

print("Missing geography IDs:", df["geography_id"].isna().sum())

print("Missing channel IDs:", df["sales_channel_id"].isna().sum())

print("Missing priority IDs:", df["priority_id"].isna().sum())

print("Missing order date IDs:", df["order_date_id"].isna().sum())

print("Missing ship date IDs:", df["ship_date_id"].isna().sum())




# -----------------------------
# 11. Prepare fact table data
# -----------------------------

fact_data = df[
    [
        "Order ID",
        "order_date_id",
        "ship_date_id",
        "product_id",
        "geography_id",
        "sales_channel_id",
        "priority_id",
        "Units Sold",
        "Unit Price",
        "Unit Cost",
        "Total Revenue",
        "Total Cost",
        "Total Profit"
    ]
].copy()


fact_data.columns = [
    "order_id",
    "order_date_id",
    "ship_date_id",
    "product_id",
    "geography_id",
    "sales_channel_id",
    "priority_id",
    "units_sold",
    "unit_price",
    "unit_cost",
    "total_revenue",
    "total_cost",
    "total_profit"
]


print("\nFact data:")
print(fact_data.head())

print("\nFact data shape:", fact_data.shape)



# -----------------------------
# 12. Load fact_sales
# -----------------------------

fact_query = """
    INSERT IGNORE INTO fact_sales (
        order_id,
        order_date_id,
        ship_date_id,
        product_id,
        geography_id,
        sales_channel_id,
        priority_id,
        units_sold,
        unit_price,
        unit_cost,
        total_revenue,
        total_cost,
        total_profit
    )
    VALUES (
        %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s
    )
"""

data_to_insert = [
    tuple(row)
    for row in fact_data.itertuples(index=False, name=None)
]

cursor.executemany(
    fact_query,
    data_to_insert
)

conn.commit()

print("Fact table loaded successfully!")
print("Rows inserted:", cursor.rowcount)


# -----------------------------
# 13. Validate fact table
# -----------------------------

cursor.execute("SELECT COUNT(*) FROM fact_sales")

fact_count = cursor.fetchone()[0]

print("Rows in fact_sales:", fact_count)


# -----------------------------
# 14. Close connection
# -----------------------------

cursor.close()
conn.close()

print("ETL completed successfully!")