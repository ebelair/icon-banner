<h3 align="center">
  <a href="https://github.com/ebelair/icon-banner/blob/master/.assets/icon_banner.png">
  <img src="https://github.com/ebelair/icon-banner/blob/master/.assets/icon_banner.png?raw=true" alt="IconBanner" width="400">
  </a>
</h3>

[![GitHub: @ebelair](https://img.shields.io/badge/author-@ebelair-blue.svg?style=flat)](https://github.com/ebelair)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/icon-banner.svg?style=flat)](https://rubygems.org/gems/icon-banner)
[![Fastlane](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-icon_banner)

**IconBanner** adds custom nice-looking banners over your mobile app icons.

It is available both as a **command-line tool** and as a **Fastlane plugin**.

## Introduction

**IconBanner** is inspired by the great [HazAT/badge](https://github.com/HazAT/badge). It provides custom banner creation on-the-fly, allowing to create different text banners for different build contexts.

It allows to create this kind of icons:

### 🍏 iOS

|Original|Daily|QA|Staging|Production|
|---|---|---|---|---|
|![FaceTime Regular](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.appiconset/facetime.png)|![FaceTime Daily](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/facetime_Daily.png)|![FaceTime QA](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/facetime_QA.png)|![FaceTime Staging](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/facetime_Staging.png)|![FaceTime Production](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/facetime_Production.png)|
|![iBooks Regular](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.appiconset/ibooks.png)|![iBooks Daily](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/ibooks_Daily.png)|![iBooks QA](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/ibooks_QA.png)|![iBooks Staging](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/ibooks_Staging.png)|![iBooks Production](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/ibooks_Production.png)|
|![Podcasts Regular](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.appiconset/podcasts.png)|![Podcasts Daily](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/podcasts_Daily.png)|![Podcasts QA](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/podcasts_QA.png)|![Podcasts Staging](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/podcasts_Staging.png)|![Podcasts Production](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/podcasts_Production.png)|
|![TestFlight Regular](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.appiconset/testflight.png)|![TestFlight Daily](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/testflight_Daily.png)|![TestFlight QA](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/testflight_QA.png)|![TestFlight Staging](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/testflight_Staging.png)|![TestFlight Production](https://github.com/ebelair/icon-banner/raw/master/spec/Sample.reference/testflight_Production.png)|

### 🤖 Android

|Original|Daily|QA|Staging|Production|
|---|---|---|---|---|
|![Calender Regular](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_icons/calendar/ic_launcher.png)|![Calender Daily](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/calendar/ic_launcher_Daily.png)|![Calender QA](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/calendar/ic_launcher_QA.png)|![Calender Staging](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/calendar/ic_launcher_Staging.png)|![Calender Production](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/calendar/ic_launcher_Production.png)|
|![Games Regular](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_icons/games/ic_launcher.png)|![Games Daily](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/games/ic_launcher_Daily.png)|![Games QA](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/games/ic_launcher_QA.png)|![Games Staging](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/games/ic_launcher_Staging.png)|![Games Production](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/games/ic_launcher_Production.png)|
|![Mail Regular](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_icons/mail/ic_launcher.png)|![Mail Daily](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/mail/ic_launcher_Daily.png)|![Mail QA](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/mail/ic_launcher_QA.png)|![Mail Staging](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/mail/ic_launcher_Staging.png)|![Mail Production](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/mail/ic_launcher_Production.png)|
|![Movies Regular](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_icons/movies/ic_launcher.png)|![Movies Daily](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/movies/ic_launcher_Daily.png)|![Movies QA](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/movies/ic_launcher_QA.png)|![Movies Staging](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/movies/ic_launcher_Staging.png)|![Movies Production](https://github.com/ebelair/icon-banner/raw/master/spec/ic_launcher_reference/movies/ic_launcher_Production.png)|

## Setup

### 🚀 Fastlane

Start by running this command in your project repository:

```bash
fastlane add_plugin icon_banner
```

Then simply add the following actions in your Fastfile:

```ruby
lane :sample do
  icon_banner([options])
  # [build_ios_app and other actions]
  icon_banner_restore()
end
```

For more details, see the [Usage](https://github.com/ebelair/icon-banner#options) section below.

### 💻 Standalone

First install the gem:

```bash
gem install icon-banner
```

Then use it directly from the root of your app repository:

```bash
icon-banner generate [options]
icon-banner restore
```

For more details, see the [Usage](https://github.com/ebelair/icon-banner#options) section below.

## Usage

### Generate

Generates banners and adds them to app icons. Available via:

- The `icon_banner()` Fastlane action
- The `icon-banner generate` terminal command

| Key     | Description                        | Default |
|--------|------------------------------------|---------|
| label  | Sets the text to display inside the banner    | BETA    |
| color  | Sets the text color (when not set, the script uses the dominant icon color)      |         |
| font   | Sets the text font with a _direct link_ to a TTF file (when not set, the script uses the embedded LilitaOne font) |         |
| backup | Creates a backup of icons before applying banners (only set to `false` if you are under source-control)  | true     |

Sample usages:

```ruby
# fastlane
icon_banner(label: 'QA')
icon_banner(label: 'QA', color: '#ff000088', font: '/Users/johndoe/Documents/mybestfont.ttf')
```

```bash
# command-line
icon-banner generate --label QA
icon-banner generate --label QA --color '#ff000088' --font '/Users/johndoe/Documents/mybestfont.ttf'
```

### Restore

Restores app icons without banners (if backups are available). Available via:

- The `icon_banner_restore()` Fastlane action
- The `icon-banner restore` terminal command

No options are required – if backup files are available, they are automatically restored.

Sample usage:

```ruby
# fastlane
icon_banner_restore()
```

```bash
# command-line
icon-banner restore
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ebelair/icon-banner.

## License

IconBanner is ©2019 [ebelair](https://github.com/ebelair) and may be freely distributed under the [MIT license](https://opensource.org/licenses/MIT). See the [`LICENSE`](https://github.com/ebelair/icon-banner/blob/master/LICENSE.md) file.

The project is highly inspired by [`badge` by HazAT](https://github.com/HazAT/badge). Used also under the [MIT license](https://opensource.org/licenses/MIT). Thanks again. 🙏

## About ebelair

[Émile Bélair](https://github.com/ebelair) acts as a Product Owner @ [Mirego](https://www.mirego.com). He enjoys creating great products and works hard with his team to deliver some of the greatest.