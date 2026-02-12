"""create product schema and table

Revision ID: 0001_init_product_schema
Revises:
Create Date: 2026-01-01 00:00:00

"""

from alembic import op
import sqlalchemy as sa


revision = "0001_init_product_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("CREATE SCHEMA IF NOT EXISTS product")
    op.create_table(
        "product",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("now()")),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("cost_price", sa.Numeric(10, 2), nullable=False),
        sa.Column("sale_price", sa.Numeric(10, 2), nullable=False),
        sa.Column("quantity", sa.Numeric(10, 2), nullable=False),
        schema="product",
    )


def downgrade() -> None:
    op.drop_table("product", schema="product")
    op.execute("DROP SCHEMA IF EXISTS product")
