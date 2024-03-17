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

Remember that these cloud storage systems operate around buckets of data, and each bucket is basically like a drive that you can store folders and files in. You may already have a bucket where you can store processed data to use behind external tables (because we created one a couple of weeks ago in week05). I like to have one bucket for keeping my data downloads, and a separate bucket for my external table data, but in this case I'll just use different folders in the same bucket.

I'll use my `mjumbewu_musa_5090_data_lake` bucket for my external table data, and for my extracted data. Refer back to the week06 video for the process for creating a bucket. As a reminder, for resources that you're creating, try to create them all in the same region. For really critical tasks, you might choose to create multi-region resources, but for our purposes a single region will suffice (and help ensure we don't run into any unintended bills).

I often choose the central-1 region because I know that it's one of the data centers that uses more [renewable energy](https://cloud.google.com/sustainability/region-carbon). Even though it's a drop in the bucket compared to what we need to be doing for our environment, it does make me feel just a smidge better. (Even if it does smell a little of green-washing. Like, what is Google doing running data centers that _don't_ use renewable energy? Why is this even a choice?)

**sigh**

Anyways, we have our data lake bucket. I'm using the term "data lake" here to refer to a place where I can store all of my mostly-raw data in an organized way. I'll drop a few references explaining the term in the week notes, but just know that the concept of a "data lake" is a bit of a buzzword, and it's not always clear what it means. It's way simpler than people often make it out to be.

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

Something like poetry or pipenv is also great for managing environments. Also by the way, for folks who want to use conda, there's an article that was just published about managing virtual environments with `conda`. I'll leave a link in the week notes.

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

Let's copy the extract script in your language of choice into our new folder (I'm going to copy both the Python and the JS, but again, you can stick to one or the other, or mix-and-match as you see fit). Since we'll be installing things that I don't want to check in to the repository, I'll also copy the .gitignore file from the week06 folder. And finally I'll create raw_data/ and prepared_data/ folders in my new folder, since the scripts expect them to be there.

[DO THE COPY]

Now let's see how to update the files. I have the JavaScript on the left and the Python on the right.

1.  First we'll need to import the appropriate libraries
2.  Then we'll need a connection to the service. Many of these types of libraries borrow from networking terminology, so the object that interacts with the remote service is called a client.
3.  We also need to know which bucket we're working with.
   
    Normally I wouldn't put the bucket name directly in the script, but we'll talk about environment variables later, so this is good enough for now.
4.  We need to specify where we're going to put the file within the bucket. Remember, you can think of a bucket like a drive, and you can have a many folders within it as you want, with as many files as you want.
5.  Finally, we'll upload the file. Notice that the the file will be overwritten each time we run the script. Oftentimes, one might add a timestamp or some other uniquely identifying aspect to the file path, such as a "hash" of the file contents.

Now let's try to run the script. For the Python version that's:

    python extract_phl_opa_properties.py

And for node that's:

    node extract_phl_opa_properties.mjs

But when we run the command right now, we get an error. The links in the errors from the Python and Node libraries are different, but trust me, the error is the same: we're trying to create a connection to GCS but we don't have any way currently for GCP to know who we are -- ...

-->

---

<!--

... we are not "authenticated" at GCP when we run the script, so it's not going to be able to "authorize" us to access to the bucket we're requesting.

-->

## Auth/auth for GCP client libraries

- **Authentication:** How a system knows which user a given process should act as.
- **Authorization:** How a system knows which resources a given user can access or modify.

---

## Auth/auth for GCP client libraries

<!--
There are a number of ways to authenticate with GCP, but there are two that we're going to concern ourselves with in this class. We'll talk about application default credentials when we get into using the `gcloud` command line tool next week, but the authentication method we're going to use this week is to use a "service account".

A service account is a special type of account that is used by an application to make authorized API requests. It's not a user account, and it's not meant to be used interactively. It's meant to be used by a machine, and it's meant to be used in a way that's secure.

I think of service accounts as being like robots that you use to do specific tasks. You can give the robot a set of keys that it can use to open doors that you've pre-approved, and you can tell it to go do specific things behind those doors. It's not you, but it's acting on your behalf in some limited places that you've authorized it to.

### Creating a service account

To create a service account you can search for service accounts in the GCP console. It's in a section of GCP called Identity & Access Management.

https://console.cloud.google.com/iam-admin/serviceaccounts

Give your robot -- your service account -- whatever name you want, and give it a description so that when you look at it later you know what it's for.

After that, you'll be asked to give it a role. A role is a set of permissions that the service account will have -- they're the keys that you're giving the robot. There are a lot of roles to choose from, but generally you want to give your service accounts a narrow set of permissions. This is because, if anyone got access to your service account credentials, they could do whatever you've allowed the service account to do, so you want that to be as small a set of actions as possible.

In our case, our robot has to be able to read and write files in a Google Cloud Storage bucket, so we're going to give it the "Storage Object Admin" role. I'll link to the comprehensive set of predefined roles in GCP in the week README.

You can skip the step to grant users access to this service account. Click "Done" to create the service account.

-->

We'll use a couple ways to create Application Default Credentials (ADC) for our scripts:

<div class="columns-2">
<div>

**The `gcloud` CLI tool**

```bash
gcloud auth application-default login
```

https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev

</div>
<div>

**Service Accounts**

Created through the GCP console, and then downloaded as a JSON file.

https://cloud.google.com/iam/docs/service-account-overview

<!--

### Service account credentials

Once you've created your service account, you'll want to download the credentials so that we can use them with your script. Use the three dot menu to the right of the service account you just created, and select "Manage keys".

On the next screen click "Add key", and then select "Create new key". You'll be asked to choose a key type, and you'll want to choose "JSON". This will download a JSON file to your computer. This file is your service account key, and it's the file that you'll use to authenticate your script.

You're going to want to move that key somewhere that it's easy to refer to it, but, (and this is _very_ important) YOU WANT TO MAKE SURE THAT THE KEY FILE DOES NOT GET CHECKED IN TO YOUR REPOSITORY. Remember what I said before about anyone that has access to the service account credentials being able to do whatever the service account can do? Well, if you check the credentials into your repository, then anyone who can see your repository can use your service account to do whatever it's allowed to do. So never add your service account key (or any credentials) into your repository (...also, it happens to everyone at least once, so don't judge if it happens to you or your peers -- that's why it's possible to revoke these credentials as easily as they're created).

What I often do is create a separate folder in my code for keys, and then I add that folder to my .gitignore file. That way, I can keep my keys in a place that's easy to find, but I don't have to worry about them getting checked in.

-->

</div>
</div>

---

## Auth/auth for GCP client libraries

### Using the service account keyfile

<!--

Now we'll use the key by setting an environment variable. We've seen environment variables before -- the PATH variable that many of you had to set on Windows to get ogr2ogr to work is an environment variable. Also, the .env file that we used to set the connection information for running tests in assignments 1 and 2 was loaded into environment variables.

Since we don't want the variable we set now to apply to your entire system, we're going to use a .env file to set the variable for our script. We'll use the `dotenv` package in Node, and the `python-dotenv` package in Python. We'll also add the .env file to our .gitignore file so that we don't accidentally check it in to our repository.

Finally we'll use the dotenv package in each language to load the .env file into the environment variables for our script. In Python that looks like putting the following line at the top of your script:

```python
from dotenv import load_dotenv
load_dotenv()
```

And in Node that looks like putting the following line at the top of your script:

```javascript
import dotenv from 'dotenv';
dotenv.config();
```

Now if we run either of these scripts, they should work, and we'll see a new file in the bucket.
-->

1.  Create a `.env` file in the same directory as your script
2.  Add the following line to the `.env` file:

    ```
    GOOGLE_APPLICATION_CREDENTIALS=keys/service-account-key.json
    ```
3.  Install a tool for loading environment variables from a `.env` file:

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

```bash
pip install python-dotenv
```

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

```bash
npm install --save dotenv
```

</div>
</div>

---

## Using environment variables to avoid hard-coding

<!--
While we're here, let's make one other update to our script. Generally when creating scripts that will eventually be run somewhere other than on your computer, you want to avoid hard-coding things like file paths and bucket names. For file paths, this is because the file paths on your computer are not going to be the same as the file paths on another machine that runs your script (be that a collaborator of yours, or some cloud server).

For bucket names, you want to avoid hard-coding them because you might want to test your script against a different bucket than you use when your script is running in production. You may be thinking "it will be easy enough for me to remember to change the bucket name when I move my script to production", but I promise you that you will forget. I've forgotten. Everyone forgets. So it's best to just avoid the problem altogether.

So we're going to leverage environment variables to avoid hard-coding the bucket name in our script. In the .env file, create a new variable called `DATA_LAKE_BUCKET` and set it to the name of your bucket. Then in your script, you can use the `os` module in Python, and the `process.env` object in Node to access the environment variable.

After that, we have a pretty decent extract script. It's not the most memory efficient script, but it will work for our purposes. We'll talk about how to make it more memory efficient in the future.
-->

1.  Add a new line to the `.env` file:

    ```
    DATA_LAKE_BUCKET=mjumbewu_musa_5090_data_lake
    ```
2.  Update the script to use the environment variable:

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

```python
import os
BUCKET_NAME = os.getenv('DATA_LAKE_BUCKET')
```

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

```javascript

const BUCKET_NAME = process.env.DATA_LAKE_BUCKET;
```

</div>
</div>

---

## Updating the prepare _(i.e. little-t transform)_ script

<!--

Now we can use these same patterns to quickly update the prepare_phl_opa_properties scripts as well.

Starting with the scripts from week06, we'll copy them into our new folder, and then we'll update them to 

1. load the environment variables (including the service account key),
2. use the GCP client libraries,
3. use environment variables for the bucket name,
4. download the raw data from the bucket, and
5. upload the prepared data to a different path in the bucket.

Now, you may be asking "but why did we upload the data to cloud storage in the first place if we were just going to download it again?" But remember, when these scripts are running in the cloud, they're running on a machine that's going to be wiped after the script is done. So we have to write the extract script as if it's going to self-destruct after it's done, and the prepare script as if it's going to be run on a fresh machine.

Your next question might be "why not just download the data directly from the source in the prepare script?" One of the main reasons is that saving the raw data into our data lake first gives us more control over exactly what version of the data we load into our warehouse. For example, say we download data from some source on day 1, and process that data to load into bigquery. Then, on day 2, say we find a bug in our processing script. Well, we now have to fix that bug and run the processing script again. But also say that the data has changed in the source between days 1 and 2. We might never be able to get back to the version of the data that existed on day 1. If we're interested in any kind of longitudinal analysis of the data, this could be a problem. So, by saving the raw data into our data lake, we can always go back to the exact version of the data to load into bigquery.

This reason actually alludes to why I put the CSV file for each data source in its own folder; it's because I would normally add a new file into the folder each time I do the extract step. Each of these files may have the time attached to the name, for example, so that I'm not overwriting the same file each time. But, to keep things simple, we'll just stick with a single file for now.

Now if we run either of these scripts, we should get a new file in our data lake bucket.
-->

---

## Loading data into BigQuery

<!--

Now we're going to perform one more step with these scripts: we're going to create or replace an external table that points to these prepared files. I don't have a strong opinion about whether this should be in a separate script, or just added to the end of the prepare script. At this point we're operating on data that's already within the bounds of our system, so we're in less danger of losing any history.

I'm going to create new scripts -- we're going to import our environment variables, add an import to the top of each script for BigQuery, and then tell BigQuery to create or replace an external table that points to the file we just prepared.

When we try to run this script, we'll get an error. The error will be that we don't have the right permissions to create an external table in BigQuery. This is because the service account that we created earlier only has the ability to read and write files in Cloud Storage. It doesn't have the ability to run jobs in BigQuery.

We could give the service account BigQuery Admin, but in this case I think that role is a bit too permissive. We only want to give the service account the ability to run jobs in BigQuery, and work with data in datasets. So, we'll add the BigQuery Job User role and the BigQuery Data Editor role to the service account.

Now if we run the scripts again, we'll have our table created. Now, it's important to check that the table is valid, because as we saw before with this data source, the schema detection can be a bit off.

```sql
SELECT * FROM data_lake.phl_opa_properties
```

And if we query for all the rows in the table [WAIT]...

we can see that BigQuery thinks the "exterior_condition" field should be an integer, but there's at least one non-integer value in the table.

https://cloud.google.com/bigquery/docs/schema-detect#:~:text=scans%20up%20to%20the%20first%20500%20rows%20of%20data%20to%20use%20as%20a%20representative%20sample

I'll leave a link in this week's README to the documentation on how schema auto-detection works, but long-story-short if you're using a CSV or JSON-L file as the backing for your table, BigQuery will look at the first 500 rows of data in the file and try to guess what the schema should be.

[BACK TO THE SLIDES]

-->

- JSON-L and CSV files can be scanned to determine the schema
- File formats like Parquet don't require this scan; the schema is specified explicitly in the file

<!--

If you use file formats like Parquet then BigQuery doesn't have to do this scan. To write Parquet files you'll just need to use different libraries than the ones we've been using, such as `pandas` with `pyarrow` in Python or something like `duckdb` in Node. I'll leave links in the README.

Let's specify the schema explicitly in our load scripts and just make everything a string; we can cast the fields we care about to more appropriate types later.

I'm going to grab the fields from the first line of my JSON-L file (though I could also get them from the CSV). I'll talk through my keyboard shortcuts as I use them.

```bash
head -n 1 prepared_data/phl_opa_properties.jsonl
```

If you have used R or Pandas you may be familiar with how you can run `head` on a dataframe. The `head` function is named what it is because of this command line utility, which just gets the first few lines of a file. Here we're telling it to just get the first 1 line of our file.

I think in PowerShell there's a similar way to do `head` -- something like `Get-Content -TotalCount 1`, or `gc -TotalCount 1`.

Copy that and paste it into a new empty file. I just hit Ctrl+N to get an empty file. I think it's just Cmd+N on a mac.

I paste the line that I copied and then format the file. I can do this with the super menu in VSCode (which is accessible on Windows via Ctrl+Shift+P, and on Mac via Cmd+Shift+P), and then I can search for "format document". On my computer, the keyboard shortcut for this is Shift+Alt+I.

Now I can get rid of the curly brackets around the fields, hold down Shift and Alt, and press down to put a cursor at the first character of each line. Then I can remove the first double quote and replace it with a backtick. Then I can hold Ctrl on windows or Cmd on mac and press the right arrow key to go to the end of the current word, delete the double quote, and replace it with a backtick. Then I can tap shift and end (which on my computer is fn+right arrow, but you'll have to figure out where the end key is on your keyboard) and delete everything else up to the end of the line. Finally I can put STRING and a comma at the end of each field.

https://code.visualstudio.com/docs/editor/codebasics

I'm also going to leave a link to VS Code's core keyboard shortcuts in this week's README file.

Now I can copy these field definitions into my scripts.
-->

---

## Security considerations & `git` hygiene

<!--

Ok we'll leave it there for now. We've covered a lot of ground today. We've talked about how to use the GCP client libraries to interact with Cloud Storage and BigQuery, and we've talked about how to use service accounts to authenticate our scripts. We've also talked about how to use environment variables to avoid hard-coding sensitive information into our scripts, and we've talked about how to use the dotenv package in Python and Node to load environment variables from a .env file.

I just want to end with a couple important security reminders. There are a few types of things that you want to avoid checking in to your git repository. The first is any kind of credentials, like the service account key that we created earlier. The second is any kind of environment variable file, like the .env file that we created earlier. 

There are other things that you should generally avoid adding to your git repositories (such as large data files, or dependencies that are installed in a node_modules folder through npm or in a virtual environment folder). Make sure to add all of these files and folders to your .gitignore file so that you don't have to remember to not check them in.
-->

- **Environment variables** - Avoid hard-coding sensitive information or information that is specific to your computer into your scripts. Use something like a `.env` file, and don't check it in to your repository.

- **Credentials in git** - Avoid checking in credentials or environment variable files. Use the `.gitignore` file to avoid checking in these and other  files.

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

