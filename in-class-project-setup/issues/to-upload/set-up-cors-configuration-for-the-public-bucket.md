---
title: Set up CORS configuration for the public bucket
labels: ["Front-end", "Scripting"]
---

In order to be able to access the files in the public bucket (`musa5090s25-team<N>-public`) from the web application, the bucket has to be publicly accessible, and it has to have a CORS configuration that allows the web application to access the files. You must [use the `gcloud` command line](https://cloud.google.com/storage/docs/cors-configurations) to set the CORS configuration for a bucket. In your configuration, you probably want to set the `origin` to `["*"]`, as that will allow access to the files from wherever you need them. See https://gist.github.com/pjbelo/a38da9a69b4b6cefc3b1434a5cb8c7f4 for a permissive configuration that is more than sufficient.

**Acceptance criteria:**
- [ ] The public bucket has a CORS configuration that allows the web application to access the files in the bucket.
- [ ] The command to set that configuration is saved in your teams deployment documentation Markdown file