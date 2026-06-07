import { RouterProvider } from 'react-router-dom'
import { AppProvider } from './provider'
import { appRouter } from './router'

export function App() {
  return (
    <AppProvider>
      <RouterProvider router={appRouter} />
    </AppProvider>
  )
}
