# Database changes

The finalized SRS is unchanged. Supabase is the shared development database; Cloud SQL remains the intended deployment target.

Create an isolated workspace with the coordinator tool before applying migrations. Use the owner's private migration credential, not the application's CRUD-only credential:

```powershell
python backend/tools/workspace.py create dev1 --output .secrets/dev1.json
# Set DATABASE_URL to DATABASE_ADMIN_URL privately; set DATABASE_SCHEMA=dev1.
python -m alembic -c backend/alembic.ini upgrade head
```

Run from the repository root. The migration sets the workspace owner role. Keep one linear Alembic head and resolve revision conflicts before merge. The coordinator applies reviewed integration migrations explicitly with `python backend/tools/migrate.py integration`.

The old public-schema init.sql is historical scaffolding only. It is not run by the foundation. Existing local Docker volumes/public tables are not deleted, reset or imported. If they contain wanted data, export and review it before a separate migration; do not match Firebase identities by email.

Downgrades are allowed only against disposable test configuration. Review destructive changes explicitly. Never reset integration or another developer's workspace to solve a local issue.
