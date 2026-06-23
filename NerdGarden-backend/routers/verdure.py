#endpoint per le verdure

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db #chiamata automatica al database
import models, schemas

router = APIRouter(prefix="/verdure", tags=["verdure"])

#restituzione lista verdure per popolare il menù a tendina
@router.get("/", response_model=list[schemas.VerduraResponse])
def get_verdure(db: Session = Depends(get_db)):
    return db.query(models.Verdura).all()

#creazione nuove verdure
@router.post("/", response_model=schemas.VerduraResponse)
def create_verdura(verdura: schemas.VerduraCreate, db: Session = Depends(get_db)):
    #check per evitare omonimi
    esistente = db.query(models.Verdura).filter(models.Verdura.nome == verdura.nome).first()
    if esistente:
        raise HTTPException(status_code=400, detail="Verdura già esistente")
    nuova = models.Verdura(**verdura.model_dump()) #conversione da schema a modello SQLAlchemy
    db.add(nuova)
    db.commit()
    db.refresh(nuova)
    return nuova

#eliminazione verdura per ID
@router.delete("/{verdura_id}")
def delete_verdura(verdura_id: int, db: Session = Depends(get_db)):
    verdura = db.query(models.Verdura).filter(models.Verdura.id == verdura_id).first()
    #check esistenza ID 
    if not verdura:
        raise HTTPException(status_code=404, detail="Verdura non trovata")
    db.delete(verdura)
    db.commit()
    return {"ok": True}