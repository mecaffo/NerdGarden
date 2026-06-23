#endpoint per i raccolti 

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import extract
from database import get_db
from typing import Optional
import models, schemas

router = APIRouter(prefix="/raccolti", tags=["raccolti"])

#restitizione raccolti, con filtri custom per verdura e data
@router.get("/", response_model=list[schemas.RaccoltoResponse])
def get_raccolti(
    verdura_id: Optional[int] = None,
    mese: Optional[int] = None,
    anno: Optional[int] = None,
    db: Session = Depends(get_db)
):
    #costruzione query custom in base ai filtri
    query = db.query(models.Raccolto)
    if verdura_id:
        query = query.filter(models.Raccolto.verdura_id == verdura_id)
    if mese:
        query = query.filter(extract("month", models.Raccolto.data) == mese)
    if anno:
        query = query.filter(extract("year", models.Raccolto.data) == anno)
    return query.order_by(models.Raccolto.data.desc()).all()

#salvataggio nuovo raccolto
@router.post("/", response_model=schemas.RaccoltoResponse)
def create_raccolto(raccolto: schemas.RaccoltoCreate, db: Session = Depends(get_db)):
    verdura = db.query(models.Verdura).filter(models.Verdura.id == raccolto.verdura_id).first()
    #check esistenza verdura, ridondante
    if not verdura:
        raise HTTPException(status_code=404, detail="Verdura non trovata")
    nuovo = models.Raccolto(**raccolto.model_dump())
    db.add(nuovo)
    db.commit()
    db.refresh(nuovo)
    return nuovo

#eliminazione raccolto per ID
@router.delete("/{raccolto_id}")
def delete_raccolto(raccolto_id: int, db: Session = Depends(get_db)):
    raccolto = db.query(models.Raccolto).filter(models.Raccolto.id == raccolto_id).first()
    #check esistenza ID
    if not raccolto:
        raise HTTPException(status_code=404, detail="Raccolto non trovato")
    db.delete(raccolto)
    db.commit()
    return {"ok": True}