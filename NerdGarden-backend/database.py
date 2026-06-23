#gestione connessione SQL
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

#connessione a postgresql
engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class Base(DeclarativeBase):
    pass

#sessione HTTP per la connessione al DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally: #la chiudo ogni volta
        db.close()