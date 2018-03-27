# Doutaku

[![Language: Swift](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgray.svg?style=flat)](https://img.shields.io/)
[![License](https://img.shields.io/github/license/masakih/Doutaku.svg?style=flat)](https://github.com/masakih/Doutaku/blob/master/LICENSE)
[![Build status](https://travis-ci.org/masakih/Doutaku.svg?style=flat)](https://travis-ci.org/masakih/Doutaku)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/masakih/Doutaku.svg)](https://github.com/masakih/Doutaku/releases/latest)

CoreDataを簡単に扱うためのフレームワーク

# 利用法

## Carthage
[Carthage](https://github.com/Carthage/Carthage)が利用可能です。Cartfileに以下の行を追加してください。
```
github "masakih/Doutaku"
```

# 使い方

## 準備

### プロジェクトを作成する
「use Core Data」を**選択する必要はありません。**

### モデルファイルの作成
モデルファイルは普通に作ってください

### エンティティの作成
エンティティも普通に作ってください。
この時、クラス名とエンティティ名を一致させておくと後が楽です。
Codegenは Manual/None または Class Definition を指定します。 Intの扱いを考えると Manual/None がおすすめです。

### NSManagedObectのサブクラスの作成

```swift
import Doutaku

class Person: NSManagedObject {
    
    @NSManaged public var name: String?
    @NSManaged public var identifier: Int
}

extension Person: EntityProvider {}
```

Doutakuをインポートし EntityProvider プロトコルに準拠させます。


### CoreDataManagerのサブクラスの作成

以下は Model.xcdatamodeld を使用する場合の例です。
通常はこれだけでOKです。
```swift
struct Model: CoreDataManager {
    
    static let core = CoreDataCore(CoreDataConfiguration("Model"))
    
    static let `default` = Model(type: .reader)
    
    let context: NSManagedObjectContext // Use ONLY for CocoaBindings to NSObjectController.
    
    init(type: CoreDataManagerType) {
        
        context = Model.context(for: type)
    }
}
```
データストアファイルは`~/Library/Application Support/{Your Application Bundle Identifier}/Model.storedata`あるいはサンドボックス内の同じ場所に保存されます。

## CoreDataManagerの利用

### オブジェクトの生成
```swift
// 編集用のModelのインスタンスを取得
let model = Model.oneTimeEditor()
defer { model.save() }

// NSManagedObjectContextの所有するqueueで実行
model.sync {
  
  // 新しいPersonをインサート
  let person = model.insertNewObject(for: Person.entity)
  
  person?.name = name
  person?.identifier = model.nextIdentifier()
}
```

### オブジェクトの取得
```swift
extension Model {
    
    // 利用可能なidentifierを取得
    func nextIdentifier() -> Int {
                
        return sync {
            
            let sortDesc = SortDescriptors(keyPath: \Person.identifier, ascending: true)
            
            // すべてのPersonをidentifierの順で取得
            let persons = try? objects(of: Person.entity, sortDescriptors: sortDescs)
            
            return (persons?.first?.identifier ?? 0) + 1
        }
    }
}
```

### オブジェクトの削除
```swift
let selections: [Person] = // Person Objects under OTHER Model instance.

let editorModel = Model.oneTimeEditor()
defer { editorModel.save() }

editorModel.sync {
  selections
    .flatMap(editorModel.exchange)  // 他のModelの管理下にあるPersonをeditorModelの管理下のインスタンスに変換
    .forEach(editorModel.delete) // 削除
}
```
