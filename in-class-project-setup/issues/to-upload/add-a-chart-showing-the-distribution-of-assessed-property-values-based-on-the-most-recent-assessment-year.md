---
title: "Add a chart showing the distribution of assessed property values based on the most recent assessment year"
labels: ["Front-end"]
---

The chart will use the data in the `/configs/tax_year_assessment_bins.json` in the public bucket. You will have to decide how to best portray this distribution:
- If a histogram, how big should the bins be?
- Should you use a linear or logarithmic price scale?

You may have to experiment with visualizations of the existing data to make some of these decisions. Something like Looker from BigQuery could be useful for this.

Regarding the choice of technology, I recommend choosing a library such as [Apex Charts](https://apexcharts.com/) or [C3](https://c3js.org/), but the library is up to you.

**Acceptance criteria:**
- [ ] A bar chart or smoothed line chart showing the number of properties that fell into each of the price bins during the most recent tax assessment year.