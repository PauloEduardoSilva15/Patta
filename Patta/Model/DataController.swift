////
////  DataController.swift
////  Patta
////
////  Created by Pedro Canute on 14/08/26.
////
//
//import CoreData
//import Combine
//
//@Observable
//class DataController {
//    static let shared = DataController()
//    
//    let container: NSPersistentContainer
//    
//    private init () {
//        container = NSPersistentContainer(name: "TarefaPet")
//        
//        container.loadPersistentStores { [weak self] description, error in
//            if let nsError = error as NSError? {
//                fatalError(
//                    """
//                    Não foi possível abrir o Core Data.
//                    
//                    Código: \(nsError.code)
//                    Descrição: \(nsError.localizedDescription)
//                    Detalhes: \(nsError.userInfo)
//                    """
//                )
//            }
//            
//            print(
//                "Core Data carregado em:",
//                description.url?.absoluteString ?? "URL desconhecida"
//            )
//            
//            self?.seedDefaultVaccines()
//        }
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//    }
//    
//    private func seedDefaultVaccines() {
//        let context = container.viewContext
//        
//        let request = Vaccine.fetchRequest()
//        request.fetchLimit = 1
//        
//        let alreadySeeded = (try? context.count(for: request))
//        guard alreadySeeded == 0 else { return }
//        
//        let defaultVaccines = [
//            "V8 (Óctupla Canina)",
//            "V10 (Décupla Canina)",
//            "V12 (Duodécupla Canina)",
//            "Antirrábica Canina",
//            "Giárdia Canina",
//            "Gripe Canina",
//            "Leishmaniose Canina",
//            "Coronavirose Canina",
//            "Parvovirose Canina",
//            "Cinomose",
//            "Hepatite Infecciosa Canina (Adenovírus tipo 1)",
//            "Leptospirose Canina",
//            "Parainfluenza Canina",
//            "Traqueobronquite Infecciosa Canina",
//            "V3 (Tríplice Felina)",
//            "V4 Felina",
//            "V5 Felina",
//            "Leucemia Felina (FeLV)",
//            "Antirrábica Felina",
//            "Clamidiose Felina",
//            "Peritonite Infecciosa Felina (PIF/FIP)",
//            "Panleucopenia Felina",
//            "Rinotraqueíte Felina (Herpesvírus Felino)",
//            "Calicivirose Felina",
//            "Imunodeficiência Felina (FIV)",
//            "Doença de Newcastle",
//            "Bouba Aviária (Varíola Aviária)",
//            "Influenza Aviária",
//            "Bronquite Infecciosa Aviária",
//            "Doença de Marek",
//            "Gumboro (Bursite Infecciosa)",
//            "Reovirose Aviária",
//            "Encefalomielite Aviária",
//            "Clamidiose Aviária (Psitacose)",
//            "Poliomavírus Aviário (PBFD associado)",
//            "Circovírus Aviário (PBFD)",
//            "Coriza Infecciosa das Aves",
//            "Laringotraqueíte Infecciosa Aviária",
//            "Mixomatose",
//            "Doença Hemorrágica Viral do Coelho (VHD/RHDV)",
//            "Pasteurelose do Coelho",
//            "Cinomose (Furão)",
//            "Antirrábica (Furão)",
//            "Enterite Epizoótica do Furão",
//            "Influenza Equina",
//            "Tétano Equino",
//            "Encefalomielite Equina do Leste",
//            "Encefalomielite Equina do Oeste",
//            "Raiva Equina",
//            "Rinopneumonite Equina",
//            "Arterite Viral Equina",
//            "Febre do Nilo Ocidental",
//            "Adenite Equina (Garrotilho)",
//            "Rotavirose Equina",
//            "Febre Aftosa",
//            "Brucelose Bovina",
//            "Raiva dos Herbívoros (Bovina)",
//            "Clostridiose Bovina (Polivalente)",
//            "Botulismo Bovino",
//            "IBR (Rinotraqueíte Infecciosa Bovina)",
//            "BVD (Diarreia Viral Bovina)",
//            "Leptospirose Bovina",
//            "Carbúnculo Sintomático (Manqueira)",
//            "Carbúnculo Hemático (Antraz)",
//            "Pasteurelose Bovina",
//            "Febre Catarral Maligna",
//            "Peste Suína Clássica",
//            "Parvovirose Suína",
//            "Erisipela Suína",
//            "Circovirose Suína (PCV2)",
//            "Micoplasmose Suína",
//            "Rinite Atrófica Suína",
//            "Colibacilose Suína",
//            "Síndrome Reprodutiva e Respiratória Suína (PRRS)",
//            "Clostridiose Ovina/Caprina (Polivalente)",
//            "Ectima Contagioso",
//            "Linfadenite Caseosa",
//            "Raiva dos Herbívoros (Ovina/Caprina)",
//            "Brucelose Caprina",
//            "Vibriose (Peixes)",
//            "Furunculose (Salmonídeos)",
//            "Septicemia Hemorrágica Viral (Peixes)",
//            "Mixomatose (Roedores)",
//            "Antirrábica (Cavalos-marinhos)",
//            "Doença Respiratória Crônica (Roedores)",
//            "Pasteurelose (Porquinho-da-índia)",
//        ]
//        
//        for title in defaultVaccines {
//            let vaccine = Vaccine(context: context)
//            vaccine.id = UUID()
//            vaccine.title = title
//        }
//        
//        do {
//            try context.save()
//        } catch {
//            print("Erro ao popular vacinas padrão: \(error.localizedDescription)")
//        }
//    }
//}
