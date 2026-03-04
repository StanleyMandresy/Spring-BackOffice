#!/usr/bin/env python3
import os
import re

# Mapping des couleurs: olive → bleu
color_map = {
    '#E9F5DB': '#F6FAFD',
    '#CFE1B9': '#B3CFE5',
    '#B5C99A': '#4A7FA7',
    '#97A97C': '#4A7FA7',
    '#87986A': '#1A3D63',
    '#718355': '#1A3D63'
}

# Répertoire des vues
views_dir = 'src/main/webapp/WEB-INF/views'

# Fonction pour remplacer les couleurs dans un fichier
def replace_colors_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Remplacer chaque couleur
    for old_color, new_color in color_map.items():
        content = content.replace(old_color, new_color)
    
    # Sauvegarder si modifié
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

# Parcourir tous les fichiers JSP
modified_count = 0
for root, dirs, files in os.walk(views_dir):
    for file in files:
        if file.endswith('.jsp'):
            filepath = os.path.join(root, file)
            if replace_colors_in_file(filepath):
                modified_count += 1
                print(f'✅ {filepath}')

print(f'\n🎨 {modified_count} fichiers modifiés avec la nouvelle palette bleue!')
