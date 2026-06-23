#punto d'ingresso dell'applicazione
from fastapi import FastAPI
from database import Base, engine
from routers import verdure, raccolti

#creazione tabelle se non esistono già
Base.metadata.create_all(bind=engine)

#creazione app FastAPI
app = FastAPI(title="NerdGarden API")

#collegamento router
app.include_router(verdure.router)
app.include_router(raccolti.router)

#check server
@app.get("/health")
def health():
    return {"status": "ok"}