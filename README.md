## Business Goals

The SaaS company aims to improve conversion, retention, and long-term customer value while supporting future product growth strategies.

However, the business lacks clear visibility into customer engagement and drop-off behavior across the subscription journey, making it difficult to optimize onboarding and retention efforts.

This project applies funnel analysis, cohort retention analysis, and customer lifetime value (CLV) analysis to identify conversion bottlenecks, retention trends, and high-value customer segments that can support product and business decision-making.

---

## Executive Summary

The analysis showed major user drop-off during onboarding and payment stages, while retention decreased noticeably between Month 3 and Month 7, suggesting a key churn period in the customer lifecycle.

Organic Search and LinkedIn Ads brought in higher-value users with stronger conversion and CLV performance, while Enterprise customers generated the highest long-term customer value.

The results suggest opportunities to simplify onboarding and payment flows, improve engagement during the M3–M7 period, and invest more in high-performing acquisition channels and Enterprise customer growth.

---

## Dataset Structure

The dataset includes customer, subscription, revenue, and event-level tables used to analyze user behavior across the SaaS subscription lifecycle.

<img width="1055" height="496" alt="Screenshot 2026-05-16 at 3 22 59 PM" src="https://github.com/user-attachments/assets/ac01dad2-235f-4bc0-a29d-51e0add371e4" />


---

# Funnel Analysis
<img width="905" height="527" alt="Screenshot 2026-05-18 at 2 26 37 PM" src="https://github.com/user-attachments/assets/b68e70e5-4aa2-446d-a3eb-b8ab9f6b46a6" />


### Funnel Analysis Insights

- Overall conversion from homepage visit to paid subscription was only **2.58%**
- The largest drop-off occurred before users reached the pricing page (**64.31% drop-off**)
- Another major bottleneck appeared during the payment stage, where **65.92%** of trial users did not add payment information
- The results suggest opportunities to improve onboarding, pricing page engagement, and payment-stage user experience

---

# Cohort / Retention Analysis
<img width="1456" height="790" alt="download" src="https://github.com/user-attachments/assets/ab2b33c8-41cf-465a-8ab8-a2f084279acb" />


### Cohort Retention Insights
- Earlier 2024 cohorts showed stronger long-term retention compared to newer 2025 cohorts
- Retention for many cohorts dropped below 50% between Month 3 and Month 7, indicating a key churn period in the customer lifecycle

---

# CLV Analysis

<p align="center">
  <img width="435" height="215" alt="image" src="https://github.com/user-attachments/assets/b1a905ba-7bfa-4010-8d2e-ec79a3bcec24" />
  <img width="361" height="218" alt="image" src="https://github.com/user-attachments/assets/53078c58-ad8d-4881-ab3a-bbd505b0cd5b" />
</p>

### CLV Insights

- Enterprise customers generated the highest average CLV (**$2,729**) despite higher acquisition costs
- LinkedIn Ads generated the highest average CLV by acquisition channel (**$1,714**), followed by Organic Search (**$1,471**)
- Google Ads generated the lowest average CLV among acquisition channels (**$960**)

---

# Recommendations

- **Onboarding Optimization:** Simplify onboarding and pricing page flows to reduce drop-off before signup and payment stages
- **Retention Strategy:** Introduce engagement emails or renewal reminders during the Month 3–Month 7 churn period
- **Acquisition Channels:** Invest more in Organic Search and LinkedIn Ads, which showed stronger conversion and higher CLV
- **Enterprise Growth:** Prioritize Enterprise customer acquisition and retention, as Enterprise users generated the highest average CLV
- **Google Ads Optimization:** Reevaluate Google Ads targeting, as it generated the lowest average CLV among acquisition channels

---

# Technical Highlights

SQL was used to clean, transform, and aggregate SaaS customer event data for funnel, retention, and CLV analysis. Subqueries, CTEs, and window functions were used to analyze user behavior across different stages of the subscription lifecycle.

Python was used for cohort retention analysis and retention heatmap visualization to identify customer engagement and churn trends over time.

---
