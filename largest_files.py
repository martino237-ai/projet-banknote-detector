import os
import pathlib

base = pathlib.Path('C:/Users/USER')
roots = ['Downloads', 'Desktop', 'Documents', 'Videos', 'Pictures', 'AppData/Local', 'AppData/Roaming']
print('Scanning common large-data folders...')
for root in roots:
    path = base / root
    if path.exists():
        total = 0
        for dirpath, dirnames, filenames in os.walk(path):
            for f in filenames:
                try:
                    total += os.path.getsize(os.path.join(dirpath, f))
                except Exception:
                    pass
        print(f'{root}: {total/1024/1024:.1f} MB')

print('\nTop 30 largest files in those folders:')
files = []
for root in roots:
    path = base / root
    if not path.exists():
        continue
    for dirpath, dirnames, filenames in os.walk(path):
        for f in filenames:
            try:
                p = pathlib.Path(dirpath) / f
                files.append((p.stat().st_size, p))
            except Exception:
                pass
files.sort(reverse=True)
for size, p in files[:30]:
    print(f'{size/1024/1024:.1f} MB  {p}')
