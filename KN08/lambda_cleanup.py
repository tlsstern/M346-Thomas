import boto3
import datetime

ec = boto3.client('ec2')

def lambda_handler(event, context):
    account_ids = ['343088266482']

    delete_on = datetime.date.today().strftime('%Y-%m-%d')
    filters = [
        {'Name': 'tag-key', 'Values': ['DeleteOn']},
        {'Name': 'tag-value', 'Values': [delete_on]},
    ]
    snapshot_response = ec.describe_snapshots(OwnerIds=account_ids, Filters=filters)

    for snap in snapshot_response['Snapshots']:
        print("Deleting snapshot %s" % snap['SnapshotId'])
        ec.delete_snapshot(SnapshotId=snap['SnapshotId'])

    print("Deleted %d snapshots" % len(snapshot_response['Snapshots']))