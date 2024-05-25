---
title: Create a function to generate a geojson file for the vector tiles
tags: ["Analysis", "Scripting"]
---

The features in the GeoJSON should have the following properties:
* `property_id`: The unique identifier for each property (9-10 digit number corresponding to OPA `parcel_number` or the PWD `BRT_ID`).
* `address`: The address of the property.
* `tax_year_assessed_value`: The assessed value of the property according to the most recent tax year.
* `current_assessed_value`: The assessed value of the property according to the ML model.

## Acceptance Criteria:

- [ ] A function that generates a file in the `musa5090s24_team<N>_temp_data` bucket named `property_tile_info.geojson`. The geometries should come from the PWD parcels dataset, and the OPA assessment values should come from the OPA dataset, and the predicted property values should come from the model.
