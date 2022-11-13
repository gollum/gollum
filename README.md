gollum -- A git-based Wiki
====================================




### Service

Gollum can also be run as a service. More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-as-a-service).

## CONFIGURATION

Gollum comes with the following command line options:

| Option            | Arguments | Description |
| ----------------- | --------- | ----------- |
| --host            | [HOST]    | Specify the hostname or IP address to listen on. Default: '0.0.0.0'.<sup>1</sup> |
| --port            | [PORT]    | Specify the port to bind Gollum with. Default: `4567`. |
| --config          | [FILE]    | Specify path to Gollum's [configuration file](#Config-file). |
| --ref             | [REF]     | Specify the git branch to serve. Default: `master`. |
| --bare            | none      | Tell Gollum that the git repository should be treated as bare. |
| --adapter         | [ADAPTER] | Launch Gollum using a specific git adapter. Default: `rugged`.<sup>2</sup> |
| --base-path       | [PATH]    | Specify the leading portion of all Gollum URLs (path info). Setting this to `/wiki` will make the wiki accessible under `http://localhost:4567/wiki/`. Default: `/`. |
| --page-file-dir   | [PATH]    | Specify the subdirectory for all pages. If set, Gollum will only serve pages from this directory and its subdirectories. Default: repository root. |
| --static, --no-static | none  | Use static assets. Defaults to false in development/test,  true in production/staging. |
| --assets          |  [PATH]   | Set the path to look for static assets. |
| --css             | none      | Tell Gollum to inject custom CSS into each page. Uses `custom.css` from wiki root.<sup>3</sup> |
| --js              | none      | Tell Gollum to inject custom JS into each page. Uses `custom.js` from wiki root.<sup>3</sup> |
| --no-edit         | none      | Disable the feature of editing pages. |
| --local-time | none      | Use the browser's local timezone instead of the server's for displaying dates. Default: false.
| --follow-renames, --no-follow-renames  | none      | Follow pages across renames in the History view. Default: true.
| --allow-uploads   | [MODE]    | Enable file uploads. If set to `dir`, Gollum will store all uploads in the `/uploads/` directory in repository root. If set to `page`, Gollum will store each upload at the currently edited page.<sup>4</sup> |
| --mathjax         | none      | Enables MathJax (renders mathematical equations). By default, uses the `TeX-AMS-MML_HTMLorMML` config with the `autoload-all` extension.<sup>5</sup> |
| --critic-markup   | none      | Enable support for annotations using [CriticMarkup](http://criticmarkup.com/). |
| --irb             | none      | Launch Gollum in "console mode", with a [predefined API](https://github.com/gollum/gollum-lib/). |
| --h1-title        | none      | Tell Gollum to use the first `<h1>` as page title. |
| --no-display-metadata | none  | Do not render metadata tables in pages. |
| --user-icons      | [MODE]    | Tell Gollum to use specific user icons for history view. Can be set to `gravatar`, `identicon` or `none`. Default: `none`. |
| --mathjax-config  | [FILE]    | Specify path to a custom MathJax configuration. If not specified, uses the `mathjax.config.js` file from repository root. |
| --template-dir    | [PATH]    | Specify custom mustache template directory. Only overrides templates that exist in this directory. |
| --template-page   | none      | Use _Template in root as a template for new pages. Must be committed. |
| --emoji           | none      | Parse and interpret emoji tags (e.g. `:heart:`) except when the leading colon is backslashed (e.g. `\:heart:`). |
| --default-keybind | none      | Set the default keybinding for the editor. Can be set to `vim`, or `emacs`. |
| --lenient-tag-lookup | none | Internal links resolve case-insensitively, will treat spaces as hyphens, and will match the first page found with a certain filename, anywhere in the repository. Provides compatibility with Gollum 4.x. |
| --help            | none      | Display the list of options on the command line. |
| --version         | none      | Display the current version of Gollum. |
| --versions        | none      | Display the current version of Gollum and auxiliary gems. |
