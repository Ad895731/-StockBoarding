# StockBoarding (SmartStock AI)

StockBoarding (SmartStock AI) is an inventory and product onboarding application featuring a FastAPI backend and a Flutter cross-platform frontend. It enables users to browse catalog products, manually add new stock items, upload product photos, and extract packaging text using optical character recognition (OCR).

---

## Tech Stack

* **Frontend:** [Flutter](https://flutter.dev) (Dart SDK `^3.9.2`)
  * Material 3 UI design
  * HTTP client (`http`)
  * Image picker (`image_picker`)
* **Backend:** [FastAPI](https://fastapi.tiangolo.com) (Python 3.10+)
  * Web server: Uvicorn ASGI server
  * ORM: SQLAlchemy
  * Data validation: Pydantic
  * OCR & image processing: PyTesseract, Pillow (PIL)
  * Multipart uploads: python-multipart
* **Database:** PostgreSQL (`smartstock` database)

---

## Project Structure

```text
StockBoarding/
├── backend/
│   ├── app/
│   │   ├── models/           # SQLAlchemy database models (Product)
│   │   ├── routes/           # FastAPI routers (Product endpoints & OCR upload)
│   │   ├── schemas/          # Pydantic validation schemas
│   │   ├── services/         # OCR service with image preprocessing & Tesseract
│   │   ├── database.py       # SQLAlchemy engine & session setup
│   │   └── main.py           # FastAPI application entrypoint and middleware
│   ├── uploads/              # Runtime directory for uploaded product images
│   ├── .env.example          # Sample environment configuration
│   ├── main.py               # Root module hook
│   └── requirements.txt      # Python backend dependencies
├── flutter_app/
│   ├── lib/
│   │   ├── screens/          # UI screens (AddProductPage)
│   │   ├── services/         # API and ImagePicker helper services
│   │   └── main.dart         # Flutter application entrypoint & product list view
│   ├── test/                 # Flutter tests
│   └── pubspec.yaml          # Flutter package configuration & dependencies
├── .gitignore                # Root Git ignore configuration
└── README.md                 # Project documentation
```

---

## Implemented Features

* **Product Catalog:** View onboarded products in a real-time list with name, brand, and selling price.
* **Add Products:** Form to onboard items with name, brand, category, MRP, quantity, and selling price.
* **Image Selection & Upload:** Pick images from the device gallery and upload them to the backend server.
* **OCR Text Extraction:** Automated image preprocessing (grayscale conversion, resolution upscaling, contrast adjustment, sharpening) and text extraction via Tesseract OCR (`--oem 3 --psm 11` with standard fallback).
* **RESTful Product API:** Full CRUD operations on products (`GET /products/`, `POST /products/`, `GET /products/{id}`, `PUT /products/{id}`, `DELETE /products/{id}`, and `POST /products/upload-image`).

---

## Prerequisites

1. **Python 3.10+**
2. **PostgreSQL** server running locally
3. **Tesseract OCR**:
   * **macOS:** `brew install tesseract`
   * **Ubuntu / Debian:** `sudo apt-get install tesseract-ocr`
   * **Windows:** Download and install from [UB-Mannheim Tesseract](https://github.com/UB-Mannheim/tesseract/wiki)
4. **Flutter SDK** (`>=3.9.2`)

---

## Getting Started

### 1. Database Setup

Ensure PostgreSQL is running and create the `smartstock` database:

```bash
createdb smartstock
```

*(Or connect to `psql` and execute `CREATE DATABASE smartstock;`)*

---

### 2. Backend Setup

1. Open a terminal and navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a Python virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   # On Windows: venv\Scripts\activate
   ```

3. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. *(Optional)* Configure environment variables:
   ```bash
   cp .env.example .env
   ```

5. Run the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

   The backend will start at `http://127.0.0.1:8000`.
   * **Interactive Swagger UI:** `http://127.0.0.1:8000/docs`
   * **ReDoc:** `http://127.0.0.1:8000/redoc`

---

### 3. Frontend Setup

1. Open a new terminal and navigate to the `flutter_app` directory:
   ```bash
   cd flutter_app
   ```

2. Install the Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Launch the application:
   * **Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```
   * **macOS (Desktop):**
     ```bash
     flutter run -d macos
     ```
   * **Mobile Device / Emulator:**
     ```bash
     flutter run
     ```

> **Note on Network Configuration:** The Flutter app connects to `http://127.0.0.1:8000` by default. If running on an Android emulator, update the API base URL in `lib/services/api_service.dart` to `http://10.0.2.2:8000` or your machine's local IP address.
