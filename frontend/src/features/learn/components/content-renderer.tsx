import type { ContentBlock } from '../content/types'

type ContentRendererProps = {
  blocks: ContentBlock[]
}

export function ContentRenderer({ blocks }: ContentRendererProps) {
  return (
    <div className="space-y-4 text-sm leading-relaxed text-slate-700">
      {blocks.map((block, index) => {
        switch (block.type) {
          case 'paragraph':
            return <p key={index}>{block.text}</p>
          case 'heading':
            if (block.level === 2) {
              return (
                <h3 key={index} className="text-base font-semibold text-slate-900">
                  {block.text}
                </h3>
              )
            }
            return (
              <h4 key={index} className="text-sm font-semibold text-slate-800">
                {block.text}
              </h4>
            )
          case 'code':
            return (
              <pre
                key={index}
                className="overflow-x-auto rounded-xl bg-slate-900 p-4 font-mono text-xs leading-relaxed text-emerald-300"
              >
                <code>{block.code}</code>
              </pre>
            )
          case 'list':
            if (block.ordered) {
              return (
                <ol key={index} className="list-decimal space-y-1 pl-5">
                  {block.items.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ol>
              )
            }
            return (
              <ul key={index} className="list-disc space-y-1 pl-5">
                {block.items.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            )
          case 'tip':
            return (
              <div
                key={index}
                className="rounded-xl border border-indigo-200 bg-indigo-50 p-4"
              >
                <p className="font-semibold text-indigo-900">{block.title}</p>
                <p className="mt-1 text-indigo-800">{block.text}</p>
              </div>
            )
          case 'warning':
            return (
              <div
                key={index}
                className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-amber-900"
              >
                {block.text}
              </div>
            )
          default:
            return null
        }
      })}
    </div>
  )
}
