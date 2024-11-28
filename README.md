# GovukWebBanners
Proof of Concept for centralising handling of Recruitment, Global, and Emergency
banners (currently spread across apps)

## Usage
Currently supports recruitment banners

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

## Adding recruitment banners

Add a call to the partial in the layout or view that you want banners to appear
in (typically recruitment banners should be in the layout, below the breadcrumbs
and just above the `main` element):

```
  <%= render "govuk_web_banners/recruitment_banner" %>
```

### Required stylesheets

If you are using individual component stylesheets in your app, you should make
sure the call to the recruitment_banner partial is above the call to
render_component_stylesheets in your layout.

If you are _not_ using individual component stylesheets in your app, you will
have to make sure the intervention component's styles are included in your
application stylesheet:

`@import "govuk_publishing_components/components/intervention"`

## Updating banner information in the gem

Data for the current set of live banners can be found at
`config/govuk_web_banners/recruitment_banners.yml`. To add a banner to the
config, add an entry under the banners: array. Note that this array must always
be valid, so if there are no banners in the file, it must contain at least
`banners: []`

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

The required keys are `suggestion_text`, `suggestion_link_text`, and
`survey_url` (the values to appear in the banner), and `page_paths` (an array of
paths on which the banner should be shown).

Optional keys are `name` (an identifying name for this banner, not rendered
anywhere), and `start_date` / `end_date` (the banner becomes active at the start
of the day specified as `start_date`, and stops at the *start* of the day
specified as `end_date`). Start and end dates must be in the DD/MM/YYYY format
parsable as a YAML -> Date.

### Keeping the config file valid and tidy

The config file will be checked during CI, so an invalid file can't be released
as a gem and we are forced to make sure it's kept tidy. These checks include:

* the banners array must be a valid YAML array
* all banners have a suggestion_text, suggestion_link_text, survey_url and
  page_paths
* the same page_path is not present on two banners that are active at the same
  time
* paths must start with a forward-slash (/)

It will also display warnings (but not fail CI)

* if there are banners that have expired - you are encouraged to remove obsolete
  config, but it will not prevent you merging changes.
* if page_paths point to pages that are not currently live on GOV.UK - this may
  be intentional (if the banner is for a page that isn't yet published), or it
  may indicate a typo in the path.

Note that some of this validation code is in the
lib/govuk_web_banners/validators path, which should be tested to ensure the
checking is valid, but will not be bundled into the released gem.

## License
The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
