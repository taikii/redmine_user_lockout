
require_dependency 'project'

module RedmineUserLockout
  module AccountControllerPatch
    
    def invalid_credentials
        call_hook(:controller_account_failed_authentication_after, {:params => params})
        super
    end
  end
end

AccountController.prepend(RedmineUserLockout::AccountControllerPatch)
