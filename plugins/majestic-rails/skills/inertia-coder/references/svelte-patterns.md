# Inertia.js Svelte Patterns

## Table of Contents
- [Entry Point Setup](#entry-point-setup)
- [Page Components](#page-components)
- [Form Patterns](#form-patterns)
- [Stores](#stores)
- [Testing](#testing)

## Entry Point Setup

```javascript
// app/frontend/entrypoints/application.js
import { createInertiaApp } from '@inertiajs/svelte'
import '../styles/application.css'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.svelte', { eager: true })
    return pages[`../pages/${name}.svelte`]
  },

  setup({ el, App }) {
    new App({ target: el })
  },

  progress: {
    color: '#29d'
  }
})
```

## Page Components

### Complete Index Page

```svelte
<!-- app/frontend/pages/Articles/Index.svelte -->
<script>
  import { Link, router, page } from '@inertiajs/svelte'
  import { debounce } from 'lodash'
  import AppLayout from '@/layouts/AppLayout.svelte'

  export let articles = []
  export let pagination = {}
  export let filters = {}

  $: auth = $page.props.auth

  let search = filters.search || ''

  const handleSearch = debounce((value) => {
    router.get('/articles', { search: value }, {
      preserveState: true,
      replace: true
    })
  }, 300)

  $: handleSearch(search)
</script>

<AppLayout>
  <div class="container mx-auto px-4">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Articles</h1>
      {#if auth.can?.('create', 'Article')}
        <Link href="/articles/new" class="btn btn-primary">
          New Article
        </Link>
      {/if}
    </div>

    <input
      bind:value={search}
      type="search"
      placeholder="Search articles..."
      class="form-input w-full mb-6"
    />

    <div class="grid gap-4">
      {#each articles as article (article.id)}
        <Link
          href="/articles/{article.id}"
          class="card hover:shadow-lg transition"
        >
          <h2 class="text-xl font-semibold">{article.title}</h2>
          <p class="text-gray-600">{article.excerpt}</p>
        </Link>
      {:else}
        <p class="text-gray-500">No articles found</p>
      {/each}
    </div>
  </div>
</AppLayout>
```

### Form Page

```svelte
<!-- app/frontend/pages/Articles/Form.svelte -->
<script>
  import { useForm, Link } from '@inertiajs/svelte'

  export let article = null

  $: isEdit = !!article

  let form = useForm({
    title: article?.title || '',
    body: article?.body || '',
    excerpt: article?.excerpt || '',
    published: article?.published || false
  })

  function handleSubmit() {
    if (isEdit) {
      $form.put(`/articles/${article.id}`, {
        preserveScroll: true
      })
    } else {
      $form.post('/articles', {
        preserveScroll: true
      })
    }
  }

  // Auto-generate excerpt
  $: if (!$form.excerpt && $form.body) {
    $form.excerpt = $form.body.slice(0, 200)
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6 max-w-2xl">
  <div>
    <label for="title" class="block font-semibold mb-2">Title *</label>
    <input
      id="title"
      bind:value={$form.title}
      type="text"
      class="form-input w-full"
      class:border-red-500={$form.errors.title}
      disabled={$form.processing}
    />
    {#if $form.errors.title}
      <div class="text-red-600 text-sm mt-1">{$form.errors.title}</div>
    {/if}
  </div>

  <div>
    <label for="body" class="block font-semibold mb-2">Body *</label>
    <textarea
      id="body"
      bind:value={$form.body}
      rows="15"
      class="form-input w-full"
      class:border-red-500={$form.errors.body}
      disabled={$form.processing}
    />
    {#if $form.errors.body}
      <div class="text-red-600 text-sm mt-1">{$form.errors.body}</div>
    {/if}
  </div>

  <label class="flex items-center">
    <input
      type="checkbox"
      bind:checked={$form.published}
      class="mr-2"
      disabled={$form.processing}
    />
    <span>Publish immediately</span>
  </label>

  <div class="flex gap-4">
    <button
      type="submit"
      disabled={$form.processing}
      class="btn btn-primary"
    >
      {$form.processing ? 'Saving...' : (isEdit ? 'Update' : 'Create')}
    </button>
    <Link href="/articles" class="btn btn-secondary">Cancel</Link>
  </div>
</form>
```

## Form Patterns

### Form with File Upload

```svelte
<script>
  import { useForm } from '@inertiajs/svelte'

  let form = useForm({
    avatar: null
  })

  function selectFile(event) {
    $form.avatar = event.target.files[0]
  }

  function upload() {
    $form.post('/profile/avatar', {
      forceFormData: true
    })
  }
</script>

<div>
  <input type="file" on:change={selectFile} />

  {#if $form.progress}
    <progress value={$form.progress.percentage} max="100" />
  {/if}

  <button on:click={upload} disabled={$form.processing}>
    Upload
  </button>
</div>
```

### Form Reset

```svelte
<script>
  import { useForm } from '@inertiajs/svelte'

  let form = useForm({
    title: ''
  })

  function reset() {
    $form.reset()
    // or reset specific fields
    $form.reset('title')
  }

  function clearErrors() {
    $form.clearErrors()
    // or specific field
    $form.clearErrors('title')
  }
</script>

{#if $form.isDirty}
  <p>You have unsaved changes</p>
{/if}

<button on:click={reset}>Reset</button>
```

## Stores

### Auth Store

```javascript
// app/frontend/stores/auth.js
import { derived } from 'svelte/store'
import { page } from '@inertiajs/svelte'

export const user = derived(page, $page => $page.props.auth?.user)
export const isLoggedIn = derived(user, $user => !!$user)

export function can(action, resource) {
  let result = false
  page.subscribe($page => {
    result = $page.props.auth?.can?.(action, resource)
  })()
  return result
}
```

```svelte
<script>
  import { user, isLoggedIn, can } from '@/stores/auth'
</script>

{#if $isLoggedIn}
  Welcome, {$user.name}
  {#if can('create', 'Article')}
    <button>New Article</button>
  {/if}
{/if}
```

### Flash Store

```javascript
// app/frontend/stores/flash.js
import { derived } from 'svelte/store'
import { page } from '@inertiajs/svelte'

export const flash = derived(page, $page => $page.props.flash || {})
export const success = derived(flash, $flash => $flash.success)
export const error = derived(flash, $flash => $flash.error)
export const notice = derived(flash, $flash => $flash.notice)
```

```svelte
<script>
  import { success, error } from '@/stores/flash'
</script>

{#if $success}
  <div class="alert alert-success">{$success}</div>
{/if}

{#if $error}
  <div class="alert alert-error">{$error}</div>
{/if}
```

## Layouts

### App Layout

```svelte
<!-- app/frontend/layouts/AppLayout.svelte -->
<script>
  import { Link, page } from '@inertiajs/svelte'

  $: auth = $page.props.auth
  $: flash = $page.props.flash
</script>

<div class="min-h-screen">
  <nav class="bg-white shadow">
    <div class="container mx-auto px-4 py-3">
      <Link href="/" class="font-bold">Home</Link>

      {#if auth.user}
        <span>{auth.user.name}</span>
        <Link href="/logout" method="delete">Logout</Link>
      {:else}
        <Link href="/login">Login</Link>
      {/if}
    </div>
  </nav>

  {#if flash.success}
    <div class="alert alert-success">{flash.success}</div>
  {/if}

  {#if flash.error}
    <div class="alert alert-error">{flash.error}</div>
  {/if}

  <main class="container mx-auto px-4 py-6">
    <slot />
  </main>
</div>
```

## Advanced Patterns

### Delete Confirmation

```svelte
<script>
  import { router } from '@inertiajs/svelte'

  export let article

  function handleDelete() {
    if (confirm(`Delete "${article.title}"?`)) {
      router.delete(`/articles/${article.id}`, {
        preserveScroll: true
      })
    }
  }
</script>

<button on:click={handleDelete} class="text-red-600">
  Delete
</button>
```

### Pagination Component

```svelte
<script>
  import { Link } from '@inertiajs/svelte'

  export let pagination
  export let baseUrl = '/articles'
</script>

{#if pagination.total_pages > 1}
  <div class="flex justify-center gap-2">
    {#if pagination.current_page > 1}
      <Link
        href="{baseUrl}?page={pagination.current_page - 1}"
        class="btn btn-secondary"
      >
        Previous
      </Link>
    {/if}

    {#each Array(pagination.total_pages) as _, i}
      <Link
        href="{baseUrl}?page={i + 1}"
        class="btn"
        class:btn-primary={i + 1 === pagination.current_page}
        class:btn-secondary={i + 1 !== pagination.current_page}
      >
        {i + 1}
      </Link>
    {/each}

    {#if pagination.current_page < pagination.total_pages}
      <Link
        href="{baseUrl}?page={pagination.current_page + 1}"
        class="btn btn-secondary"
      >
        Next
      </Link>
    {/if}
  </div>
{/if}
```

## Testing

### Component Testing

```javascript
import { render, screen } from '@testing-library/svelte'
import Index from '@/pages/Articles/Index.svelte'

describe('Articles Index', () => {
  const articles = [
    { id: 1, title: 'First', excerpt: 'Excerpt 1' },
    { id: 2, title: 'Second', excerpt: 'Excerpt 2' }
  ]

  it('renders articles', () => {
    render(Index, {
      props: {
        articles,
        pagination: {},
        filters: {}
      }
    })

    expect(screen.getByText('First')).toBeInTheDocument()
    expect(screen.getByText('Second')).toBeInTheDocument()
  })

  it('shows empty state', () => {
    render(Index, {
      props: {
        articles: [],
        pagination: {},
        filters: {}
      }
    })

    expect(screen.getByText('No articles found')).toBeInTheDocument()
  })
})
```
