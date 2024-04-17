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
    api: str
    version: str    
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
   return [
        Item(api="product",version=currentVersion,name="Coke", price=2.0),
        Item(api="product",version=currentVersion,name="Pepsi", price=2.5),
        Item(api="product",version=currentVersion,name="7up", price=2.45),
        Item(api="product",version=currentVersion,name="Fanta", price=1.5)
    ]