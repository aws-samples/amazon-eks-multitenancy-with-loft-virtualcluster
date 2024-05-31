from typing import Optional

from fastapi import FastAPI
from pydantic import BaseModel
import os

currentEnvironment = os.environ.get('current_env')
if currentEnvironment is None:
   currentEnvironment = "!!Environment missing!!"  
currentVersion = os.environ.get('current_ver')
if currentVersion is None:
   currentVersion = "NULL"     
class Item(BaseModel):  
    name: str
    description: Optional[str] = None
    price: float
app = FastAPI()

@app.get("/ping")
def ping():
  print(f'Env:{currentEnvironment}-ping product api called !!')
  return {"Hi from product API!"}

@app.get("/")
def listProducts():
   print(f'Env:{currentEnvironment}-list poducts api called !!')
   data = [
        Item(name="Coke", price=2.0),
        Item(name="Pepsi", price=2.5),
        Item(name="7up", price=2.45),
        Item(name="Fanta", price=1.5)
    ]
   response ={"api":"product","customer":currentEnvironment ,"version":currentVersion, "data": data}
   return response