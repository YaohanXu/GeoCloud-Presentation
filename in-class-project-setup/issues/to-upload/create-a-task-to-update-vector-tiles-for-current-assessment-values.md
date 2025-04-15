---
title: "Create a task to update vector tiles for current assessment values"
labels: ["Scripting","Analysis","Front-end"]
---

This can most easily be done with a [Cloud Run shell job](https://cloud.google.com/run/docs/quickstarts/jobs/build-create-shell) using `ogr2ogr`. In brief, there are three steps involved:

1. Download the `property_tile_info.geojson` data file from the `musa5090s25-team<N>-temp_data` bucket
2. Use `ogr2ogr` to convert the data into a folder of [Mapbox Vector Tile](https://github.com/mapbox/vector-tile-spec) (MVT) protobuf (.pbf) files.
3. Upload the resulting folder into a Google Cloud Storage bucket. The easiest way to do this may be to use the `gcloud` CLI.

You could instead implement these steps using all Python or Node in a Cloud Function, but it would be more trouble. More detail about the Cloud Run approach follows.

## What's Cloud Run?

Google Cloud Run allows you to specify instructions for installing your dependencies and running your program in a virtual machine on Google's infrastructure. A virtual machine into which your dependencies get pre-installed is called a "container" (or sometimes a "container image"). Cloud Run installs your dependencies according to your instructions into a container, and uses that container to run your program.

Google Cloud Functions is actually implemented on top of Google Cloud Run. In the case of Cloud Functions, Google has simply given you a choice of container building instructions ("runtimes") to choose from. For example, if you select the Python runtime and upload your code, Cloud Functions will build a container by installing everything in your requirements.txt file, and then run your `main.py` when the container starts up.

## Create a container for Cloud Run

For Cloud Run, we'll use a container definition script called a [Dockerfile](https://docs.docker.com/engine/reference/builder/#:~:text=A%20Dockerfile%20is%20a%20text,line%20to%20assemble%20an%20image.). The following Dockerfile will create a container that contains the dependencies mentioned above (GDAL for `ogr2ogr`, and the `gcloud` CLI):

```docker
# This Dockerfile is a mix of two documentation sources:
# https://cloud.google.com/run/docs/quickstarts/jobs/build-create-shell#writing
# https://cloud.google.com/run/docs/tutorials/gcloud#code-container

# ----------

# Use a gcloud image based on debian:buster-slim for a lean production container.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim

RUN apt-get update

# Install GDAL for ogr2ogr
RUN apt-get install -y gdal-bin

# Execute next commands in the directory /workspace
WORKDIR /workspace

# Copy over the script to the /workspace directory
COPY script.sh .

# Just in case the script doesn't have the executable bit set
RUN chmod +x ./script.sh

# Run the script when starting the container
CMD [ "./script.sh" ]
```

In the same folder as `Dockerfile`, create a file named `script.sh`. When the container is built, this script file will be copied in. The script should contain the following:

```bash
#!/usr/bin/env bash
set -ex

# Download the property_tile_info.geojson file from the temp bucket.
gcloud storage cp \
  gs://musa5090s25-team<N>-temp_data/property_tile_info.geojson \
  ./property_tile_info.geojson

# Convert the geojson file to a vector tileset in a folder named "properties".
# The tile set will be in the range of zoom levels 12-18. See the ogr2ogr docs
# at https://gdal.org/drivers/vector/mvt.html for more information.
ogr2ogr \
  -f MVT \
  -dsco MINZOOM=12 \
  -dsco MAXZOOM=18 \
  -dsco COMPRESS=NO \
  ./properties \
  ./property_tile_info.geojson

# Upload the vector tileset to the public bucket.
gcloud storage cp \
  --recursive \
  ./properties \
  gs://musa5090s25-team<N>-public/tiles
```

## Deploy the Cloud Run job

In order to deploy a script to Cloud Run, use the following command:

```bash
gcloud run jobs \
  deploy generate-property-map-tiles \
  --project musa5090s25-team<N> \
  --region us-east4 \
  --source . \
  --cpu 4 \
  --memory 2Gi
```

The first time you run this command, the `gcloud` tool will ask you a question like the following:

```
Deploying from source requires an Artifact Registry Docker repository to store built containers. A repository named [cloud-run-source-deploy] in region [us-east4] will be created.

Do you want to continue (Y/n)?
```

This is because your Dockerfile needs to be built into an image file, and that image needs to be stored somewhere (in GCP, this place where images are built and stored is called an "Artifact Registry"). Go ahead and answer `Y`.

## Testing the job

```bash
gcloud run jobs \
  execute generate-property-map-tiles \
  --project musa5090s25-team<N> \
  --region us-east4
```

If it's working correctly, it will take a while (like 15 minutes), but will complete by copying a bunch of tile files to GCS.

**Acceptance criteria:**
- [ ] A Cloud Run job named `generate-property-map-tiles` using the Dockerfile and script above
- [ ] The job should run successfully and copy a bunch of tile files to the public bucket
- [ ] The job should be scheduled to run as part of the data pipeline