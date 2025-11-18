# GovukWebBanners
Proof of Concept for centralising handling of Recruitment, Global, and Emergency
banners (currently spread across apps)

## Usage

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

Add the CSS dependencies to your application's CSS file - Note that this is not necessary
if you have single-component support in your app and you're rendering the components early
enough in your layout that their styles can be picked up automatically:

```
@import "govuk_web_banners/dependencies"
```

Note: this import relies on frontend and component support being available in your application's
CSS file. If you do not already have the following lines at the top of the file you'll need to add
them:

```
@import 'govuk_publishing_components/govuk_frontend_support';
@import 'govuk_publishing_components/component_support';
```

## Adding emergency banners

Emergency banners are passed to the [Layout for
Public](https://components.publishing.service.gov.uk/component-guide/layout_for_public)
component, which is currently applied to each frontend app by the slimmer/static
wrapping code - so you will only need to handle emergency banners in your app
when Slimmer is removed from it. Once Slimmer is removed and you are calling the
layout_for_public component directly in your app, add the emergency banner
partial to the component's `emergency_banner:` key:

```
<%= render "govuk_publishing_components/components/layout_for_public", {
  draft_watermark: draft_environment,
  emergency_banner: render("govuk_web_banners/emergency_banner"), # <-- Add this line
  full_width: false,
  ...etc
```

if you want the homepage variant of the banner, you can add `homepage: true` to
the render call:

```
<%= render "govuk_publishing_components/components/layout_for_public", {
  draft_watermark: draft_environment,
  emergency_banner: render("govuk_web_banners/emergency_banner", homepage: true), # <-- Add this line
  full_width: full_width,
  ...etc
```

Your app will also need access to the whitehall shared redis cluster (which is
used to signal the emergency banner is up), via the `EMERGENCY_BANNER_REDIS_URL`
environment variable (here is an example of [setting this in
govuk-helm-charts](https://github.com/alphagov/govuk-helm-charts/blob/7818eaa22fc194d21548f316bcc5a46c2023dcb6/charts/app-config/values-staging.yaml#L3337-L3338)).
You'll need to allow this in all three environments.

Finally, you'll need to configure a connection to the redis cluster, available
at `Rails.application.config.emergency_banner_redis_client`. The suggested way
of doing this is creating an initializer at
`/config/initializers/govuk_web_banners.rb` with the content:

```
Rails.application.config.emergency_banner_redis_client = Redis.new(
  url: ENV["EMERGENCY_BANNER_REDIS_URL"],
  reconnect_attempts: [15, 30, 45, 60],
)
```

### Required stylesheets

If you're not including the style dependencies as above, and not using
single-component autoloading of styles, you'll need to import:

`@import "govuk_web_banners/components/emergency-banner"`

## Adding global banners

Global banners are passed to the [Layout for
Public](https://components.publishing.service.gov.uk/component-guide/layout_for_public)
component, which is currently applied to each frontend app by the slimmer/static
wrapping code - so you will only need to handle global banners in your app when
Slimmer is removed from it. Once Slimmer is removed and you are calling the
layout_for_public component directly in your app, add the global banner partial
to the component's `global_banner:` key:

```
<%= render "govuk_publishing_components/components/layout_for_public", {
  draft_watermark: draft_environment,
  global_banner: render("govuk_web_banners/global_banner"), # <-- Add this line
  full_width: false,
  ...etc
```

## Updating banner information in the gem

Data for the global banners can be found at
`config/govuk_web_banners/global_banners.yml`. To add a banner to the config,
add an entry under the banners: array. Note that this array must always be
valid, so if there are no banners in the file, it must contain at least
`global_banners: []`

### Example banner entry

```
global_banners:
- name: Banner 1
  title: "Register to Vote"
  title_href: /register-to-vote
  text: "You must register to vote before the election"
  always_visible: false
  exclude_paths:
  - /find-your-local-electoral-office
  start_date: 2024/10/21
  end_date: 2024/11/18
```
Each banner must include a `title`, `title_href`, `text`, and a valid `start_date`.
`title_href` can be either a valid URL or a path on gov.uk.

> [!NOTE]
>
> `start_date` is **mandatory** here (unlike in recruitment banners) because it's
> needed to create a banner_version to pass to the underlying component. This lets
> the component reset the cookie that records how many times a banner has been seen
> (by default banners are shown only three times, see the `always_visible` option below.)

Optional keys are:
- `name` (an identifying name for this banner, not rendered
  anywhere)
- `always_visible` (defaults to false. If false, banner is hidden if the user
  has consented to cookies and has seen this banner more than 3 times)
- `exclude_paths` an array of paths on which the banner should not be shown.
  Note that the banner is never shown on the path it points to, this
  list is to include any additional pages.
- `end_date` (the banner stops being active at the *start* of the day
  specified as `end_date`). Start and end dates must be in the YYYY/MM/DD
  format parsable as a YAML -> Date.

### Validations on the global banners config file

The config file will be checked during CI, so an invalid file can't be released
as a gem and we are nudged to make sure it's kept tidy. These checks include:

* the global_banners array must be a valid YAML array
* all banners have a `title`, `title_href`, and `info_text`.
* all banners must have a valid `start_date`.

It will also display warnings (but not fail CI)

* if there are banners that have expired - you are encouraged to remove
  obsolete config, but it will not prevent you merging changes.
* if `title_href` of any banner points to a page that are not currently live on
  GOV.UK - this may be intentional (if the banner points to a page that isn't
  yet published), or it may indicate a typo in the path.
* if any `exclude_paths` value points to a page that is not currently live on
  GOV.UK - this may be intentional, or it may indicate a typo in the path.
* if two global banners will be active on the same day (this is only a warning
  because ultimately we may need this, but the current iteration of the
  component does not support it)

Note that some of this validation code is in the
`/lib/govuk_web_banners/validators/global_banner.rb` file, which should be
tested to ensure the checking is valid, but will not be bundled into the
released gem.

### Required stylesheets

If you're not including the style dependencies as above, and not using
single-component autoloading of styles, you'll need to import:

`@import "govuk_web_banners/components/global-banner"`

## Adding recruitment banners

Add a call to the partial in the layout or view that you want banners to appear
in (typically recruitment banners should be in the layout, below the
breadcrumbs and just above the `main` element):

```
  <%= render "govuk_web_banners/recruitment_banner" %>
```

### Required stylesheets

If you're not including the style dependencies as above, and not using
single-component autoloading of styles, you'll need to import:

`@import "govuk_web_banners/components/intervention"`

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
  start_date: 2024/10/21
  end_date: 2024/11/18
  image: hmrc
```

The required keys are `suggestion_text`, `suggestion_link_text`, and
`survey_url` (the values to appear in the banner), and `page_paths` (an array of
paths on which the banner should be shown).

Optional keys are:
- `name` (an identifying name for this banner, not rendered
  anywhere)
- `start_date` the banner becomes active at the *start* of the day specified.
  Must be in the YYYY/MM/DD format parsable as a YAML -> Date.
- `end_date` (the banner stops being active at the *start* of the day
  specified). Must be in the YYYY/MM/DD format parsable as a YAML -> Date.
- `image` an image name supported by the [interaction banner image option](https://components.publishing.service.gov.uk/component-guide/intervention#with_image)
  Currently the only allowable value is `hmrc`.

### Validations on the recruitment banners config file

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
`lib/govuk_web_banners/validator/recruitment_banner.rb` file, which should be
tested to ensure the checking is valid, but will not be bundled into the
released gem.

## License
The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
