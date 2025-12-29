# api.py
from fastapi import FastAPI
from pydantic import BaseModel
import uuid, json, os
import redis

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
app = FastAPI()

class ChatRequest(BaseModel):
    text: str
    priority: str = "normal"
    session_id: str | None = None

@app.post("/api_v1/chat")
def chat(req: ChatRequest):
    job_id = str(uuid.uuid4())

    payload = {
        "job_id": job_id,
        "text": req.text,
        "priority": req.priority,
        "session_id": req.session_id,
    }

    queue_name = "queue:high" if req.priority == "high" else "queue:normal"
    r.lpush(queue_name, json.dumps(payload))

    return {"job_id": job_id, "status": "queued"}

@app.get("/api_v1/result/{job_id}")
def result(job_id: str):
    res = r.get(f"result:{job_id}")
    if not res:
        return {"job_id": job_id, "status": "processing"}
    return {"job_id": job_id, "status": "done", "response": res}

@app.get("/")
def health():
    return {"status": "ok"}