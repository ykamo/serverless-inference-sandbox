FROM python:3.9

ARG WD="/work/"

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

RUN pip install fastapi pydantic uvicorn[standard]

WORKDIR ${WD}
RUN mkdir -p ${WD}
COPY src/* ${WD}

ENTRYPOINT [ "/usr/local/bin/python", "app.py"]
