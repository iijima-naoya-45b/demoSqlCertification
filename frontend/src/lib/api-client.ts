import { z } from 'zod'
import { env } from '../config/env'
import { getCsrfToken } from './csrf'

const apiErrorSchema = z.object({
  timestamp: z.string(),
  status: z.number(),
  error: z.string(),
  message: z.string(),
})

export class ApiUnauthorizedError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'ApiUnauthorizedError'
  }
}

type FetchOptions = {
  params?: Record<string, string | number | boolean | undefined | null>
  method?: 'GET' | 'POST'
  body?: unknown
}

function buildUrl(path: string, params?: FetchOptions['params']): string {
  const url = new URL(`${env.apiBaseUrl}${path}`, window.location.origin)
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        url.searchParams.set(key, String(value))
      }
    })
  }
  return url.toString()
}

function buildHeaders(method: string): HeadersInit {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  }

  if (method !== 'GET') {
    headers['Content-Type'] = 'application/json'
    const csrfToken = getCsrfToken()
    if (csrfToken) {
      headers['X-XSRF-TOKEN'] = csrfToken
    }
  }

  return headers
}

export async function apiFetch<T>(
  path: string,
  schema: z.ZodType<T>,
  options: FetchOptions = {},
): Promise<T> {
  const method = options.method ?? 'GET'
  const url = buildUrl(path, options.params)
  const response = await fetch(url, {
    method,
    headers: buildHeaders(method),
    credentials: 'include',
    body: options.body ? JSON.stringify(options.body) : undefined,
  })

  if (response.status === 401) {
    throw new ApiUnauthorizedError(`apiFetch: 認証が必要です。path=${path}`)
  }

  if (!response.ok) {
    let errorMessage = `apiFetch: HTTP ${response.status} path=${path}`
    try {
      const errorBody = apiErrorSchema.parse(await response.json())
      errorMessage = errorBody.message
    } catch {
      // JSON パース失敗時はデフォルトメッセージを使用
    }
    throw new Error(errorMessage)
  }

  const json: unknown = await response.json()
  return schema.parse(json)
}

export async function apiGet<T>(
  path: string,
  schema: z.ZodType<T>,
  options: Omit<FetchOptions, 'method' | 'body'> = {},
): Promise<T> {
  return apiFetch(path, schema, { ...options, method: 'GET' })
}

export async function apiPost<T>(
  path: string,
  schema: z.ZodType<T>,
  body: unknown,
  options: Omit<FetchOptions, 'method' | 'body'> = {},
): Promise<T> {
  return apiFetch(path, schema, { ...options, method: 'POST', body })
}
