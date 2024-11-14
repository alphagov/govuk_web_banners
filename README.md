# GovukWebBanners
Proof of Concept for centralising handling of Recruitment, Global, and Emergency banners (currently spread across apps)

## Usage
Currently, supports recruitment banners

## Adding the gem to your application
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
  <%= render "govuk_web_banners/recruitment_banner" %>
```

You should make sure this line is above the call to render_component_stylesheets call if your
app is using individual component stylesheets.

## Updating banner information in the gem

Data for the current set of live banners can be found at `config/govuk_web_banners/recruitment_banners.yml`. To
add a banner to the config, add an entry under the banners: array. Note that this array must always be valid,
so if there are no banners in the file, it must contain at least `banners: []`

### Example banner entry

```
banners:
- name: Banner 1
  suggestion_text: "Help improve GOV.UK"
  suggestion_link_text: "Sign up to take part in user research (opens in a new tab)"
  survey_url: https://google.com
  page_paths:
  - /
  - /foreign-travel-advice
  start_date: 21/10/2024
  end_date: 18/11/2024
```

The required keys are `suggestion_text`, `suggestion_link_text`, and `survey_url` (the values to appear in the
banner), and `page_paths` (an array of paths on which the banner should be shown).

Optional keys are `name` (an identifying name for this banner, not rendered anywhere), and `start_date` / `end_date`
(the banner becomes active at the start of the day specified as `start_date`, and stops at the *start* of the day
specified as `end_date`). Start and end dates must be in the DD/MM/YYYY format parsable as a YAML -> Date.


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
