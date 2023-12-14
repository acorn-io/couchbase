from datetime import timedelta
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions
import couchbase.subdocument as SD
import os

# Configuration
CB_HOST = os.environ.get('CB_HOST')
CB_BUCKET = os.environ.get('CB_BUCKET')
CB_USERNAME = os.environ.get('CB_USERNAME')
CB_PASSWORD = os.environ.get('CB_PASSWORD')

print(f'{CB_HOST} / {CB_BUCKET} / {CB_USERNAME} / {CB_PASSWORD}')

# FastAPI application
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# Initialize Couchbase connection
auth = PasswordAuthenticator(CB_USERNAME, CB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(f'couchbase://{CB_HOST}', options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))

# Get default collection in bucket
cb = cluster.bucket(CB_BUCKET)
cb_coll = cb.default_collection()

def setup_database():
    try:
        # Initialize the counter if it doesn't exist
        cb_coll.insert('hits', {'count': 0})
    except:
        # If it already exists, ignore the error
        pass

@app.on_event("startup")
async def startup_event():
    # Setting up database during startup
    setup_database()

@app.get('/', response_class=HTMLResponse)
async def read_root(request: Request):
    try:
        # Increment the counter and retrieve its value
        result = cb_coll.mutate_in( "hits",
            [ SD.increment( "count", 1)])
        
        count = result.content_as[int](0)
    except Exception as e:
        print(f"Error: {e}")
        count = "Error"

    # Returning the current counter value within the rendered HTML
    return templates.TemplateResponse("index.html", {"request": request, "counter": count})
