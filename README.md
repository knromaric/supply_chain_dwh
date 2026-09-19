# Supply Chain Analytics Platform (dbt + Databricks + Power BI)

An end-to-end supply chain data warehouse and executive dashboard — raw operational data from suppliers, production, inventory, logistics, and sales forecasting consolidated into a single governed warehouse with **dbt on Databricks**, and surfaced to leadership through a **Power BI executive dashboard**.

## Problem Statement

Supply chain data was fragmented across separate operational feeds — purchasing, production, warehousing, shipping, forecasting — with no consistent way to see the whole picture. Leadership needed a single warehouse that could answer:

- Are we forecasting demand accurately, and where is the bias?
- Which suppliers deliver on time, and which consistently cause delays?
- Where is inventory running low and at risk of a stockout?
- How much production downtime are we losing, and why?
- What's driving logistics cost across transport modes?

## Data Domain

Seven source feeds, modeled into a star schema:

| Source | Description |
|---|---|
| `suppliers` | Supplier ID, name, location, rating |
| `purchase_orders` | Order date, SKU, supplier, quantity, promised vs. actual delivery date |
| `logistics` | Shipment ID, linked purchase order, transport mode, cost, transit delay |
| `production` | Production date, SKU, output quantity, downtime hours/reason |
| `inventory` | SKU, warehouse, supplier, current stock vs. reorder level |
| `sales_forecast` | Date, SKU, historical vs. forecasted demand |
| `calendar` | Date dimension (year, quarter, month, week, day of week) |

## Architecture: Medallion on Databricks

```
Source tables (Unity Catalog)
   │  dbt source()
   ▼
🥉 Bronze   — 1:1 pass-through of each source table, no transformation
   │
   ▼
🥈 Silver   — cleaned, typed, and enriched with derived business metrics
   │
   ▼
🥇 Gold     — star schema: 5 fact tables + 4 dimensions, joined and business-ready
   │
   ▼
📊 Power BI — executive dashboard on top of the Gold layer
```

<img src="https://github.com/knromaric/supply_chain_dwh/blob/main/resources/supply_chain_architecture.png" width=1000>


**Key metrics computed in the Silver layer**:

| Model | Derived Metric |
|---|---|
| `silver_sales_forecast` | `forecast_bias` (forecasted − historical demand), `forecast_accuracy` (%) |
| `silver_purchase_orders` | `lead_time_days` (order → actual delivery), `delivery_delay_days` (actual vs. promised) |
| `silver_inventory` | `inventory_status` (`Reorder` vs. `Sufficient`, from current stock vs. reorder level) |
| `silver_production` | Downtime hours and reason, with nulls coalesced to `'No Downtime'` |

## Gold Layer (Star Schema)

**Fact tables:**
- `fact_purchase_orders` — one row per PO, enriched with supplier name, location, and rating
- `fact_logistics` — one row per shipment, enriched with the supplier and SKU from its linked PO
- `fact_production` — one row per production run, enriched with calendar attributes (year/month/week)
- `fact_inventory` — current stock position and reorder status by SKU/warehouse/supplier
- `fact_sales_forecast` — demand forecast accuracy and bias by SKU/date

**Dimensions:**
- `dim_suppliers`, `dim_calendar`, `dim_product`, `dim_warehouse`

<img src="https://github.com/knromaric/supply_chain_dwh/blob/main/resources/sc_data_modeling.png" width=1000>

## Tech Stack

| Layer | Tool |
|---|---|
| Transformation | dbt-core, dbt-databricks adapter |
| Storage / Compute | Databricks (Unity Catalog sources, SQL Warehouse) |
| Modeling pattern | Medallion architecture (Bronze → Silver → Gold), star schema in Gold |
| Reporting | Power BI (`Supply Chain Executive Dashboard.pbix`) connected to the Gold layer |

## Repository Structure

```
supply_chain_dbt_dwh/
├── dbt_project.yml
├── models/
│   ├── sources/            # sources.yml — declares the 7 upstream tables
│   ├── bronze/              # 1:1 views over each source
│   ├── silver/                # cleaned + derived metrics
│   └── gold/                   # fact & dimension models (star schema)
├── macros/
└── analyses/
raw_data/                          # sample CSVs used to seed the source tables
supply_chain_executive_dashboard/
└── Supply Chain Executive Dashboard.pbix
```

## Running Locally

```bash
cd supply_chain_dbt_dwh
dbt deps
dbt run
```

(Source tables are already loaded in the `supply_chain_db.supply_chain_schema` catalog/schema — see `models/sources/sources.yml` using raw csv files)

## Executive Dashboard

`Supply Chain Executive Dashboard.pbix` connects directly to the Gold layer and gives leadership one screen to slice and monitor supply chain performance.

**Filters:** SKU · Year · Supplier Name

**KPI cards:**
| Card | What it tracks |
|---|---|
| Total Logistics Cost | Overall shipment spend |
| Total Downtime Hours | Production time lost |
| Total Orders | Purchase order volume |
| Average Delivery Delay (days) | How late deliveries run on average |

**Trend charts (line):**
- Total Orders by Year — order volume trend
- Forecasted vs. Historical Demand by Year — how closely demand planning tracks reality

**Comparison charts (bar):**
- Total Downtime Hours by Downtime Reason — where production time is actually being lost
- Average Delivery Delay by Supplier — which suppliers run late, and by how much

**Detail table:** Supplier Name · Average Delivery Delay (days) · Total Orders — a sortable, supplier-level scorecard for procurement conversations

Every one of these is a direct, unaggregated pull from the Gold fact/dimension tables (`fact_purchase_orders`, `fact_logistics`, `fact_production`, `fact_sales_forecast`, `dim_suppliers`, `dim_calendar`) — no additional logic is computed inside Power BI itself.   


<img src="https://github.com/knromaric/supply_chain_dwh/blob/main/resources/sc_executive_dashboard.png" width=1000>     


## What This Demonstrates

- Consolidating a fragmented, multi-source operational domain (purchasing, production, warehousing, logistics, forecasting) into one governed warehouse
- Deriving real business KPIs in SQL/dbt (forecast accuracy, lead time, delivery delay, reorder status) rather than leaving that logic to the BI layer
- Star-schema design: multiple fact tables at their own natural grain, joined to shared dimensions
- Medallion architecture on Databricks, from raw source to BI-ready Gold tables
- Connecting a governed warehouse directly to Power BI for executive reporting
- Designing an executive-level dashboard around a small set of decision-driving KPIs (cost, downtime, delay, volume) rather than dumping every available metric on the page

## Possible Next Steps

- Add dbt schema/data tests (`not_null`, `unique`, `relationships`, plus custom checks like non-negative stock or valid delivery dates)
- Incremental materialization on the larger fact tables instead of full-refresh views

