output "vps_id" {
  description = "The ID of the created VPS instance"
  value       = hostinger_vps.openclaw.id
}

output "vps_ip_address" {
  description = "Public IP address of the VPS"
  value       = hostinger_vps.openclaw.ipv4_address
}

output "dashboard_url" {
  description = "OpenClaw dashboard URL"
  value       = "http://${hostinger_vps.openclaw.ipv4_address}:18789"
}

output "ssh_command" {
  description = "SSH command to connect to the VPS"
  value       = "ssh root@${hostinger_vps.openclaw.ipv4_address}"
}

output "ssh_key_id" {
  description = "ID of the SSH key resource"
  value       = hostinger_vps_ssh_key.openclaw_key.id
}

output "first_login_instructions" {
  description = "Instructions for first login and configuration"
  value       = <<-EOT

    ========================================
    OpenClaw Job Search Agent - First Login
    ========================================

    1. SSH into your VPS:
       ${join(" ", ["ssh", "root@${hostinger_vps.openclaw.ipv4_address}"])}

    2. Check OpenClaw status:
       cd /root/openclaw
       docker compose ps

    3. View OpenClaw logs:
       docker compose logs -f

    4. Access the dashboard:
       ${join("", ["http://", hostinger_vps.openclaw.ipv4_address, ":18789"])}

    5. Customize your job search configuration:
       - Edit /root/workspace/SOUL.md (agent personality)
       - Edit /root/workspace/cv_latest.md (add your CV)
       - Review /root/workspace/HEARTBEAT.md (search schedule)
       - Check /root/workspace/applications_tracker.csv

    6. Restart OpenClaw to apply changes:
       docker compose restart gateway

    7. Monitor job search activity:
       tail -f /root/workspace/sent_emails.log
       tail -f /root/workspace/MEMORY.md

    IMPORTANT SECURITY NOTES:
    - Review and customize .env file with your API keys
    - The agent will only send notifications to: ${var.user_email}
    - Email sending requires your approval (check SECURITY.md)
    - Never auto-applies to jobs - only provides notifications

    EOT
}
