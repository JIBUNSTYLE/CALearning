CALearning
==========

1. フォルダ構成
2. Viewの表示
3. ユースケースのコードによる表現
4. ドメインモデルの実装
5. プレゼンテーション層でのユースケース呼び出し
6. インフラ層と依存性逆転の原則
7. 振る舞い駆動開発


# 1. フォルダ構成

Clean Architecture では、`Domain` と `Application` とその他（`Infrastructure`／`Presentation`）をレイヤーとして明確に分けます。ここでは、`Domain`／`Application`／`Infrastructure`／`Presentation` を Service 以下に、下記のように配置します。

```
CALearning
  ├─ Service
  │    ├─ Domain
  │    ├─ Application
  │    ├─ Infrastructure
  │    └─ Presentation
  ├─ System
  ├─ CALearningApp 
  └─ ContentView
```

その他、アーキテクチャの実装に必要なprotocolなどをまとめるためにSystemフォルダを用意しておきます。

# 2. Viewの表示

新規プロジェクト作成時点で、`View` として ContetView.swift が作られます。 ContetView はアプリの実体である CALearningApp から呼ばれています。

ここでは、ContentView はサービスの `View` の表示を制御するものとして利用することにし、`Viewコンテナ` と呼びます。

具体的には、アプリの状態に基づいてサービスの `View`、例えば splash／tutorial／login を出し分ける（＝遷移させる）ようにします。


## 1.1 Viewを作成する

Service/Presentation/Viewsフォルダを作成し、Splash.swift／Tutorial.swift／Login.swift の3つの SwiftUI View ファイルを新規作成します。
"Hello, World!"の替わりに"Splash"など、画面が分かる文言を表示するようにしましょう。
 
## 1.2 ルーティングを実装する

ContentViewが状態として、表示したいViewに対応するenumを保持するようにします。

```ContetView.swift

enum Views {
    case splash, tutorial, login
}

struct ContentView: View {
    var currentView: Views = .splash

    var body: some View {
        switch self.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .login:
            Login()
        }
    }
}
```

previewを表示させて、Splashが表示されていることを確認します。
currentViewの値を変えることで、TutorialやLoginが表示されていることを確認します。


# 3. ユースケースのコードによる表現

ここではユースケースをenumで表現します。

## 3.1 ユースケースシナリオの記述

Service/Application/Useasesフォルダを作成し、Boot.swift の Swiftファイルを新規作成します。

ユースケースシナリオの基本コース／代替コースを以下のようにenumの入れ子で表現します。
デフォルト値としシナリオの初めの状態をinit関数で定義します。


```Boot.swift
/// ユースケース【アプリを起動する】を実現します。
enum Boot {
    enum Basics {
        case アプリはユーザがチュートリアル完了の記録がないかを調べる
        case チュートリアル完了の記録がある場合_アプリはログイン画面を表示
    }
    
    enum Alternatives {
        case チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示
    }
    
    case basic(scene: Basics)
    case alternate(scene: Alternatives)
    
    init() {
        self = .basic(scene: .アプリはユーザがチュートリアル完了の記録がないかを調べる)
    }
}
```

Swift の enum はとても強力で、入れ子にできたり、associated valueを持つことができたり、関数を持たせることができます。
@see: https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html

## 3.2 ユースケースの実装

enumで定義したユースケースのシナリオを実行可能にします。
具体的には再起呼び出しを使って、シナリオの一つひとつ（ここではシーンと呼ぶことにします）を処理していくようにします。

System/Protocolsフォルダを作成し、Usecase.swift の Swiftファイルを新規作成します。

```Usecase.swift
import Combine

protocol Usecase {
    /// 自身が表すユースケースのSceneを実行した結果として、次のSceneがあれば次のSceneを返すFutureを、ない（シナリオの最後の）場合には nil を返します。
    func next() -> AnyPublisher<Self, Error>?
    
    /// 引数で渡されたSceneを次のSceneとして返します。
    /// next関数の実装時、特にドメイン的な処理がSceneが続く場合に使います。
    func just(next: Self) -> AnyPublisher<Self, Error>
    
    /// Usecaseに準拠するenumを引数に取り、再帰的にnext()を実行します。
    ///
    /// - Parameter contexts: ユースケースシナリオの（画面での分岐を除く）分岐をけcaseに持つenumのある要素
    /// - Returns: 引数のenumと同様のenumで、引数の分岐を処理した結果の要素
    func interact() -> AnyPublisher<[Self], Error>
}

extension Usecase {
    
    func just(next: Self) -> AnyPublisher<Self, Error> {
        return Deferred {
            Future<Self, Error> { promise in
                promise(.success(next))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func recursive(contexts: [Self]) -> AnyPublisher<[Self], Error> {
        guard let context = contexts.last else { fatalError() }
        
        // 終了条件
        guard let future = context.next() else {
            return Deferred {
                Future<[Self], Error> { promise in
                    promise(.success(contexts))
                }
            }
            .eraseToAnyPublisher()
        }
        
        // 再帰呼び出し
        return future
            .flatMap { nextContext -> AnyPublisher<[Self], Error> in
                var _contexts = contexts
                _contexts.append(nextContext)
                return self.recursive(contexts: _contexts)
            }
            .eraseToAnyPublisher()
    }
    
    func interact() -> AnyPublisher<[Self], Error> {
        return self.recursive(contexts: [self])
    }
}
```

CombineはReactiveX（RxSwift）のApple版で、非同期処理によるデータの変更を別の処理に伝播させるといった Reactiveプログラミングを実現するフレームワークです。
@see: https://developer.apple.com/documentation/combine


BootをUsecaseプロトコルを準拠するようにし、next関数を実装します。
next関数は、自身が表すシーンの次のシーンを返すように実装します。処理終了の場合には nil を返すようにします。

```Boot.switf
enum Boot : Usecase {
    ...
    
    func next() -> AnyPublisher<Boot, Error>? {
        switch self {
        case .basic(.アプリはユーザがチュートリアルを完了した記録がないかを調べる):
            // TODO
        case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示):
            // TODO
        case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示):
            // TODO
        }
    }
```

例えば以下のようにし、detect関数の中でチュートリアルの完了記録があるか否かを調べることとします。

```Boot.swift
    func next() -> AnyPublisher<Boot, Error>? {
        switch self {
        case .basic(.アプリはユーザがチュートリアルを完了した記録がないかを調べる):
            return self.detect()
        case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示):
            return nil
        case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示):
            return nil
        }
    }
```

```Boot.swift
    private func detect() -> AnyPublisher<Boot, Error> {
        // Deferredでsubscribesされてから実行されるようになる
        // Futureは一度だけ結果を返す
        return Deferred {
            Future<Boot, Error> { promise in
                // Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
                // 非同期処理が終わる前にsubsciptionはキャンセルされてしまうので注意
                // @see: https://forums.swift.org/t/combine-future-broken/28560/2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if /* TODO: ドメインモデルが持つメソッドが結果を返すようにする */ {
                        promise(.success(.basic(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示)))
                    } else {
                        promise(.success(.alternate(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
```

ここではSplashを2秒表示させるものとして実装しています。

# 4. ドメインモデルの実装

一旦、ユースケースの実装は置いておいて、ドメインモデルを作成します。

## 4.1 ドメインモデルを作成する

様々な値をアプリが保持するので、アプリを表すドメインモデルをオブジェクトとして作成します。

Service/Domain/Modelsフォルダ作成し、Application.swift の Swiftファイルを新規作成します。

```Application.swift
class Application {

    var hasCompletedTutorial: Bool {
        get {
            // TODO
            return true
        }
        set {
            // TODO
        }
    }
}
```

一旦、呼ばれたら true を返すのみとします。
在るべき実装としては、データ読み書き用のプロトコルを宣言し、それを実装する形でインフラ層でデータ読み書き機能を実装し、それを使うようにします（6で行います）。

## 4.2 ドメインモデルを利用してユースケースを実装する


```Boot.swift
    private func detect() -> AnyPublisher<Boot, Error> {
        // Deferredでsubscribesされてから実行されるようになる
        // Futureは一度だけ結果を返す
        return Deferred {
            Future<Boot, Error> { promise in
                // Futureが非同期になる場合、sinkする側ではcancellableをstoreしておかないと、
                // 非同期処理が終わる前にsubsciptionはキャンセルされてしまうので注意
                // @see: https://forums.swift.org/t/combine-future-broken/28560/2
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if Application().hasCompletedTutorial {
                        promise(.success(.basic(scene: .チュートリアル完了の記録がある場合_アプリはログイン画面を表示)))
                    } else {
                        promise(.success(.alternate(scene: .チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
```

# 5. プレゼンテーション層でのユースケース呼び出し

ユーザの入力イベントなどをトリガーとして、プレゼンテーション層からユースケースを実行する必要があります。

## 5.1 ユースケースの実行

以下のように、Bootユースケースを初期化し、interact関数を実行し、結果をサブスクライブするようにします（これをどこに実装するかについては5.2参照）。
結果は実際に実行されたシーンの配列（これをscenarioと呼ぶことにします）で返ってくるので、その最後のシーンが何だったかによって、次の処理を変更します。

```swift
    Boot()
        .interact()
        .sink { completion in
            if case .finished = completion {
                print("boot は正常終了")
            } else if case .failure(let error) = completion {
                print("boot が異常終了: \(error)")
            }
        } receiveValue: { scenario in
            print("usecase - boot: \(scenario)")
            
            if case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示) = scenario.last {
                // TODO

            } else if case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示) = scenario.last {
                // TODO
            }
        }
```

## 5.2 ユースケースをどこから呼ぶべきか

拡張性の担保や再利用性を考えた場合、Viewは表示のために設定された値を表示するためのコードのみを持つべきです。
値を取得するためのコード、ユースケースの結果に応じて表示内容を加工するなどの処理は、別のオブジェクトで担うようにします。

ここではそれら、Viewから呼ばれてユースケースを実行し、その結果をViewに伝える（Viewが参照する値を保持する）役割をもつオブジェクトを`Presenter`とします。

## 5.3 Presenterの実装

先述の通り、「Viewは表示のために設定された値を表示するためのコードのみを持つべき」です。Viewを表示するには、ユーザに表示したい様々な値を設定してあげる必要があります。

この処理を、SwiftUIでは Swift5.1で導入された`Property Wrapper`という機能を使って実現しています。

`Property Wrapper` とは、プロパティの制御をテンプレート化したもので、SwiftUI でのView Modelとして `ObservableObject` などの `Property Wrapper` が用意されています。
@see: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app

ここでは、`Presenter` を `ObservableObject` として実装します。


```Presenter.swift
import Combine

class Presenter: ObservableObject {
    
    private var cancellables = [AnyCancellable]()
    
    func boot() {
        Boot()
            .interact()
            .sink { completion in
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    print("boot が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                if case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示) = scenario.last {
                    // TODO

                } else if case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示) = scenario.last {
                    // TODO
                }
            }
            .store(in: &cancellables)
    }
}
```

ユースケースの実行結果で遷移する画面を変更したいため、ContetViewで保持していた currentViewプロパティ を `Presenter` に移植します。


```Presenter.swift
class Presenter: ObservableObject {
    
    @Published var currentView: Views = .splash
    
    private var cancellables = [AnyCancellable]()
    
    func boot() {
        Boot()
            .interact()
            .sink { completion in
                if case .finished = completion {
                    print("boot は正常終了")
                } else if case .failure(let error) = completion {
                    print("boot が異常終了: \(error)")
                }
            } receiveValue: { scenario in
                print("usecase - boot: \(scenario)")
                
                if case .basic(.チュートリアル完了の記録がある場合_アプリはログイン画面を表示) = scenario.last {
                    self.currentView = .login

                } else if case .alternate(.チュートリアル完了の記録がない場合_アプリはチュートリアル画面を表示) = scenario.last {
                    self.currentView = .tutorial
                }
            }
            .store(in: &cancellables)
    }
}
```

## 5.4 ViewとPresenterをつなぐ

`Presenter` を `ObservableObject` として作成しましたが、`ObservableObject` を View（SwiftUI）に繋ぐ方法には以下があります。

### 5.4.1 単一のViewとつなぐ（ライフサイクルなし）

以下のように `@StateObject` として宣言すると、作成されたプロパティは、Viewが書き変わっても値が保持されます。

```swift
struct ContentView: View {

    @StateObject var presenter = Presenter()
    ...
```

### 5.4.1 単一のViewとつなぐ（ライフサイクルあり）

以下のように `@ObservedObject` として宣言すると、作成されたプロパティは、Viewが書き変わると初期化されます。


```swift
struct ContentView: View {

    @ObservedObject var presenter = Presenter()
    ...
```

### 5.4.2 あるView以下の子孫すべてとつなぐ

以下のように、`.environmentObject`モディファイアで指定し、View側に `@EnvironmentObject`を用意すると、`.environmentObject`モディファイアで指定したView以下、すべての子孫で同一の `Presenter` を参照できます。

```CALearningApp.swift
@main
struct CALearningApp: App {

    @StateObject var presenter = Presenter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presenter)
        }
    }
}
```
```ContentView.swift
struct ContentView: View {

    @EnvironmentObject var presenter: Presenter
    ...
}
``` 

ここでは `environmentObject` を選択します。

```CALearningApp.swift@main
struct CALearningApp: App {

    @StateObject var presenter = Presenter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presenter)
        }
    }
}
```

```ContentView.swift
struct ContentView: View {

    @EnvironmentObject var presenter: Presenter

    var body: some View {
        switch presenter.currentView {
        case .splash:
            Splash()
        case .tutorial:
            Tutorial()
        case .login:
            Login()
        }
    }
}
```

プレビューでは各Viewで直接追加しましょう。

```ContentView.swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Presenter())
    }
}
```


## 5.5 ViewからPresenterを経由してユースケースを実行する


アプリが起動されるとまずはSplash画面を表示し、ユースケース「ユーザはアプリを起動する」が実行されるようにします。
以下のように、Splash内で onAppearモディファイアを使ってPresenterのメソッドを呼び出します。

```Splash.swift
struct Splash: View {
    
    @EnvironmentObject var presenter: Presenter
    
    var body: some View {
        Text("Slash")
            .onAppear {
                self.presenter.boot()
            }
    }
}
```

Run でアプリを実行します。「Splash」が表示されてから、2秒後に「Login」と自動で変わり、画面遷移したことが確認できます。

また、以下のようにコンソールにログが出ています。

> usecase - boot: [CALearning.Boot.basic(scene: CALearning.Boot.Basics.アプリはユーザがチュートリアルを完了した記録がないかを調べる), CALearning.Boot.basic(scene: CALearning.Boot.Basics.チュートリアル完了の記録がある場合_アプリはログイン画面を表示)]
> boot は正常終了

これは usecase bootが実行され、基本コースの `アプリはユーザがチュートリアルを完了した記録がないかを調べる` → `チュートリアル完了の記録がある場合_アプリはログイン画面を表示` というシナリオを通ったことを示しています。


# 6. インフラ層と依存性逆転の原則

さて、ドメインモデルの実装に戻ります。
チュートリアルが終わっているか否かをドメインモデルであるApplicationが判断できるようにしたいですが、ここでデータ保存などのインフラ層に置くべきコードを書くのはご法度です。

そこで、依存性逆転の原則に則り、データ保存の仕様を決めるプロトコルを作成し、インフラ層でそれを実装するようにします。

Service/Domain/Interfacesフォルダを作成し、DataStore.swift の Swift ファイルを新規作成します。

```DataStore.swift
protocol Key: CaseIterable, RawRepresentable where Self.RawValue == String {
    associatedtype ValueType
}

enum KeyValue {

    enum BoolKey: String, Key {
        typealias ValueType = Bool
        case hasCompletedTutorial
    }
    
    case bool(key: BoolKey, value: BoolKey.ValueType)
}

protocol StoreInterface {

    /// データの保存
    func save(_ keyValue: KeyValue)

    /// データの取り出し
    func get<T: Key>(_ key: T) -> T.ValueType?

    /// データの削除
    func delete<T: Key>(_ key: T)
}
```

これを実装するクラスため、Service/Infrastructureフォルダを作成し、UserDefaultsDataStore.swift の Swiftファイルを新規作成します。
ここではデータストアの実体としてUserDefaultsを使います。

```UserDefaultsDataStore.swift
struct UserDefaultsDataStore : DataStore {
    
    func save(_ keyValue: KeyValue) {
        switch keyValue {
        case .bool(let key, let value):
            UserDefaults.standard.set(value, forKey: key.rawValue)
        }
    }
    
    func get<T: Key>(_ key: T) -> T.ValueType? {
        return UserDefaults.standard
            .object(forKey: key.rawValue) as? T.ValueType
    }
    
    func delete<T: Key>(_ key: T) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
```

ドメインモデルからインフラ層での実装を呼び出すため、実装を抽象化して保持するシングルトンオブジェクトを作成します。
Service/Domain 以下に Dependencies.swift のSwiftファイルを新規作成します。


```Dependencies.swift
struct Dependencies {
    // シングルトン
    static private(set) var shared: Dependencies = Dependencies()
    
    // 依存性逆転が必要なものが増えたら足していく
    var dataStore: DataStore
   
    init(
        dataStore: DataStore = UserDefaultsDataStore()
    ) {
        self.dataStore = dataStore
    }
    
    /// mockなどを差し込む際に使う
    func set(mock: Dependencies) {
        Dipendencies.shared = mock
    }
}
```

ドメインモデル Application の hasCompletedTutorialの実装は以下のようになります。

```Application.swift
    var hasCompletedTutorial: Bool {
        get {
            if let value = Dependencies.shared.dataStore.get(KeyValue.BoolKey.hasCompletedTutorial) {
                return value
            } else {
                return false
            }
        }
        set {
            Dependencies.shared.dataStore.save(
                .bool(key: .hasCompletedTutorial, value: newValue)
            )
        }
    }
```


# 7. 振る舞い駆動開発

QuickおよびNimbleというパッケージをUnitTest用のターゲットに導入します。
Xcodeのメニューから、File > Add packages... を開き、右上の検索窓に以下を入力し、パッケージを追加します。

- https://github.com/Quick/Quick.git
- https://github.com/Quick/Nimble.git

SwiftPMのパッケージ検索は[ここ](https://swiftpackageindex.com/)で行えます。
追加する際に、どのTargetに追加するかを問われるので、UnitTestsを選択します。


ここではユースケース毎にSpecファイルを作成することにします。
Testsフォルダ以下に、`Unit Test Case Class`としてBootSpecをQuickSpecのサブクラスとして新規作成します。


```BootSpec.swift
import XCTest
@testable import CALearning

import Quick
import Nimble

class BootSpec: QuickSpec {

    override func spec() {
        let presenter = Presenter()
        
        describe("アプリを起動する") {
            context("チュートリアル完了の記録がある場合") {
                beforeEach {
                    presenter.currentView = .splash
                    Application().hasCompletedTutorial = true
                }
                it("アプリはログイン画面を表示") {
                    presenter.boot()
                    
                    expect(presenter.currentView)
                        .toEventually(equal(Views.login), timeout: .seconds(2))
                        
                }
            }
            context("チュートリアル完了の記録がない場合") {
                beforeEach {
                    presenter.currentView = .splash
                    Application().hasCompletedTutorial = false
                }
                it("アプリはチュートリアル画面を表示") {
                    presenter.boot()
                    
                    expect(presenter.currentView)
                        .toEventually(equal(Views.tutorial), timeout: .seconds(2))
                }
            }
        }
    }
}
```

describe にはユースケースを記述します。
context にはユースケースシナリオの分岐部分を記述します。
it には期待する結果を記述します。

itってなんやねん、というと、英語では it should be... と期待する結果を書くから it なのです。

ユースケースシナリオ＝仕様＝テストです。テストさえ書けば、詳細設計書は不要です（Tests as Documentation）。

このアーキテクチャでは、Viewがユーザの操作を受け付けるとPresenterを通してユースケースを実行するので、振る舞いテストとしては、Viewから呼ぶPresenterのメソッドを直接呼び出し、View Modelなどが期待する結果となっているかのアサーションを記述します。


もちろんユースケース以外にも、複雑なメソッドの機能テストも振る舞いを記述してテストをすることができます。

```swift
    describe("UserDefaultsDataStore.save") {
        context("引数が .bool(key: .hasCompletedTutorial, value: true )") {
            it("UserDefautlsに文字列キーhasCompletedTutorialで、trueが保存されること) {
                UserDefaultsDataStore().save(.bool(key: .hasCompletedTutorial, value: true))
                
                expect {
                    guard let result = UserDefaults.standard.object(forKey: "hasCompletedTutorial") as? Bool else {
                        return .failed(reason: "hasCompletedTutorialをキーとする値がありません")
                    }
                }.to(beTrue())
                    
            }
        }
    }
```

これは関数の仕様書であり、使い方のサンプルでもあります（Specification by Example）。

// 以上
