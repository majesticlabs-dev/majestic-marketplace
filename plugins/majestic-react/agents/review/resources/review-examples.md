# React Review Examples

## Component Structure

### Functional Components

```tsx
// FAIL: Class component for simple use case
class Button extends React.Component {
  render() {
    return <button>{this.props.label}</button>;
  }
}

// PASS: Functional component
const Button: FC<ButtonProps> = ({ label }) => {
  return <button>{label}</button>;
};
```

### TypeScript Typing

```tsx
// FAIL: Missing or weak types
const UserCard = ({ user }: any) => { ... }

// PASS: Explicit interface
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
  };
  onEdit?: (userId: string) => void;
}

const UserCard: FC<UserCardProps> = ({ user, onEdit }) => { ... }
```

### Component Composition

```tsx
// FAIL: Monolithic component
const Dashboard = () => {
  return (
    <div>
      <div className="header">...</div>
      <div className="sidebar">...</div>
      <div className="content">
        <div className="stats">...</div>
        <div className="charts">...</div>
        <div className="tables">...</div>
      </div>
    </div>
  );
};

// PASS: Composed components
const Dashboard = () => {
  return (
    <div>
      <Header />
      <Sidebar />
      <DashboardContent>
        <Stats />
        <Charts />
        <DataTable />
      </DashboardContent>
    </div>
  );
};
```

## Hooks Usage

### Dependency Arrays

```tsx
// FAIL: Missing dependencies
useEffect(() => {
  fetchUser(userId);
}, []); // userId should be in deps

// PASS: Complete dependencies
useEffect(() => {
  fetchUser(userId);
}, [userId]);

// FAIL: Object/function in deps without memoization
useEffect(() => {
  doSomething(config);
}, [config]); // Re-runs on every render if config is inline object

// PASS: Memoized dependencies
const config = useMemo(() => ({ api: apiUrl }), [apiUrl]);
useEffect(() => {
  doSomething(config);
}, [config]);
```

### Custom Hook Extraction

```tsx
// FAIL: Complex logic in component
const UserProfile = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/user')
      .then(res => res.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  // ... rest of component
};

// PASS: Extracted to custom hook
const useUser = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/user')
      .then(res => res.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  return { user, loading, error };
};

const UserProfile = () => {
  const { user, loading, error } = useUser();
  // ... rest of component
};
```

### Cleanup in useEffect

```tsx
// FAIL: No cleanup for subscriptions
useEffect(() => {
  const subscription = dataStream.subscribe(setData);
}, []);

// PASS: Proper cleanup
useEffect(() => {
  const subscription = dataStream.subscribe(setData);
  return () => subscription.unsubscribe();
}, []);

// FAIL: No abort controller for fetch
useEffect(() => {
  fetch('/api/data').then(res => res.json()).then(setData);
}, []);

// PASS: Abort controller
useEffect(() => {
  const controller = new AbortController();

  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') {
        console.error(err);
      }
    });

  return () => controller.abort();
}, []);
```

## Performance

### Unnecessary Re-renders

```tsx
// FAIL: Inline object/function props
<UserList
  users={users}
  config={{ sortBy: 'name' }}  // New object every render
  onSelect={(id) => console.log(id)}  // New function every render
/>

// PASS: Memoized props
const config = useMemo(() => ({ sortBy: 'name' }), []);
const handleSelect = useCallback((id: string) => {
  console.log(id);
}, []);

<UserList users={users} config={config} onSelect={handleSelect} />
```

### Memo Usage

```tsx
// FAIL: No memoization for expensive computation
const ProductList = ({ products, filter }) => {
  const filtered = products.filter(p => p.category === filter); // Runs every render
  return <div>{filtered.map(...)}</div>;
};

// PASS: useMemo for expensive computation
const ProductList = ({ products, filter }) => {
  const filtered = useMemo(
    () => products.filter(p => p.category === filter),
    [products, filter]
  );
  return <div>{filtered.map(...)}</div>;
};

// FAIL: Component re-renders unnecessarily
const ListItem = ({ item, onClick }) => {
  return <div onClick={() => onClick(item.id)}>{item.name}</div>;
};

// PASS: Memoized component
const ListItem = memo(({ item, onClick }) => {
  return <div onClick={() => onClick(item.id)}>{item.name}</div>;
});
```

### Key Props in Lists

```tsx
// FAIL: Index as key
{items.map((item, index) => <Item key={index} {...item} />)}

// FAIL: Non-unique key
{items.map(item => <Item key={item.name} {...item} />)}

// PASS: Stable unique key
{items.map(item => <Item key={item.id} {...item} />)}
```

## Accessibility (a11y)

### Semantic HTML

```tsx
// FAIL: Div buttons
<div onClick={handleClick}>Click me</div>

// PASS: Button element
<button onClick={handleClick}>Click me</button>

// FAIL: Non-semantic markup
<div className="nav">
  <div className="nav-item">Home</div>
</div>

// PASS: Semantic HTML
<nav>
  <a href="/">Home</a>
</nav>
```

### ARIA Labels

```tsx
// FAIL: Icon button without label
<button onClick={handleDelete}>
  <TrashIcon />
</button>

// PASS: aria-label for screen readers
<button onClick={handleDelete} aria-label="Delete item">
  <TrashIcon />
</button>

// FAIL: Form without labels
<input type="text" placeholder="Email" />

// PASS: Proper label
<label htmlFor="email">Email</label>
<input id="email" type="text" />
```

### Keyboard Navigation

```tsx
// FAIL: onClick on non-interactive element
<div onClick={handleClick}>Click me</div>

// PASS: Proper keyboard handling
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Click me
</div>

// BETTER: Use button
<button onClick={handleClick}>Click me</button>
```

## State Management

### Prop Drilling

```tsx
// FAIL: Excessive prop drilling
<App>
  <Header user={user} />
  <Main user={user}>
    <Sidebar user={user} />
    <Content user={user}>
      <Profile user={user} />
    </Content>
  </Main>
</App>

// PASS: Context for shared state
const UserContext = createContext<User | null>(null);

<UserContext.Provider value={user}>
  <App>
    <Header />
    <Main>
      <Sidebar />
      <Content>
        <Profile />
      </Content>
    </Main>
  </App>
</UserContext.Provider>

// In child components:
const user = useContext(UserContext);
```

### State Colocation

```tsx
// FAIL: Global state for local UI
const [isModalOpen, setIsModalOpen] = useState(false); // In app root

// PASS: Colocate state with usage
const Modal = () => {
  const [isOpen, setIsOpen] = useState(false);
  // ...
};
```

## Error Handling

### Error Boundaries

```tsx
// FAIL: No error boundary
<App>
  <Dashboard />
</App>

// PASS: Error boundary wrapping
<ErrorBoundary fallback={<ErrorPage />}>
  <App>
    <Dashboard />
  </App>
</ErrorBoundary>
```

### Loading and Error States

```tsx
// FAIL: No loading/error states
const Users = () => {
  const { data } = useApi('/api/users');
  return <div>{data.map(...)}</div>;
};

// PASS: Proper state handling
const Users = () => {
  const { data, loading, error } = useApi('/api/users');

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return null;

  return <div>{data.map(...)}</div>;
};
```

## Testing Considerations

```tsx
// FAIL: Hard to test - inline logic, no test IDs
const Dashboard = () => {
  const [data, setData] = useState([]);
  useEffect(() => {
    fetch('/api/data').then(r => r.json()).then(setData);
  }, []);
  return <div>{data.map(...)}</div>;
};

// PASS: Testable - extracted hook, test IDs
const useDashboardData = () => {
  const [data, setData] = useState([]);
  useEffect(() => {
    fetch('/api/data').then(r => r.json()).then(setData);
  }, []);
  return data;
};

const Dashboard = () => {
  const data = useDashboardData();
  return <div data-testid="dashboard">{data.map(...)}</div>;
};
```
