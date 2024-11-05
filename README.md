# GovukWebBanners
Proof of Concept for centralising handling of Recruitment, Global, and Emergency banners (currently spread across apps)

## Usage
Currently, supports recruitment banners

## Installation
Add this line to your application's Gemfile:

```ruby
gem "govuk_web_banners"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install govuk_web_banners
```

Add the JS dependencies to your existing asset dependencies file:

```
//= require govuk_web_banners/dependencies
```

Add a call to the partial in the layout or view that you want banners to appear in:

```
  <%= render partial: "govuk_web_banners/recruitment_banner" if recruitment_banner.present? %>
```

(The if clause is not strictly necessary, the partial is also guarded by it.) Make sure that
the include is above the render_component_stylesheets call if your app is using individual
component stylesheets.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
