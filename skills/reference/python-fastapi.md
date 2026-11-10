# Python/FastAPI Review Reference

Bugs, security, and performance patterns only. No style/lint content — ruff/black own that.

## Async bugs

```python
# ❌ Blocking call inside an async route — stalls the event loop for all requests
@app.get("/users/{id}")
async def get_user(id: int):
    result = requests.get(f"http://api/users/{id}")  # blocking I/O
    return result.json()
# Fix: use an async client (httpx.AsyncClient) or run_in_executor for blocking calls

# ❌ CPU-heavy work in an async route — blocks the whole event loop
@app.post("/process")
async def process(data: Data):
    return heavy_computation(data)  # blocks other requests
# Fix: offload to a thread/process pool (run_in_executor, background worker/queue)

# ❌ Sync DB driver used with async route — negates async benefits
async def get_items(db: Session = Depends(get_db)):
    return db.query(Item).all()  # sync ORM call blocks loop
# Fix: use an async driver/ORM (asyncpg, SQLAlchemy async session) consistently

# ❌ Fire-and-forget task with unhandled exception
asyncio.create_task(send_email(user))  # exception silently swallowed
# Fix: await it, or attach a done-callback that logs/handles exceptions
```

## Security

```python
# ❌ SQL built via string formatting — injection risk
db.execute(f"SELECT * FROM users WHERE name = '{name}'")
# Fix: use parameterized queries / ORM query builder, never interpolate input

# ❌ Missing auth/authorization check on a route with sensitive data
@app.get("/admin/users")
async def list_users():
    return db.query(User).all()  # no auth dependency
# Fix: add Depends(require_admin) or equivalent auth guard

# ❌ Pydantic model too permissive — mass assignment risk
class UserUpdate(BaseModel):
    is_admin: bool  # client can set this on their own profile update
# Fix: exclude privileged fields from client-writable schemas; set them server-side

# ❌ Secrets/credentials hardcoded or logged
logger.info(f"Connecting with password={db_password}")
API_KEY = "sk-abc123..."
# Fix: load from environment/secret manager, never log secrets

# ❌ Unrestricted CORS in production
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True)
# Fix: restrict allow_origins to known hosts, especially with credentials enabled

# ❌ Path/file parameter used without validation — path traversal
@app.get("/files/{filename}")
async def get_file(filename: str):
    return FileResponse(f"/data/{filename}")  # "../../etc/passwd"
# Fix: validate/sanitize filename, resolve path and confirm it stays under base dir
```

## Good patterns to encourage

```python
# ✅ Async DB dependency via yield — commit/cleanup happens automatically
async def get_db(pool = Depends(get_pool)) -> AsyncGenerator[AsyncConnection, None]:
    async with pool.connection() as conn:
        yield conn
        await conn.commit()

# ✅ Centralized authorization via Depends/Security, not ad-hoc per-route checks
@router.get("/projects/{id}", dependencies=[Depends(require_project_access)])
async def get_project(id: int): ...
```

## SQL injection via identifiers (not just values)

```python
# ❌ f-string used for identifiers (schema/table/column names) — not fixed by
# parameterized queries, since bind params only cover values, not identifiers
conn.execute(f"DROP SCHEMA IF EXISTS {schema_name} CASCADE")
# Fix: validate identifiers against an allowlist, or use a quoting helper
# (e.g. sqlalchemy.sql.quoted_name / psycopg identifier composition)
```

## Blocking calls hidden inside async auth/dependency code

```python
# ❌ Sync HTTP call or token acquisition (e.g. MSAL) inside an async dependency
# used by every request — blocks the event loop for all concurrent requests
async def get_current_user(request: Request):
    token = msal_client.acquire_token_silent(...)  # sync call
    roles = requests.get(f"{API}/roles", timeout=5).json()  # sync call
    return roles
# Fix: use async MSAL/HTTP clients, or run_in_executor for unavoidable sync SDKs

# ❌ Fan-out of async work per item without bounding concurrency or checking
# for per-item DB/HTTP calls inside the gathered coroutine (N+1 in disguise)
results = await asyncio.gather(*[process(item_id) for item_id in item_ids])
# Fix: batch-fetch shared data once before the gather; bound concurrency with
# a semaphore if item_ids can be large
```

## Correctness / common traps

```python
# ❌ Mutable default argument — shared state across calls
def add_item(item, items=[]):
    items.append(item)
    return items
# Fix: use items: list | None = None, then items = items or []

# ❌ Bare except swallowing errors (including KeyboardInterrupt/SystemExit)
try:
    do_work()
except:
    pass
# Fix: except Exception as e: (never bare except), log or re-raise

# ❌ Broad exception catch hiding real bugs
try:
    result = risky_call()
except Exception:
    result = None  # silently masks the actual error
# Fix: catch specific exceptions, log unexpected ones

# ❌ Comparing with `is` for value equality
if status is "active":
# Fix: use == for value comparison; `is` only for None/singleton identity
```

## Performance / resource management

```python
# ❌ N+1 query pattern in a loop
for order in orders:
    customer = db.query(Customer).get(order.customer_id)  # one query per order
# Fix: eager-load (joinedload/selectinload) or batch-fetch with a single query

# ❌ Loading entire table/result set into memory
users = db.query(User).all()  # millions of rows
# Fix: paginate, stream results, or use .yield_per()/cursor-based iteration

# ❌ Unbounded response size / no pagination on a list endpoint
@app.get("/items")
async def list_items():
    return db.query(Item).all()
# Fix: add limit/offset or cursor-based pagination with a max page size

# ❌ Opening a new DB/HTTP connection per request instead of pooling
async def get_data():
    conn = await asyncpg.connect(DSN)  # new connection every call
# Fix: reuse a connection pool (Depends on a shared pool/session)

# ❌ Missing timeout on outbound HTTP calls — request can hang indefinitely
async with httpx.AsyncClient() as client:
    await client.get(url)  # no timeout
# Fix: httpx.AsyncClient(timeout=...) with sane connect/read timeouts
```

## FastAPI-specific

```python
# ❌ Mutable/shared object used as a dependency singleton without care
def get_cache():
    return {}  # new dict each call actually fine here, but watch for module-level
               # mutable globals shared across concurrent requests
# Fix: use Depends with proper lifecycle (yield-based) for stateful resources

# ❌ Missing response_model — leaks internal fields (password hashes, etc.)
@app.get("/users/{id}")
async def get_user(id: int) -> User:  # User ORM model includes hashed_password
    return db.query(User).get(id)
# Fix: define/return a response_model schema that excludes sensitive fields

# ❌ Validation only at the API boundary is skipped internally
def internal_helper(data: dict):  # bypasses Pydantic validation entirely
    process(data["email"])  # KeyError if missing
# Fix: pass validated Pydantic models through internal call chains, not raw dicts
```

## Review checklist

- [ ] No blocking/sync calls inside async def routes
- [ ] CPU-heavy work offloaded, not run inline in async handlers
- [ ] All SQL parameterized, no string-built queries
- [ ] Auth/authorization present on sensitive/privileged routes
- [ ] Client-writable schemas exclude privileged fields
- [ ] No secrets hardcoded or logged
- [ ] CORS restricted appropriately
- [ ] User-supplied paths/filenames validated against traversal
- [ ] No mutable default arguments
- [ ] No bare/overly broad except blocks hiding errors
- [ ] No N+1 queries; batch/eager-load where needed
- [ ] List endpoints paginated with a max page size
- [ ] Outbound HTTP/DB calls have timeouts and use pooling
- [ ] response_model used to avoid leaking internal/sensitive fields
- [ ] Identifiers (schema/table/column names) built from input are validated/allowlisted, not just parameterized as values
- [ ] Async dependencies (auth, token acquisition) use async clients, not sync SDKs/HTTP calls
- [ ] `asyncio.gather`/fan-out over a collection doesn't hide per-item N+1 DB/HTTP calls
