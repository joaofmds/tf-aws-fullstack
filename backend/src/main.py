from datetime import datetime
import logging
from io import BytesIO
from typing import List

import boto3
import pandas as pd
import sqlalchemy
from fastapi import FastAPI, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from src.config import get_settings
from src.db import engine

settings = get_settings()

api = FastAPI(title="products-api", version="1.0.0")

api.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


class Product(BaseModel):
    id: int
    created_at: datetime
    name: str
    cost_price: float
    sale_price: float
    quantity: float


@api.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    return response


@api.get("/api")
def index():
    return {"detail": "Hello World!"}


@api.get("/healthz")
def healthz():
    try:
        with engine.connect() as con:
            con.execute(sqlalchemy.text("SELECT 1"))
        return {"status": "ok"}
    except Exception as exc:
        logging.exception(exc)
        return JSONResponse(status_code=503, content={"status": "degraded"})


def validate_and_parse_csv(raw_bytes: bytes) -> pd.DataFrame:
    df = pd.read_csv(BytesIO(raw_bytes))
    expected_columns = ["name", "cost_price", "sale_price", "quantity"]
    if df.columns.tolist() != expected_columns:
        raise HTTPException(status_code=400, detail="O arquivo não está no formato correto!")

    if df.empty:
        raise HTTPException(status_code=400, detail="Arquivo CSV vazio!")

    return df


def import_dataframe_to_database(df: pd.DataFrame):
    with engine.begin() as connection:
        rows = []
        for _, row in df.iterrows():
            rows.append(
                {
                    "name": row["name"],
                    "cost_price": row["cost_price"],
                    "sale_price": row["sale_price"],
                    "quantity": row["quantity"],
                }
            )

        connection.execute(
            sqlalchemy.text(
                "INSERT INTO product.product(created_at, name, cost_price, sale_price, quantity) "
                "VALUES (now(), :name, :cost_price, :sale_price, :quantity)"
            ),
            rows,
        )


def upload_file_to_s3(raw_bytes: bytes, filename: str):
    if not settings.upload_s3_bucket:
        return

    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=settings.upload_s3_bucket,
        Key=f"imports/{filename}",
        Body=raw_bytes,
        ContentType="text/csv",
    )


@api.post("/api/import_file")
async def import_files(file: UploadFile):
    try:
        if not file.filename or not file.filename.endswith(".csv"):
            raise HTTPException(status_code=400, detail="Envie um arquivo .csv")

        raw_bytes = await file.read()
        if len(raw_bytes) > settings.upload_max_mb * 1024 * 1024:
            raise HTTPException(status_code=413, detail="Arquivo excede limite de upload")

        df = validate_and_parse_csv(raw_bytes)
        generated_name = datetime.now().strftime("%Y_%m_%d_%H_%M_%S_%f.csv")
        upload_file_to_s3(raw_bytes, generated_name)
        import_dataframe_to_database(df)

        return {"detail": "Importação realizada com sucesso!"}
    except HTTPException:
        raise
    except Exception as exc:
        logging.exception(exc)
        raise HTTPException(status_code=500, detail="Erro ao realizar importação!") from exc


@api.get("/api/products", response_model=List[Product])
async def get_products() -> List[Product]:
    products = []
    with engine.connect() as con:
        res = con.execute(sqlalchemy.text("SELECT * FROM product.product ORDER BY created_at DESC"))

    for row in res:
        products.append(
            Product(
                id=row.id,
                created_at=row.created_at,
                name=row.name,
                cost_price=row.cost_price,
                sale_price=row.sale_price,
                quantity=row.quantity,
            )
        )

    return products
