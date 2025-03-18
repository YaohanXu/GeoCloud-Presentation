---
title: "Export a JSON file with map styling metadata"
labels: ["Analysis","Scripting","Front-end"]
---

For styling your vector tiles, whether you're using [MapLibreGL](https://maplibre.org/maplibre-gl-js/docs/#quickstart) directly to manage your map, or you're using a library like [Leaflet](https://leafletjs.com/) with a plugin like [maplibre-gl-leaflet](https://github.com/maplibre/maplibre-gl-leaflet), you'll need to know certain information like the range of sale prices, where to set breakpoints for color ramps to represent things like predicted sale values, last tax year assessment values, percent changes, absolute dollar changes, etc. This aggregated information won't be available in a convenient way in the vector tiles themselves, so we'll need to calculate it separately and export it to a JSON file.

The JSON file could be simple, like this:

```json
{
  "sale_prices": {
    "min": 10000,
    "max": 1000000,
    "breakpoints": [10000, 50000, 100000, 500000, 1000000]
  }
}
```

Or it could be more complex, with multiple properties and multiple types of properties.
