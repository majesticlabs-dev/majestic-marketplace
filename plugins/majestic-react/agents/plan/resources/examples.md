# React Architecture Examples

## Context API Pattern

```tsx
const AuthContext = createContext<AuthState | null>(null);

const AuthProvider = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  );
};
```

## URL State Pattern

```tsx
const [searchParams, setSearchParams] = useSearchParams();
const filter = searchParams.get('filter') ?? 'all';
```

## Server State Pattern (React Query)

```tsx
const { data, isLoading } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers
});
```

## Global State Pattern (Zustand)

```tsx
const useStore = create<StoreState>((set) => ({
  cart: [],
  addToCart: (item) => set((state) => ({
    cart: [...state.cart, item]
  }))
}));
```

## Simple Data Fetching

```tsx
const Dashboard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard')
      .then(res => res.json())
      .then(setData)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Spinner />;
  return <DashboardView data={data} />;
};
```

## React Query Pattern

```tsx
const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetch('/api/users');
      if (!res.ok) throw new Error('Failed to fetch');
      return res.json();
    },
    staleTime: 5 * 60 * 1000 // 5 minutes
  });
};
```

## Code Splitting

```tsx
// Route-based splitting
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Reports = lazy(() => import('./pages/Reports'));

// Component-based splitting for heavy components
const DataVisualization = lazy(() => import('./components/DataVisualization'));
```

## Memoization Strategy

```tsx
// Parent component
const ProductList = ({ products, category }) => {
  // Memoize expensive filter
  const filtered = useMemo(
    () => products.filter(p => p.category === category),
    [products, category]
  );

  // Memoize callback
  const handleSelect = useCallback((id: string) => {
    console.log('Selected:', id);
  }, []);

  return (
    <div>
      {filtered.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onSelect={handleSelect}
        />
      ))}
    </div>
  );
};

// Child component - memoized
const ProductCard = memo(({ product, onSelect }) => {
  return (
    <div onClick={() => onSelect(product.id)}>
      {product.name}
    </div>
  );
});
```

## Virtual Scrolling (TanStack Virtual)

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

const LargeList = ({ items }) => {
  const parentRef = useRef(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50
  });

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map(virtualItem => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualItem.size}px`,
              transform: `translateY(${virtualItem.start}px)`
            }}
          >
            {items[virtualItem.index].name}
          </div>
        ))}
      </div>
    </div>
  );
};
```

## React Router Pattern

```tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/users/:id" element={<UserProfile />} />
    </Routes>
  </BrowserRouter>
);
```

## Protected Routes

```tsx
const ProtectedRoute = ({ children }) => {
  const { user } = useAuth();
  return user ? children : <Navigate to="/login" />;
};

const App = () => (
  <Routes>
    <Route path="/login" element={<Login />} />
    <Route
      path="/dashboard"
      element={
        <ProtectedRoute>
          <Dashboard />
        </ProtectedRoute>
      }
    />
  </Routes>
);
```

## Error Boundary Strategy

```tsx
// Global error boundary
<ErrorBoundary fallback={<ErrorPage />}>
  <App />
</ErrorBoundary>

// Feature-level error boundaries
<Dashboard>
  <ErrorBoundary fallback={<WidgetError />}>
    <StatsWidget />
  </ErrorBoundary>
  <ErrorBoundary fallback={<WidgetError />}>
    <ChartWidget />
  </ErrorBoundary>
</Dashboard>
```

## Centralized API Error Handler

```tsx
const handleApiError = (error: Error) => {
  if (error.message.includes('401')) {
    window.location.href = '/login';
  } else if (error.message.includes('500')) {
    toast.error('Server error. Please try again.');
  }
};

// In React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      onError: handleApiError
    }
  }
});
```

## Unit Testing Examples

```tsx
// Hook test
test('useCounter increments count', () => {
  const { result } = renderHook(() => useCounter());
  act(() => result.current.increment());
  expect(result.current.count).toBe(1);
});

// Component test
test('Button renders with label', () => {
  render(<Button label="Click me" onClick={vi.fn()} />);
  expect(screen.getByText('Click me')).toBeInTheDocument();
});
```

## Integration Testing Example

```tsx
test('user can login', async () => {
  render(<LoginForm />);

  await userEvent.type(screen.getByLabelText('Email'), 'user@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'password');
  await userEvent.click(screen.getByRole('button', { name: 'Login' }));

  await waitFor(() => {
    expect(screen.getByText('Welcome back!')).toBeInTheDocument();
  });
});
```

## Accessible Modal

```tsx
const Modal = ({ isOpen, onClose, children }) => {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      modalRef.current?.focus();
    }
  }, [isOpen]);

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') onClose();
  };

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
      onKeyDown={handleKeyDown}
    >
      {children}
      <button onClick={onClose} aria-label="Close modal">
        ×
      </button>
    </div>
  );
};
```
