locals {
  post_install_script = templatefile("${path.module}/scripts/post-install.sh", {
    user_email            = var.user_email
    user_full_name        = var.user_full_name
    target_location       = var.target_location
    target_roles          = var.target_roles
    min_salary            = var.min_salary
    max_commute_minutes   = var.max_commute_minutes
    anthropic_api_key     = var.anthropic_api_key
    openai_api_key        = var.openai_api_key
    smtp_host             = var.smtp_host
    smtp_port             = var.smtp_port
    smtp_user             = var.smtp_user
    smtp_password         = var.smtp_password
    smtp_from             = var.smtp_from
    telegram_bot_token    = var.telegram_bot_token
    telegram_chat_id      = var.telegram_chat_id
    whatsapp_token        = var.whatsapp_token
  })

  soul_content = templatefile("${path.module}/templates/SOUL.md", {
    user_full_name      = var.user_full_name
    user_email          = var.user_email
    target_location     = var.target_location
    target_roles        = var.target_roles
    min_salary          = var.min_salary
    max_commute_minutes = var.max_commute_minutes
  })

  heartbeat_content = templatefile("${path.module}/templates/HEARTBEAT.md", {
    user_email = var.user_email
  })
}

# SSH Key Resource
resource "hostinger_vps_ssh_key" "openclaw_key" {
  name       = "openclaw-jobseeker-key"
  public_key = var.ssh_public_key
}

# VPS Instance
resource "hostinger_vps" "openclaw" {
  hostname        = var.hostname
  plan            = var.vps_plan
  data_center_id  = var.data_center_id
  os_image        = var.os_image
  ssh_key_ids     = [hostinger_vps_ssh_key.openclaw_key.id]

  # Bootstrap script executed on first boot
  post_install_script = local.post_install_script

  # Firewall rules
  firewall_rules = [
    {
      name        = "allow-ssh"
      port        = 22
      protocol    = "tcp"
      source_cidr = "0.0.0.0/0"
    },
    {
      name        = "allow-openclaw-dashboard"
      port        = 18789
      protocol    = "tcp"
      source_cidr = "0.0.0.0/0"
    },
    {
      name        = "allow-http"
      port        = 80
      protocol    = "tcp"
      source_cidr = "0.0.0.0/0"
    },
    {
      name        = "allow-https"
      port        = 443
      protocol    = "tcp"
      source_cidr = "0.0.0.0/0"
    }
  ]

  tags = [
    "openclaw",
    "job-search-agent",
    "production"
  ]
}
