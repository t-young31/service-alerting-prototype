import os
import asyncio
import requests
from fastapi import FastAPI


app = FastAPI(title="toy-api")


@app.get("/ping")
def health() -> str:
    return "pong"


@app.on_event("startup")
def startup() -> None:
    asyncio.create_task(ping_opsgenie_heartbeat())


async def ping_opsgenie_heartbeat() -> None:
    auth_header = {"Authorization": f"GenieKey {os.environ['OPSGENIE_API_KEY']}"}
    base_url = f"http://{os.environ['OPSGENIE_API_URL']}"
    url = f"{base_url}/v2/heartbeats/{os.environ['OPSGENIE_HEARTBEAT_NAME']}/ping"

    while True:
        response = requests.get(url=url, headers=auth_header)
        print(f"Ping to {url}: Response: {response} {response.text}")
        await asyncio.sleep(10)  # seconds
