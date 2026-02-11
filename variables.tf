variable "hostinger_api_token" {
  description = "Hostinger API token for authentication"
  type        = string
  sensitive   = true
}

variable "vps_plan" {
  description = "Hostinger VPS plan identifier"
  type        = string
  default     = "hostingercom-vps-kvm2-usd-1m"
}

variable "data_center_id" {
  description = "Hostinger data center ID (e.g., 'us-west', 'eu-central', 'asia-singapore')"
  type        = string
  default     = "eu-central"
}

variable "hostname" {
  description = "VPS hostname"
  type        = string
  default     = "openclaw-jobseeker"
}

variable "ssh_public_key" {
  description = "SSH public key for VPS access"
  type        = string
}

variable "os_image" {
  description = "Operating system image for the VPS"
  type        = string
  default     = "ubuntu-22.04"
}

# Job Search Agent Configuration
variable "user_full_name" {
  description = "User's full name for job applications"
  type        = string
  default     = "YOUR_FULL_NAME"
}

variable "user_email" {
  description = "Email address for job search notifications (dedicated, not personal inbox)"
  type        = string
}

variable "target_location" {
  description = "Target job location"
  type        = string
  default     = "Central London"
}

variable "target_roles" {
  description = "Target job roles (comma-separated)"
  type        = string
  default     = "Mental Health Support Worker,SEN Support Assistant,Therapy Assistant,Healthcare Assistant,Youth Support Worker"
}

variable "min_salary" {
  description = "Minimum acceptable salary"
  type        = string
  default     = "£22000"
}

variable "max_commute_minutes" {
  description = "Maximum commute time in minutes"
  type        = number
  default     = 60
}

# LLM Provider Configuration
variable "anthropic_api_key" {
  description = "Anthropic (Claude) API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
  default     = ""
}

# Email Configuration (for agent notifications)
variable "smtp_host" {
  description = "SMTP host for sending notification emails"
  type        = string
  default     = ""
}

variable "smtp_port" {
  description = "SMTP port"
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "SMTP username"
  type        = string
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_from" {
  description = "From email address for notifications"
  type        = string
  default     = ""
}

# Optional Messaging Integration
variable "telegram_bot_token" {
  description = "Telegram bot token (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "telegram_chat_id" {
  description = "Telegram chat ID for notifications (optional)"
  type        = string
  default     = ""
}

variable "whatsapp_token" {
  description = "WhatsApp API token (optional)"
  type        = string
  sensitive   = true
  default     = ""
}
