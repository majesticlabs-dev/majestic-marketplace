---
name: react-testing
description: Testing patterns for Vitest, React Testing Library, and Jest. Routes to component, hook, and integration test examples.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# React Testing

## Overview

This skill provides comprehensive guidance for testing React applications using Vitest, React Testing Library, and Jest. Apply these patterns when writing unit tests, integration tests, and ensuring code quality.

## Core Philosophy

- **Test behavior, not implementation**: Focus on what users see and do
- **Avoid testing internal state**: Test public APIs and user interactions
- **Write tests that give confidence**: Catch real bugs, not false positives
- **Keep tests simple**: Tests should be easier to understand than the code

## Testing Tools

### Vitest Configuration

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/test/']
    }
  }
});
```

### Test Setup

```ts
// src/test/setup.ts
import { expect, afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';
import * as matchers from '@testing-library/jest-dom/matchers';

expect.extend(matchers);

afterEach(() => {
  cleanup();
});
```

## Component Testing

### Basic Component Test

```tsx
import { render, screen } from '@testing-library/react';
import { expect, test } from 'vitest';
import { Button } from './Button';

test('renders button with label', () => {
  render(<Button label="Click me" onClick={vi.fn()} />);
  expect(screen.getByText('Click me')).toBeInTheDocument();
});

test('calls onClick when clicked', async () => {
  const handleClick = vi.fn();
  render(<Button label="Click me" onClick={handleClick} />);

  await userEvent.click(screen.getByRole('button'));
  expect(handleClick).toHaveBeenCalledTimes(1);
});

test('is disabled when prop is set', () => {
  render(<Button label="Click me" onClick={vi.fn()} disabled />);
  expect(screen.getByRole('button')).toBeDisabled();
});
```

### Form Testing

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

test('submits form with email and password', async () => {
  const handleSubmit = vi.fn();
  render(<LoginForm onSubmit={handleSubmit} />);

  await userEvent.type(screen.getByLabelText('Email'), 'user@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'password123');
  await userEvent.click(screen.getByRole('button', { name: 'Login' }));

  await waitFor(() => {
    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'user@example.com',
      password: 'password123'
    });
  });
});

test('shows validation error for invalid email', async () => {
  render(<LoginForm onSubmit={vi.fn()} />);

  await userEvent.type(screen.getByLabelText('Email'), 'invalid-email');
  await userEvent.click(screen.getByRole('button', { name: 'Login' }));

  expect(await screen.findByText('Invalid email address')).toBeInTheDocument();
});
```

## Hook Testing

### Custom Hook Test

```tsx
import { renderHook, act } from '@testing-library/react';
import { expect, test } from 'vitest';
import { useCounter } from './useCounter';

test('increments counter', () => {
  const { result } = renderHook(() => useCounter());

  expect(result.current.count).toBe(0);

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});

test('decrements counter', () => {
  const { result } = renderHook(() => useCounter(10));

  act(() => {
    result.current.decrement();
  });

  expect(result.current.count).toBe(9);
});
```

### Hook with Dependencies

```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { useApi } from './useApi';

test('fetches data successfully', async () => {
  global.fetch = vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ name: 'John' })
    })
  ) as any;

  const { result } = renderHook(() => useApi('/api/user'));

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.data).toEqual({ name: 'John' });
  expect(result.current.error).toBeNull();
});

test('handles error', async () => {
  global.fetch = vi.fn(() =>
    Promise.reject(new Error('Network error'))
  );

  const { result } = renderHook(() => useApi('/api/user'));

  await waitFor(() => {
    expect(result.current.error).toBeTruthy();
  });

  expect(result.current.data).toBeUndefined();
});
```

## Integration Testing

### With Context

```tsx
import { render, screen } from '@testing-library/react';
import { AuthProvider } from './AuthContext';
import { Dashboard } from './Dashboard';

const renderWithAuth = (ui: ReactElement, { user = null } = {}) => {
  return render(
    <AuthProvider value={{ user }}>
      {ui}
    </AuthProvider>
  );
};

test('shows dashboard when authenticated', () => {
  renderWithAuth(<Dashboard />, { user: { name: 'John' } });
  expect(screen.getByText('Welcome, John')).toBeInTheDocument();
});

test('redirects to login when not authenticated', () => {
  renderWithAuth(<Dashboard />);
  expect(screen.queryByText('Welcome')).not.toBeInTheDocument();
});
```

### With Router

```tsx
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { App } from './App';

test('navigates to profile page', async () => {
  render(
    <MemoryRouter initialEntries={['/profile']}>
      <App />
    </MemoryRouter>
  );

  expect(screen.getByText('User Profile')).toBeInTheDocument();
});
```

## Mocking

### API Mocking

```tsx
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(
      ctx.json([
        { id: '1', name: 'John' },
        { id: '2', name: 'Jane' }
      ])
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('displays users from API', async () => {
  render(<UserList />);

  expect(await screen.findByText('John')).toBeInTheDocument();
  expect(await screen.findByText('Jane')).toBeInTheDocument();
});
```

### Component Mocking

```tsx
import { vi } from 'vitest';

vi.mock('./HeavyComponent', () => ({
  HeavyComponent: () => <div>Mocked Component</div>
}));

test('renders page with mocked component', () => {
  render(<Dashboard />);
  expect(screen.getByText('Mocked Component')).toBeInTheDocument();
});
```

## Accessibility Testing

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('has no accessibility violations', async () => {
  const { container } = render(<LoginForm onSubmit={vi.fn()} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

## Best Practices

1. **Use semantic queries**: `getByRole`, `getByLabelText` over `getByTestId`
2. **Test user behavior**: Click, type, navigate like users do
3. **Avoid implementation details**: Don't test state or props directly
4. **Use `findBy` for async**: Automatically waits for elements
5. **Clean up**: Use `afterEach(cleanup)` to reset DOM
6. **Mock external dependencies**: APIs, timers, modules
7. **Test error states**: Loading, error, empty states
8. **Keep tests focused**: One assertion per test when possible
9. **Use descriptive test names**: Describe what should happen
10. **Run tests in CI/CD**: Ensure tests pass before deployment
