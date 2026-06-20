from __future__ import annotations

import sys
import asyncio
from datetime import datetime, timezone
from pathlib import Path

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine


APP_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(APP_ROOT / "marginalia-backend"))

from marginalia.db.models import AuditEvent, Base, EntryTag, File, FileEntry, Tag  # noqa: E402
from marginalia.pipelines.base import PipelineResult, TagSuggestion  # noqa: E402
from marginalia.tasks.handlers.ingest_file import _persist  # noqa: E402


async def _run_persist_deduplicates_pipeline_tag_suggestions() -> None:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

        session_factory = async_sessionmaker(engine, expire_on_commit=False)
        now = datetime.now(timezone.utc)

        async with session_factory() as session:
            session.add_all(
                [
                    File(
                        id="file-1",
                        storage_key="vault/test.md",
                        sha256="a" * 64,
                        size_bytes=42,
                        mime_type="text/markdown",
                        original_ext=".md",
                        ingest_status="pending",
                        created_at=now,
                        updated_at=now,
                    ),
                    FileEntry(
                        id="entry-1",
                        folder_id=None,
                        file_id="file-1",
                        display_name="test.md",
                        lifecycle="active",
                        created_at=now,
                        updated_at=now,
                    ),
                ]
            )
            await session.commit()

        result = PipelineResult(
            summary="summary",
            description={"sections": []},
            kind="text",
            extra=None,
            entry_extra=None,
            entry_catalog_path=None,
            entry_tags=[
                TagSuggestion(name="CSR", facet="topic"),
                TagSuggestion(name="CSR", facet="topic"),
            ],
        )

        async with session_factory() as session:
            await _persist(session, file_id="file-1", entry_id="entry-1", result=result)
            await session.commit()

        async with session_factory() as session:
            entry_tag_count = await session.scalar(select(func.count()).select_from(EntryTag))
            tags = list((await session.execute(select(Tag))).scalars())
            done_payload = await session.scalar(
                select(AuditEvent.payload).where(
                    AuditEvent.kind == "ingest_status_changed",
                    AuditEvent.payload["status"].as_string() == "done",
                )
            )

        assert entry_tag_count == 1
        assert len(tags) == 1
        assert tags[0].doc_count == 1
        assert done_payload is not None
        assert done_payload["tag_count"] == 1
    finally:
        await engine.dispose()


def test_persist_deduplicates_pipeline_tag_suggestions() -> None:
    asyncio.run(_run_persist_deduplicates_pipeline_tag_suggestions())


if __name__ == "__main__":
    test_persist_deduplicates_pipeline_tag_suggestions()
