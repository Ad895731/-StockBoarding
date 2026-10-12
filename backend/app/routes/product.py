# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends , HTTPException , UploadFile,File
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.product import Product
from app.schemas.product import ProductCreate
import os
import shutil 
from app.services.ocr_service import OCRService



router = APIRouter(prefix="/products", tags=["Products"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/")
def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    new_product = Product(
        name=product.name,
        brand=product.brand,
        category=product.category,
        mrp=product.mrp,
        quantity=product.quantity,
        selling_price=product.selling_price,
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product

@router.get("/")
def get_products(db: Session = Depends(get_db)):
    products = db.query(Product).all()
    return products

@router.get("/{product_id}")
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        return {"error": "Product not found"}
    return product

@router.put("/{product_id}")
def update_product(
    product_id: int,
    product_data: ProductCreate,
    db: Session = Depends(get_db)
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    product.name = product_data.name
    product.brand = product_data.brand
    product.category = product_data.category
    product.mrp = product_data.mrp
    product.quantity = product_data.quantity
    product.selling_price = product_data.selling_price
    db.commit()
    db.refresh(product)
    return product

@router.delete("/{product_id}")
def delete_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    db.delete(product)
    db.commit()
    return {"message": "Product deleted successfully"}


@router.post("/upload-image")
async def upload_product_image(file: UploadFile = File(...)):
    # Resolves to backend/uploads regardless of execution directory
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    upload_dir = os.path.join(base_dir, "uploads")
    os.makedirs(upload_dir, exist_ok=True)

    filename = os.path.basename(file.filename) if file.filename else "uploaded_image.jpg"
    file_path = os.path.join(upload_dir, filename)

    # 1. Save the uploaded file to disk
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 2. Extract text using our OCR Service
    try:
        extracted_text = OCRService.extract_text(file_path)
    except Exception as e:
        extracted_text = f"OCR failed: {str(e)}"

    # 3. Return the response with extracted text
    return {
        "message": "Image uploaded and processed successfully",
        "filename": filename,
        "path": file_path,
        "extracted_text": extracted_text
    }
