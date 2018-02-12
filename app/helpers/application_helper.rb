module ApplicationHelper
  def site_name
    "Swing Left Localhost"
  end

  def cause_name
    "Swing Left Localhost"
  end

  def site_hostname(request)
    request.host_with_port
  end

  def logo_light
    "logo-light.png"
  end

  def logo_dark
    "logo-dark.png"
  end

  def email_contact
    "admin@peopleshousing.com"
  end

  def privacy_policy_link
    "https://github.com/samuelcole/MarchBNB/blob/master/doc/facebook-privacy-statement.txt"
  end

  def bug_report_link
    "https://github.com/samuelcole/MarchBNB/issues"
  end

  def github_link
    "https://github.com/samuelcole/MarchBNB"
  end
end
