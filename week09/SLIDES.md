---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# Implementing ELT with Cloud Services, Part 3
## Modeling and Transforming Data

---

## Agenda

1.  Modeling data in a warehouse
    - Fact and dimension tables
    - Star and snowflake schemas
    - Tools that help (like `dbt`)
2.  Running data transformations

---

## Modeling Data in a Warehouse

<!-- So you've got some raw data in your warehouse. We're gonna talk about what many organizations do next, which is model their data. Note when I'm talking about models here it's different than machine learning models. A "data model" in this sense is just a way of describing the structure of your data.

Know that modeling data for transaction processing and for analytical processing are frequently approached differently, and we're going to focus on analytical processing right now. In an OLAP data warehouse, the most frequent approach to data modeling is call "star schema". There's also "snowflake schema", but that's just a star schema with more detail. Generally, both star schema and snowflake schema are known as dimensional modeling.

In a dimensional modeling approach, you represent your domain -- or the stuff that you're modeling with data -- using what are called "fact tables" and "dimension tables". Most information you'll find about what makes a fact table or what makes a dimension table is very hand-wavy. But don't worry, you're not missing anything. The descriptions are vague because data modeling is more of an art than a science -- you're trying to figure out the best way to represent some real world stuff within an imperfect medium of data tables.

Still, broadly speeking, I think of facts in dimensional modeling as events that happen, and I think of dimensions as the context around the events -- who did the things, where did the things happen, what did the things happen to, etc. -->

**"Star/Snowflake Schema" (i.e. Dimensional Modeling)**
-   **Fact tables**  -- Each row represents an event that occurred at a particular time
-   **Dimension tables** -- Each row represent the who, what, where, when, how, and why of the event.

Martin Kleppmann, _Designing Data Intensive Applications_ (chapter 3)

Ralph Kimball and Margy Ross, _The Data Warehouse Toolkit_

---

## Modeling Data in a Warehouse

For example, a bikeshare trip model...

![bg right:70%](images/Bikeshare%20Trip%20Dimensional%20Model.png)

<!-- For example, if I wanted to model the activity in a bikeshare system, I might choose to create a trip fact table, and model the bikes, stations, and subscription plans as dimensions. 

This arrangement of a central fact table connected to several dimension tables is where the name "star schema" comes from. The fact table is like the center of a star.

The trip table may not be the only fact table that is in my system. For example, when someone purchases a new plan, I may want a new fact table to represent that event. So, a dimension table may be connected to several fact tables as well. But, fact tables usually don't reference other fact table (in a snowflake schema, dimension tables may have other sub dimension tables, but the relationships still usually radiate from one central point out). -->

---

<!-- You're raw data is almost never in an optimal structure for whater your data model is, so you usually have to transform it to get it into your organization's desired form. There are many tools that can help you do this data transformation, but one of the most popular (and best in my opinion) is dbt.

dbt (Data Build Tool) is an open-source tool used for orchestrating and automating the data transformation and modeling process within data warehouses. While dbt doesn't specifically focus on getting data into a star schema, it plays a crucial role in the overall process of building and maintaining star schemas.

DBT was actually started by a Philadelphia company (they used to be called Fishtown Analytics). It essentially allows you to define your models as SQL queries, and then it will create a relationship graph between your tables.

[https://www.getdbt.com/]

One of the easiest ways to try out DBT is to use their DBT cloud product, but also you can run it locally on your machine. You can literally run `pip install dbt` to get started.

[https://docs.getdbt.com/docs/introduction]

And on top of that, they have excellent documentation.

While we're not going to be using dbt in this class, we will be using techniques that are similar to what dbt does. -->

![bg dbt](images/dbt-logo.png)

---

## Running Data Transformations

In the `week08/explore_phila_data/run_sql/` directory, you'll find a Cloud Function that runs a SQL file.

<!--

In the week07/explore_phila_data/ folder there is a script for loading OPA property data by creating an external table in BigQuery. The SQL for creating the table is hard-coded into the script, but generally speaking, I prefer to keep my SQL in separate SQL files. This is because it allows me to run linters on the SQL, and I don't have to create a new script to run each file.

So, in week08, I added a cloud function that will run any SQL file that is packages alongside it. Let's walk through this file.

[IMPORTS]

- The scripts begin like all of our others, with some imports. At the top we load our environment variables, and down below we load the google cloud libraries we'll need -- namely function framework and bigquery.

- Next we locate the path to the folder with the SQL files.


- Note that instead of including the file in the source code, I could just read a full SQL query from the request (like we saw the Carto API does if you take a look at the extract_phl_li_permits script from week06 -- in the week06 lecture there's a section where I break down the components of that URL). However, allowing a user to simply provide any SQL query they want to run is a huge security risk (and I assure you, Carto is doing a lot of validation when they process the query to ensure that nothing harmful is happening; generally speaking, that kind of validation is called input sanitizing, and explains the other half of the XKCD comic that I showed in week02 about Little Bobby Tables). So in this script, instead of allowing _any_ SQL query, I'm just allowing the user to run one of the SQL files that is packaged with the function, as I already know these to be safe.

-->