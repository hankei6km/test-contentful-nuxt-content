# コンテンツセーブ用スクリプト

Contentful のコンテンツをセーブする。

- `save_contents.sh` - コンテンツをセーブするスクリプト
  - GraphQL の query を利用してコンテンツを受信する
- `mapconfig.json` - コンテンツのフィールドをマップ(値を変換)する設定
  - 特定のコンテンツ(`id` で特定する)を親とし、参照されているコンテンツ群を `.md` として保存する
    - コンテンツの並び順を手動で指定するための構成
  - 各フィールドは基本的にはそのまま FrontMatter へマップされる
  - `contents` フィールド(RichText) は Markdown へ変換される

## 概要

Contentful ではコンテンツを手動で並び変える方法(UI)が提供されていない。

よって、なんからの対策を利用者側で実施することになる。今回は「コンテンツを参照する場合、UI 上で並び変えを指定できる」ことを利用している。

そのため「コンテンツを参照するときの利便性」を考慮し API としては GraphQL を利用することにした(Content Delivery API でも扱ええるが制約がある)。

ただし、query の(結果の複雑さの)制限が厳しいので、コンテンツを参照するすべてのケースで GraphQL が適しているとは限らない。

## 設定

以下の環境編集を定義する。

- `RCC_CLIENT_KIND` - `contentful:gql`
- `RCC_API_BASE_URL` - `https://graphql.contentful.com/content/v1/spaces/`
- `RCC_CREDENTIAL__0` - `{SPACE_ID}`
- `RCC_CREDENTIAL__1` - `{CDA_TOKEN}`
- `RCC_MAP_CONFIG` - `scripts/mapconfig.json`
- `RCC_QUERY__0` - `scripts/fragment_ctf.gql`
- `RCC_QUERY__1` - `scripts/query_ctf.gql`

## Contentful からコンテンツを受信する API

スクリプトの内容と直接関係はないのですが、簡単なメモなど。

### GraphQL

おおよそは「CMS + GraphQL だとこうなるだろう(Model と型の紐付けなど)」という形になっている。

以下はメモしておいた項目。

- Model に対して model 名 + `Collection` 型が定義される
  - `*Collection` には `skip` などが定義されている
- Rferences 型は フィールド名 + `Collection` フィールドとなる
  - `skip` などが定義される
    - 参照しているコンテンツでもページネーションが可能
- ページネーションは `skip` などで実装する([Paginating your Contentful blog posts in Next.js with the GraphQL API](https://www.contentful.com/blog/2021/04/23/paginating-contentful-blogposts-with-nextjs-graphql-api/))
- `preview` は `*Collection` 型に定義されている
  - query で `*Collection` に指定するとセレクションセットの全体に適用される
  - 個別の `*Collection` に対して異なる指定を行うことも可能
- `locale` は `*Collection` と各フィールドの型に定義されている
  - query で `*Collection` に指定するとセレクションセットの各フィールドにも適用される
  - 個別のフィールドに対して異なる `locale` を指定することも可能
- RichText 型は `json` フィールドを指定することで document node を取得できる
  - `json` では Embedded Asset などは参照先のみ記述されている
  - `links` を指定することで Embeddes Asset などを取得できる([Rich Text field tips and tricks from the Contentful DevRel team](https://www.contentful.com/blog/2021/05/27/rich-text-field-tips-and-tricks/))
  - Content Delivery API の `include` のようなものは提供されていない
- Asset の `url` はプロトコルが付与されている(`https:` がセットされている)
- サブスクリプションには対応していない
- GraphQL では query の結果の複雑さ(どのような responce が出来上がるか)の制限が厳しいため、ページネーションのページサイズ(`limit`)を小さくする必要がある。
  - ためした限りでは RichText の links を含めるとおおよそで 10 件程度が限界であった

上記のようなことから、「参照しているコンテンツを条件付きで取得する」ような場合は GraphQL は利用しやすい。しかし、ある程度のレコードをまとめて受信するような場合は API 実行回数が増加するので注意が必要。

## Content Delivery API

検索するといろいろ情報は出てくるので引っかかったところだけ。

- Model で定義したフィールドは `fields.*` となる
- 参照されたコンテンツの RichText で embedded asset の内容を含めるには `include` を使う
- `preview` `locale` などはクエリーパラメーターとして指定する(リクエスト単位での指定のみ)
- ページネーションも同様に `skip` などをパラメーターとして指定することで実装可能
  - 参照しているコンテンツを部分的に受信する方法は不明
- API の制限は GraphQL ほど厳しくはなさそう
  - `indelu=2` でも `limit=100` のままで通る(実際に受信はしていないのでサイズ的に弾かれる可能性はある)

Content Delivery API については「参照しているコンテンツを部分的に受信する方法が不明」という点で利用を見送ったが、今回は 10 件程度のレコードしか扱わないので実用上の問題があったというわけでもない。

なお、Content Delivert API を利用しているバージョンは `rest/` に保存してある(preview には未対応)。
