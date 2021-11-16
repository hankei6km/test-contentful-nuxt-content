import theme from "@nuxt/content-theme-docs";

export default theme({
  docs: {
    primaryColor: "#3B82F6",
  },
  i18n: {
    locales: () => [
      {
        code: "ja",
        iso: "ja-JP",
        file: "ja-JP.js",
        name: "日本語",
      },
      {
        code: "en",
        iso: "en-US",
        file: "en-US.js",
        name: "English",
      },
    ],
    defaultLocale: "ja",
  },
  buildModules: ["@nuxt/image"],
  modules: ["@nuxt/image"],
  image: {
    // domains: [ ],
    contentful: {
      baseURL: "https://images.ctfassets.net/",
    },
  },
  // CodesandoBox で試したところ、Fork すると置き換わった.
  // 何かのキャッシュが残っているのか?
  // ローカルではコンテナ再起動しても変化しなかったのだが、
  // 現状では再現しないのでコメントアウト.
  // pwa: {
  //   // これを設定しておかないと "static/icon.png" を置き換えても
  //   // デフォルトのアイコン画像が使われる
  //   icon: {
  //     source: "static/icon.png",
  //   },
  // },
  content: {
    markdown: {
      rehypePlugins: [
        [
          "@hankei6km/rehype-image-salt",
          {
            baseURL: "https://images.ctfassets.net/",
            rebuild: {
              tagName: "nuxt-img",
              baseAttrs: 'provider="contentful" data-salt-q=""',
            },
          },
        ],
      ],
    },
  },
  server: {
    // host: 0,
    host: process.env.NODE_ENV !== "production" ? "0" : "localhost", // デフォルト: localhost
  },
  router: {
    base: process.env.BASE_PATH || "/",
  },
  // https://github.com/nuxt/content/issues/376
  hooks: {
    "vue-renderer:ssr:templateParams": function (params) {
      if (process.env.BASE_PATH) {
        params.HEAD = params.HEAD.replace(
          `<base href="${process.env.BASE_PATH}">`,
          ""
        );
      }
    },
  },
  publicRuntimeConfig: {
    baseURL: process.env.BASE_URL || "http://localhost:3000",
  },
});
