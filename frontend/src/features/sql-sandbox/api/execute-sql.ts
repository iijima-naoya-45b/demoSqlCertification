import { env } from '../../../config/env'
import { getCsrfToken } from '../../../lib/csrf'
import {
  sqlBlockedErrorSchema,
  sqlExecutionResultSchema,
  type SqlBlockedError,
  type SqlExecutionResult,
} from './schemas'

export type ExecuteSqlRequest = {
  sql: string
  exerciseId?: string
}

export type ExecuteSqlResponse =
  | { type: 'success'; data: SqlExecutionResult }
  | { type: 'blocked'; error: SqlBlockedError }
  | { type: 'error'; message: string }

export async function executeSql(request: ExecuteSqlRequest): Promise<ExecuteSqlResponse> {
  const url = new URL(`${env.apiBaseUrl}/api/sandbox/execute`, window.location.origin)

  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  const csrfToken = getCsrfToken()
  if (csrfToken) {
    headers['X-XSRF-TOKEN'] = csrfToken
  }

  const response = await fetch(url.toString(), {
    method: 'POST',
    headers,
    credentials: 'include',
    body: JSON.stringify(request),
  })

  const json: unknown = await response.json()

  if (response.status === 403) {
    return {
      type: 'blocked',
      error: sqlBlockedErrorSchema.parse(json),
    }
  }

  if (!response.ok) {
    const message =
      typeof json === 'object' && json !== null && 'message' in json
        ? String((json as { message: string }).message)
        : `executeSql: HTTP ${response.status}`
    return { type: 'error', message }
  }

  return {
    type: 'success',
    data: sqlExecutionResultSchema.parse(json),
  }
}
