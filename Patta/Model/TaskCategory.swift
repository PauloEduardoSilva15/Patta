//
//  TaskCategory.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import Foundation

enum TaskCategory: String, CaseIterable, Identifiable {
    case alimentacao
    case medicamento
    case higiene
    case vacinacao
    case acompanhamentoMedico
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .alimentacao:
            return "Alimentação"
        case .medicamento:
            return "Medicamentos"
        case .higiene:
            return "Higiene"
        case .vacinacao:
            return "Vacinações"
        case .acompanhamentoMedico:
            return "Acompanhamento Médico"
        }
    }
    
    var icon: String {
        switch self {
        case .alimentacao:
            return "fork.knife"
        case .medicamento:
            return "pills.fill"
        case .higiene:
            return "shower.fill"
        case .vacinacao:
            return "syringe.fill"
        case .acompanhamentoMedico:
            return "cross.fill"
        }
    }
}
