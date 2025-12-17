Redmine::Plugin.register :redmine_user_lockout do
  name 'Redmine User Lockout plugin'
  author 'taikii'
  description ''
  version '1.0.0'
  url 'https://github.com/taikii/redmine_user_lockout'
  author_url 'https://github.com/taikii/'

  settings :default => { 'lockout_threshold' => 10, 'custom_field_id' => 0 },
           :partial => 'settings/redmine_user_lockout_settings'

end

require File.expand_path('lib/redmine_user_lockout/account_controller_patch', __dir__)
require File.expand_path('lib/redmine_user_lockout/user_lockout_hook_listener', __dir__)
