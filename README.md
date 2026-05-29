# 📊 Sales & Profitability Analytics Dashboard

### End-to-end analytics project using MySQL and Power BI
**Report Period: 2022 – 2025**

---

## 🔍 Project Overview
This project analyzes **$2.3M in revenue** across **5,009 orders** 
from 2022 to 2025 using a complete data analytics workflow — 
from raw data cleaning in MySQL to an interactive 7-page 
Power BI dashboard covering sales performance, product 
profitability, customer segments, and fulfillment operations.

---

## 🛠️ Tools & Technologies
| Tool | Purpose |
|---|---|
| MySQL | Data cleaning, validation, star schema design |
| Power BI | 7-page interactive dashboard |
| DAX | Custom measures and KPI calculations |
| Dataset | Superstore Sales Dataset (Kaggle) |

---

## 📁 Repository Structure
├── Sales_Analytics_queries_Final.sql  → MySQL queries
├── SalesAnalytics.pbix                → Power BI dashboard
├── Sales_data.csv                     → Raw dataset
└── Screenshots/                       → Dashboard images
---

## 📊 Dashboard Pages

| Page | Title | Description |
|---|---|---|
| 1 | Executive Overview | KPIs, revenue trend, regional and segment performance |
| 2 | Product Intelligence | Category analysis, loss exposure, discount impact |
| 3 | Customer & Segment Intelligence | Segment trends, revenue growth, discount behavior |
| 4 | Fulfillment & Customer Trends | Shipment analysis, late delivery, critical insights |
| 5 | Monthly Trend | MoM performance, profit and loss distribution |
| 6 | Product Deep Dive | Sub-category profitability and contribution analysis |
| 7 | Loss Analysis | Loss-making products, discount risk matrix |

---

## 💡 Key Business Insights

- 📈 **Technology** is the best margin category at **17.4%**
- ⚠️ **40.92%** of products are loss-making, driven by Binders and Tables
- 🏆 **Home Office** is the fastest growing segment at **51.53% YoY growth**
- 🚨 Late shipment rate is critically high at **57.40%**
- 💸 High discounts above **30%** consistently drive negative profit margins
- 🌍 **West region** leads in total sales at **$250K**
- 📉 Profit margins are **declining YoY** despite growing revenue

---

## 🗄️ Database Design — Star Schema
sales_fact (central fact table)
├── product_dim    → product, category, sub-category
├── customer_dim   → customer details and segment
├── date_dim       → full date hierarchy
├── region_dim     → country, state, city, region
└── ship_mode_dim  → shipping method
---

## 📸 Dashboard Screenshots

### Executive Overview
![Executive Overview](Screenshots/01_Executive_Overview.png)

### Product Intelligence
![Product Intelligence](Screenshots/02_Product_Intelligence.png)

### Customer & Segment Intelligence
![Customer & Segment](Screenshots/03_Customer_Segment.png)

### Fulfillment & Customer Trends
![Fulfillment](Screenshots/04_Fulfillment.png)

### Monthly Trend
![Monthly Trend](Screenshots/05_Monthly_Trend.png)

### Product Deep Dive
![Product Deep Dive](Screenshots/06_Product_Deep_Dive.png)

### Loss Analysis
![Loss Analysis](Screenshots/07_Loss_Analysis.png)

---

## ⚙️ How to Use This Project

1. **SQL** → Open `Sales_Analytics_queries_Final.sql` 
   in MySQL Workbench and run queries in order
2. **Power BI** → Download `SalesAnalytics.pbix` 
   and open in Power BI Desktop
3. **Data** → `Sales_data.csv` is the raw source data

---

## 👤 Author
**Indumathi Thiruvenkadam**
indumathi1305@gmail.com
(https://github.com/Indumathi96)
