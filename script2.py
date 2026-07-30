import os

def fix_wizard():
    p = 'lib/screens/wizard_screen.dart'
    with open(p, 'r', encoding='utf-8') as f: c = f.read()
    
    # Title
    c = c.replace('color: Colors.white,\n                              letterSpacing: -0.5,', 'color: AppTheme.textPrimary,\n                              letterSpacing: -0.5,')
    # Text Field
    c = c.replace('style: const TextStyle(color: Colors.white, fontSize: 16)', 'style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)')
    c = c.replace('counterStyle: const TextStyle(color: Colors.white38)', 'counterStyle: const TextStyle(color: AppTheme.textSecondary)')
    
    # Dialogs
    c = c.replace('style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)', 'style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)')
    c = c.replace("const Text('Kapat', style: TextStyle(color: Colors.white54))", "const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary))")
    
    # Subtitles
    c = c.replace('style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))', 'style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)')
    
    with open(p, 'w', encoding='utf-8') as f: f.write(c)

def fix_library():
    p = 'lib/screens/library_screen.dart'
    with open(p, 'r', encoding='utf-8') as f: c = f.read()
    c = c.replace('color: Colors.white,', 'color: AppTheme.textPrimary,')
    c = c.replace('color: Colors.white.withValues(alpha: 0.6),', 'color: AppTheme.textSecondary,')
    c = c.replace('color: Colors.white.withValues(alpha: 0.1)', 'AppTheme.violet.withValues(alpha: 0.1)')
    c = c.replace('color: Colors.white.withValues(alpha: 0.05)', 'AppTheme.violet.withValues(alpha: 0.05)')
    with open(p, 'w', encoding='utf-8') as f: f.write(c)

def fix_story_detail():
    p = 'lib/screens/story_detail_screen.dart'
    with open(p, 'r', encoding='utf-8') as f: c = f.read()
    c = c.replace('color: Colors.white.withValues(alpha: 0.90),', 'color: AppTheme.textPrimary,')
    c = c.replace('color: Colors.white,', 'color: AppTheme.textPrimary,')
    # Revert icon colors that got broken if any
    c = c.replace('color: AppTheme.textPrimary, size: 20', 'color: Colors.white, size: 20') 
    with open(p, 'w', encoding='utf-8') as f: f.write(c)

def fix_subscription():
    p = 'lib/screens/subscription_screen.dart'
    with open(p, 'r', encoding='utf-8') as f: c = f.read()
    c = c.replace('color: Colors.white,', 'color: AppTheme.textPrimary,')
    c = c.replace('color: Colors.white.withValues(alpha: 0.9),', 'color: AppTheme.textPrimary,')
    c = c.replace('color: Colors.white.withValues(alpha: 0.5),', 'color: AppTheme.textSecondary,')
    c = c.replace('color: Colors.white.withValues(alpha: 0.85),', 'color: AppTheme.textPrimary,')
    with open(p, 'w', encoding='utf-8') as f: f.write(c)

fix_wizard()
fix_library()
fix_story_detail()
fix_subscription()
