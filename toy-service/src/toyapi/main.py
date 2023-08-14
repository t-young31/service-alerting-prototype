from fastapi import FastAPI

app = FastAPI(title="toy-api")


@app.get("/ping")
def health() -> str:
    return "pong"
