#definizione forma dati in ingresso e in uscita per le API
#le classi di creazione non hanno id, perché il DB lo genera in automatico
from pydantic import BaseModel
from datetime import date
from typing import Optional

class VerduraCreate(BaseModel):
    nome: str
    unita: str = "g"

class VerduraResponse(BaseModel):
    id: int
    nome: str
    unita: str

    model_config = {"from_attributes": True}

class RaccoltoCreate(BaseModel):
    verdura_id: int
    peso: int
    data: date
    note: Optional[str] = None

class RaccoltoResponse(BaseModel):
    id: int
    verdura_id: int
    peso: int
    data: date
    note: Optional[str]
    verdura: VerduraResponse #includo tutto così non deve fare 2 chiamate per il nome
    
    #crea risposta degli oggetti che vengono da models.py
    model_config = {"from_attributes": True} 