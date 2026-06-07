import { createBrowserRouter, Navigate } from 'react-router-dom'
import { AppLayout } from '../components/layouts/app-layout'
import { LoginPage } from '../features/auth/components/login-page'
import { ProtectedRoute } from '../features/auth/components/protected-route'
import { DashboardPage } from '../features/dashboard/components/dashboard-page'
import { CustomersPage } from '../features/customers/components/customers-page'
import { CustomerDetailPage } from '../features/customers/components/customer-detail-page'
import { OrdersPage } from '../features/orders/components/orders-page'
import { CatalogPage } from '../features/products/components/catalog-page'
import { StaffPage } from '../features/employees/components/staff-page'
import { ArticlePage } from '../features/learn/components/article-page'
import { LearnHomePage } from '../features/learn/components/learn-home-page'
import { SectionPage } from '../features/learn/components/section-page'
import { SandboxPage } from '../features/sql-sandbox/components/sandbox-page'

export const appRouter = createBrowserRouter([
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/',
    element: (
      <ProtectedRoute>
        <AppLayout />
      </ProtectedRoute>
    ),
    children: [
      { index: true, element: <DashboardPage /> },
      { path: 'learn', element: <LearnHomePage /> },
      { path: 'learn/:sectionId', element: <SectionPage /> },
      { path: 'learn/:sectionId/:articleId', element: <ArticlePage /> },
      { path: 'catalog', element: <CatalogPage /> },
      { path: 'orders', element: <OrdersPage /> },
      { path: 'customers', element: <CustomersPage /> },
      { path: 'customers/:customerId', element: <CustomerDetailPage /> },
      { path: 'staff', element: <StaffPage /> },
      { path: 'sandbox', element: <SandboxPage /> },
      { path: 'products', element: <Navigate to="/catalog" replace /> },
      { path: 'employees', element: <Navigate to="/staff" replace /> },
      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
])
