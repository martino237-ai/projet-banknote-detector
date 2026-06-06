import os
import pathlib

downloads = pathlib.Path('C:/Users/USER/Downloads')
if not downloads.exists():
    print('No Downloads folder found')
    raise SystemExit(0)

files = []
for root, _, filenames in os.walk(downloads):
    for f in filenames:
        try:
            p = pathlib.Path(root) / f
            files.append((p.stat().st_size, p))
        except Exception:
            pass

files.sort(reverse=True)
for size, path in files[:50]:
    print(f'{size/1024/1024:.1f} MB  {path}')
