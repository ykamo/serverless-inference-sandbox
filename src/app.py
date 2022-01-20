from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
import json
import uvicorn


app = FastAPI()

# Load model
# /opt/ml/model 以下に、model.tar.gzを展開したものが入ってる

with open("/opt/ml/model/model.json") as f:
    model = json.load(f)

class Data(BaseModel):
    key: str
    option: Optional[float] = None

                    
@app.get("/ping")
def ping():
    """
    Health check
    """
    return {"Status": "OK"}


@app.post("/invocations")
def do_inference(data: Data):
    data = model[data.key] if data.key in model else "Other"
    res = {"response": data}
    return res


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8080
    )
