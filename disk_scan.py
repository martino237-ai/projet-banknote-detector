import os
import pathlib

base = pathlib.Path('C:/Users/USER')
print('BASE', base)

folders = []
for child in base.iterdir():
    try:
        if child.is_dir():
            total = 0
            for root, _, files in os.walk(child):
                for f in files:
                    try:
                        total += os.path.getsize(os.path.join(root, f))
                    except Exception:
                        pass
            folders.append((total, child))
    except Exception:
        pass

for size, path in sorted(folders, reverse=True)[:15]:
    print(f'{size/1024/1024:.1f} MB  {path}')

print('\nTop large files in user folder:')
files = []
for root, _, filenames in os.walk(base):
    for f in filenames:
        try:
            p = pathlib.Path(root) / f
            files.append((p.stat().st_size, p))
        except Exception:
            pass

for size, path in sorted(files, reverse=True)[:20]:
    print(f'{size/1024/1024:.1f} MB  {path}')
