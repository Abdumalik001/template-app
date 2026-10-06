import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ActiveTheme _selectedTheme;

  late final List<DataHelper> _listLanguage;
  late DataHelper _selectedLanguage;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      return;
    }
    _listLanguage = [
      DataHelper(title: Strings.of(context)!.english, type: 'en'),
      DataHelper(title: Strings.of(context)!.uzbek, type: 'uz'),
      DataHelper(title: Strings.of(context)!.russian, type: 'ru'),
    ];
    final settings = context.read<SettingsCubit>().settings;
    _selectedTheme = settings.activeTheme;
    _selectedLanguage = _listLanguage.firstWhere(
      (element) => element.type == settings.type,
      orElse: () => _listLanguage[0],
    );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) => Parent(
    appBar: AppBar(
      centerTitle: true,
      title: Text(Strings.of(context)!.settings),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: Dimens.space20,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(Routes.dashboard.name);
          }
        },
      ),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Dimens.space16),
        child: Column(
          spacing: Dimens.space8,
          children: [
            FadeSlideIn(
              child: DropDown<ActiveTheme>(
                key: const Key('dropdown_theme'),
                hint: appStrings.chooseTheme,
                value: _selectedTheme,
                prefixIcon: Icon(
                  Icons.contrast_rounded,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
                items: ActiveTheme.values
                    .map(
                      (data) => DropdownMenuItem(
                        value: data,
                        child: Text(
                          _getThemeName(data, context),
                          style: TextTheme.of(context).bodyLarge,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  /// Reload theme
                  context.read<SettingsCubit>().updateTheme(
                    value ?? ActiveTheme.system,
                  );
                },
              ),
            ),

            /// Language
            FadeSlideIn(
              delay: Motion.stagger,
              child: DropDown<DataHelper>(
                key: const Key('dropdown_language'),
                hint: Strings.of(context)!.chooseLanguage,
                value: _selectedLanguage,
                prefixIcon: Icon(
                  Icons.translate_rounded,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
                items: _listLanguage
                    .map(
                      (data) => DropdownMenuItem(
                        value: data,
                        child: Text(
                          data.title ?? '-',
                          style: TextTheme.of(context).bodyLarge,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (DataHelper? value) {
                  _selectedLanguage = value ?? _listLanguage[0];

                  /// Reload theme
                  if (!mounted) {
                    return;
                  }
                  context.read<SettingsCubit>().updateLanguage(
                    value?.type ?? 'en',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _getThemeName(ActiveTheme activeTheme, BuildContext context) {
    if (activeTheme == ActiveTheme.system) {
      return Strings.of(context)!.themeSystem;
    } else if (activeTheme == ActiveTheme.dark) {
      return Strings.of(context)!.themeDark;
    } else {
      return Strings.of(context)!.themeLight;
    }
  }
}
