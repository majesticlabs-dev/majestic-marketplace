# Inertia.js Vue 3 Patterns

## Table of Contents
- [Entry Point Setup](#entry-point-setup)
- [Page Components](#page-components)
- [Form Patterns](#form-patterns)
- [Composables](#composables)
- [Testing](#testing)

## Entry Point Setup

```javascript
// app/frontend/entrypoints/application.js
import { createInertiaApp } from '@inertiajs/vue3'
import { createApp, h } from 'vue'
import '../styles/application.css'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
    return pages[`../pages/${name}.vue`]
  },

  setup({ el, App, props, plugin }) {
    createApp({ render: () => h(App, props) })
      .use(plugin)
      .mount(el)
  },

  progress: {
    color: '#29d'
  }
})
```

## Page Components

### Complete Index Page

```vue
<!-- app/frontend/pages/Articles/Index.vue -->
<script setup>
import { Link, router, usePage } from '@inertiajs/vue3'
import { ref, computed } from 'vue'
import { debounce } from 'lodash'
import AppLayout from '@/layouts/AppLayout.vue'

const props = defineProps({
  articles: Array,
  pagination: Object,
  filters: Object
})

const page = usePage()
const auth = computed(() => page.props.auth)

const search = ref(props.filters.search || '')

const handleSearch = debounce((value) => {
  router.get('/articles', { search: value }, {
    preserveState: true,
    replace: true
  })
}, 300)
</script>

<template>
  <AppLayout>
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Articles</h1>
        <Link
          v-if="auth.can?.('create', 'Article')"
          href="/articles/new"
          class="btn btn-primary"
        >
          New Article
        </Link>
      </div>

      <input
        v-model="search"
        @input="handleSearch(search)"
        type="search"
        placeholder="Search articles..."
        class="form-input w-full mb-6"
      />

      <div class="grid gap-4">
        <Link
          v-for="article in articles"
          :key="article.id"
          :href="`/articles/${article.id}`"
          class="card hover:shadow-lg transition"
        >
          <h2 class="text-xl font-semibold">{{ article.title }}</h2>
          <p class="text-gray-600">{{ article.excerpt }}</p>
        </Link>
      </div>
    </div>
  </AppLayout>
</template>
```

### Form Page

```vue
<!-- app/frontend/pages/Articles/Form.vue -->
<script setup>
import { useForm, Link } from '@inertiajs/vue3'
import { computed, watch } from 'vue'

const props = defineProps({
  article: Object
})

const isEdit = computed(() => !!props.article)

const form = useForm({
  title: props.article?.title || '',
  body: props.article?.body || '',
  excerpt: props.article?.excerpt || '',
  published: props.article?.published || false
})

function handleSubmit() {
  if (isEdit.value) {
    form.put(`/articles/${props.article.id}`, {
      preserveScroll: true
    })
  } else {
    form.post('/articles', {
      preserveScroll: true
    })
  }
}

// Auto-generate excerpt
watch(() => form.body, (newBody) => {
  if (!form.excerpt && newBody) {
    form.excerpt = newBody.slice(0, 200)
  }
})
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6 max-w-2xl">
    <div>
      <label for="title" class="block font-semibold mb-2">Title *</label>
      <input
        id="title"
        v-model="form.title"
        type="text"
        :class="['form-input w-full', { 'border-red-500': form.errors.title }]"
        :disabled="form.processing"
      />
      <div v-if="form.errors.title" class="text-red-600 text-sm mt-1">
        {{ form.errors.title }}
      </div>
    </div>

    <div>
      <label for="body" class="block font-semibold mb-2">Body *</label>
      <textarea
        id="body"
        v-model="form.body"
        rows="15"
        :class="['form-input w-full', { 'border-red-500': form.errors.body }]"
        :disabled="form.processing"
      />
      <div v-if="form.errors.body" class="text-red-600 text-sm mt-1">
        {{ form.errors.body }}
      </div>
    </div>

    <label class="flex items-center">
      <input
        type="checkbox"
        v-model="form.published"
        class="mr-2"
        :disabled="form.processing"
      />
      <span>Publish immediately</span>
    </label>

    <div class="flex gap-4">
      <button
        type="submit"
        :disabled="form.processing"
        class="btn btn-primary"
      >
        {{ form.processing ? 'Saving...' : (isEdit ? 'Update' : 'Create') }}
      </button>
      <Link href="/articles" class="btn btn-secondary">Cancel</Link>
    </div>
  </form>
</template>
```

## Form Patterns

### Form with File Upload

```vue
<script setup>
import { useForm } from '@inertiajs/vue3'

const form = useForm({
  avatar: null
})

function selectFile(event) {
  form.avatar = event.target.files[0]
}

function upload() {
  form.post('/profile/avatar', {
    forceFormData: true
  })
}
</script>

<template>
  <div>
    <input type="file" @change="selectFile" />

    <progress
      v-if="form.progress"
      :value="form.progress.percentage"
      max="100"
    />

    <button @click="upload" :disabled="form.processing">
      Upload
    </button>
  </div>
</template>
```

### Form Reset and State

```vue
<script setup>
import { useForm } from '@inertiajs/vue3'

const form = useForm({
  title: ''
})

// Check dirty state
const canLeave = computed(() => !form.isDirty)

// Reset form
function reset() {
  form.reset()
  // or reset specific fields
  form.reset('title')
}

// Clear errors
function clearErrors() {
  form.clearErrors()
  // or specific field
  form.clearErrors('title')
}
</script>
```

## Composables

### useAuth Composable

```javascript
// app/frontend/composables/useAuth.js
import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

export function useAuth() {
  const page = usePage()

  const user = computed(() => page.props.auth?.user)
  const isLoggedIn = computed(() => !!user.value)

  function can(action, resource) {
    return page.props.auth?.can?.(action, resource)
  }

  return {
    user,
    isLoggedIn,
    can
  }
}
```

```vue
<script setup>
import { useAuth } from '@/composables/useAuth'

const { user, isLoggedIn, can } = useAuth()
</script>

<template>
  <div v-if="isLoggedIn">
    Welcome, {{ user.name }}
    <button v-if="can('create', 'Article')">New Article</button>
  </div>
</template>
```

### useFlash Composable

```javascript
// app/frontend/composables/useFlash.js
import { computed, watch } from 'vue'
import { usePage } from '@inertiajs/vue3'

export function useFlash() {
  const page = usePage()

  const flash = computed(() => page.props.flash)

  function hasMessage(type) {
    return !!flash.value?.[type]
  }

  return {
    flash,
    hasMessage,
    success: computed(() => flash.value?.success),
    error: computed(() => flash.value?.error),
    notice: computed(() => flash.value?.notice)
  }
}
```

## Testing

### Component Testing (Vitest)

```javascript
import { mount } from '@vue/test-utils'
import Index from '@/pages/Articles/Index.vue'

describe('Articles Index', () => {
  const articles = [
    { id: 1, title: 'First', excerpt: 'Excerpt 1' },
    { id: 2, title: 'Second', excerpt: 'Excerpt 2' }
  ]

  it('renders articles', () => {
    const wrapper = mount(Index, {
      props: {
        articles,
        pagination: {},
        filters: {}
      }
    })

    expect(wrapper.text()).toContain('First')
    expect(wrapper.text()).toContain('Second')
  })

  it('handles search input', async () => {
    const wrapper = mount(Index, {
      props: {
        articles,
        pagination: {},
        filters: {}
      }
    })

    const input = wrapper.find('input[type="search"]')
    await input.setValue('test')

    expect(input.element.value).toBe('test')
  })
})
```
