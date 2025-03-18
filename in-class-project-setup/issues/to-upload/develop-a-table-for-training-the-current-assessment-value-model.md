---
title: "Develop a table for training the current assessment value model"
labels: ["Analysis","Data Science"]
---

In order to train a model to predict the current assessed value of a property, we need to have a table that contains the features and the target variable. The target variable is the last sale price of the property. The features are the variables that we believe are related to the sale price of the property.

**Acceptance criteria:**
- [ ] A Cloud Function to run the `CREATE TABLE` SQL to generate the `derived.current_assessments_model_training_data` table