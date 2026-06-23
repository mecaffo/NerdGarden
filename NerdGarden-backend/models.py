#descrizione tabelle SQL in python, utilizzando SQLAlchemy
from sqlalchemy import Column, Integer, String, Numeric, Date, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class Verdura(Base): 
    __tablename__ = "verdure"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100), nullable=False, unique=True) #nome unico
    unita = Column(String(1), default="g") #grammi

    raccolti = relationship("Raccolto", back_populates="verdura")

class Raccolto(Base):
    __tablename__ = "raccolti"

    id = Column(Integer, primary_key=True, index=True)
    verdura_id = Column(Integer, ForeignKey("verdure.id"), nullable=False)
    peso = Column(Numeric(8, 0), nullable=False) #in grammi, no decimali
    data = Column(Date, nullable=False)
    note = Column(String(255), nullable=True)

    verdura = relationship("Verdura", back_populates="raccolti")