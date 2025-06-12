# Aplicativo de Personagens da Marvel

Um aplicativo iOS que exibe personagens da Marvel, permite visualizar detalhes dos personagens e gerenciar favoritos.

## Funcionalidades

- Navegar por personagens da Marvel com rolagem infinita
- Buscar personagens por nome
- Visualizar informações detalhadas dos personagens
- Salvar personagens favoritos para visualização offline
- Compartilhar imagens de personagens

## Arquitetura

O aplicativo segue o padrão de arquitetura MVVM (Model-View-ViewModel):

- **Models**: Estruturas de dados que representam personagens e respostas da API
- **Views**: Elementos UIKit para exibir a UI
- **ViewModels**: Camada de lógica de negócios que conecta modelos e visões
- **Services**: Lida com a comunicação da API e a persistência de dados local

## Tecnologias Utilizadas

- Swift 5.0+
- UIKit
- URLSession para comunicação de rede
- UserDefaults para persistência de dados
- XCTest para testes unitários

## Componentes Chave

### Camada de Rede
- `APIClient`: Cliente de rede genérico para fazer requisições à API
- `MarvelAPI`: Endpoints e autenticação para a API da Marvel

### Persistência de Dados
- `FavoriteService`: Gerencia o salvamento e a recuperação de personagens favoritos usando UserDefaults

### Componentes de UI
- Interface baseada em abas com as abas Personagens e Favoritos
- Funcionalidade de busca para filtrar personagens
- Pull-to-refresh para atualizar conteúdo
- Estados vazios para ausência de conteúdo, erros e modo offline

### Funcionalidade de Busca Otimizada

Para a funcionalidade de pesquisa de personagens, o seguinte código foi utilizado:

```swift
private func setupBindings() {
    searchSubject
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { [weak self] query in
            guard let self = self else { return }
            
            self.currentOffset = 0
            if self.isLoading { return }
            
            self.loadCharacters()
        }
        .store(in: &cancellables)
}
````

A inclusão deste trecho de código é crucial para otimizar a experiência de pesquisa do usuário. A utilização de `debounce(for: .seconds(0.5)`, `scheduler: RunLoop.main)` garante que a pesquisa só seja acionada após 0.5 segundos de inatividade do usuário digitando, evitando requisições desnecessárias à API a cada caractere digitado. Isso melhora significativamente a performance e reduz o consumo de dados e recursos do servidor.

Além disso, `.removeDuplicates()` assegura que, se o usuário digitar e apagar o mesmo texto rapidamente, ou digitar o mesmo termo duas vezes seguidas, a pesquisa não será refeita desnecessariamente, otimizando ainda mais o desempenho. Quando uma nova consulta é confirmada, o currentOffset é resetado para 0 para que a pesquisa comece do início, e `loadCharacters()` é chamado para buscar os resultados.

## Instruções de Configuração

1. Clone o repositório
2. Abra MarvelApp.xcodeproj no Xcode
3. Adicione suas chaves da API da Marvel em `MarvelAPI.swift`:
   ```swift
   private static let publicKey = "YOUR_PUBLIC_KEY"
   private static let privateKey = "YOUR_PRIVATE_KEY"
