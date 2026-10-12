import os
from pathlib import Path
from dotenv import load_dotenv, find_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Load environment variables from backend/.env or root .env
backend_env_path = Path(__file__).resolve().parent.parent / ".env"
if backend_env_path.exists():
    load_dotenv(dotenv_path=backend_env_path)
else:
    load_dotenv(find_dotenv())

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError(
        "DATABASE_URL environment variable is not set. "
        "Please define DATABASE_URL in your environment or backend/.env file "
        "(e.g., DATABASE_URL=postgresql://localhost/smartstock)."
    )

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()