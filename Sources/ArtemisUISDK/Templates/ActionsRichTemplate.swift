import Foundation
import SwiftUI
import ArtemisSocketSDK

struct ActionsRichTemplate: View {
    let actions: ActionSet
    let context: RichTemplateContext
    @State private var values: [String: String] = [:]
    @State private var usedButtonIds: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(actions.elements) { element in
                switch element.type {
                case "select":
                    Menu {
                        ForEach(element.options) { option in
                            Button(option.label) { values[element.id] = option.id }
                        }
                    } label: {
                        HStack {
                            Text(values[element.id].flatMap { value in element.options.first { $0.id == value }?.label } ?? element.label)
                                .foregroundStyle((values[element.id] ?? "").isEmpty ? TemplateStyle.mutedText : TemplateStyle.text)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(TemplateStyle.mutedText)
                        }
                        .templateInputBorder(accentColor: context.accentColor, focused: !(values[element.id] ?? "").isEmpty)
                    }
                    .onChange(of: values[element.id] ?? "") { newValue in
                        guard !newValue.isEmpty, actions.submitId == nil else { return }
                        context.submitAction(element.id, newValue, nil, actions.renderId)
                    }
                case "input":
                    TextField(element.placeholder ?? element.label, text: binding(for: element))
                        .templateTextField(accentColor: context.accentColor)
                default:
                    Button(element.label) {
                        usedButtonIds.insert(element.id)
                        context.submitAction(element.id, element.value ?? element.label, nil, actions.renderId)
                    }
                    .buttonStyle(OutlinedPillButtonStyle(accentColor: context.accentColor, isSelected: usedButtonIds.contains(element.id)))
                    .disabled(usedButtonIds.contains(element.id))
                }
            }
            if let submitId = actions.submitId, !submitId.templateTrimmed.isEmpty {
                Button(actions.submitLabel ?? "Submit") {
                    context.submitAction(submitId, nil, values, actions.renderId)
                }
                .buttonStyle(FilledCapsuleButtonStyle(accentColor: context.accentColor))
            }
        }
    }

    private func binding(for element: ActionElement) -> Binding<String> {
        Binding(get: { values[element.id] ?? element.value ?? "" }, set: { values[element.id] = $0 })
    }
}
