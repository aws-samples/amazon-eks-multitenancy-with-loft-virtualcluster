# Sale - Run/Test APP

```
cd aws-eks-loft-vcluster/app 
===========================================================
$$ If you have already set venv then skip next 3 step $$
===========================================================
python3 -m venv vclusterenv 

source ./vclusterenv/bin/activate 

pip install --no-cache-dir --upgrade -r requirements.txt 

uvicorn _src.saleApi:app --reload  


http://127.0.0.1:8000/docs

```

# Docker Build & Publish
 
```

docker build -t sale_api:rc0.2 .  

docker run -d -p 8080:80 -e current_env='localDev'  --name saleapi sale_api:rc0.2

http://127.0.0.1:8080/docs

docker login

docker tag sale_api:rc0.2 khanasif1/sale_api:rc0.2

docker push khanasif1/sale_api:rc0.2

```

- Browser locally : http://localhost:8080/docs
- check logs