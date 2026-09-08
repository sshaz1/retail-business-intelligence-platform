# Retail Business Intelligence & Analytics Platform

## Overview

An end-to-end business intelligence and analytics project designed to transform raw retail data into actionable business insights using Python, SQL, dimensional data modelling, and Power BI.

The project will cover the complete analytics lifecycle, including data exploration, data cleaning, database design, analytical modelling, business intelligence development, and process automation.

## Project Objectives

- Analyze retail sales, customer, and product performance
- Build a reproducible data preparation pipeline using Python
- Design an analytical data model using dimensional modelling principles
- Perform business analysis using SQL
- Develop interactive dashboards using Power BI
- Define and calculate business KPIs using DAX
- Automate reporting processes using Microsoft Power Automate

## Dataset

This project uses the **Brazilian E-Commerce Public Dataset by Olist**, a public e-commerce dataset containing approximately 100,000 anonymized orders placed in Brazil between 2016 and 2018.

The dataset contains multiple related files covering customers, orders, order items, products, sellers, payments, reviews, and geographic information. This relational structure is used throughout the project to demonstrate data preparation, SQL development, data modelling, and business intelligence concepts.

### Data Source

The dataset is available publicly on Kaggle:

**Brazilian E-Commerce Public Dataset by Olist**  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The original dataset is not included in this repository. This keeps the repository focused on the project's code, analytical models, documentation, and outputs while maintaining the original dataset separately.

### Dataset Setup

To reproduce the project:

1. Download the Brazilian E-Commerce Public Dataset by Olist from Kaggle.
2. Extract the downloaded archive.
3. Place the following files inside the `data/raw/` directory:

```text
data/raw/
├── olist_customers_dataset.csv
├── olist_geolocation_dataset.csv
├── olist_order_items_dataset.csv
├── olist_order_payments_dataset.csv
├── olist_order_reviews_dataset.csv
├── olist_orders_dataset.csv
├── olist_products_dataset.csv
├── olist_sellers_dataset.csv
└── product_category_name_translation.csv
```

## Technologies

- Python
- Pandas
- SQL
- Power BI
- DAX
- Power Query
- Git / GitHub

Additional technologies will be added as the project develops.

## Project Architecture

Architecture documentation will be added as the project progresses.

## Repository Structure

```text
data/          Raw and processed datasets
notebooks/     Exploratory data analysis
python/        Data cleaning and transformation scripts
sql/           Database schema and analytical SQL
powerbi/       Power BI reports
automation/    Process automation components
docs/          Project documentation
screenshots/   Dashboard and project screenshots
