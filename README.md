# aika

![aika-image](public/assets/img/aika.jpg)

## 製品概要
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

#### Step 2. index.js (DEBUG)
デバッグ時はpublic/zoom/index.jsの上2行を適時修正して使用してください。

#### Step 3. 実行
当リポジトリのプログラムはVagrant上での動作を想定して開発しています。   

```bash
vagrant up
vagrant ssh
ruby app.rb -o 0.0.0.0
```

##### Vagrant採用理由について
仮想カメラの実装に[v4l2loopback](https://github.com/umlaeute/v4l2loopback)を使用しています。v4l2loopbackはカーネルモジュールであり、全ての開発者のPCで環境を整えるのは難しいと判断したためVagrantを採用しています。

### 製品説明（具体的な製品の説明）

### 特長
#### 1. 仮想カメラ
#### 2. アジェンダの延長機能

### 解決出来ること
オンライン会議における雑談
### 今後の展望
議事録の自動生成
### 注力したこと（こだわり等）
* アジェンダの自動生成
* 仮想カメラの実装

## 開発技術

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
