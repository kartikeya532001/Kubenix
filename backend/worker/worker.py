# worker.py
import os
import time
import json
import redis
from transformers import AutoTokenizer, AutoModelForCausalLM, StoppingCriteria, StoppingCriteriaList
import torch

# Redis configuration
REDIS_HOST = os.getenv("REDIS_HOST", "redis-master")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

# Load TinyLlama model
print("Loading TinyLlama model...")
tokenizer = AutoTokenizer.from_pretrained("TinyLlama/TinyLlama-1.1B-Chat-v1.0")
model = AutoModelForCausalLM.from_pretrained(
    "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    torch_dtype=torch.float32
)

# Redis job handling
def pop_job():
    job = r.rpop("queue:high")
    if job:
        return json.loads(job)
    job = r.rpop("queue:normal")
    if job:
        return json.loads(job)
    return None

# Custom stopping criteria: stop after first sentence ends
class StopAfterFirstSentence(StoppingCriteria):
    def __init__(self, tokenizer):
        self.tokenizer = tokenizer

    def __call__(self, input_ids, scores, **kwargs):
        text = self.tokenizer.decode(input_ids[0], skip_special_tokens=True)
        # Stop if last character is ., !, or ?
        return any(text.endswith(punct) for punct in ["."])

def run_inference(text):
    prompt = f"<|user|>\n{text}\n<|assistant|>\n"
    inputs = tokenizer(prompt, return_tensors="pt")

    stop_criteria = StoppingCriteriaList([StopAfterFirstSentence(tokenizer)])

    outputs = model.generate(
        inputs["input_ids"],
        max_new_tokens=80,          # Increased for longer answers
        do_sample=True,
        temperature=0.7,
        top_p=0.9,
        stopping_criteria=stop_criteria,
        pad_token_id=tokenizer.eos_token_id
    )

    decoded = tokenizer.decode(outputs[0], skip_special_tokens=True)
    # Return only the assistant's part
    return decoded.split("<|assistant|>")[-1].strip()

def save_result(job_id, result):
    r.set(f"result:{job_id}", result, ex=3600)

def main():
    print("Worker started, waiting for jobs...")
    while True:
        job = pop_job()
        if not job:
            time.sleep(0.2)
            continue

        print("Processing job:", job["job_id"])

        response = run_inference(job["text"])
        save_result(job["job_id"], response)

        print("Completed job:", job["job_id"])

if __name__ == "__main__":
    main()
