---
title: "Develop a table for current assessment value distributions"
labels: ["Analysis"]
---

Create a table `derived.current_assessment_bins`. Imagine that the data in this table informs a histogram of the assessed values. This is similar to Issue #8, except only for the current values as calculated by the valuation model.

The table should have the following columns:
* `lower_bound` -- The minimum assessed value cutoff in the histogram bin
* `upper_bound` -- The maximum assessed value cutoff in the histogram bin
* `property_count` -- The number of properties that fall between that min and max value

Use the `derived.current_assessments` table to build this `derived.current_assessment_bins` table.

**Acceptance criteria:**
- [ ] A Cloud Function to run the `CREATE TABLE` SQL to generate the `derived.current_assessment_bins` table