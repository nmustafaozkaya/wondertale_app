import os, glob

paths = glob.glob('lib/screens/*.dart') + glob.glob('lib/widgets/*.dart')

for p in paths:
    with open(p, 'r', encoding='utf-8') as f: 
        c = f.read()
    
    c = c.replace('AppTheme.bgDark', 'AppTheme.bgLight')
    c = c.replace('AppTheme.rose', 'AppTheme.pink')
    c = c.replace('AppTheme.bgCardLight', 'AppTheme.bgCard')
    c = c.replace('AppTheme.goldLight', 'AppTheme.gold')
    c = c.replace('const [AppTheme.violet.withValues(alpha: 0.1), AppTheme.bgLight]', '[AppTheme.violet.withValues(alpha: 0.1), AppTheme.bgLight]')
    c = c.replace('const [AppTheme.violet.withValues(alpha: 0.18), Colors.transparent]', '[AppTheme.violet.withValues(alpha: 0.18), Colors.transparent]')
    
    with open(p, 'w', encoding='utf-8') as f: 
        f.write(c)
