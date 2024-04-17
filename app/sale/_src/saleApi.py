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
    sale: str
    description: Optional[str] = None
    product: str
    count: float
app = FastAPI()

@app.get("/ping")
def ping():
  print(f'Env:{currentEnvironment}-ping sale api called !!')
  return {"Hi from sale API!"}

@app.get("/")
def listProducts():
   print(f'Env:{currentEnvironment}-list sale api called !!')
   return [
        Item(api="sale",version=currentVersion,sale="Coles",product="Coke", count=2000),
        Item(api="sale",version=currentVersion,sale="Woolies",product="Coke", count=125),
        Item(api="sale",version=currentVersion,sale="IGA",product="Pepsi", count=3500),
        Item(api="sale",version=currentVersion,sale="Bondi", product="Fanta", count=890),
        Item(api="sale",version=currentVersion,sale="SydCBD", product="7up", count=10000)
    ]