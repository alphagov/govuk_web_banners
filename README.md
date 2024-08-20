# GovukWebBanners
Proof of Concept for centralising handling of Recruitment, Global, and Emergency banners (currently spread across apps)

## Usage
Currently, supports recruitment and emergency banners

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

## Recruitment banners

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

## Emergency banners

There are no JS dependencies for the emergency banner, but the rendered banner must be inserted
into a layout component rather than being added directly to your view.

```
<%= render "govuk_publishing_components/components/layout_for_public", {
  emergency_banner: emergency_banner.present? ? render(partial: "govuk_web_banners/emergency_banner") : nil
} %>
```

The emergency banner is set in Whitehall using a shared Redis key. The banner will be shown if the set key
contains valid information (it must have a campaign class and a heading), and if the current path is
not the same as the path set in the emergency banner's link (ie the banner will not show on the page the
banner is directing people to),

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
