import sqlalchemy

from src.config import get_settings

settings = get_settings()

engine = sqlalchemy.create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=5,
    pool_recycle=1800,
)
