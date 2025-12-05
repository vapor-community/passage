import Testing
@testable import Passage

@Suite("Views Theme Tests")
struct ViewsThemeTests {

    // MARK: - Theme Brightness Tests

    @Test("Brightness enum cases")
    func brightnessEnumCases() {
        let brightnesses: [Passage.Views.Theme.Brightness] = [
            .light,
            .dark
        ]

        #expect(brightnesses.count == 2)
    }

    // MARK: - Theme Initialization Tests

    @Test("Theme initialization with colors")
    func themeInitialization() {
        let colors = Passage.Views.Theme.Colors.defaultLight
        let theme = Passage.Views.Theme(colors: colors)

        #expect(theme.colors.primary == colors.primary)
        #expect(theme.orverrides.isEmpty)
    }

    @Test("Theme initialization with overrides")
    func themeInitializationWithOverrides() {
        let lightColors = Passage.Views.Theme.Colors.defaultLight
        let darkColors = Passage.Views.Theme.Colors.defaultDark

        let theme = Passage.Views.Theme(
            colors: lightColors,
            overrides: [
                .dark: .init(colors: darkColors)
            ]
        )

        #expect(theme.colors.primary == lightColors.primary)
        #expect(!theme.orverrides.isEmpty)
    }

    // MARK: - Theme Resolution Tests

    @Test("Theme resolves to base colors for light when no override")
    func themeResolvesToBaseColorsForLight() {
        let colors = Passage.Views.Theme.Colors.defaultLight
        let theme = Passage.Views.Theme(colors: colors)

        let resolved = theme.colors(for: .light)

        #expect(resolved.primary == colors.primary)
    }

    @Test("Theme resolves to override colors when available")
    func themeResolvesToOverrideColors() {
        let lightColors = Passage.Views.Theme.Colors.defaultLight
        let darkColors = Passage.Views.Theme.Colors.defaultDark

        let theme = Passage.Views.Theme(
            colors: lightColors,
            overrides: [
                .dark: .init(colors: darkColors)
            ]
        )

        let resolvedDark = theme.colors(for: .dark)

        #expect(resolvedDark.primary == darkColors.primary)
        #expect(resolvedDark.primary != lightColors.primary)
    }

    @Test("Theme resolves to base colors when override not available")
    func themeResolvesToBaseWhenNoOverride() {
        let colors = Passage.Views.Theme.Colors.defaultLight
        let theme = Passage.Views.Theme(colors: colors)

        let resolvedDark = theme.colors(for: .dark)

        // Should fall back to base colors
        #expect(resolvedDark.primary == colors.primary)
    }

    @Test("Theme resolve method creates Resolved struct")
    func themeResolveCreatesResolvedStruct() {
        let colors = Passage.Views.Theme.Colors.defaultLight
        let theme = Passage.Views.Theme(colors: colors)

        let resolved = theme.resolve(for: .light)

        #expect(resolved.colors.primary == colors.primary)
    }

    // MARK: - Default Theme Colors Tests

    @Test("Default light theme has expected primary color")
    func defaultLightThemePrimaryColor() {
        let colors = Passage.Views.Theme.Colors.defaultLight
        #expect(colors.primary == "#6200EE")
    }

    @Test("Default dark theme has expected primary color")
    func defaultDarkThemePrimaryColor() {
        let colors = Passage.Views.Theme.Colors.defaultDark
        #expect(colors.primary == "#BB86FC")
    }

    @Test("All default themes have all required color properties", arguments: [
        Passage.Views.Theme.Colors.defaultLight,
        Passage.Views.Theme.Colors.defaultDark,
        Passage.Views.Theme.Colors.oceanLight,
        Passage.Views.Theme.Colors.oceanDark,
        Passage.Views.Theme.Colors.forestLight,
        Passage.Views.Theme.Colors.forestDark
    ])
    func defaultThemesHaveAllColors(colors: Passage.Views.Theme.Colors) {
        #expect(!colors.primary.isEmpty)
        #expect(!colors.onPrimary.isEmpty)
        #expect(!colors.secondary.isEmpty)
        #expect(!colors.onSecondary.isEmpty)
        #expect(!colors.surface.isEmpty)
        #expect(!colors.onSurface.isEmpty)
        #expect(!colors.onSurfaceVariant.isEmpty)
        #expect(!colors.background.isEmpty)
        #expect(!colors.onBackground.isEmpty)
        #expect(!colors.error.isEmpty)
        #expect(!colors.onError.isEmpty)
        #expect(!colors.warning.isEmpty)
        #expect(!colors.onWarning.isEmpty)
        #expect(!colors.success.isEmpty)
        #expect(!colors.onSuccess.isEmpty)
        #expect(!colors.outline.isEmpty)
    }

    @Test("All color values are valid hex codes", arguments: [
        Passage.Views.Theme.Colors.defaultLight,
        Passage.Views.Theme.Colors.defaultDark
    ])
    func colorValuesAreValidHexCodes(colors: Passage.Views.Theme.Colors) {
        let allColors = [
            colors.primary, colors.onPrimary, colors.secondary, colors.onSecondary,
            colors.surface, colors.onSurface, colors.onSurfaceVariant,
            colors.background, colors.onBackground,
            colors.error, colors.onError,
            colors.warning, colors.onWarning,
            colors.success, colors.onSuccess,
            colors.outline
        ]

        for color in allColors {
            #expect(color.hasPrefix("#"))
            #expect(color.count == 7) // #RRGGBB format
        }
    }

    // MARK: - Theme Color Pairs Tests

    @Test("Ocean theme has both light and dark variants")
    func oceanThemeVariants() {
        let light = Passage.Views.Theme.Colors.oceanLight
        let dark = Passage.Views.Theme.Colors.oceanDark

        #expect(light.primary != dark.primary)
        #expect(light.background != dark.background)
    }

    @Test("Forest theme has both light and dark variants")
    func forestThemeVariants() {
        let light = Passage.Views.Theme.Colors.forestLight
        let dark = Passage.Views.Theme.Colors.forestDark

        #expect(light.primary != dark.primary)
        #expect(light.background != dark.background)
    }

    @Test("Sunset theme has both light and dark variants")
    func sunsetThemeVariants() {
        let light = Passage.Views.Theme.Colors.sunsetLight
        let dark = Passage.Views.Theme.Colors.sunsetDark

        #expect(light.primary != dark.primary)
        #expect(light.background != dark.background)
    }

    // MARK: - Sendable Conformance Tests

    @Test("Theme conforms to Sendable")
    func themeIsSendable() {
        let theme: any Sendable = Passage.Views.Theme(colors: .defaultLight)
        #expect(theme is Passage.Views.Theme)
    }

    @Test("Theme.Colors conforms to Sendable")
    func colorsIsSendable() {
        let colors: any Sendable = Passage.Views.Theme.Colors.defaultLight
        #expect(colors is Passage.Views.Theme.Colors)
    }

    @Test("Theme.Brightness conforms to Sendable")
    func brightnessIsSendable() {
        let brightness: any Sendable = Passage.Views.Theme.Brightness.light
        #expect(brightness is Passage.Views.Theme.Brightness)
    }
}
