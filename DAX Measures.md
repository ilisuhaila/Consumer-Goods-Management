# [DAX] Optimizing Manufacturing Efficiency

#### Gross_Sales_mln
        = ROUND(
            (SUMX( fact_sales_monthly, 
            fact_sales_monthly[sold_quantity] * 
            CALCULATE( SUM( fact_gross_price[gross_price]), 
                FILTER( fact_gross_price, 
                fact_gross_price[fiscal_year] = fact_sales_monthly[fiscal_year] && 
                fact_gross_price[product_code] = fact_sales_monthly[product_code] )))
          /1000000),2)

#### Gross Sales Amount
        = SUMX( 
          fact_sales_monthly, fact_sales_monthly[sold_quantity] * 
          CALCULATE( SUM( fact_gross_price[gross_price]), 
              FILTER( fact_gross_price, fact_gross_price[fiscal_year] = fact_sales_monthly[fiscal_year] && 
              fact_gross_price[product_code] = fact_sales_monthly[product_code] )))

#### yearly_gross_sales
        =ROUND( SUMX( fact_gross_price,
		         fact_gross_price[gross_price] *
		         CALCULATE( SUM(fact_sales_monthly[sold_quantity]),
                 FILTER(fact_sales_monthly,
                 fact_sales_monthly[fiscal_year] = fact_gross_price[fiscal_year] &&
                 fact_sales_monthly[product_code] = fact_gross_price[product_code] )))
	       / 1000000, 2)

#### Unique_Products_2020
        = CALCULATE( 
            DISTINCTCOUNT( fact_sales_monthly[product_code]),
            fact_sales_monthly[fiscal_year] = 2020)

#### Unique_Products_2021
        = CALCULATE( 
            DISTINCTCOUNT( fact_sales_monthly[product_code]),
            fact_sales_monthly[fiscal_year] = 2021)

#### percentage_chg
        = DIVIDE([Unique_Products_2021] - [Unique_Products_2020], [Unique_Products_2020]) * 100

#### Difference
        = [Unique_Products_2021] - [Unique_Products_2020]
