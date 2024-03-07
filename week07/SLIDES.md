---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# Implementing ELT with Cloud Services, Part 1

---

## Agenda

0.  Refresher on extract and prepare scripts
1.  Scripting with cloud services
    * Python and Node.js libraries
    * Identity & Access Management with Service Accounts
2.  Working with Google Cloud Storage
    * Uploading files
    * Downloading files
3.  Loading into BigQuery
    * Running a SQL job
4.  Security considerations
    * Environment variables
    * Credentials in git

---

## Review: Extract and Prepare

https://github.com/musa-5090-spring-2024/course-info/tree/main/week06#code-samples

<!-- 

In the week 06 README under the Code Samples section you can find descriptions of what you can see demonstrated in each of the extract and prepare script files (I added this since last week, and cleaned up some of the scripts).

### Extract scripts

Some of these extract scripts download from what look like static files, and others download from API endpoints. You can see an example of one of the API endpoings in the `extract_phl_li_permits` scripts where the data is actually downloaded from an endpoint provided by Carto. The City of Philadelphia contracts with Carto to serve up certain data tables through Carto's SQL API. 

Breaking this down a bit, when you're getting data from an API, we usually call the place you get that data from a "resource". A resource is just some data that an API can manipulate and provide. A resource is usually accessible at an "endpoint" of the API. And endpoint is just a URL host and path that you can use to interact with the API. In this case, the particular endpoint we're working with is:

https://phl.carto.com/api/v2/sql

Now, for this API, we can control what resource we're asking for, and how we want to represent that resource by using querystring parameters:

filename=permits
format=gpkg
skipfields=cartodb_id
q=SELECT%20*%20FROM%20permits%20WHERE%20permitissuedate%20%3E=%20%272016-01-01%27

Here we're asking for the "permits" resource, in "gpkg" format, and we're asking for all the fields except for "cartodb_id". We're also filtering the table with a SQL query in the q parameter. Because these querystring parameters are supplied as part of the URL, and because certain characters are not allowed in URLs, we often "percent-encode" the querystring parameter values. This is why you see `%20` instead of spaces, and `%3E%3D` instead of `>=`. So the actual query is:

q=SELECT * FROM permits WHERE permitissuedate >= '2016-01-01'

You can find all the percent-encoded character values in an [ASCII table](https://www.ascii-code.com/). Most languages also come with functions to encode and decode these values. For example, in Python you can use [`urllib.parse.quote` and `urllib.parse.unquote`](https://docs.python.org/3/library/urllib.parse.html#url-quoting) from the Python standard library:

```python
import urllib.parse
query = "SELECT * FROM permits WHERE permitissuedate >= '2016-01-01'"
encoded_query = urllib.parse.quote(query)
print(encoded_query)
```

and in JavaScript you can use [`encodeURIComponent`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) and [`decodeURIComponent`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent), which are built into the language:

```javascript
const query = "SELECT * FROM permits WHERE permitissuedate >= '2016-01-01'";
const encodedQuery = encodeURIComponent(query);
console.log(encodedQuery);
```

If you notice, the JS was a little bit more lax, in that it didn't encode the asterisk or the single quotation marks. In practice, this would certainly be fine, but the MDN documentation does actually [call it out](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#encoding_for_rfc3986).

One of our set of extract scripts -- the ones for SEPTA GTFS feeds -- also demonstrates working with zipped files. The Python version of this script uses the built-in `zipfile` package within the core Python library, and the Node version uses the adm-zip package (there are other zipfile libraries in Node, but this one's fine).

## Prepare scripts

Going back to the README, we see that each one of the prepare scripts demonstrates something a little bit different. In each case we're creating JSON-L files, but our starting formats are different.

- We have the Philadelphia Water Department (PWD) parcels as GeoJSON. In Python we use the built-in JSON library to read that file, but in Node.js we use the `big-json` package, since the input file is so large. You can try using the built-in `JSON.parse` function in Node.js, just to see how it will fail. Don't worry, you won't break anything.
- We have the Licenses and Inspections permits as GeoPackage. In Python we use the `fiona` library to read the file, and in Node.js we use the `gdal-async` package. Reading from a Shapefile would be very similar and could use the same packages in each language.
- We have the Office of Property Assessments (OPA) properties file, which we load as a CSV, parse WKT values, and reproject from PA State Plane South (or 2272) into 4326 latitude-longitudes. For the Wellknown Text parsing, we use `shapely` in Python and `betterknown` in JavaScript, and for reprojecting points we use pyproj and proj4 respectively.
- Finally, we have the SEPTA GTFS data, which is contained within multiple CSV-formatted files. In this case, we loop over each of the files to convert each to JSON-L.

Take as much time as you need to look through these files, and be sure to ask questions about anything you don't understand.

-->

---

## Scripting with cloud services

<!--

As we get ready to do this processing in the cloud instead of on our local computers, we're going to want to modify our scripts.

-->

---

## Scripting with cloud services

![Extract and load in separate scripts width:1200px](../week06/images/separate-extract-and-load-sequences.svg)

<!--

If you recall, we're going to write separate scripts for each major step in our pipelines, for the sake of modularity. Check out last week's video to refresh yourself on why.

When we write our scripts in a modular fashion for the cloud though, we want to assume that each time the script runs, it's running on a new, clean machine. This new machine may have our script's dependencies installed, but it won't have any of the data from any other step. We should get used to operating as if the script runs, and then the machine that ran it is immediately wiped afterwards (there are cases where this won't be the case, but it's still a good practice).

So, anything we need shared between scripts needs to be stored somewhere that isn't temporary. In many cases, some cloud storage system provider such as Amazon S3 or, in our case, Google Cloud Storage is a good choice.

Remember that these cloud storage systems operate around buckets of data, and each bucket is basically like a drive that you can store folders and files in. You may already have a bucket where you can store processed data to use behind external tables (because we created one a couple of weeks ago in week05). I like to have one bucket for keeping my data downloads, and a separate bucket for my external table data.

I'll use my `mjumbewu_musa_5090_data_lake` bucket for my external table data, but I'll create a new bucket called `mjumbewu_musa_5090_raw_downloads` for my extracted data. As a reminder, for resources that you're creating, try to create them all in the same region. For really critical tasks, you might choose to create multi-region resources, but for our purposes a single region will suffice (and help ensure we don't run into any unintended bills).

I'm going choose the central-1 region because I know that it's one of the data centers that uses more [renewable energy](https://cloud.google.com/sustainability/region-carbon). Even though it's a drop in the bucket compared to what we need to be doing for our environment, it does make me feel just a smidge better. (Even if it does smell a little of green-washing. Like, what is Google doing running data centers that _don't_ use renewable energy? Why is this even a choice?)

**sigh**

Anyways, go ahead and create a bucket for your raw downloaded data if you haven't already.

### Getting my scripts set up

Once I have my buckets created, I can start adapting my scripts to store data in them. I'm going to create a new folder for this work, just to go through the process.

```
mkdir week07_explore_phila_data
cd week07_explore_phila_data
```

I can use the dependencies that we specified in week 06 to bootstrap my environment. I'll just copy the requirements.txt file over for Python, and the package.json for Node. Then, for Python, I can create my environment

```
python3 -m venv env
source env/bin/activate
```

By the way, I was reminded that on windows, to activate a virtual environment, the command that you would want to run is:

```
env\Scripts\activate
```

Now that my environment is activated, I can install my requirements:

```
pip install -r requirements.txt
```

The "-r" tells pip to look in the requirements file for what to install.

For node, I just have to tell npm to install the stuff from the package.json file:

```
npm install
```

-->

---

### GCP Client libraries

https://cloud.google.com/apis/docs/cloud-client-libraries

<!--

We're going to need a couple of additional tools to talk to GCP easily. Google provides [libraries](https://cloud.google.com/apis/docs/cloud-client-libraries) that we can use for interacting with different parts of their Cloud Platform. Specifically we'll need to interact with files in Cloud Storage buckets, and we'll need to run queryies in BigQuery.

Let's go ahead and install the appropriate tools for Python:

```
pip install \
  google-cloud-storage \
  google-cloud-bigquery
```

Or for Node:

```
npm install --save \
  @google-cloud/storage \
  @google-cloud/bigquery
```
-->

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

```bash
pip install \
  google-cloud-storage \
  google-cloud-bigquery
```

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

```bash
npm install --save \
  @google-cloud/storage \
  @google-cloud/bigquery
```

</div>
</div>

_Remember that the backslashes (`\`) are for continuing a command on the next line, and in Windows PowerShell the continuation character is the backtick (`` ` ``)_

---

### Updating the extract script

<!--

Now that we have our requirements, let's go ahead and update our code, starting with an extract script first. I'm going to start with the code from the week06 folder, and I recommend that you follow along, doing the same.

For the most part, the extract scripts are all the same, except that they download from different URLs, so I'll just pick one to start with: the PWD parcels.

Let's copy the extract script in your language of choice into our new folder (I'm going to copy both the Python and the JS, but again, you can stick to one or the other, or mix-and-match as you see fit).

[DO THE COPY]

Now let's see how to update the files. I have the JavaScript on the left and the Python on the right.

1.  First we'll need to import the appropriate libraries
2.  Then we'll need a connection to the service. Many of these types of libraries borrow from networking terminology, so the object that interacts with the remote service is called a client.
3.  We also need to know which bucket we're working with.
   
    Normally I wouldn't put the bucket name directly in the script, but we'll talk about environment variables later, so this is good enough for now.
4.  We need to specify where we're going to put the file within the bucket. Remember, you can think of a bucket like a drive, and you can have a many folders within it as you want, with as many files as you want.
5.  Finally, we'll upload the file. Notice that the the file will be overwritten each time we run the script. Oftentimes, one might add a timestamp or some other uniquely identifying aspect to the file path, such as a "hash" of the file contents.

-->
---

## More extracting and (little-t) transforming files

This is the **Et** of **EtLT**. We will:
1.  **Extract** -- Download data from somewhere on the web and save it to a file (unzipping if necessary).
3.  **transform** -- Read the data from the file, convert to a format that can be loaded into BigQuery (we used JSON-L the other day, but we'll use CSV today), and save to a new file.

<!-- We're going to prepare a bunch of different file types for loading into BigQuery. Specifically, we'll be working with:
- GTFS (General Transit Feed Specification) feeds
- Decenial census data from the census API
- Shapefiles from the Census Bureau
-->

---

### But first ... files, and streams, and buffers (oh my 🦁!)

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

In python there are **file-like objects**. Typically any functions that read or write data will take a file-like object argument.
- For example, `csv.reader`, `json.load`, `zipfile.ZipFile` all accept file-like objects
- We can use `open` to open a file on disk, or we can use `io.StringIO` or `io.BytesIO` to treat any `str` or `byte` data like a file.

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

In Node.js, we'll most frequently either use **streams** or **buffers**. Streams are a way to read and write data in chunks.  Buffers are used to represent a sequence of bytes.
- For example, `fs.createReadStream` and `fs.createWriteStream` are used to read and write data in chunks
- We can use `Buffer.from` to convert a `String` or `Array` object into a buffer.


</div>
</div>

---

### Common libraries

Last week we used `urllib.urlopen` in Python and `https.get` in Node.js to download files from the web.  This week we'll use a few more common libraries.

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

* [`requests`](https://requests.readthedocs.io/en/master/)
* [`csv`](https://docs.python.org/3/library/csv.html) _(core)_
* [`zipfile`](https://docs.python.org/3/library/zipfile.html) _(core)_
* [`fiona`](https://fiona.readthedocs.io/en/latest/) & [`pyproj`](https://pypi.org/project/pyproj/)

Install dependencies:
```bash
pip install requests fiona pyproj
pip freeze > requirements.txt
```

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

* [`node-fetch`](https://www.npmjs.com/package/node-fetch)
* [`csv`](https://www.npmjs.com/package/csv)
* [`adm-zip`](https://www.npmjs.com/package/adm-zip)
* [`gdal-async`](https://www.npmjs.com/package/gdal-async)

Install dependencies:
```bash
npm install --save \
  node-fetch csv adm-zip gdal-async
```

</div>
</div>

