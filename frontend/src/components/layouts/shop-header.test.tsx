import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'
import { AuthProvider } from '../../features/auth/components/auth-provider'
import { ShopHeader } from './shop-header'

vi.mock('../../features/auth/api/get-auth', () => ({
  getCurrentUser: vi.fn().mockResolvedValue({
    authenticated: true,
    displayName: 'Demo Learner',
    roles: ['learner'],
  }),
  getAuthConfig: vi.fn().mockResolvedValue({
    loginUrl: '/oauth2/authorization/keycloak',
    logoutUrl: '/api/auth/logout',
  }),
}))

function renderHeader() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })

  return render(
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <MemoryRouter>
          <ShopHeader />
        </MemoryRouter>
      </AuthProvider>
    </QueryClientProvider>,
  )
}

describe('ShopHeader', () => {
  it('should render navigation links for demo shop', async () => {
    renderHeader()

    expect(await screen.findByText('DemoShop')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: '学習ガイド' })).toHaveAttribute('href', '/learn')
    expect(screen.getByRole('link', { name: 'SQL演習' })).toHaveAttribute('href', '/sandbox')
    expect(screen.getByRole('link', { name: '商品カタログ' })).toHaveAttribute('href', '/catalog')
    expect(screen.getByRole('link', { name: '注文管理' })).toHaveAttribute('href', '/orders')
  })
})
