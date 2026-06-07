import { Input } from '../../../components/ui/input'
import { Select } from '../../../components/ui/select'

type CustomerFiltersProps = {
  keyword: string
  prefecture: string
  membershipTier: string
  onKeywordChange: (value: string) => void
  onPrefectureChange: (value: string) => void
  onMembershipTierChange: (value: string) => void
}

export function CustomerFilters({
  keyword,
  prefecture,
  membershipTier,
  onKeywordChange,
  onPrefectureChange,
  onMembershipTierChange,
}: CustomerFiltersProps) {
  return (
    <div className="grid gap-3 md:grid-cols-3">
      <Input
        placeholder="名前・メールで検索"
        value={keyword}
        onChange={(event) => onKeywordChange(event.target.value)}
      />
      <Input
        placeholder="都道府県（例: 東京都）"
        value={prefecture}
        onChange={(event) => onPrefectureChange(event.target.value)}
      />
      <Select
        value={membershipTier}
        onChange={(event) => onMembershipTierChange(event.target.value)}
      >
        <option value="">全会員ランク</option>
        <option value="standard">standard</option>
        <option value="silver">silver</option>
        <option value="gold">gold</option>
        <option value="platinum">platinum</option>
      </Select>
    </div>
  )
}
