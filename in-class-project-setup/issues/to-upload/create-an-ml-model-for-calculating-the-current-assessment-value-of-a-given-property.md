---
title: "Create an ML model for predicting the current market value of a given property"
labels: ["Data Science"]
---

The model can be implemented in BigQuery SQL, or in R/Python.
* The model should attempt to predict the `sale_price` of a property. Note that the `opa_properties` table also has a `market_value` field, which is the OPA's estimate of the property's market value, and is not the same as the `sale_price` field, which is the actual price that the property commanded on the market. The model should use the `sale_price` field as the target, not the `market_value` field.
* Keep in mind that the `sale_price` represents how much the property was last sold for, and the `sale_date` represents the date of the last sale. You probably want to take both into account, as properties that were sold more recently are likely to have a stronger signal for what the current value of other properties is.
* Some properties have a very low sale price, like $1. These are likely properties that were transferred between family members. You may want to exclude these properties from your model, as they are not representative of the market value of the property.
* Some properties are sold as part of a bundle of properties. These are likely to have a lower sale price per property than properties that are sold individually. You may want to exclude these properties from your model, as they are not representative of the market value of the property. You can identify these properties by looking at the `sale_price` and `sale_date` fields of the `opa_properties` table. Properties sold on the exact same day with the exact same sale price are likely to be part of a bundle (the `sale_price` value of the properties is going to represent the price of the entire bundle, not the price of any individual property).
* For implementing a model in BigQuery, refer to the [BigQuery ML docs](https://cloud.google.com/bigquery-ml/docs/introduction)
* For using R/Python to run your model in the cloud, we'll need [Google Cloud Run](https://cloud.google.com/run/docs/quickstarts); if the model is in Python, you can use a Python container, however for an R-based model you would need to use a shell container and install any necessary packages. The shell container will run Ubuntu Linux; this [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-22-04) explains the steps to install R on Ubuntu. _Let Mjumbe know if this is the route you are going to pursue._

**Acceptance criteria:**
- [ ] A model that predicts the `sale_price` of a property
