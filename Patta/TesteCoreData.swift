//
//  TesteCoreData.swift
//  Patta
//
//  Created by Pedro Canute on 15/08/26.
//

import SwiftUI
import CoreData
struct TesteCoreData: View {
    
    @EnvironmentObject var controlador: DataController
    @FetchRequest(sortDescriptors: []) var pets: FetchedResults<Pet>
    
    @State var nome = ""
    @State var data_nac = Date()
    var body: some View {
        VStack(spacing: 14){
            TextField("Nome", text: $nome)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350)
            DatePicker("Data de nascimento", selection: $data_nac, displayedComponents: .date)
                .frame(width: 350)
            Button("Criar Pet") {
                criarPet()
            }
            .buttonStyle(.borderedProminent)
            .disabled(nome.isEmpty)
            ListaPet()
        }
    }
    
    func criarPet() {
        let pet = Pet(context: controlador.container.viewContext)
        pet.id = UUID()
        pet.nome = nome
        pet.data_nac = data_nac
        
        do {
           try controlador.salvar()
            
        } catch {
            controlador.container.viewContext.rollback()
            print("Erro ao criar pet", error.localizedDescription)
        }
    }
    
    func buscarPet(id: UUID) throws -> Pet? {
        let pesquisa = Pet.fetchRequest()
        
        pesquisa.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        pesquisa.fetchLimit = 1
        
        return try controlador.container.viewContext.fetch(pesquisa).first
    }
    
    func apagarPet(pet: Pet) {
        controlador.deletar(objeto: pet)
        
        do {
            try controlador.salvar()
        } catch {
            controlador.container.viewContext.rollback()
            print("Erro ao apagar pet", error.localizedDescription)
        }
    }
    
}

#Preview {
    TesteCoreData()
}
