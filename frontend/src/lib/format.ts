export function formatCurrency(value: number): string {
  return `¥${Math.round(value).toLocaleString('ja-JP')}`
}

export function formatDateTime(value: string): string {
  return new Date(value).toLocaleString('ja-JP')
}

export function formatDate(value: string): string {
  return new Date(value).toLocaleDateString('ja-JP')
}
