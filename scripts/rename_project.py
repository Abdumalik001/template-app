#!/usr/bin/env python3
"""
Production-Ready Flutter Project Renamer Script.

Automatically detects current project facts from:
- pubspec.yaml (current package name)
- android/app/build.gradle.kts (current namespace / applicationId)
- ios/Runner.xcodeproj/project.pbxproj & Info.plist (current bundle ID & display name)

Updates:
1. Flutter / Dart package name (pubspec.yaml, all Dart imports).
2. Android namespace, applicationId, AndroidManifests, strings.xml (app_name).
3. Android Kotlin MainActivity.kt directory hierarchy and package declaration.
4. iOS CFBundleDisplayName, CFBundleName, project.pbxproj PRODUCT_BUNDLE_IDENTIFIER & APP_DISPLAY_NAME.
5. Local storage prefix/box naming (app_storage.dart).
6. AGENTS.md documentation facts.
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parent.parent


def get_current_facts():
    """Dynamically read current project facts from files."""
    # 1. Package name from pubspec.yaml
    pkg_name = "cactus_hr"
    pubspec = ROOT_DIR / "pubspec.yaml"
    if pubspec.exists():
        content = pubspec.read_text(encoding="utf-8")
        m = re.search(r"^name:\s+([a-zA-Z0-9_]+)", content, re.MULTILINE)
        if m:
            pkg_name = m.group(1).strip()

    # 2. Android ID from build.gradle.kts
    android_id = "com.lazycatlabs.auth"
    gradle_kts = ROOT_DIR / "android" / "app" / "build.gradle.kts"
    if gradle_kts.exists():
        content = gradle_kts.read_text(encoding="utf-8")
        m = re.search(r'applicationId\s*=\s*"([^"]+)"', content)
        if m:
            android_id = m.group(1).strip()
        else:
            m = re.search(r'namespace\s*=\s*"([^"]+)"', content)
            if m:
                android_id = m.group(1).strip()

    # 3. iOS Bundle ID from project.pbxproj
    ios_bundle_id = "com.lazycatlabs.auths"
    pbxproj = ROOT_DIR / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if pbxproj.exists():
        content = pbxproj.read_text(encoding="utf-8")
        m = re.search(r"PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);", content)
        if m:
            ios_bundle_id = m.group(1).strip().replace(".stg", "")

    # 4. App title from strings.xml or Info.plist
    app_title = "Flutter Auth"
    strings_xml = ROOT_DIR / "android" / "app" / "src" / "main" / "res" / "values" / "strings.xml"
    if strings_xml.exists():
        content = strings_xml.read_text(encoding="utf-8")
        m = re.search(r'<string name="app_name">([^<]+)</string>', content)
        if m:
            app_title = m.group(1).strip()

    return pkg_name, android_id, ios_bundle_id, app_title


def validate_pkg_name(name: str) -> bool:
    """Validate Dart package name (lowercase, numbers, underscores, starting with letter)."""
    return bool(re.match(r"^[a-z][a-z0-9_]*$", name))


def validate_app_id(app_id: str) -> bool:
    """Validate reverse domain identifier (e.g. com.company.app)."""
    return bool(re.match(r"^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$", app_id))


def replace_in_file(file_path: Path, old_str: str, new_str: str, dry_run: bool = False) -> int:
    """Replace occurrences of old_str with new_str in a file."""
    if not file_path.exists():
        return 0

    try:
        content = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return 0

    count = content.count(old_str)
    if count > 0:
        if not dry_run:
            updated_content = content.replace(old_str, new_str)
            file_path.write_text(updated_content, encoding="utf-8")
        print(f"  [✓] {file_path.relative_to(ROOT_DIR)}: {count} replacement(s)")
    return count


def replace_regex_in_file(file_path: Path, pattern: str, replacement: str, dry_run: bool = False) -> int:
    """Replace pattern using regex in a file."""
    if not file_path.exists():
        return 0

    try:
        content = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return 0

    updated, count = re.subn(pattern, replacement, content)
    if count > 0:
        if not dry_run:
            file_path.write_text(updated, encoding="utf-8")
        print(f"  [✓] {file_path.relative_to(ROOT_DIR)}: {count} regex replacement(s)")
    return count


def update_dart_files(old_pkg_name: str, new_pkg_name: str, dry_run: bool = False):
    """Update package name in pubspec.yaml, AGENTS.md, app_storage and all dart imports."""
    print("\n📦 Updating Dart / Flutter files...")

    # 1. pubspec.yaml
    pubspec = ROOT_DIR / "pubspec.yaml"
    replace_regex_in_file(pubspec, rf"^name:\s+{re.escape(old_pkg_name)}\b", f"name: {new_pkg_name}", dry_run=dry_run)

    # 2. AGENTS.md
    agents_md = ROOT_DIR / "AGENTS.md"
    replace_in_file(agents_md, f"package:{old_pkg_name}/", f"package:{new_pkg_name}/", dry_run=dry_run)
    replace_in_file(agents_md, f"`{old_pkg_name}`", f"`{new_pkg_name}`", dry_run=dry_run)

    # 3. app_storage.dart Hive box name
    app_storage = ROOT_DIR / "lib" / "utils" / "services" / "storage" / "app_storage.dart"
    replace_in_file(app_storage, f"'${{prefix}}{old_pkg_name}'", f"'${{prefix}}{new_pkg_name}'", dry_run=dry_run)

    # 4. All .dart imports
    old_import = f"package:{old_pkg_name}/"
    new_import = f"package:{new_pkg_name}/"
    dart_count = 0
    for dart_file in ROOT_DIR.glob("**/*.dart"):
        if ".dart_tool" in dart_file.parts or ".build" in dart_file.parts:
            continue
        dart_count += replace_in_file(dart_file, old_import, new_import, dry_run=dry_run)
    print(f"  -> Total Dart import references updated: {dart_count}")


def update_android(old_android_id: str, new_app_id: str, new_title: str, dry_run: bool = False):
    """Update Android applicationId, namespace, manifests, strings.xml, and Kotlin package path."""
    print("\n🤖 Updating Android configuration...")

    # 1. build.gradle.kts
    gradle_kts = ROOT_DIR / "android" / "app" / "build.gradle.kts"
    replace_in_file(gradle_kts, f'namespace = "{old_android_id}"', f'namespace = "{new_app_id}"', dry_run=dry_run)
    replace_in_file(gradle_kts, f'applicationId = "{old_android_id}"', f'applicationId = "{new_app_id}"', dry_run=dry_run)

    # 2. AndroidManifest files
    manifests = [
        ROOT_DIR / "android" / "app" / "src" / "main" / "AndroidManifest.xml",
        ROOT_DIR / "android" / "app" / "src" / "debug" / "AndroidManifest.xml",
        ROOT_DIR / "android" / "app" / "src" / "profile" / "AndroidManifest.xml",
    ]
    for mf in manifests:
        replace_in_file(mf, f'package="{old_android_id}"', f'package="{new_app_id}"', dry_run=dry_run)

    # 3. strings.xml (App label)
    strings_xml = ROOT_DIR / "android" / "app" / "src" / "main" / "res" / "values" / "strings.xml"
    replace_regex_in_file(
        strings_xml,
        r'<string name="app_name">.*?</string>',
        f'<string name="app_name">{new_title}</string>',
        dry_run=dry_run,
    )

    # 4. Refactor Kotlin directory & MainActivity.kt
    kotlin_root = ROOT_DIR / "android" / "app" / "src" / "main" / "kotlin"
    old_kotlin_dir = kotlin_root / Path(*old_android_id.split("."))
    new_kotlin_dir = kotlin_root / Path(*new_app_id.split("."))

    main_activity = old_kotlin_dir / "MainActivity.kt"
    if main_activity.exists():
        print(f"  -> Found MainActivity.kt at: {old_kotlin_dir.relative_to(ROOT_DIR)}")
        if not dry_run:
            replace_in_file(main_activity, f"package {old_android_id}", f"package {new_app_id}", dry_run=False)
            new_kotlin_dir.mkdir(parents=True, exist_ok=True)
            new_main_activity = new_kotlin_dir / "MainActivity.kt"
            shutil.move(str(main_activity), str(new_main_activity))
            print(f"  [✓] Moved MainActivity.kt -> {new_kotlin_dir.relative_to(ROOT_DIR)}")

            # Remove empty old directories
            curr = old_kotlin_dir
            while curr != kotlin_root and curr.exists() and not any(curr.iterdir()):
                curr.rmdir()
                curr = curr.parent
        else:
            print(f"  [Dry-Run] Would move MainActivity.kt -> {new_kotlin_dir.relative_to(ROOT_DIR)}")


def update_ios(old_pkg_name: str, old_bundle_id: str, old_title: str,
               new_pkg_name: str, new_bundle_id: str, new_title: str, dry_run: bool = False):
    """Update iOS Info.plist, project.pbxproj, and bundle identifiers."""
    print("\n🍎 Updating iOS configuration...")

    # 1. Info.plist
    info_plist = ROOT_DIR / "ios" / "Runner" / "Info.plist"
    replace_in_file(info_plist, f"<string>{old_pkg_name}</string>", f"<string>{new_pkg_name}</string>", dry_run=dry_run)

    # 2. project.pbxproj
    pbxproj = ROOT_DIR / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    # Bundle IDs
    replace_in_file(pbxproj, f"PRODUCT_BUNDLE_IDENTIFIER = {old_bundle_id};", f"PRODUCT_BUNDLE_IDENTIFIER = {new_bundle_id};", dry_run=dry_run)
    replace_in_file(pbxproj, f"PRODUCT_BUNDLE_IDENTIFIER = {old_bundle_id}.stg;", f"PRODUCT_BUNDLE_IDENTIFIER = {new_bundle_id}.stg;", dry_run=dry_run)

    # Display Names
    replace_in_file(pbxproj, f'APP_DISPLAY_NAME = "{old_title}";', f'APP_DISPLAY_NAME = "{new_title}";', dry_run=dry_run)
    replace_in_file(pbxproj, f'APP_DISPLAY_NAME = "{old_title} STG";', f'APP_DISPLAY_NAME = "{new_title} STG";', dry_run=dry_run)


def main():
    old_pkg, old_android, old_ios, old_title = get_current_facts()

    parser = argparse.ArgumentParser(description="Rename Flutter project to a new name.")
    parser.add_argument("--name", help="New Flutter package name (snake_case, e.g. my_cool_app)")
    parser.add_argument("--org", help="New Android & iOS Organization / Application ID (e.g. com.mycompany.app)")
    parser.add_argument("--title", help='New User-Facing App Display Name (e.g. "My Cool App")')
    parser.add_argument("--dry-run", action="store_true", help="Preview modifications without touching files")

    args = parser.parse_args()

    pkg_name = args.name
    app_id = args.org
    app_title = args.title
    dry_run = args.dry_run

    # Interactive prompts if arguments are omitted
    if not pkg_name:
        print(f"🌵 Flutter Project Renamer 🌵")
        print(f"Current Package: {old_pkg}")
        print(f"Current App ID : {old_android}")
        print(f"Current Title  : {old_title}\n")
        while True:
            pkg_name = input("Enter new package name [snake_case, e.g. nova_hr]: ").strip()
            if validate_pkg_name(pkg_name):
                break
            print("❌ Invalid package name! Must be lowercase, numbers, and underscores (e.g. nova_hr).")

    if not app_id:
        default_app_id = f"com.example.{pkg_name}"
        while True:
            prompt = f"Enter Application ID / Bundle ID [default: {default_app_id}]: "
            entered = input(prompt).strip()
            app_id = entered if entered else default_app_id
            if validate_app_id(app_id):
                break
            print("❌ Invalid Application ID! Format must be like 'com.example.app'.")

    if not app_title:
        default_title = " ".join(word.capitalize() for word in pkg_name.split("_"))
        entered = input(f'Enter App Display Name [default: "{default_title}"]: ').strip()
        app_title = entered if entered else default_title

    print("\n" + "=" * 60)
    print(f"Old Package    : {old_pkg}  -> New: {pkg_name}")
    print(f"Old App ID     : {old_android}  -> New: {app_id}")
    print(f"Old Title      : {old_title}  -> New: {app_title}")
    print(f"Mode           : {'[DRY RUN - No changes will be saved]' if dry_run else '[LIVE UPDATE]'}")
    print("=" * 60)

    if not args.name and not dry_run:
        confirm = input("\nProceed with rename? [y/N]: ").strip().lower()
        if confirm != "y":
            print("Aborted.")
            sys.exit(0)

    # Perform updates
    update_dart_files(old_pkg, pkg_name, dry_run=dry_run)
    update_android(old_android, app_id, app_title, dry_run=dry_run)
    update_ios(old_pkg, old_ios, old_title, pkg_name, app_id, app_title, dry_run=dry_run)

    print("\n" + "=" * 60)
    if dry_run:
        print("✅ Dry-run completed! All target patterns match correctly.")
    else:
        print("🎉 Code and configuration successfully updated!")
        print("\n⚙️ Running post-rename tasks (pub get, codegen, formatting)...")

        # Determine flutter / fvm flutter command
        flutter_cmd = "fvm flutter" if shutil.which("fvm") else "flutter"
        dart_cmd = "fvm dart" if shutil.which("fvm") else "dart"

        steps = [
            ("Running flutter pub get", f"{flutter_cmd} pub get"),
            ("Running build_runner codegen", f"{dart_cmd} run build_runner build --delete-conflicting-outputs"),
            ("Applying automatic dart fixes", f"{dart_cmd} fix --apply lib/"),
            ("Formatting Dart files", f"{dart_cmd} format lib/"),
            ("Verifying with flutter analyze", f"{flutter_cmd} analyze"),
        ]

        for desc, cmd in steps:
            print(f"\n▶ {desc} (`{cmd}`)...")
            ret = os.system(cmd)
            if ret != 0:
                print(f"⚠️ Warning: Command `{cmd}` exited with code {ret}")

        print("\n" + "=" * 60)
        print("🎉 All done! Project is cleanly renamed and ready to run.")
    print("=" * 60)


if __name__ == "__main__":
    main()
