module RedmineUserLockout
	class UserLockoutHookListener < Redmine::Hook::ViewListener

		def controller_account_success_authentication_after(context)
			Rails.logger.debug "controller_account_success_authentication_after"
			cvs = CustomValue.where(custom_field_id: Setting.plugin_redmine_user_lockout['custom_field_id'], customized: context[:user].id.to_s)
			if cvs.length > 0
				cv = cvs[0]
				Rails.logger.debug "Reset CustomValue '#{context[:user].login}' / '#{context[:user].id}' / #{cv.value} -> 0"
				cv.value = 0
				cv.save
			else
				Rails.logger.debug "CustomValue is not found '#{context[:user].login}' / '#{context[:user].id}'"
			end
		end

		def controller_account_failed_authentication_after(context)
			Rails.logger.debug "controller_account_failed_authentication_after"

			if Setting.plugin_redmine_user_lockout['lockout_threshold'].to_i > 0
				if Setting.plugin_redmine_user_lockout['custom_field_id'].to_i <= 0
					cf = UserCustomField.new(:name => 'Login failed count', :field_format => 'int', :editable => false, :visible => false)
					cf.save
					setting = Setting.send :plugin_redmine_user_lockout
					setting['custom_field_id'] = cf.id.to_s
					Setting.send :"plugin_redmine_user_lockout=", setting
					Rails.logger.info "Create UserCustomField '#{cf.id}'"
				else
					Rails.logger.debug "Using UserCustomField '#{Setting.plugin_redmine_user_lockout['custom_field_id']}'"
				end

				user = User.find_by_login(context[:params][:username])
				unless user.nil?
					Rails.logger.debug "User found '#{context[:params][:username]}' / '#{user.id}'"
					if user.status == User::STATUS_ACTIVE
						Rails.logger.debug "User is active '#{context[:params][:username]}' / '#{user.id}' / '#{user.status}'"
						cvs = CustomValue.where(custom_field_id: Setting.plugin_redmine_user_lockout['custom_field_id'], customized: user.id.to_s)
						if cvs.length == 0
							Rails.logger.debug "Create CustomValue '#{context[:params][:username]}' / '#{user.id}'"
							cf = CustomField.where(:id => Setting.plugin_redmine_user_lockout['custom_field_id'])[0]
							cv = CustomValue.new(:custom_field => cf,
									:customized => user,
									:value => '1')
							cv.save
						else
							cv = cvs[0]
							cv.value = cv.value.to_i + 1
							Rails.logger.debug "Increment CustomValue '#{context[:params][:username]}' / '#{user.id}' / #{cv.value}"
							cv.save
						end

						if cv.value.to_i > Setting.plugin_redmine_user_lockout['lockout_threshold'].to_i
							Rails.logger.info "Lockout user '#{context[:params][:username]}' / '#{user.id}' / '#{cv.value} > #{Setting.plugin_redmine_user_lockout['lockout_threshold']}'"
							user.lock
							user.save

							::Mailer.security_notification(
								user,
								User.current,
								{
									title: :lockout_notify_mail_subject,
									message: 'lockout_notify_mail_body',
									url: {controller: 'my', action: 'account'}
								}
							).deliver
						else
							Rails.logger.debug "Not lockout '#{context[:params][:username]}' / '#{user.id}' / '#{cv.value} <= #{Setting.plugin_redmine_user_lockout['lockout_threshold']}'"
						end
					else
						Rails.logger.debug "User is not active '#{context[:params][:username]}' / '#{user.id}' / '#{user.status}'"
					end
				else
					Rails.logger.debug "User not found '#{context[:params][:username]}'"
				end
			end
		end
	end
end
