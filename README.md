![aika-image](https://github.com/jphacks/D_2011/raw/master/public/assets/img/aika.jpg)
# aika
## 製品概要
本アプリはZoomでのオンラインミーティングをより円滑に進めるための支援サービスです。
オンラインミーティングではつい雑談などに逸れてしまい、ミーティングが長引いてしまうことが多々あります。そんなオンラインミーティングの進行を制御してくれるサービスがこの「aika」です。
aikeでは事前に設定したアジェンダに沿って、今話すべき議題の提示、時間が過ぎた際に一度全員の音声をミュートにするなどしてミーティングの進行を支援します。
Ruby介してzoom用のバーチャルカメラを作成したところが本サービスの最大のアピールポイントです。
### 製品紹介動画
[製品紹介動画](https://youtu.be/IIrvYkngzpM)  
[iPhoneデモ動画](https://youtu.be/iaB4rb-Tf9Y)
### 背景(製品開発のきっかけ、課題等）
Zoomでの会議は何故か雑談で長くなってしまう。この課題に対して、Zoomでの会議の有能な議長を行ってくれるアプリをつくりました。事前に作成したアジェンダに沿って会議が進められます。議題と残り時間が、仮想カメラ上に表示され現在話し合う内容を確認することができます。勿論、アプリから時間延長などのすべての操作が可能です。また、会議終了後は自動的に議事録が作成され会議の手間を省くことができます。

### 環境構築
#### Step 1. Zoom API Key
token.jsをpublic/zoomに用意してください。
内容はZoomのtokenです

```js
var API_KEY = "";
var API_SECRET = "";
```

#### Step 2. 実行
当リポジトリのプログラムはVagrant上での動作を想定して開発しています。   

```bash
vagrant up
vagrant ssh
bundle exec puma
```

とすることで http://localhost:3000/ でサービスにアクセス出来るようになります。

##### Vagrant採用理由について
仮想カメラの実装に[v4l2loopback](https://github.com/umlaeute/v4l2loopback)を使用しています。v4l2loopbackはカーネルモジュールであり、全ての開発者のPCで環境を整えるのは難しいと判断したためVagrantを採用しています。

### 製品説明（具体的な製品の説明）
### 製品名に込められた思い
aikaは、フィンランド語で"時間"という意味があります。本製品を活用し、すべてのオンライン会議ユーザーが会議の時間管理や雑談の煩わしさから開放されてほしいという思いが込められています。

### 特長
#### 1. 仮想カメラ
仮想カメラを実装する事により、アジェンダをスマートに表示出来るようにしました。
画面共有でアジェンダを見せつつ会議をする事も出来ますが、画面共有の取り合いになってしまったり、そもそも参加者の顔が極端に小さくなり会議に向いていないことからこのような実装を選択しました。

#### 2. アジェンダの延長・短縮機能
早くアジェンダを終わりたい時は、時間を任意の長さに調節することができます。  
アジェンダの時間を予定より長く取りたい場合は、特徴3の自動ミュート機能に邪魔されることなく、会議中のアジェンダの時間の延長することができます。
すべての操作は、スマートフォンで行うことができユーザーは最低限の操作で作業が完了します。

#### 3. aikaによる自動ミュート機能
強制的にミュートにすることでアジェンダの予定時間が終わったことをユーザーに伝えます。その後、ミュート解除のポップアップが表示されるためミュートを解除して会議を継続することができます。
一度、会議の話を止めることで予定時間を超過していること、もし雑談をしていた場合は本題に戻ることをユーザーに意識させることができます。

#### 4. すべての操作はアプリ上で完結
ユーザーは、会議の時間管理から開放されます。すべての操作は、アプリ上で行われユーザーは最低限の操作で、これまで以上のオンライン会議を体験することができます。  
タイマーの表示機能も内臓しているため、アジェンダの残り時間をリアルタイムで知ることができます。

### 解決出来ること
- オンライン会議における雑談
- オンライン会議における時間管理

### 今後の展望
- 議事録の自動生成
- Zoom上に有意義な情報を参加者と同じ枠で表示出来るのでアジェンダ以外も表示

### 注力したこと（こだわり等）
* アジェンダの自動生成
* 仮想カメラの実装

## 開発技術 (サーバーサイド)

### 活用した技術
#### API・データ
* ZoomAPI

#### フレームワーク・ライブラリ・モジュール
* v4l2(loopback)
* FFmpeg
* Sinatra

#### デバイス
* 仮想カメラ

### 独自技術
#### ハッカソンで開発した独自機能・技術
* 仮想カメラ
* https://github.com/jphacks/D_2011/blob/master/zoom_client.rb


## 開発技術 (クライアントサイド)

### 活用した技術
#### SDK
* ZoomSDK

#### フレームワーク・ライブラリ・モジュール
* Eureka
* Floaty
* PKHUD
* RealmSwift
* paper-onboarding
* Alamofire

#### デバイス
* iPhone
* iPad
