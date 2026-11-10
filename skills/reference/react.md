# React/TypeScript Review Reference

Bugs, security, and performance patterns only. No style/lint content — biome/eslint/prettier own that.

## Hooks bugs

```tsx
// ❌ Conditional hook call — breaks Rules of Hooks
function Bad({ isLoggedIn }) {
  if (isLoggedIn) {
    const [user, setUser] = useState(null); // crashes on mismatched renders
  }
}

// ❌ Missing/incomplete dependency array — stale closure bug
useEffect(() => {
  fetchUser(userId).then(setUser);
}, []); // userId not tracked; effect never re-runs when it changes

// ❌ Missing cleanup — race condition / setState after unmount
useEffect(() => {
  fetchUser(userId).then(setUser); // no cancellation
}, [userId]);
// Fix: track a cancelled flag or use AbortController, bail out in cleanup

// ❌ useEffect used for derived state — extra render + bug-prone
useEffect(() => {
  setFilteredItems(items.filter(i => i.active));
}, [items]);
// Fix: compute during render (optionally with useMemo), don't store in state
```

## Security

```tsx
// ❌ dangerouslySetInnerHTML with unsanitized input — XSS
<div dangerouslySetInnerHTML={{ __html: userComment }} />
// Fix: sanitize with DOMPurify, or better, render via a markdown/rich-text
// component (e.g. react-markdown) instead of raw HTML injection

// ❌ Building URLs/queries from user input without encoding
window.location.href = `/search?q=${userInput}`;
// Fix: encodeURIComponent(userInput)

// ❌ Storing tokens/secrets in localStorage accessible to any script
localStorage.setItem('authToken', token);
// Fix: prefer httpOnly cookies for sensitive tokens

// ❌ Rendering user-controlled href without validating scheme
<a href={userProvidedUrl}>link</a>
// Fix: reject javascript: scheme, allow only http(s)
```

## Performance (real, measurable — not premature optimization)

```tsx
// ❌ Component defined inside another component — remounts every render,
// loses state, resets child effects
function Parent() {
  function Child() { return <div />; } // new identity every render
  return <Child />;
}
// Fix: hoist Child outside Parent

// ❌ Expensive computation on every render with no memoization
function List({ items }) {
  const sorted = items.slice().sort(expensiveCompare); // re-sorts every render
  return <ul>{sorted.map(...)}</ul>;
}
// Fix: useMemo(() => items.slice().sort(expensiveCompare), [items])

// ❌ New object/function identity breaking memoized children every render
<MemoizedChild style={{ color: 'red' }} onClick={() => {}} />
// Fix: hoist static style object; useCallback for onClick if passed to memo'd child

// ❌ Unbounded/uncleaned subscriptions, intervals, listeners
useEffect(() => {
  window.addEventListener('resize', handler);
}); // no deps, no cleanup -> listener leak on every render
// Fix: add [] deps and return () => window.removeEventListener(...)

// ❌ Rendering large unvirtualized lists
{items.map(item => <Row key={item.id} {...item} />)} // 10k+ items
// Fix: use virtualization (react-window/react-virtual) for large lists
```

## Async/data-fetching bugs

```tsx
// ❌ Fire-and-forget promise in event handler — unhandled rejection
function onSubmit() {
  saveData(form); // no await, no catch
}
// Fix: await and catch, or attach .catch(handleError)

// ❌ State update after component unmounts
useEffect(() => {
  let cancelled = false;
  fetchData().then(data => {
    if (!cancelled) setData(data);
  });
  return () => { cancelled = true; };
}, []);
// (this is the correct pattern — flag its absence, not its presence)

// ❌ Fetch effect without cancellation when the fetched key changes quickly —
// a slower earlier response can overwrite a later one (race condition)
useEffect(() => {
  fetchContent(path).then(setContent); // no guard against out-of-order responses
}, [path]);
// Fix: use an AbortController or a cancelled/staleness flag keyed on `path`,
// or use a data-fetching library (TanStack Query/SWR) that handles this

// ❌ Key derived from array index for reorderable/filterable lists
{items.map((item, i) => <Row key={i} {...item} />)}
// Fix: use a stable unique id as key to avoid state/identity bugs on reorder
```

## Server Components / RSC

```tsx
// ❌ Client-only hooks used in a Server Component
function ServerComp() {
  const [count, setCount] = useState(0); // Error: no hooks in RSC
}
// Fix: extract interactive logic into a 'use client' component

// ❌ Missing Suspense/Error Boundary around async server data
<DataComponent /> // no fallback, no error boundary — crashes whole tree
// Fix: wrap in <ErrorBoundary><Suspense fallback={...}>...</Suspense></ErrorBoundary>
```

## Review checklist

- [ ] Hooks called unconditionally at top level
- [ ] Effect dependency arrays complete and correct
- [ ] Async effects have cancellation/cleanup
- [ ] No XSS via dangerouslySetInnerHTML/unvalidated href
- [ ] No sensitive tokens in localStorage/sessionStorage
- [ ] Components not redefined inside render
- [ ] Expensive work memoized only where it has measurable cost
- [ ] Large lists virtualized
- [ ] Stable keys (not array index) for dynamic lists
- [ ] Promises in handlers are awaited/caught
