import os
from datetime import datetime, timedelta, timezone

import boto3


def cleanup_s3(bucket_name: str, retention_days: int = 7):
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix="imports/")
    contents = response.get("Contents", [])
    delete_before = datetime.now(timezone.utc) - timedelta(days=retention_days)

    old_objects = [
        {"Key": obj["Key"]}
        for obj in contents
        if obj["LastModified"] < delete_before
    ]

    if old_objects:
        s3.delete_objects(Bucket=bucket_name, Delete={"Objects": old_objects})


def main():
    bucket = os.getenv("UPLOAD_S3_BUCKET")
    if bucket:
        cleanup_s3(bucket)


if __name__ == "__main__":
    main()
