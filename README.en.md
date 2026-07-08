# 📊 Brazilian Federal Public Spending Analysis — Portal da Transparência

🇧🇷 *[Leia este README em Português](README.md)*

## 📌 About the project

This project is an exploratory data analysis of Brazilian Federal Government public spending, using open data from the **Portal da Transparência** (Transparency Portal). The goal was to practice a complete data analysis pipeline — from extraction and cleaning (ETL) to business insight generation — using **SQL Server** as the main tool.

The project covers **May, June, and July 2026**.

## 🗂️ Data source

- **Source:** [Brazilian Federal Government Transparency Portal](https://portaldatransparencia.gov.br/download-de-dados)
- **Category:** Public Expenditures → Budget Execution
- **Original format:** CSV (semicolon-delimited `;`, text qualifier `"`, UTF-8 encoding)
- **Volume:** 148,832 records, combining the 3 months

## 🛠️ Tools used

- **SQL Server / SSMS** — data storage, cleaning, and analysis
- **Excel** — initial inspection of raw files
- *(In progress)* **Power BI** — interactive dashboard

## ⚙️ ETL Process (Extract, Transform, Load)

1. **Extraction:** manual download of monthly CSV files directly from the Transparency Portal
2. **Load:** import via SSMS's *Import Flat File* tool, generating one "raw" table per month with the original 47 columns
3. **Transformation:** main challenges solved:
   - Column type adjustments (`nvarchar(50)` → `nvarchar(255)`) to prevent truncation on long text fields (program names, budget actions)
   - Allowing null values in columns that had empty cells in the original CSV
   - Correctly identifying the source file's delimiter (`;`) and text qualifier (`"`)
4. **Consolidation:** unifying the 3 monthly raw tables into a single clean, lean table (`despesas_publicas`), keeping only relevant columns, via `INSERT INTO ... UNION ALL`

## 🗃️ Final data model

**Table: `despesas_publicas`**

| Column | Description |
|---|---|
| AnoMes | Reference year/month of the entry |
| NomeOrgaoSuperior | Ministry / parent agency |
| NomeOrgao | Specific agency or managing unit |
| NomeFuncao | Government function (Education, Health, Defense, etc.) |
| NomeSubfuncao | Budget sub-function |
| NomePrograma | Budget program |
| NomeAcao | Budget action |
| UF | Destination state (can be null) |
| NomeLocal | Destination municipality |
| ValorEmpenhado | Committed value in the period |
| ValorLiquidado | Verified/liquidated value in the period |
| ValorPago | Value actually paid in the period |

## ❓ Business questions answered

**1. Which parent agencies have the highest budget execution?**
The Ministry of Finance leads in total value (R$49.1B committed) but with few entries (1,909) — suggesting a small number of very high-value entries. The Ministry of Education has the highest entry count (43,146), reflecting its widespread network of federal universities and institutes.

**2. How does spending evolve across the 3 months analyzed?**
July shows the lowest committed value but the highest paid value — a reflection of data being collected early in the month (partial monthly execution).

**3. What percentage of committed value was actually paid?**
Some agencies show rates above 100%, since the paid value in the period includes settlement of *Restos a Pagar* (carried-over obligations) from prior fiscal years — an important limitation of the 3-month window (see Limitations section).

**4. Are there agencies where paid value exceeds committed value?**
Yes, 197 agency combinations show this pattern, including extreme cases such as negative committed value (reversals) — e.g., the Federal Highway Police, with a net commitment of -R$68.2B in the period.

**5. Which government functions receive the most resources?**
"Special Charges" leads by far (R$53.7T), but it's a financial/accounting category (public debt, constitutional transfers), not a specific public policy. Excluding it, **Social Security** (R$16.6T) leads, followed by Health (R$5.1T).

**6. Within a specific function, which programs receive the most resources?**
Within Health, Specialized Care and Primary Care programs concentrate most resources, totaling over R$4 trillion.

**7. Which states (UF) receive the most federal resources?**
The Federal District leads, followed by SP, MG, RJ, and RS — reflecting the concentration of central administrative agencies in Brasília.

**8. What proportion of spending has no associated state?**
**94.09%** of the total committed value has no associated UF — the geographic analysis (question 7) represents only a small fraction (~6%) of the total budget, mostly composed of nationwide/central administrative expenses.

**9. Which agency spends the most within a specific function (e.g., Education)?**
The National Fund for Education Development (FNDE) leads by a wide margin (R$311.8B), followed by federal higher education institutions.

## ⚠️ Identified limitations

- **Short time window (3 months):** budget execution metrics (% paid vs. committed) can exceed 100% or be negative, since paid/reversed values in the period may refer to obligations from prior fiscal years, outside the analyzed window.
- **Apparent geographic concentration:** 94% of the budget has no associated UF, which strongly limits any geographic distribution analysis.
- **Partial July data:** this month's data was collected early in the period, so July's budget execution is understated relative to May and June.

## 📊 Next steps

- Build an interactive **Power BI** dashboard, with DAX measures for the metrics already validated in SQL
- Study *window functions* (`ROW_NUMBER()`, `PARTITION BY`) to generalize question 9 (top agency per function, for all functions at once)
- Expand the time window (incorporate more months) to reduce the distortions identified in the limitations

## 📁 Repository structure

```
public-spending-project/
├── README.md                    <- Portuguese version
├── README.en.md                 <- this file
├── sql/
│   ├── 01_setup_e_importacao.sql
│   └── 02_queries_analise.sql
└── powerbi/                     <- (coming soon)
```

---

*Project developed as part of a data analysis portfolio, applying SQL Server to real public data.*
