---
title: "Create a task to run the current assessment value model"
labels: ["Data Science"]
---

The task should either be implemented using a Cloud Function (if the model is implemented in SQL or Python) or using a Cloud Run container (if the model is implemented in R or Python). The prediction values should be loaded into a BigQuery table named `derived.current_assessments`, and should have at least three columns:
* `property_id`
* `predicted_value`
* `predicted_date`