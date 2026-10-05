#!/usr/bin/env python3
"""
rename_project.py

Ushbu skript loyiha bo'ylab 'flutter_auth_app' nomini yangi 'cactus_hr' nomiga o'zgartiradi.
Eslatma: Dart/Flutter spetsifikatsiyasiga ko'ra, paket nomlarida (package name) chiziqcha ('-')
ishlatish mumkin emas, faqat kichik harflar, raqamlar va tagchiziq ('_') ruxsat etilgan.
Shu sababli paket nomi va barcha Dart importlarida 'cactus_hr' ishlatiladi.
"""

import os
import sys

# O'zgartiriladigan qiymatlar
OLD_NAME = "flutter_auth_app"
NEW_NAME = "cactus_hr"

# Tekshirilmaydigan kataloglar va fayl turlari
IGNORE_DIRS = {
    ".git",
    ".idea",
    ".dart_tool",
    "build",
    ".fvm",
    ".gradle",
    "android/app/build",
    "ios/Pods",
}

BINARY_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico",
    ".ttf", ".otf", ".woff", ".woff2",
    ".zip", ".tar", ".gz", ".jar", ".keystore",
    ".DS_Store", ".dylib", ".so", ".a"
}

def is_text_file(filename: str) -> bool:
    _, ext = os.path.splitext(filename)
    return ext.lower() not in BINARY_EXTENSIONS

def process_file(filepath: str) -> int:
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except (UnicodeDecodeError, PermissionError):
        return 0

    count = content.count(OLD_NAME)
    if count > 0:
        new_content = content.replace(OLD_NAME, NEW_NAME)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)
        return count
    return 0

def main():
    root_dir = os.path.dirname(os.path.abspath(__file__))
    total_files_changed = 0
    total_replacements = 0
    changed_files = []

    print(f"🔄 Loyihani yangilash boshlanmoqda: '{OLD_NAME}' -> '{NEW_NAME}'")
    print(f"📁 Ildiz katalog: {root_dir}\n")

    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Keraksiz kataloglarni tashlab ketish
        dirnames[:] = [
            d for d in dirnames
            if d not in IGNORE_DIRS and not any(
                os.path.relpath(os.path.join(dirpath, d), root_dir).startswith(ig)
                for ig in IGNORE_DIRS
            )
        ]

        for filename in filenames:
            if not is_text_file(filename):
                continue

            filepath = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(filepath, root_dir)

            # O'zini o'zi o'zgartirmasligi uchun
            if rel_path == "rename_project.py":
                continue

            replacements = process_file(filepath)
            if replacements > 0:
                total_files_changed += 1
                total_replacements += replacements
                changed_files.append((rel_path, replacements))

    print("=" * 60)
    print(f"✅ Bajarildi!")
    print(f"📄 O'zgartirilgan fayllar soni: {total_files_changed}")
    print(f"🔁 Jami almashtirishlar soni: {total_replacements}")
    print("=" * 60)
    print("\nO'zgartirilgan fayllar ro'yxati:")
    for rel_path, count in changed_files:
        print(f"  • {rel_path} ({count} ta)")

if __name__ == "__main__":
    main()
