class UsersController < ApplicationController

  def edit
    @user = User.find_by_id UserParams.build(params).fetch(:id)
  end

  # we should allow logged in users to update their pending_organisation_id
  # and only superadmins should be allowed to update organisation_id
  # makes me think of a attributes permissions matrix
  def update
    usr = User.find_by_id UserParams.build(params).fetch(:id)
    UserOrganisationClaimer.new(self, usr, usr).call(UserParams.build(params).fetch(:pending_organisation_id))
  end

  def update_message_for_superadmin_status
    org = Organisation.find(UserParams.build(params).fetch(:pending_organisation_id))
    flash[:notice] = "You have requested superadmin status for #{org.name}"
    send_email_to_site_superadmin_about_request_for_superadmin_of org   # could be moved to an hook on the user model?
    redirect_to organisation_path(UserParams.build(params).fetch(:pending_organisation_id))
  end

  def send_email_to_site_superadmin_about_request_for_superadmin_of org
    superadmin_emails = User.superadmins.pluck(:email)
    AdminMailer.new_user_waiting_for_approval(org.name, superadmin_emails).deliver
  end
  class UserParams
    def self.build params
      params.permit(
          :id,
          :email,
          :password,
          :password_confirmation,
          :remember_me,
          :pending_organisation_id
      )
    end
  end
end
