class GroupMailer < ActionMailer::Base
  default :from => "noreply@opencongress.org"
  
  def invite_email(group_invite)
    @to_email = group_invite.user.nil? ? group_invite.email : group_invite.user.email
    @from_email = group_invite.group.user.email
    @group_invite = group_invite
    
    mail(:to => @to_email, :from => @from_email,
    :subject => "Join my OpenCongress Group '#{group_invite.group.name}'")
  end
  
  def boot_email(group, member)
    @group_name = group.name
    
    mail(:to => member.email, :subject => "You have been booted from an OpenCongress group!")
  end
end
