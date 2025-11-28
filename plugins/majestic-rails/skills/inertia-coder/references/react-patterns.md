# Inertia.js React Patterns

## Table of Contents
- [Entry Point Setup](#entry-point-setup)
- [Page Components](#page-components)
- [Form Patterns](#form-patterns)
- [Advanced Patterns](#advanced-patterns)
- [Performance](#performance)
- [Testing](#testing)

## Entry Point Setup

```javascript
// app/frontend/entrypoints/application.js
import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'
import '../styles/application.css'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.jsx', { eager: true })
    const page = pages[`../pages/${name}.jsx`]

    if (!page) {
      throw new Error(`Page not found: ${name}`)
    }

    return page
  },

  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },

  progress: {
    delay: 250,
    color: '#29d',
    includeCSS: true,
    showSpinner: true
  }
})
```

## Page Components

### Complete Index Page

```jsx
// app/frontend/pages/Articles/Index.jsx
import { Link, usePage, router } from '@inertiajs/react'
import { useState, useMemo } from 'react'
import debounce from 'lodash/debounce'
import AppLayout from '@/layouts/AppLayout'

export default function Index({ articles, pagination, filters }) {
  const { auth } = usePage().props
  const [search, setSearch] = useState(filters.search || '')

  const handleSearch = useMemo(
    () => debounce(value => {
      router.get('/articles', { search: value }, {
        preserveState: true,
        replace: true
      })
    }, 300),
    []
  )

  return (
    <div className="container mx-auto px-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Articles</h1>
        {auth.can?.('create', 'Article') && (
          <Link href="/articles/new" className="btn btn-primary">
            New Article
          </Link>
        )}
      </div>

      <input
        type="search"
        value={search}
        onChange={e => {
          setSearch(e.target.value)
          handleSearch(e.target.value)
        }}
        placeholder="Search articles..."
        className="form-input w-full mb-6"
      />

      <div className="grid gap-4">
        {articles.map(article => (
          <Link
            key={article.id}
            href={`/articles/${article.id}`}
            className="card hover:shadow-lg transition"
          >
            <h2 className="text-xl font-semibold">{article.title}</h2>
            <p className="text-gray-600">{article.excerpt}</p>
          </Link>
        ))}
      </div>

      {pagination.total_pages > 1 && (
        <Pagination pagination={pagination} />
      )}
    </div>
  )
}

Index.layout = page => <AppLayout>{page}</AppLayout>
```

### Complete Form Page

```jsx
// app/frontend/pages/Articles/Form.jsx
import { useForm, Link } from '@inertiajs/react'
import { useEffect } from 'react'

export default function Form({ article }) {
  const isEdit = !!article

  const { data, setData, post, put, processing, errors, reset } = useForm({
    title: article?.title || '',
    body: article?.body || '',
    excerpt: article?.excerpt || '',
    published: article?.published || false
  })

  function handleSubmit(e) {
    e.preventDefault()

    if (isEdit) {
      put(`/articles/${article.id}`, {
        preserveScroll: true,
        onSuccess: () => reset()
      })
    } else {
      post('/articles', { preserveScroll: true })
    }
  }

  // Auto-generate excerpt from body
  useEffect(() => {
    if (!data.excerpt && data.body) {
      setData('excerpt', data.body.slice(0, 200))
    }
  }, [data.body])

  return (
    <form onSubmit={handleSubmit} className="space-y-6 max-w-2xl">
      <div>
        <label htmlFor="title" className="block font-semibold mb-2">
          Title *
        </label>
        <input
          id="title"
          type="text"
          value={data.title}
          onChange={e => setData('title', e.target.value)}
          className={`form-input w-full ${errors.title ? 'border-red-500' : ''}`}
          disabled={processing}
        />
        {errors.title && (
          <div className="text-red-600 text-sm mt-1">{errors.title}</div>
        )}
      </div>

      <div>
        <label htmlFor="body" className="block font-semibold mb-2">
          Body *
        </label>
        <textarea
          id="body"
          value={data.body}
          onChange={e => setData('body', e.target.value)}
          rows="15"
          className={`form-input w-full ${errors.body ? 'border-red-500' : ''}`}
          disabled={processing}
        />
        {errors.body && (
          <div className="text-red-600 text-sm mt-1">{errors.body}</div>
        )}
      </div>

      <label className="flex items-center">
        <input
          type="checkbox"
          checked={data.published}
          onChange={e => setData('published', e.target.checked)}
          className="mr-2"
          disabled={processing}
        />
        <span>Publish immediately</span>
      </label>

      <div className="flex gap-4">
        <button
          type="submit"
          disabled={processing}
          className="btn btn-primary"
        >
          {processing ? 'Saving...' : (isEdit ? 'Update' : 'Create')}
        </button>
        <Link href="/articles" className="btn btn-secondary">
          Cancel
        </Link>
      </div>
    </form>
  )
}
```

## Form Patterns

### Form with Transform

```jsx
const { data, setData, transform, post } = useForm({
  title: '',
  tags: ''
})

// Transform before submission
transform(data => ({
  ...data,
  tags: data.tags.split(',').map(t => t.trim())
}))
```

### Form Reset and Dirty State

```jsx
const { data, setData, isDirty, reset, clearErrors } = useForm({
  title: ''
})

// Check if form has unsaved changes
if (isDirty) {
  // Prompt user before leaving
}

// Reset to original values
reset()

// Reset specific fields
reset('title', 'body')

// Clear validation errors
clearErrors()
clearErrors('title')
```

### Delete with Confirmation

```jsx
import { router } from '@inertiajs/react'

function handleDelete(article) {
  if (confirm(`Delete "${article.title}"?`)) {
    router.delete(`/articles/${article.id}`, {
      preserveScroll: true
    })
  }
}
```

## Advanced Patterns

### Modal Windows

```jsx
import { useState } from 'react'
import { router } from '@inertiajs/react'

export default function Index({ articles, showModal, modalArticle }) {
  function openModal(article) {
    router.get(`/articles/${article.id}/modal`, {}, {
      preserveState: true,
      only: ['showModal', 'modalArticle']
    })
  }

  function closeModal() {
    router.get('/articles', {}, {
      preserveState: true,
      only: ['showModal', 'modalArticle']
    })
  }

  return (
    <>
      {articles.map(article => (
        <button key={article.id} onClick={() => openModal(article)}>
          Quick View
        </button>
      ))}

      {showModal && (
        <Modal onClose={closeModal}>
          <h2>{modalArticle.title}</h2>
          <p>{modalArticle.body}</p>
        </Modal>
      )}
    </>
  )
}
```

### Infinite Scrolling

```jsx
import { router } from '@inertiajs/react'
import { useEffect, useState, useRef } from 'react'

export default function InfiniteList({ articles, pagination }) {
  const [allArticles, setAllArticles] = useState(articles)
  const [loading, setLoading] = useState(false)
  const sentinel = useRef()

  function loadMore() {
    if (loading || !pagination.has_next_page) return

    setLoading(true)
    router.get(`/articles?page=${pagination.current_page + 1}`, {}, {
      preserveState: true,
      preserveScroll: true,
      only: ['articles', 'pagination'],
      onSuccess: (page) => {
        setAllArticles(prev => [...prev, ...page.props.articles])
        setLoading(false)
      }
    })
  }

  useEffect(() => {
    const observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) loadMore()
    })

    if (sentinel.current) observer.observe(sentinel.current)
    return () => observer.disconnect()
  }, [pagination])

  return (
    <div>
      {allArticles.map(article => (
        <ArticleCard key={article.id} article={article} />
      ))}

      {pagination.has_next_page && (
        <div ref={sentinel} className="py-4 text-center">
          {loading ? 'Loading...' : 'Scroll for more'}
        </div>
      )}
    </div>
  )
}
```

### Optimistic Updates

```jsx
import { router } from '@inertiajs/react'
import { useState } from 'react'

export default function LikeButton({ article }) {
  const [liked, setLiked] = useState(article.liked_by_current_user)
  const [count, setCount] = useState(article.likes_count)

  function toggleLike() {
    // Optimistic update
    setLiked(!liked)
    setCount(liked ? count - 1 : count + 1)

    router.post(`/articles/${article.id}/like`, {}, {
      preserveScroll: true,
      onError: () => {
        // Revert on error
        setLiked(liked)
        setCount(count)
      }
    })
  }

  return (
    <button onClick={toggleLike}>
      {liked ? '❤️' : '🤍'} {count}
    </button>
  )
}
```

## Performance

### Lazy Loading Pages

```javascript
// Lazy load instead of eager
createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.jsx')
    return pages[`../pages/${name}.jsx`]()
  }
})
```

### Partial Reloads

```ruby
# Rails controller - lazy props
def index
  render inertia: 'Articles/Index', props: {
    articles: -> { Article.all.as_json },
    categories: InertiaRails.lazy(-> { Category.all.as_json })
  }
end
```

```jsx
// React - request specific data
router.reload({ only: ['articles'] })
```

### Prefetching

```jsx
function ArticleLink({ article }) {
  return (
    <Link
      href={`/articles/${article.id}`}
      onMouseEnter={() => router.prefetch(`/articles/${article.id}`)}
    >
      {article.title}
    </Link>
  )
}
```

## Testing

### Component Testing

```javascript
// Vitest + React Testing Library
import { render, screen, fireEvent } from '@testing-library/react'
import Index from '@/pages/Articles/Index'

describe('Articles Index', () => {
  const articles = [
    { id: 1, title: 'First', excerpt: 'Excerpt 1' },
    { id: 2, title: 'Second', excerpt: 'Excerpt 2' }
  ]

  it('renders articles', () => {
    render(<Index articles={articles} pagination={{}} filters={{}} />)

    expect(screen.getByText('First')).toBeInTheDocument()
    expect(screen.getByText('Second')).toBeInTheDocument()
  })

  it('handles search', async () => {
    render(<Index articles={articles} pagination={{}} filters={{}} />)

    const input = screen.getByPlaceholderText('Search articles...')
    fireEvent.change(input, { target: { value: 'test' } })

    expect(input.value).toBe('test')
  })
})
```

### Integration Testing (RSpec)

```ruby
RSpec.describe "Articles", type: :system, js: true do
  it "creates article via Inertia form" do
    visit new_article_path

    fill_in "Title", with: "My Article"
    fill_in "Body", with: "Article content"
    click_button "Create"

    expect(page).to have_text("Article created")
  end
end
```
