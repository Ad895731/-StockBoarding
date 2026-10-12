from pydantic import BaseModel

class ProductCreate(BaseModel):
    name : str 
    brand:str | None = None
    category: str | None = None
    mrp: float | None = None
    quantity: str | None = None
    selling_price: float | None = None