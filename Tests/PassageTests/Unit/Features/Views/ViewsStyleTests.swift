import Testing
@testable import Passage

@Suite("Views Style Tests")
struct ViewsStyleTests {

    // MARK: - Style Enum Tests

    @Test("Style enum has all expected cases")
    func styleEnumCases() {
        let styles: [Passage.Views.Style] = [
            .neobrutalism,
            .neomorphism,
            .minimalism,
            .material
        ]

        #expect(styles.count == 4)
    }

    // MARK: - Template Suffix Tests

    @Test("Template suffix for each style", arguments: [
        (Passage.Views.Style.neobrutalism, "neobrutalism"),
        (Passage.Views.Style.neomorphism, "neomorphism"),
        (Passage.Views.Style.minimalism, "minimalism"),
        (Passage.Views.Style.material, "material")
    ])
    func templateSuffix(style: Passage.Views.Style, expectedSuffix: String) {
        #expect(style.templateSuffix == expectedSuffix)
    }

    // MARK: - Sendable Conformance Tests

    @Test("Style conforms to Sendable")
    func styleIsSendable() {
        let style: any Sendable = Passage.Views.Style.neobrutalism
        #expect(style is Passage.Views.Style)
    }
}
