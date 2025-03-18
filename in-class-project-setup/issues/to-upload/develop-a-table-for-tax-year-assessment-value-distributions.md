---
title: "Develop a table for tax year assessment value distributions"
labels: ["Analysis", "Scripting"]
---

Dynamically populate (i.e. `CREATE OR REPLACE`) a table named `derived.tax_year_assessment_bins`. Imagine that the data in this table informs a distribution of the assessed values. The values should be divided into bins of some consistent widths either on a linear or logarithmic scale, and the number of properties with assessed values in each bin should be counted up. For example, it could look something like this:

![Image](https://user-images.githubusercontent.com/146749/229034786-9d8f5038-2f34-488d-9c9a-148fa3e37c7f.png)

The table should have the following columns:
* `tax_year` -- The year for which the tax assessment value applies
* `lower_bound` -- The minimum assessed value cutoff in the histogram bin
* `upper_bound` -- The maximum assessed value cutoff in the histogram bin
* `property_count` -- The number of properties that fall between that min and max value

Use the `source.opa_assessments` table to build this  table.

**Acceptance criteria:**
- [ ] A Cloud Function to run the `CREATE TABLE` SQL to generate the `derived.tax_year_assessment_bins` table. The actual SQL statement should be in its own _.sql_ file (e.g. `create_derived_tax_year_assessment_bins.sql`). See the `run_sql` task from the course_info as an example (https://github.com/Weitzman-MUSA-GeoCloud/course-info/tree/main/week08/explore_phila_data/run_sql)