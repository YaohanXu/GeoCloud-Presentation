---
title: "Create a task to run the current assessment value model"
labels: ["Scripting","Data Science"]
---

The task should either be implemented using a Cloud Function (if the model is implemented in SQL or Python) or using a Cloud Run container (if the model is implemented in R or Python).

The input training data should be prepared in a table named `derived.current_assessments_model_training_data`.

There are a few steps implicit in this task:
1. Download the training data from BigQuery (e.g. using the [`bq` command line tool](https://cloud.google.com/bigquery/docs/reference/bq-cli-reference#bq_extract) or using a client library for [R](https://cran.r-project.org/web/packages/bigrquery/index.html) or [Python](https://pypi.org/project/google-cloud-bigquery/))
2. Train the model using the training data
3. Use the trained model to predict the current assessment value of all (residential) properties in the `core.opa_properties` table (which you will also need to download from BigQuery)
4. Load the predictions back into BigQuery

The resulting prediction values should be loaded into a BigQuery table named `derived.current_assessments`, and should have at least three columns:
* `property_id` -- The OPA number of the property
* `predicted_value` -- The predicted current assessment value of the property
* `predicted_at` -- The date and time that the predicion was run. This will be the same for all properties in the table loaded on the same day/time, but notice that you could update this table every time you run predictions, thus keeping a history of how your predictions across the city change over time.

If you are using R for the model (or, in some cases, Python), you will need to create a Docker container that includes the model code and any dependencies. You can use the [rocker/tidyverse](https://hub.docker.com/r/rocker/tidyverse) image as a base image for R, and install any additional packages you need using `install.packages()`. In this case your _Dockerfile_ may look something like:

```docker
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim

RUN apt-get update

# Install GDAL for ogr2ogr
RUN apt-get install -y r-base r-base-dev r-cran-tidyverse

COPY install.R .
COPY train-and-predict.R .

# Pre-install the packages during build
RUN Rscript install.R

# Train and predict when starting the container
CMD [ "Rscript", "train-and-predict.R" ]
```

Refer to issue #6 for more information on running containers in Cloud Run.