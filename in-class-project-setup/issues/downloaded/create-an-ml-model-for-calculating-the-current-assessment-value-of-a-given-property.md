---
title: "Create an ML model for calculating the current assessment value of a given property"
labels: ["Data Science"]
---

The model can be implemented in BigQuery SQL, or in R/Python.
* For implementing a model in BigQuery, refer to the [BigQuery ML docs](https://cloud.google.com/bigquery-ml/docs/introduction)
* For using R/Python to run your model in the cloud, we'll need [Google Cloud Run](https://cloud.google.com/run/docs/quickstarts); if the model is in Python, you can use a Python container, however for an R-based model you would need to use a shell container and install any necessary packages. The shell container will run Ubuntu Linux; this [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-22-04) explains the steps to install R on Ubuntu. _Let Mjumbe know if this is the route you are going to pursue._