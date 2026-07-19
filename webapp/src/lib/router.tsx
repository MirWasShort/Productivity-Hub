import { createBrowserRouter, Navigate, type RouteObject } from 'react-router'
import { AppShell } from '@/components/layout/app-shell'
import { RequireAnonymous, RequireAuth } from '@/lib/auth/route-guards'
import NotFoundPage from '@/components/layout/not-found-page'
import LoginPage from '@/features/auth/login-page'
import RegisterPage from '@/features/auth/register-page'
import CalendarPage from '@/features/calendar/calendar-page'
import DashboardPage from '@/features/dashboard/dashboard-page'
import TagManagementPage from '@/features/tags/tag-management-page'
import TaskDetailPage from '@/features/tasks/task-detail-page'
import TaskEditPage from '@/features/tasks/task-edit-page'
import TaskListPage from '@/features/tasks/task-list-page'

/**
 * Albero delle rotte, gemello di `app_router.dart`: le pagine di autenticazione
 * stanno fuori dalla shell, tutto il resto dentro e sotto guard.
 */
export const routes: RouteObject[] = [
  {
    path: '/login',
    element: (
      <RequireAnonymous>
        <LoginPage />
      </RequireAnonymous>
    ),
  },
  {
    path: '/register',
    element: (
      <RequireAnonymous>
        <RegisterPage />
      </RequireAnonymous>
    ),
  },
  {
    element: (
      <RequireAuth>
        <AppShell />
      </RequireAuth>
    ),
    children: [
      { index: true, element: <Navigate to="/tasks" replace /> },
      { path: 'tasks', element: <TaskListPage /> },
      { path: 'tasks/new', element: <TaskEditPage /> },
      { path: 'tasks/:taskId', element: <TaskDetailPage /> },
      { path: 'tasks/:taskId/edit', element: <TaskEditPage /> },
      { path: 'calendar', element: <CalendarPage /> },
      { path: 'dashboard', element: <DashboardPage /> },
      { path: 'tags', element: <TagManagementPage /> },
    ],
  },
  { path: '*', element: <NotFoundPage /> },
]

export const router = createBrowserRouter(routes)
