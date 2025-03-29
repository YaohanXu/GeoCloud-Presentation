import re
from concurrent.futures import ThreadPoolExecutor
from google.cloud import storage

# We want to ensure that all tiles have a 'properties' directory in their path,
# and that there is only one 'properties' directory in the path.
# Good: tiles/properties/...
good_prefix = re.compile(r'tiles/properties/(?!properties/)')

# Problems: Some tiles have no 'properties' in their path, some have multiple
# 'properties', and some have no trailing slash after 'properties'.
problem_prefix = re.compile(r'tiles(/properties)*/?')

# Solution: Replace no or multiple 'properties' with a single 'properties'
replacement_prefix = 'tiles/properties/'


def rename_blob(bucket, blob, problem, replacement, executor=None):
    new_name = re.sub(problem, replacement, blob.name)
    print(f"Renaming gs://{bucket.name}/{blob.name} to {new_name}")
    if executor is None:
        bucket.rename_blob(blob, new_name)
    else:
        executor.submit(bucket.rename_blob, blob, new_name)


def restructure_tiles(bucket_name):
    print(f"Restructuring tiles in bucket {bucket_name}")
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blobs = bucket.list_blobs()

    with ThreadPoolExecutor() as executor:
        for blob in blobs:
            if not good_prefix.match(blob.name):
                executor.submit(rename_blob, bucket, blob, problem_prefix,
                                replacement_prefix)

    print(f"Finished restructuring tiles in bucket {bucket_name}")


if __name__ == '__main__':
    restructure_tiles('musa5090s25-team1-public')
    restructure_tiles('musa5090s25-team2-public')
    restructure_tiles('musa5090s25-team3-public')
    restructure_tiles('musa5090s25-team4-public')
    restructure_tiles('musa5090s25-team5-public')
    restructure_tiles('musa5090s25-team6-public')
