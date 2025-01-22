---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# Welcome to MUSA509: Geospatial Cloud Computing & Visualization

---

## Agenda

1.  Course content overview
    - Goals
    - Content overview
1.  Logistics
1.  Interactive: Set up tools
    - PostgreSQL & PG Admin
    - VS Code (with useful extensions)
    - A Terminal
    - GitHub

---

## Goals of this _track_ (MUSA 6110 & 5090)

Give you the skills to build **data-centric cloud-based applications and reports**, powered by data pipelines that take raw data (spatial and otherwise) from around the web, **to provide answers to operational questions**.

By the end of _this_ course, you'll have built your own data-centric operational tool in the cloud.

---

## Data-centric Cloud-based Tools?

- Let's talk about it.
  https://docs.google.com/presentation/d/1JX-y6-s0PUilrR6_NlFmqc7w_2F_OaznORmtu-TTlpI/edit?usp=sharing

---

# Overview of Skills & Technologies

---

## Spatial Databases

![bg vertical right:30% 80%](images/PostgreSQL_logo.webp)
![bg right:30% 80%](images/PostGIS_logo.png)

Databases are a super power once you learn a bit about them. We’ll learn lots of **SQL**, a very transferable skill

How we’ll use them:
- Querying data efficiently
- Managing datasets with explicit relationships between them
- Query geography (e.g., give me all bike share stations within 500 meters of a cafe), etc.

---

## Large, messy datasets

![bg vertical right:30% 80%](images/dbt-signature_tm.png)
![bg vertical right:30% 80%](images/GoogleBigQuery_logo.png)

We will work with large and/or messy datasets such as OpenStreetMap (global), US Census (national), Philadelphia Office of Property Assessment (local), Placer.ai (proprietary) and more, in a variety of formats.

We’ll cover:
- Techniques for taming these datasets
- Using tools to access, store, transform, and run analyses on datasets
- Best practices for modeling and organizing data

---

## Data Visualization Platforms

![bg vertical right:30% 70%](images/Carto_logo.png)
![bg vertical right:30% 80%](images/Metabase_logo.png)
![bg vertical right:30% 60%](images/Redash_logo.png)

We'll get introduced to some common platforms for visualizing data stored in cloud repositories. These can be good for lightweight exploration of data, or quick prototyping of dashboards.

---

## Enough scripting to be dangerous

![bg vertical right:30% 80%](images/Python_logo.png)
![bg vertical right:30% 80%](images/Node.js_logo.png)
![bg vertical right:30% 80%](images/GoogleCloudFunctions_logo.png)

**Python** and **JavaScript** are powerful programming languages with a huge communities, which means that there are a lot of amazing packages.

We need these scripting languages to:
- Fetch and process data from around the web
- Build APIs to serve up processed data
- Provide glue between a user interaction on a webpage and a database transaction

---

## API basics and HTTP requests

An Application Programming Interface (**API**) gives an interface for computers to communicate with one another. We will learn patterns that will help us extract dynamic data from a number of sources through APIs, and to create our own APIs.

Where possible, examples will be given in the approximately equivalent Python and JavaScript.

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

```py
from flask import Flask
app = Flask(__name__)

@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'
```
</div>

<div>

![Node.js h:32](images/Node.js_icon.png)

```js
import express from 'express';
const app = express();
  
app.get('/', (req, res) => {
    res.send('Hello, World!');
});
```
</div>

---

## Cloud Services

![bg vertical right:30% 80%](images/GoogleCloudPlatform_logo.png)
![bg vertical right:30% 80%](images/MicrosoftAzure_logo.png)
![bg vertical right:30% 60%](images/AmazonWebServices_logo.png)

Our final work will all be in the cloud!

- Data will be stored in Google Cloud Storage
- Pipelines and servers will be run in Google Cloud Functions
- We’ll use Google Cloud for accessing data in BigQuery

Though we'll work in Google Cloud for this class, I'll mention analagous services in Amazon Web Services (AWS), Microsoft Azure, etc. when applicable.

---

## Containers

![bg vertical right:40% 80%](images/Docker_logo.png)

We'll use containerization technologies (specifically **Docker**) to standardize our local environments, and to deploy code to the cloud.

<!-- [...AFTER READING THE SLIDE]

To be honest, I don't really like running Docker on my local computer as part of my regular development workflow.  I find that, after you know what you're doing with the tools you're using, Docker just introduces an unnecessary layer of complication to the flow.

That said, _before_ you're entirely comfortable with all the tools (and there are a lot of tools that we'll be using, as you've just seen), Docker containers can be a useful way to provide some consistency across environments, especially for testing how code will run when it's deployed, and since we're going to be working across Windows, Mac, and once we get into the cloud, Linux-based systems, Docker's going to be useful -- hopefully more help than hindrance.

-->

---

# Logistics

---

## Living Course Info

https://github.com/Weitzman-MUSA-GeoCloud/course-info

Contains the syllabus, schedule, assignments, etc.

---

## Class format

- The majority of lectures will be asynchronous.
- The beginning of each class will be devoted to answering questions, clarifying content, or discussions.
- The later part of classes will be interactive, sometimes with some deliverable expected by the end that will make up part of the participation portion of your grade.
- Starting week 7 (or 8?) we will be doing an in-class project -- building a property tax review platform around City of Philadelphia data

<!--
  - **The majority of lectures will be async**

    That means that, when we have a lecture, I'll record the lecture content and make it available to you to watch _before_ the class session. You'll be expected to watch the videos before class.

  - **The beginning of each class will be devoted to answering questions, or clarifying content, or discussions.**

    As you're going through the video, you'll want to be actively following along. If you have questions or something is unclear, please feel free to leave a comment on the actual video. These videos will be unlisted, so it's not like someone searching YouTube will be able to see your comment. However you will have to have a google account in order to actually leave a comment.

    In class I'll go through the comments and expound on anything from the video that people bring up.

    Some of the material will merit discussion -- when I anticipate this I'll try to call it out in the video.
  
  - **The later part of classes will be interactive...**

  - **Starting week 7 (or 8?) ...**

    I'll share more about that project when the time comes, but that project will be largely if not entirely in-class, as you'll be doing it in parallel with your final projects and I don't want it to get in the way. But just anticipate that it will be very important to be in attendance.
-->
---

## Books

There will occasionally be readings from the following books to provide more depth on certain core topics. All are available from [O'Reilly for Higher Education](http://pwp.library.upenn.edu.proxy.library.upenn.edu/loggedin/pwp/pw-oreilly.html):
  - _Learning SQL, 3rd Edition_ by Alan Beaulieu
  - _SQL Cookbook, 2nd Edition_ by Anthony Molinaro
  - _Data Pipelines Pocket Reference_ by James Densmore
  - _Designing Data-Intensive Applications_ by Martin Kleppmann

---

# Questions?

---

## Let's get configured!

- **VS Code** (or your editor of choice) and extensions
  - _PostgreSQL_ (by Weijan Chen) for running SQL in VS Code
  - _Docker_ (by Microsoft) for Dockerfile style and container management
  - _sqlfluff_ (by dorzey) for SQL style
  - _eslint_ (by Microsoft) for JavaScript style
  - _flake8_ (by Microsoft) for Python style
- A command line terminal (you can use the one embedded in VS Code)
- A **git** client (e.g. **GitHub Desktop**, or the VS Code git tools, _but also ensure that you can run `git` on the command line_, just in case you need it)
- **Docker** and **Docker Desktop** -- we won't use this _today_, but soon.
- A **PostgreSQL** client such as **PGAdmin** ([sneak peek at next week's slides](https://docs.google.com/presentation/d/1v-nMrK1-xhoOSA4Euq3B5xq6pSm0uv-D_485J4d_yZo/edit#slide=id.g1d409c96e66_0_0))
