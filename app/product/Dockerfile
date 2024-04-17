# 
FROM --platform=linux/amd64 python:3.9

# 
WORKDIR /code

# 
COPY ./requirements.txt /code/requirements.txt

# 
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# 
COPY ./_src /code/app

# 
CMD ["uvicorn", "app.productApi:app", "--host", "0.0.0.0", "--port", "80"]